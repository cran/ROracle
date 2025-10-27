/* Copyright (c) 2011, 2025, Oracle and/or its affiliates. */
/* All rights reserved.*/

/*
   NAME
     roociload.c

   DESCRIPTION
     Load OCI functions from Oracle Client library used by ROracle.so for R.
   On Linux/UNIX libclntsh.so is loaded and all OCI public functions are
   resolved dyanmically. On Windows OCI.DLL is used to load the various
   OCI public functiosn used by ROracle.

   EXPORT FUNCTION(S)
     roociload__loadLib - Dynamially LOAD Oracle Client LIBrary

   INTERNAL FUNCTION(S)
     NONE

   NOTES

   MODIFIED   (MM/DD/YY)
   rpingte     10/17/25 - change __FUNCTION__ to __func__
   rpingte     09/01/24 - fix debug printf
   rpingte     07/11/24 - fix compiler warnigs with pre-19c clients
   brusures    07/10/24 - Bug 36827031 : include syscall.h only for linux
   rpingte     01/24/24 - Creation from odpi-c
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#if defined _WIN32 || defined __CYGWIN__
# include <windows.h>
#else
# define _GNU_SOURCE
# define __USE_GNU
# include <errno.h>
# include <pthread.h>
# include <sys/time.h>
# include <time.h>
# include <dlfcn.h>
#endif

#ifdef __linux
# include <unistd.h>
# include <sys/syscall.h>
#endif

#ifndef OCI_ORACLE
# include <oci.h>
#endif

#include "rooci.h"
#include "rodbi.h"
#include "roociload.h"

#define RORACLE_ERR_CREATE_ENV_MSG      \
  _("unable to acquire Oracle environment handle")
#define RORACLE_ERR_LOAD_LIBRARY_MSG    \
  _("Cannot locate a %s-bit Oracle Client library: \"%s\". See %s for help")
#define RORACLE_ERR_LOAD_SYMBOL_MSG     \
  _("symbol %s not found in OCI library")
#define RORACLE_ERR_ORACLE_CLIENT_UNSUPPORTED_MSG \
  _("the Oracle Client library version is unsupported")
#define RORACLE_ERR_GET_FAILED_MSG      \
  _("unable to get error message")
#define RORACLE_ERR_NO_MEMORY_MSG       \
  _("out of memory")
#define RORACLE_ERR_NLS_ENV_VAR_GET_MSG \
  _("unable to get NLS environment variable")
#define RORACLE_ERR_OS_MSG              \
  _("OS error: %s (%s) Oracle client library is not found in the specified PATH")
#define RORACLE_ERR_NOT_INITIALIZED_MSG \
  _("internal error: OCI handle is not initialized")
#define RORACLE_ERR_INVALID_HANDLE_MSG \
  _("internal error: OCI handle is invalid")
#define RORACLE_ERR_OCI_ERROR_MSG \
  _("OCI error %.*s (%s / %s)\n")
#define RORACLE_ERR_UNKNOWN_MSG         \
  _("internal err message not found")

#define RORACLE_DEBUG_THREAD_FORMAT         "%.5" PRIu64
#define RORACLE_DEBUG_DATE_FORMAT           "%.4d-%.2d-%.2d"
#define RORACLE_DEBUG_TIME_FORMAT           "%.2d:%.2d:%.2d.%.3d"

// debug level (populated by environment variable RORACLE_DEBUG_LEVEL)
unsigned long roociloadDebugLevel = 0;
#define ROOCILOAD_DEBUG_LEVEL_ERRORS 1
#define ROOCILOAD_DEBUG_LEVEL_MEM    2
#define RORACLE_DEBUG_LEVEL_UNREPORTED_ERRORS 4
#define RORACLE_DEBUG_LEVEL_LOAD_LIB 8


/* define structure used for loading the OCI library */
typedef struct
{
  void   *handle;
  char   *nameBuffer;
  size_t  nameBufferLength;
  char   *moduleNameBuffer;
  size_t  moduleNameBufferLength;
  char   *loadError;
  size_t  loadErrorLength;
  char   *errorBuffer;
  size_t  errorBufferLength;
} roociloadLibParams;


/* forward declarations of internal functions only used in this file */
static sword roociload__loadLibValidate(roociloadVersion *versionInfo,
                                        roociloadCtx *lCtx);

static sword roociload__loadLibWithDir(roociloadLibParams *loadParams,
                                       const char *dirName,
                                       size_t dirNameLength, int scanAllNames,
                                       roociloadCtx *lCtx);

static sword roociload__loadLibWithName(roociloadLibParams *loadParams,
                                        const char *libName,
                                        roociloadCtx *lCtx);

//-----------------------------------------------------------------------------
// ROOCILOADFNTYPE__LOADSYMBOL() [INTERNAL]
//   Return the symbol for the function that is to be called. The symbol table
// is first consulted. If the symbol is not found there, it is looked up and
// then stored there so the next invocation does not have to perform the
// lookup.
//-----------------------------------------------------------------------------
#ifdef _WIN32
#define ROOCILOADFNTYPE__LOADSYMBOL(_fnType, _symbolName, _symbol, _loadCtx, \
                                    _status)                                 \
do                                                                           \
{                                                                            \
  *(_symbol)=(_fnType)GetProcAddress((_loadCtx)->loadLibHandle__roociloadCtx,\
                                     #_symbolName);                          \
  if (!*(_symbol))                                                           \
    *(_status) = roociload__set((_loadCtx), "get symbol",                    \
                                RORACLE_ERR_LOAD_SYMBOL, #_symbolName);      \
                                                                             \
} while(0)
#endif

#ifndef _WIN32
#define ROOCILOADFNTYPE__LOADSYMBOL(_fnType, _symbolName, _symbol, _loadCtx, \
                                    _status)                                 \
do                                                                           \
{                                                                            \
  *((void **)_symbol) = dlsym((_loadCtx)->loadLibHandle__roociloadCtx,       \
                              #_symbolName);                                 \
  if (!*(_symbol))                                                           \
    *(_status) = roociload__set((_loadCtx), "get symbol",                    \
                                RORACLE_ERR_LOAD_SYMBOL, #_symbolName);      \
                                                                             \
} while(0)
#endif



static sword roociload__set(roociloadCtx *lCtx, const char *action,
                            roociloadErrorNum errorNum, ...);

static sword roociload__checkClientVersion(roociloadVersion *versionInfo,
                                           int minVersionNum, int minReleaseNum,
                                           roociloadCtx *lCtx);

static void roociloadDebug__print(const char *format, ...);

#if defined _WIN32 || defined __CYGWIN__
#else
  static int roociload__allocateMemory(size_t numMembers, size_t memberSize,
                                       int clearMemory, const char *action,
                                       void **ptr, roociloadCtx *lCtx);
#endif

static void roociload__freeMemory(void *ptr);

#if defined _WIN32 || defined __CYGWIN__
  static int roociload__getWindowsError(DWORD errorNum, char **buffer,
                                        size_t *bufferLength,
                                        roociloadCtx *lCtx);
#endif

/* macro to simplify code for loading each symbol */
#define ROOCILOAD_LOAD_SYMBOL(_fnType, _symbolName, _symbol, _ldctx)     \
do                                                                       \
{                                                                        \
  sword status = 0;                                                      \
  if (!_symbol)                                                          \
  {                                                                      \
    if (roociloadDebugLevel & ROOCILOAD_DEBUG_LEVEL_ERRORS)              \
      roociloadDebug__print("%s:%d: symbol cannot be null\n",            \
                            __func__, __LINE__);                         \
    status = roociload__set((_ldctx),                                    \
                          "internal error address of symbol not passed", \
                           RORACLE_ERR_LOAD_SYMBOL, #_symbolName);       \
    return ROOCI_DRV_ERR_LOAD_FAIL;                                      \
  }                                                                      \
  else                                                                   \
    ROOCILOADFNTYPE__LOADSYMBOL(_fnType, _symbolName, _symbol, _ldctx,   \
                                &status);                                \
  if (status < 0)                                                        \
  {                                                                      \
    if (roociloadDebugLevel & ROOCILOAD_DEBUG_LEVEL_ERRORS)              \
      roociloadDebug__print("%s:%d: symbol cannot be null\n",            \
                            __func__, __LINE__);                         \
    return ROOCI_DRV_ERR_LOAD_FAIL;                                      \
  }                                                                      \
} while (0)


#define ROOCILOAD_ERROR_OCCURRED(status)                                 \
  (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)


#define ROOCILOAD_CHECK_AND_RETURN(_error, _status, _action)                \
do                                                                          \
{                                                                           \
  if ((roociloadDebugLevel & ROOCILOAD_DEBUG_LEVEL_ERRORS) &&               \
      ((_status) != OCI_SUCCESS))                                           \
  {                                                                         \
    roociloadDebug__print("error encountered in function %s at line %d\n",  \
                          __func__, __LINE__);                              \
    loadCtx_g->fnName_roociloadCtx = __func__;                              \
    return roociload__setFromOCI((_error), (_status), (_action));           \
  }                                                                         \
  else                                                                      \
    return (_status);                                                       \
} while (0)


/* typedefs for all OCI functions used by ROracle.so */
typedef sword (*roociloadFnType__arrayDescriptorAlloc)(const void *parenth,
        void **descpp, const ub4 type, ub4 array_size, const size_t xtramem_sz,
        void  **usrmempp);
typedef sword (*roociloadFnType__arrayDescriptorFree)(void **descp,
        const ub4 type);
typedef sword (*roociloadFnType__attrGet)(const void *trgthndlp,
        ub4 trghndltyp, void *attributep, ub4 *sizep, ub4 attrtype,
        OCIError  *errhp);
typedef sword (*roociloadFnType__attrSet)(void *trgthndlp, ub4 trghndltyp,
        void *attributep, ub4 size, ub4 attrtype, OCIError *errhp);
typedef sword (*roociloadFnType__bindByName)(OCIStmt *stmhp,
        OCIBind **bindp, OCIError *errhp, const oratext *placeholder,
        sb4 placeh_len, void *valuep, sb4 value_sz, ub2 dty, void  *indp,
        ub2 *alenp, ub2 *rcodep, ub4 maxarr_len, ub4 *curelep, ub4 mode);
typedef sword (*roociloadFnType__bindByName2)(OCIStmt *stmhp,
        OCIBind **bindp, OCIError *errhp, const oratext *placeholder,
        sb4 placeh_len, void  *valuep, sb8 value_sz, ub2 dty, void *indp,
        ub4 *alenp, ub2 *rcodep, ub4 maxarr_len, ub4 *curelep, ub4 mode);
typedef sword (*roociloadFnType__bindByPos)(OCIStmt *stmhp,
        OCIBind **bindp, OCIError *errhp, ub4 position, void *valuep,
        sb4 value_sz, ub2 dty, void  *indp, ub2 *alenp, ub2 *rcodep,
        ub4 maxarr_len, ub4 *curelep, ub4 mode);
typedef sword (*roociloadFnType__bindByPos2)(OCIStmt *stmhp,
        OCIBind **bindp, OCIError *errhp, ub4 position, void  *valuep,
        sb8 value_sz, ub2 dty, void *indp, ub4 *alenp, ub2 *rcodep,
        ub4 maxarr_len, ub4 *curelep, ub4 mode);
typedef sword (*roociloadFnType__bindObject)(OCIBind *bndhp,
        OCIError *errhp, const OCIType *type, void **pgvpp, ub4 *pvszsp,
        void **indpp, ub4 *indszp);
typedef sword (*roociloadFnType__break)(void *hndlp, OCIError *errhp);
typedef void (*roociloadFnType__clientVersion)(sword *featureRelease,
        sword *releaseUpdate, sword *releaseUpdateRevision, sword *increment,
        sword *ext);
typedef sword (*roociloadFnType__collAppend)(OCIEnv *env, OCIError *err,
        const void *elem, const void *elemind, OCIColl *coll);
typedef sword (*roociloadFnType__collAssignElem)(OCIEnv *env, OCIError *err,
        sb4 index, const void *elem, const void *elemind, OCIColl *coll);
typedef sword (*roociloadFnType__collGetElem)(OCIEnv *env, OCIError *err,
        const OCIColl *coll, sb4 index, boolean *exists, void  **elem,
        void  **elemind);
typedef sword (*roociloadFnType__collSize)(OCIEnv *env, OCIError *err,
        const OCIColl *coll, sb4 *size);
typedef sword (*roociloadFnType__collTrim)(OCIEnv *env, OCIError *err,
        sb4 trim_num, OCIColl *coll);
typedef sword (*roociloadFnType__contextGetValue)(void *hdl, OCIError *err,
        ub1 *key, ub1 keylen, void **ctx_value);
typedef sword (*roociloadFnType__contextSetValue)(void *hdl, OCIError *err,
        OCIDuration dur, ub1 *key, ub1 keylen, void  *ctx_value);
typedef sword (*roociloadFnType__dateTimeConstruct)(void *hndl,
        OCIError *err, OCIDateTime *datetime, sb2 year, ub1 month, ub1 day,
        ub1 hour, ub1 min, ub1 sec, ub4 fsec, OraText *timezone,
        size_t timezone_length);
typedef sword (*roociloadFnType__dateTimeGetDate)(void *hndl, OCIError *err,
        const OCIDateTime *datetime, sb2 *year, ub1 *month, ub1 *day);
typedef sword (*roociloadFnType__dateTimeGetTime)(void *hndl, OCIError *err,
        OCIDateTime *datetime, ub1 *hour, ub1 *min, ub1 *sec, ub4 *fsec);
typedef sword (*roociloadFnType__dateTimeGetTimeZoneOffset)(void *hndl,
        OCIError *err, const OCIDateTime *datetime, sb1 *hour, sb1 *minute);
typedef sword (*roociloadFnType__dateTimeIntervalAdd)(void *hndl,
        OCIError *err, OCIDateTime *datetime, OCIInterval *interval,
        OCIDateTime *outdatetime);
typedef sword (*roociloadFnType__dateTimeSubtract)(void *hndl,
        OCIError *err, OCIDateTime *indate1, OCIDateTime *indate2,
        OCIInterval *interval);
typedef sword (*roociloadFnType__dateTimeSysTimeStamp)(void *hndl,
        OCIError *err, OCIDateTime *sys_date);
typedef sword (*roociloadFnType__defineByPos)(OCIStmt *stmhp,
        OCIDefine **defnp, OCIError *errhp, ub4 position, void *valuep,
        sb4 value_sz, ub2 dty, void *indp, ub2 *rlenp, ub2 *rcodep,
        ub4 mode);
typedef sword (*roociloadFnType__defineObject)(OCIDefine  *dfnhp,
        OCIError  *errhp, const OCIType *type, void **pgvpp, ub4 *pvszsp,
        void **indpp, ub4 *indszp);
typedef sword (*roociloadFnType__describeAny)(OCISvcCtx *svchp,
        OCIError *errhp, void  *objptr, ub4 objptr_len, ub1 objptr_typ,
        ub1 info_level, ub1 objtype, OCIDescribe *dschp);
typedef sword (*roociloadFnType__descriptorAlloc)(const void *parenth,
        void **descpp, const ub4 type, const size_t xtramem_sz,
        void **usrmempp);
typedef sword (*roociloadFnType__descriptorFree)(void *descp, const ub4 type);
typedef sword (*roociloadFnType__envCreate)(OCIEnv **envp,
        ub4 mode, void *ctxp,
        void    *(*malocfp)(void  *ctxp, size_t size),
        void    *(*ralocfp)(void  *ctxp, void  *memptr, size_t newsize),
        void     (*mfreefp)(void  *ctxp, void  *memptr),
        size_t   xtramem_sz, void   **usrmempp);
typedef sword (*roociloadFnType__envNlsCreate)(OCIEnv **envp,
        ub4 mode, void  *ctxp,
        void  *(*malocfp)(void  *ctxp, size_t size),
        void  *(*ralocfp)(void  *ctxp, void  *memptr, size_t newsize),
        void (*mfreefp)(void  *ctxp, void  *memptr),
        size_t xtramem_sz, void **usrmempp, ub2 charset, ub2 ncharset);
typedef sword (*roociloadFnType__errorGet)(void *hndlp, ub4 recordno,
        oratext *sqlstate, sb4 *errcodep, oratext *bufp,
        ub4 bufsiz, ub4 type);
typedef sword (*roociloadFnType__handleAlloc)(const void *parenth,
        void **hndlpp, const ub4 type, const size_t xtramem_sz,
        void  **usrmempp);
typedef sword (*roociloadFnType__handleFree)(void *hndlpp, const ub4 type);
typedef sword (*roociloadFnType__intervalGetDaySecond)(void *hndl,
        OCIError *err, sb4 *day, sb4 *hour, sb4 *min, sb4 *sec,
        sb4 *fsec, const OCIInterval *result);
typedef sword (*roociloadFnType__intervalGetYearMonth)(void *hndl,
        OCIError *err, sb4 *year, sb4 *month, const OCIInterval *result);
typedef sword (*roociloadFnType__intervalSetDaySecond)(void *hndl,
        OCIError *err, sb4 day, sb4 hour, sb4 min, sb4 sec,
        sb4 fsec, OCIInterval *result);
typedef sword  (*roociloadFnType__iterCreate)(OCIEnv *env,
        OCIError *err, const OCIColl *coll, OCIIter **itr);
typedef sword  (*roociloadFnType__iterNext)(OCIEnv *env,
        OCIError *err, OCIIter *itr, void **elem,
        void **elemind, boolean *eoc);
typedef sword (*roociloadFnType__interCreate)(OCIEnv *env,
        OCIError *err, const OCIColl *coll, OCIIter **itr);
typedef sword (*roociloadFnType__lobClose)(OCISvcCtx *svchp,
        OCIError *errhp, OCILobLocator *locp);
typedef sword (*roociloadFnType__lobCreateTemporary)(OCISvcCtx *svchp,
        OCIError *errhp, OCILobLocator *locp, ub2 csid, ub1 csfrm,
        ub1 lobtype, boolean cache, OCIDuration duration);
typedef sword (*roociloadFnType__lobFileClose)(OCISvcCtx *svchp,
        OCIError *errhp, OCILobLocator *filep);
typedef sword (*roociloadFnType__lobFileOpen)(OCISvcCtx *svchp,
        OCIError *errhp, OCILobLocator *filep, ub1 mode);
typedef sword (*roociloadFnType__lobFileExists)(OCISvcCtx *svchp,
        OCIError *errhp, OCILobLocator *filep, boolean *flag);
typedef sword (*roociloadFnType__lobFileSetName)(OCIEnv *envp,
        OCIError *errhp, OCILobLocator **locator, const oratext *dir_alias,
        ub2 d_length, const oratext *filename, ub2 f_length);
typedef sword (*roociloadFnType__lobFreeTemporary)(OCISvcCtx *svchp,
        OCIError *errhp, OCILobLocator *locp);
typedef sword (*roociloadFnType__lobGetChunkSize)(OCISvcCtx *svchp,
        OCIError *errhp, OCILobLocator *locp, ub4 *chunksizep);
typedef sword (*roociloadFnType__lobGetLength2)(OCISvcCtx *svchp,
        OCIError *errhp, OCILobLocator *lobdp, oraub8 *lenp);
typedef sword (*roociloadFnType__lobLocatorAssign)(OCISvcCtx *svchp,
        OCIError *errhp, const OCILobLocator *source,
        OCILobLocator **destination);
typedef sword (*roociloadFnType__lobOpen)(OCISvcCtx *svchp,
        OCIError *errhp, OCILobLocator *filep, ub1 mode);
typedef sword (*roociloadFnType__lobRead2)(OCISvcCtx *svchp,
        OCIError *errhp, OCILobLocator *lobp, oraub8 *byte_amtp,
        oraub8 *char_amtp, oraub8 offset, void  *bufp, oraub8 bufl,
        ub1 piece, void  *ctxp, OCICallbackLobRead2 cbfp, ub2 csid, ub1 csfrm);
typedef sword (*roociloadFnType__lobTrim2)(OCISvcCtx *svchp,
        OCIError *errhp, OCILobLocator *lobdp, oraub8 new_length);
typedef sword (*roociloadFnType__lobWrite2)(OCISvcCtx *svchp,
        OCIError *errhp, OCILobLocator *locp, oraub8 *byte_amtp,
        oraub8 *char_amtp, oraub8 offset, void  *bufp, oraub8 buflen,
        ub1 piece, void  *ctxp, OCICallbackLobWrite2 cbfp, ub2 csid, ub1 csfrm);
typedef sword (*roociloadFnType__memoryAlloc)(void *hdl, OCIError *err,
        void **mem, OCIDuration dur, ub4 size, ub4 flags);
typedef sword (*roociloadFnType__memoryFree)(void *hdl,
        OCIError *err, void *mem);
typedef sword (*roociloadFnType__nlsCharSetConvert)(void *envhp,
        OCIError *errhp, ub2 dstid, void *dstp, size_t dstlen,
        ub2 srcid, const void  *srcp, size_t srclen, size_t *rsize);
typedef sword (*roociloadFnType__nlsCharSetIdToName)(void *envhp,
        oratext *buf, size_t buflen, ub2 id);
typedef ub2 (*roociloadFnType__nlsCharSetNameToId)(void *envhp,
        const oratext *name);
typedef sword (*roociloadFnType__nlsEnvironmentVariableGet)(void *val,
        size_t size, ub2 item, ub2 charset, size_t *rsize);
typedef sword (*roociloadFnType__nlsNameMap)(void *envhp,
        oratext *buf, size_t buflen, const oratext *srcbuf, ub4 flag);
typedef sword (*roociloadFnType__nlsNumericInfoGet)(void *envhp,
        OCIError *errhp, sb4 *val, ub2 item);
typedef sword (*roociloadFnType__numberFromInt)(OCIError *err,
        const void  *inum, uword inum_length, uword inum_s_flag,
        OCINumber *number);
typedef sword (*roociloadFnType__numberFromReal)(OCIError *err,
        const OCINumber *number, uword rsl_length, void  *rsl);
typedef sword (*roociloadFnType__numberToInt)(OCIError *err,
        const OCINumber *number, uword rsl_length, uword rsl_flag, void *rsl);
typedef sword (*roociloadFnType__numberToReal)(OCIError *err,
        const OCINumber *number, uword rsl_length, void *rsl);
typedef sword (*roociloadFnType__objectCopy)(OCIEnv *env, OCIError *err,
        const OCISvcCtx *svc, void *source, void *null_source,
        void *target, void *null_target, OCIType *tdo,
        OCIDuration duration, ub1 option);
typedef sword (*roociloadFnType__objectFree)(OCIEnv *env,
        OCIError *err, void  *instance, ub2 flag);
typedef sword (*roociloadFnType__objectGetAttr)(OCIEnv *env,
        OCIError *err, void *instance, void *null_struct, OCIType *tdo,
        const oratext   **names, const ub4 *lengths, const ub4 name_count,
        const ub4 *indexes, const ub4 index_count, OCIInd *attr_null_status,
        void **attr_null_struct, void **attr_value, OCIType **attr_tdo);
typedef sword (*roociloadFnType__objectGetInd)(OCIEnv *env, OCIError *err,
        void *instance, void **null);
typedef sword (*roociloadFnType__objectGetTypeRef)(OCIEnv *env,
        OCIError *err, void *instance, OCIRef *tdo_ref);
typedef sword (*roociloadFnType__objectNew)(OCIEnv *env, OCIError *err,
        const OCISvcCtx *svc, OCITypeCode tc, OCIType *tdo, void  *table,
        OCIDuration pin_duration, boolean value, void **instance);
typedef sword (*roociloadFnType__objectPin)(OCIEnv *env, OCIError *err,
        OCIRef *object_ref, OCIComplexObject *corhdl, OCIPinOpt pin_opt,
        OCIDuration pin_dur, OCILockOpt lock_opt, void **object);
typedef sword (*roociloadFnType__objectSetAttr)(OCIEnv *env, OCIError *err,
        void *instance, void  *null_struct, struct OCIType *tdo,
        const oratext **names, const ub4 *lengths, const ub4 name_count,
        const ub4 *indexes, const ub4 index_count,
        const OCIInd attr_null_status, const void  *attr_null_struct,
        const void  *attr_value);
typedef sword (*roociloadFnType__paramGet)(const void *hndlp,
        ub4 htype, OCIError *errhp, void **parmdpp, ub4 pos);
typedef sword (*roociloadFnType__passwordChange)(OCISvcCtx *svchp,
        OCIError *errhp, const oratext *user_name, ub4 usernm_len,
        const oratext *opasswd, ub4 opasswd_len, const oratext *npasswd,
        ub4 npasswd_len, ub4 mode);
typedef sword (*roociloadFnType__ping)(OCISvcCtx *svchp,
        OCIError *errhp, ub4 mode);
typedef sword (*roociloadFnType__rawAssignBytes)(OCIEnv *env,
        OCIError *err, const ub1 *rhs, ub4 rhs_len, OCIRaw **lhs);
typedef ub1 *(*roociloadFnType__rawPtr)( OCIEnv *env, const OCIRaw *raw);
typedef ub4 (*roociloadFnType__rawSize)( OCIEnv *env, const OCIRaw *raw);
typedef sword (*roociloadFnType__reset)(void *hndl, OCIError *err);
typedef sword (*roociloadFnType__rowidToChar)(OCIRowid *rowidDesc,
        oratext *outbfp, ub2 *outbflp, OCIError *errhp);
typedef sword (*roociloadFnType__serverRelease)(void *hndlp, OCIError *errhp,
        oratext *bufp, ub4 bufsz, ub1 hndltype, ub4 *version);
typedef sword (*roociloadFnType__serverVersion)(void *hndlp, OCIError *errhp,
        oratext *bufp, ub4 bufsz, ub1 hndltype);
typedef sword (*roociloadFnType__sessionGet)(OCIEnv *envhp, OCIError *errhp,
        OCISvcCtx **svchp, OCIAuthInfo *sechp, OraText *poolName,
        ub4 poolNameLen, const OraText *tagInfo, ub4 tagInfoLen,
        OraText **retTagInfo, ub4 *retTagInfoLen, boolean *found, ub4 mode);
typedef sword (*roociloadFnType__sessionPoolDestroy)(OCICPool *poolhp,
        OCIError *errhp, ub4 mode);
typedef sword (*roociloadFnType__sessionRelease)(OCISvcCtx *svchp,
        OCIError *errhp, OraText *tag, ub4 tagLen, ub4 mode);
typedef sword (*roociloadFnType__stmtExecute)(OCISvcCtx *svchp,
        OCIStmt *stmtp, OCIError *errhp, ub4 iters, ub4 rowoff,
        const OCISnapshot *snap_in, OCISnapshot *snap_out, ub4 mode);
typedef sword (*roociloadFnType__stmtFetch2)(OCIStmt *stmtp, OCIError *errhp,
        ub4 nrows, ub2 orientation, sb4 scrollOffset, ub4 mode);
typedef sword (*roociloadFnType__stmtPrepare)(OCIStmt *stmhp, OCIError *errhp,
        const oratext *stmt, ub4 stmt_len, ub4 language, ub4 mode);
typedef sword (*roociloadFnType__stmtPrepare2)(OCISvcCtx *svchp,
        OCIStmt **stmtp, OCIError *errhp, CONST OraText *stmt, ub4 stmt_len,
        const OraText *key, ub4 key_len, ub4 language, ub4 mode);
typedef sword (*roociloadFnType__stmtRelease)(OCIStmt *stmtp, OCIError *errhp,
        const OraText *key, ub4 key_len, ub4 mode);
typedef sword (*roociloadFnType__stringAssignText)(OCIEnv *env, OCIError *err,
        const oratext *rhs, ub4 rhs_len, OCIString **lhs);
typedef char *(*roociloadFnType__stringPtr)(OCIEnv *env, const OCIString *vs);
typedef sword (*roociloadFnType__stringResize)(OCIEnv *env, OCIError *err,
        ub4 new_size, OCIString **str);
typedef ub4 (*roociloadFnType__stringSize)(OCIEnv *env, const OCIString *vs);
typedef sword (*roociloadFnType__tableFirst)(OCIEnv *env, OCIError *err,
        const OCITable *tbl, sb4 *index);
typedef sword (*roociloadFnType__tableNext)(OCIEnv *env, OCIError *err,
        sb4 index, const OCITable *tbl, sb4 *next_index, boolean *exists);
typedef sword (*roociloadFnType__threadCreate)(void *hndl, OCIError *err,
        void (*start)(void  *), void  *arg, OCIThreadId *tid,
        OCIThreadHandle *tHnd);
typedef sword (*roociloadFnType__threadHndInit)(void *hndl,
        OCIError *err, OCIThreadHandle **tHnd);
typedef sword (*roociloadFnType__threadIdInit)(void *hndl,
        OCIError *err, OCIThreadId **tid);
typedef sword (*roociloadFnType__threadJoin)(void *hndl,
        OCIError *err, OCIThreadHandle *tHnd);
typedef sword (*roociloadFnType__transCommit)(OCISvcCtx *svchp,
        OCIError *errhp, ub4 flags);
typedef sword (*roociloadFnType__transRollback)(OCISvcCtx *svchp,
        OCIError *errhp, ub4 flags);
typedef sword (*roociloadFnType__typeByName)(OCIEnv *envhp,
        OCIError *errhp, const OCISvcCtx *svchp, const oratext *schema_name,
        ub4 schema_name_length, const oratext *type_name,
        ub4 t_length, const oratext *version_name,
        ub4 version_name_length, OCIDuration pin_duration,
        OCITypeGetOpt get_option, OCIType **tdo);
typedef sword (*roociloadFnType__typeByFullName)(OCIEnv *envhp,
        OCIError *errhp, const OCISvcCtx *svchp, const oratext *full_type_name,
        ub4 full_type_name_length, const oratext *version_name,
        ub4 version_name_length, OCIDuration pin_duration,
        OCITypeGetOpt get_option, OCIType **tdo);
typedef sword (*roociloadFnType__unicodeToCharSet)(void *envhp,
        OraText *dst, size_t dstlen, const ub2 *src,
        size_t srclen, size_t *rsize);
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
typedef sword (*roociloadFnType__vectorFromArray)(OCIVector *vectord,
        OCIError *errhp, ub1 vformat, ub4 vdim,
        void *vecarray, ub4 mode);
typedef sword (*roociloadFnType__vectorFromSparseArray)(OCIVector *vectord,
        OCIError *errhp, ub1 vformat, ub4 vdim, ub4 indices,
        void *indarray, void *vecarray, ub4 mode);
typedef sword (*roociloadFnType__vectorFromText)(OCIVector *vectord,
        OCIError *errhp, ub1 vformat, ub4 vdim,
        const OraText *vtext, ub4 vtextlen, ub4 mode);
typedef sword (*roociloadFnType__vectorToArray)(OCIVector *vectord,
        OCIError *errhp, ub1 vformat, ub4 *vdim,
        void *vecarray, ub4 mode);
typedef sword (*roociloadFnType__vectorToSparseArray)(OCIVector *vectord,
        OCIError *errhp, ub1 vformat, ub4 *vdim,
        ub4 *indices, void *indarray, void *vecarray, ub4 mode);
typedef sword (*roociloadFnType__vectorToText)(OCIVector *vectord,
        OCIError *errhp, OraText *vtext, ub4 *vtextlen, ub4 mode);

#endif /* OCI_MAJOR_VERSION >= 23 */
typedef sword (*roociloadFnType__ociepgoe)(OCIExtProcContext *with_context,
        OCIEnv **envh, OCISvcCtx **svch, OCIError **errh);

// library names to search
static const char *roociloadLibNames[] =
{
#if defined _WIN32 || defined __CYGWIN__
  "oci.dll",
#elif __APPLE__
  "libclntsh.dylib",
  "libclntsh.dylib.23.1",
  "libclntsh.dylib.21.1",
  "libclntsh.dylib.20.1",
  "libclntsh.dylib.19.1",
  "libclntsh.dylib.18.1",
  "libclntsh.dylib.12.1",
  "libclntsh.dylib.11.1",
#else
  "libclntsh.so",
  "libclntsh.so.23.1",
  "libclntsh.so.21.1",
  "libclntsh.so.20.1",
  "libclntsh.so.19.1",
  "libclntsh.so.18.1",
  "libclntsh.so.12.1",
  "libclntsh.so.11.1",
#endif
   NULL
};

/* all OCI symbols used by ROracle */
struct roociloadSymbols
{
  roociloadFnType__arrayDescriptorAlloc fnArrayDescriptorAlloc;
  roociloadFnType__arrayDescriptorFree fnArrayDescriptorFree;
  roociloadFnType__attrGet fnAttrGet;
  roociloadFnType__attrSet fnAttrSet;
  roociloadFnType__bindByName fnBindByName;
  roociloadFnType__bindByName2 fnBindByName2;
  roociloadFnType__bindByPos fnBindByPos;
  roociloadFnType__bindByPos2 fnBindByPos2;
  roociloadFnType__bindObject fnBindObject;
  roociloadFnType__break fnBreak;
  roociloadFnType__clientVersion fnClientVersion;
  roociloadFnType__collAppend fnCollAppend;
  roociloadFnType__collAssignElem fnCollAssignElem;
  roociloadFnType__collGetElem fnCollGetElem;
  roociloadFnType__collSize fnCollSize;
  roociloadFnType__collTrim fnCollTrim;
  roociloadFnType__dateTimeConstruct fnDateTimeConstruct;
  roociloadFnType__dateTimeGetDate fnDateTimeGetDate;
  roociloadFnType__dateTimeGetTime fnDateTimeGetTime;
  roociloadFnType__dateTimeGetTimeZoneOffset fnDateTimeGetTimeZoneOffset;
  roociloadFnType__dateTimeIntervalAdd fnDateTimeIntervalAdd;
  roociloadFnType__dateTimeSubtract fnDateTimeSubtract;
  roociloadFnType__dateTimeSysTimeStamp fnDateTimeSysTimeStamp;
  roociloadFnType__defineByPos fnDefineByPos;
  roociloadFnType__defineObject fnDefineObject;
  roociloadFnType__describeAny fnDescribeAny;
  roociloadFnType__descriptorAlloc fnDescriptorAlloc;
  roociloadFnType__descriptorFree fnDescriptorFree;
  roociloadFnType__envCreate fnEnvCreate;
  roociloadFnType__envNlsCreate fnEnvNlsCreate;
  roociloadFnType__errorGet fnErrorGet;
  roociloadFnType__handleAlloc fnHandleAlloc;
  roociloadFnType__handleFree fnHandleFree;
  roociloadFnType__intervalGetDaySecond fnIntervalGetDaySecond;
  roociloadFnType__intervalSetDaySecond fnIntervalSetDaySecond;
  roociloadFnType__iterCreate fnIterCreate;
  roociloadFnType__iterNext fnIterNext;
  roociloadFnType__lobCreateTemporary fnLobCreateTemporary;
  roociloadFnType__lobFileClose fnLobFileClose;
  roociloadFnType__lobFileOpen fnLobFileOpen;
  roociloadFnType__lobGetLength2 fnLobGetLength2;
  roociloadFnType__lobLocatorAssign fnLobLocatorAssign;
  roociloadFnType__lobRead2 fnLobRead2;
  roociloadFnType__lobWrite2 fnLobWrite2;
  roociloadFnType__nlsCharSetConvert fnNlsCharSetConvert;
  roociloadFnType__nlsCharSetIdToName fnNlsCharSetIdToName;
  roociloadFnType__nlsCharSetNameToId fnNlsCharSetNameToId;
  roociloadFnType__nlsEnvironmentVariableGet fnNlsEnvironmentVariableGet;
  roociloadFnType__nlsNumericInfoGet fnNlsNumericInfoGet;
  roociloadFnType__numberFromInt fnNumberFromInt;
  roociloadFnType__numberFromReal fnNumberFromReal;
  roociloadFnType__numberToInt fnNumberToInt;
  roociloadFnType__numberToReal fnNumberToReal;
  roociloadFnType__objectCopy fnObjectCopy;
  roociloadFnType__objectFree fnObjectFree;
  roociloadFnType__objectGetAttr fnObjectGetAttr;
  roociloadFnType__objectGetInd fnObjectGetInd;
  roociloadFnType__objectGetTypeRef fnObjectGetTypeRef;
  roociloadFnType__objectNew fnObjectNew;
  roociloadFnType__objectPin fnObjectPin;
  roociloadFnType__objectSetAttr fnObjectSetAttr;
  roociloadFnType__paramGet fnParamGet;
  roociloadFnType__rawAssignBytes fnRawAssignBytes;
  roociloadFnType__rawPtr fnRawPtr;
  roociloadFnType__rawSize fnRawSize;
  roociloadFnType__reset fnReset;
  roociloadFnType__serverRelease fnServerRelease;
  roociloadFnType__serverVersion fnServerVersion;
  roociloadFnType__sessionGet fnSessionGet;
  roociloadFnType__sessionRelease fnSessionRelease;
  roociloadFnType__stmtExecute fnStmtExecute;
  roociloadFnType__stmtFetch2 fnStmtFetch2;
  roociloadFnType__stmtPrepare fnStmtPrepare;
  roociloadFnType__stmtPrepare2 fnStmtPrepare2;
  roociloadFnType__stmtRelease fnStmtRelease;
  roociloadFnType__stringAssignText fnStringAssignText;
  roociloadFnType__stringPtr fnStringPtr;
  roociloadFnType__stringResize fnStringResize;
  roociloadFnType__stringSize fnStringSize;
  roociloadFnType__tableFirst fnTableFirst;
  roociloadFnType__tableNext fnTableNext;
  roociloadFnType__threadCreate fnThreadCreate;
  roociloadFnType__threadHndInit fnThreadHndInit;
  roociloadFnType__threadIdInit fnThreadIdInit;
  roociloadFnType__threadJoin fnThreadJoin;
  roociloadFnType__transCommit fnTransCommit;
  roociloadFnType__transRollback fnTransRollback;
  roociloadFnType__typeByName fnTypeByName;
  roociloadFnType__typeByFullName fnTypeByFullName;
  roociloadFnType__unicodeToCharSet fnUnicodeToCharSet;
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
  roociloadFnType__vectorFromArray fnvectorFromArray;
  roociloadFnType__vectorFromSparseArray fnvectorFromSparseArray;
  roociloadFnType__vectorFromText fnvectorFromText;
  roociloadFnType__vectorToArray fnvectorToArray;
  roociloadFnType__vectorToSparseArray fnvectorToSparseArray;
  roociloadFnType__vectorToText fnvectorToText;
#endif /* OCI_MAJOR_VERSION >= 23 */
  roociloadFnType__ociepgoe fnociepgoe;
};
typedef struct roociloadSymbols roociloadSymbols;

static struct roociloadSymbols loadSyms;


// debug prefix format (populated by environment variable RORACLE_DEBUG_PREFIX)
static char roociloadDebugPrefixFormat[64] = "RORACLE [%i] %d %t: ";

static roociloadCtx *loadCtx_g = NULL;

//-----------------------------------------------------------------------------
// roociload__checkClientVersion() [INTERNAL]
//   Check the Oracle Client version and verify that it is at least at the
// minimum version that is required.
//-----------------------------------------------------------------------------
static sword roociload__checkClientVersion(roociloadVersion *versionInfo,
                                           int minVersionNum, int minReleaseNum,
                                           roociloadCtx *lCtx)
{
  if (versionInfo->maj_roociloadVersion < minVersionNum ||
      (versionInfo->maj_roociloadVersion == minVersionNum &&
      versionInfo->minor_roociloadVersion < minReleaseNum))
    return roociload__set(lCtx, "check Oracle Client version",
                          RORACLE_ERR_ORACLE_CLIENT_UNSUPPORTED,
                          versionInfo->maj_roociloadVersion,
                          versionInfo->minor_roociloadVersion,
                          minVersionNum, minReleaseNum);
  return OCI_SUCCESS;
}


//-----------------------------------------------------------------------------
// roociloadDebug__getFormatWithPrefix() [INTERNAL]
//   Adjust the provided format to include the prefix requested by the user.
// This method is not permitted to fail, so if there is not enough space, the
// prefix is truncated as needed -- although this is a very unlikely scenario.
//-----------------------------------------------------------------------------
static void roociloadDebug__getFormatWithPrefix(
const char *format,
char *formatWithPrefix,
size_t maxFormatWithPrefixSize)
{
  char      *sourcePtr, *targetPtr;
  int        gotTime, tempSize;
  uint64_t   threadId;
  size_t     size;
#ifdef _WIN32
  SYSTEMTIME mytime;
#else
  struct timeval timeOfDay;
  struct tm      mytime;
#endif

  gotTime = 0;
  sourcePtr = roociloadDebugPrefixFormat;
  targetPtr = formatWithPrefix;
  size = maxFormatWithPrefixSize - strlen(format);
  while (*sourcePtr && size > 20)
  {
    // all characters except '%' are copied verbatim to the target
    if (*sourcePtr != '%')
    {
      *targetPtr++ = *sourcePtr++;
      maxFormatWithPrefixSize--;
      continue;
    }

    // handle the different directives
    sourcePtr++;
    switch (*sourcePtr)
    {
      case 'i':
#ifdef _WIN32
        threadId = (uint64_t) GetCurrentThreadId();
#elif defined __linux
        threadId = (uint64_t) syscall(SYS_gettid);
#elif defined __APPLE__
        pthread_threadid_np(NULL, &threadId);
#else
        threadId = (uint64_t) pthread_self();
#endif
        tempSize = snprintf(targetPtr, size, RORACLE_DEBUG_THREAD_FORMAT,
                            threadId);
        size -= tempSize;
        targetPtr += tempSize;
        sourcePtr++;
        break;
      case 'd':
      case 't':
        if (!gotTime)
        {
          gotTime = 1;
#ifdef _WIN32
          GetLocalTime(&mytime);
#else
          gettimeofday(&timeOfDay, NULL);
          localtime_r(&timeOfDay.tv_sec, &mytime);
#endif
        }
#ifdef _WIN32
        if (*sourcePtr == 'd')
          tempSize = snprintf(targetPtr, size, RORACLE_DEBUG_DATE_FORMAT,
                             mytime.wYear, mytime.wMonth, mytime.wDay);
        else tempSize = snprintf(targetPtr, size, RORACLE_DEBUG_TIME_FORMAT,
                                mytime.wHour, mytime.wMinute, mytime.wSecond,
                                mytime.wMilliseconds);
#else
        if (*sourcePtr == 'd')
          tempSize = snprintf(targetPtr, size, RORACLE_DEBUG_DATE_FORMAT,
                             mytime.tm_year + 1900, mytime.tm_mon + 1,
                             mytime.tm_mday);
        else tempSize = snprintf(targetPtr, size, RORACLE_DEBUG_TIME_FORMAT,
                                mytime.tm_hour, mytime.tm_min, mytime.tm_sec,
                                (int) (timeOfDay.tv_usec / 1000));
#endif
        size -= tempSize;
        targetPtr += tempSize;
        sourcePtr++;
        break;
      case '\0':
        break;
      default:
        *targetPtr++ = '%';
        *targetPtr++ = *sourcePtr++;
        break;
    }
  }

  // append original format
  strcpy(targetPtr, format);
}


//-----------------------------------------------------------------------------
// roociloadDebug__print() [INTERNAL]
//   Print the specified debugging message with a newly calculated prefix.
//-----------------------------------------------------------------------------
static void roociloadDebug__print(const char *format, ...)
{
  char formatWithPrefix[512];
  va_list varArgs;

  roociloadDebug__getFormatWithPrefix(format, formatWithPrefix,
                                      sizeof(formatWithPrefix));
  va_start(varArgs, format);
  (void) Rvprintf(formatWithPrefix, varArgs);
  va_end(varArgs);
}


//-----------------------------------------------------------------------------
// roociloadDebug__initialize() [INTERNAL]
//   Initialize debugging infrastructure. This reads the environment variables
// and populates the global variables used for determining which messages to
// print and what prefix should be placed in front of each message.
//-----------------------------------------------------------------------------
static void roociloadDebug__initialize(void)
{
  char *envValue;

  // determine the value of the environment variable RORACLE_DEBUG_LEVEL and
  // convert to an integer; if the value in the environment variable is not a
  // valid integer, it is ignored
  envValue = getenv("RORACLE_DEBUG_LEVEL");
  if (envValue)
    roociloadDebugLevel = (unsigned long) strtol(envValue, NULL, 10);

  // determine the value of the environment variable RORACLE_DEBUG_PREFIX and
  // store it in the static buffer available for it; a static buffer is used
  // since this runs during startup and may not fail; if the value of the
  // environment variable is too large for the buffer, the value is ignored
  // and the default value is used instead
  envValue = getenv("RORACLE_DEBUG_PREFIX");
  if (envValue && strlen(envValue) < sizeof(roociloadDebugPrefixFormat))
    strcpy(roociloadDebugPrefixFormat, envValue);

  // for any debugging level > 0 print a message indicating that tracing
  // has started
  if (roociloadDebugLevel)
  {
    roociloadDebug__print("ROracle - %d.%d-%d\n",
                          RODBI_DRV_MAJOR, RODBI_DRV_MINOR, RODBI_DRV_UPDATE);
    roociloadDebug__print("debugging messages initialized at level %lu\n",
                          roociloadDebugLevel);
  }
}


//-----------------------------------------------------------------------------
// roociload__set() [INTERNAL]
//   Set the error buffer to the specified DPI error. Returns
//   ROOCI_DRV_ERR_LOAD_FAILas a convenience to the caller.
//-----------------------------------------------------------------------------
static sword roociload__set(roociloadCtx *lCtx, const char *action,
                            roociloadErrorNum errorNum, ...)
{
  va_list varArgs;

  if (lCtx)
  {
    const char *format;
    lCtx->action_roociloadCtx = action;
    lCtx->errorNum_roociloadCtx = errorNum;
    switch (errorNum)
    {
      case RORACLE_ERR_CREATE_ENV:
        format = RORACLE_ERR_CREATE_ENV_MSG;
        break;
      case RORACLE_ERR_LOAD_LIBRARY:
        format = RORACLE_ERR_LOAD_LIBRARY_MSG;
        break;
      case RORACLE_ERR_LOAD_SYMBOL:
        format = RORACLE_ERR_LOAD_SYMBOL_MSG;
        break;
      case RORACLE_ERR_ORACLE_CLIENT_UNSUPPORTED:
        format = RORACLE_ERR_ORACLE_CLIENT_UNSUPPORTED_MSG;
        break;
      case RORACLE_ERR_GET_FAILED:
        format = RORACLE_ERR_GET_FAILED_MSG;
        break;
      case RORACLE_ERR_NO_MEMORY:
        format = RORACLE_ERR_NO_MEMORY_MSG;
        break;
      case RORACLE_ERR_NLS_ENV_VAR_GET:
        format = RORACLE_ERR_NLS_ENV_VAR_GET_MSG;
        break;
      case RORACLE_ERR_OS:
        format = RORACLE_ERR_OS_MSG;
        break;
      case RORACLE_ERR_NOT_INITIALIZED:
        format = RORACLE_ERR_NOT_INITIALIZED_MSG;
        break;
      case RORACLE_ERR_INVALID_HANDLE:
        format = RORACLE_ERR_INVALID_HANDLE_MSG;
        break;
      case RORACLE_ERR_OCI_ERROR:
        format = RORACLE_ERR_OCI_ERROR_MSG;
        break;
      default:
        format = RORACLE_ERR_UNKNOWN_MSG;
        break;
    }

    va_start(varArgs, errorNum);
    lCtx->messageLength = vsnprintf((char *)lCtx->message_roociloadCtx,
                                    sizeof(lCtx->message_roociloadCtx),
                                    format, varArgs);
    va_end(varArgs);
    if (roociloadDebugLevel & ROOCILOAD_DEBUG_LEVEL_ERRORS)
      roociloadDebug__print("internal error %.*s (%s / %s)\n",
                      lCtx->messageLength, lCtx->message_roociloadCtx,
                      lCtx->fnName_roociloadCtx, action);
  }

  return ROOCI_DRV_ERR_LOAD_FAIL;
}


//-----------------------------------------------------------------------------
// roociload__setFromOCI() [INTERNAL]
//   Called when an OCI error has occurred and sets the error structure with
// the contents of that error. The value status is returned the caller,
// It is used for debugging only.
//-----------------------------------------------------------------------------
int roociload__setFromOCI(void *hndl, sword status, const char *action)
{
  sword errstatus;
  sb4   errcode = 0;

  // fetch OCI error
  errstatus = OCIErrorGet(hndl, 1, (text *)NULL, &errcode,
                          &loadCtx_g->message_roociloadCtx[0],
                          sizeof(loadCtx_g->message_roociloadCtx),
                          OCI_HTYPE_ERROR);

  if (errstatus == OCI_SUCCESS)
    roociloadDebug__print("OCI error %d - %s (%s / %s)\n", errcode,
                          loadCtx_g->message_roociloadCtx,
                          loadCtx_g->fnName_roociloadCtx, action);
  else
    roociloadDebug__print(
      "roociload__setFromOCI: OCIErrorGet for status=%d cannot be obtained\n",
      status);

  return status;
}


//-----------------------------------------------------------------------------
// roociload__setFromOS() [INTERNAL]
//   Set the error buffer to a general OS error. Returns ROOCILOAD_FAILURE as a
// convenience to the caller.
//-----------------------------------------------------------------------------
int roociload__setFromOS(roociloadCtx *lCtx, const char *action)
{
  char *message;

#ifdef _WIN32

  size_t messageLength = 0;

  message = NULL;
  if (roociload__getWindowsError(GetLastError(), &message, &messageLength,
                                                                    lCtx) < 0)
    return ROOCILOAD_FAILURE;
  roociload__set(lCtx, action, RORACLE_ERR_OS, message);
  roociload__freeMemory(message);

#else

  char buffer[512];
  int err = errno;
#if defined(__GLIBC__) || defined(__CYGWIN__)
//  message = strerror_r(err, buffer, sizeof(buffer));
  message = (strerror_r(err, buffer, sizeof(buffer)) == 0) ? buffer : NULL;
#else
  message = (strerror_r(err, buffer, sizeof(buffer)) == 0) ? buffer : NULL;
#endif
  if (!message)
  {
    (void) snprintf(buffer, sizeof(buffer),
                    "unable to get OS error %d", err);
    message = buffer;
  }
  roociload__set(lCtx, action, RORACLE_ERR_OS, message);

#endif
  return ROOCILOAD_FAILURE;
}


#ifndef _WIN32
//-----------------------------------------------------------------------------
// roociload__allocateMemory() [INTERNAL]
//   Method for allocating memory which permits tracing and populates the error
// structure in the event of a memory allocation failure.
//-----------------------------------------------------------------------------
static int roociload__allocateMemory(size_t numMembers, size_t memberSize,
                                     int clearMemory, const char *action,
                                     void **ptr, roociloadCtx *lCtx)
{
  if (clearMemory)
    *ptr = calloc(numMembers, memberSize);
  else *ptr = malloc(numMembers * memberSize);
  if (!*ptr)
    return roociload__set(lCtx, action, RORACLE_ERR_NO_MEMORY);
  if (roociloadDebugLevel & ROOCILOAD_DEBUG_LEVEL_MEM)
    roociloadDebug__print("allocated %u bytes at %p (%s)\n",
                          numMembers * memberSize, *ptr, action);
  return OCI_SUCCESS;
}
#endif


//-----------------------------------------------------------------------------
// roociload__freeMemory() [INTERNAL]
//   Method for allocating memory which permits tracing and populates the error
// structure in the event of a memory allocation failure.
//-----------------------------------------------------------------------------
static void roociload__freeMemory(void *ptr)
{
  if (roociloadDebugLevel & ROOCILOAD_DEBUG_LEVEL_MEM)
    roociloadDebug__print("freed ptr at %p\n", ptr);
  free(ptr);
}


//-----------------------------------------------------------------------------
// roociload__ensureBuffer() [INTERNAL]
//   Ensure that a buffer of the specified size is available. If a buffer of
// the requested size is not available, free any existing buffer and allocate a
// new, larger buffer.
//-----------------------------------------------------------------------------
static sword roociload__ensureBuffer(
size_t       desiredSize,
const char  *action,
void       **ptr,
size_t      *currentSize,
roociloadCtx    *lCtx)
{
  if (desiredSize <= *currentSize)
    return OCI_SUCCESS;

  if (*ptr)
  {
    ROOCI_MEM_FREE(*ptr);
    *ptr = NULL;
    *currentSize = 0;
  }

  ROOCI_MEM_ALLOC(*ptr, desiredSize, 1); 
  if (!*ptr)
    return ROOCI_DRV_ERR_MEM_FAIL;

  *currentSize = desiredSize;
  return OCI_SUCCESS;
}

#ifdef _WIN32
//-----------------------------------------------------------------------------
// roociload__getWindowsError() [INTERNAL]
//   Get the error message from Windows and place into the supplied buffer. The
// buffer and length are provided as pointers and memory is allocated as needed
// in order to be able to store the entire error message.
//-----------------------------------------------------------------------------
static int roociload__getWindowsError(DWORD errorNum, char **buffer,
                                      size_t *bufferLength, roociloadCtx *lCtx)
{
  char *fallbackErrorFormat = "failed to get message for Windows Error %d";
  wchar_t *wLoadError = NULL;
  DWORD length = 0, status;

  // use English unless English error messages aren't available
  status = FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM |
                          FORMAT_MESSAGE_IGNORE_INSERTS |
                          FORMAT_MESSAGE_ALLOCATE_BUFFER,
                          NULL, errorNum,
                          MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US),
                         (LPWSTR)&wLoadError, 0, NULL);
  if (!status && GetLastError() == ERROR_MUI_FILE_NOT_FOUND)
    FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM |
                   FORMAT_MESSAGE_IGNORE_INSERTS |
                   FORMAT_MESSAGE_ALLOCATE_BUFFER,
                   NULL, errorNum, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                   (LPWSTR)&wLoadError, 0, NULL);

  // transform UTF-16 to UTF-8
  if (wLoadError)
  {
    // strip trailing period and carriage return from message, if needed
    length = (DWORD) wcslen(wLoadError);
    while (length > 0)
    {
      if (wLoadError[length - 1] > 127 ||
                    (wLoadError[length - 1] != L'.' &&
                    !isspace(wLoadError[length - 1])))
        break;
      length--;
    }
    wLoadError[length] = L'\0';

    // convert to UTF-8 encoding
    if (length > 0)
    {
      length = WideCharToMultiByte(CP_UTF8, 0, wLoadError, -1, NULL, 0,
                                   NULL, NULL);
      if (length > 0)
      {
        if (roociload__ensureBuffer(length,
                  "allocate buffer for Windows error message",
                  (void**) buffer, bufferLength, lCtx) < 0)
        {
          LocalFree(wLoadError);
          return ROOCILOAD_FAILURE;
        }
        length = WideCharToMultiByte(CP_UTF8, 0, wLoadError, -1, *buffer,
                                     (int) *bufferLength, NULL, NULL);
      }
    }
    LocalFree(wLoadError);

  }

  if (length == 0)
  {
    if (roociload__ensureBuffer(strlen(fallbackErrorFormat) + 20,
                "allocate buffer for fallback error message",
                (void**) buffer, bufferLength, lCtx) < 0)
      return ROOCILOAD_FAILURE;
    (void) snprintf(*buffer, *bufferLength, fallbackErrorFormat, errorNum);
  }

  return errorNum;
}


//-----------------------------------------------------------------------------
// roociloadFnType__checkDllArchitecture() [INTERNAL]
//   Check the architecture of the specified DLL name and check if it
// matches the expected architecture. If it does not, the load error is
// modified and OCI_SUCCESS is returned; otherwise, ROOCILOAD_FAILURE is returned.
//-----------------------------------------------------------------------------
static sword roociloadFnType__checkDllArchitecture(
roociloadLibParams *loadParams,
const char         *name,
roociloadCtx       *lCtx)
{
  const char *errorFormat = "%s is not the correct architecture";
  IMAGE_DOS_HEADER dosHeader;
  IMAGE_NT_HEADERS ntHeaders;
  FILE *fp;

  // check DLL architecture
  fp = fopen(name, "rb");
  if (!fp)
    return ROOCILOAD_FAILURE;
  fread(&dosHeader, sizeof(dosHeader), 1, fp);
  if (dosHeader.e_magic != IMAGE_DOS_SIGNATURE) {
    fclose(fp);
    return ROOCI_DRV_ERR_LOAD_FAIL;
  }
  fseek(fp, dosHeader.e_lfanew, SEEK_SET);
  fread(&ntHeaders, sizeof(ntHeaders), 1, fp);
  fclose(fp);
  if (ntHeaders.Signature != IMAGE_NT_SIGNATURE)
    return ROOCI_DRV_ERR_LOAD_FAIL;

#if defined _M_AMD64
  if (ntHeaders.FileHeader.Machine == IMAGE_FILE_MACHINE_AMD64)
    return ROOCI_DRV_ERR_LOAD_FAIL;
#elif defined _M_IX86
  if (ntHeaders.FileHeader.Machine == IMAGE_FILE_MACHINE_I386)
    return ROOCI_DRV_ERR_LOAD_FAIL;
#else
  return ROOCI_DRV_ERR_LOAD_FAIL;
#endif

  // store a modified error in the error buffer
  if (roociload__ensureBuffer(strlen(errorFormat) + strlen(name) + 1,
            "allocate wrong architecture load error buffer",
            (void**) &loadParams->errorBuffer,
            &loadParams->errorBufferLength, lCtx) < 0)
    return ROOCI_DRV_ERR_MEM_FAIL;

  snprintf(loadParams->errorBuffer, loadParams->errorBufferLength,
           errorFormat, name);
  return OCI_SUCCESS;
}


//-----------------------------------------------------------------------------
// roociloadFnType__findAndCheckDllArchitecture() [INTERNAL]
//   Attempt to find the specified DLL name using the standard search path and
// if the DLL can be found but is of the wrong architecture, include the full
// name of the DLL in the load error. Return OCI_SUCCESS if such a DLL was
// found and was of the wrong architecture (in which case the load error has
// been set); otherwise, return ROOCILOAD_FAILURE so that the normal load error can
// be determined.
//-----------------------------------------------------------------------------
static sword roociloadFnType__findAndCheckDllArchitecture(
roociloadLibParams *loadParams,
const char         *name,
roociloadCtx       *lCtx)
{
  DWORD bufferLength;
  char *temp, *path;
  size_t length;
  int status;

  // if the name of the DLL is an absolute path, check it directly
  temp = strchr(name, '\\');
  if (temp)
    return roociloadFnType__checkDllArchitecture(loadParams, name, lCtx);

  // check current directory
  bufferLength = GetCurrentDirectory(0, NULL);
  if (bufferLength == 0)
    return ROOCI_DRV_ERR_LOAD_FAIL;

  if (roociload__ensureBuffer(strlen(name) + 1 + bufferLength,
            "allocate load params name buffer (current dir)",
            (void**) &loadParams->nameBuffer,
            &loadParams->nameBufferLength, lCtx) < 0)
    return ROOCI_DRV_ERR_MEM_FAIL;

  if (GetCurrentDirectory(bufferLength, loadParams->nameBuffer) == 0)
        return ROOCILOAD_FAILURE;
  temp = loadParams->nameBuffer + strlen(loadParams->nameBuffer);
  *temp++ = '\\';
  strcpy(temp, name);
  status = roociloadFnType__checkDllArchitecture(loadParams, loadParams->nameBuffer,
            lCtx);

  // search PATH
  path = getenv("PATH");
  if (path)
  {
    while (status < 0)
    {
      temp = strchr(path, ';');
      if (temp)
      {
        length = temp - path;
      }
      else
      {
        length = strlen(path);
      }

      if (roociload__ensureBuffer(strlen(name) + length + 2,
                    "allocate load params name buffer (PATH)",
                    (void**) &loadParams->nameBuffer,
                  &loadParams->nameBufferLength, lCtx) < 0)
        return ROOCI_DRV_ERR_MEM_FAIL;

      (void) snprintf(loadParams->nameBuffer, loadParams->nameBufferLength,
                      "%.*s\\%s", (int) length, path, name);
      status = roociloadFnType__checkDllArchitecture(loadParams,
                                              loadParams->nameBuffer, lCtx);
      if (!temp)
        break;
      path = temp + 1;
    }
  }

  return status;
}


//-----------------------------------------------------------------------------
// roociload__loadLibWithName() [INTERNAL]
//   Platform specific method of loading the library with a specific name.
// Load errors are stored in the temporary load error buffer and do not cause
// the function to fail; other errors (such as memory allocation errors) will
// result in failure.
//-----------------------------------------------------------------------------
static sword roociload__loadLibWithName(
roociloadLibParams *loadParams,
const char         *name,
roociloadCtx       *lCtx)
{
  DWORD errorNum;

  if (roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
    roociloadDebug__print("load with name %s\n", name);

  // attempt to load the library
  loadParams->handle = LoadLibrary(name);
  if (loadParams->handle)
    return OCI_SUCCESS;

  // if DLL is of the wrong architecture, attempt to locate the DLL that was
  // loaded and use that information if it can be found
  errorNum = GetLastError();
  if (errorNum == ERROR_BAD_EXE_FORMAT &&
      roociloadFnType__findAndCheckDllArchitecture(loadParams, name, lCtx) == 0)
    return OCI_SUCCESS;

  if (roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
    roociloadDebug__print("load with name %s failed %d\n", name, errorNum);

  // otherwise, attempt to get the error message
  roociload__getWindowsError(errorNum, &loadParams->errorBuffer,
                             &loadParams->errorBufferLength, lCtx);

  if (roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
    roociloadDebug__print("load with name %s failed %s %d\n", name,
                          loadParams->errorBuffer, RORACLE_ERR_OS);

  roociload__set(lCtx, name, RORACLE_ERR_OS, loadParams->errorBuffer, name);
  return ROOCI_DRV_ERR_LOAD_FAIL;
}


//-----------------------------------------------------------------------------
// roociload__loadLibInModuleDir() [INTERNAL]
//   Attempts to load the library from the directory in which the ODPI-C module
// (or its containing module) is located. This is platform specific.
//-----------------------------------------------------------------------------
static sword roociload__loadLibInModuleDir(
roociloadLibParams *loadParams,
roociloadCtx       *lCtx)
{
  HMODULE module = NULL;
  DWORD result = 0;
  char *temp;

  // attempt to get the module handle from a known function pointer
  if (GetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,
                        (LPCSTR)"roociload__loadLib", &module) == 0)
    return ROOCI_DRV_ERR_LOAD_FAIL;

  // attempt to get the module name from the module; the size of the buffer
  // is increased as needed as there is no other known way to acquire the
  // full name (MAX_PATH is no longer the maximum path length)
  if (roociload__ensureBuffer(MAX_PATH, "allocate module name",
                                   (void**) &loadParams->moduleNameBuffer,
                                   &loadParams->moduleNameBufferLength, lCtx) < 0)
  {
    FreeLibrary(module);
    return ROOCI_DRV_ERR_MEM_FAIL;
  }

  while (1)
  {
    result = GetModuleFileName(module, loadParams->moduleNameBuffer,
                               loadParams->moduleNameBufferLength);
    if (result < (DWORD)loadParams->moduleNameBufferLength)
      break;
    if (roociload__ensureBuffer(loadParams->moduleNameBufferLength * 2,
                "allocate module name", (void**) &loadParams->moduleNameBuffer,
                &loadParams->moduleNameBufferLength, lCtx) < 0)
    {
      FreeLibrary(module);
      return ROOCI_DRV_ERR_MEM_FAIL;
    }
  }
  FreeLibrary(module);
  if (result == 0)
    return ROOCI_DRV_ERR_LOAD_FAIL;
  if (roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
    roociloadDebug__print("module name is %s\n", loadParams->moduleNameBuffer);

  // use the module name to determine the directory and attempt to load the
  // Oracle client libraries from there
  temp = strrchr(loadParams->moduleNameBuffer, '\\');
  if (temp)
  {
    *temp = '\0';
    return roociload__loadLibWithDir(loadParams, loadParams->moduleNameBuffer,
                                 strlen(loadParams->moduleNameBuffer), 0, lCtx);
  }

  return ROOCI_DRV_ERR_LOAD_FAIL;
}


// for platforms other than Windows
#else


//-----------------------------------------------------------------------------
// roociload__loadLibInModuleDir() [INTERNAL]
//   Attempts to load the library from the directory in which the ODPI-C module
// (or its containing module) is located. This is platform specific.
//-----------------------------------------------------------------------------
static sword roociload__loadLibInModuleDir(
roociloadLibParams *loadParams,
roociloadCtx       *lCtx)
{
#ifndef _AIX
  char *dirName;
  Dl_info info;

  if (dladdr(roociload__loadLib, &info) != 0)
  {
    if (roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
      roociloadDebug__print("module name is %s\n", info.dli_fname);
    dirName = strrchr(info.dli_fname, '/');
    if (dirName)
      return roociload__loadLibWithDir(loadParams, info.dli_fname,
                                       (size_t)(dirName - info.dli_fname),
                                       0, lCtx);
  }
#endif

  return ROOCI_DRV_ERR_LOAD_FAIL;
}


//-----------------------------------------------------------------------------
// roociload__loadLibWithName() [INTERNAL]
//   Platform specific method of loading the library with a specific name.
// Load errors are stored in the temporary load error buffer and do not cause
// the function to fail; other errors (such as memory allocation errors) will
// result in failure.
//-----------------------------------------------------------------------------
static sword roociload__loadLibWithName(
roociloadLibParams *loadParams,
const char         *libName,
roociloadCtx       *error)
{
  char *osError;

  loadParams->handle = dlopen(libName, RTLD_LAZY);
  if (!loadParams->handle)
  {
    osError = dlerror();
    if (roociload__ensureBuffer(strlen(osError) + 1,
                "allocate load error buffer",
                (void**) &loadParams->errorBuffer,
                &loadParams->errorBufferLength, error) < 0)
      return ROOCI_DRV_ERR_MEM_FAIL;
    strcpy(loadParams->errorBuffer, osError);
  }

  return OCI_SUCCESS;
}


//-----------------------------------------------------------------------------
// roociload__loadLibWithOracleHome() [INTERNAL]
//   Attempts to load the library from the lib subdirectory of an Oracle home
// pointed to by the environemnt variable ORACLE_HOME.
//-----------------------------------------------------------------------------
static sword roociload__loadLibWithOracleHome(
roociloadLibParams *loadParams,
roociloadCtx       *error)
{
  char *oracleHome, *oracleHomeLibDir;
  size_t oracleHomeLength;
  int status;

  // check environment variable; if not set, attempt cannot proceed
  oracleHome = getenv("ORACLE_HOME");
  if (!oracleHome)
    return ROOCILOAD_FAILURE;

  // a zero-length directory is ignored
  oracleHomeLength = strlen(oracleHome);
  if (oracleHomeLength == 0)
    return ROOCILOAD_FAILURE;

  // craft directory to search
  if (roociload__allocateMemory(1, oracleHomeLength + 5, 0,
                                "allocate ORACLE_HOME dir name",
                                (void**)&oracleHomeLibDir, error) < 0)
    return ROOCILOAD_FAILURE;
  (void) snprintf(oracleHomeLibDir, oracleHomeLength + 5,
                  "%s/lib", oracleHome);

  // perform search
  status = roociload__loadLibWithDir(loadParams, oracleHomeLibDir,
                                     strlen(oracleHomeLibDir), 0, error);
  roociload__freeMemory(oracleHomeLibDir);
  return status;
}

#endif


//-----------------------------------------------------------------------------
// roociload__loadLibWithDir() [INTERNAL]
//   Helper function for loading the OCI library. If a directory is specified,
// that directory is searched; otherwise, an unqualfied search is performed
// using the normal OS library loading rules.
//-----------------------------------------------------------------------------
static sword roociload__loadLibWithDir(
roociloadLibParams *loadParams,
const char         *dirName,
size_t              dirNameLength,
int                 scanAllNames,
roociloadCtx       *error)
{
  const char *searchName;
  size_t nameLength;
  int i;

  // report attempt with directory, if applicable
  if (dirName && roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
    roociloadDebug__print("load in dir %.*s\n", (int) dirNameLength, dirName);

  // iterate over all possible options
  for (i = 0; roociloadLibNames[i]; i++)
  {
    // determine name to search
    if (!dirName)
    {
      searchName = roociloadLibNames[i];
    }
    else
    {
      nameLength = strlen(roociloadLibNames[i]) + dirNameLength + 2;
      if (roociload__ensureBuffer(nameLength, "allocate name buffer",
                                 (void**) &loadParams->nameBuffer,
                                 &loadParams->nameBufferLength, error) < 0)
        return ROOCI_DRV_ERR_MEM_FAIL;
      (void) snprintf(loadParams->nameBuffer, loadParams->nameBufferLength,
                      "%.*s/%s", (int) dirNameLength, dirName,
                      roociloadLibNames[i]);
      searchName = loadParams->nameBuffer;
      searchName = loadParams->nameBuffer;
    }

    // attempt to load the library using the calculated name; failure here
    // implies something other than a load failure and this error is
    // reported immediately
    if (roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
      roociloadDebug__print("load with name %s\n", searchName);
    if (roociload__loadLibWithName(loadParams, searchName, error) != 0)
      return ROOCI_DRV_ERR_LOAD_FAIL;

    // success is also reported immediately
    if (loadParams->handle)
    {
      if (roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
        roociloadDebug__print("load by OS successful\n");
      return OCI_SUCCESS;
    }

    // load failed; store the first failure that occurs which will be
    // reported if no successful loads were made and no other errors took
    // place
    if (roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
      roociloadDebug__print("load by OS failure: %s\n",
                            loadParams->errorBuffer);
    if (i == 0)
    {
      if (roociload__ensureBuffer(loadParams->errorBufferLength,
                    "allocate load error buffer",
                    (void**) &loadParams->loadError,
                    &loadParams->loadErrorLength, error) < 0)
        return ROOCI_DRV_ERR_MEM_FAIL;
      strcpy(loadParams->loadError, loadParams->errorBuffer);
      if (!scanAllNames)
        break;
    }
  }

  // no attempts were successful
  return ROOCI_DRV_ERR_LOAD_FAIL;
}


//-----------------------------------------------------------------------------
// roociload__loadLib() [INTERNAL]
//   Load the OCI library.
//-----------------------------------------------------------------------------
sword roociload__loadLib(
roociloadVersion *clientVersionInfo,
roociloadCtx     *ldCtx)
{
#if 0
  static const char *envNamesToCheck[] =
  {
    "ORACLE_HOME",
    "ORA_TZFILE",
    "TNS_ADMIN",
#ifdef _WIN32
    "PATH",
#else
    "LD_LIBRARY_PATH",
    "DYLD_LIBRARY_PATH",
    "LIBPATH",
    "SHLIB_PATH",
#endif
    NULL
  };
#endif

  roociloadLibParams  loadLibParams;
  int                 status;

  roociloadDebug__initialize();

  // initialize loading parameters; these are used to provide space for
  // loading errors and the names that are being searched; memory is
  // allocated dynamically in order to avoid potential issues with long paths
  // on some platforms
  memset(&loadLibParams, 0, sizeof(loadLibParams));

  // first try the directory in which the ODPI-C library itself is found
  if (roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
    roociloadDebug__print("check module directory\n");

  status = roociload__loadLibInModuleDir(&loadLibParams, ldCtx);
  // if that fails, try the default OS library loading mechanism
  if (status < 0)
  {
    if (roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
      roociloadDebug__print("load with OS search heuristics\n");
    status = roociload__loadLibWithDir(&loadLibParams, NULL, 0, 1, ldCtx);
  }

#ifndef _WIN32
  // if that fails, on platforms other than Windows, attempt to load
  // from $ORACLE_HOME/lib
  if (status < 0)
  {
    if (roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
      roociloadDebug__print("check ORACLE_HOME\n");
    status = roociload__loadLibWithOracleHome(&loadLibParams, ldCtx);
  }
#endif

  // if no attempts succeeded and no other error was reported, craft the
  // error message that will be returned
  if (status < 0 && (int) ldCtx->errorNum_roociloadCtx == 0)
  {
    const char *bits = (sizeof(void *) == 8) ? "64" : "32";
    roociload__set(ldCtx, "load library", RORACLE_ERR_LOAD_LIBRARY,
                   bits, loadLibParams.loadError);
  }

  // free any memory that was allocated
  if (loadLibParams.nameBuffer)
    roociload__freeMemory(loadLibParams.nameBuffer);
  if (loadLibParams.moduleNameBuffer)
    roociload__freeMemory(loadLibParams.moduleNameBuffer);
  if (loadLibParams.loadError)
    roociload__freeMemory(loadLibParams.loadError);
  if (loadLibParams.errorBuffer)
    roociload__freeMemory(loadLibParams.errorBuffer);

  // if no attempts, succeeded, return an error
  if (status < 0)
    return ROOCI_DRV_ERR_LOAD_FAIL;

  // validate library
  ldCtx->loadLibHandle__roociloadCtx = loadLibParams.handle;
  if (roociload__loadLibValidate(clientVersionInfo, ldCtx) < 0)
  {
#ifdef _WIN32
    FreeLibrary(ldCtx->loadLibHandle__roociloadCtx);
#else
    dlclose(ldCtx->loadLibHandle__roociloadCtx);
#endif
    ldCtx->loadLibHandle__roociloadCtx = NULL;
    memset(&loadSyms, 0, sizeof(loadSyms));
    return ROOCI_DRV_ERR_LOAD_FAIL;
  }

  loadCtx_g = ldCtx;

  return OCI_SUCCESS;
}


//-----------------------------------------------------------------------------
// roociload__loadLibValidate() [INTERNAL]
//   Validate the OCI library after loading.
//-----------------------------------------------------------------------------
static sword roociload__loadLibValidate(
roociloadVersion *clientVersionInfo,
roociloadCtx     *loadCtx)
{
  sword status = 0;
  if (roociloadDebugLevel & RORACLE_DEBUG_LEVEL_LOAD_LIB)
      roociloadDebug__print("validating loaded library\n");

  // determine the OCI client version information
  ROOCILOADFNTYPE__LOADSYMBOL(roociloadFnType__clientVersion, OCIClientVersion,
                              &loadSyms.fnClientVersion,
                              loadCtx, &status);
  if (status < 0)
    return roociload__set(loadCtx, "load symbol OCIClientVersion",
                          RORACLE_ERR_ORACLE_CLIENT_UNSUPPORTED);
  memset(clientVersionInfo, 0, sizeof(*clientVersionInfo));
  (*loadSyms.fnClientVersion)(&clientVersionInfo->maj_roociloadVersion,
                              &clientVersionInfo->minor_roociloadVersion,
                              &clientVersionInfo->update_roociloadVersion,
                              &clientVersionInfo->patch_roociloadVersion,
                              &clientVersionInfo->port_roociloadVersion);
  if (clientVersionInfo->maj_roociloadVersion == 0)
    return roociload__set(loadCtx, "get OCI client version",
                          RORACLE_ERR_ORACLE_CLIENT_UNSUPPORTED);
  // OCI version must be a minimum of 11.2
  if (roociload__checkClientVersion(clientVersionInfo, 11, 2, loadCtx) < 0)
    return ROOCILOAD_FAILURE;

  // load symbols for key functions which are called many times
  // this list should be kept as small as possible in order to avoid
  // overhead in looking up symbols at startup
  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__attrGet, OCIAttrGet,
                        &loadSyms.fnAttrGet, loadCtx);
  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__attrSet, OCIAttrSet,
                        &loadSyms.fnAttrSet, loadCtx);

  return OCI_SUCCESS;
}


//-----------------------------------------------------------------------------
// roociloadFnType__arrayDescriptorAlloc() [INTERNAL]
//   Wrapper for OCIArrayDescriptorAlloc().
//-----------------------------------------------------------------------------
sword OCIArrayDescriptorAlloc(const void    *parenth,
                              void         **descpp,
                              const ub4      type,
                              ub4            array_size,
                              const size_t   xtramem_sz,
                              void         **usrmempp)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__arrayDescriptorAlloc,
                        OCIArrayDescriptorAlloc,
                        &loadSyms.fnArrayDescriptorAlloc, loadCtx_g);
  status = (*loadSyms.fnArrayDescriptorAlloc)(parenth, descpp,
                                      type, array_size, xtramem_sz, usrmempp);
  ROOCILOAD_CHECK_AND_RETURN((void *)parenth, status, "allocate descriptors");
}


//-----------------------------------------------------------------------------
// roociloadFnType__arrayDescriptorFree() [INTERNAL]
//   Wrapper for OCIArrayDescriptorFree().
//-----------------------------------------------------------------------------
sword OCIArrayDescriptorFree(void **descp, const ub4 type)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__arrayDescriptorFree,
                        OCIArrayDescriptorFree,
                        &loadSyms.fnArrayDescriptorFree, loadCtx_g);
  status = (*loadSyms.fnArrayDescriptorFree)(descp, type);
  if (status != OCI_SUCCESS &&
      roociloadDebugLevel & RORACLE_DEBUG_LEVEL_UNREPORTED_ERRORS)
    roociloadDebug__print("free array descriptors %p, handleType %d failed\n",
                          descp, type);
  ROOCILOAD_CHECK_AND_RETURN(*descp, OCI_SUCCESS, "free descriptors");
  return OCI_SUCCESS;
}


//-----------------------------------------------------------------------------
// roociloadFnType__attrGet() [INTERNAL]
//   Wrapper for OCIAttrGet().
//-----------------------------------------------------------------------------
sword OCIAttrGet(const void    *trgthndlp,
                 ub4            trghndltyp,
                 void          *attributep,
                 ub4           *sizep,
                 ub4            attrtype,
                 OCIError      *errhp)
{
  sword status;

  status = (*loadSyms.fnAttrGet)(trgthndlp, trghndltyp, attributep,
                                 sizep, attrtype, errhp);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "attr get");
}


//-----------------------------------------------------------------------------
// roociloadFnType__attrSet() [INTERNAL]
//   Wrapper for OCIAttrSet().
//-----------------------------------------------------------------------------
sword OCIAttrSet(void          *trgthndlp,
                 ub4            trghndltyp,
                 void          *attributep,
                 ub4            size,
                 ub4            attrtype,
                 OCIError      *errhp)
{
  sword status;

  status = (*loadSyms.fnAttrSet)(trgthndlp, trghndltyp, attributep,
                                 size, attrtype, errhp);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "attr set");
}


//-----------------------------------------------------------------------------
// roociloadFnType__bindByName() [INTERNAL]
//   Wrapper for OCIBindByName().
//-----------------------------------------------------------------------------
sword OCIBindByName(OCIStmt         *stmhp,
                    OCIBind        **bindp,
                    OCIError        *errhp,
                    const oratext   *placeholder,
                    sb4              placeh_len,
                    void            *valuep,
                    sb4              value_sz,
                    ub2              dty,
                    void            *indp,
                    ub2             *alenp,
                    ub2             *rcodep,
                    ub4              maxarr_len,
                    ub4             *curelep,
                    ub4              mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__bindByName, OCIBindByName,
                        &loadSyms.fnBindByName, loadCtx_g);
  status = (*loadSyms.fnBindByName)(stmhp, bindp, errhp, placeholder,
                                    placeh_len, valuep, value_sz,
                                    dty, indp, alenp, rcodep,
                                    maxarr_len, curelep, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "bind by name");
}


//-----------------------------------------------------------------------------
// roociloadFnType__bindByName2() [INTERNAL]
//   Wrapper for OCIBindByName2().
//-----------------------------------------------------------------------------
sword OCIBindByName2(OCIStmt        *stmhp,
                     OCIBind       **bindp,
                     OCIError       *errhp,
                     const oratext  *placeholder,
                     sb4             placeh_len,
                     void           *valuep,
                     sb8             value_sz,
                     ub2             dty,
                     void           *indp,
                     ub4            *alenp,
                     ub2            *rcodep,
                     ub4             maxarr_len,
                     ub4            *curelep,
                     ub4             mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__bindByName2, OCIBindByName2,
                        &loadSyms.fnBindByName2, loadCtx_g);
  status = (*loadSyms.fnBindByName2)(stmhp, bindp, errhp, placeholder,
                                     placeh_len, valuep, value_sz,
                                     dty, indp, alenp, rcodep,
                                     maxarr_len, curelep, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "bind by name2");
}


//-----------------------------------------------------------------------------
// roociloadFnType__bindByPos() [INTERNAL]
//   Wrapper for OCIBindByPos().
//-----------------------------------------------------------------------------
sword OCIBindByPos(OCIStmt   *stmhp,
                   OCIBind  **bindp,
                   OCIError  *errhp,
                   ub4        position,
                   void      *valuep,
                   sb4        value_sz,
                   ub2        dty,
                   void      *indp,
                   ub2       *alenp,
                   ub2       *rcodep,
                   ub4        maxarr_len,
                   ub4       *curelep,
                   ub4        mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__bindByPos, OCIBindByPos,
                        &loadSyms.fnBindByPos, loadCtx_g);
  status = (*loadSyms.fnBindByPos)(stmhp, bindp, errhp, position,
                                   valuep, value_sz, dty, indp,
                                   alenp, rcodep, maxarr_len,
                                   curelep, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "bind by position");
}


//-----------------------------------------------------------------------------
// roociloadFnType__bindByPos2() [INTERNAL]
//   Wrapper for OCIBindByPos2().
//-----------------------------------------------------------------------------
sword OCIBindByPos2(OCIStmt       *stmhp,
                    OCIBind      **bindp,
                    OCIError      *errhp,
                    ub4            position,
                    void          *valuep,
                    sb8            value_sz,
                    ub2            dty,
                    void          *indp,
                    ub4           *alenp,
                    ub2           *rcodep,
                    ub4            maxarr_len,
                    ub4           *curelep,
                    ub4            mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__bindByPos2, OCIBindByPos2,
                        &loadSyms.fnBindByPos2, loadCtx_g);
  status = (*loadSyms.fnBindByPos2)(stmhp, bindp, errhp, position,
                                    valuep, value_sz, dty, indp,
                                    alenp, rcodep, maxarr_len,
                                    curelep, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "bind by position2");
}


//-----------------------------------------------------------------------------
// roociloadFnType__bindObject() [INTERNAL]
//   Wrapper for OCIBindObject().
//-----------------------------------------------------------------------------
sword OCIBindObject(OCIBind        *bndhp,
                    OCIError       *errhp,
                    const OCIType  *type,
                    void          **pgvpp,
                    ub4            *pvszsp,
                    void          **indpp,
                    ub4            *indszp)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__bindObject, OCIBindObject,
                        &loadSyms.fnBindObject, loadCtx_g);
  status = (*loadSyms.fnBindObject)(bndhp, errhp, type, pgvpp,
                                    pvszsp, indpp, indszp);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "bind object");
}


//-----------------------------------------------------------------------------
// roociloadFnType__break() [INTERNAL]
//   Wrapper for OCIBreak().
//-----------------------------------------------------------------------------
sword OCIBreak(void *hndlp, OCIError  *errhp)

{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__break, OCIBreak,
                        &loadSyms.fnBreak, loadCtx_g);
  status = (*loadSyms.fnBreak)(hndlp, errhp);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "break execution");
}


//-----------------------------------------------------------------------------
// roociloadFnType__clientVersion() [INTERNAL]
//   Wrapper for OCIClientVersion().
//-----------------------------------------------------------------------------
void OCIClientVersion(sword         *featureRelease,
                      sword         *releaseUpdate,
                      sword         *releaseUpdateRevision,
                      sword         *increment,
                      sword         *ext)
{
  sword status = 0;
  ROOCILOADFNTYPE__LOADSYMBOL(roociloadFnType__clientVersion, OCIClientVersion,
                              &loadSyms.fnClientVersion, loadCtx_g, &status);
  if (status < 0)
    (void) roociload__set(loadCtx_g, "load symbol OCIClientVersion",
                          RORACLE_ERR_LOAD_SYMBOL);
  else
    (*loadSyms.fnClientVersion)(featureRelease, releaseUpdate,
                                releaseUpdateRevision, increment, ext);
}


//-----------------------------------------------------------------------------
// roociloadFnType__collAppend() [INTERNAL]
//   Wrapper for OCICollAppend().
//-----------------------------------------------------------------------------
sword OCICollAppend(OCIEnv      *env,
                    OCIError    *err,
                    const void  *elem,
                    const void  *elemind,
                    OCIColl     *coll)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__collAppend, OCICollAppend,
                        &loadSyms.fnCollAppend, loadCtx_g);
  status = (*loadSyms.fnCollAppend)(env, err, elem, elemind, coll);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "coll append element");
}


//-----------------------------------------------------------------------------
// roociloadFnType__collAssignElem() [INTERNAL]
//   Wrapper for OCICollAssignElem().
//-----------------------------------------------------------------------------
sword OCICollAssignElem(OCIEnv        *env,
                        OCIError      *err,
                        sb4            index,
                        const void    *elem,
                        const void    *elemind,
                        OCIColl       *coll)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__collAssignElem, OCICollAssignElem,
                        &loadSyms.fnCollAssignElem, loadCtx_g);
  status = (*loadSyms.fnCollAssignElem)(env, err, index, elem, elemind, coll);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "coll assign element");
}


//-----------------------------------------------------------------------------
// roociloadFnType__collGetElem() [INTERNAL]
//   Wrapper for OCICollGetElem().
//-----------------------------------------------------------------------------
sword OCICollGetElem(OCIEnv         *env,
                     OCIError       *err,
                     const OCIColl  *coll,
                     sb4             index,
                     boolean        *exists,
                     void          **elem,
                     void          **elemind)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__collGetElem, OCICollGetElem,
                        &loadSyms.fnCollGetElem, loadCtx_g);
  status = (*loadSyms.fnCollGetElem)(env, err, coll, index, exists,
                                     elem, elemind);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "coll get element");
}


//-----------------------------------------------------------------------------
// roociloadFnType__collSize() [INTERNAL]
//   Wrapper for OCICollSize().
//-----------------------------------------------------------------------------
sword OCICollSize(OCIEnv        *env,
                  OCIError      *err,
                  const OCIColl *coll,
                  sb4           *size)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__collSize, OCICollSize,
                        &loadSyms.fnCollSize, loadCtx_g);
  status = (*loadSyms.fnCollSize)(env, err, coll, size);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "coll get size");
}


//-----------------------------------------------------------------------------
// roociloadFnType__collTrim() [INTERNAL]
//   Wrapper for OCICollTrim().
//-----------------------------------------------------------------------------
sword OCICollTrim(OCIEnv   *env,
                  OCIError *err,
                  sb4       trim_num,
                  OCIColl  *coll)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__collTrim, OCICollTrim,
                        &loadSyms.fnCollTrim, loadCtx_g);
  status = (*loadSyms.fnCollTrim)(env, err, trim_num, coll);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "coll trim");
}


//-----------------------------------------------------------------------------
// roociloadFnType__dateTimeConstruct() [INTERNAL]
//   Wrapper for OCIDateTimeConstruct().
//-----------------------------------------------------------------------------
sword OCIDateTimeConstruct(void         *hndl,
                           OCIError     *err,
                           OCIDateTime  *datetime,
                           sb2           year,
                           ub1           month,
                           ub1           day,
                           ub1           hour,
                           ub1           min,
                           ub1           sec,
                           ub4           fsec,
                           OraText      *timezone,
                           size_t        timezone_length)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__dateTimeConstruct, OCIDateTimeConstruct,
                        &loadSyms.fnDateTimeConstruct, loadCtx_g);
  status = (*loadSyms.fnDateTimeConstruct)(hndl, err, datetime, year,
                        month, day, hour, min, sec,
                        fsec, timezone, timezone_length);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "construct date");
}


//-----------------------------------------------------------------------------
// roociloadFnType__dateTimeGetDate() [INTERNAL]
//   Wrapper for OCIDateTimeGetDate().
//-----------------------------------------------------------------------------
sword OCIDateTimeGetDate(void              *hndl,
                         OCIError          *err,
                         const OCIDateTime *datetime,
                         sb2               *year,
                         ub1               *month,
                         ub1               *day)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__dateTimeGetDate, OCIDateTimeGetDate,
                        &loadSyms.fnDateTimeGetDate, loadCtx_g);
  status = (*loadSyms.fnDateTimeGetDate)(hndl, err, datetime, year,
                                                 month, day);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "get date portion");
}


//-----------------------------------------------------------------------------
// roociloadFnType__dateTimeGetTime() [INTERNAL]
//   Wrapper for OCIDateTimeGetTime().
//-----------------------------------------------------------------------------
sword OCIDateTimeGetTime(void        *hndl,
                         OCIError    *err,
                         OCIDateTime *datetime,
                         ub1         *hour,
                         ub1         *min,
                         ub1         *sec,
                         ub4         *fsec)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__dateTimeGetTime, OCIDateTimeGetTime,
                        &loadSyms.fnDateTimeGetTime, loadCtx_g);
  status = (*loadSyms.fnDateTimeGetTime)(hndl, err, datetime, hour,
                                                 min, sec, fsec);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "get time portion");
}


//-----------------------------------------------------------------------------
// roociloadFnType__dateTimeGetTimeZoneOffset() [INTERNAL]
//   Wrapper for OCIDateTimeGetTimeZoneOffset().
//-----------------------------------------------------------------------------
sword OCIDateTimeGetTimeZoneOffset(void              *hndl,
                                   OCIError          *err,
                                   const OCIDateTime *datetime,
                                   sb1               *hour,
                                   sb1               *minute)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__dateTimeGetTimeZoneOffset,
                        OCIDateTimeGetTimeZoneOffset,
                        &loadSyms.fnDateTimeGetTimeZoneOffset, loadCtx_g);
  status = (*loadSyms.fnDateTimeGetTimeZoneOffset)(hndl, err, datetime,
                                                   hour, minute);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "get time zone portion");
}


//-----------------------------------------------------------------------------
// roociloadFnType__dateTimeIntervalAdd() [INTERNAL]
//   Wrapper for OCIDateTimeIntervalAdd().
//-----------------------------------------------------------------------------
sword OCIDateTimeIntervalAdd(void        *hndl,
                             OCIError    *err,
                             OCIDateTime *datetime,
                             OCIInterval *interval,
                             OCIDateTime *outdatetime)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__dateTimeIntervalAdd,
                        OCIDateTimeIntervalAdd,
                        &loadSyms.fnDateTimeIntervalAdd, loadCtx_g);
  status = (*loadSyms.fnDateTimeIntervalAdd)(hndl, err, datetime,
                                             interval, outdatetime);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "add interval to date");
}


//-----------------------------------------------------------------------------
// roociloadFnType__dateTimeSubtract() [INTERNAL]
//   Wrapper for OCIDateTimeSubtract().
//-----------------------------------------------------------------------------
sword OCIDateTimeSubtract(void        *hndl,
                          OCIError    *err,
                          OCIDateTime *indate1,
                          OCIDateTime *indate2,
                          OCIInterval *interval)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__dateTimeSubtract, OCIDateTimeSubtract,
                        &loadSyms.fnDateTimeSubtract, loadCtx_g);
  status = (*loadSyms.fnDateTimeSubtract)(hndl, err, indate1,
                                          indate2, interval);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "subtract date");
}


//-----------------------------------------------------------------------------
// roociloadFnType__dateTimeSubtract() [INTERNAL]
//   Wrapper for OCIDateTimeSysTimeStamp().
//-----------------------------------------------------------------------------
sword OCIDateTimeSysTimeStamp(void        *hndl,
                              OCIError    *err,
                              OCIDateTime *sys_date)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__dateTimeSysTimeStamp,
                        OCIDateTimeSysTimeStamp,
                        &loadSyms.fnDateTimeSysTimeStamp, loadCtx_g);
  status = (*loadSyms.fnDateTimeSysTimeStamp)(hndl, err, sys_date);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "system time stamp");
}

//-----------------------------------------------------------------------------
// roociloadFnType__defineByPos() [INTERNAL]
//   Wrapper for OCIDefineByPos().
//-----------------------------------------------------------------------------
sword OCIDefineByPos(OCIStmt    *stmhp,
                     OCIDefine **defnp,
                     OCIError   *errhp,
                     ub4         position,
                     void       *valuep,
                     sb4         value_sz,
                     ub2         dty,
                     void       *indp,
                     ub2        *rlenp,
                     ub2        *rcodep,
                     ub4         mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__defineByPos, OCIDefineByPos,
                        &loadSyms.fnDefineByPos, loadCtx_g);
  status = (*loadSyms.fnDefineByPos)(stmhp, defnp, errhp, position,
                        valuep, value_sz, dty, indp, rlenp, rcodep, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "define by pos");
}


//-----------------------------------------------------------------------------
// roociloadFnType__defineObject() [INTERNAL]
//   Wrapper for OCIDefineObject().
//-----------------------------------------------------------------------------
sword OCIDefineObject(OCIDefine       *dfnhp,
                      OCIError        *errhp,
                      const OCIType   *type,
                      void           **pgvpp,
                      ub4             *pvszsp,
                      void           **indpp,
                      ub4             *indszp)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__defineObject, OCIDefineObject,
                        &loadSyms.fnDefineObject, loadCtx_g);
  status = (*loadSyms.fnDefineObject)(dfnhp, errhp, type, pgvpp,
                                      pvszsp, indpp, indszp);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "define object");
}


//-----------------------------------------------------------------------------
// roociloadFnType__describeAny() [INTERNAL]
//   Wrapper for OCIDescribeAny().
//-----------------------------------------------------------------------------
sword OCIDescribeAny(OCISvcCtx   *svchp,
                     OCIError    *errhp,
                     void        *objptr,
                     ub4          objptr_len,
                     ub1          objptr_typ,
                     ub1          info_level,
                     ub1          objtype,
                     OCIDescribe *dschp)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__describeAny, OCIDescribeAny,
                        &loadSyms.fnDescribeAny, loadCtx_g);
  status = (*loadSyms.fnDescribeAny)(svchp, errhp, objptr, objptr_len,
                                     objptr_typ, info_level, objtype, dschp);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "describe type");
}


//-----------------------------------------------------------------------------
// roociloadFnType__descriptorAlloc() [INTERNAL]
//   Wrapper for OCIDescriptorAlloc().
//-----------------------------------------------------------------------------
sword OCIDescriptorAlloc(const void    *parenth,
                         void         **descpp,
                         const ub4      type,
                         const size_t   xtramem_sz,
                         void         **usrmempp)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__descriptorAlloc, OCIDescriptorAlloc,
                        &loadSyms.fnDescriptorAlloc, loadCtx_g);
  status = (*loadSyms.fnDescriptorAlloc)(parenth, descpp, type,
                                         xtramem_sz, usrmempp);
  ROOCILOAD_CHECK_AND_RETURN((void *)parenth, status, "descriptor alloc");
}


//-----------------------------------------------------------------------------
// roociloadFnType__descriptorFree() [INTERNAL]
//   Wrapper for OCIDescriptorFree().
//-----------------------------------------------------------------------------
sword OCIDescriptorFree(void      *descp,
                        const ub4  type)

{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__descriptorFree, OCIDescriptorFree,
                        &loadSyms.fnDescriptorFree, loadCtx_g);
  status = (*loadSyms.fnDescriptorFree)(descp, type);
  if (status != OCI_SUCCESS &&
      roociloadDebugLevel & RORACLE_DEBUG_LEVEL_UNREPORTED_ERRORS)
    roociloadDebug__print("free descriptor %p, type %d failed\n", descp,
                          type);
  ROOCILOAD_CHECK_AND_RETURN(NULL, OCI_SUCCESS, "descriptor free");
  return OCI_SUCCESS;
}


//-----------------------------------------------------------------------------
// roociloadFnType__envCreate() [INTERNAL]
//   Wrapper for OCIEnvCreate().
//-----------------------------------------------------------------------------
sword OCIEnvCreate(OCIEnv **envp,
              ub4      mode,
              void    *ctxp,
              void    *(*malocfp)(void  *ctxp, size_t size),
              void    *(*ralocfp)(void  *ctxp, void  *memptr, size_t newsize),
              void     (*mfreefp)(void  *ctxp, void  *memptr),
              size_t   xtramem_sz,
              void   **usrmempp)
{
  sword status;

  *envp = NULL;
  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__envCreate, OCIEnvCreate,
                        &loadSyms.fnEnvCreate, loadCtx_g);
  status = (*loadSyms.fnEnvCreate)(envp, mode, ctxp, malocfp, ralocfp,
                                   mfreefp, xtramem_sz, usrmempp);
  if (*envp)
  {
    if (status == OCI_SUCCESS || status == OCI_SUCCESS_WITH_INFO)
      return OCI_SUCCESS;
    else
    {
      sword errstatus;
      sb4   errcode = 0;

      // fetch OCI error
      errstatus = OCIErrorGet(*envp, 1, (text *)NULL, &errcode,
                              &loadCtx_g->message_roociloadCtx[0],
                              sizeof(loadCtx_g->message_roociloadCtx),
                              OCI_HTYPE_ENV);

      if (errstatus == OCI_SUCCESS)
        roociloadDebug__print("OCI error %d - %s (%s / %s)\n", errcode,
                              loadCtx_g->message_roociloadCtx,
                              loadCtx_g->fnName_roociloadCtx,
                              "create env");
      else
        roociloadDebug__print(
          "OCIEnvCreate: OCIErrorGet for status=%d cannot be obtained\n",
           status);

      return status;
    }
  }
  return roociload__set(loadCtx_g, "create env", RORACLE_ERR_CREATE_ENV);
}


//-----------------------------------------------------------------------------
// roociloadFnType__envNlsCreate() [INTERNAL]
//   Wrapper for OCIEnvNlsCreate().
//-----------------------------------------------------------------------------
sword OCIEnvNlsCreate(OCIEnv **envp,
                 ub4      mode,
                 void    *ctxp,
                 void    *(*malocfp)(void *ctxp, size_t size),
                 void    *(*ralocfp)(void *ctxp, void *memptr, size_t newsize),
                 void     (*mfreefp)(void *ctxp, void *memptr),
                 size_t   xtramem_sz,
                 void   **usrmempp,
                 ub2      charset,
                 ub2      ncharset)
{
  sword status;

  *envp = NULL;
  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__envNlsCreate, OCIEnvNlsCreate,
                        &loadSyms.fnEnvNlsCreate, loadCtx_g);
  status = (*loadSyms.fnEnvNlsCreate)(envp, mode, ctxp, malocfp,
                                      ralocfp, mfreefp, xtramem_sz,
                                      usrmempp, charset, ncharset);
  if (*envp)
  {
    if (status == OCI_SUCCESS || status == OCI_SUCCESS_WITH_INFO)
      return OCI_SUCCESS;
    else
    {
      sword errstatus;
      sb4   errcode = 0;

      // fetch OCI error
      errstatus = OCIErrorGet(*envp, 1, (text *)NULL, &errcode,
                              &loadCtx_g->message_roociloadCtx[0],
                              sizeof(loadCtx_g->message_roociloadCtx),
                              OCI_HTYPE_ENV);

      if (errstatus == OCI_SUCCESS)
        roociloadDebug__print("OCI error %d - %s (%s / %s)\n", errcode,
                              loadCtx_g->message_roociloadCtx,
                              loadCtx_g->fnName_roociloadCtx,
                              "create nls env");
      else
        roociloadDebug__print(
          "OCIEnvNlsCreate: OCIErrorGet for status=%d cannot be obtained\n",
          errcode);

      return status;
    }
  }
  return roociload__set(loadCtx_g, "create nls env", RORACLE_ERR_CREATE_ENV);
}


//-----------------------------------------------------------------------------
// roociloadFnType__errorGet() [INTERNAL]
//   Wrapper for OCIErrorGet().
//-----------------------------------------------------------------------------
sword OCIErrorGet(void     *hndlp,
                  ub4       recordno,
                  oratext  *sqlstate,
                  sb4      *errcodep,
                  oratext  *bufp,
                  ub4       bufsiz,
                  ub4       type)
{
  sword  status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__errorGet, OCIErrorGet,
                        &loadSyms.fnErrorGet, loadCtx_g);
  status = (*loadSyms.fnErrorGet)(hndlp, recordno, sqlstate, errcodep,
                                  bufp, bufsiz, type);
  ROOCILOAD_CHECK_AND_RETURN(hndlp, status, "error get");
}


//-----------------------------------------------------------------------------
// roociloadFnType__handleAlloc() [INTERNAL]
//   Wrapper for OCIHandleAlloc().
//-----------------------------------------------------------------------------
sword OCIHandleAlloc(const void    *parenth,
                     void         **hndlpp,
                     const ub4      type,
                     const size_t   xtramem_sz,
                     void         **usrmempp)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__handleAlloc, OCIHandleAlloc,
                        &loadSyms.fnHandleAlloc, loadCtx_g);
  status = (*loadSyms.fnHandleAlloc)(parenth, hndlpp, type,
                                             xtramem_sz, usrmempp);
  ROOCILOAD_CHECK_AND_RETURN((void *)parenth, status, "handle alloc");
}


//-----------------------------------------------------------------------------
// roociloadFnType__handleFree() [INTERNAL]
//   Wrapper for OCIHandleFree().
//-----------------------------------------------------------------------------
sword OCIHandleFree(void *handle, const ub4 type)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__handleFree, OCIHandleFree,
                        &loadSyms.fnHandleFree, loadCtx_g);
  status = (*loadSyms.fnHandleFree)(handle,type);
  if (status != OCI_SUCCESS &&
      roociloadDebugLevel & RORACLE_DEBUG_LEVEL_UNREPORTED_ERRORS)
    roociloadDebug__print("free handle %p, handleType %d failed\n", handle,
                          type);
  ROOCILOAD_CHECK_AND_RETURN(handle, status, "handle free");
}


//-----------------------------------------------------------------------------
// roociloadFnType__intervalGetDaySecond() [INTERNAL]
//   Wrapper for OCIIntervalGetDaySecond().
//-----------------------------------------------------------------------------
sword OCIIntervalGetDaySecond(void              *hndl,
                              OCIError          *err,
                              sb4               *day,
                              sb4               *hour,
                              sb4               *min,
                              sb4               *sec,
                              sb4               *fsec,
                              const OCIInterval *result)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__intervalGetDaySecond,
                        OCIIntervalGetDaySecond,
                        &loadSyms.fnIntervalGetDaySecond, loadCtx_g);
  status = (*loadSyms.fnIntervalGetDaySecond)(hndl, err, day, hour,
                                              min, sec, fsec, result);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "get interval components");
}


//-----------------------------------------------------------------------------
// roociloadFnType__intervalSetDaySecond() [INTERNAL]
//   Wrapper for OCIIntervalSetDaySecond().
//-----------------------------------------------------------------------------
sword OCIIntervalSetDaySecond(void        *hndl,
                              OCIError    *err,
                              sb4          day,
                              sb4          hour,
                              sb4          min,
                              sb4          sec,
                              sb4          fsec,
                              OCIInterval *result)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__intervalSetDaySecond,
                        OCIIntervalSetDaySecond,
                        &loadSyms.fnIntervalSetDaySecond, loadCtx_g);
  status = (*loadSyms.fnIntervalSetDaySecond)(hndl, err, day, hour,
                                              min, sec, fsec, result);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "set interval components");
}


//-----------------------------------------------------------------------------
// roociloadFnType__iterCreate() [INTERNAL]
//   Wrapper for OCIIterCreate().
//-----------------------------------------------------------------------------
sword OCIIterCreate(OCIEnv         *env,
                    OCIError       *err,
                    const OCIColl  *coll,
                    OCIIter       **itr)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__iterCreate, OCIIterCreate,
                        &loadSyms.fnIterCreate, loadCtx_g);
  status = (*loadSyms.fnIterCreate)(env, err, coll, itr);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "create iterator");
}


//-----------------------------------------------------------------------------
// roociloadFnType__interNext() [INTERNAL]
//   Wrapper for OCIIterNext().
//-----------------------------------------------------------------------------
sword OCIIterNext(OCIEnv   *env,
                  OCIError *err,
                  OCIIter  *itr,
                  void    **elem,
                  void    **elemind,
                  boolean  *eoc)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__iterNext, OCIIterNext,
                        &loadSyms.fnIterNext, loadCtx_g);
  status = (*loadSyms.fnIterNext)(env, err, itr, elem, elemind, eoc);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "iterator next");
}

//-----------------------------------------------------------------------------
// roociloadFnType__lobCreateTemporary() [INTERNAL]
//   Wrapper for OCILobCreateTemporary().
//-----------------------------------------------------------------------------
sword OCILobCreateTemporary(OCISvcCtx     *svchp,
                            OCIError      *errhp,
                            OCILobLocator *locp,
                            ub2            csid,
                            ub1            csfrm,
                            ub1            lobtype,
                            boolean        cache,
                            OCIDuration    duration)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__lobCreateTemporary,
                        OCILobCreateTemporary,
                        &loadSyms.fnLobCreateTemporary, loadCtx_g);
  status = (*loadSyms.fnLobCreateTemporary)(svchp, errhp, locp, csid,
                                            csfrm, lobtype, cache, duration);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "create temporary LOB");
}


//-----------------------------------------------------------------------------
// roociloadFnType__lobFileClose() [INTERNAL]
//   Wrapper for OCILobFileClose().
//-----------------------------------------------------------------------------
sword OCILobFileClose(OCISvcCtx     *svchp,
                      OCIError      *errhp,
                      OCILobLocator *file)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__lobFileClose, OCILobFileClose,
                        &loadSyms.fnLobFileClose, loadCtx_g);
  status = (*loadSyms.fnLobFileClose)(svchp, errhp, file);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "get file close");
}


//-----------------------------------------------------------------------------
// roociloadFnType__lobFileOpen() [INTERNAL]
//   Wrapper for OCILobFileOpen().
//-----------------------------------------------------------------------------
sword OCILobFileOpen(OCISvcCtx     *svchp,
                     OCIError      *errhp,
                     OCILobLocator *filep,
                     ub1            mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__lobFileOpen, OCILobFileOpen,
                        &loadSyms.fnLobFileOpen, loadCtx_g);
  status = (*loadSyms.fnLobFileOpen)(svchp, errhp, filep, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "get file open");
}


//-----------------------------------------------------------------------------
// roociloadFnType__lobGetLength2() [INTERNAL]
//   Wrapper for OCILobGetLength2().
//-----------------------------------------------------------------------------
sword OCILobGetLength2(OCISvcCtx     *svchp,
                       OCIError      *errhp,
                       OCILobLocator *lobdp,
                       oraub8        *lenp)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__lobGetLength2, OCILobGetLength2,
                        &loadSyms.fnLobGetLength2, loadCtx_g);
  status = (*loadSyms.fnLobGetLength2)(svchp, errhp, lobdp, lenp);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "get LOB length2");
}


//-----------------------------------------------------------------------------
// roociloadFnType__lobLocatorAssign() [INTERNAL]
//   Wrapper for OCILobLocatorAssign().
//-----------------------------------------------------------------------------
sword OCILobLocatorAssign(OCISvcCtx         *svchp,
                          OCIError          *errhp,
                          const OCILobLocator    *source,
                          OCILobLocator         **destination
)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__lobLocatorAssign, OCILobLocatorAssign,
                        &loadSyms.fnLobLocatorAssign, loadCtx_g);
  status = (*loadSyms.fnLobLocatorAssign)(svchp, errhp, source, destination);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "LOB locator assign");
}


//-----------------------------------------------------------------------------
// roociloadFnType__lobRead2() [INTERNAL]
//   Wrapper for OCILobRead2().
//-----------------------------------------------------------------------------
sword OCILobRead2(OCISvcCtx           *svchp,
                  OCIError            *errhp,
                  OCILobLocator       *lobp,
                  oraub8              *byte_amtp,
                  oraub8              *char_amtp,
                  oraub8               offset,
                  void                *bufp,
                  oraub8               bufl,
                  ub1                  piece,
                  void                *ctxp,
                  OCICallbackLobRead2  cbfp,
                  ub2                  csid,
                  ub1                  csfrm)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__lobRead2, OCILobRead2,
                        &loadSyms.fnLobRead2, loadCtx_g);
  status = (*loadSyms.fnLobRead2)(svchp, errhp, lobp,
                                  byte_amtp, char_amtp, offset,
                                  bufp, bufl, piece, ctxp,
                                  cbfp, csid, csfrm);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "read from LOB");
}


//-----------------------------------------------------------------------------
// roociloadFnType__lobWrite2() [INTERNAL]
//   Wrapper for OCILobWrite2().
//-----------------------------------------------------------------------------
sword OCILobWrite2(OCISvcCtx            *svchp,
                   OCIError             *errhp,
                   OCILobLocator        *locp,
                   oraub8               *byte_amtp,
                   oraub8               *char_amtp,
                   oraub8                offset,
                   void                 *bufp,
                   oraub8                buflen,
                   ub1                   piece,
                   void                 *ctxp,
                   OCICallbackLobWrite2  cbfp,
                   ub2                   csid,
                   ub1                   csfrm)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__lobWrite2, OCILobWrite2,
                        &loadSyms.fnLobWrite2, loadCtx_g);
  status = (*loadSyms.fnLobWrite2)(svchp, errhp, locp,
                          byte_amtp, char_amtp, offset, bufp, buflen,
                          piece, ctxp, cbfp, csid, csfrm);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "write to LOB");
}


//-----------------------------------------------------------------------------
// roociloadFnType__nlsCharSetConvert() [INTERNAL]
//   Wrapper for OCINlsCharSetConvert().
//-----------------------------------------------------------------------------
sword OCINlsCharSetConvert(void       *envhp,
                           OCIError   *errhp,
                           ub2         dstid,
                           void       *dstp,
                           size_t      dstlen,
                           ub2         srcid,
                           const void *srcp,
                           size_t      srclen,
                           size_t     *rsize)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__nlsCharSetConvert, OCINlsCharSetConvert,
                        &loadSyms.fnNlsCharSetConvert, loadCtx_g);
  status = (*loadSyms.fnNlsCharSetConvert)(envhp, errhp, dstid, dstp,
                        dstlen, srcid, srcp, srclen, rsize);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "convert text");
}


//-----------------------------------------------------------------------------
// roociloadFnType__nlsCharSetIdToName() [INTERNAL]
//   Wrapper for OCINlsCharSetIdToName().
//-----------------------------------------------------------------------------
sword OCINlsCharSetIdToName(void    *envhp,
                            oratext *buf,
                            size_t   buflen,
                            ub2      id)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__nlsCharSetIdToName, OCINlsCharSetIdToName,
                        &loadSyms.fnNlsCharSetIdToName, loadCtx_g);
  status = (*loadSyms.fnNlsCharSetIdToName)(envhp, buf, buflen, id);
  ROOCILOAD_CHECK_AND_RETURN(envhp, status, "nls charset id to name");
}


//-----------------------------------------------------------------------------
// roociloadFnType__nlsCharSetNameToId() [INTERNAL]
//   Wrapper for OCINlsCharSetNameToId().
//-----------------------------------------------------------------------------
ub2 OCINlsCharSetNameToId(void *env, const oratext *name)
{
  ub2 csid;
  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__nlsCharSetNameToId, OCINlsCharSetNameToId,
                        &loadSyms.fnNlsCharSetNameToId, loadCtx_g);
  return (csid = (*loadSyms.fnNlsCharSetNameToId)(env, name));
}


//-----------------------------------------------------------------------------
// roociloadFnType__nlsEnvironmentVariableGet() [INTERNAL]
//   Wrapper for OCIEnvironmentVariableGet().
//-----------------------------------------------------------------------------
sword OCINlsEnvironmentVariableGet(void   *val,
                                   size_t  size,
                                   ub2     item,
                                   ub2     charset,
                                   size_t *rsize)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__nlsEnvironmentVariableGet,
                        OCINlsEnvironmentVariableGet,
                        &loadSyms.fnNlsEnvironmentVariableGet, loadCtx_g);
  status = (*loadSyms.fnNlsEnvironmentVariableGet)(val, size, item,
                                                   charset, rsize);
  if (status != OCI_SUCCESS)
    return roociload__set(loadCtx_g, "get NLS environment variable",
                          RORACLE_ERR_NLS_ENV_VAR_GET);
  return OCI_SUCCESS;
}


//-----------------------------------------------------------------------------
// roociloadFnType__nlsNumericInfoGet() [INTERNAL]
//   Wrapper for OCINlsNumericInfoGet().
//-----------------------------------------------------------------------------
sword OCINlsNumericInfoGet(void     *envhp,
                           OCIError *errhp,
                           sb4      *val,
                           ub2       item)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__nlsNumericInfoGet, OCINlsNumericInfoGet,
                        &loadSyms.fnNlsNumericInfoGet, loadCtx_g);
  status = (*loadSyms.fnNlsNumericInfoGet)(envhp, errhp, val, item);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "get NLS info");
}


//-----------------------------------------------------------------------------
// roociloadFnType__numberFromInt() [INTERNAL]
//   Wrapper for OCINumberFromInt().
//-----------------------------------------------------------------------------
sword OCINumberFromInt(OCIError    *err,
                       const void  *inum,
                       uword        inum_length,
                       uword        inum_s_flag,
                       OCINumber   *number)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__numberFromInt, OCINumberFromInt,
                        &loadSyms.fnNumberFromInt, loadCtx_g);
  status = (*loadSyms.fnNumberFromInt)(err, inum, inum_length,
                                       inum_s_flag, number);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "number from integer");
}


//-----------------------------------------------------------------------------
// roociloadFnType__numberFromReal() [INTERNAL]
//   Wrapper for OCINumberFromReal().
//-----------------------------------------------------------------------------
sword OCINumberFromReal(OCIError   *err,
                        const void *rnum,
                        uword       rnum_length,
                        OCINumber  *number)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__numberFromReal, OCINumberFromReal,
                        &loadSyms.fnNumberFromReal, loadCtx_g);
  status = (*loadSyms.fnNumberFromReal)(err, rnum, rnum_length, number);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "number from real");
}


//-----------------------------------------------------------------------------
// roociloadFnType__numberToInt() [INTERNAL]
//   Wrapper for OCINumberToInt().
//-----------------------------------------------------------------------------
sword OCINumberToInt(OCIError         *err,
                     const OCINumber *number,
                     uword            rsl_length,
                     uword            rsl_flag,
                     void            *rsl)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__numberToInt, OCINumberToInt,
                        &loadSyms.fnNumberToInt, loadCtx_g);
  status = (*loadSyms.fnNumberToInt)(err, number, rsl_length,
                                     rsl_flag, rsl);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "number to integer");
}


//-----------------------------------------------------------------------------
// roociloadFnType__numberToReal() [INTERNAL]
//   Wrapper for OCINumberToReal().
//-----------------------------------------------------------------------------
sword OCINumberToReal(OCIError        *err,
                      const OCINumber *number,
                      uword            rsl_length,
                      void            *rsl)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__numberToReal, OCINumberToReal,
                        &loadSyms.fnNumberToReal, loadCtx_g);
  status = (*loadSyms.fnNumberToReal)(err, number, rsl_length, rsl);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "number to real");
}


//-----------------------------------------------------------------------------
// roociloadFnType__objectCopy() [INTERNAL]
//   Wrapper for OCIObjectCopy().
//-----------------------------------------------------------------------------
sword OCIObjectCopy(OCIEnv *env, OCIError *err, const OCISvcCtx *svc,
                    void  *source, void  *null_source,
                    void  *target, void  *null_target, OCIType *tdo,
                    OCIDuration duration, ub1 option)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__objectCopy, OCIObjectCopy,
                        &loadSyms.fnObjectCopy, loadCtx_g);
  status = (*loadSyms.fnObjectCopy)(env, err, svc, source, null_source,
                                    target, null_target, tdo, duration,
                                    option);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "copy object");
}


//-----------------------------------------------------------------------------
// roociloadFnType__objectFree() [INTERNAL]
//   Wrapper for OCIObjectFree().
//-----------------------------------------------------------------------------
sword OCIObjectFree(OCIEnv   *env,
                    OCIError *err,
                    void     *instance,
                    ub2       flag)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__objectFree, OCIObjectFree,
                        &loadSyms.fnObjectFree, loadCtx_g);
  status = (*loadSyms.fnObjectFree)(env, err, instance, flag);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "free object");
}


//-----------------------------------------------------------------------------
// roociloadFnType__objectGetAttr() [INTERNAL]
//   Wrapper for OCIObjectGetAttr().
//-----------------------------------------------------------------------------
sword OCIObjectGetAttr(OCIEnv         *env,
                       OCIError       *err,
                       void           *instance,
                       void           *null_struct,
                       OCIType        *tdo,
                       const oratext **names,
                       const ub4      *lengths,
                       const ub4       name_count,
                       const ub4      *indexes,
                       const ub4       index_count,
                       OCIInd         *attr_null_status,
                       void          **attr_null_struct,
                       void          **attr_value,
                       OCIType       **attr_tdo)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__objectGetAttr, OCIObjectGetAttr,
                        &loadSyms.fnObjectGetAttr, loadCtx_g);
  status = (*loadSyms.fnObjectGetAttr)(env, err, instance, null_struct,
                        tdo, names, lengths, name_count, indexes, index_count,
                        attr_null_status, attr_null_struct, attr_value,
                        attr_tdo);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "get object attribute");
}


//-----------------------------------------------------------------------------
// roociloadFnType__objectGetInd() [INTERNAL]
//   Wrapper for OCIObjectGetInd().
//-----------------------------------------------------------------------------
sword OCIObjectGetInd(OCIEnv     *env,
                      OCIError   *err,
                      void       *instance,
                      void      **null)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__objectGetInd, OCIObjectGetInd,
                        &loadSyms.fnObjectGetInd, loadCtx_g);
  status = (*loadSyms.fnObjectGetInd)(env, err, instance, null);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "get object indicator");
}


//-----------------------------------------------------------------------------
// roociloadFnType__objectGetTypeRef() [INTERNAL]
//   Wrapper for OCIObjectGetTypeRef().
//-----------------------------------------------------------------------------
sword OCIObjectGetTypeRef(OCIEnv   *env,
                          OCIError *err,
                          void     *instance,
                          OCIRef   *tdo_ref)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__objectGetTypeRef, OCIObjectGetTypeRef,
                        &loadSyms.fnObjectGetTypeRef, loadCtx_g);
  status = (*loadSyms.fnObjectGetTypeRef)(env, err, instance, tdo_ref);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "get object type ref");
}


//-----------------------------------------------------------------------------
// roociloadFnType__objectNew() [INTERNAL]
//   Wrapper for OCIObjectNew().
//-----------------------------------------------------------------------------
sword OCIObjectNew(OCIEnv            *env,
                   OCIError          *err,
                   const OCISvcCtx   *svc,
                   OCITypeCode        tc,
                   OCIType           *tdo,
                   void              *table,
                   OCIDuration        pin_duration,
                   boolean            value,
                   void             **instance)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__objectNew, OCIObjectNew,
                        &loadSyms.fnObjectNew, loadCtx_g);
  status = (*loadSyms.fnObjectNew)(env, err, svc, tc, tdo, table,
                                   pin_duration, value, instance);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "create object");
}


//-----------------------------------------------------------------------------
// roociloadFnType__objectPin() [INTERNAL]
//   Wrapper for OCIObjectPin().
//-----------------------------------------------------------------------------
sword OCIObjectPin(OCIEnv             *env,
                   OCIError           *err,
                   OCIRef             *object_ref,
                   OCIComplexObject   *corhdl,
                   OCIPinOpt           pin_opt,
                   OCIDuration         pin_dur,
                   OCILockOpt          lock_opt,
                   void              **object)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__objectPin, OCIObjectPin,
                        &loadSyms.fnObjectPin, loadCtx_g);
  status = (*loadSyms.fnObjectPin)(env, err, object_ref, corhdl, pin_opt,
                                   pin_dur, lock_opt, object);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "pin reference");
}


//-----------------------------------------------------------------------------
// roociloadFnType__objectSetAttr() [INTERNAL]
//   Wrapper for OCIObjectSetAttr().
//-----------------------------------------------------------------------------
sword OCIObjectSetAttr(OCIEnv         *env,
                       OCIError       *err,
                       void           *instance,
                       void           *null_struct,
                       struct OCIType *tdo,
                       const oratext **names,
                       const ub4      *lengths,
                       const ub4       name_count,
                       const ub4      *indexes,
                       const ub4       index_count,
                       const OCIInd    attr_null_status,
                       const void     *attr_null_struct,
                       const void     *attr_value)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__objectSetAttr, OCIObjectSetAttr,
                        &loadSyms.fnObjectSetAttr,
                        loadCtx_g);
  status = (*loadSyms.fnObjectSetAttr)(env, err, instance, null_struct,
                        tdo, names, lengths, name_count, indexes, index_count,
                        attr_null_status, attr_null_struct, attr_value);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "set object attribute");
}


//-----------------------------------------------------------------------------
// roociloadFnType__paramGet() [INTERNAL]
//   Wrapper for OCIParamGet().
//-----------------------------------------------------------------------------
sword OCIParamGet(const void  *hndlp,
                  ub4          htype,
                  OCIError    *errhp,
                  void       **parmdpp,
                  ub4          pos)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__paramGet, OCIParamGet,
                        &loadSyms.fnParamGet, loadCtx_g);
  status = (*loadSyms.fnParamGet)(hndlp, htype, errhp, parmdpp, pos);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "param get");
}


//-----------------------------------------------------------------------------
// roociloadFnType__rawAssignBytes() [INTERNAL]
//   Wrapper for OCIRawAssignBytes().
//-----------------------------------------------------------------------------
sword OCIRawAssignBytes(OCIEnv     *env,
                        OCIError   *err,
                        const ub1  *rhs,
                        ub4         rhs_len,
                        OCIRaw    **lhs)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__rawAssignBytes, OCIRawAssignBytes,
                        &loadSyms.fnRawAssignBytes,
                        loadCtx_g);
  status = (*loadSyms.fnRawAssignBytes)(env, err, rhs, rhs_len, lhs);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "assign bytes to raw");
}


//-----------------------------------------------------------------------------
// roociloadFnType__rawPtr() [INTERNAL]
//   Wrapper for OCIRawPtr().
//-----------------------------------------------------------------------------
ub1 *OCIRawPtr(OCIEnv *env, const OCIRaw *raw)
{
  sword status = 0;
  ROOCILOADFNTYPE__LOADSYMBOL(roociloadFnType__rawPtr, OCIRawPtr,
                              &loadSyms.fnRawPtr, loadCtx_g, &status);
  if (status < 0)
  {
    (void) roociload__set(loadCtx_g, "load symbol OCIRawPtr",
                          RORACLE_ERR_LOAD_SYMBOL);
    return NULL;
  }
  else
    return (*loadSyms.fnRawPtr)(env, raw);
}


//-----------------------------------------------------------------------------
// roociloadFnType__rawSize() [INTERNAL]
//   Wrapper for OCIRawSize().
//-----------------------------------------------------------------------------
ub4 OCIRawSize(OCIEnv *env, const OCIRaw *raw)
{
  sword status = 0;
  ROOCILOADFNTYPE__LOADSYMBOL(roociloadFnType__rawSize, OCIRawSize,
                              &loadSyms.fnRawSize, loadCtx_g, &status);
  if (status < 0)
  {
    (void) roociload__set(loadCtx_g, "load symbol OCIRawSize",
                          RORACLE_ERR_LOAD_SYMBOL);
    return 0;
  }
  else
    return (ub4)(*loadSyms.fnRawSize)(env, raw);
}


//-----------------------------------------------------------------------------
// roociloadFnType__reset() [INTERNAL]
//   Wrapper for OCIRreset().
//-----------------------------------------------------------------------------
sword OCIReset(void *hndl, OCIError *err)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__reset, OCIReset,
                        &loadSyms.fnReset, loadCtx_g);
  status = (*loadSyms.fnReset)(hndl, err);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "reset connection");
}


//-----------------------------------------------------------------------------
// roociloadFnType__serverRelease() [INTERNAL]
//   Wrapper for OCIServerRelease().
//-----------------------------------------------------------------------------
sword OCIServerRelease(void     *hndlp,
                       OCIError *errhp,
                       oratext  *bufp,
                       ub4       bufsz,
                       ub1       hndltype,
                       ub4      *version)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__serverRelease, OCIServerRelease,
                        &loadSyms.fnServerRelease,
                        loadCtx_g);
  status = (*loadSyms.fnServerRelease)(hndlp, errhp, bufp, bufsz,
                                       hndltype, version);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "get server release");
}


//-----------------------------------------------------------------------------
// roociloadFnType__serverVersion() [INTERNAL]
//   Wrapper for OCIServerVersion().
//-----------------------------------------------------------------------------
sword OCIServerVersion(void     *hndlp,
                       OCIError *errhp,
                       oratext  *bufp,
                       ub4       bufsz,
                       ub1       hndltype)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__serverVersion, OCIServerVersion,
                        &loadSyms.fnServerVersion, loadCtx_g);
  status = (*loadSyms.fnServerVersion)(hndlp, errhp,
                                       bufp, bufsz, hndltype);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "get server version");
}


//-----------------------------------------------------------------------------
// roociloadFnType__sessionGet() [INTERNAL]
//   Wrapper for OCISessionGet().
//-----------------------------------------------------------------------------
sword OCISessionGet(OCIEnv         *envhp,
                    OCIError       *errhp,
                    OCISvcCtx     **svchp,
                    OCIAuthInfo    *sechp,
                    OraText        *poolName,
                    ub4             poolNameLen,
                    const OraText  *tagInfo,
                    ub4             tagInfoLen,
                    OraText       **retTagInfo,
                    ub4            *retTagInfoLen,
                    boolean        *found,
                    ub4             mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__sessionGet, OCISessionGet,
                        &loadSyms.fnSessionGet, loadCtx_g);
  status = (*loadSyms.fnSessionGet)(envhp, errhp, svchp,
                        sechp, poolName, poolNameLen, tagInfo, tagInfoLen,
                        retTagInfo, retTagInfoLen, found, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "get session");
}


//-----------------------------------------------------------------------------
// roociloadFnType__sessionRelease() [INTERNAL]
//   Wrapper for OCISessionRelease().
//-----------------------------------------------------------------------------
sword OCISessionRelease(OCISvcCtx *svchp,
                        OCIError  *errhp,
                        OraText   *tag,
                        ub4        tagLen,
                        ub4        mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__sessionRelease, OCISessionRelease,
                        &loadSyms.fnSessionRelease, loadCtx_g);
  status = (*loadSyms.fnSessionRelease)(svchp, errhp, tag,
                                                tagLen, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "release session");
}


//-----------------------------------------------------------------------------
// roociloadFnType__stmtExecute() [INTERNAL]
//   Wrapper for OCIStmtExecute().
//-----------------------------------------------------------------------------
sword OCIStmtExecute(OCISvcCtx         *svchp,
                     OCIStmt           *stmhp,
                     OCIError          *errhp,
                     ub4                iters,
                     ub4                rowoff,
                     const OCISnapshot *snap_in,
                     OCISnapshot       *snap_out,
                     ub4                mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__stmtExecute, OCIStmtExecute,
                        &loadSyms.fnStmtExecute, loadCtx_g);
  status = (*loadSyms.fnStmtExecute)(svchp, stmhp, errhp, iters,
                                     rowoff, snap_in, snap_out, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "execute");
}


//-----------------------------------------------------------------------------
// roociloadFnType__stmtFetch2() [INTERNAL]
//   Wrapper for OCIStmtFetch2().
//-----------------------------------------------------------------------------
sword OCIStmtFetch2(OCIStmt  *stmhp,
                    OCIError *errhp,
                    ub4       nrows,
                    ub2       orientation,
                    sb4       scrollOffset,
                    ub4       mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__stmtFetch2, OCIStmtFetch2,
                        &loadSyms.fnStmtFetch2, loadCtx_g);
  status = (*loadSyms.fnStmtFetch2)(stmhp, errhp, nrows, orientation,
                                    scrollOffset, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "fetch2");
}


//-----------------------------------------------------------------------------
// roociloadFnType__stmtPrepare() [INTERNAL]
//   Wrapper for OCIStmtPrepare().
//-----------------------------------------------------------------------------
sword OCIStmtPrepare(OCIStmt       *stmhp,
                     OCIError      *errhp,
                     const oratext *stmt,
                     ub4            stmt_len,
                     ub4            language,
                     ub4            mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__stmtPrepare, OCIStmtPrepare,
                        &loadSyms.fnStmtPrepare, loadCtx_g);
  status = (*loadSyms.fnStmtPrepare)(stmhp, errhp, stmt, stmt_len,
                                     language, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "prepare");
}


//-----------------------------------------------------------------------------
// roociloadFnType__stmtPrepare2() [INTERNAL]
//   Wrapper for OCIStmtPrepare2().
//-----------------------------------------------------------------------------
sword OCIStmtPrepare2(OCISvcCtx     *svchp,
                      OCIStmt      **stmhp,
                      OCIError      *errhp,
                      const oratext *stmt,
                      ub4            stmt_len,
                      const oratext *key,
                      ub4            key_len,
                      ub4            language,
                      ub4            mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__stmtPrepare2, OCIStmtPrepare2,
                        &loadSyms.fnStmtPrepare2, loadCtx_g);
  status = (*loadSyms.fnStmtPrepare2)(svchp, stmhp, errhp, stmt, stmt_len,
                                      key, key_len, language, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "prepare2");
}


//-----------------------------------------------------------------------------
// roociloadFnType__stmtRelease() [INTERNAL]
//   Wrapper for OCIStmtRelease().
//-----------------------------------------------------------------------------
sword OCIStmtRelease(OCIStmt       *stmhp,
                     OCIError      *errhp,
                     const oratext *key,
                     ub4            key_len,
                     ub4            mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__stmtRelease, OCIStmtRelease,
                        &loadSyms.fnStmtRelease, loadCtx_g);
  status = (*loadSyms.fnStmtRelease)(stmhp, errhp, key, key_len, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "release statement");
}


//-----------------------------------------------------------------------------
// roociloadFnType__stringAssignText() [INTERNAL]
//   Wrapper for OCIStringAssignText().
//-----------------------------------------------------------------------------
sword OCIStringAssignText(OCIEnv         *env,
                          OCIError       *err,
                          const oratext  *rhs,
                          ub4             rhs_len,
                          OCIString     **lhs)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__stringAssignText, OCIStringAssignText,
                        &loadSyms.fnStringAssignText, loadCtx_g);
  status = (*loadSyms.fnStringAssignText)(env, err, rhs, rhs_len, lhs);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "assign to string");
}


//-----------------------------------------------------------------------------
// roociloadFnType__stringPtr() [INTERNAL]
//   Wrapper for OCIStringPtr().
//-----------------------------------------------------------------------------
oratext *OCIStringPtr(OCIEnv *env, const OCIString *vs)
{
  sword status = 0;
  ROOCILOADFNTYPE__LOADSYMBOL(roociloadFnType__stringPtr, OCIStringPtr,
                              &loadSyms.fnStringPtr, loadCtx_g, &status);
  if (status < 0)
  {
    (void) roociload__set(loadCtx_g, "load symbol OCIStringPtr",
                          RORACLE_ERR_LOAD_SYMBOL);
    return NULL;
  }
  else
    return ((oratext *)(*loadSyms.fnStringPtr)(env, vs));
}


//-----------------------------------------------------------------------------
// roociloadFnType__stringResize() [INTERNAL]
//   Wrapper for OCIStringResize().
//-----------------------------------------------------------------------------
sword OCIStringResize(OCIEnv     *env,
                      OCIError   *err,
                      ub4         new_size,
                      OCIString **vs)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__stringResize, OCIStringResize,
                        &loadSyms.fnStringResize, loadCtx_g);
  status = (*loadSyms.fnStringResize)(env, err, new_size, vs);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "resize string");
}


//-----------------------------------------------------------------------------
// roociloadFnType__stringSize() [INTERNAL]
//   Wrapper for OCIStringSize().
//-----------------------------------------------------------------------------
ub4 OCIStringSize(OCIEnv *env, const OCIString *vs)
{
  sword status = 0;
  ROOCILOADFNTYPE__LOADSYMBOL(roociloadFnType__stringSize, OCIStringSize,
                              &loadSyms.fnStringSize, loadCtx_g, &status);
  if (status < 0)
  {
    (void) roociload__set(loadCtx_g, "load symbol OCIStringSize",
                          RORACLE_ERR_LOAD_SYMBOL);
    return 0;
  }
  else
    return (*loadSyms.fnStringSize)(env, vs);
}


//-----------------------------------------------------------------------------
// roociloadFnType__tableFirst() [INTERNAL]
//   Wrapper for OCITableFirst().
//-----------------------------------------------------------------------------
sword OCITableFirst(OCIEnv         *env,
                    OCIError       *err,
                    const OCITable *tbl,
                    sb4            *index)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__tableFirst, OCITableFirst,
                        &loadSyms.fnTableFirst, loadCtx_g);
  status = (*loadSyms.fnTableFirst)(env, err, tbl, index);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "get first table");
}


//-----------------------------------------------------------------------------
// roociloadFnType__tableNext() [INTERNAL]
//   Wrapper for OCITableNext().
//-----------------------------------------------------------------------------
sword OCITableNext(OCIEnv         *env,
                   OCIError       *err,
                   sb4             index,
                   const OCITable *tbl,
                   sb4            *next_index,
                   boolean        *exists)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__tableNext, OCITableNext,
                        &loadSyms.fnTableNext, loadCtx_g);
  status = (*loadSyms.fnTableNext)(env, err, index, tbl,
                                   next_index, exists);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "get next table");
}


//-----------------------------------------------------------------------------
// roociloadFnType__threadCreate() [INTERNAL]
//   Wrapper for OCIThreadCreate().
//-----------------------------------------------------------------------------
sword OCIThreadCreate(void            *hndl,
                      OCIError        *err,
                      void            (*start)(void  *),
                      void            *arg,
                      OCIThreadId     *tid,
                      OCIThreadHandle *tHnd)
{
  sword status;
  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__threadCreate, OCIThreadCreate,
                        &loadSyms.fnThreadCreate, loadCtx_g);
  status = (*loadSyms.fnThreadCreate)(hndl, err, start, arg, tid, tHnd);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "create thread");
  return OCI_SUCCESS;
}


//-----------------------------------------------------------------------------
// roociloadFnType__threadHndInit() [INTERNAL]
//   Wrapper for OCIThreadHndInit().
//-----------------------------------------------------------------------------
sword OCIThreadHndInit(void             *hndl,
                       OCIError         *err,
                       OCIThreadHandle **tHnd)
{
  sword status;
  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__threadHndInit, OCIThreadHndInit,
                        &loadSyms.fnThreadHndInit, loadCtx_g);
  status = (*loadSyms.fnThreadHndInit)(hndl, err, tHnd);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "init thread handle");
  return OCI_SUCCESS;
}


//-----------------------------------------------------------------------------
// roociloadFnType__threadIdInit() [INTERNAL]
//   Wrapper for OCIThreadIdInit().
//-----------------------------------------------------------------------------
sword OCIThreadIdInit(void          *hndl,
                      OCIError     *err,
                      OCIThreadId **tid)
{
  sword status;
  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__threadIdInit, OCIThreadIdInit,
                        &loadSyms.fnThreadIdInit, loadCtx_g);
  status = (*loadSyms.fnThreadIdInit)(hndl, err, tid);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "thread id init");
  return OCI_SUCCESS;
}


//-----------------------------------------------------------------------------
// roociloadFnType__threadJoin() [INTERNAL]
//   Wrapper for OCIThreadJoin().
//-----------------------------------------------------------------------------
sword OCIThreadJoin(void            *hndl,
                    OCIError        *err,
                    OCIThreadHandle *tHnd)
{
  sword status;
  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__threadJoin, OCIThreadJoin,
                        &loadSyms.fnThreadJoin, loadCtx_g);
  status = (*loadSyms.fnThreadJoin)(hndl, err, tHnd);
  ROOCILOAD_CHECK_AND_RETURN(err, status, "thread join");
  return OCI_SUCCESS;
}


//-----------------------------------------------------------------------------
// roociloadFnType__transCommit() [INTERNAL]
//   Wrapper for OCITransCommit().
//-----------------------------------------------------------------------------
sword OCITransCommit(OCISvcCtx *svchp,
                     OCIError  *errhp,
                     ub4        flags)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__transCommit, OCITransCommit,
                        &loadSyms.fnTransCommit, loadCtx_g);
  status = (*loadSyms.fnTransCommit)(svchp, errhp, flags);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "commit");
}


//-----------------------------------------------------------------------------
// roociloadFnType__transRollback() [INTERNAL]
//   Wrapper for OCITransRollback().
//-----------------------------------------------------------------------------
sword OCITransRollback(OCISvcCtx *svchp,
                       OCIError  *errhp,
                       ub4        flags)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__transRollback, OCITransRollback,
                        &loadSyms.fnTransRollback, loadCtx_g);
  status = (*loadSyms.fnTransRollback)(svchp, errhp, flags);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "rollback");
}


//-----------------------------------------------------------------------------
// roociloadFnType__typeByName() [INTERNAL]
//   Wrapper for OCITypeByName().
//-----------------------------------------------------------------------------
sword OCITypeByName(OCIEnv            *envhp,
                    OCIError          *errhp,
                    const OCISvcCtx   *svchp,
                    const oratext     *schema_name,
                    ub4                schema_name_len,
                    const oratext     *type_name,
                    ub4                type_name_length,
                    const oratext     *version_name,
                    ub4                version_name_length,
                    OCIDuration        pin_duration,
                    OCITypeGetOpt      get_option,
                    OCIType          **tdo)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__typeByName, OCITypeByName,
                        &loadSyms.fnTypeByName, loadCtx_g);
  status = (*loadSyms.fnTypeByName)(envhp, errhp, svchp,
                        schema_name, schema_name_len,
                        type_name, type_name_length,
                        version_name, version_name_length,
                        pin_duration, get_option, tdo);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "get type by name");
}


//-----------------------------------------------------------------------------
// roociloadFnType__typeByFullName() [INTERNAL]
//   Wrapper for OCITypeByFullName().
//-----------------------------------------------------------------------------
sword OCITypeByFullName(OCIEnv            *envhp,
                        OCIError          *errhp,
                        const OCISvcCtx   *svchp,
                        const oratext     *full_type_name,
                        ub4                full_type_name_length,
                        const oratext     *version_name,
                        ub4                version_name_length,
                        OCIDuration        pin_duration,
                        OCITypeGetOpt      get_option,
                        OCIType          **tdo)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__typeByFullName, OCITypeByFullName,
                        &loadSyms.fnTypeByFullName, loadCtx_g);
  status = (*loadSyms.fnTypeByFullName)(envhp, errhp, svchp,
                        full_type_name, full_type_name_length,
                        version_name, version_name_length,
                        pin_duration, get_option, tdo);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "get type by full name");
}


//-----------------------------------------------------------------------------
// roociloadFnType__unicodeToCharSet() [INTERNAL]
//   Wrapper for OCIUnicodeToCharSet().
//-----------------------------------------------------------------------------
sword OCIUnicodeToCharSet(void      *envhp,
                          OraText   *dst,
                          size_t     dstlen,
                          const ub2 *src,
                          size_t     srclen,
                          size_t    *rsize)
{
  sword status;
  
  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__unicodeToCharSet, OCIUnicodeToCharSet,
                        &loadSyms.fnUnicodeToCharSet, loadCtx_g);
  status = (*loadSyms.fnUnicodeToCharSet)(envhp, dst, dstlen, src,
                                                  srclen, rsize);
  ROOCILOAD_CHECK_AND_RETURN(envhp, status, "unicode to character set");
}


#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
//-----------------------------------------------------------------------------
// roociloadFnType__vectorFromArray() [INTERNAL]
//   Wrapper for OCIVectorFromArray().
//-----------------------------------------------------------------------------
sword OCIVectorFromArray(OCIVector *vectord,
                         OCIError  *errhp,
                         ub1        vformat,
                         ub4        vdim,
                         void      *vecarray,
                         ub4        mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__vectorFromArray, OCIVectorFromArray,
                        &loadSyms.fnvectorFromArray, loadCtx_g);
  status = (*loadSyms.fnvectorFromArray)(vectord, errhp, vformat, vdim,
                                         vecarray, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "vector from array");
}


//-----------------------------------------------------------------------------
// roociloadFnType__vectorFromSparseArray() [INTERNAL]
//   Wrapper for OCIVectorFromSparseArray().
//-----------------------------------------------------------------------------
sword OCIVectorFromSparseArray(OCIVector *vectord,
        OCIError *errhp, ub1 vformat, ub4 vdim, ub4 indices,
        void *indarray, void *vecarray, ub4 mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__vectorFromSparseArray,
                        OCIVectorFromSparseArray,
                        &loadSyms.fnvectorFromSparseArray, loadCtx_g);
  status = (*loadSyms.fnvectorFromSparseArray)(vectord, errhp, vformat, vdim,
                                         indices, indarray, vecarray, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "vector from sparse array");
}

//-----------------------------------------------------------------------------
// roociloadFnType__vectorFromText() [INTERNAL]
//   Wrapper for OCIVectorFromText().
//-----------------------------------------------------------------------------
sword OCIVectorFromText(OCIVector     *vectord,
                        OCIError      *errhp,
                        ub1            vformat,
                        ub4            vdim,
                        const OraText *vtext,
                        ub4            vtextlen,
                        ub4            mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__vectorFromText, OCIVectorFromText,
                        &loadSyms.fnvectorFromText, loadCtx_g);
  status = (*loadSyms.fnvectorFromText)(vectord, errhp, vformat, vdim,
                                        vtext, vtextlen, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "vector from text");
}


//-----------------------------------------------------------------------------
// roociloadFnType__vectorToArray() [INTERNAL]
//   Wrapper for OCIVectorToArray().
//-----------------------------------------------------------------------------
sword OCIVectorToArray(OCIVector    *vectord,
                       OCIError     *errhp,
                       ub1           vformat,
                       ub4          *vdim,
                       void         *vecarray,
                       ub4           mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__vectorToArray, OCIVectorToArray,
                        &loadSyms.fnvectorToArray, loadCtx_g);
  status = (*loadSyms.fnvectorToArray)(vectord, errhp, vformat, vdim,
                                       vecarray, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "vector to array");
}


//-----------------------------------------------------------------------------
// roociloadFnType__vectorToSparseArray() [INTERNAL]
//   Wrapper for OCIVectorToSparseArray().
//-----------------------------------------------------------------------------
sword OCIVectorToSparseArray(OCIVector *vectord,
                             OCIError  *errhp,
                             ub1        vformat,
                             ub4       *vdim,
                             ub4       *indices,
                             void      *indarray,
                             void      *vecarray,
                             ub4        mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__vectorToSparseArray,
                        OCIVectorToSparseArray,
                        &loadSyms.fnvectorToSparseArray, loadCtx_g);
  status = (*loadSyms.fnvectorToSparseArray)(vectord, errhp, vformat, vdim,
                                       indices, indarray, vecarray, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "vector to sparse array");

}

//-----------------------------------------------------------------------------
// roociloadFnType__vectorToText() [INTERNAL]
//   Wrapper for OCIVectorToText().
//-----------------------------------------------------------------------------
sword OCIVectorToText(OCIVector    *vectord,
                      OCIError     *errhp,
                      OraText      *vtext,
                      ub4          *vtextlen,
                      ub4           mode)
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__vectorToText, OCIVectorToText,
                        &loadSyms.fnvectorToText, loadCtx_g);
  status = (*loadSyms.fnvectorToText)(vectord, errhp, vtext, vtextlen, mode);
  ROOCILOAD_CHECK_AND_RETURN(errhp, status, "vector to text");
}
#endif /* OCI_MAJOR_VERSION >= 23 */


//-----------------------------------------------------------------------------
// roociloadFnType__ociepgoe() [INTERNAL]
//   Wrapper for OCIExtProcGetEnv().
//-----------------------------------------------------------------------------
sword OCIExtProcGetEnv(
OCIExtProcContext   *with_context,         /* IN  : With context ptr */
OCIEnv             **envh,                 /* OUT : OCI environment handle */
OCISvcCtx          **svch,                 /* OUT : OCI Service handle */
OCIError           **errh)                 /* OUT : OCI Error handle */
{
  sword status;

  ROOCILOAD_LOAD_SYMBOL(roociloadFnType__ociepgoe, ociepgoe,
                        &loadSyms.fnociepgoe, loadCtx_g);
  status = (*loadSyms.fnociepgoe)(with_context, envh, svch, errh);
  ROOCILOAD_CHECK_AND_RETURN(*errh, status, "extproc get env");
}

