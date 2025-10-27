/* Copyright (c) 2011, 2025, Oracle and/or its affiliates.*/
/* All rights reserved.*/

/*
   NAME
     rodbi.c

   DESCRIPTION
     Implementation of all DBI functions for OCI based DBI driver for R.
   
   EXPORT FUNCTION(S)
     (*) DRIVER FUNCTIONS
         rociDrvAlloc    - DRiVer ALLOCate handle
         rociDrvInit     - DRiVer INITialize handle
         rociDrvInfo     - DRiVer get INFO
         rociDrvTerm     - DRiVer TERMinate handle

     (*) CONNECTION FUNCTIONS
         rociConInit     - CONnection INITialize handle
         rociConError    - CONnection get and reset last ERRor
         rociConInfo     - CONnection get INFO
         rociConTerm     - CONnection TERMinate handle
         rociConCommit   - CONnection transaction COMMIT
         rociConRollback - CONnection transaction ROLLBACK
         rodbiAssertCon  - CONnection validation

     (*) RESULT FUNCTIONS
         rociResInit     - RESult INITialize handle and execute statement
         rociResExec     - RESult re-EXECute
         rociResFetch    - RESult FETCH data
         rociResInfo     - RESult get INFO
         rociEOFRes      - Is end of result set?
         rociResTerm     - RESult TERMinate handle
         rodbiAssertRes  - RESult validation

   INTERNAL FUNCTION(S)
     NONE

   STATIC FUNCTION(S)
     (*) DRIVER FUNCTIONS
         rodbiGetDrv
         rodbiDrvInfoConnections
         rodbiDrvFree

     (*) CONNECTION FUNCTIONS
         rodbiGetCon
         rodbiConInfoResults

     (*) RESULT FUNCTIONS
         rodbiGetRes
         rodbiResExecStmt
         rodbiResExecQuery
         rodbiResExecBind
         rodbiResBind
         rodbiPlsqlResBind
         rodbiResBindCopy
         rodbiResAlloc
         rodbiResExpand
         rodbiResSplit
         rodbiResAccum
         rodbiResAccumInCache
         rodbiResTrim
         rodbiResDataFrame
         rodbiResStateNext
         rodbiResInfoStmt
         rodbiResInfoFields

     (*) ERROR CHECK FUNCTIONS
         rodbiCheck

   NOTES

   MODIFIED   (MM/DD/YY)
   rpingte     10/17/25 - change __FUNCTION__ to __func__
   rpingte     05/10/25 - add sparse vector support
   rpingte     04/25/25 - Bug 37777349: support data > 32767 in bind to CLOB
   brusures    10/23/24 - add format specifiers for warnings and errors
   brusures    10/21/24 - fixing Windows Warning
   brusures    10/16/24 - fix compiler error for VFMT flags <23.4
   rpingte     10/02/24 - do not display flex for now
   rpingte     07/11/24 - fix compiler warnigs with pre-19c clients
   rpingte     04/09/24 - use dynamic loading
   rpingte     03/19/24 - add vector supprt
   rpingte     01/26/22 - Add support for PLSQL boolean
   rpingte     04/03/20 - Allow duplicate binds and use elements in data frame
                          as the upper bound instead of bind count from OCI
   msavanur    06/22/19 - Recreate driver handle in case of objects
   msavanur    05/20/19 - extract N pass boolean to roociInitializeCtx
   rpingte     03/19/19 - Object support
   rpingte     01/14/19 - version 1.3-2 -> 1.3-3
   rpingte     11/01/18 - use ora.encoding for DMLs if specified
   rpingte     12/14/16 - version 1.3-1 -> 1.3-2
   rpingte     10/05/16 - fix compilation on windows
   ssjaiswa    08/03/16 - 22329115: Initialize CursorCount by 1 instead of 0
   ssjaiswa    07/14/16 - update ROracle version to 1.3-1
   ssjaiswa    05/12/16 - add new function rodbiPlsqlResBind
   ssjaiswa    03/15/16 - pre-incrementing CursorCount variable to avoid passing
                          0 for calloc (number of items) argument, Bug[22329115]
   ssjaiswa    03/12/16 - removing break from OCI_SUCCESS_WITH_INFO check, 
                          Bug [22233938]
   ssjaiswa    03/11/16 - REFETCH state added for multiple cursor fetch
   ssjaiswa    03/11/16 - SQLT_RSET bind type is set for cursor case
   ssjaiswa    03/10/16 - add list and name fields for list return from ResFetch
   ssjaiswa    03/08/16 - set indicator buffer to NULL if Plsql OUT parameter
   ssjaiswa    03/07/16 - set state to FETCH for Plsql OUT in rodbiResExecBind
   ssjaiswa    03/07/16 - add PlsqlResPopulate for Plsql result populating
   ssjaiswa    03/04/16 - add numOut field
   rpingte     02/23/16 - remove unused variables
   rpingte     08/05/15 - 21128853: performance improvements for datetime types
   ssjaiswa    08/03/15 - update version to 1.2-2
   rpingte     03/31/15 - add ora.attributes
   rpingte     03/25/15 - add NCHAR, NVARCHAR2 and NCLOB
   rpingte     01/26/15 - convert UCS2 to UTF8 for NCHAR in TimesTen
   rpingte     12/04/14 - NLS support
   ssjaiswa    11/21/14 - update version to 1.2-1
   ssjaiswa    09/10/14 - Add bulk_write
   rpingte     06/04/14 - time stamp with time zone define as
                          SQLT_TIMESTAMP_LTZ
   rpingte     05/21/14 - add time zone to connection
   rpingte     05/02/14 - maintain date, time stamp, time stamp with time zone
                          and time stamp with local time zone as string
   paboyoun    06/04/14 - switch to standard format for default row names
   rpingte     05/13/14 - align buffer for char/raw data
   rpingte     04/21/14 - use SQLT_LVC & SQLT_LVB for large bind data
   rpingte     04/21/14 - change bsiz_roociRes to sb4
   rpingte     04/16/14 - remove AIX tracing
   rpingte     04/12/14 - add more diagnostics for AIX srg
   rpingte     04/09/14 - check DIAG_SRG_AIX integration run
   rpingte     04/07/14 - Add debug print statements to determine SRG issue on
                          AIX
   rpingte     03/10/14 - add end of result
   rpingte     03/06/14 - ROracle version to 1.1-12 & fix fetch with cache
   rkanodia    09/17/13 - change ROracle version to 1.1-11
   rpingte     02/12/14 - OCI_SESSGET_SYSDBA available in specific
                          patch/release
   rpingte     01/09/14 - Copyright update
   rpingte     10/24/13 - Cache resultset in memory before transferring to R to
                          avoid unnecessary alloc and free using allocVector
                          when result exceeds bulk_read rows
   rkanodia    10/03/13 - Add session mode
   rkanodia    09/17/13 - change ROracle version to 1.1-11
   rpingte     05/08/13 - update version to 10
   rpingte     04/09/13 - use SQLT_FLT instead of SQLT_BDOUBLE
   qinwan      03/01/13 - remove rawVecToListCall
   rpingte     01/30/13 - change version to 1.1-8
   rkanodia    12/10/12 - Changed default value of bulk read/write to 1000
   rpingte     11/20/12 - 15900089: remove avoidable errors reported with date
                          time types
   paboyoun    11/05/12 - add PROTECT to rociConInfo
   paboyoun    09/29/12 - use Rf_inherits to determine class
   rpingte     09/26/12 - TimesTen interval DS not supported for difftime
   rpingte     09/21/12 - use roociAllocDescBindBuf
   paboyoun    09/17/12 - add difftime support
   demukhin    09/04/12 - add Extproc driver
   rkanodia    08/27/12 - [14542319] Updated ROracle version from 1.1-4 to
                          1.1-5
   rkanodia    08/08/12 - Removed redundant arguments passed to functions
                          and removed LOB prefetch support, bug [14508278]
   qinwan      08/06/12 - remove hexstrtoraw and rawtohexstr call
   rkanodia    07/27/12 - updated driver version
   rpingte     07/27/12 - fix error check
   qinwan      07/22/12 - add rawToStrhexCall
   rkanodia    07/01/12 - block statement caching without prefetch
   rpingte     06/21/12 - convert utf-8 sql to env handle character set
   jfeldhau    06/18/12 - ROracle support for TimesTen.
   rkanodia    06/13/12 - put boundary check for string data
   rpingte     06/06/12 - use charset form for NLS
   rpingte     05/31/12 - handle NULL raw
   rpingte     05/22/12 - POSIXct, POSIXlt and RAW support
   qinwan      05/22/12 - add strhexToRawCall for bugfix (Bug No. 14051139) 
   rkanodia    05/13/12 - LOB prefetch
   rkanodia    05/12/12 - statement cache
   rpingte     05/19/12 - Fix windows build and warnings
   demukhin    05/10/12 - translation changes
   rpingte     05/07/12 - fix memory leak
   rpingte     05/03/12 - cleanup & performance
   rkanodia    05/01/12 - Namespace changes
   rpingte     04/25/12 - use pointers instead of id
   rpingte     04/19/12 - normalize structures
   rkanodia    03/25/12 - DBI calls implementation
   rkanodia    03/15/12 - cleanup of connection structure   
   rkanodia    04/01/12 - timestamp support
   rkanodia    03/05/12 - obs7 bugfix (Bug No. 13843813)
   rkanodia    03/05/12 - obs5 bugfix (Bug No. 13844668)
   rkanodia    03/05/12 - obs4 bugfix (Bug No. 13843811)
   demukhin    03/29/12 - bug 13904056: wrong result in dbWriteTable with NAs
   demukhin    03/23/12 - bug 13880813: when NUMBER is an integer
   paboyoun    03/20/12 - simplify protect stack management and
                          creation of length 1 vectors
   schakrab    02/28/12 - enable oracle wallet in ROracle
   demukhin    01/20/12 - cleanup
   paboyoun    01/12/12 - add support for writing logical columns
   paboyoun    01/10/12 - temporary fix to handle DATE data type
   demukhin    12/12/11 - ROracle to support ORACLE_HOME
   demukhin    12/01/11 - add support for more methods
   demukhin    10/17/11 - Creation

*/

#include "rooci.h"
#include "rodbi.h"

#define RODBI_ERR_INVALID_DRV      _("invalid driver")
#define RODBI_ERR_INVALID_CON      _("invalid connection")
#define RODBI_ERR_INVALID_RES      _("invalid result set")
#define RODBI_ERR_UNKNOWN_VFMT     _("ROracle internal error [unexpected vector format %d, expected *Iflex), float16, float32, float64, int8 or binary]")
#define RODBI_ERR_MEMORY_ALC       _("memory could not be allocated")
#define RODBI_ERR_MANY_ROWS        _("bind data has too many rows")
#define RODBI_ERR_BIND_MISMATCH    _("bind data does not match bind specification")
#define RODBI_ERR_BIND_EMPTY       _("bind data is empty")
#define RODBI_ERR_UNSUPP_BIND_TYPE _("unsupported bind type")
#define RODBI_ERR_UNSUPP_COL_TYPE  _("unsupported column type")
#define RODBI_ERR_INTERNAL         _("ROracle internal error [%s, %d, %d]")
#ifdef WIN32
#define RODBI_ERR_BIND_VAL_TOOBIG  _("bind value is too big(%lld), exceeds 2GB")
#else
#define RODBI_ERR_BIND_VAL_TOOBIG  _("bind value is too big(%ld), exceeds 2GB")
#endif
#define RODBI_ERR_UNSUPP_BIND_ENC  _("bind data can only be in native or utf-8 encoding")
#define RODBI_ERR_UNSUPP_SQL_ENC   _("sql text can only be in native or utf-8 encoding")
#define RODBI_ERR_PREF_STMT_CACHE  _("prefetch should be enabled for statement cache")
#define RODBI_ERR_UNSUPP_TYPE      _("only object and named collection types are supported")
#define RODBI_ERR_BIND_TYPE        _("type of bind variable must be specified in ""ora.type"" for a vector column")
#define RODBI_ERR_BIND_FORMAT      _("format of bind variable specifed(%s) in ""ora.format"" for a vector column is invalid")
#define RODBI_ERR_BINARY_FORMAT    _("binary format of bind variable in ""ora.format"" can only be specified with RAW data typ")

#define RODBI_ERR_VECTOR_USAGE                                               \
    _("Vector data type cannot be used with ROracle package that was built " \
      "with higher version(%d.%d) of Oracle client. Oracle Client version "  \
      "installed is %d.%d, please use Oracle Client 23.4 or higher else "    \
      "rebuild ROracle with %d.%d version of client.")

#define RODBI_ERR_VECTOR_UNSUPPORTED                                              \
    _("Vector data type cannot be used with ROracle package that was built with " \
      "Oracle Client version %d.%d. Please use Oracle Client 23.4 or higher and " \
      "rebuild ROracle with it. Oracle Client version installed is %d.%d\n")

#define RODBI_ERR_DATATYPE_UNSUPPORTED                                           \
    _("Data type %d is supported in installed version of Oracle Client %d.%d "   \
      "but ROracle package that was built with Oracle Client version %d.%d does not. "\
      "Please use Oracle Client version %d.%d that was "                         \
      "used to build ROracle or rebuild ROracle with installed version %d.%d.")

#define RODBI_DRV_ERR_CHECKWD     -1                      /* Invalid object */
#define RODBI_BULK_READ         1000               /* rodbi BULK READ count */ 
#define RODBI_BULK_WRITE        1000              /* rodbi BULK WRITE count */


/* RODBI FATAL error */
#define RODBI_FATAL(fun, pos, info) \
do \
{ \
  Rf_error(RODBI_ERR_INTERNAL, (fun), (pos), (info)); \
} while (0)

/* RODBI ERROR */
#define RODBI_ERROR(_err) \
        error((const char *)"%s", (char *)(_err))

/* RODBI WARNING */
#define RODBI_WARNING(_war) \
        warning((const char *)"%s", (char *)(_war))

#ifdef DEBUG_ro
# define RODBI_TRACE(_txt)  Rprintf("ROracle: %s\n", (_txt))
#else
# define RODBI_TRACE(_txt)
#endif

#define RODBI_DRV_ASSERT(drv_, fun_, pos_)              \
do                                                      \
{                                                       \
  if(!(drv_))                                           \
    RODBI_ERROR(RODBI_ERR_INVALID_DRV);                 \
  else if((drv_)->magicWord_rodbiDrv != RODBI_CHECKWD)  \
    RODBI_FATAL((fun_), (pos_), RODBI_DRV_ERR_CHECKWD); \
}                                                       \
while (0)

#define RODBI_CON_ASSERT(con_, fun_, pos_)              \
do                                                      \
{                                                       \
  if(!(con_))                                           \
    RODBI_ERROR(RODBI_ERR_INVALID_CON);                 \
  else if((con_)->magicWord_rodbiCon != RODBI_CHECKWD)  \
    RODBI_FATAL((fun_), (pos_), RODBI_DRV_ERR_CHECKWD); \
}                                                       \
while (0)

#define RODBI_RES_ASSERT(res_, fun_, pos_)              \
do                                                      \
{                                                       \
  if(!(res_))                                           \
    RODBI_ERROR(RODBI_ERR_INVALID_RES);                 \
  else if((res_)->magicWord_rodbiRes != RODBI_CHECKWD)  \
    RODBI_FATAL((fun_), (pos_), RODBI_DRV_ERR_CHECKWD); \
}                                                       \
while (0)

#define RODBI_CHECK_VERSION(_pctx)                      \
  (((_pctx)->compiled_maj_roociCtx >= 23) &&             \
   ((_pctx)->ver_roociCtx.maj_roociloadVersion < 23))

#define RODBI_WARN_VERSION_MISMATCH(_pctx)                  \
do                                                          \
{                                                           \
  Rf_error(RODBI_ERR_VECTOR_USAGE,                         \
            (_pctx)->compiled_maj_roociCtx,                 \
            (_pctx)->compiled_min_roociCtx,                 \
            (_pctx)->ver_roociCtx.maj_roociloadVersion,     \
            (_pctx)->ver_roociCtx.minor_roociloadVersion,   \
            (_pctx)->ver_roociCtx.maj_roociloadVersion,     \
            (_pctx)->ver_roociCtx.minor_roociloadVersion);  \
} while (0)

#define RODBI_WARN_VECTOR_UNSUPPORTED(_pctx)                       \
do                                                                 \
{                                                                  \
  Rf_error(RODBI_ERR_VECTOR_UNSUPPORTED,                          \
            (_pctx)->compiled_maj_roociCtx,                        \
            (_pctx)->compiled_min_roociCtx,                        \
            (_pctx)->ver_roociCtx.maj_roociloadVersion,            \
            (_pctx)->ver_roociCtx.minor_roociloadVersion);         \
} while (0)

#define RODBI_FATAL_DATATYPE_UNSUPPORTED(_pctx, ctype)             \
do                                                                 \
{                                                                  \
  Rf_error(RODBI_ERR_DATATYPE_UNSUPPORTED,                        \
            (ctype), (_pctx)->ver_roociCtx.maj_roociloadVersion,   \
            (_pctx)->ver_roociCtx.minor_roociloadVersion,          \
            (_pctx)->compiled_maj_roociCtx,                        \
            (_pctx)->compiled_min_roociCtx,                        \
            (_pctx)->compiled_maj_roociCtx,                        \
            (_pctx)->compiled_min_roociCtx,                        \
            (_pctx)->ver_roociCtx.maj_roociloadVersion,            \
            (_pctx)->ver_roociCtx.minor_roociloadVersion);         \
} while (0)

#define RODBI_SET_STRING_BIND(_res, _vec, _data, _err_buf, _free_res)       \
do                                                                          \
{                                                                           \
  int    len = LENGTH(VECTOR_ELT((_data), 0));                              \
  int    i;                                                                 \
  sb8    bndsz = 0;                                                         \
                                                                            \
  /* find the max len of the bind data */                                   \
  for (i=0; i<len; i++)                                                     \
  {                                                                         \
    sb8 ellen = (sb8)strlen(CHAR(STRING_ELT(VECTOR_ELT(_vec, i), i)));                   \
    bndsz = (bndsz < ellen) ? ellen : bndsz;                                \
  }                                                                         \
                                                                            \
  if (bndsz > SB4MAXVAL)                                                    \
  {                                                                         \
    RODBI_ERROR_RES((_free_res));                                           \
    Rf_error(RODBI_ERR_BIND_VAL_TOOBIG, bndsz);                            \
  }                                                                         \
                                                                            \
  /* Limitation of OCIBindByPos API, where alen is ub2 for array binds */   \
  /* For strings larger than UB2MAXVAL - NULL terminator, use SQLT_LVC */   \
  if (bndsz > (UB2MAXVAL -                                                  \
               (_res)->con_rodbiRes->con_rodbiCon.nlsmaxwidth_roociCon))    \
  {                                                                         \
    (_res)->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_LVC;  \
    bndsz += sizeof(sb4);                                                   \
  }                                                                         \
  else                                                                      \
  {                                                                         \
    bndsz += res->con_rodbiRes->con_rodbiCon.nlsmaxwidth_roociCon;          \
    (_res)->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_STR;  \
  }                                                                         \
                                                                            \
  /* align buffer to even boundary */                                       \
  bndsz += (sizeof(char *) - (bndsz % sizeof(char *)));                     \
  (_res)->res_rodbiRes.bsiz_roociRes[bid] = (sb4)bndsz;                     \
} while (0)

#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
#define RODBI_SET_VECTOR_FORMAT(_res_vfmt, _vfmt)                           \
do                                                                          \
{                                                                           \
  if ((_res_vfmt) == OCI_ATTR_VECTOR_FORMAT_FLEX)                           \
    snprintf((_vfmt), sizeof(_vfmt), "*");                                  \
  else if ((_res_vfmt) == OCI_ATTR_VECTOR_FORMAT_FLOAT16)                   \
    snprintf((_vfmt), sizeof(_vfmt), "float16");                            \
  else if ((_res_vfmt) == OCI_ATTR_VECTOR_FORMAT_FLOAT32)                   \
    snprintf((_vfmt), sizeof(_vfmt), "float32");                            \
  else if ((_res_vfmt) == OCI_ATTR_VECTOR_FORMAT_FLOAT64)                   \
    snprintf((_vfmt), sizeof(_vfmt), "float64");                            \
  else if ((_res_vfmt) == OCI_ATTR_VECTOR_FORMAT_INT8)                      \
    snprintf((_vfmt), sizeof(_vfmt), "int8");                               \
  else if ((_res_vfmt) == OCI_ATTR_VECTOR_FORMAT_BINARY)                    \
    snprintf((_vfmt), sizeof(_vfmt), "binary");                             \
  else                                                                      \
    Rf_error(RODBI_ERR_UNKNOWN_VFMT, (_res_vfmt));                          \
} while (0)
#endif


/*----------------------------------------------------------------------------
                          PRIVATE TYPES AND CONSTANTS
 ---------------------------------------------------------------------------*/

/* forward declarations */
struct rodbiCon;
struct rodbiRes;
typedef struct rodbichdl rodbichdl;

/* parameter modes for PL/SQL */
enum mode
{
  IN_mode,
  INOUT_mode,
  OUT_mode,
};
typedef enum mode mode;

/* RODBI fetch STATEs */
enum rodbiState
{
  FETCH_rodbiState,                                 /* pre-FETCH query data */
  SPLIT_rodbiState,                               /* SPLIT pre-fetch buffer */
  ACCUM_rodbiState,        /* ACCUMulate pre-fetched data into a data frame */
  OUTPUT_rodbiState,                                 /* OUTPUT a data frame */
  REFETCH_rodbiState,  /* For multiple cursor case to set FETCH state again */ 
  CLOSE_rodbiState                                    /* CLOSE the satement */
};
typedef enum rodbiState rodbiState;

/* RODBI DRiVer */
struct rodbiDrv
{
  ub4        magicWord_rodbiDrv;  /* Magic word to check structure validity */
  roociCtx   ctx_rodbiDrv;                                   /* OCI context */
  boolean    interrupt_rodbiDrv;   /* Use ^C handler for long running query */
  boolean    extproc_rodbiDrv;                       /* extproc driver flag */
  boolean    unicode_as_utf8;         /* fetch nchar/nvarchar/nclob in utf8 */
  boolean    ora_attributes; /* carry ora.* attributes in result data frame */
};
typedef struct rodbiDrv rodbiDrv;

/* RODBI CONnection */
struct rodbiCon
{
  ub4        magicWord_rodbiCon;     /* Magic word to check struct validity */
  rodbiDrv  *drv_rodbiCon;                                  /* rodbi DRiVer */
  roociCon   con_rodbiCon;                                /* OCI connection */
  boolean    err_checked_rodbiCon;    /* error already return to exception? */
  boolean    ociprefetch_rodbiCon;             /* use OCI's prefetch buffer */
  int        nrows_rodbiCon;      /* No. of rows to allocate in prefetch or */
                                                   /* array fetch operation */
  int        nrows_write_rodbiCon;  /* Number of elements to bind at a time */
};
typedef struct rodbiCon rodbiCon;

/* RODBI RESult */
struct rodbiRes
{
  ub4        magicWord_rodbiRes;  /* Magic word to check structure validity */
  rodbiCon  *con_rodbiRes;                              /* rodbi CONnection */
  roociRes   res_rodbiRes;                                /* OCI Result set */
  ub2        styp_rodbiRes;                               /* Statement TYPe */
  boolean    cnvtxt_rodbiRes;    /* sql text utf-8 needs conversion to env? */
  /* ------------------------------- FETCH -------------------------------- */
  boolean    ociprefetch_rodbiRes;             /* use OCI's prefetch buffer */
  int        nrows_rodbiRes;      /* No. of rows to allocate in prefetch or */
                                                   /* array fetch operation */
  int        nrows_write_rodbiRes;  /* Number of elements to bind at a time */
  int        rows_rodbiRes;           /* current number of ROWS in the list */
  int        nrow_rodbiRes;         /* allocated Number of ROWs in the list */
  int        fchNum_rodbiRes;                 /* NUMber of pre-FetCHed rows */
  int        fchBeg_rodbiRes;          /* pre-FetCH buffer BEGinning offset */
  int        fchEnd_rodbiRes;             /* pre-FetCH buffer ENDing offset */
  boolean    done_rodbiRes;                                /* DONE fetching */
  boolean    expand_rodbiRes;                /* adaptively EXPAND data list */
  int        affrows_rodbiRes;           /* No of rows affected; [13843811] */
  rodbichdl *pghdl_rodbiRes;    /* PaGe data HaNDles for accessing col data */
  SEXP       name_rodbiRes;                          /* column NAMEs vector */
  SEXP       list_rodbiRes;                                    /* data LIST */
  rodbiState state_rodbiRes;                      /* query processing STATE */
  int        numOut;                  /* Number of OUT or IN OUT parameters */
                                                 /* in PLSQL statement call */
  SEXP       list;                                    /* OUT bind data list */
  SEXP       name;                                 /* OUT bind NAMEs vector */
  mode      *mode_rodbiRes;               /* paramater mode for PL/SQL bind */
};
typedef struct rodbiRes rodbiRes;


/* rodbi Internal TYPe TABle */
const rodbiITyp rodbiITypTab[] =
{
  {"",                0,           0,                 0},
  {RODBI_VARCHAR2_NM, RODBI_R_CHR, SQLT_STR,          0}, 
  {RODBI_NUMBER_NM,   RODBI_R_NUM, SQLT_FLT,          sizeof(double)},
  {RODBI_INTEGER_NM,  RODBI_R_INT, SQLT_INT,          sizeof(int)},
  {RODBI_LONG_NM,     0,           0,                 0},
  {RODBI_DATE_NM,     RODBI_R_DAT, SQLT_TIMESTAMP_LTZ,sizeof(OCIDateTime *)}, 
  {RODBI_RAW_NM,      RODBI_R_RAW, SQLT_BIN,          0}, 
  {RODBI_LONG_RAW_NM, 0,           0,                 0},
  {RODBI_ROWID_NM,    RODBI_R_CHR, SQLT_STR,          0}, 
  {RODBI_CHAR_NM,     RODBI_R_CHR, SQLT_STR,          0}, 
  {RODBI_BFLOAT_NM,   RODBI_R_NUM, SQLT_BDOUBLE,      sizeof(double)},
  {RODBI_BDOUBLE_NM,  RODBI_R_NUM, SQLT_BDOUBLE,      sizeof(double)},
  {RODBI_UDT_NM,      RODBI_R_LST, SQLT_NTY,          sizeof(void *)},
  {RODBI_REF_NM,      0,           0,                 0},
//{RODBI_REF_NM,      RODBI_R_LST, SQLT_NTY,          sizeof(void *)},
  {RODBI_CLOB_NM,     RODBI_R_CHR, SQLT_CLOB,         sizeof(OCILobLocator *)},
  {RODBI_BLOB_NM,     RODBI_R_RAW, SQLT_BLOB,         sizeof(OCILobLocator *)},
  {RODBI_BFILE_NM,    RODBI_R_RAW, SQLT_BFILE,        sizeof(OCILobLocator *)},
  {RODBI_TIME_NM,     RODBI_R_DAT, SQLT_TIMESTAMP_LTZ,sizeof(OCIDateTime *)}, 
  {RODBI_TIME_TZ_NM,  RODBI_R_DAT, SQLT_TIMESTAMP_LTZ,sizeof(OCIDateTime *)}, 
  {RODBI_INTER_YM_NM, RODBI_R_CHR, SQLT_STR,          0},
  {RODBI_INTER_DS_NM, RODBI_R_DIF, SQLT_INTERVAL_DS,  sizeof(OCIInterval *)},
  {RODBI_TIME_LTZ_NM, RODBI_R_DAT, SQLT_TIMESTAMP_LTZ,sizeof(OCIDateTime *)},
  {RODBI_NVARCHAR2_NM,RODBI_R_CHR, SQLT_STR,          0}, 
  {RODBI_NCHAR_NM,    RODBI_R_CHR, SQLT_STR,          0}, 
  {RODBI_NCLOB_NM,    RODBI_R_CHR, SQLT_CLOB,         sizeof(OCILobLocator *)},
#if (OCI_MAJOR_VERSION >= 12)
  {RODBI_BOOLEAN_NM,  RODBI_R_LOG, SQLT_BOL,          sizeof(boolean)},
#else
  {RODBI_BOOLEAN_NM,  RODBI_R_LOG, SQLT_INT,          sizeof(int)},
#endif
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
  {RODBI_VECTOR_NM,   RODBI_R_LST, SQLT_VEC,          sizeof(OCIVector *)}
#else
  {RODBI_VECTOR_NM,   RODBI_R_LST, SQLT_STR,          0}
#endif
};

/* default maximum size of a page is 65536 for fixed data types */
#define RODBI_MAX_FIXED_PAGE_SIZE (int)0x10000

/* default maximum size of a page is 65536*2 for variable data types */
#define RODBI_MAX_VAR_PAGE_SIZE (int)0x20000

#define RODBI_VCOL_NULL     (int)-1
#define RODBI_VCOL_NO_REF   (int)-2

/* Each page representation */
struct rodbiPg
{
  struct rodbiPg *next_rodbiPg;
  ub1             buf_rodbiPg[1];
};
typedef struct rodbiPg rodbiPg;

/*
** variable length column data type: char, raw, blob, clob, etc.
*/
struct rodbivcol
{
  ub1        flag_rodbivcol;                         /* flag for column data */
#define RODBI_VCOL_FLG_NOTNULL         0x00      /* column value is not NULL */
#define RODBI_VCOL_FLG_NULL            0x01          /* column value is NULL */
#define RODBI_VCOL_FLG_ELEM_IN_NEXT_PG 0x02         /* value is in next page */
#define RODBI_VCOL_FLG_ELEM_REF_ACCESS 0x04     /* access by ref is possible */
  ub4        len_rodbivcol;                        /* length of column value */
  ub1        dat_rodbivcol[1];                                /* column data */
};
typedef struct rodbivcol rodbivcol;

/* Handle to traverse the pages to access data */
struct rodbichdl
{
  int      pgsize_rodbichdl;                        /* max size of each page */
  int      totpgs_rodbichdl;                             /* total pages used */
  int      extpgs_rodbichdl;  /* number of pages in extent that are not used */
  int      actual_maxlen_rodbichdl; /* actual maximum length of var in cache */
  rodbiPg *begpg_rodbichdl;                                     /* head page */
  rodbiPg *currpg_rodbichdl;          /* current page that is being accessed */
  rodbiPg *lastpg_rodbichdl;              /* last page page in column handle */
  int      offset_rodbichdl;       /* item offset in page accessed currently */
};

/* RODBI CHECK error using DRiVer handle */
#define RODBI_CHECK_DRV(drv, fun, pos, free_drv, function_to_invoke)   \
do                                                                     \
{                                                                      \
  sword  rc;                                                           \
  text *errMsg =                                                       \
          &drv->ctx_rodbiDrv.loadCtx_roociCtx.message_roociloadCtx[0]; \
  if ((rc = (function_to_invoke)) != OCI_SUCCESS)                      \
  {                                                                    \
    rodbiCheck((drv), NULL, (fun), (pos), rc, errMsg,                  \
                ROOCI_ERR_LEN);                                        \
    if (free_drv)                                                      \
    {                                                                  \
      rodbiDrvFree(drv);                                               \
    }                                                                  \
    RODBI_ERROR(errMsg);                                               \
  }                                                                    \
}                                                                      \
while (0)

/* RODBI CHECK error using Connection handle */
#define RODBI_CHECK_CON(con, fun, pos, free_con, function_to_invoke)   \
do                                                                     \
{                                                                      \
  sword  rc;                                                           \
  text *errMsg =                                                       \
    &(con)->drv_rodbiCon->ctx_rodbiDrv.loadCtx_roociCtx.message_roociloadCtx[0]; \
  if ((rc = (function_to_invoke)) != OCI_SUCCESS)                      \
  {                                                                    \
    rodbiCheck((con)->drv_rodbiCon, con, (fun), (pos), rc, errMsg,     \
               ROOCI_ERR_LEN);                                         \
    if (free_con)                                                      \
    {                                                                  \
      roociTerminateCon(&((con)->con_rodbiCon), 1);                    \
      ROOCI_MEM_FREE((con));                                           \
    }                                                                  \
    RODBI_ERROR(errMsg);                                               \
  }                                                                    \
}                                                                      \
while (0)

#define RODBI_CHECK_RES(res, fun, pos, free_res, function_to_invoke)   \
do                                                                     \
{                                                                      \
  sword  rc;                                                           \
  text *errMsg =                                                       \
          &((res)->con_rodbiRes)->drv_rodbiCon->ctx_rodbiDrv.loadCtx_roociCtx.message_roociloadCtx[0]; \
  if ((rc = (function_to_invoke)) != OCI_SUCCESS)                      \
  {                                                                    \
    rodbiCheck((res)->con_rodbiRes->drv_rodbiCon, (res)->con_rodbiRes, \
               (fun), (pos), rc, errMsg, ROOCI_ERR_LEN);               \
    if (free_res)                                                      \
    {                                                                  \
      if (res->mode_rodbiRes)                                          \
      {                                                                \
        ROOCI_MEM_FREE(res->mode_rodbiRes);                            \
      }                                                                \
      roociResFree(&(res)->res_rodbiRes);                              \
      ROOCI_MEM_FREE((res));                                           \
    }                                                                  \
    RODBI_ERROR(errMsg);                                               \
  }                                                                    \
}                                                                      \
while (0)

#define RODBI_ERROR_RES(free_res)                                      \
do                                                                     \
{                                                                      \
  if (free_res)                                                        \
  {                                                                    \
    if (res->mode_rodbiRes)                                            \
    {                                                                  \
      ROOCI_MEM_FREE(res->mode_rodbiRes);                              \
    }                                                                  \
    roociResFree(&(res)->res_rodbiRes);                                \
    ROOCI_MEM_FREE((res));                                             \
  }                                                                    \
}                                                                      \
while (0)


/*
** Get the character encoding, we only look at first element and
** assume that the remaining ones are of same encoding.
*/
#define RODBI_GET_FORM_OF_USE(form, elem, i, free_res)                     \
do                                                                         \
{                                                                          \
  if (*(form) == 0)                                                        \
  {                                                                        \
    cetype_t    enc;                                                       \
    const char *bind_enc  = NULL;                                          \
    enc = Rf_getCharCE(STRING_ELT((elem), (i)));                           \
    if (enc == CE_NATIVE)                                                  \
      *(form) = SQLCS_IMPLICIT;                                            \
    else if (enc == CE_LATIN1)                                             \
      *(form) = SQLCS_IMPLICIT;                                            \
    else if (enc == CE_UTF8)                                               \
      *(form) = SQLCS_NCHAR;                                               \
    else                                                                   \
    {                                                                      \
      RODBI_ERROR_RES((free_res));                                         \
      Rf_error(RODBI_ERR_UNSUPP_BIND_ENC);                                 \
    }                                                                      \
                                                                           \
    /* "ora.encoding" for deciding bind_length for OUT string/raw */       \
    if (Rf_getAttrib((elem), Rf_mkString((const char *)"ora.encoding"))    \
                                                         != R_NilValue)    \
      bind_enc = CHAR(STRING_ELT(Rf_getAttrib((elem),                      \
                      Rf_mkString((const char *)"ora.encoding")), 0));     \
    else                                                                   \
    if (Rf_getAttrib(data, Rf_mkString((const char *)"ora.encoding"))      \
                                                         != R_NilValue)    \
      bind_enc = CHAR(STRING_ELT(Rf_getAttrib(data,                        \
                      Rf_mkString((const char *)"ora.encoding")), 0));     \
                                                                           \
    if (bind_enc && !strcmp(bind_enc, "UTF-8"))                            \
      *(form) = SQLCS_NCHAR;                                               \
  }                                                                        \
} while (0)

/*
** Get the format of vector using "ora.format" if the user has specified
** for DML operations along with "ora.type" set to "vector"
*/
#define RODBI_GET_VECTOR_FORMAT(vec, data, vfrmt, free_res)                \
do                                                                         \
{                                                                          \
  const char *vecfmt = (const char *)0;                                    \
        SEXP  attrb = (SEXP)0;                                             \
  /* check if ora.format is specified */                                   \
  attrb = Rf_getAttrib((vec), Rf_mkString((const char *)"ora.format"));    \
  if (attrb != R_NilValue)                                                 \
    vecfmt = CHAR(STRING_ELT(attrb , 0));                                  \
                                                                           \
  if (!vecfmt)                                                             \
    attrb = Rf_getAttrib((data), Rf_mkString((const char *)"ora.format")); \
                                                                           \
  if (attrb != R_NilValue)                                                 \
    vecfmt = CHAR(STRING_ELT(attrb, 0));                                   \
                                                                           \
  if (vecfmt)                                                              \
  {                                                                        \
    int len = strlen(vecfmt);                                              \
    if ((len == 1) && !strcmp(vecfmt, "*"))                                \
      (*vfrmt) = OCI_ATTR_VECTOR_FORMAT_FLEX;                              \
    else if ((len == 7) && !strcmp(vecfmt, "float16"))                     \
      (*vfrmt) = OCI_ATTR_VECTOR_FORMAT_FLOAT16;                           \
    else if ((len == 7) && !strcmp(vecfmt,  "float32"))                    \
      (*vfrmt) = OCI_ATTR_VECTOR_FORMAT_FLOAT32;                           \
    else if ((len == 7) && !strcmp(vecfmt,  "float64"))                    \
      (*vfrmt) = OCI_ATTR_VECTOR_FORMAT_FLOAT64;                           \
    else if ((len == 4) && !strcmp(vecfmt,  "int8"))                       \
      (*vfrmt) = OCI_ATTR_VECTOR_FORMAT_INT8;                              \
    else if ((len == 6) && !strcmp(vecfmt,  "binary"))                     \
      (*vfrmt) = OCI_ATTR_VECTOR_FORMAT_BINARY;                            \
    else                                                                   \
    {                                                                      \
      RODBI_ERROR_RES((free_res));                                         \
      Rf_error(RODBI_ERR_BIND_FORMAT, vecfmt);                             \
    }                                                                      \
  }                                                                        \
  else                                                                     \
    (*vfrmt) = OCI_ATTR_VECTOR_FORMAT_FLOAT64;                             \
} while (0)

/* RODBI R TYPe TABle */
const rodbiRTyp rodbiRTypTab[] =
{
  {"",             NILSXP},
  {RODBI_R_LOG_NM, LGLSXP},
  {RODBI_R_INT_NM, INTSXP},
  {RODBI_R_NUM_NM, REALSXP},
  {RODBI_R_CHR_NM, STRSXP},
  {RODBI_R_LST_NM, VECSXP},
  {RODBI_R_DAT_NM, REALSXP},
  {RODBI_R_DIF_NM, REALSXP},
  {RODBI_R_RAW_NM, VECSXP}
};

/* Structure representing SQLT_LVC and SQLT_LVB data */
struct rodbild                                            /* RODBI Large Data */
{   
  sb4  len_rodbild;                                         /* Length of data */
  ub1  dat_rodbild[1];                                    /* Data starts here */
};
typedef struct rodbild rodbild;
    
/*
** Name:      RODBI_CREATE_COL_HDL - ROracle DBI CREATE COLumn HanDLe
**
** Function:  This function initializes the column handle to write data into
**            paged memory.
**
** Input:     hdl(IN)     - address of rodbichdl
**            pgsize(IN)  - max size of each page
**            blob(IN)    - TRUE if it a BLOB, CLOB or BFILE
**
** Exception: Fatal error when memory cannot be allocated.
**
** Returns:   Initialized collection handle on success.
**
*/
#define RODBI_CREATE_COL_HDL(hdl, pgsize)                                     \
do                                                                            \
{                                                                             \
  ROOCI_MEM_ALLOC((hdl)->begpg_rodbichdl,                                     \
                  ((pgsize) + sizeof(rodbiPg *)), sizeof(ub1));               \
  if (!(hdl)->begpg_rodbichdl)                                                \
    RODBI_ERROR(RODBI_ERR_MEMORY_ALC);                                        \
  (hdl)->pgsize_rodbichdl = (pgsize);                                         \
  (hdl)->lastpg_rodbichdl = (hdl)->begpg_rodbichdl;                           \
  RODBI_EXTEND_PAGES((hdl), (hdl)->begpg_rodbichdl, 1);                       \
  (hdl)->currpg_rodbichdl = (hdl)->begpg_rodbichdl;                           \
  (hdl)->totpgs_rodbichdl = 0;                                                \
  (hdl)->extpgs_rodbichdl = 1;                                                \
  (hdl)->actual_maxlen_rodbichdl = 0;                                         \
  (hdl)->offset_rodbichdl = 0;                                                \
}                                                                             \
while (0)


/*
** Name:      RODBI_REPOSITION_COL_HDL - ROracle DBI RE-POSITION COLumn HanDLe
**
** Function:  This function repositions the column handle to the beginning of
**            paged memory to be used to read the data.
**
** Input:     hdl(IN)     - address of rodbichdl
**
** Exception: None
**
** Returns:   Initialized collection handle.
**
*/
#define RODBI_REPOSITION_COL_HDL(hdl)               \
do                                                  \
{                                                   \
  (hdl)->currpg_rodbichdl = (hdl)->begpg_rodbichdl; \
  (hdl)->offset_rodbichdl = 0;                      \
} while (0)


/*
** Name:      RODBI_DESTROY_COL_HDL - ROracle DBI DESTROY COLumn HanDLe
**
** Function:  This function closes the column handle after freeing all pages
**            allocated.
**
** Input:     hdl(IN)     - address of rodbichdl
**
** Exception: None
**
** Returns:   None.
**
*/
#define RODBI_DESTROY_COL_HDL(hdl)             \
do                                             \
{                                              \
  rodbiPg *tmppg;                              \
  if (hdl)                                     \
  {                                            \
    tmppg = (hdl)->begpg_rodbichdl;            \
    if ((hdl)->begpg_rodbichdl)                \
    {                                          \
      while (tmppg)                            \
      {                                        \
        rodbiPg *tmppg2 = tmppg->next_rodbiPg; \
        ROOCI_MEM_FREE(tmppg);                 \
        tmppg = tmppg2;                        \
      }                                        \
    }                                          \
                                               \
    (hdl)->begpg_rodbichdl = NULL;             \
  }                                            \
} while(0)


/*
** Name:      RODBI_EXTEND_PAGES - ROracle DBI EXTEND PAGE table
**
** Function:  This function allocates number of pages at the end of the list
**            navigating from current page.
**
** Input:     hdl(IN)     - address of rodbichdl
**            curr_page(IN) - current page that hdl is operating with
**            npages(IN) - number of pages to extend bye
**
** Exception: Fatal error when memory cannot be allocated.
**
** Returns:   None.
**
*/
#define RODBI_EXTEND_PAGES(hdl, curr_page, npages)                         \
do                                                                         \
{                                                                          \
  rodbiPg *tmppg = (curr_page);                                            \
  int      npg = (npages);                                                 \
                                                                           \
  tmppg = (hdl)->lastpg_rodbichdl;                                         \
                                                                           \
  while(npg--)                                                             \
  {                                                                        \
    ROOCI_MEM_MALLOC(tmppg->next_rodbiPg,                                  \
                     ((hdl)->pgsize_rodbichdl + sizeof(rodbiPg *)),        \
                     sizeof(ub1));                                         \
    if (!tmppg->next_rodbiPg)                                              \
      RODBI_ERROR(RODBI_ERR_MEMORY_ALC);                                   \
    else                                                                   \
      tmppg = tmppg->next_rodbiPg;                                         \
    ((hdl)->extpgs_rodbichdl++);                                           \
  }                                                                        \
  (hdl)->lastpg_rodbichdl = tmppg;                                         \
  tmppg->next_rodbiPg = (rodbiPg *)0;                                      \
} while (0)



/*
** Name:      RODBI_ADD_FIXED_DATA_ITEM - ROracle DBI ADD a FIXED len DATA ITEM
**                                        to page table
**
** Function:  This function adds an integer or double data item to paged memory
**            at the current offset and incrementing it to add next item.
**            Before adding an item it expands the page table when the item
**            does not fit in the page adjusting the current offset.
**
** Input:     hdl(IN)     - address of rodbichdl
**            T(IN)       - type of data
**            data(IN)    - integer value to be copied into the page
**
** Exception: Fatal error when memory cannot be allocated.
**
** Returns:   None.
**
*/
#define RODBI_ADD_FIXED_DATA_ITEM(hdl, T, data)                               \
do                                                                            \
{                                                                             \
  T *pdata;                                                                   \
  if ((hdl)->offset_rodbichdl + (int)sizeof(T) > (hdl)->pgsize_rodbichdl)     \
  {                                                                           \
    if ((hdl)->currpg_rodbichdl->next_rodbiPg)                                \
      (hdl)->currpg_rodbichdl = (hdl)->currpg_rodbichdl->next_rodbiPg;        \
    else                                                                      \
    {                                                                         \
      RODBI_EXTEND_PAGES((hdl), (hdl)->currpg_rodbichdl, 1);                  \
      (hdl)->currpg_rodbichdl = (hdl)->currpg_rodbichdl->next_rodbiPg;        \
    }                                                                         \
    (hdl)->totpgs_rodbichdl++;                                                \
    (hdl)->extpgs_rodbichdl--;                                                \
    (hdl)->offset_rodbichdl = 0;                                              \
  }                                                                           \
  pdata = (T *)(&(hdl)->currpg_rodbichdl->buf_rodbiPg[(hdl)->offset_rodbichdl]);\
  *pdata = (data);                                                           \
  (hdl)->offset_rodbichdl += sizeof(T);                                       \
} while (0)



/*
** Name:     RODBI_GET_FIXED_DATA_ITEM - ROracle DBI GET an FIXED len DATA ITEM
**                                       from page table at current offset
**
** Function:  This function copies an integer data from paged memory at the
**            current offset into address pointed by data. Current offset is
**            incremented to get the next item.
**
** Input:     hdl(IN)   - address of rodbichdl
**            T(IN)     - type of data item
**            data(IN)  - pointer to integer where data will be copied to
**            res(IN)   - result set
**
** Exception: Fatal error when accessing beyond page limit.
**
** Returns:   None.
**
*/
#define RODBI_GET_FIXED_DATA_ITEM(hdl, T, data, res)                          \
do                                                                            \
{                                                                             \
  T *pdata;                                                                   \
  if ((hdl)->offset_rodbichdl + (int)sizeof(T) > (hdl)->pgsize_rodbichdl)     \
  {                                                                           \
    if ((hdl)->currpg_rodbichdl->next_rodbiPg)                                \
      (hdl)->currpg_rodbichdl = (hdl)->currpg_rodbichdl->next_rodbiPg;        \
    else                                                                      \
      RODBI_FATAL(__func__, 1, (res)->state_rodbiRes);                    \
    (hdl)->offset_rodbichdl = 0;                                              \
  }                                                                           \
  pdata = (T *)&((hdl)->currpg_rodbichdl->buf_rodbiPg[(hdl)->offset_rodbichdl]); \
  *((T *)data) = *pdata;                                                      \
  (hdl)->offset_rodbichdl += sizeof(T);                                       \
} while(0)


/*
** Name:     RODBI_GET_MAX_VAR_ITEM_LEN - ROracle DBI GET MAXimum VARiable data
**                                        ITEM LENgth that is store in paged
**                                        table
**
** Function:  This function returns the maximum length of an item that is
**            currently stored in the entire paged table.
**
** Input:     hdl(IN)     - address of rodbichdl
**            maxlen(IN)  - maximum length of an element stored currently
**
** Exception: None.
**
** Returns:   None.
**
*/
#define RODBI_GET_MAX_VAR_ITEM_LEN(hdl, maxlen) \
  (*maxlen) = (hdl)->actual_maxlen_rodbichdl



/*
** Name:      RODBI_GET_VAR_DATA_ITEM_BY_REF - ROracle DBI GET a VARiable DATA
**                                             ITEM from page table BY REFrence
**
** Function:  This function returns the pointer to data item from paged memory
**            at the current offset. Current offset incremented to get the next
**            item. This access applies to VARCHAR, RAW and CHAR data only used
**            avoid an extra memcpy.
**            For LOB's use RODBI_GET_VAR_DATA_ITEM_BY.
**
** Input:     hdl(IN)      - address of rodbichdl
**            data(IN)     - pointer to buffer where data will be copied to
**            len(IN)      - length of data in paged memory
**                           -1 - indicates NULL
**            res(IN)      - result set
**
** Exception: Fatal error when accessing beyond memory
**
** Returns:   None.
**
*/
#define RODBI_GET_VAR_DATA_ITEM_BY_REF(hdl, data, len, res)                   \
do                                                                            \
{                                                                             \
  rodbivcol *col;                                                             \
                                                                              \
  if (((hdl)->offset_rodbichdl + (int)sizeof(rodbivcol)) > (hdl)->pgsize_rodbichdl)\
  {                                                                           \
    if ((hdl)->currpg_rodbichdl->next_rodbiPg)                                \
      (hdl)->currpg_rodbichdl = (hdl)->currpg_rodbichdl->next_rodbiPg;        \
    else                                                                      \
      RODBI_FATAL(__func__, 1, (res)->state_rodbiRes);                    \
    (hdl)->offset_rodbichdl = 0;                                              \
  }                                                                           \
                                                                              \
  col=(rodbivcol *)                                                           \
             &((hdl)->currpg_rodbichdl->buf_rodbiPg[(hdl)->offset_rodbichdl]);\
  if (col->flag_rodbivcol & RODBI_VCOL_FLG_ELEM_REF_ACCESS)                   \
  {                                                                           \
    if (col->flag_rodbivcol & RODBI_VCOL_FLG_ELEM_IN_NEXT_PG)                 \
    {                                                                         \
      (hdl)->offset_rodbichdl = 0;                                            \
      (hdl)->currpg_rodbichdl = (hdl)->currpg_rodbichdl->next_rodbiPg;        \
      *data = (void *)&((hdl)->currpg_rodbichdl->buf_rodbiPg[0]);             \
    }                                                                         \
    else                                                                      \
    {                                                                         \
      (hdl)->offset_rodbichdl += offsetof(struct rodbivcol, dat_rodbivcol);   \
      *data = (void *)(&col->dat_rodbivcol[0]);                               \
    }                                                                         \
                                                                              \
    if (col->flag_rodbivcol & RODBI_VCOL_FLG_NULL)                            \
      (*len) = RODBI_VCOL_NULL;                                               \
    else                                                                      \
    {                                                                         \
      (*len) = col->len_rodbivcol;                                            \
      (hdl)->offset_rodbichdl += (*len);                                      \
    }                                                                         \
                                                                              \
    /* align offset to 4 or 8 byte boundary to access next item */            \
    (hdl)->offset_rodbichdl += (sizeof(char *) -                              \
                                 (hdl->offset_rodbichdl % sizeof(char *)));   \
  }                                                                           \
  else                                                                        \
    (*len) = RODBI_VCOL_NO_REF;                                               \
} while(0)


static SEXP rodbiUDTInfoFields(SEXP list, roociObjType *objtyp,
                               roociColType *attrtyp, int *curritm, int nrows);

/* --------------------- rodbichkIntFn ------------------------------------ */
/* Check for cntl-C interrupt */
void rodbichkIntFn(void *dummy)
{
  R_CheckUserInterrupt();
}

/*----------------------------------------------------------------------------
                               EXPORT FUNCTIONS
 ---------------------------------------------------------------------------*/

/* --------------------------- rodbiGetDrv -------------------------------- */
/* get driver pointer */
static rodbiDrv *rodbiGetDrv(SEXP ptrDrv);

/* --------------------------- rodbiDrvInfoConnections -------------------- */
/* get connection information */
static SEXP rodbiDrvInfoConnections(rodbiDrv *drv);

/* -------------------------- rodbiDrvFree -------------------------------- */
/* clear driver context */
static void rodbiDrvFree(rodbiDrv *drv);

/* ------------------------- rodbiGetCon ---------------------------------- */
/* get connection id */
static rodbiCon *rodbiGetCon(SEXP hdlCon);

/* ------------------------- rodbiConInfoResults -------------------------- */
/* get result set information related to connection */
static SEXP rodbiConInfoResults(SEXP con);

/* ----------------------------- rodbiConTerm ----------------------------- */
static void rodbiConTerm(rodbiCon *con);

/* -------------------------- rodbiGetRes --------------------------------- */
/* get result set ID */
static rodbiRes *rodbiGetRes(SEXP hdlRes);

/* ------------------------- rodbiResExecStmt ----------------------------- */
/* execute statement other than SELECT statement */
static void rodbiResExecStmt(rodbiRes *res, SEXP data, boolean free_res);

/* ------------------------- rodbiResExecQuery ---------------------------- */
/* execute SELECT statement */
static void rodbiResExecQuery(rodbiRes *res, SEXP data, boolean free_res);

/* -------------- rodbiIsVectorBind -------------- */
static boolean rodbiIsVectorBind(SEXP data, SEXP vec, SEXP elem,
                                 roociColType *btyp, int *vectyp);

/* ------------------------- rodbiResExecBind ----------------------------- */
/* bind input data and execute query */
static void rodbiResExecBind(rodbiRes *res, SEXP data, boolean free_res);

/* ------------------------- rodbiResBind --------------------------------- */
/* bind input data */
static void rodbiResBind(rodbiRes *res, SEXP data, int bulk_write,
                         boolean free_res);

/* ----------------------- rodbiPlsqlResBind ------------------------------ */
/* bind PL/SQL input data */
static void rodbiPlsqlResBind(rodbiRes *res, SEXP data, int bulk_write,
                              boolean free_res);

/* ------------------------ rodbiResBindCopy ------------------------------ */
/* bind data */
static void rodbiResBindCopy(rodbiRes *res, SEXP data, int beg, int end,
                             boolean free_res);

/* ----------------------- rodbiResAlloc ---------------------------------- */
/* get information of output result set */
static void rodbiResAlloc(rodbiRes *res, int nrow);

/* ----------------------- rodbiResExpand --------------------------------- */
/* expand result set  */
static void rodbiResExpand(rodbiRes *res);

/* ----------------------- rodbiResSplit ---------------------------------- */
/* split result set */
static void rodbiResSplit(rodbiRes *res);

/* ---------------------- rodbiResAccum ----------------------------------- */
/* accumulate result set */
static void rodbiResAccum(rodbiRes *res);

/* ---------------------- rodbiResAccumInCache ---------------------------- */
/* accumulate result set in ROracle cache */
static void rodbiResAccumInCache(rodbiRes *res);

/* ---------------------- rodbiResTrim ------------------------------------ */
/* trim result set column vector  */
static void rodbiResTrim(rodbiRes *res);

/* ----------------------- rodbiResPopulate ------------------------------- */
/* pupulate the result in dataframe from cache */
static void rodbiResPopulate(rodbiRes *res);

/* ---------------------- rodbiResDataFrame ------------------------------- */
/* make input data list a data frame  */
static void rodbiResDataFrame(rodbiRes *res);

/* -------------------------- rodbiPlsqlResPopulate ----------------------- */
/* populate the plsql result set */
static void rodbiPlsqlResPopulate(rodbiRes *res, ub4 *flag);

/* ---------------------- rodbiResStateNext ------------------------------- */
/* move to next state to process result set */
static void rodbiResStateNext(rodbiRes *res);

/* ---------------------- rodbiResInfoStmt -------------------------------- */
/* get statement related to result set */
static SEXP rodbiResInfoStmt(rodbiRes *res);

/* --------------------- rodbiResInfoFields ------------------------------- */
/* get result set fields information */
static SEXP rodbiResInfoFields(rodbiRes *res);

/* ------------------------------- rodbiResTerm ---------------------------- */
/* Terminate the result and free memory */
static void rodbiResTerm(rodbiRes  *res);

/* --------------------- rodbiCheck --------------------------------------- */
/* get error message and throw error */
static void rodbiCheck(rodbiDrv *drv, rodbiCon *con, const char *fun,
                       int pos, sword status, text *errMsg, size_t errMsgLen);

/*
** Name:      RODBI_ADD_VAR_DATA_ITEM - ROracle DBI ADD a VARiable length DATA
**                                      ITEM to page table
**
** Function:  This function adds a variable length data item into the paged
**            memory at the current offset. Current offset is incremented to add
**            the next item. Before adding an item it expands the page table when
**            the item does not fit in the page adjusting the current offset.
**            It tracks the maximum length of an item added in the paged table.
**
** Input:     hdl(IN)      - address of rodbichdl
**            flag(IN)     - RODBI_VCOL_FLG_NULL when NULL data or 
**                           RODBI_VCOL_FLG_NOTNULL when data is not NULL
**            data(IN)     - pointer to buffer where data will be copied from
**            len(IN)      - length of buffer data
**
** Exception: Fatal error when memory cannot be allocated.
**
** Returns:   None.
**
*/
static sword RODBI_ADD_VAR_DATA_ITEM(rodbichdl *hdl, ub1 flag,
                                     void *data, int len);

/*
** Name:      RODBI_GET_VAR_DATA_ITEM - ROracle DBI GET a VARiable DATA ITEM from
**                                      page table at current offset
**
** Function:  This function copies a variable length data item from paged memory
**            at the current offset into address pointed by data. Current offset
**            is incremented to get the next item.
**
** Input:     hdl(IN)      - address of rodbichdl
**            data(IN)     - pointer to buffer where data will be copied to
**            len(IN)      - length of buffer data
**
** Exception: None.
**
** Returns:   0 on success and ROOCI_DRV_ERR_NO_DATA if there is no data.
**
*/
static int RODBI_GET_VAR_DATA_ITEM(rodbichdl *hdl, void *data, int len);

/* ----------------------------- rociDrvAlloc ----------------------------- */
/* create external pointer of driver */
SEXP rociDrvAlloc(void);

/* ----------------------------- rociDrvInit ------------------------------ */
/* Initialize driver  context */
SEXP rociDrvInit(SEXP ptrDrv, SEXP interruptible, SEXP ptrEpx,
                 SEXP unicode_as_utf8, SEXP ora_attributes,
                 SEXP ora_objects, SEXP sparse);

/* ----------------------------- rociDrvInfo ------------------------------ */
/* get driver info */
SEXP rociDrvInfo(SEXP ptrDrv);

/* ----------------------------- rociDrvTerm ------------------------------ */
/* terminate driver */
SEXP rociDrvTerm(SEXP ptrDrv);

/* ---------------------------- rociConInit ------------------------------- */
/* initialize connection context */
SEXP rociConInit(SEXP ptrDrv, SEXP params, SEXP prefetch, SEXP nrows,
                 SEXP nrows_write, SEXP stmtCacheSize,
                 SEXP external_credentials, SEXP sysdba);

/* ---------------------------- rociConError ------------------------------ */
/* get connection error */
SEXP rociConError(SEXP hdlCon);

/* ---------------------------- rociConInfo ------------------------------- */
/* get connection info */
SEXP rociConInfo(SEXP hdlCon);

/* ---------------------------- rociConTerm ------------------------------- */
/* clear connection context */
SEXP rociConTerm(SEXP hdlCon);

/* ---------------------------- rociConCommit ----------------------------- */
/* commit connection transaction */
SEXP rociConCommit(SEXP hdlCon);

/* ---------------------------- rociConRollback ---------------------------- */
/* rollback connection transaction */
SEXP rociConRollback(SEXP hdlCon);

/* ---------------------------- rociResInit ------------------------------- */
/* initialize result set */
SEXP rociResInit(SEXP hdlCon, SEXP statement, SEXP data,
                 SEXP prefetch, SEXP nrows, SEXP nrows_write, SEXP sparse);

/* --------------------------- rociResExec -------------------------------- */
/* execute statement */
SEXP rociResExec(SEXP hdlRes, SEXP data);

/* --------------------------- rociResFetch ------------------------------- */
/* fetch result */
SEXP rociResFetch(SEXP hdlRes, SEXP numRec);

/* --------------------------- rociResInfo -------------------------------- */
SEXP rociResInfo(SEXP hdlRes);

/* --------------------------- rociEOFRes  -------------------------------- */
SEXP rociEOFRes(SEXP hdlRes);

/* --------------------------- rociResTerm -------------------------------- */
/* terminate result set */
SEXP rociResTerm(SEXP hdlRes);

/*
 this will call rochkIntFn in a top-level context so it won't longjmp-out 
 of your context
*/
boolean rodbicheckInterrupt()
{
  return (R_ToplevelExec(rodbichkIntFn, NULL) == FALSE);
}

/****************************************************************************/
/*  (*) DRIVER FUNCTIONS                                                    */
/****************************************************************************/

/* ----------------------------- rociDrvAlloc ----------------------------- */

SEXP rociDrvAlloc(void)
{
  SEXP     ptrDrv;

  /* make external pointer */
  ptrDrv = R_MakeExternalPtr(NULL, R_NilValue, R_NilValue);

  RODBI_TRACE("driver allocated");

  return ptrDrv;
} /* end rociDrvAlloc */

/* ------------------------------ rociDrvInit ----------------------------- */

SEXP rociDrvInit(SEXP ptrDrv, SEXP interruptible, SEXP ptrEpx,
                 SEXP unicode_as_utf8, SEXP ora_attributes,
                 SEXP ora_objects, SEXP sparse)
{
  rodbiDrv  *drv = R_ExternalPtrAddr(ptrDrv);
  void      *epx = isNull(ptrEpx) ? NULL : R_ExternalPtrAddr(ptrEpx);
  boolean isObject = *LOGICAL(ora_objects);

  /* check validity */
  if (drv)
  {
    if (drv->magicWord_rodbiDrv == RODBI_CHECKWD)    /* already initialized */
    {
/*
fprintf(stdout, "rodbi: Extproc driver epx=%p\n", epx);
      if (isObject)
      {
        R_ClearExternalPtr(ptrDrv);
        rodbiDrvFree(drv);
        drv->magicWord_rodbiDrv = 0;
      }
      else
*/
        return R_NilValue;
    }
    else                                     /* clean up partial allocation */
    {
      R_ClearExternalPtr(ptrDrv);
      rodbiDrvFree(drv);
    }
  }

  /* allocate rodbi driver */
  ROOCI_MEM_ALLOC(drv, 1, sizeof(rodbiDrv));
  if (!drv)
    RODBI_ERROR(RODBI_ERR_MEMORY_ALC);

  /* create OCI environment, get client version */
  RODBI_CHECK_DRV(drv, __func__, 1, TRUE,
               roociload__loadLib(&drv->ctx_rodbiDrv.ver_roociCtx,
                                  &drv->ctx_rodbiDrv.loadCtx_roociCtx));

  drv->ctx_rodbiDrv.bMatrixPkgLoaded = *LOGICAL(sparse);

  /* create OCI environment, get client version */
  RODBI_CHECK_DRV(drv, __func__, 2, TRUE,
               roociInitializeCtx(&(drv->ctx_rodbiDrv), epx,
                                  *LOGICAL(interruptible),
                                  *LOGICAL(unicode_as_utf8),
                                  (isObject)));

  /* set external pointer */
  R_SetExternalPtrAddr(ptrDrv, drv);
 
  /* set magicWord for driver */
  drv->magicWord_rodbiDrv = RODBI_CHECKWD;
  drv->interrupt_rodbiDrv = *LOGICAL(interruptible);
  drv->unicode_as_utf8    = *LOGICAL(unicode_as_utf8);
  drv->ora_attributes     = *LOGICAL(ora_attributes);
  drv->extproc_rodbiDrv   = (epx == NULL) ? FALSE : TRUE;

  RODBI_TRACE("driver created");

  return R_NilValue;
} /* end rociDrvInit */

/* ------------------------------ rociDrvInfo ----------------------------- */

SEXP rociDrvInfo(SEXP ptrDrv)
{
  rodbiDrv  *drv = rodbiGetDrv(ptrDrv);
  char      version[ROOCI_VERSION_LEN];
  SEXP      info;
  SEXP      names;

  /* allocate output list */
  PROTECT(info = allocVector(VECSXP, 9));
//PROTECT(info = allocVector(VECSXP, 10));

  /* allocate list element names */
  names = allocVector(STRSXP, 9);
//names = allocVector(STRSXP, 10);
  setAttrib(info, R_NamesSymbol, names);                  /* protects names */

  /* driverName */
  SET_VECTOR_ELT(info,  0, drv->extproc_rodbiDrv ? mkString(RODBI_DRV_EXTPROC)
                                                 : mkString(RODBI_DRV_NAME));
  SET_STRING_ELT(names, 0, mkChar("driverName"));

  /* driverVersion */
  snprintf(version, ROOCI_VERSION_LEN, "%d.%d-%d",
           RODBI_DRV_MAJOR, RODBI_DRV_MINOR, RODBI_DRV_UPDATE);
  SET_VECTOR_ELT(info,  1, mkString(version));
  SET_STRING_ELT(names, 1, mkChar("driverVersion"));

  /* clientVersion */
  snprintf(version, ROOCI_VERSION_LEN, "%d.%d.%d.%d.%d",
           drv->ctx_rodbiDrv.ver_roociCtx.maj_roociloadVersion,
           drv->ctx_rodbiDrv.ver_roociCtx.minor_roociloadVersion,
           drv->ctx_rodbiDrv.ver_roociCtx.update_roociloadVersion, 
           drv->ctx_rodbiDrv.ver_roociCtx.patch_roociloadVersion,
           drv->ctx_rodbiDrv.ver_roociCtx.port_roociloadVersion);
  SET_VECTOR_ELT(info,  2, mkString(version));
  SET_STRING_ELT(names, 2, mkChar("clientVersion"));

  /* conTotal */
  SET_VECTOR_ELT(info,  3, ScalarInteger((drv->ctx_rodbiDrv).tot_roociCtx));
  SET_STRING_ELT(names, 3, mkChar("conTotal"));

  /* conOpen */
  SET_VECTOR_ELT(info,  4, ScalarInteger((drv->ctx_rodbiDrv).num_roociCtx));
  SET_STRING_ELT(names, 4, mkChar("conOpen"));

  /* interruptible */
  SET_VECTOR_ELT(info,  5, ScalarLogical(drv->interrupt_rodbiDrv));
  SET_STRING_ELT(names, 5, mkChar("interruptible"));

  /* unicode_as_utf8 */
  SET_VECTOR_ELT(info,  6, ScalarLogical(drv->unicode_as_utf8));
  SET_STRING_ELT(names, 6, mkChar("unicode_as_utf8"));

  /* ora_attributes */
  SET_VECTOR_ELT(info,  7, ScalarLogical(drv->ora_attributes));
  SET_STRING_ELT(names, 7, mkChar("ora_attributes"));

  /* connections */
  SET_VECTOR_ELT(info,  8, rodbiDrvInfoConnections(drv));
  SET_STRING_ELT(names, 8, mkChar("connections"));

///* ROracle compiled with Oracle client */
//snprintf(version, ROOCI_VERSION_LEN, "%d",
//         drv->ctx_rodbiDrv.compiled_maj_roociCtx);
//SET_VECTOR_ELT(info,  9, mkString(version));
//SET_STRING_ELT(names, 9, mkChar("compiledVersion"));

  /* release info list */
  UNPROTECT(1);

  RODBI_TRACE("driver described");

  return info;
} /* end rociDrvInfo */

/* ------------------------------ rociDrvTerm ----------------------------- */

SEXP rociDrvTerm(SEXP ptrDrv)
{
  rodbiDrv  *drv = rodbiGetDrv(ptrDrv);
  
  /* clean up */
  R_ClearExternalPtr(ptrDrv);
  rodbiDrvFree(drv);

  RODBI_TRACE("driver removed");

  return R_NilValue;
} /* end rociDrvTerm */


/****************************************************************************/
/*  (*) CONNECTION FUNCTIONS                                                */
/****************************************************************************/


/* ----------------------------- rociConCreate ---------------------------- */

SEXP rociConInit(SEXP ptrDrv, SEXP params, SEXP prefetch, SEXP nrows,
                 SEXP nrows_write, SEXP stmtCacheSize,
                 SEXP external_credentials, SEXP sysdba)
{
  char       *user             = (char *)CHAR(STRING_ELT(params, 0));
  char       *pass             = (char *)CHAR(STRING_ELT(params, 1));
  char       *conStr           = (char *)CHAR(STRING_ELT(params, 2));
  rodbiDrv   *drv              = rodbiGetDrv(ptrDrv);
  rodbiCon   *con;
  SEXP        hdlCon;
  boolean     wallet           = (!strcmp(user, "") && !strcmp(pass, ""));
                            /* is oracle wallet being used for authentication?
                               for oracle wallet authentication, user needs to
                               pass empty strings for username and password */
  ub4         sess_mod         = OCI_DEFAULT;                          

  if (drv->extproc_rodbiDrv && drv->ctx_rodbiDrv.num_roociCtx > 0)
    con = drv->ctx_rodbiDrv.con_roociCtx[0]->parent_roociCon;
  else
  {
    /* allocate rodbi connection */
    ROOCI_MEM_ALLOC(con, 1, sizeof(rodbiCon));
    if (!con)
      RODBI_ERROR(RODBI_ERR_MEMORY_ALC);

    con->drv_rodbiCon = drv;

    if (*LOGICAL(external_credentials) || wallet)
      sess_mod = sess_mod | OCI_SESSGET_CREDEXT;

    if (*LOGICAL(sysdba)) 
    {
#if defined(OCI_SESSGET_SYSDBA)
      sess_mod = sess_mod | OCI_SESSGET_SYSDBA;
#else
#pragma message("Oracle Client library used does not support OCI_SESSGET_SYSDBA, please check NEWS for additional details if it is necessary to connect using SYSDBA privilege to the Oracle Database.")
#endif
    }

    /* If statement cache size is > 0 then it will set OCI_SESSGET_STMTCACHE
       session mode */
    if (((ub4)INTEGER(stmtCacheSize)[0]) > 0)
      sess_mod = sess_mod | OCI_SESSGET_STMTCACHE;

    /* Initialize connection environment */
    RODBI_CHECK_CON(con, __func__, 1, FALSE,
                    roociInitializeCon(&drv->ctx_rodbiDrv,
                                       &(con->con_rodbiCon),
                                       user, pass, conStr,
                                       (ub4)INTEGER(stmtCacheSize)[0],
                                       sess_mod)); 

    (con->con_rodbiCon).parent_roociCon = con;
    con->ociprefetch_rodbiCon           = (*LOGICAL(prefetch) == TRUE) ? 
                                                                  TRUE : FALSE;
    con->nrows_rodbiCon                 = INTEGER(nrows)[0];
    con->nrows_write_rodbiCon           = INTEGER(nrows_write)[0];
  }

  /* allocate connection handle */
  hdlCon = R_MakeExternalPtr((void *)con, R_NilValue, R_NilValue);

  /* set connection magic word */
  con->magicWord_rodbiCon = RODBI_CHECKWD;

  RODBI_TRACE("connection created");

  return hdlCon;
} /* end rociConInit */

/* ----------------------------- rociConError ----------------------------- */

SEXP rociConError(SEXP hdlCon)
{
  rodbiCon    *con  = rodbiGetCon(hdlCon);
  rodbiDrv    *drv  = con->drv_rodbiCon;
  SEXP         info = R_NilValue;
  SEXP         names;
  sb4          errNum;
  text        *errMsg =
          &(con)->drv_rodbiCon->ctx_rodbiDrv.loadCtx_roociCtx.message_roociloadCtx[0];

  if (con)
  {
    /* allocate output list */
    PROTECT(info = allocVector(VECSXP, 2));

    /* allocate list element names */
    names = allocVector(STRSXP, 2);
    setAttrib(info, R_NamesSymbol, names);                /* protects names */

    /* errorNum */
    errNum = 0;
    errMsg[0] = '\0';

    if (con && !con->err_checked_rodbiCon)
    {
      RODBI_CHECK_CON(con, __func__, 1, FALSE,
        roociGetError(&drv->ctx_rodbiDrv, &con->con_rodbiCon,
             __func__, &errNum, errMsg, (ub4)ROOCI_ERR_LEN));
      con->err_checked_rodbiCon = TRUE;
    }
    SET_VECTOR_ELT(info,  0, ScalarInteger((int)errNum));
    SET_STRING_ELT(names, 0, mkChar("errorNum"));

    /* errorMsg */
    SET_VECTOR_ELT(info,  1, mkString((char *)errMsg));
    SET_STRING_ELT(names, 1, mkChar("errorMsg"));

    /* release info list */
    UNPROTECT(1);

    RODBI_TRACE("connection error");
  }
  else
    RODBI_ERROR(RODBI_ERR_INVALID_CON);

  return info;
} /* end rociConError */

/* ------------------------------ rociConInfo ----------------------------- */

SEXP rociConInfo(SEXP hdlCon)
{
  rodbiCon    *con              = rodbiGetCon(hdlCon);
  SEXP        info              = R_NilValue;
  SEXP        names;
  SEXP        usr_string;
  oratext    *user;
  ub4         userLen           = 0;
  text        verServer[ROOCI_VERSION_LEN];
  ub4         stmt_cache_size   = 0;                /* statement cache size */

  if (con)
  {
    con->err_checked_rodbiCon = FALSE;

    /* allocate output list */
    PROTECT(info = allocVector(VECSXP, 11));

    /* allocate list element names */
    names = allocVector(STRSXP, 11);
    setAttrib(info, R_NamesSymbol, names);                /* protects names */

    RODBI_CHECK_CON(con, __func__, 1, FALSE,
                    roociGetConInfo(&con->con_rodbiCon, &user, &userLen,
                                    verServer, &stmt_cache_size));

    /* username */
    PROTECT(usr_string = allocVector(STRSXP, 1));
    SET_STRING_ELT(usr_string, 0, mkCharLen((const char *)user, (int)userLen));
    SET_VECTOR_ELT(info,  0, usr_string);
    UNPROTECT(1);
    SET_STRING_ELT(names, 0, mkChar("username"));

    /* dbname */
    SET_VECTOR_ELT(info,  1, mkString((con->con_rodbiCon).cstr_roociCon));
    SET_STRING_ELT(names, 1, mkChar("dbname"));

    /* serverVersion */
    SET_VECTOR_ELT(info,  2, mkString((char *)verServer));
    SET_STRING_ELT(names, 2, mkChar("serverVersion"));

    /* serverType */
    if ((con->con_rodbiCon).timesten_rociCon)
      SET_VECTOR_ELT(info, 3, mkString("TimesTen IMDB"));
    else if (con->drv_rodbiCon->extproc_rodbiDrv)
      SET_VECTOR_ELT(info, 3, mkString("Oracle Extproc"));
    else
      SET_VECTOR_ELT(info, 3, mkString("Oracle RDBMS"));

    SET_STRING_ELT(names, 3, mkChar("serverType"));

    /* resTotal */
    SET_VECTOR_ELT(info,  4, ScalarInteger((con->con_rodbiCon).tot_roociCon));
    SET_STRING_ELT(names, 4, mkChar("resTotal"));

    /* resOpen */
    SET_VECTOR_ELT(info,  5, ScalarInteger((con->con_rodbiCon).num_roociCon));
    SET_STRING_ELT(names, 5, mkChar("resOpen"));

    /* prefetch */
    SET_VECTOR_ELT(info,  6, ScalarLogical(con->ociprefetch_rodbiCon));
    SET_STRING_ELT(names, 6, mkChar("prefetch"));

    /* bulk_read */
    SET_VECTOR_ELT(info,  7, ScalarInteger(con->nrows_rodbiCon));
    SET_STRING_ELT(names, 7, mkChar("bulk_read"));

    /* bulk_write */
    SET_VECTOR_ELT(info,  8, ScalarInteger(con->nrows_write_rodbiCon));
    SET_STRING_ELT(names, 8, mkChar("bulk_write"));

    /* stmt_cache */
    SET_VECTOR_ELT(info,  9, ScalarInteger((int)stmt_cache_size));
    SET_STRING_ELT(names, 9, mkChar("stmt_cache"));
    
    /* results */
    SET_VECTOR_ELT(info,  10, rodbiConInfoResults(hdlCon));
    SET_STRING_ELT(names, 10, mkChar("results"));

    /* release info list */
    UNPROTECT(1);

    RODBI_TRACE("connection described");
  }
  else
    RODBI_ERROR(RODBI_ERR_INVALID_CON);

  return info;
} /* end rociConInfo */

/* ------------------------------ rociConTerm ----------------------------- */

SEXP rociConTerm(SEXP hdlCon)
{
  rodbiCon  *con = rodbiGetCon(hdlCon);

  if (con)
  {
    con->err_checked_rodbiCon = FALSE;

    /* clean up */
    R_ClearExternalPtr(hdlCon);

    /* free connection */
    rodbiConTerm(con);

    RODBI_TRACE("connection removed");
  }
  else
    RODBI_ERROR(RODBI_ERR_INVALID_CON);

  return R_NilValue;
} /* end rociConTerm */

/* ------------------------------ rociConCommit ---------------------------- */

SEXP rociConCommit(SEXP hdlCon)
{
  rodbiCon  *con = rodbiGetCon(hdlCon);

  if (con)
  {
    /* commit */
    sword status = roociCommitCon(&(con->con_rodbiCon));
    RODBI_CHECK_CON(con, __func__, 1, FALSE, status);

    RODBI_TRACE("transaction committed");
  }
  else
    RODBI_ERROR(RODBI_ERR_INVALID_CON);

  return R_NilValue;
} /* end rociConCommit */

/* ------------------------------ rociConRollback -------------------------- */

SEXP rociConRollback(SEXP hdlCon)
{
  rodbiCon  *con = rodbiGetCon(hdlCon);

  if (con)
  {
    /* commit */
    sword status = roociRollbackCon(&(con->con_rodbiCon));
    RODBI_CHECK_CON(con, __func__, 1, FALSE, status);

    RODBI_TRACE("transaction rolled back");
  }
  else
    RODBI_ERROR(RODBI_ERR_INVALID_CON);

  return R_NilValue;
} /* end rociConRollback */

/****************************************************************************/
/*  (*) RESULT FUNCTIONS                                                    */
/****************************************************************************/


/* ------------------------------ rociResInit ----------------------------- */

SEXP rociResInit(SEXP hdlCon, SEXP statement, SEXP data,
                 SEXP prefetch, SEXP nrows, SEXP nrows_write, SEXP sparse)
{
  rodbiCon   *con             = rodbiGetCon(hdlCon);
  rodbiRes   *res;
  SEXP        hdlRes;
  boolean     pref;
  int         rows_per_fetch;
  int         rows_per_write;
  cetype_t    enc;                                 /* encoding of statement */
  ub1         qry_encoding    = CE_NATIVE;
  ub4         stmt_cache_size = 0;
  int         bid;

  pref = ((*LOGICAL(prefetch) == TRUE) ? TRUE :
                                        (con->ociprefetch_rodbiCon ? TRUE : 
                                                                     FALSE));
  /* There is some problem with statement cache and prefetch = FALSE optons.
     Hence blocking this combination for time being. */
  RODBI_CHECK_CON(con, __func__, 1, FALSE,
                  roociGetConInfo(&con->con_rodbiCon, NULL, NULL, NULL, 
                                  &stmt_cache_size));

  if (pref == FALSE && stmt_cache_size > 0)
    RODBI_ERROR(RODBI_ERR_PREF_STMT_CACHE);

  /* allocate rodbi result */
  ROOCI_MEM_ALLOC(res, 1, sizeof(rodbiRes));
  if (!res)
    RODBI_ERROR(RODBI_ERR_MEMORY_ALC);

  res->con_rodbiRes = con;
  con->err_checked_rodbiCon = FALSE;
  res->numOut = 0;

  rows_per_fetch = (INTEGER(nrows)[0] == RODBI_BULK_READ) ?
                                   ((con->nrows_rodbiCon == RODBI_BULK_READ) ? 
                                      RODBI_BULK_READ : con->nrows_rodbiCon) :
                                                            INTEGER(nrows)[0];

  rows_per_write = (INTEGER(nrows_write)[0] == RODBI_BULK_WRITE) ?
                                   ((con->nrows_write_rodbiCon == 
                                                           RODBI_BULK_WRITE) ? 
                                      RODBI_BULK_WRITE : 
                                                  con->nrows_write_rodbiCon) :
                                                      INTEGER(nrows_write)[0];

  enc = Rf_getCharCE(STRING_ELT(statement, 0));
  if (enc == CE_NATIVE)
    qry_encoding = ROOCI_QRY_NATIVE;
  else if (enc == CE_LATIN1)
    qry_encoding = ROOCI_QRY_LATIN1;
  else if (enc == CE_UTF8)
    qry_encoding = ROOCI_QRY_UTF8;
  else
  {
    RODBI_ERROR_RES(TRUE);
    Rprintf(RODBI_ERR_UNSUPP_SQL_ENC);
  }

  enc = Rf_getCharCE(STRING_ELT(statement, 0));
  if (enc == CE_NATIVE)
    res->cnvtxt_rodbiRes = FALSE;
  else if ((enc == CE_UTF8) || (enc == CE_LATIN1))
    res->cnvtxt_rodbiRes = TRUE;
  else
  {
    RODBI_ERROR_RES(TRUE);
    Rprintf(RODBI_ERR_UNSUPP_SQL_ENC);
  }

  if (res->con_rodbiRes->con_rodbiCon.timesten_rociCon)
  {
    /* execute optimizer statements for TimesTen connections */  
    sword status = roociExecTTOpt(&(res->con_rodbiRes->con_rodbiCon));
    RODBI_CHECK_RES(res, __func__, __LINE__, TRUE, status);
  }

  /* Initialize result set */
  RODBI_CHECK_RES(res, __func__, __LINE__, TRUE,
                  roociInitializeRes(&(con->con_rodbiCon), 
                                     &(res->res_rodbiRes),
                                     (oratext *)CHAR(STRING_ELT(statement, 0)),
                                     LENGTH(STRING_ELT(statement, 0)),
                                     qry_encoding,
                                     &(res->styp_rodbiRes), pref, 
                                     rows_per_fetch, rows_per_write));

  (res->res_rodbiRes).parent_roociRes = res;
  /* vector data in data frame has elements with zeros */
  res->res_rodbiRes.sparse_vec_roociRes = (*LOGICAL(sparse) == TRUE) ? TRUE :
               res->con_rodbiRes->drv_rodbiCon->ctx_rodbiDrv.bMatrixPkgLoaded;

  /* validate data then count PLSQL OUT/IN OUT variable present */
  if (!isNull(data) && LENGTH(data) == (res->res_rodbiRes).bcnt_roociRes && 
      ((res->styp_rodbiRes == OCI_STMT_BEGIN) ||
      (res->styp_rodbiRes == OCI_STMT_DECLARE)))
  {
    for(bid =0; bid < (res->res_rodbiRes).bcnt_roociRes; bid++)
    {
      SEXP elem = VECTOR_ELT(data, bid);
      SEXP mode = Rf_getAttrib(elem, install("ora.parameter_mode"));
      SEXP mode1 = Rf_getAttrib(data,  install("ora.parameter_mode"));
      if ((!isNull(mode) && (!strcmp(CHAR(STRING_ELT(mode, 0)), "OUT") ||
          !strcmp(CHAR(STRING_ELT(mode, 0)), "IN OUT"))) ||
          (!isNull(mode1) && (!strcmp(CHAR(STRING_ELT(mode1, 0)), "OUT") ||
          !strcmp(CHAR(STRING_ELT(mode1, 0)), "IN OUT"))))
      {
        res->numOut++;
      }
    }
  }

  if  ((res->res_rodbiRes).bcnt_roociRes)
  {
    if (res->numOut)
     /* bind Pl/SQL data */
      rodbiPlsqlResBind(res, data, rows_per_write, TRUE);
    else
      rodbiResBind(res, data, rows_per_write, TRUE);
  }

  /* execute the statement */
  rodbiResExecStmt(res, data, TRUE);

  /* define data for SELECT statement case or REF cursor case */
  if (res->styp_rodbiRes == OCI_STMT_SELECT || 
      res->res_rodbiRes.stm_cur_roociRes)
  {
    /* define data */
    RODBI_CHECK_RES(res, __func__, __LINE__, TRUE,
                    roociResDefine(&res->res_rodbiRes));
  }  

  /* allocate result handle */
  hdlRes = R_MakeExternalPtr((void *)res, R_NilValue, R_NilValue);

  /* bump up the number open/total results */
  (con->con_rodbiCon).num_roociCon++;
  (con->con_rodbiCon).tot_roociCon++;
  
  /* set magic word for result set */
  res->magicWord_rodbiRes   = RODBI_CHECKWD;
  res->ociprefetch_rodbiRes = pref;
  res->nrows_rodbiRes       = rows_per_fetch;
  res->nrows_write_rodbiRes = rows_per_write;

  RODBI_TRACE("result created");

  return hdlRes;
} /* end rociResInit */

/* ------------------------------ rociResExec ----------------------------- */

SEXP rociResExec(SEXP hdlRes, SEXP data)
{
  rodbiRes  *res = rodbiGetRes(hdlRes);
  rodbiCon  *con = res->con_rodbiRes;

  con->err_checked_rodbiCon = FALSE;

  /* execute the statement */
  rodbiResExecStmt(res, data, FALSE);

  RODBI_TRACE("result executed");

  return R_NilValue;
} /* end rociResExec */

/* ----------------------------- rociResFetch ----------------------------- */

SEXP rociResFetch(SEXP hdlRes, SEXP numRec)
{
  rodbiRes    *res       = rodbiGetRes(hdlRes);
  rodbiCon    *con       = res->con_rodbiRes;
  int          nrow      = INTEGER(numRec)[0];
  boolean      hasOutput = FALSE;
  ub4          fch_rows  = 0;

  /* use this flag to communicate between successive rodbiPlsqlResPopulate() */
  ub4          flag      = 1;

  /* Create new result set for PLSQL OUT or IN OUT case */
  if (res->numOut)
    rodbiPlsqlResPopulate(res, &flag);

  con->err_checked_rodbiCon = FALSE;

  /* setup adaptive fetching */
  if (nrow <= 0)
  {
    nrow                 = res->nrows_rodbiRes;
    res->expand_rodbiRes = TRUE;
  }
  else
    /* Do not cache results as user is explicitly fetching n rows at a time */
    res->res_rodbiRes.nocache_roociRes = TRUE;

  /* if lob's in result we cannot use cache as it slows down upto 2X */
  if (res->res_rodbiRes.nocache_roociRes)
    /* allocate output data frame */
    rodbiResAlloc(res, nrow);

  /* state machine */
  while (!hasOutput)
  {
    switch (res->state_rodbiRes)
    {
    case FETCH_rodbiState:
      if (res->numOut && !res->res_rodbiRes.stm_cur_roociRes)
      {
        /* if cursor is not present (simple OUT), return output list directly */
        res->state_rodbiRes = OUTPUT_rodbiState;
        break;
      }
      /* fetch data */
      RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                      roociFetchData(&(res->res_rodbiRes), &fch_rows, 
                                     &(res->done_rodbiRes)));
     res->fchNum_rodbiRes = (int)fch_rows;
     /* set state */
     res->fchBeg_rodbiRes = 0;
     /* if there are more than nrows_roociRes, cache result set in ROracle */
     if (res->done_rodbiRes)
     {
       if (res->pghdl_rodbiRes)
         res->nrow_rodbiRes += fch_rows;
       else
       {
         if (nrow > 0)
           fch_rows = nrow;
         /* allocate output data frame */
         if (!res->res_rodbiRes.nocache_roociRes)
           rodbiResAlloc(res, fch_rows);
       }
     }
     else
     {
       /*
        * cache results only when BLOB,CLOB, BFILE or user-defined types
        * not in result set
       */
       if (!res->res_rodbiRes.nocache_roociRes && !res->pghdl_rodbiRes)
       {
         ROOCI_MEM_ALLOC(res->pghdl_rodbiRes, res->res_rodbiRes.ncol_roociRes,
                         sizeof(rodbichdl));
         if (!res->pghdl_rodbiRes)
           RODBI_ERROR(RODBI_ERR_MEMORY_ALC);
         res->nrow_rodbiRes += fch_rows;
       }
     }
     break;

    case SPLIT_rodbiState:
      rodbiResExpand(res);
      rodbiResSplit(res);
      break;

    case ACCUM_rodbiState:
      if (res->pghdl_rodbiRes)
        rodbiResAccumInCache(res);
      else
        rodbiResAccum(res);
      break;

    case OUTPUT_rodbiState: 
      if (!res->numOut || res->res_rodbiRes.stm_cur_roociRes)
      {
        /* for select and PLSQL cursor statement only */
        rodbiResTrim(res);
        rodbiResDataFrame(res);
      }

      /* add data frame fetched from cursor to output result list */
      if (res->numOut > 1 && res->res_rodbiRes.stm_cur_roociRes)
      {
        /* skip rodbiPlsqlResPopulate() call if single OUT cursor only */
          rodbiPlsqlResPopulate(res, &flag);
      }

      /* if more than one cursor present, FETCH again */
      if (res->state_rodbiRes == REFETCH_rodbiState)
      {
        /*
        ** Previous res->list_rodbiRes/name_rodbiRes assigned to res->list and
        ** unprotected
        */
        /* allocate output data frame */
        rodbiResAlloc(res, nrow);
        break;
      }
      else
        hasOutput = TRUE;
      break;

    default:
      RODBI_FATAL(__func__, 1, res->state_rodbiRes);
      break;
    }
    rodbiResStateNext(res);
  }

  RODBI_TRACE("result fetched");

  /* release output data frame and column names vector */
  if (res->numOut)
  {
    /* return data frame if single OUT cursor only */ 
    if (res->res_rodbiRes.stm_cur_roociRes && (res->numOut == 1))
    {
      UNPROTECT(2);
      return res->list_rodbiRes;
    }
    else
    /* else return output list */
      return res->list;
  }
  else
  {
    /* for non-PLSQL case, return data frame */
    UNPROTECT(2);
    return res->list_rodbiRes;
  }

} /* end rociResFetch */

/* ------------------------------ rociResInfo ----------------------------- */

SEXP rociResInfo(SEXP hdlRes)
{
  rodbiRes    *res = rodbiGetRes(hdlRes);
  rodbiCon    *con = res->con_rodbiRes;
  SEXP         info;
  SEXP         names;

  con->err_checked_rodbiCon = FALSE;

  /* allocate output list */
  PROTECT(info = allocVector(VECSXP, 9));

  /* allocate list element names */
  names = allocVector(STRSXP, 9);
  setAttrib(info, R_NamesSymbol, names);                  /* protects names */

  /* statement */
  SET_VECTOR_ELT(info,  0, rodbiResInfoStmt(res));
  SET_STRING_ELT(names, 0, mkChar("statement"));

  /* isSelect */
  SET_VECTOR_ELT(info,  1, 
                 ScalarLogical(res->styp_rodbiRes == OCI_STMT_SELECT));
  SET_STRING_ELT(names, 1, mkChar("isSelect"));

  /* rowsAffected */
  /* Bug 13843811 */
  SET_VECTOR_ELT(info,  2, ScalarInteger((int)res->affrows_rodbiRes));
  SET_STRING_ELT(names, 2, mkChar("rowsAffected"));

  /* rowCount */
  /* Bug 13843811 */
  SET_VECTOR_ELT(info,  3, ScalarInteger(res->rows_rodbiRes));
  SET_STRING_ELT(names, 3, mkChar("rowCount"));

  /* completed */
  SET_VECTOR_ELT(info,  4,
                 ScalarLogical(res->state_rodbiRes == CLOSE_rodbiState));
  SET_STRING_ELT(names, 4, mkChar("completed"));

  /* prefetch */
  SET_VECTOR_ELT(info,  5, ScalarLogical(res->ociprefetch_rodbiRes));
  SET_STRING_ELT(names, 5, mkChar("prefetch"));

  /* bulk_read */
  SET_VECTOR_ELT(info,  6, ScalarInteger(res->nrows_rodbiRes));
  SET_STRING_ELT(names, 6, mkChar("bulk_read"));

  /* bulk_write */
  SET_VECTOR_ELT(info,  7, ScalarInteger(res->nrows_write_rodbiRes));
  SET_STRING_ELT(names, 7, mkChar("bulk_write"));

  /* fields */
  SET_VECTOR_ELT(info,  8, rodbiResInfoFields(res));
  SET_STRING_ELT(names, 8, mkChar("fields"));

  /* release info list */
  UNPROTECT(1);

  RODBI_TRACE("result described");

  return info;
} /* end rociResInfo */

/* ------------------------------ rociEOFRes  ----------------------------- */

SEXP rociEOFRes(SEXP hdlRes)
{
  rodbiRes    *res = rodbiGetRes(hdlRes);
  SEXP         ret;

  PROTECT(ret = NEW_LOGICAL(1));

  if (res->state_rodbiRes == CLOSE_rodbiState)
    LOGICAL(ret)[0] = TRUE;
  else
    LOGICAL(ret)[0] = FALSE;

  UNPROTECT(1);
  return ret;
} /* end rociEOFRes */

/* ------------------------------- rociResTerm ---------------------------- */

SEXP rociResTerm(SEXP hdlRes)
{
  rodbiRes  *res = rodbiGetRes(hdlRes);
  rodbiCon  *con;

  if (res)
  {
    con = res->con_rodbiRes;
    con->err_checked_rodbiCon = FALSE;

    /* clean up */
    R_ClearExternalPtr(hdlRes);

    /* free result set */
    rodbiResTerm(res);

    RODBI_TRACE("result removed");
  }
  else
    RODBI_ERROR(RODBI_ERR_INVALID_RES);

  return R_NilValue;
} /* end rociResTerm */


/*----------------------------------------------------------------------------
                              INTERNAL FUNCTIONS
  --------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------
                               STATIC FUNCTIONS
  --------------------------------------------------------------------------*/

/****************************************************************************/
/*  (*) DRIVER FUNCTIONS                                                    */
/****************************************************************************/

/* ------------------------------- rodbiGetDrv ---------------------------- */

static rodbiDrv *rodbiGetDrv(SEXP ptrDrv)
{
  rodbiDrv  *drv = R_ExternalPtrAddr(ptrDrv);
  
  /* rodbiGetDrv() is called at many other places and driver pointer returned
     by this function is used without any validity check */
  /* driver validity check */
  RODBI_DRV_ASSERT(drv, __func__, 1);

  return drv;
} /* rodbiGetDrv */

/* ------------------------ rodbiDrvInfoConnections ----------------------- */

static SEXP rodbiDrvInfoConnections(rodbiDrv *drv)
{
  SEXP  vec   = R_NilValue;
  int   conID;
  int   vecID = 0;

  if ((drv->ctx_rodbiDrv).num_roociCtx)
  {
    /* allocate output vector */
    PROTECT(vec = allocVector(VECSXP, (drv->ctx_rodbiDrv).num_roociCtx));

    /* set valid connection IDs */ 
    for (conID = 0; conID < (drv->ctx_rodbiDrv).max_roociCtx; conID++)
      if ((drv->ctx_rodbiDrv).con_roociCtx[conID] &&
          rodbiAssertCon(
                   ((drv->ctx_rodbiDrv).con_roociCtx[conID])->parent_roociCon, 
                    __func__, 1))
      {
        /* allocate connection handle */
        SEXP hdlCon = R_MakeExternalPtr(
                   ((drv->ctx_rodbiDrv).con_roociCtx[conID])->parent_roociCon,
                   R_NilValue, R_NilValue);
        SET_VECTOR_ELT(vec, vecID++, hdlCon);
      }

    /* release vec */
    UNPROTECT(1);
  }

  return vec;
} /* end rodbiDrvInfoConnections */

/* ------------------------------ rodbiDrvFree ---------------------------- */

static void rodbiDrvFree(rodbiDrv *drv)
{
  rodbiCon *con;

  /* Free all results and connections */
  con = roociGetFirstParentCon(&(drv->ctx_rodbiDrv));
  while (con)
  {
    if (!rodbiAssertCon(con, __func__, 1))
      RODBI_ERROR(RODBI_ERR_INVALID_CON);

    rodbiConTerm(con);
    con = roociGetNextParentCon(&(drv->ctx_rodbiDrv));
  }

  /* free driver oci context */
  RODBI_CHECK_DRV(drv, __func__, 1, FALSE,
                  roociTerminateCtx(&(drv->ctx_rodbiDrv)));

  /* free rodbi driver */
  ROOCI_MEM_FREE(drv);

  RODBI_TRACE("driver freed");
} /* end rodbiDrvFree */


/* Convert UCS2 to UTF8 */
sword rodbiTTConvertUCS2UTF8Data(roociRes *res, const ub2 *src,
                                 size_t srclen, char **tempbuf,
                                 size_t *tempbuflen)
{
  size_t templen = 0;

  /* srclen is 2 bytes per character(UCS2) */
  srclen /= 2;

  if (*tempbuflen < srclen)
  {
    if (*tempbuf) 
      ROOCI_MEM_FREE(*tempbuf);

    /*
    ** FIXME: Multiply by ratio of 4.
    ** There is no OCI API to get max width.
    */
    *tempbuflen = srclen;
    ROOCI_MEM_MALLOC(*tempbuf, *tempbuflen * 4, sizeof(char));
    if (!*tempbuf)
      RODBI_ERROR(RODBI_ERR_MEMORY_ALC);
  }

  templen = *tempbuflen * 4;
  /* NCHAR data is returned as UCS2 in TimeTen */
  return(OCIUnicodeToCharSet(res->con_roociRes->usr_roociCon,
                             (OraText *)*tempbuf, templen, src,
                             (size_t)(srclen), &templen));
}



/****************************************************************************/
/*  (*) CONNECTION FUNCTIONS                                                */
/****************************************************************************/

/* ------------------------------ rodbiGetCon ----------------------------- */

static rodbiCon *rodbiGetCon(SEXP hdlCon)
{
  rodbiCon  *con = R_ExternalPtrAddr(hdlCon);

  /* check validity */
  if (!con || (con && !rodbiAssertCon(con, __func__, 1)))
    RODBI_ERROR(RODBI_ERR_INVALID_CON);

  return con;
} /* rodbiGetCon */


/* -------------------------- rodbiConInfoResults ------------------------- */

static SEXP rodbiConInfoResults(SEXP conxp)
{
  rodbiCon   *con  = rodbiGetCon(conxp);
  SEXP        list  = R_NilValue;
  int         resID;
  int         lstID = 0;
  int         activeRes = (con->con_rodbiCon).num_roociCon;

  if (activeRes)
  {
    /* allocate output list */
    PROTECT(list = allocVector(VECSXP, activeRes));

    /* set valid result IDs */ 
    for (resID = 0; resID < (con->con_rodbiCon).max_roociCon; resID++)
    {
      roociRes *res = (con->con_rodbiCon).res_roociCon[resID];
      if (res && rodbiAssertRes(res->parent_roociRes, __func__, 1))
      {
        /* allocate result handle */
        SEXP hdlRes = R_MakeExternalPtr(res->parent_roociRes,
                                        R_NilValue, R_NilValue);
        SET_VECTOR_ELT(list, lstID++, hdlRes);              /* protects vec */
      }
    }

    /* release output list */
    UNPROTECT(1);
  }

  return list;
} /* end rodbiConInfoResults */


/* ----------------------------- rodbiConTerm ----------------------------- */
  
static void rodbiConTerm(rodbiCon *con)
{ 
  rodbiRes  *res;

  /* Free all results */
  res = roociGetFirstParentRes(&(con->con_rodbiCon));
  while(res)
  {
    if (!rodbiAssertRes(res, __func__, 1))
      RODBI_ERROR(RODBI_ERR_INVALID_RES);
    rodbiResTerm(res);
    res = roociGetNextParentRes(&(con->con_rodbiCon));
  }

  /* free connection */
  RODBI_CHECK_CON(con, __func__, 1, FALSE,
                  roociTerminateCon(&(con->con_rodbiCon), 1));

  ROOCI_MEM_FREE(con);
} /* end rodbiConTerm */



/****************************************************************************/
/*  (*) STATEMENT FUNCTIONS                                                 */
/****************************************************************************/

/* ------------------------------ rodbiGetRes ----------------------------- */

static rodbiRes *rodbiGetRes(SEXP hdlRes)
{
  rodbiRes *res = R_ExternalPtrAddr(hdlRes);
  
  /* check validity */
  if (!res || (res && !rodbiAssertRes(res, __func__, 1)))
    RODBI_ERROR(RODBI_ERR_INVALID_RES);

  return res;
} /* rodbiGetRes */


/* ---------------------------- rodbiResExecStmt -------------------------- */

static void rodbiResExecStmt(rodbiRes *res, SEXP data, boolean free_res)
{
  switch (res->styp_rodbiRes)
  {
  case OCI_STMT_SELECT:
    rodbiResExecQuery(res, data, free_res);
    break;
  default:
    if ((res->res_rodbiRes).bcnt_roociRes)
      rodbiResExecBind(res, data, free_res);
    else
    {
      /* execute statement */
       RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                       roociStmtExec(&(res->res_rodbiRes), 1, 
                                     res->styp_rodbiRes,
                                     &(res->affrows_rodbiRes)));
       
       /* set state */
       res->state_rodbiRes = CLOSE_rodbiState;
    }
    break;
  }
} /* end rodbiResExecStmt */

/* --------------------------- rodbiResExecQuery -------------------------- */

static void rodbiResExecQuery(rodbiRes *res, SEXP data, boolean free_res)
{
  /* copy bind data */
  if ((res->res_rodbiRes).bmax_roociRes > 1)
  {
    RODBI_ERROR_RES(free_res);
    Rprintf(RODBI_ERR_UNSUPP_SQL_ENC);
  }
  else
    rodbiResBindCopy(res, data, 0, 1, free_res);

  /* execute the statement */
  RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                  roociStmtExec(&(res->res_rodbiRes), 0, res->styp_rodbiRes, 
                                &(res->affrows_rodbiRes)));

  /* set state */
  res->state_rodbiRes = FETCH_rodbiState;
} /* end rodbiResExecQuery */


/* -------------- rodbiIsVectorBind -------------- */
static boolean rodbiIsVectorBind(SEXP data, SEXP vec, SEXP elem,
                                 roociColType *btyp, int *vectyp)
{
  SEXP el = elem;
  boolean bRealVector = FALSE;
  
  if (elem)
  {
    if (TYPEOF(elem) == VECSXP)
    {
      *vectyp = TYPEOF(VECTOR_ELT(elem, 0));
      el = VECTOR_ELT(elem, 0);
    }
#if ((OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 6) || \
     (OCI_MAJOR_VERSION > 23))
    if (TYPEOF(el) == OBJSXP)
    {
      SEXP    class;
      class = Rf_getAttrib(el, R_ClassSymbol);
#ifdef DEBUG
      if (class && (TYPEOF(class) == STRSXP))
      {
        fprintf(stdout, "class=%s\n", CHAR(STRING_ELT(class, 0)));
      }
#endif
      if (class &&
          ((TYPEOF(class) == STRSXP) &&
           (!strcmp(CHAR(STRING_ELT(class, 0)), "dsparseVector"))))
      {
        btyp->vprop_roociColType |= OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE;
      }
    }
#endif
    else
      *vectyp = TYPEOF(el);
  }
  else
  {
    *vectyp = TYPEOF(vec);
  }

#ifdef DEBUG
    fprintf(stdout, "*vectyp=%d\n", *vectyp);
#endif

  if (!btyp->bndtyp_roociColType &&
      Rf_getAttrib(data, Rf_mkString((const char *)"ora.type")) != R_NilValue)
  {
    btyp->bndtyp_roociColType = CHAR(STRING_ELT(Rf_getAttrib(data,
                                  Rf_mkString((const char *)"ora.type")), 0));

#ifdef DEBUG
    fprintf(stdout, "data ora.type: bndtyp_roociColType=%s\n", 
            btyp->bndtyp_roociColType ?
            btyp->bndtyp_roociColType : "no type");
#endif
  }
  else if ((*vectyp == REALSXP) ||
           (*vectyp == STRSXP)  ||
           (*vectyp == RAWSXP)  ||
           (*vectyp == INTSXP)  ||
           (*vectyp == OBJSXP))
    bRealVector = TRUE;
  else if (!btyp->bndtyp_roociColType)
    RODBI_ERROR(RODBI_ERR_BIND_TYPE);

  return bRealVector;
}

/* ---------------------------- rodbiResExecBind -------------------------- */

static void rodbiResExecBind(rodbiRes *res, SEXP data, boolean free_res)
{
  int            beg = 0;
  int            end;
  ub4            iters;
  int            rows;


  /* execute the statement */
  rows = LENGTH(VECTOR_ELT(data, 0));
  while (rows)
  {
    /* get number of rows to process */
    iters = rows > (res->res_rodbiRes).bmax_roociRes ? 
                                     (res->res_rodbiRes).bmax_roociRes : rows;

    /* copy bind data */
    end = beg + iters;
    rodbiResBindCopy(res, data, beg, end, free_res);
    beg = end;

    /* execute the statement */
    RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                    roociStmtExec(&(res->res_rodbiRes), iters, 
                                  res->styp_rodbiRes, 
                                  &(res->affrows_rodbiRes)));
  
    /* next chunk */
    rows -= (int)iters;
  }

  /* set state -if PLSQL OUT then set state to FETCH */
  if (res->numOut)
    res->state_rodbiRes = FETCH_rodbiState;
  else
    res->state_rodbiRes = CLOSE_rodbiState;
} /* end rodbiResExecBind */


/* ----------------------------- rodbiResBind ----------------------------- */

static void rodbiResBind(rodbiRes *res, SEXP data, int bulk_write,
                         boolean free_res)
{
  int  bid;
  int  data_len = length(data);                     /* elements in data frame */

  /* validate data */
  if (isNull(data))
  {
    RODBI_ERROR_RES(free_res);
    Rf_error(RODBI_ERR_BIND_MISMATCH);
  }
  else
  {
    if ((res->res_rodbiRes).bcnt_roociRes != data_len)
      (res->res_rodbiRes).bcnt_roociRes = data_len;
  }

  /* set bind buffer size */
  (res->res_rodbiRes).bmax_roociRes = LENGTH(VECTOR_ELT(data, 0));
  if (!(res->res_rodbiRes).bmax_roociRes)
  {
    RODBI_ERROR_RES(free_res);
    Rf_error(RODBI_ERR_BIND_EMPTY);
  }
  else if ((res->res_rodbiRes).bmax_roociRes > bulk_write)
    (res->res_rodbiRes).bmax_roociRes = bulk_write;

  /* allocate bind vectors */
  ROOCI_MEM_ALLOC((res->res_rodbiRes).bdat_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(void *));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).bind_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(sb2 *));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).alen_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(ub2 *));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).bsiz_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(sb4));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).btyp_roociRes,
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(roociColType));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).param_name_roociRes,
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(void *));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).objbind_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(void *));

  if (!((res->res_rodbiRes).bdat_roociRes) ||
      !((res->res_rodbiRes).bind_roociRes) ||
      !((res->res_rodbiRes).alen_roociRes) ||
      !((res->res_rodbiRes).bsiz_roociRes) ||
      !((res->res_rodbiRes).btyp_roociRes) ||
      !((res->res_rodbiRes).param_name_roociRes) ||
      !((res->res_rodbiRes).objbind_roociRes))
  {
    RODBI_ERROR_RES(free_res);
    Rf_error(RODBI_ERR_MEMORY_ALC);
  }

  /* bind data */
  for (bid = 0; bid < (res->res_rodbiRes).bcnt_roociRes; bid++)
  {
    SEXP        vec = VECTOR_ELT(data, bid);
    SEXP        elem = ((TYPEOF(vec) == VECSXP) ? VECTOR_ELT(vec, 0) : NULL);
    SEXP        el = VECTOR_ELT(data, bid);    
#define bind_type res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType

#ifdef DEBUG
{
  printf("bid=%d\n", bid);
  Rf_PrintValue(vec);
  if (vec)
    printf("TYPEOF(vec))=%d REALSXP=%d STRSXP=%d RAWSXP=%d INTSXP=%d\n",
         TYPEOF(vec), REALSXP, STRSXP, RAWSXP, INTSXP);
  else
    printf("vec is null\n");

  if (elem)
    printf("TYPEOF(elem)=%d REALSXP=%d STRSXP=%d RAWSXP=%d INTSXP=%d\n",
           TYPEOF(elem), REALSXP, STRSXP, RAWSXP, INTSXP);
  else
    printf("elem is null\n");
}
#endif

    /* use "ora.parameter_name" attribute to call OCIBindByName */
    if (Rf_getAttrib(el,
                 Rf_mkString((const char *)"ora.parameter_name")) != R_NilValue)
      res->res_rodbiRes.btyp_roociRes[bid].bndnm_roociColType =
              CHAR(STRING_ELT(Rf_getAttrib(el,
                   Rf_mkString((const char *)"ora.parameter_name")), 0));
    else if (Rf_getAttrib(data,
             Rf_mkString((const char *)"ora.parameter_name")) != R_NilValue)
      res->res_rodbiRes.btyp_roociRes[bid].bndnm_roociColType =
              CHAR(STRING_ELT(Rf_getAttrib(data,
                   Rf_mkString((const char *)"ora.parameter_name")), 0));
    else
      res->res_rodbiRes.btyp_roociRes[bid].bndnm_roociColType = NULL;

    if (Rf_getAttrib(vec, Rf_mkString((const char *)"ora.type")) != R_NilValue)
      res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType =
                   CHAR(STRING_ELT(Rf_getAttrib(vec,
                                   Rf_mkString((const char *)"ora.type")), 0));

#ifdef DEBUG
  fprintf(stdout, "bndtyp_roociColType=%s\n", 
          res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType ?
          res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType : "no type");
#endif

    /* set bind parameters */
    if ((elem && (TYPEOF(elem) == VECSXP)) ||
        (res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType &&
           !strcmp(res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType,
                   "vector")))
    {
      int vectyp = 0;
      if (rodbiIsVectorBind(data, vec, elem,
                            &res->res_rodbiRes.btyp_roociRes[bid], &vectyp))
      {
        roociCtx *pctx = &res->con_rodbiRes->drv_rodbiCon->ctx_rodbiDrv;
        if (RODBI_CHECK_VERSION(pctx))
          RODBI_WARN_VERSION_MISMATCH(pctx);
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
        else
        {
          if (vectyp == STRSXP && ((res->styp_rodbiRes != OCI_STMT_BEGIN) &&
                                   (res->styp_rodbiRes != OCI_STMT_DECLARE)))
          {
            /*
            ** This flag is used to bind vector data represented as a list of
            ** characters in order to have server convert the data correctly.
            ** Reason for doing this is that Oracle does not provide metadata
            ** for DMLs and here if we have a binary column then we have no
            ** way of knowing and computing the dimension by multiplying with
            ** sizeof(ub1)
            */
            res->res_rodbiRes.btyp_roociRes[bid].bndflg_roociColType |=
                                                         ROOCI_COL_VEC_AS_CLOB;
          }

          res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_VEC;
          res->res_rodbiRes.bsiz_roociRes[bid] = (ub2)sizeof(OCIVector *);

          RODBI_GET_VECTOR_FORMAT(vec, elem,
                     &res->res_rodbiRes.btyp_roociRes[bid].vfmt_roociColType,
                     free_res);
        }
#else
        RODBI_WARN_VECTOR_UNSUPPORTED(pctx);
#endif /* OCI_MAJOR_VERSION >= 23 */
      }
      else
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_NTY;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(void *);

#if (OCI_MAJOR_VERSION > 11)
        RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                        OCITypeByFullName(
              res->res_rodbiRes.con_roociRes->ctx_roociCon->env_roociCtx,
              res->res_rodbiRes.con_roociRes->err_roociCon,
              res->res_rodbiRes.con_roociRes->svc_roociCon,
              (const oratext *)res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType,
              strlen(res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType),
              (const oratext *)0, (ub4)0,
              OCI_DURATION_SESSION,
              OCI_TYPEGET_ALL,
              &(res->res_rodbiRes.btyp_roociRes[bid].obtyp_roociColType.otyp_roociObjType)));
#else
        RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                        OCITypeByName(
              res->res_rodbiRes.con_roociRes->ctx_roociCon->env_roociCtx,
              res->res_rodbiRes.con_roociRes->err_roociCon,
              res->res_rodbiRes.con_roociRes->svc_roociCon,
              (const oratext *)0, (ub4)0,              
              (const oratext *)res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType,
              strlen(res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType),
              (const oratext *)0, (ub4)0,
              OCI_DURATION_SESSION,
              OCI_TYPEGET_ALL,
              &(res->res_rodbiRes.btyp_roociRes[bid].obtyp_roociColType.otyp_roociObjType)));
#endif

        RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                      roociFillAllTypeInfo(&((res->con_rodbiRes->con_rodbiCon)),
                                        &(res->res_rodbiRes),
                                        &(res->res_rodbiRes).btyp_roociRes[bid]));
      }
    }
    else
    if (TYPEOF(vec) == REALSXP)
    {
      if (Rf_inherits(vec, RODBI_R_DAT_NM))
      {
        if (res->con_rodbiRes->con_rodbiCon.timesten_rociCon)
          (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_TIMESTAMP;
        else
          (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_TIMESTAMP_LTZ;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (ub2)sizeof(OCIDateTime *);
      }
      else if (Rf_inherits(vec, RODBI_R_DIF_NM) &&
          /* TimesTen binds difftime as SQLT_BDOUBLE */
          !res->con_rodbiRes->con_rodbiCon.timesten_rociCon)
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_INTERVAL_DS;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(OCIInterval *);
      }
      else
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_BDOUBLE;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(double);
      }
    }
    else if ((TYPEOF(vec) == INTSXP) || (TYPEOF(vec) == LGLSXP))
    {
      (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_INT;
      (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(int);
    }
    else if (TYPEOF(vec) == STRSXP)
    {
      if (bind_type && !strcmp(bind_type, "clob"))
      {
        res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)sizeof(OCILobLocator *);
        res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_CLOB;
      }
      else if (bind_type && !strcmp(bind_type, "blob"))
      {
        res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)sizeof(OCILobLocator *);
        res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_BLOB;
      }
      else if (bind_type && !strcmp(bind_type, "bfile"))
      {
        res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)sizeof(OCILobLocator *);
        res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_BFILE;
      }
      else
      {
        int    len = LENGTH(VECTOR_ELT(data, 0));
        int    i;
        sb8    bndsz = 0;

        /* find the max len of the bind data */
        for (i=0; i<len; i++)
        {
          sb8 ellen = (sb8)strlen(CHAR(STRING_ELT(vec, i)));
          bndsz = (bndsz < ellen) ? ellen : bndsz;
        }

        if (bndsz > SB4MAXVAL)
        {
          RODBI_ERROR_RES(free_res);
          Rf_error(RODBI_ERR_BIND_VAL_TOOBIG, bndsz);
        }

        /* Limitation of OCIBindByPos API, where alen is ub2 for array binds */
        /* For strings larger than UB2MAXVAL - NULL terminator, use SQLT_LVC */
        if (bndsz > (UB2MAXVAL -
                    res->con_rodbiRes->con_rodbiCon.nlsmaxwidth_roociCon))
        {
          res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_LVC;
          bndsz += sizeof(sb4);
        }
        else
        {
          bndsz += res->con_rodbiRes->con_rodbiCon.nlsmaxwidth_roociCon;
          res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_STR;
        }

        /* align buffer to even boundary */
        bndsz += (sizeof(char *) - (bndsz % sizeof(char *)));
        res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)bndsz;
      }
    }
    else if ((elem && (TYPEOF(vec) == VECSXP)) &&
                      (TYPEOF(elem) == RAWSXP))                  /* raw type */
    {
      int    len = LENGTH(VECTOR_ELT(data, 0));
      int    i;
      sb8    bndsz = 0;

      if (Rf_getAttrib(vec,
                       Rf_mkString((const char *)"ora.type")) != R_NilValue)
        res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType =
           CHAR(STRING_ELT(Rf_getAttrib(vec,
                         Rf_mkString((const char *)"ora.type")), 0));

      if (bind_type && !strcmp(bind_type, "blob"))
      {
        res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)sizeof(OCILobLocator *);
        res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_BLOB;
      }
      else if (bind_type && !strcmp(bind_type, "clob"))
      {
        res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)sizeof(OCILobLocator *);
        res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_CLOB;
      }
      else if (bind_type && !strcmp(bind_type, "bfile"))
      {
        res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)sizeof(OCILobLocator *);
        res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_BFILE;
      }
      else
      {
        /* find the max len of the bind data */
        for (i=0; i<len; i++)
        {
          sb8 ellen = (sb8)(LENGTH(VECTOR_ELT(vec, i)));
          bndsz = (bndsz < ellen) ? ellen : bndsz;
        }

        if (bndsz > SB4MAXVAL)
        {
          RODBI_ERROR_RES(free_res);
          Rf_error(RODBI_ERR_BIND_VAL_TOOBIG, bndsz);
        }

        /* Limitation of OCIBindByPos API, where alen is ub2 for array binds */
        /* For strings larger than UB2MAXVAL, use SQLT_LVB */
        if (bndsz > UB2MAXVAL)
        {
          res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_LVB;
          bndsz += sizeof(sb4);
        }
        else
          res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_BIN;

        /* align buffer to even boundary */
        bndsz += (sizeof(char *) - (bndsz % sizeof(char *)));
        res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)bndsz;
      }
    }
    else
    {
      RODBI_ERROR_RES(free_res);
      Rf_error(RODBI_ERR_UNSUPP_BIND_TYPE);
    }

    /* allocate bind buffers */
    ROOCI_MEM_ALLOC((res->res_rodbiRes).bdat_roociRes[bid], 
                    ((res->res_rodbiRes).bmax_roociRes * 
                    (res->res_rodbiRes).bsiz_roociRes[bid]), sizeof(ub1));

    ROOCI_MEM_ALLOC((res->res_rodbiRes).bind_roociRes[bid],
                    (res->res_rodbiRes).bmax_roociRes, sizeof(sb2));

    ROOCI_MEM_ALLOC((res->res_rodbiRes).alen_roociRes[bid],
                    (res->res_rodbiRes).bmax_roociRes, sizeof(ub2));

    if (!((res->res_rodbiRes).bdat_roociRes[bid]) ||
        !((res->res_rodbiRes).bind_roociRes[bid]) ||
        !((res->res_rodbiRes).alen_roociRes[bid]))
    {
      RODBI_ERROR_RES(free_res);
      Rf_error(RODBI_ERR_MEMORY_ALC);
    }

    if ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType ==
                                                              SQLT_TIMESTAMP_LTZ)
    {
      void **tsdt = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                      roociAllocDescBindBuf(&(res->res_rodbiRes), tsdt,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                  (ub4)OCI_DTYPE_TIMESTAMP_LTZ));
    } 
    else if ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType ==
                                                              SQLT_TIMESTAMP)
    {
      void **tsdt = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                      roociAllocDescBindBuf(&(res->res_rodbiRes), tsdt,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                            (ub4)OCI_DTYPE_TIMESTAMP));
    } 
    else if (((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType ==
                                                          SQLT_INTERVAL_DS) &&
             /* TimesTen binds difftime as SQLT_BDOUBLE */
             !res->con_rodbiRes->con_rodbiCon.timesten_rociCon)
    {
      void **invl = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                      roociAllocDescBindBuf(&(res->res_rodbiRes), invl,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                            OCI_DTYPE_INTERVAL_DS));
    }
    else
    if (((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_CLOB) ||
        ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_BLOB))
    {
      void **lb = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                      roociAllocDescBindBuf(&(res->res_rodbiRes), lb,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                            OCI_DTYPE_LOB));
    }
    else
    if ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_BFILE)
    {
      void **lf = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                      roociAllocDescBindBuf(&(res->res_rodbiRes), lf,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                            OCI_DTYPE_FILE));
    }
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || \
    (OCI_MAJOR_VERSION > 23)
    else if ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_VEC)
    {
      void **lvec = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      roociCtx   *pctx = &res->con_rodbiRes->drv_rodbiCon->ctx_rodbiDrv;
      if (RODBI_CHECK_VERSION(pctx))
        RODBI_WARN_VERSION_MISMATCH(pctx);
      else
      {
        if (res->res_rodbiRes.btyp_roociRes[bid].bndflg_roociColType &
            ROOCI_COL_VEC_AS_CLOB)
          RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                          roociAllocDescBindBuf(&(res->res_rodbiRes), lvec,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                  OCI_DTYPE_LOB));
        else
          RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                          roociAllocDescBindBuf(&(res->res_rodbiRes), lvec,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                  OCI_DTYPE_VECTOR));
      }
    }
#endif /* OCI_MAJOR_VERSION >= 23 */
    else if ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_NTY)
    {
      ROOCI_MEM_ALLOC((res->res_rodbiRes).objbind_roociRes[bid], 
                      ((res->res_rodbiRes).bmax_roociRes * 
                      (res->res_rodbiRes).bsiz_roociRes[bid]), sizeof(void *));

      if (!((res->res_rodbiRes).objbind_roociRes[bid]))
      {
        RODBI_ERROR_RES(free_res);
        Rf_error(RODBI_ERR_MEMORY_ALC);
      }

      RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                      roociAllocObjectBindBuf(&(res->res_rodbiRes),
                          (void **)((res->res_rodbiRes).bdat_roociRes[bid]),
                          (void **)((res->res_rodbiRes).objbind_roociRes[bid]),
                          bid));
    } 
  }
} /* end rodbiResBind */

/* --------------------------- rodbiPlsqlResBind -------------------------- */

static void rodbiPlsqlResBind(rodbiRes *res, SEXP data, int bulk_write,
                              boolean free_res)
{
  int  bid;
  SEXP col_names;
  int  data_len = length(data);                     /* elements in data frame */
#define bind_type res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType

  /* Number of cursors present in PLSQL stmt */
  int  CursorCount = 1; 

  /* validate data */
  if (isNull(data))
  {
    RODBI_ERROR_RES(free_res);
    Rf_error(RODBI_ERR_BIND_MISMATCH);
  }
  else
  {
    if ((res->res_rodbiRes).bcnt_roociRes != data_len)
      (res->res_rodbiRes).bcnt_roociRes = data_len;
  }

  /* set bind buffer size */
  (res->res_rodbiRes).bmax_roociRes = LENGTH(VECTOR_ELT(data, 0));
  if (!(res->res_rodbiRes).bmax_roociRes)
  {
    RODBI_ERROR_RES(free_res);
    Rf_error(RODBI_ERR_BIND_EMPTY);
  }
  else if ((res->res_rodbiRes).bmax_roociRes > bulk_write)
    (res->res_rodbiRes).bmax_roociRes = bulk_write;

  /* allocate bind vectors */
  ROOCI_MEM_ALLOC((res->res_rodbiRes).bdat_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(void *));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).bind_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(sb2 *));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).alen_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(ub2 *));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).bsiz_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(sb4));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).btyp_roociRes,
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(roociColType));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).bform_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(int));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).param_name_roociRes,
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(void *));

  ROOCI_MEM_ALLOC(res->mode_rodbiRes,
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(int));

  if (!((res->res_rodbiRes).bdat_roociRes) ||
      !((res->res_rodbiRes).bind_roociRes) ||
      !((res->res_rodbiRes).alen_roociRes) ||
      !((res->res_rodbiRes).bsiz_roociRes) ||
      !((res->res_rodbiRes).btyp_roociRes) ||
      !((res->res_rodbiRes).bform_roociRes)||
      !(res->mode_rodbiRes)||
      !((res->res_rodbiRes).param_name_roociRes))
  {
    RODBI_ERROR_RES(free_res);
    Rf_error(RODBI_ERR_MEMORY_ALC);
  }

  /* alloc column names vector for OUT/IN OUT data.frame */
  PROTECT(col_names = allocVector(STRSXP, (res->res_rodbiRes).bcnt_roociRes));
  col_names = getAttrib (data, R_NamesSymbol);

  /* bind data */
  for (bid = 0; bid < (res->res_rodbiRes).bcnt_roociRes; bid++)
  {
    SEXP        vec = VECTOR_ELT(data, bid);
    SEXP        elem = ((TYPEOF(vec) == VECSXP) ? VECTOR_ELT(vec, 0) : NULL);
    const char *bind_enc  = NULL;
    const char *colName   = NULL;
    sb4         bind_length = 0;
    SEXP        el = VECTOR_ELT(data, bid);    

    /* use "ora.parameter_name" attribute to call OCIBindByName */
    if (Rf_getAttrib(el,
                 Rf_mkString((const char *)"ora.parameter_name")) != R_NilValue)
      res->res_rodbiRes.btyp_roociRes[bid].bndnm_roociColType =
              CHAR(STRING_ELT(Rf_getAttrib(el,
                   Rf_mkString((const char *)"ora.parameter_name")), 0));
    else if (Rf_getAttrib(data,
             Rf_mkString((const char *)"ora.parameter_name")) != R_NilValue)
      res->res_rodbiRes.btyp_roociRes[bid].bndnm_roociColType =
              CHAR(STRING_ELT(Rf_getAttrib(data,
                   Rf_mkString((const char *)"ora.parameter_name")), 0));
    else
      res->res_rodbiRes.btyp_roociRes[bid].bndnm_roociColType = NULL;

    /* Read "ora.type", "ora.encoding", "ora.maxlength" attributes */
    SEXP mode = Rf_getAttrib(vec, install("ora.parameter_mode"));
    SEXP mode1 = Rf_getAttrib(data,  install("ora.parameter_mode"));

    if ((!isNull(mode) && (!strcmp(CHAR(STRING_ELT(mode, 0)), "OUT"))) ||
        (!isNull(mode1) && (!strcmp(CHAR(STRING_ELT(mode1, 0)), "OUT"))))
      res->mode_rodbiRes[bid] = OUT_mode;
    else if ((!isNull(mode) &&
                       (!strcmp(CHAR(STRING_ELT(mode, 0)), "IN OUT"))) ||
            (!isNull(mode1) &&
                        (!strcmp(CHAR(STRING_ELT(mode1, 0)), "IN OUT"))))
      res->mode_rodbiRes[bid] = INOUT_mode;
    else
      res->mode_rodbiRes[bid] = IN_mode;

    /* setting attributes to bind buffers for simple OUT/IN OUT case */
    if (res->mode_rodbiRes[bid] != IN_mode)
    {
      if (Rf_getAttrib(vec,
                       Rf_mkString((const char *)"ora.type")) != R_NilValue)
        bind_type = CHAR(STRING_ELT(Rf_getAttrib(vec,
                         Rf_mkString((const char *)"ora.type")), 0));
      else if (Rf_getAttrib(data,
                           Rf_mkString((const char *)"ora.type")) != R_NilValue)
        bind_type = CHAR(STRING_ELT(Rf_getAttrib(data,
                         Rf_mkString((const char *)"ora.type")), 0));

      /* "ora.encoding" for deciding bind_length for OUT string/raw */
      if (Rf_getAttrib(vec,
                       Rf_mkString((const char *)"ora.encoding")) != R_NilValue)
        bind_enc = CHAR(STRING_ELT(Rf_getAttrib(vec,
                        Rf_mkString((const char *)"ora.encoding")), 0));
      else if (Rf_getAttrib(data,
                       Rf_mkString((const char *)"ora.encoding")) != R_NilValue)
        bind_enc = CHAR(STRING_ELT(Rf_getAttrib(data,
                        Rf_mkString((const char *)"ora.encoding")), 0));

      if (bind_enc && !strcmp(bind_enc, "UTF-8"))
        res->res_rodbiRes.bform_roociRes[bid] = SQLCS_NCHAR;
      else
        res->res_rodbiRes.bform_roociRes[bid] = 0;

      /* "ora.maxlength" for extracting length for OUT case e.g. string */
      if (Rf_getAttrib(vec,
                      Rf_mkString((const char *)"ora.maxlength")) != R_NilValue)
      {
        if (isInteger(Rf_getAttrib(vec,
                      Rf_mkString((const char *)"ora.maxlength"))))
          bind_length = INTEGER(Rf_getAttrib(vec,
                                Rf_mkString((const char *)"ora.maxlength")))[0];
        else if (isReal(Rf_getAttrib(vec,
                        Rf_mkString((const char *)"ora.maxlength"))))
          bind_length = REAL(Rf_getAttrib(vec,
                             Rf_mkString((const char *)"ora.maxlength")))[0];
      }
      else if (Rf_getAttrib(data,
                      Rf_mkString((const char *)"ora.maxlength")) != R_NilValue)
      {
        if (isInteger(Rf_getAttrib(data,
                      Rf_mkString((const char *)"ora.maxlength"))))
          bind_length = INTEGER(Rf_getAttrib(data,
                                Rf_mkString((const char *)"ora.maxlength")))[0];
        else if (isReal(Rf_getAttrib(data,
                        Rf_mkString((const char *)"ora.maxlength"))))
          bind_length = REAL(Rf_getAttrib(data,
                             Rf_mkString((const char *)"ora.maxlength")))[0];
      }  
      else
        bind_length = 32767;
    }

    /* use "ora.type" attribute to get type of vector passed */
    if (Rf_getAttrib(vec,
                     Rf_mkString((const char *)"ora.type")) != R_NilValue)
      res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType =
                   CHAR(STRING_ELT(Rf_getAttrib(vec,
                                   Rf_mkString((const char *)"ora.type")), 0));

#ifdef DEBUG
  printf("bid=%d\n", bid);
  Rf_PrintValue(vec);
  if (vec)
    printf("TYPEOF(vec))=%d REALSXP=%d STRSXP=%d RAWSXP=%d INTSXP=%d\n",
         TYPEOF(vec), REALSXP, STRSXP, RAWSXP, INTSXP);
  else
    printf("vec is null\n");

  if (elem)
    printf("TYPEOF(elem)=%d REALSXP=%d STRSXP=%d RAWSXP=%d INTSXP=%d\n",
           TYPEOF(elem), REALSXP, STRSXP, RAWSXP, INTSXP);
  else
    printf("elem is null\n");
  fprintf(stdout, "bndtyp_roociColType=%s\n",
          res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType ?
          res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType : "no type");
#endif

    /* set bind parameters */
    if (((elem && (TYPEOF(elem) == VECSXP)) &&
                  (TYPEOF(elem) != RAWSXP)) ||       /* user defined type */
        (elem && (TYPEOF(elem) == VECSXP) &&                 /* or vector */
         (res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType &&
           !strcmp(res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType,
                   "vector"))))
    {
      int vectyp = 0;
      if (rodbiIsVectorBind(data, vec, elem,
                            &res->res_rodbiRes.btyp_roociRes[bid], &vectyp))
      {
        roociCtx   *pctx = &res->con_rodbiRes->drv_rodbiCon->ctx_rodbiDrv;
        if (RODBI_CHECK_VERSION(pctx))
          RODBI_WARN_VERSION_MISMATCH(pctx);
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
        else
        {
          (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_VEC;
          (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(OCIVector *);

          RODBI_GET_VECTOR_FORMAT(vec, elem,
              &(res->res_rodbiRes.btyp_roociRes[bid].vfmt_roociColType),
                                  free_res);
        }
#else
        RODBI_WARN_VECTOR_UNSUPPORTED(pctx);
#endif /* OCI_MAJOR_VERSION >= 23 */
      }
      else
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_NTY;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(void *);

#if (OCI_MAJOR_VERSION > 11)
        RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                        OCITypeByFullName(
          res->res_rodbiRes.con_roociRes->ctx_roociCon->env_roociCtx,
          res->res_rodbiRes.con_roociRes->err_roociCon,
          res->res_rodbiRes.con_roociRes->svc_roociCon,
    (const oratext *)res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType,
              strlen(res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType),
                                  (const oratext *)0, (ub4)0,
                                  OCI_DURATION_SESSION,
                                  OCI_TYPEGET_ALL,
    &(res->res_rodbiRes.btyp_roociRes[bid].obtyp_roociColType.otyp_roociObjType)));
#else
        RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                        OCITypeByName(
              res->res_rodbiRes.con_roociRes->ctx_roociCon->env_roociCtx,
              res->res_rodbiRes.con_roociRes->err_roociCon,
              res->res_rodbiRes.con_roociRes->svc_roociCon,
              (const oratext *)0, (ub4)0,              
              (const oratext *)res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType,
              strlen(res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType),
              (const oratext *)0, (ub4)0,
              OCI_DURATION_SESSION,
              OCI_TYPEGET_ALL,
              &(res->res_rodbiRes.btyp_roociRes[bid].obtyp_roociColType.otyp_roociObjType)));
#endif

        RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                        roociFillAllTypeInfo(&((res->con_rodbiRes->con_rodbiCon)),
                                      &(res->res_rodbiRes),
                                      &(res->res_rodbiRes).btyp_roociRes[bid]));
      }
    }
    else
    if (TYPEOF(vec) == REALSXP)
    {
      if (Rf_inherits(vec, RODBI_R_DAT_NM))
      {
        if (res->con_rodbiRes->con_rodbiCon.timesten_rociCon)
          (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_TIMESTAMP;
        else
          (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_TIMESTAMP_LTZ;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (ub2)sizeof(OCIDateTime *);
      }
      else if (Rf_inherits(vec, RODBI_R_DIF_NM) &&
      /* TimesTen binds difftime as SQLT_BDOUBLE */
               !res->con_rodbiRes->con_rodbiCon.timesten_rociCon)
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_INTERVAL_DS;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(OCIInterval *);
      }
      else
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_BDOUBLE;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(double);
      }
    }
    else if ((TYPEOF(vec) == INTSXP) || (TYPEOF(vec) == LGLSXP))
    {
      /* check if cursor is present (NA- logical type) */
      if (bind_type && !strcmp(bind_type, "cursor"))
      {
        /* passing CursorCount from bsiz to roociBindData */
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_RSET;
        /* Bug 22329115 */
        (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)(CursorCount++); 
      }
      /* check if raw type */
      else if (bind_type && !strcmp(bind_type, "raw"))
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_BIN;
        (res->res_rodbiRes).bsiz_roociRes[bid] = bind_length;
      }
      /* check if boolean type */
      else if (bind_type && !strcmp(bind_type, "boolean"))
      {
#if (OCI_MAJOR_VERSION >= 12)
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_BOL;
#else
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_INT;
#endif
        (res->res_rodbiRes).bsiz_roociRes[bid] = sizeof(int);
      }
      else if (bind_type && !strcmp(bind_type, "clob"))
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_CLOB;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(OCILobLocator *);
      }
      /* check if BLOB type */
      else if (bind_type && !strcmp(bind_type, "blob"))
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_BLOB;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(OCILobLocator *);
      }
      /* check if vector type */
      else if (bind_type && !strcmp(bind_type, "vector"))
      {
        roociCtx   *pctx = &res->con_rodbiRes->drv_rodbiCon->ctx_rodbiDrv;
        if (RODBI_CHECK_VERSION(pctx))
          RODBI_WARN_VERSION_MISMATCH(pctx);
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
        else
        {
          (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_VEC;
          (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(OCIVector *);

          RODBI_GET_VECTOR_FORMAT(vec, data,
              &(res->res_rodbiRes.btyp_roociRes[bid].vfmt_roociColType),
                    free_res);
        }
#else
        RODBI_WARN_VECTOR_UNSUPPORTED(pctx);
#endif /* OCI_MAJOR_VERSION >= 23 */
      }
      /* check if bfile type */
      else if (bind_type && !strcmp(bind_type, "bfile"))
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_BFILE;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(OCILobLocator *);
      }
      /* check if string type */
      else if (bind_type && (!strcmp(bind_type, "char") || 
                                                 !strcmp(bind_type, "varchar")))
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_STR;
        (res->res_rodbiRes).bsiz_roociRes[bid] = bind_length;
      }
      /* check if date or timestamp or timestamp with timezone type */
      else if (bind_type && (!strcmp(bind_type, "date") || 
                                               !strcmp(bind_type, "timestamp")))
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_TIMESTAMP;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (ub2)sizeof(OCIDateTime *);
      }
      /* check timestamp with timezone or timestamp with local timezone type */
      else if (bind_type && (!strcmp(bind_type, "timestamp with timezone") ||
                           !strcmp(bind_type, "timestamp with local timezone")))
      {
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_TIMESTAMP_LTZ;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (ub2)sizeof(OCIDateTime *);
      } 
      /* check if difftime type */
      else if (bind_type && !strcmp(bind_type, "difftime"))
      {
        /* TimesTen binds difftime as SQLT_BDOUBLE */
        if (!res->con_rodbiRes->con_rodbiCon.timesten_rociCon)
        {
          (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_INTERVAL_DS;
          (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(OCIInterval *);
        }
        else
        {
          (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_BDOUBLE;
          (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(double);
        }
      }
      else
      {
#if (OCI_MAJOR_VERSION >= 12)
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = 
                                             (TYPEOF(vec) == LGLSXP) ? SQLT_BOL : SQLT_INT;
#else
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_INT;
#endif
        (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType = SQLT_INT;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (sb4)sizeof(int);
      }
    }
    else if (TYPEOF(vec) == STRSXP)
    {
      /* Using attributes to set bind buffer type & size if simple OUT case */
      if (res->mode_rodbiRes[bid] == OUT_mode)
      {
        if (bind_type)
        {
            if (!strcmp(bind_type, "clob"))
            {
              res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)sizeof(OCILobLocator *);
              res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_CLOB;
            }
            else if (!strcmp(bind_type, "blob"))
            {
              res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)sizeof(OCILobLocator *);
              res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_BLOB;
            }
            else if (!strcmp(bind_type, "vector"))
            {
              roociCtx   *pctx = &res->con_rodbiRes->drv_rodbiCon->ctx_rodbiDrv;
              if (RODBI_CHECK_VERSION(pctx))
                RODBI_WARN_VERSION_MISMATCH(pctx);
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
              else
              {
                res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_VEC;
                res->res_rodbiRes.bsiz_roociRes[bid] = (ub2)sizeof(OCIVector *);
              }
#else
              RODBI_WARN_VECTOR_UNSUPPORTED(pctx);
#endif /* OCI_MAJOR_VERSION >= 23 */
            }
            else
            {
              res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)sizeof(OCILobLocator *);
              res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_BFILE;
            }
        }
        else
        {
          res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_STR;
          res->res_rodbiRes.bsiz_roociRes[bid] = bind_length;
        }
      }
      else
      {
        int    len = LENGTH(VECTOR_ELT(data, 0));
        int    i;
        sb8    bndsz = 0;

        /* find the max len of the bind data */
        for (i=0; i<len; i++)
        {
          sb8 ellen = (sb8)strlen(CHAR(STRING_ELT(vec, i)));
          bndsz = (bndsz < ellen) ? ellen : bndsz;
        }

        if (bndsz > SB4MAXVAL)
        {
          RODBI_ERROR_RES(free_res);
          Rf_error(RODBI_ERR_BIND_VAL_TOOBIG, bndsz);
        }

        /* Limitation of OCIBindByPos API, where alen is ub2 for array binds */
        /* For strings larger than UB2MAXVAL - NULL terminator, use SQLT_LVC */
        if (bndsz > (UB2MAXVAL -
                      res->con_rodbiRes->con_rodbiCon.nlsmaxwidth_roociCon))
        {
          res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_LVC;
          bndsz += sizeof(sb4);
        }
        else
        {
          bndsz += res->con_rodbiRes->con_rodbiCon.nlsmaxwidth_roociCon;
          res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_STR;
        }

        /* align buffer to even boundary */
        bndsz += (sizeof(char *) - (bndsz % sizeof(char *)));
        res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)bndsz;
      }
    }
    else if ((TYPEOF(vec) == VECSXP) && (TYPEOF(VECTOR_ELT(vec, 0)) == RAWSXP))
    {
      if (bind_length)
      {
        res->res_rodbiRes.bsiz_roociRes[bid] = bind_length;
        res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_BIN;
      }
      else
      {
        int    len = LENGTH(VECTOR_ELT(data, 0));
        int    i;
        sb8    bndsz = 0;
  
        /* find the max len of the bind data */
        for (i=0; i<len; i++)
        {
          sb8 ellen = (sb8)(LENGTH(VECTOR_ELT(vec, i)));
          bndsz = (bndsz < ellen) ? ellen : bndsz;
        }

        if (bndsz > SB4MAXVAL)
        {
          RODBI_ERROR_RES(free_res);
          Rf_error(RODBI_ERR_BIND_VAL_TOOBIG, bndsz);
        }

        /* Limitation of OCIBindByPos API, where alen is ub2 for array binds */
        /* For strings larger than UB2MAXVAL, use SQLT_LVB */
        if (bndsz > UB2MAXVAL)
        {
          res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_LVB;
          bndsz += sizeof(sb4);
        }
        else
          res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType = SQLT_BIN;

        /* align buffer to even boundary */
        bndsz += (sizeof(char *) - (bndsz % sizeof(char *)));
        res->res_rodbiRes.bsiz_roociRes[bid] = (sb4)bndsz;
      }
    }
    else
    {
      RODBI_ERROR_RES(free_res);
      Rf_error(RODBI_ERR_UNSUPP_BIND_TYPE);
    }

    /* allocate bind buffers */
    ROOCI_MEM_ALLOC((res->res_rodbiRes).bdat_roociRes[bid], 
                    ((res->res_rodbiRes).bmax_roociRes * 
                    (res->res_rodbiRes).bsiz_roociRes[bid]), sizeof(ub1));

    ROOCI_MEM_ALLOC((res->res_rodbiRes).bind_roociRes[bid],
                    (res->res_rodbiRes).bmax_roociRes, sizeof(sb2));

    ROOCI_MEM_ALLOC((res->res_rodbiRes).alen_roociRes[bid],
                    (res->res_rodbiRes).bmax_roociRes, sizeof(ub2));

    if (!((res->res_rodbiRes).bdat_roociRes[bid]) ||
        !((res->res_rodbiRes).bind_roociRes[bid]) ||
        !((res->res_rodbiRes).alen_roociRes[bid]))
    {
      RODBI_ERROR_RES(free_res);
      Rf_error(RODBI_ERR_MEMORY_ALC);
    }

    if ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_TIMESTAMP_LTZ)
    {
      void **tsdt = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                      roociAllocDescBindBuf(&(res->res_rodbiRes), tsdt,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                            (ub4)OCI_DTYPE_TIMESTAMP_LTZ));
    } 
    else if ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_TIMESTAMP)
    {
      void **tsdt = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                      roociAllocDescBindBuf(&(res->res_rodbiRes), tsdt,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                            (ub4)OCI_DTYPE_TIMESTAMP));
    } 
    else if (((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_INTERVAL_DS) &&
             /* TimesTen binds difftime as SQLT_BDOUBLE */
             !res->con_rodbiRes->con_rodbiCon.timesten_rociCon)
    {
      void **invl = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                      roociAllocDescBindBuf(&(res->res_rodbiRes), invl,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                            OCI_DTYPE_INTERVAL_DS));
    } 
    else if (((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_CLOB) ||
             ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_BLOB))
    {
      void **lb = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                      roociAllocDescBindBuf(&(res->res_rodbiRes), lb,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                            OCI_DTYPE_LOB));
    }
    else if ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_BFILE)
    {
      void **lf = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                      roociAllocDescBindBuf(&(res->res_rodbiRes), lf,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                            OCI_DTYPE_FILE));
    }
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
    else if ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_VEC)
    {
      void **lvec = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      if (res->res_rodbiRes.btyp_roociRes[bid].bndflg_roociColType &
          ROOCI_COL_VEC_AS_CLOB)
        RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                        roociAllocDescBindBuf(&(res->res_rodbiRes), lvec,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                  OCI_DTYPE_LOB));
      else
        RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                        roociAllocDescBindBuf(&(res->res_rodbiRes), lvec,
                                  (res->res_rodbiRes).bsiz_roociRes[bid],
                                  OCI_DTYPE_VECTOR));
    }
#endif /* OCI_MAJOR_VERSION */

    /* set param_name_roociRes field for column names of OUT/INOUT date.frame */
    colName = CHAR(STRING_ELT(col_names, bid));
    if (colName)
    {
      ROOCI_MEM_ALLOC((res->res_rodbiRes).param_name_roociRes[bid],
                    1, strlen(colName)+1);
      if (!((res->res_rodbiRes).param_name_roociRes[bid]))
      {
        RODBI_ERROR_RES(free_res);
        Rf_error(RODBI_ERR_MEMORY_ALC);
      }
      strcpy((res->res_rodbiRes).param_name_roociRes[bid], colName);
    }
    else
      (res->res_rodbiRes).param_name_roociRes[bid] = NULL;
  }
  UNPROTECT(1);


  /* if Cursor is present */
  if (CursorCount-1)
  {
    /* allocate cursor statement handle buffer */
    ROOCI_MEM_ALLOC((res->res_rodbiRes).stm_cur_roociRes,
                    CursorCount-1, sizeof(OCIStmt *));

    if (!(res->res_rodbiRes).stm_cur_roociRes)
    {
      RODBI_ERROR_RES(free_res);
      Rf_error(RODBI_ERR_MEMORY_ALC);
    }

    /* Initialize each cursor statement handle */
    for (bid = 0; bid < CursorCount-1; bid++)
    {
      (res->res_rodbiRes).stm_cur_roociRes[bid] = NULL;
    }
  }
  else
    (res->res_rodbiRes).stm_cur_roociRes = NULL;

} /* end rodbiPlsqlResBind */

/* ---------------------------- rodbiResBindCopy -------------------------- */

static void rodbiResBindCopy(rodbiRes *res, SEXP data, int beg, int end,
                             boolean free_res)
{
  int  bid;
  int  i;

  for (bid = 0; bid < (res->res_rodbiRes).bcnt_roociRes; bid++)
  {
    SEXP        elem = VECTOR_ELT(data, bid);
    ub1        *dat  = (ub1 *)(res->res_rodbiRes).bdat_roociRes[bid];
    sb2        *ind  = (res->res_rodbiRes).bind_roociRes[bid];
    ub2        *alen = (res->res_rodbiRes).alen_roociRes[bid];
    ub1         form_of_use = 0;

    /* copy vector */
    for (i = beg; i < end; i++)
    {
      *ind = OCI_IND_NOTNULL;
      *alen = (res->res_rodbiRes).bsiz_roociRes[bid];

      /* For PLSQL OUT case set *ind to NULL */
      if (res->numOut &&
          res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType &&
          (strcmp(res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType,
                  "vector") ||
           (!strcmp(res->res_rodbiRes.btyp_roociRes[bid].bndtyp_roociColType,
                    "vector") &&
            res->mode_rodbiRes[bid] == OUT_mode))) {
        *ind = OCI_IND_NULL;
      }
      else 
      if (res->res_rodbiRes.btyp_roociRes[bid].obtyp_roociColType.otyp_roociObjType)
       {
        RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                        roociWriteUDTData(&(res->res_rodbiRes),
                            &res->res_rodbiRes.btyp_roociRes[bid],
                            (roociObjType *)0, *(void **)dat, (void *)0,
                            (OCIInd *)0, VECTOR_ELT(elem, i),
                            (res->con_rodbiRes->drv_rodbiCon->unicode_as_utf8 ?
                              SQLCS_NCHAR : 0)));

      }
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
      else 
      if (res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType == SQLT_VEC) 
      {
        roociCtx  *pctx = &res->con_rodbiRes->drv_rodbiCon->ctx_rodbiDrv;
        int        vectyp;
        SEXP       el;

        if (elem && (TYPEOF(elem) == VECSXP))
        {
          vectyp = TYPEOF(VECTOR_ELT(elem, i));
          if (vectyp == VECSXP)
            el = VECTOR_ELT(VECTOR_ELT(elem, i), 0);
          else
            el = elem;
        }
        else
        {
          el = elem;
          vectyp = TYPEOF(elem);
        }

        if (RODBI_CHECK_VERSION(pctx))
          RODBI_WARN_VERSION_MISMATCH(pctx);
        else
        {
          if (isNull(el))
            *ind = OCI_IND_NULL;
          else
          {
            if (TYPEOF(elem) == STRSXP)
              RODBI_GET_FORM_OF_USE(&form_of_use, el, i, free_res);

            RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
               roociWriteVectorData(&(res->res_rodbiRes),
                 &res->res_rodbiRes.btyp_roociRes[bid],
                 *(OCIVector **)dat, el,
                 form_of_use, ind));
          }
        }
      }
#endif /* OCI_MAJOR_VERSION >= 23 */
      else if (TYPEOF(elem) == REALSXP) 
      {

        if (ISNA(REAL(elem)[i]))
          *ind = OCI_IND_NULL;
        else
        {
          if (((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_TIMESTAMP_LTZ) ||
              ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_TIMESTAMP))
          {
            RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                            roociWriteDateTimeData(&(res->res_rodbiRes),
                                                   *(OCIDateTime **)dat,
                                                   REAL(elem)[i]));
          }
          else if ((res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType == SQLT_INTERVAL_DS)
            RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                            roociWriteDiffTimeData(&(res->res_rodbiRes),
                                                   *(OCIInterval **)dat,
                                                   REAL(elem)[i]));
          else
            *(double *)dat = REAL(elem)[i];
        }
      } 
      else if (TYPEOF(elem) == INTSXP) 
      {
        if (INTEGER(elem)[i] == NA_INTEGER)
          *ind = OCI_IND_NULL;
        else
          *(int *)dat = INTEGER(elem)[i];
      } 
      else if (TYPEOF(elem) == LGLSXP) 
      {
        if (LOGICAL(elem)[i] == NA_LOGICAL)
          *ind = OCI_IND_NULL;
        else
          *(int *)dat = LOGICAL(elem)[i];
      }
      else if ((TYPEOF(elem) == STRSXP) ||
               ((TYPEOF(elem) == VECSXP) &&
                (TYPEOF(VECTOR_ELT(elem, i)) == STRSXP))) 
      {
        if (STRING_ELT(elem, i) == NA_STRING)
          *ind = OCI_IND_NULL;
        else
        {
          const char *str = CHAR(STRING_ELT(elem, i));
          size_t      len = (sb4)strlen(str);

          RODBI_GET_FORM_OF_USE(&form_of_use, elem, i, free_res);

          if (res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType == SQLT_LVC)
          {
            rodbild    *pdat = (rodbild *)dat;
            pdat->len_rodbild = len;
            memcpy(pdat->dat_rodbild, str, len);
          }
          else
          if ((res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType == SQLT_CLOB) ||
              (res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType == SQLT_BLOB) ||
              (res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType == SQLT_BFILE))
          {
            if (len == 0)
            *ind = OCI_IND_NULL;
            else
            {
              OCILobCreateTemporary(res->res_rodbiRes.con_roociRes->svc_roociCon,
                                    res->res_rodbiRes.con_roociRes->err_roociCon,
                                         *(OCILobLocator **)dat,
                                         (ub2)OCI_DEFAULT,
                                         form_of_use,
                                         OCI_TEMP_CLOB, FALSE,
                                         OCI_DURATION_SESSION);

              RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                              roociWriteLOBData(&(res->res_rodbiRes),
                              *(OCILobLocator **)dat, (const oratext *)str, len,
                                form_of_use));
            }
          }
          else
          {
            memcpy(dat, str, len);
            dat[len] = (ub1)0;
          }

        }
      } 
      else if ((TYPEOF(elem) == VECSXP) &&
               (TYPEOF(VECTOR_ELT(elem, i)) == RAWSXP))
      {
        SEXP  x = VECTOR_ELT(elem, i);

        if (isNull(x))
          *ind = OCI_IND_NULL;
        else
        {
          int      len = LENGTH(x);

          if (res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType == SQLT_LVB)
          {
            rodbild *pdat = (rodbild *)dat;
            pdat->len_rodbild = len;
            memcpy((ub1 *)&pdat->dat_rodbild[0], RAW(x), len);
          }
          else
          if ((res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType == SQLT_BLOB) ||
              (res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType == SQLT_BFILE))
          {
            if (len == 0)
            *ind = OCI_IND_NULL;
            else
            {
            OCILobCreateTemporary(res->res_rodbiRes.con_roociRes->svc_roociCon,
                                  res->res_rodbiRes.con_roociRes->err_roociCon,
                                         *(OCILobLocator **)dat,
                                         (ub2)OCI_DEFAULT,
                                         form_of_use,
                                         OCI_TEMP_BLOB, FALSE,
                                         OCI_DURATION_SESSION);

            RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                            roociWriteBLOBData(&(res->res_rodbiRes),
                              *(OCILobLocator **)dat, (const ub1 *)RAW(x), len,
                              res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType,
                              form_of_use));
            }
          }
          else
          {
            *alen = (ub2)len;
            memcpy(dat, RAW(x), len);
          }
        }
      }


      /* next row */
      dat += (res->res_rodbiRes).bsiz_roociRes[bid];
      ind++;
      alen++;
    }

    /* bind data buffers */
    RODBI_CHECK_RES(res, __func__, __LINE__, free_res,
                    roociBindData(&(res->res_rodbiRes), (ub4)(bid+1), 
                      form_of_use,
                      res->res_rodbiRes.btyp_roociRes[bid].bndnm_roociColType));

  }
} /* end rodbiResBindCopy */

/* ----------------------------- rodbiResAlloc ---------------------------- */

static void rodbiResAlloc(rodbiRes *res, int nrow)
{
  int            ncol = (res->res_rodbiRes).ncol_roociRes;
  ub4            len;
  oratext       *buf;
  int            cid;

  /* allocates column list and names vector */
  PROTECT(res->list_rodbiRes = allocVector(VECSXP, ncol));
  PROTECT(res->name_rodbiRes = allocVector(STRSXP, ncol));

  /* allocate column vectors */
  for (cid = 0; cid < ncol; cid++)
  {
    /* allocate column vector */
    SET_VECTOR_ELT(res->list_rodbiRes, cid, allocVector(
        RODBI_TYPE_SXP((res->res_rodbiRes).typ_roociRes[cid].typ_roociColType),
        nrow));

    /* get column name & parameters */
    RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                    roociGetColProperties(&(res->res_rodbiRes), 
                                          (ub4)(cid+1), &len, &buf));

    /* set column name */
    SET_STRING_ELT(res->name_rodbiRes, cid,
                   mkCharLen((const char *)buf, (int)len));
  }

  /* set names attribute */
  setAttrib(res->list_rodbiRes, R_NamesSymbol, res->name_rodbiRes);

  /* set the state */
  if (!res->pghdl_rodbiRes)
  {
    res->nrow_rodbiRes = nrow;
    res->rows_rodbiRes = 0;
  }

} /* end rodbiResAlloc */

/* ---------------------------- rodbiResExpand ---------------------------- */

static void rodbiResExpand(rodbiRes *res)
{
  int nrow = res->rows_rodbiRes + res->fchNum_rodbiRes - res->fchBeg_rodbiRes;
  int ncol = (res->res_rodbiRes).ncol_roociRes;
  int cid;

  if (!(res->expand_rodbiRes) || (res->nrow_rodbiRes > nrow) || (nrow == 0))
    return;

  /* compute new size */
  while (res->nrow_rodbiRes <= nrow)
    res->nrow_rodbiRes *= 2;

  if (!res->pghdl_rodbiRes)
  {
    /* expand column vectors */
    for (cid = 0; cid < ncol; cid++)
    {
      SEXP vec = VECTOR_ELT(res->list_rodbiRes, cid);
      vec = lengthgets(vec, res->nrow_rodbiRes);
      SET_VECTOR_ELT(res->list_rodbiRes, cid, vec);          /* protects vec */
    }
  }
} /* end rodbiResExpand */

/* ----------------------------- rodbiResSplit ---------------------------- */

static void rodbiResSplit(rodbiRes *res)
{
  int fchEnd;

  /* set position after the end of the chunk */
  fchEnd = res->fchBeg_rodbiRes + res->nrow_rodbiRes - res->rows_rodbiRes;

  /* adjust based on the buffer size */
  if (fchEnd > res->fchNum_rodbiRes)
    res->fchEnd_rodbiRes = res->fchNum_rodbiRes;
  else
    res->fchEnd_rodbiRes = fchEnd;
} /* end rodbiResSplit */

/* ----------------------------- rodbiResAccum ---------------------------- */

static void rodbiResAccum(rodbiRes *res)
{
  SEXP        list = res->list_rodbiRes;
  int         rows = res->rows_rodbiRes;
  int         fbeg = res->fchBeg_rodbiRes;
  int         fend = res->fchEnd_rodbiRes;
  int         lob_len;
  int         fcur;
  int         lcur;
  int         cid  = 0;
  double      tstm;
  char       *tempbuf= (char *)0;
  size_t      tempbuflen = 0;
#ifdef DEBUG
      printf("rodbiResAccum: rows=%d fbeg=%d fend=%d\n",
             rows, fbeg, fend);
#endif
  /* accumulate data */
  for (cid = 0; cid < (res->res_rodbiRes).ncol_roociRes; cid++)
  {
    ub1  *dat = (ub1 *)(res->res_rodbiRes).dat_roociRes[cid]  +
                       (fbeg * (res->res_rodbiRes).siz_roociRes[cid]);
    SEXP       vec = VECTOR_ELT(list, cid);
    cetype_t   enc;
    ub1        rtyp = RODBI_TYPE_R((res->res_rodbiRes).typ_roociRes[cid].typ_roociColType);
    ub2        etyp = res->res_rodbiRes.typ_roociRes[cid].extyp_roociColType;


    if (res->res_rodbiRes.form_roociRes[cid] == SQLCS_NCHAR)
    {
      if (res->con_rodbiRes->drv_rodbiCon->unicode_as_utf8)
        enc = CE_UTF8;
      else
        enc = CE_NATIVE;
    }
    else
      enc = CE_NATIVE;

    for (fcur = fbeg, lcur = rows; fcur < fend; fcur++, lcur++)
    {
      /* copy data */
      if ((res->res_rodbiRes).ind_roociRes[cid][fcur] == OCI_IND_NULL)
      {
        switch(rtyp)
        {
        case RODBI_R_INT:
          INTEGER(vec)[lcur] = NA_INTEGER;
          break;

        case RODBI_R_LOG:
          INTEGER(vec)[lcur] = NA_LOGICAL;
          break;

        case RODBI_R_NUM:
        case RODBI_R_DIF:
        case RODBI_R_DAT:
          REAL(vec)[lcur] = NA_REAL;
          break;

        case RODBI_R_CHR:
          SET_STRING_ELT(vec, lcur, NA_STRING);
          break;

        case RODBI_R_RAW:
          {
            int  len = 0;
            SEXP rawVec;

            PROTECT(rawVec = NEW_RAW(len));
            SET_VECTOR_ELT(vec, lcur, rawVec);
            UNPROTECT(1);
          }
          break;

        case RODBI_R_LST:
          {
            SEXP Vec;
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
            if (etyp == SQLT_VEC)
            {
              roociCtx  *pctx = &res->con_rodbiRes->drv_rodbiCon->ctx_rodbiDrv;
              if (RODBI_CHECK_VERSION(pctx))
                RODBI_WARN_VERSION_MISMATCH(pctx);
              else
              {
                PROTECT(Vec = NEW_LIST(0));
                SET_VECTOR_ELT(vec, lcur, Vec);
                UNPROTECT(1);
              }
            }
            else
#endif /* OCI_MAJOR_VERSION >= 23 */
            {
              SET_STRING_ELT(vec, lcur, mkChar("data.frame"));
              if (res->res_rodbiRes.typ_roociRes[cid].obtyp_roociColType.otc_roociObjType ==
                  OCI_TYPECODE_NAMEDCOLLECTION)
              {
                PROTECT(Vec = NEW_LIST(0));
                SET_VECTOR_ELT(vec, lcur, Vec);
                UNPROTECT(1);
              }
              else
              if (res->res_rodbiRes.typ_roociRes[cid].obtyp_roociColType.otc_roociObjType ==
                  OCI_TYPECODE_OBJECT)
              {
                PROTECT(Vec = NEW_LIST(0));
                SET_VECTOR_ELT(vec, lcur, Vec);
                UNPROTECT(1);
              }
              else
                RODBI_FATAL(__func__, 1, rtyp);
            }
          }
          break;

        default:
          RODBI_FATAL(__func__, 2, rtyp);
          break;
        }
      }
      else                                                      /* NOT NULL */
      {
        switch (etyp)
        {
        case SQLT_INT:
          INTEGER(vec)[lcur] = *(int *)dat;
          break;

        case SQLT_BDOUBLE:
        case SQLT_FLT:
          REAL(vec)[lcur] = *(double *)dat;
          break;

        case SQLT_STR:
          if ((res->con_rodbiRes->con_rodbiCon.timesten_rociCon) &&
              (enc == CE_UTF8))
          {
            RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
              rodbiTTConvertUCS2UTF8Data(&(res->res_rodbiRes),
                          (const ub2 *)dat,
                          (size_t)(res->res_rodbiRes.len_roociRes[cid][fcur]),
                          &tempbuf, &tempbuflen));

            SET_STRING_ELT(vec, lcur,
                           Rf_mkCharLenCE((char *)tempbuf, tempbuflen, enc));
          }
          else
            SET_STRING_ELT(vec, lcur,
                           Rf_mkCharLenCE((char *)dat,
                           (res->res_rodbiRes).len_roociRes[cid][fcur], enc));
          break;

        case SQLT_BIN:
          {
            int  len = (int)((res->res_rodbiRes).len_roociRes[cid][fcur]);
            SEXP rawVec;
            Rbyte *b;

            PROTECT(rawVec = NEW_RAW(len));
            b = RAW(rawVec);
            memcpy((void *)b, (void *)dat, len);
            SET_VECTOR_ELT(vec,  lcur, rawVec);
            UNPROTECT(1);
          }
          break;

        case SQLT_CLOB:
          {
            OCILobLocator *lob_loc =
              *(OCILobLocator **)((ub1 *)res->res_rodbiRes.dat_roociRes[cid] +
                                 (fcur * res->res_rodbiRes.siz_roociRes[cid]));

            /* read LOB data */
            RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                            roociReadLOBData(&(res->res_rodbiRes),
                                        lob_loc, &lob_len,
                                        res->res_rodbiRes.form_roociRes[cid]));

            if ((res->con_rodbiRes->con_rodbiCon.timesten_rociCon) &&
                (enc == CE_UTF8))
            {
              RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                rodbiTTConvertUCS2UTF8Data(&(res->res_rodbiRes),
                            (const ub2 *)res->res_rodbiRes.lobbuf_roociRes,
                            (size_t)(lob_len),
                            &tempbuf, &tempbuflen));

              SET_STRING_ELT(vec, lcur,
                             Rf_mkCharLenCE((char *)tempbuf, tempbuflen, enc));
            }
            else
              /* make character element */
              SET_STRING_ELT(vec, lcur, mkCharLenCE((const char *)
                         ((res->res_rodbiRes).lobbuf_roociRes), lob_len, enc));
          }
          break;

        case SQLT_BLOB:
        case SQLT_BFILE:
          {
            SEXP rawVec;
            Rbyte *b;

            OCILobLocator *lob_loc =
              *(OCILobLocator **)((ub1 *)res->res_rodbiRes.dat_roociRes[cid] +
                                  (fcur * res->res_rodbiRes.siz_roociRes[cid]));

            /* read LOB data */
            RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                  roociReadBLOBData(&(res->res_rodbiRes), lob_loc, &lob_len,
                      res->res_rodbiRes.form_roociRes[cid],
                      res->res_rodbiRes.typ_roociRes[cid].extyp_roociColType));

            PROTECT(rawVec = NEW_RAW(lob_len));
            b = RAW(rawVec);
            memcpy((void *)b, (void *)res->res_rodbiRes.lobbuf_roociRes,
                   lob_len);
            SET_VECTOR_ELT(vec,  lcur, rawVec);
            UNPROTECT(1);
          }
          break;

        case SQLT_TIMESTAMP:
        case SQLT_TIMESTAMP_LTZ:
          RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
             roociReadDateTimeData(&(res->res_rodbiRes),
                                   *(OCIDateTime **)dat, &tstm,
                 (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_DATE) ? 1 : 0));
          REAL(vec)[lcur] = tstm;
          break;

        case SQLT_INTERVAL_DS:
          RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
               roociReadDiffTimeData(&(res->res_rodbiRes),
                                     *(OCIInterval **)dat, &tstm));
          REAL(vec)[lcur] = tstm;
          break;

        case SQLT_NTY:
        case SQLT_REF:
          {
            SEXP  Vec;
            RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                roociReadUDTData(&(res->res_rodbiRes),
                            &((res->res_rodbiRes).typ_roociRes[cid]),
                            (roociObjType *)0, *(void **)dat, (void *)0,
                            &Vec, enc,
                            res->con_rodbiRes->drv_rodbiCon->unicode_as_utf8));
            SET_VECTOR_ELT(vec, lcur, Vec);
          }
          break;

#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
        case SQLT_VEC:
          {
            SEXP vecVec;
            roociCtx  *pctx = &res->con_rodbiRes->drv_rodbiCon->ctx_rodbiDrv;
            if (RODBI_CHECK_VERSION(pctx))
              RODBI_WARN_VERSION_MISMATCH(pctx);
            else
            {
              OCIVector *vecdp =
                *(OCIVector **)((ub1 *)res->res_rodbiRes.dat_roociRes[cid] +
                                    (fcur * res->res_rodbiRes.siz_roociRes[cid]));

              /* read LOB data */
              RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                  roociReadVectorData(&(res->res_rodbiRes), vecdp, &vecVec,
                       res->con_rodbiRes->drv_rodbiCon->unicode_as_utf8, cid, FALSE));

              SET_VECTOR_ELT(vec, lcur, vecVec);
            }
          }
          break;
#endif

        default:
          RODBI_FATAL(__func__, 10, etyp);
          break;
        }
      }
      /* next row */
      dat += (res->res_rodbiRes).siz_roociRes[cid];
    }
  }

  if (tempbuf)
    ROOCI_MEM_FREE(tempbuf);

  /* set state */
  res->rows_rodbiRes  += res->fchEnd_rodbiRes - res->fchBeg_rodbiRes;
  res->fchBeg_rodbiRes = res->fchEnd_rodbiRes;
} /* end rodbiResAccum */

/* --------------------------- rodbiResAccumInCache ------------------------ */

static void rodbiResAccumInCache(rodbiRes *res)
{
  int         rows = res->rows_rodbiRes;
  int         fbeg = res->fchBeg_rodbiRes;
  int         fend = res->fchEnd_rodbiRes;
  int         fcur;
  int         lcur;
  int         cid  = 0;
  double      tstm;

  /* accumulate data */
  for (cid = 0; cid < (res->res_rodbiRes).ncol_roociRes; cid++)
  {
    ub1  *dat = (ub1 *)(res->res_rodbiRes).dat_roociRes[cid]  +
                       (fbeg * (res->res_rodbiRes).siz_roociRes[cid]);
    rodbichdl *hdl = (rodbichdl *)0;
    ub1        rtyp = RODBI_TYPE_R((res->res_rodbiRes).typ_roociRes[cid].typ_roociColType);
    ub2        etyp = res->res_rodbiRes.typ_roociRes[cid].extyp_roociColType;

    if (res->pghdl_rodbiRes)
    {
       hdl = &res->pghdl_rodbiRes[cid];

      if (!hdl->begpg_rodbichdl)
        RODBI_CREATE_COL_HDL(hdl, RODBI_MAX_VAR_PAGE_SIZE);
    }

    for (fcur = fbeg, lcur = rows; fcur < fend; fcur++, lcur++)
    {
      /* copy data */
      if ((res->res_rodbiRes).ind_roociRes[cid][fcur] == OCI_IND_NULL)
      {
        switch(rtyp)
        {
        case RODBI_R_INT:
          RODBI_ADD_FIXED_DATA_ITEM(hdl, int, NA_INTEGER);
          break;

        case RODBI_R_LOG:
          RODBI_ADD_FIXED_DATA_ITEM(hdl, int, NA_LOGICAL);
          break;

        case RODBI_R_NUM:
        case RODBI_R_DAT:
        case RODBI_R_DIF:
          RODBI_ADD_FIXED_DATA_ITEM(hdl, double, NA_REAL);
          break;

        case RODBI_R_CHR:
        case RODBI_R_RAW:
          RODBI_ADD_VAR_DATA_ITEM(hdl, RODBI_VCOL_FLG_NULL, (void *)0, 0);
          break;

        default:
          RODBI_FATAL(__func__, 1, rtyp);
          break;
        }
      }
      else                                                      /* NOT NULL */
      {
        switch (etyp)
        {
        case SQLT_INT:
          RODBI_ADD_FIXED_DATA_ITEM(hdl, int, *(int *)dat);
          break;

        case SQLT_BDOUBLE:
        case SQLT_FLT:
          RODBI_ADD_FIXED_DATA_ITEM(hdl, double, *(double *)dat);
          break;

        case SQLT_STR:
        case SQLT_BIN:
          RODBI_ADD_VAR_DATA_ITEM(hdl, RODBI_VCOL_FLG_NOTNULL, (void *)dat,
                                  res->res_rodbiRes.len_roociRes[cid][fcur]);
          break;

        case SQLT_CLOB:
        case SQLT_BLOB:
        case SQLT_BFILE:
          RODBI_FATAL(__func__, 2, etyp);
          break;

        case SQLT_TIMESTAMP:
        case SQLT_TIMESTAMP_LTZ:
          RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
             roociReadDateTimeData(&(res->res_rodbiRes),
                                   *(OCIDateTime **)dat, &tstm,
                 (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_DATE) ? 1 : 0));
          RODBI_ADD_FIXED_DATA_ITEM(hdl, double, tstm);
          break;

        case SQLT_INTERVAL_DS:
          RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
               roociReadDiffTimeData(&(res->res_rodbiRes),
                                     *(OCIInterval **)dat, &tstm));
          RODBI_ADD_FIXED_DATA_ITEM(hdl, double, tstm);
          break;

        default:
          RODBI_FATAL(__func__, 3, etyp);
          break;
        }
      }
      /* next row */
      dat += (res->res_rodbiRes).siz_roociRes[cid];
    }
  }

  /* set state */
  res->rows_rodbiRes  += res->fchEnd_rodbiRes - res->fchBeg_rodbiRes;
  res->fchBeg_rodbiRes = res->fchEnd_rodbiRes;
} /* end rodbiResAccumInCache */


/* ----------------------------- rodbiResTrim ----------------------------- */

static void rodbiResTrim(rodbiRes *res)
{
  int  cid;

  /* nothing to trim */
  if (res->rows_rodbiRes == res->nrow_rodbiRes)
    return;

  if (!res->pghdl_rodbiRes)
  {
    /* trim column vectors to the actual size */
    for (cid = 0; cid < (res->res_rodbiRes).ncol_roociRes; cid++)
    {
      SEXP vec = VECTOR_ELT(res->list_rodbiRes, cid);
      vec = lengthgets(vec, res->rows_rodbiRes);
      SET_VECTOR_ELT(res->list_rodbiRes, cid, vec);          /* protects vec */
    }
  }
} /* end rodbiResTrim */

/* ---------------------------- rodbiResPopulate --------------------------- */

static void rodbiResPopulate(rodbiRes *res)
{
  SEXP        list = res->list_rodbiRes;
  int         lcur;
  int         cid  = 0;
  ub1        *conv_buf = (ub1 *)0;
  int         conv_buf_len = 0;
  char       *tempbuf= (char *)0;
  size_t      tempbuflen = 0;

  /* populate data in R from cache */
  for (cid = 0; cid < res->res_rodbiRes.ncol_roociRes; cid++)
  {
    rodbichdl *hdl  = &res->pghdl_rodbiRes[cid];
    SEXP       vec  = VECTOR_ELT(list, cid);
    ub1        rtyp = RODBI_TYPE_R(res->res_rodbiRes.typ_roociRes[cid].typ_roociColType);
    ub2        etyp = res->res_rodbiRes.typ_roociRes[cid].extyp_roociColType;
    cetype_t   enc;

    RODBI_REPOSITION_COL_HDL(hdl);

    if (res->res_rodbiRes.form_roociRes[cid] == SQLCS_NCHAR)
    {
      if (res->con_rodbiRes->drv_rodbiCon->unicode_as_utf8)
        enc = CE_UTF8;
      else
        enc = CE_NATIVE;
    }
    else
      enc = CE_NATIVE;

    if ((rtyp == RODBI_R_CHR) ||
        (rtyp == RODBI_R_DAT) ||
        (rtyp == RODBI_R_RAW))
    {
      int tmplen;
      RODBI_GET_MAX_VAR_ITEM_LEN(hdl, &tmplen);

      if (tmplen > conv_buf_len)
       {
         if (conv_buf)
           ROOCI_MEM_FREE(conv_buf);

         conv_buf_len = tmplen;
         ROOCI_MEM_MALLOC(conv_buf, conv_buf_len, sizeof(ub1));
         if (!conv_buf)
           RODBI_ERROR(RODBI_ERR_MEMORY_ALC);
       }
    }

    for (lcur = 0; lcur < res->rows_rodbiRes; lcur++)
    {
      /* copy data */
      switch (etyp)
      {
        case SQLT_INT:
          RODBI_GET_FIXED_DATA_ITEM(hdl, int, &(INTEGER(vec)[lcur]), res);
          break;

        case SQLT_BDOUBLE:
        case SQLT_FLT:
        case SQLT_TIMESTAMP:
        case SQLT_TIMESTAMP_LTZ:
        case SQLT_INTERVAL_DS:
            RODBI_GET_FIXED_DATA_ITEM(hdl, double, &REAL(vec)[lcur], res);
          break;

        case SQLT_STR:
          {
            ub1     *data;
            int      len;

            RODBI_GET_VAR_DATA_ITEM_BY_REF(hdl, (void **)&data, &len, res);
            if (len == RODBI_VCOL_NULL)
              SET_STRING_ELT(vec, lcur, NA_STRING);
            else if (len == RODBI_VCOL_NO_REF)
            {
              len = RODBI_GET_VAR_DATA_ITEM(hdl,(void *)conv_buf,conv_buf_len);

              if ((res->con_rodbiRes->con_rodbiCon.timesten_rociCon) &&
                  (enc == CE_UTF8))
              {
                RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                  rodbiTTConvertUCS2UTF8Data(&(res->res_rodbiRes),
                                             (const ub2 *)conv_buf,
                                             (size_t)(len), &tempbuf,
                                             &tempbuflen));

                SET_STRING_ELT(vec, lcur,
                             Rf_mkCharLenCE((char *)tempbuf, tempbuflen, enc));
              }
              else
                SET_STRING_ELT(vec, lcur,
                               Rf_mkCharLenCE((char *)conv_buf, len, enc));
            }
            else
            {
              if ((res->con_rodbiRes->con_rodbiCon.timesten_rociCon) &&
                  (enc == CE_UTF8))
              {
                RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                  rodbiTTConvertUCS2UTF8Data(&(res->res_rodbiRes),
                                             (const ub2 *)data,
                                             (size_t)(len), &tempbuf,
                                             &tempbuflen));

                SET_STRING_ELT(vec, lcur,
                             Rf_mkCharLenCE((char *)tempbuf,tempbuflen,enc));
              }
              else
                SET_STRING_ELT(vec,lcur,Rf_mkCharLenCE((char *)data,len,enc));
            }
          }
          break;

        case SQLT_BIN:
          {
            SEXP   rawVec;
            Rbyte *b;
            ub1   *data;
            int    len;

            RODBI_GET_VAR_DATA_ITEM_BY_REF(hdl, (void **)&data, &len, res);
            if (len == RODBI_VCOL_NULL)
            {
              int  len = 0;
              SEXP rawVec;

              PROTECT(rawVec = NEW_RAW(len));
              SET_VECTOR_ELT(vec,  lcur, rawVec);
              UNPROTECT(1);
            }
            else if (len == RODBI_VCOL_NO_REF)
            {
              len = RODBI_GET_VAR_DATA_ITEM(hdl,(void *)conv_buf,conv_buf_len);

              PROTECT(rawVec = NEW_RAW(len));
              b = RAW(rawVec);
              memcpy((void *)b, (void *)conv_buf, len);
              SET_VECTOR_ELT(vec,  lcur, rawVec);
              UNPROTECT(1);
            }
            else
            {
              PROTECT(rawVec = NEW_RAW(len));
              b = RAW(rawVec);
              memcpy((void *)b, (void *)data, len);
              SET_VECTOR_ELT(vec,  lcur, rawVec);
              UNPROTECT(1);
            }
          }
          break;

        case SQLT_CLOB:
        case SQLT_BLOB:
        case SQLT_BFILE:
          RODBI_FATAL(__func__, 3, etyp);
          break;

        default:
          RODBI_FATAL(__func__, 4, etyp);
          break;
      }
    }

    /* next column */
    RODBI_DESTROY_COL_HDL(hdl);
  }

  if (conv_buf)
    ROOCI_MEM_FREE(conv_buf);

  if (tempbuf)
    ROOCI_MEM_FREE(tempbuf);

} /* end rodbiResPopulate */

/* -------------------------- rodbiResDataFrame --------------------------- */

static void rodbiResDataFrame(rodbiRes *res)
{
  SEXP  row_names;
  SEXP  cla; 
  int   ncol = (res->res_rodbiRes).ncol_roociRes;
  int   cid;

  if (res->pghdl_rodbiRes)
  {
    /* allocate output data frame */
    rodbiResAlloc(res, res->rows_rodbiRes);

    /* copy data from cache to vectors */
    rodbiResPopulate(res);
  }

  /* make datetime columns a POSIXct */
  for (cid = 0; cid < ncol; cid++)
  {
    if (RODBI_TYPE_R((res->res_rodbiRes).typ_roociRes[cid].typ_roociColType) == RODBI_R_DAT)
    {
      PROTECT(cla = allocVector(STRSXP, 2)); 
      SET_STRING_ELT(cla, 0, mkChar(RODBI_R_DAT_NM));
      SET_STRING_ELT(cla, 1, mkChar("POSIXt"));
      setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), R_ClassSymbol, cla);
      UNPROTECT(1);
    }
    else if (RODBI_TYPE_R((res->res_rodbiRes).typ_roociRes[cid].typ_roociColType) ==
             RODBI_R_DIF)
    {
      setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("units"),
                ScalarString(mkChar("secs")));
      setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), R_ClassSymbol,
                ScalarString(mkChar(RODBI_R_DIF_NM)));
    }

    if (res->con_rodbiRes->drv_rodbiCon->ora_attributes)
    {
      if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_NCHAR ||
          res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_NVARCHAR2)
      {
        ub4  siz;
        RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                       roociDescCol(&(res->res_rodbiRes), (ub4)(cid+1), NULL,
                                    NULL, NULL, &siz, NULL, NULL, NULL, NULL));

        setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.encoding"),
                  ScalarString(mkChar("UTF-8")));
        siz /= 2;
        setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.maxlength"),
                  ScalarInteger(siz));

        if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_NCHAR)
          setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.type"),
                  ScalarString(mkChar("char")));
      }
      else
      {
        if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_CHAR)
        {
          ub4  siz;
          RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                          roociDescCol(&(res->res_rodbiRes), 
                                       (ub4)(cid+1), NULL, NULL, NULL, 
                                       &siz, NULL, NULL, NULL, NULL));
          setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.type"),
                  ScalarString(mkChar("char")));
          setAttrib(VECTOR_ELT(res->list_rodbiRes, cid),
                    install("ora.maxlength"), ScalarInteger(siz));
        }
        else if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_VARCHAR2)
        {
          ub4  siz;
          RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                          roociDescCol(&(res->res_rodbiRes), 
                                       (ub4)(cid+1), NULL, NULL, NULL, 
                                       &siz, NULL, NULL, NULL, NULL));
          setAttrib(VECTOR_ELT(res->list_rodbiRes, cid),
                    install("ora.maxlength"), ScalarInteger(siz));
        }
        else if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_NCLOB)
        {
          setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.type"),
                    ScalarString(mkChar("clob")));
          setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.encoding"),
                    ScalarString(mkChar("UTF-8")));
        }
        else if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_CLOB)
        {
          setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.type"),
                    ScalarString(mkChar("clob")));
        }
        else if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_BLOB)
        {
          setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.type"),
                    ScalarString(mkChar("blob")));
        }
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
        else if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_VEC)
        {
          char vfmt[64] = {0};
          ub4 maxlength;
          
          setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.type"),
                    ScalarString(mkChar("vector")));

          if (res->res_rodbiRes.typ_roociRes[cid].vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_FLEX)
          {
            setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.maxlength"),
                      ScalarString(mkChar("*")));
          }
          else if(res->res_rodbiRes.typ_roociRes[cid].vdim_roociColType)
          {         
            maxlength = res->res_rodbiRes.typ_roociRes[cid].vdim_roociColType; 
            setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.maxlength"),
                      ScalarInteger(maxlength));
          }

#ifdef OCI_ATTR_VECTOR_FORMAT_BINARY
          if (res->res_rodbiRes.typ_roociRes[cid].vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_BINARY)
            snprintf(vfmt,sizeof(vfmt), "binary");
          else
#endif
            RODBI_SET_VECTOR_FORMAT(res->res_rodbiRes.typ_roociRes[cid].vfmt_roociColType, vfmt);

          setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.format"),
                    ScalarString(mkChar(vfmt)));
        }
#endif
        else if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_BFILE)
        {
          setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.type"),
                    ScalarString(mkChar("bfile")));
        }
        else if ((res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_UDT) ||
                 (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_REF))
        {
          setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), install("ora.type"),
              ScalarString(Rf_mkCharLen(
                    (const char *)res->res_rodbiRes.typ_roociRes[cid].obtyp_roociColType.name_roociObjType,
                    res->res_rodbiRes.typ_roociRes[cid].obtyp_roociColType.namsz_roociObjType)));
        }
      }
    }
  }

  /* make input data list a data.frame */
  PROTECT(row_names     = allocVector(INTSXP, 2));
  INTEGER(row_names)[0] = NA_INTEGER;
  INTEGER(row_names)[1] = - LENGTH(VECTOR_ELT(res->list_rodbiRes, 0));
  setAttrib(res->list_rodbiRes, R_RowNamesSymbol, row_names);
  setAttrib(res->list_rodbiRes, R_ClassSymbol, mkString("data.frame"));
  UNPROTECT(1);
} /* end rodbiResDataFrame */

/* -------------------------- rodbiPlsqlResPopulate ----------------------- */

static void rodbiPlsqlResPopulate(rodbiRes *res, ub4 *flip)
{
 /* check if already called once */
 if (!*flip)
 {
  /* if cursor is present, add data frame fetched from cursor to output list */
  if (res->res_rodbiRes.stm_cur_roociRes)
  {
    int cid;
    /* use flag to handle case (Cursor OUT, Simple OUT) */
    boolean flag = FALSE; 
    /* use static variable to keep cursor count */
    static int CursorCount = 1;
    for (cid = 0; cid < res->numOut; cid++)
    {
      /* add dataframe fetched by cursor handle to NULL places in output list */
      if (isNull(VECTOR_ELT(res->list, cid)))
      {
        if (!flag)
        {
          SET_VECTOR_ELT(res->list, cid, res->list_rodbiRes);
          UNPROTECT(2);
          flag = TRUE;
        }
        else
          break;
      }
    }
    /* check if more cursors are present */
    if (cid < res->numOut)
    {
      /* set state to REFETCH to fetch for next cursor */
      res->state_rodbiRes = REFETCH_rodbiState;

      /* free result set of old cursor statement handle */
      RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                      roociResFree(&(res->res_rodbiRes)));

      /* Using current value of static variable(CursorCount) move cursor 
       * statement handle buffer to next position */
      *res->res_rodbiRes.stm_cur_roociRes =
                              res->res_rodbiRes.stm_cur_roociRes[CursorCount++];

      /* define data for new cursor statement handle */
      RODBI_CHECK_RES(res, __func__, __LINE__, TRUE,
                      roociResDefine(&res->res_rodbiRes));
    }
    else 
    {
      /* reset static variable for new call */
      CursorCount = 1;
    }
  }
 }
 else
 {
  /* variables declared/defined for R bind data frame */
  int    bid;
  int    i;
  /* variables declared/defined for output list that needs to be returned */
  int    cid = 0;
  int    ncol = 0;
  int    j; 
  int    lob_len;
  char  *tempbuf= (char *)0;
  size_t tempbuflen = 0;
  SEXP   list;
  SEXP   row_names;
  SEXP   cla;

  ncol = res->numOut;

  /* allocate column list and names vector based on PLSQL OUT/IN OUT count */
  PROTECT(res->list = allocVector(VECSXP, ncol));
  PROTECT(res->name = allocVector(STRSXP, ncol));

  /*  allocate column vectors based on bind buffer type (btyp_roociRes) */ 
  for(bid =0, cid = 0; bid < (res->res_rodbiRes).bcnt_roociRes; bid++)
  {
    char *name = (res->res_rodbiRes).param_name_roociRes[bid];
    /* check if OUT/IN OUT case */
    if (res->mode_rodbiRes[bid] != IN_mode)
    {
      /* set column name -accept "" (empty string) cases */
      SET_STRING_ELT(res->name, cid, mkChar((const char *)name));

      switch (res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType)
      {
        case SQLT_INT:
          SET_VECTOR_ELT(res->list, cid, allocVector(INTSXP, 1));
          break;

#if (OCI_MAJOR_VERSION >= 12)
        case SQLT_BOL:
          SET_VECTOR_ELT(res->list, cid, allocVector(LGLSXP, 1));
          break;
#endif

        case SQLT_BDOUBLE:
        case SQLT_FLT:
        case SQLT_INTERVAL_DS:
        case SQLT_TIMESTAMP:
        case SQLT_TIMESTAMP_LTZ:
          SET_VECTOR_ELT(res->list, cid, allocVector(REALSXP, 1));
          break;

        case SQLT_STR:
        case SQLT_CLOB:
          SET_VECTOR_ELT(res->list, cid, allocVector(STRSXP, 1));
          break;

        case SQLT_BIN:
        case SQLT_BLOB:
        case SQLT_BFILE:
        case SQLT_RSET:
        case SQLT_NTY:
        case SQLT_REF:
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || \
    (OCI_MAJOR_VERSION > 23)
        case SQLT_VEC:        
#endif        
          SET_VECTOR_ELT(res->list, cid, allocVector(VECSXP, 1));
          break;

        default:
          RODBI_FATAL(__func__, 1,
                      (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType);
          break;
      }
      cid++;
    }
  }

  list = res->list;

  /* copy bind data to output list column vectors which is to be returned */
  for(bid =0, cid = 0; bid < (res->res_rodbiRes).bcnt_roociRes; bid++)
  {
    if (res->mode_rodbiRes[bid] != IN_mode)
    {
      ub1        *dat  = (ub1 *)(res->res_rodbiRes).bdat_roociRes[bid];
      SEXP        vec  = VECTOR_ELT(list, cid);
      double      tstm;
      cetype_t    enc;

      /* set encoding method */
      if (res->res_rodbiRes.bform_roociRes[cid] == SQLCS_NCHAR)
      {
        if (res->con_rodbiRes->drv_rodbiCon->unicode_as_utf8)
          enc = CE_UTF8;
        else
          enc = CE_NATIVE;
      }
      else
        enc = CE_NATIVE;

      for (i = 0, j = 0; i < 1; i++, j++)
      {
        switch (res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType)
        {
          case SQLT_INT:
            INTEGER(vec)[j] = *(int *)dat;
            break;
          case SQLT_BDOUBLE:
          case SQLT_FLT:
            REAL(vec)[j] = *(double *)dat;
            break;

          case SQLT_STR:
            {
              int len = strlen((char *)dat);
              if ((res->con_rodbiRes->con_rodbiCon.timesten_rociCon) &&
                  (enc == CE_UTF8))
              {
                RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                  rodbiTTConvertUCS2UTF8Data(&(res->res_rodbiRes),
                                             (const ub2 *)dat, len,
                                             &tempbuf, &tempbuflen));

                SET_STRING_ELT(vec, j, Rf_mkCharLenCE((char *)tempbuf,
                               tempbuflen, enc));
              }
              else
                SET_STRING_ELT(vec, j,
                               Rf_mkCharLenCE((char *)dat, len, enc));
            }
            break;

          case SQLT_BIN:
            {
              int  len = (int)((res->res_rodbiRes).bsiz_roociRes[bid]);
              SEXP rawVec;
              Rbyte *b;

              PROTECT(rawVec = NEW_RAW(len));
              b = RAW(rawVec);
              memcpy((void *)b, (void *)dat, len);
              SET_VECTOR_ELT(vec,  j, rawVec);
              UNPROTECT(1);
            }
            break;

          case SQLT_CLOB:
            {
              OCILobLocator *lob_loc;
              ub1            form;

              /*
               *  if Plsql scalar OUT is present, use bind data buffer
               *  (bdat_roociRes)
               */
              if (res->numOut)
              {
                lob_loc = 
                 *(OCILobLocator **)((ub1 *)res->res_rodbiRes.bdat_roociRes[bid]
                                  + (i * res->res_rodbiRes.bsiz_roociRes[bid]));
                /* read LOB data */
                /* if Plsql simple OUT/IN OUT is present, don't use field form_roociRes */
               form = res->res_rodbiRes.bform_roociRes[bid];
              }
              else
              {
                lob_loc = 
                 *(OCILobLocator **)((ub1 *)res->res_rodbiRes.dat_roociRes[bid]
                                  + (i * res->res_rodbiRes.siz_roociRes[bid]));
              
                /* read LOB data */
                /* if Plsql simple OUT/IN OUT is present, don't use field form_roociRes */
                form = res->res_rodbiRes.form_roociRes[bid];
              }

              /* read LOB data */
              RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                              roociReadLOBData(&(res->res_rodbiRes),
                                               lob_loc, &lob_len, form));

              if ((res->con_rodbiRes->con_rodbiCon.timesten_rociCon) &&
                  (enc == CE_UTF8))
              {
                RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                  rodbiTTConvertUCS2UTF8Data(&(res->res_rodbiRes),
                               (const ub2 *)res->res_rodbiRes.lobbuf_roociRes,
                               (size_t)(lob_len),
                               &tempbuf, &tempbuflen));

                SET_STRING_ELT(vec, j,
                            Rf_mkCharLenCE((char *)tempbuf, tempbuflen, enc));
              }
              /* make character element */
              SET_STRING_ELT(vec, j, mkCharLenCE((const char *)
                        ((res->res_rodbiRes).lobbuf_roociRes), lob_len, enc));
            }
            break;

#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
          case SQLT_VEC:
            {
              OCIVector *vecdp;
              SEXP       vecVec;
              roociCtx  *pctx = &res->con_rodbiRes->drv_rodbiCon->ctx_rodbiDrv;

              if (RODBI_CHECK_VERSION(pctx))
                RODBI_WARN_VERSION_MISMATCH(pctx);
              else
              {
                /*
                 *  if Plsql scalar OUT is present, use bind data buffer
                 *  (bdat_roociRes)
                 */
                if (res->numOut)
                  vecdp = 
                   *(OCIVector **)((ub1 *)res->res_rodbiRes.bdat_roociRes[bid]
                                   + (i * res->res_rodbiRes.bsiz_roociRes[bid]));
                else
                  vecdp = 
                   *(OCIVector **)((ub1 *)res->res_rodbiRes.dat_roociRes[bid]
                                   + (i * res->res_rodbiRes.siz_roociRes[bid]));
                /* read VECTOR data */
                RODBI_CHECK_RES(
                    res, __func__, __LINE__, FALSE,
                    roociReadVectorData(
                        &(res->res_rodbiRes), vecdp, &vecVec,
                        res->con_rodbiRes->drv_rodbiCon->unicode_as_utf8, bid,
                        res->numOut));
                SET_VECTOR_ELT(vec, j, vecVec);
              }
            }
            break;
#endif

          case SQLT_BLOB:
          case SQLT_BFILE:
            {
              SEXP           rawVec;
              Rbyte         *b;
              ub2            exttype;
              OCILobLocator *lob_loc;
              ub1            form;

              if (res->numOut)
              {
                /* Plsql scalar OUT present, use bind type btyp_roociRes */
                exttype =
                       res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType;

                /* Plsql scalar OUT present, use bind buffer bdat_roociRes */
                lob_loc = 
                 *(OCILobLocator **)((ub1 *)res->res_rodbiRes.bdat_roociRes[bid]
                                  + (i * res->res_rodbiRes.bsiz_roociRes[bid]));

                /* Plsql simple OUT is present, use bform_roociRes */
                form = res->res_rodbiRes.bform_roociRes[bid];
              }
              else
              {
                /* Plsql scalar OUT not present, use type typ_roociRes */
                exttype = 
                        res->res_rodbiRes.typ_roociRes[bid].extyp_roociColType;

                /* Plsql scalar OUT not present, use buffer dat_roociRes */
                lob_loc =
                 *(OCILobLocator **)((ub1 *)res->res_rodbiRes.dat_roociRes[bid]
                                   + (i * res->res_rodbiRes.siz_roociRes[bid]));
              
                /* Plsql simple IN/OUT is present, use form_roociRes */
                form = res->res_rodbiRes.form_roociRes[bid];
              }

              /* read LOB data */
              RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                  roociReadBLOBData(&(res->res_rodbiRes), lob_loc, &lob_len,
                                    form, exttype));

              PROTECT(rawVec = NEW_RAW(lob_len));
              b = RAW(rawVec);
              memcpy((void *)b, (void *)res->res_rodbiRes.lobbuf_roociRes,
                     lob_len);
              SET_VECTOR_ELT(vec, j, rawVec);
              UNPROTECT(1);
            }
            break;

          case SQLT_NTY:
          case SQLT_REF:
          {
            SEXP  Vec;
            void *obj;

            if (res->numOut)
            {
              /* Plsql scalar OUT is present, use bdat_roociRes */
              obj = *(void **)((ub1 *)res->res_rodbiRes.bdat_roociRes[bid] +
                               (i * res->res_rodbiRes.bsiz_roociRes[bid]));
            }
            else
            {
              /* if Plsql scalar OUT is not present, use buffer dat_roociRes */
              obj = *(void **)((ub1 *)res->res_rodbiRes.dat_roociRes[bid] +
                               (i * res->res_rodbiRes.siz_roociRes[bid]));
              
            }
            RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                roociReadUDTData(&(res->res_rodbiRes),
                            &((res->res_rodbiRes).btyp_roociRes[bid]),
                            (roociObjType *)0, obj, (void *)0,
                            &Vec, enc,
                            res->con_rodbiRes->drv_rodbiCon->unicode_as_utf8));
            SET_VECTOR_ELT(vec, j, Vec);
          }
          break;

          case SQLT_TIMESTAMP:
          case SQLT_TIMESTAMP_LTZ:
            RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                            roociReadDateTimeData(&(res->res_rodbiRes),
                            *(OCIDateTime **)dat, &tstm, 0));
            REAL(vec)[j] = tstm;
            break;

          case SQLT_INTERVAL_DS:
            RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                            roociReadDiffTimeData(&(res->res_rodbiRes),
                                               *(OCIInterval **)dat, &tstm));
            REAL(vec)[j] = tstm;
            break;

          case SQLT_RSET:
            SET_VECTOR_ELT(list, cid, R_NilValue);
            break;

          default:
            RODBI_FATAL(__func__, 8, 
                                      (res->res_rodbiRes).btyp_roociRes[bid].extyp_roociColType);
            break;
        }
      }
      cid++;
    }
  }

  /* set names attribute */
  setAttrib(res->list, R_NamesSymbol, res->name);

  for(bid = 0, cid = 0; bid < (res->res_rodbiRes).bcnt_roociRes; bid++)
  {
    if (res->mode_rodbiRes[bid] != IN_mode)
    {
      /* make datetime columns a POSIXct */
      if ((res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType == SQLT_TIMESTAMP) ||
          (res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType == SQLT_TIMESTAMP_LTZ))
      {
        PROTECT(cla = allocVector(STRSXP, 2));
        SET_STRING_ELT(cla, 0, mkChar(RODBI_R_DAT_NM));
        SET_STRING_ELT(cla, 1, mkChar("POSIXt"));
        setAttrib(VECTOR_ELT(res->list, cid), R_ClassSymbol, cla);
        UNPROTECT(1);
      }
      else if (res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType == SQLT_INTERVAL_DS)
      {
        setAttrib(VECTOR_ELT(res->list, cid), install("units"),

                  ScalarString(mkChar("secs")));
        setAttrib(VECTOR_ELT(res->list, cid), R_ClassSymbol,
                  ScalarString(mkChar(RODBI_R_DIF_NM)));
      }
      else if (res->con_rodbiRes->drv_rodbiCon->ora_attributes)
      {
        sb4 bind_length = 0;
        switch (res->res_rodbiRes.btyp_roociRes[bid].extyp_roociColType)
        {
          case SQLT_STR:
          {
            if (res->res_rodbiRes.bform_roociRes[cid] == SQLCS_NCHAR)
              setAttrib(VECTOR_ELT(res->list, cid), install("ora.encoding"),
                        ScalarString(mkChar("UTF-8")));
            bind_length = res->res_rodbiRes.bsiz_roociRes[bid];
            setAttrib(VECTOR_ELT(res->list, cid), install("ora.maxlength"),
                    ScalarInteger(bind_length));
            break;
          }
          case SQLT_CLOB:
          {
            if (res->res_rodbiRes.bform_roociRes[cid] == SQLCS_NCHAR)
              setAttrib(VECTOR_ELT(res->list, cid), install("ora.encoding"),
                        ScalarString(mkChar("UTF-8")));
            setAttrib(VECTOR_ELT(res->list, cid), install("ora.type"),
                      ScalarString(mkChar("clob")));
            break;
          }
          case SQLT_BLOB:
          {
            setAttrib(VECTOR_ELT(res->list, cid), install("ora.type"),
                      ScalarString(mkChar("blob")));
            break;
          }
          case SQLT_BFILE:
          {
            setAttrib(VECTOR_ELT(res->list, cid), install("ora.type"),
                      ScalarString(mkChar("bfile")));
            break;
          }

          case SQLT_NTY:
          case SQLT_REF:
          {
            roociColType *coltyp = &((res->res_rodbiRes).btyp_roociRes[bid]);
            roociObjType *objtyp = &(coltyp->obtyp_roociColType);
            roociColType *embcol = &objtyp->typ_roociObjType[bid];
            if ((((coltyp->obtyp_roociColType.otc_roociObjType ==
                                               OCI_TYPECODE_NAMEDCOLLECTION) ||
                  (coltyp->obtyp_roociColType.otc_roociObjType ==
                                               OCI_TYPECODE_VARRAY) ||
                  (coltyp->obtyp_roociColType.otc_roociObjType ==
                                                        OCI_TYPECODE_TABLE)) &&
                 embcol->obtyp_roociColType.nattr_roociObjType) &&
                 embcol->namsz_roociColType)
              setAttrib(VECTOR_ELT(res->list, cid), install("ora.type"),
                        ScalarString(
                          Rf_mkCharLen((const char *)embcol->name_roociColType,
                                       embcol->namsz_roociColType)));
            else if ((coltyp->obtyp_roociColType.otc_roociObjType ==
                                                        OCI_TYPECODE_OBJECT) &&
                     ((embcol->typ_roociColType == RODBI_UDT) ||
                      (embcol->typ_roociColType == RODBI_REF)))
              setAttrib(VECTOR_ELT(res->list, cid), install("ora.type"),
                 ScalarString(
                   Rf_mkCharLen(
                    (const char *)embcol->obtyp_roociColType.name_roociObjType,
                    embcol->obtyp_roociColType.namsz_roociObjType)));
          }
        }
      }
      cid++;
    }
  }

  if (!res->res_rodbiRes.stm_cur_roociRes)
  {
    /* make result set list a data.frame if cursor is not present */
    PROTECT(row_names     = allocVector(INTSXP, 2));
    INTEGER(row_names)[0] = NA_INTEGER;
    INTEGER(row_names)[1] = - LENGTH(VECTOR_ELT(res->list, 0));
    setAttrib(res->list, R_RowNamesSymbol, row_names);
    setAttrib(res->list, R_ClassSymbol, mkString("data.frame"));
    UNPROTECT(3);
  }
  else
    UNPROTECT(2);

  /* unset this flag so that it goes to other part of the function */
  *flip = 0;
 }
} /* end rodbiPlsqlResPopulate */

/* -------------------------- rodbiResStateNext --------------------------- */

static void rodbiResStateNext(rodbiRes *res)
{

  switch(res->state_rodbiRes)
  {
  case FETCH_rodbiState:
    res->state_rodbiRes = SPLIT_rodbiState;
    break;
  case SPLIT_rodbiState:
    res->state_rodbiRes = ACCUM_rodbiState;
    break;
  case ACCUM_rodbiState:
    if ((res->rows_rodbiRes < res->nrow_rodbiRes) && !(res->done_rodbiRes))
      res->state_rodbiRes = FETCH_rodbiState;
    else
      res->state_rodbiRes = OUTPUT_rodbiState;
    break;
  case OUTPUT_rodbiState:
    if ((res->fchBeg_rodbiRes < res->fchNum_rodbiRes) ||
        !(res->done_rodbiRes))
      res->state_rodbiRes = SPLIT_rodbiState;
    else
      res->state_rodbiRes = CLOSE_rodbiState;
    break;
  case REFETCH_rodbiState:
    res->state_rodbiRes = FETCH_rodbiState;
    break;
  default:
    RODBI_FATAL(__func__, 1, res->state_rodbiRes);
    break;
  }
} /* end rodbiResStateNext */

/* --------------------------- rodbiResInfoStmt --------------------------- */

static SEXP rodbiResInfoStmt(rodbiRes *res)
{
  ub4         qrylen;
  oratext    *qrybuf;
  SEXP        vec;

  /* get statement */
  RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                  roociGetResStmt(&(res->res_rodbiRes), &qrybuf, &qrylen));

  /* allocate result vector */
  PROTECT(vec = allocVector(STRSXP, 1));
  SET_STRING_ELT(vec, 0, Rf_mkCharLenCE((char *)qrybuf, (int)qrylen,
                                        CE_NATIVE));
  UNPROTECT(1);

  return vec;
} /* end rodbiResInfoStmt */

/* -------------------------- rodbiResInfoFields -------------------------- */

static SEXP rodbiResInfoFields(rodbiRes *res)
{
  SEXP      list;
  SEXP      names;
  SEXP      row_names;
  SEXP      vecName;
  SEXP      vecType;
  SEXP      vecClass;
  SEXP      vecLen;
  SEXP      vecPrec;
  SEXP      vecScale;
  SEXP      vecInd;
  ub4       len = 0;
  text     *buf;
  ub4       siz;
  sb2       pre;
  sb1       sca;
  ub1       nul;
  int       cid;
  int       curritm;
  int       ncol;

  /* allocate output list */
  PROTECT(list = allocVector(VECSXP, 7));

  /* allocate and set names */
  names = allocVector(STRSXP, 7);
  setAttrib(list, R_NamesSymbol, names);                  /* protects names */

  /* set class to data frame */
  setAttrib(list, R_ClassSymbol, mkString("data.frame"));

  ncol = res->res_rodbiRes.ncol_roociRes;

  /* name */
  PROTECT(vecName = allocVector(STRSXP, ncol));
  /* Sclass */
  PROTECT(vecType = allocVector(STRSXP, ncol));
  /* len */
  PROTECT(vecLen = allocVector(INTSXP, ncol));
  /* type */
  PROTECT(vecClass = allocVector(STRSXP, ncol));
  /* precision */
  PROTECT(vecPrec = allocVector(INTSXP, ncol));
  /* scale */
  PROTECT(vecScale = allocVector(INTSXP, ncol));
  /* nullOK */
  PROTECT(vecInd = allocVector(LGLSXP, ncol));

  SET_VECTOR_ELT(list,  0, vecName);
  SET_STRING_ELT(names, 0, mkChar("name"));

  SET_VECTOR_ELT(list,  1, vecType);
  SET_STRING_ELT(names, 1, mkChar("Sclass"));

  SET_VECTOR_ELT(list,  2, vecClass);
  SET_STRING_ELT(names, 2, mkChar("type"));

  SET_VECTOR_ELT(list,  3, vecLen);
  SET_STRING_ELT(names, 3, mkChar("len"));

  SET_VECTOR_ELT(list,  4, vecPrec);
  SET_STRING_ELT(names, 4, mkChar("precision"));

  SET_VECTOR_ELT(list,  5, vecScale);
  SET_STRING_ELT(names, 5, mkChar("scale"));

  SET_VECTOR_ELT(list,  6, vecInd);
  SET_STRING_ELT(names, 6, mkChar("nullOK"));

  curritm = 0;
  for (cid = 0; cid < (res->res_rodbiRes).ncol_roociRes; cid++)
  {
    RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                    roociDescCol(&(res->res_rodbiRes), 
                                 (ub4)(cid+1), NULL, &buf, &len, 
                                 &siz, &pre, &sca, &nul, NULL));

    if (Rf_length(vecName) < curritm + 1)
    {
      vecName = VECTOR_ELT(list, 0);
      vecName = lengthgets(vecName, curritm + 1);
      SET_VECTOR_ELT(list, 0, vecName);          /* protects vec */

      vecType = VECTOR_ELT(list, 1);
      vecType = lengthgets(vecType, curritm + 1);
      SET_VECTOR_ELT(list, 1, vecType);          /* protects vec */

      vecClass = VECTOR_ELT(list, 2);
      vecClass = lengthgets(vecClass, curritm + 1);
      SET_VECTOR_ELT(list, 2, vecClass);          /* protects vec */

      vecLen = VECTOR_ELT(list, 3);
      vecLen = lengthgets(vecLen, curritm + 1);
      SET_VECTOR_ELT(list, 3, vecLen);          /* protects vec */

      vecPrec = VECTOR_ELT(list, 4);
      vecPrec = lengthgets(vecPrec, curritm + 1);
      SET_VECTOR_ELT(list, 4, vecPrec);          /* protects vec */

      vecScale = VECTOR_ELT(list, 5);
      vecScale = lengthgets(vecScale, curritm + 1);
      SET_VECTOR_ELT(list, 5, vecScale);          /* protects vec */

      vecInd = VECTOR_ELT(list, 6);
      vecInd = lengthgets(vecInd, curritm + 1);
      SET_VECTOR_ELT(list, 6, vecInd);          /* protects vec */

    }

    SET_STRING_ELT(vecName, curritm, mkCharLen((const char *)buf, (int)len));
    if (!strcmp(RODBI_NAME_CLASS(res->res_rodbiRes.typ_roociRes[cid].typ_roociColType),
                                 RODBI_R_DAT_NM))
    {
      SET_STRING_ELT(vecType, curritm, mkChar("POSIXct"));
      SET_STRING_ELT(vecClass, curritm, mkChar(RODBI_NAME_INT(
                     (res->res_rodbiRes).typ_roociRes[cid].typ_roociColType)));
    }
#if ((OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION >= 4) || (OCI_MAJOR_VERSION > 23))
    else
    if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_VEC)
    {
      char vecdesc[SB1MAXVAL] = {0};
      char vfmt[64] = {0};


#ifdef OCI_ATTR_VECTOR_FORMAT_BINARY
      if (res->res_rodbiRes.typ_roociRes[cid].vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_BINARY)
        snprintf(vfmt,sizeof(vfmt), "binary");
      else
#endif
       RODBI_SET_VECTOR_FORMAT(res->res_rodbiRes.typ_roociRes[cid].vfmt_roociColType, vfmt);

#ifdef OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE
      if (res->res_rodbiRes.typ_roociRes[cid].vprop_roociColType &
          OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
        strcat(vfmt, ",SPARSE");
#endif

      SET_STRING_ELT(vecType, curritm, mkChar(RODBI_NAME_CLASS(
                     res->res_rodbiRes.typ_roociRes[cid].typ_roociColType)));
      snprintf(vecdesc, SB1MAXVAL,
               RODBI_NAME_INT(res->res_rodbiRes.typ_roociRes[cid].typ_roociColType),
               vfmt);
      SET_STRING_ELT(vecClass, curritm, mkChar(vecdesc));
    }
#endif
    else
    if ((res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_UDT) ||
        (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_REF))
    {
      SET_STRING_ELT(vecType, curritm, mkChar("data.frame"));
      SET_STRING_ELT(vecClass, curritm, mkCharLen(
       (const char *)res->res_rodbiRes.typ_roociRes[cid].obtyp_roociColType.name_roociObjType,
       (int)res->res_rodbiRes.typ_roociRes[cid].obtyp_roociColType.namsz_roociObjType));
    }
    else
    {
      SET_STRING_ELT(vecType, curritm, mkChar(RODBI_NAME_CLASS(
                     res->res_rodbiRes.typ_roociRes[cid].typ_roociColType)));
      SET_STRING_ELT(vecClass, curritm, mkChar(RODBI_NAME_INT(
                     (res->res_rodbiRes).typ_roociRes[cid].typ_roociColType)));
    }
    if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_CHAR ||
        res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_VARCHAR2 ||
        res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_RAW)
      INTEGER(vecLen)[curritm]   = (int)siz;
    else
    if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_NCHAR ||
        res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_NVARCHAR2)
      INTEGER(vecLen)[curritm]   = (int)siz/2;
#if ((OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION >= 4) || (OCI_MAJOR_VERSION > 23))
    else if (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_VEC)
    {
      if (res->res_rodbiRes.typ_roociRes[cid].vprop_roociColType &
          OCI_ATTR_VECTOR_COL_PROPERTY_IS_FLEX)
        INTEGER(vecLen)[curritm]   = NA_INTEGER;
      else
        INTEGER(vecLen)[curritm]   = res->res_rodbiRes.typ_roociRes[cid].vdim_roociColType;
    }
    else
      INTEGER(vecLen)[curritm]   = NA_INTEGER;
#endif

    INTEGER(vecPrec)[curritm]  = (int)pre;
    INTEGER(vecScale)[curritm] = (int)sca;
    LOGICAL(vecInd)[curritm]   = nul ? TRUE : FALSE;

    curritm++;

    /* User defined type, fill all elements in it */
    if ((res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_UDT) ||
        (res->res_rodbiRes.typ_roociRes[cid].typ_roociColType == RODBI_REF))
    {
      list = rodbiUDTInfoFields(list,
       &res->res_rodbiRes.typ_roociRes[cid].obtyp_roociColType,
       res->res_rodbiRes.typ_roociRes[cid].obtyp_roociColType.typ_roociObjType,
       &curritm, res->res_rodbiRes.ncol_roociRes);
    }
  }

  /* allocate and set row names */
  row_names = allocVector(INTSXP, 2);
  INTEGER(row_names)[0] = NA_INTEGER;
  INTEGER(row_names)[1] = - curritm;
  setAttrib(list, R_RowNamesSymbol, row_names);       /* protects row_names */

  /* release output list */
  UNPROTECT(8);

  return list;
} /* end rodbiResInfoFields */

/* -------------------------- rodbiUDTInfoFields -------------------------- */

static SEXP rodbiUDTInfoFields(SEXP list, roociObjType *objtyp,
                               roociColType *attrtyp, int *curritm, int nrows)
{
  SEXP      vecName;
  SEXP      vecType;
  SEXP      vecClass;
  SEXP      vecLen;
  SEXP      vecPrec;
  SEXP      vecScale;
  SEXP      vecInd;
  int       cid;

  vecName = VECTOR_ELT(list, 0);
  vecType = VECTOR_ELT(list, 1);
  vecClass = VECTOR_ELT(list, 2);
  vecLen = VECTOR_ELT(list, 3);
  vecPrec = VECTOR_ELT(list, 4);
  vecScale = VECTOR_ELT(list, 5);
  vecInd = VECTOR_ELT(list, 6);

  for (cid = 0; cid < objtyp->nattr_roociObjType; cid++, attrtyp++)
  {
    if (Rf_length(vecName) < *curritm + 1)
    {
      vecName = VECTOR_ELT(list, 0);
      vecName = lengthgets(vecName, *curritm + 1);
      SET_VECTOR_ELT(list, 0, vecName);          /* protects vec */

      vecType = VECTOR_ELT(list, 1);
      vecType = lengthgets(vecType, *curritm + 1);
      SET_VECTOR_ELT(list, 1, vecType);          /* protects vec */

      vecClass = VECTOR_ELT(list, 2);
      vecClass = lengthgets(vecClass, *curritm + 1);
      SET_VECTOR_ELT(list, 2, vecClass);          /* protects vec */

      vecLen = VECTOR_ELT(list, 3);
      vecLen = lengthgets(vecLen, *curritm + 1);
      SET_VECTOR_ELT(list, 3, vecLen);          /* protects vec */

      vecPrec = VECTOR_ELT(list, 4);
      vecPrec = lengthgets(vecPrec, *curritm + 1);
      SET_VECTOR_ELT(list, 4, vecPrec);          /* protects vec */

      vecScale = VECTOR_ELT(list, 5);
      vecScale = lengthgets(vecScale, *curritm + 1);
      SET_VECTOR_ELT(list, 5, vecScale);          /* protects vec */

      vecInd = VECTOR_ELT(list, 6);
      vecInd = lengthgets(vecInd, *curritm + 1);
      SET_VECTOR_ELT(list, 6, vecInd);          /* protects vec */

    }

    if ((attrtyp->typ_roociColType == RODBI_UDT) ||
        (attrtyp->typ_roociColType == RODBI_REF))
    {
      if (objtyp->namsz_roociObjType)
      {
        SET_STRING_ELT(vecName, *curritm,
                       mkCharLen((const char *)objtyp->name_roociObjType,
                                 (int)objtyp->namsz_roociObjType));
      }
    }
    else if (objtyp->namsz_roociObjType)
    {
      if (objtyp->namsz_roociObjType)
      {
        char tmpval[UB1MAXVAL];
        int len = snprintf(tmpval, sizeof(tmpval), "%.*s.%.*s",
                        objtyp->namsz_roociObjType,
                        objtyp->name_roociObjType, attrtyp->namsz_roociColType,
                        attrtyp->name_roociColType);
        SET_STRING_ELT(vecName, *curritm,
                       mkCharLen((const char *)tmpval, len));
      }
      else
        SET_STRING_ELT(vecName, *curritm,
                       mkCharLen((const char *)attrtyp->name_roociColType,
                                 (int)attrtyp->namsz_roociColType));
    }

    if (!strcmp(RODBI_NAME_CLASS(attrtyp->typ_roociColType), RODBI_R_DAT_NM))
    {
      SET_STRING_ELT(vecType, *curritm, mkChar("POSIXct"));
      SET_STRING_ELT(vecClass, *curritm,
                     mkChar(RODBI_NAME_INT(attrtyp->typ_roociColType)));
    }
    else
    if ((attrtyp->typ_roociColType == RODBI_UDT) ||
        (attrtyp->typ_roociColType == RODBI_REF))
    {
      SET_STRING_ELT(vecType, *curritm, mkChar("data.frame"));
      if (attrtyp->attrnmsz_roociColType)
        SET_STRING_ELT(vecClass, *curritm,
                     mkCharLen((const char *)attrtyp->attrnm_roociColType,
                               (int)attrtyp->attrnmsz_roociColType));
      else
        SET_STRING_ELT(vecClass, *curritm,
                     mkCharLen((const char *)attrtyp->name_roociColType,
                               (int)attrtyp->namsz_roociColType));
    }
    else
    if (attrtyp->typ_roociColType == RODBI_REF)
    {
      char type_buf[UB1MAXVAL];
      snprintf(type_buf, sizeof(type_buf), "%s OF %.*s",
              RODBI_NAME_INT(attrtyp->typ_roociColType),
              (attrtyp->attrnmsz_roociColType ?
                attrtyp->attrnmsz_roociColType :
                attrtyp->namsz_roociColType),
              (attrtyp->attrnmsz_roociColType ?
                attrtyp->attrnm_roociColType :
                attrtyp->name_roociColType));
      SET_STRING_ELT(vecType, *curritm,
                     mkChar(RODBI_NAME_CLASS(attrtyp->typ_roociColType)));
      SET_STRING_ELT(vecClass, *curritm, mkChar(type_buf));
    }
    else
    {
      SET_STRING_ELT(vecType, *curritm,
                     mkChar(RODBI_NAME_CLASS(attrtyp->typ_roociColType)));
      SET_STRING_ELT(vecClass, *curritm,
                     mkChar(RODBI_NAME_INT(attrtyp->typ_roociColType)));
    }
    if (attrtyp->typ_roociColType == RODBI_CHAR ||
        attrtyp->typ_roociColType == RODBI_VARCHAR2 ||
        attrtyp->typ_roociColType == RODBI_RAW)
      INTEGER(vecLen)[*curritm]   = (int)(attrtyp->colsz_roociColType);
    else if (attrtyp->typ_roociColType == RODBI_NCHAR ||
             attrtyp->typ_roociColType == RODBI_NVARCHAR2)
      INTEGER(vecLen)[*curritm]   = (int)(attrtyp->colsz_roociColType)/2;
    else
      INTEGER(vecLen)[*curritm]   = NA_INTEGER;

    INTEGER(vecPrec)[*curritm]  = (int)attrtyp->prec_roociColType;
    INTEGER(vecScale)[*curritm] = (int)attrtyp->scale_roociColType;
    LOGICAL(vecInd)[*curritm]   = attrtyp->null_roociColType ? TRUE : FALSE;

    (*curritm)++;

    /* User defined type, fill all elements in it */
    if ((attrtyp->typ_roociColType == RODBI_UDT) ||
        (attrtyp->typ_roociColType == RODBI_REF))
    {
      list = rodbiUDTInfoFields(list, &attrtyp->obtyp_roociColType,
                         attrtyp->obtyp_roociColType.typ_roociObjType,
                         curritm, nrows + objtyp->nattr_roociObjType);
    }
  }

  return list;
} /* end rodbiUDTInfoFields */

/* ------------------------------- rodbiResTerm ---------------------------- */

static void rodbiResTerm(rodbiRes  *res)
{
  rodbiCon  *con = res->con_rodbiRes;
  
  con->err_checked_rodbiCon = FALSE;

  /* free result set */
  RODBI_CHECK_RES(res, __func__, __LINE__, FALSE,
                  roociResFree(&(res->res_rodbiRes)));
  (con->con_rodbiCon).num_roociCon--;

  if (res->pghdl_rodbiRes)
  {
    int        cid;

    /* Free any temporary cache memory */
    for (cid = 0; cid < res->res_rodbiRes.ncol_roociRes; cid++)
    {
      rodbichdl *hdl  = &res->pghdl_rodbiRes[cid];

      if (hdl->begpg_rodbichdl)
        RODBI_DESTROY_COL_HDL(hdl);
    }
    
    ROOCI_MEM_FREE(res->pghdl_rodbiRes);
  }

  ROOCI_MEM_FREE(res);
} /* end rodbiResTerm */
  
  
/* ------------------------------- rodbiCheck ----------------------------- */

static void rodbiCheck(rodbiDrv *drv, rodbiCon *con, const char *fun, 
                       int pos, sword status, text *errMsg, size_t errMsgLen)
{
  sb4    errNum  = 0;
  int    msglen  = errMsgLen;
  int    msglen2 = msglen;

  switch (status)
  {
  case OCI_SUCCESS:
    break;
  /* Bug 22233938 */
  case OCI_SUCCESS_WITH_INFO:

  case OCI_ERROR:
    /* get error */
    *errMsg = 0;
    roociGetError(drv ? &(drv->ctx_rodbiDrv) : NULL,
                  con ? &(con->con_rodbiCon) : NULL, 
                  fun, &errNum, errMsg, (ub4)msglen - 1);
    break;

  case ROOCI_DRV_ERR_MEM_FAIL:
    msglen = (int)((msglen < strlen(RODBI_ERR_MEMORY_ALC)+1) ?
                    msglen : strlen(RODBI_ERR_MEMORY_ALC)+1);
    memcpy(errMsg, RODBI_ERR_MEMORY_ALC, msglen);
    *(errMsg + msglen) = 0;
    break;

  case ROOCI_DRV_ERR_CON_FAIL:
    *errMsg = 0;
    /* get error */
    roociGetError(drv ? &(drv->ctx_rodbiDrv) : NULL,
                  con ? &(con->con_rodbiCon) : NULL,
                  fun, &errNum, errMsg, (ub4)msglen - 1);
    /* free connection */
    roociTerminateCon(&(con->con_rodbiCon), 0);
    ROOCI_MEM_FREE(con);                                           
    break;

  case ROOCI_DRV_ERR_TYPE_FAIL:
      msglen = snprintf((char *)errMsg, msglen2, RODBI_ERR_UNSUPP_TYPE);
      *(errMsg + msglen2 - 1) = 0;
    break;

  case ROOCI_DRV_ERR_ENCODE_FAIL:
      msglen = snprintf((char *)errMsg, msglen2, RODBI_ERR_UNSUPP_SQL_ENC);
      *(errMsg + msglen2 - 1) = 0;
    break;

  case ROOCI_DRV_ERR_LOAD_FAIL:
      /*
      ** In case of load failure error message is already in message buffer,
      ** refer to roociloadError__set() in roociload.c
      */
      *(errMsg + drv->ctx_rodbiDrv.loadCtx_roociCtx.messageLength) = 0;
    break;

  case OCI_INVALID_HANDLE:
    {
      char errbuf[128];
      snprintf(errbuf, sizeof(errbuf),
               "OCI_INVALID_HANDLE was returned in %s at label", fun);
      msglen = snprintf((char *)errMsg, msglen2, RODBI_ERR_INTERNAL,
                        errbuf, pos, status);
    }
    break;

  case OCI_STILL_EXECUTING:
    {
      char errbuf[128];
      snprintf(errbuf, sizeof(errbuf),
               "OCI_STILL_EXECUTE was returned in %s at label", fun);
      msglen = snprintf((char *)errMsg, msglen2, RODBI_ERR_INTERNAL,
                        errbuf, pos, status);
    }
    break;

  case OCI_CONTINUE:
    {
      char errbuf[128];
      snprintf(errbuf, sizeof(errbuf),
               "OCI_CONTINUE was returned in %s at label", fun);
      msglen = snprintf((char *)errMsg, msglen2, RODBI_ERR_INTERNAL,
                        errbuf, pos, status);
    }
    break;

  default:
    {
      char errbuf[128];
      snprintf(errbuf, sizeof(errbuf),
               "Unexpected error was returned in %s at label", fun);
      msglen = snprintf((char *)errMsg, msglen2, RODBI_ERR_INTERNAL,
                        fun, pos, status);
      *(errMsg + msglen2 - 1) = 0;
    }
    break;
  }
} /* end rodbiCheck */

/* ------------------------ rodbiAssertCon -------------------------------- */

boolean rodbiAssertCon(void *rCon, const char *func, size_t pos) 
{
  if (((rodbiCon *)rCon)->magicWord_rodbiCon == RODBI_CHECKWD)
    return TRUE;
  else 
    return FALSE;
} /* end rodbiAssertCon */

/* ------------------------ rodbiAssertRes -------------------------------- */

boolean rodbiAssertRes(void *rRes, const char *func, size_t pos) 
{
  if (((rodbiRes *)rRes)->magicWord_rodbiRes == RODBI_CHECKWD)
    return TRUE;
  else 
    return FALSE;
} /* end rodbiAssertRes */

/* --------------------------------- rodbiTypeExt ------------------------- */

ub2 rodbiTypeExt(ub1 ityp)
{
  ub2  etyp;

  etyp = rodbiITypTab[ityp].etyp_rodbiITyp;
  if (!etyp)
    RODBI_ERROR(RODBI_ERR_UNSUPP_COL_TYPE);

  return etyp;
} /* end of rodbiTypeExt */

/* ---------------------------- rodbiTypeInt ------------------------------ */

ub1 rodbiTypeInt(roociCtx *pctx, ub2 ctyp, sb2 precision, sb1 scale, ub4 size,
                 boolean timesten, ub1 csform)
{
  ub1 ityp;

  switch (ctyp)
  {
  case SQLT_CHR:                                     /* VARCHAR2, NVARCHAR2 */
    if (csform == SQLCS_NCHAR)
      ityp = RODBI_NVARCHAR2;
    else
      ityp = RODBI_VARCHAR2;
    break;
  case SQLT_NUM:                                                  /* Number */
    if (precision > 0 && precision < 10 && scale == 0)
      ityp = RODBI_INTEGER;                                      /* Integer */
    else
      ityp = RODBI_NUMBER;
   break;
  case SQLT_INT:
    if (timesten && size <= sizeof (int))
      ityp = RODBI_INTEGER;                     /* TimesTen native integers */
    else
      ityp = RODBI_NUMBER;
    break;
#if (OCI_MAJOR_VERSION >= 12)
  case SQLT_BOL:
    ityp = RODBI_BOOLEAN;
    break;
#endif
  case SQLT_LNG:                                                    /* Long */
    ityp = RODBI_LONG;
    break;
  case SQLT_DAT:                                                    /* Date */
    ityp = RODBI_DATE;
    break;
  case SQLT_BIN:                                                  /* Binary */
    ityp = RODBI_RAW;
    break;
  case SQLT_LBI:                                                /* Long Raw */
    if (timesten)
      ityp = RODBI_RAW;                               /* TimesTen Varbinary */
    else
      ityp = RODBI_LONG_RAW;
    break;
  case SQLT_AFC:                            
    if (csform == SQLCS_NCHAR)
      ityp = RODBI_NCHAR;
    else
      ityp = RODBI_CHAR;
    break;
  case SQLT_FLT:
    ityp = RODBI_NUMBER;                                          /* DOUBLE */
    break;
  case SQLT_IBFLOAT:
    ityp = RODBI_BFLOAT;                                    /* BINARY_FLOAT */
    break;
  case SQLT_IBDOUBLE:
    ityp = RODBI_BDOUBLE;                                  /* BINARY_DOUBLE */
    break;
  case SQLT_RDD:
    ityp = RODBI_ROWID;                                            /* RowID */
    break;
  case OCI_TYPECODE_OBJECT:                   /* USER-DEFINED TYPE (OBJECT) */
  case OCI_TYPECODE_NAMEDCOLLECTION:      /* USER-DEFINED TYPE (COLLECTION) */
  case OCI_TYPECODE_VARRAY:                   /* USER-DEFINED TYPE (VARRAY) */
  case OCI_TYPECODE_TABLE:                     /* USER-DEFINED TYPE (TABLE) */
    ityp = RODBI_UDT;
    break;
  case OCI_TYPECODE_REF:
    ityp = RODBI_REF;
    break;
  case SQLT_CLOB:                                          /* Character LOB */
    if (csform == SQLCS_NCHAR)
      ityp = RODBI_NCLOB;
    else
      ityp = RODBI_CLOB;
    break;
  case SQLT_BLOB:                                             /* Binary LOB */
    ityp = RODBI_BLOB;
    break;
  case SQLT_FILE:                                            /* Binary File */
    ityp = RODBI_BFILE;
    break;
  case SQLT_TIMESTAMP:                                         /* Timestamp */
    ityp = RODBI_TIME;
    break;
  case SQLT_TIMESTAMP_TZ:                       /* TIMESTAMP WITH TIME ZONE */
    ityp = RODBI_TIME_TZ;
    break;
  case SQLT_INTERVAL_YM:                          /* INTERVAL YEAR TO MONTH */
    ityp = RODBI_INTER_YM;
    break;
  case SQLT_INTERVAL_DS:                          /* INTERVAL DAY TO SECOND */
    ityp = RODBI_INTER_DS;
    break;
  case SQLT_TIMESTAMP_LTZ:                /* TIMESTAMP WITH LOCAL TIME ZONE */
    ityp = RODBI_TIME_LTZ;
    break;
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
  case SQLT_VEC:                                                  /* VECTOR */
    ityp = RODBI_VEC;
    break;
#endif /* OCI_MAJOR_VERSION >= 23 */
  default:
    ityp = 0;
    RODBI_FATAL_DATATYPE_UNSUPPORTED(pctx, ctyp);
    break;
  }

  return ityp;
} /* end rodbiTypeInt */


static sword RODBI_ADD_VAR_DATA_ITEM(rodbichdl *hdl, ub1 flag,
                                     void *data, int len)
{
  rodbivcol *col;
  int        tmplen;
  ub1       *datasrc;
  ub1       *dat;

  /* extend pages if necessary */
  tmplen = (len + (int)sizeof(rodbivcol));
  tmplen = (tmplen/(int)(hdl)->pgsize_rodbichdl) + 1;
  if (hdl->extpgs_rodbichdl <= tmplen)
    RODBI_EXTEND_PAGES(hdl, hdl->currpg_rodbichdl, tmplen+1);

  if ((hdl->offset_rodbichdl + (int)sizeof(rodbivcol)) >
                                                       (hdl)->pgsize_rodbichdl)
  {
    hdl->currpg_rodbichdl = hdl->currpg_rodbichdl->next_rodbiPg;
    hdl->totpgs_rodbichdl++;
    hdl->extpgs_rodbichdl--;
    hdl->offset_rodbichdl = 0;
  }

  if (len <= hdl->pgsize_rodbichdl)
  {
    int remaining = hdl->pgsize_rodbichdl - hdl->offset_rodbichdl -
                    sizeof(rodbivcol);
    if (remaining <= 5)
    {
      flag |= RODBI_VCOL_FLG_ELEM_IN_NEXT_PG;
      flag |= RODBI_VCOL_FLG_ELEM_REF_ACCESS;
    }
    else if(remaining >= len)
      flag |= RODBI_VCOL_FLG_ELEM_REF_ACCESS;
  }

  col=(rodbivcol *)&(hdl->currpg_rodbichdl->buf_rodbiPg[hdl->offset_rodbichdl]);

  /* Keep data in single page to avoid memcpy during populate */
  col->len_rodbivcol    = (len);
  col->flag_rodbivcol   = flag;
  if (flag & RODBI_VCOL_FLG_ELEM_IN_NEXT_PG)
  {
    hdl->totpgs_rodbichdl++;
    hdl->extpgs_rodbichdl--;
    hdl->offset_rodbichdl = 0;
    hdl->currpg_rodbichdl = hdl->currpg_rodbichdl->next_rodbiPg;
    dat = (ub1 *)&(hdl->currpg_rodbichdl->buf_rodbiPg[hdl->offset_rodbichdl]);
  }
  else
  {
    hdl->offset_rodbichdl += offsetof(struct rodbivcol, dat_rodbivcol);
    dat    = (ub1 *)&col->dat_rodbivcol[0];
  }

  if (flag & RODBI_VCOL_FLG_NULL)
  {
    /* align offset to 4 or 8 byte boundary for next item to be added */
    hdl->offset_rodbichdl += (sizeof(char *) - 
                              (hdl->offset_rodbichdl % sizeof(char *)));
    return 0;
  }

  hdl->actual_maxlen_rodbichdl = (hdl->actual_maxlen_rodbichdl > len ?
                                  hdl->actual_maxlen_rodbichdl : len);
  tmplen = len;
  datasrc = (ub1 *)data;
  while (tmplen > 0)
  {
    int nbytes = ((hdl)->pgsize_rodbichdl - hdl->offset_rodbichdl) > tmplen ?
                        tmplen :
                        ((hdl)->pgsize_rodbichdl - hdl->offset_rodbichdl);
    memcpy(dat, datasrc, nbytes);
    tmplen -= nbytes;
    datasrc += nbytes;
    if (tmplen)
    {
      hdl->currpg_rodbichdl = hdl->currpg_rodbichdl->next_rodbiPg;
      hdl->totpgs_rodbichdl++;
      hdl->extpgs_rodbichdl--;
      hdl->offset_rodbichdl = 0;

      dat = &hdl->currpg_rodbichdl->buf_rodbiPg[0];
    }
    else
      hdl->offset_rodbichdl += nbytes;
  }

  /* align offset to 4 or 8 byte boundary for next item to be added */
  hdl->offset_rodbichdl += (sizeof(char *) - 
                            (hdl->offset_rodbichdl % sizeof(char *)));
  return 0;
} /* RODBI_ADD_VAR_DATA_ITEM */

static int RODBI_GET_VAR_DATA_ITEM(rodbichdl *hdl, void *data, int len)
{
  rodbivcol *col;
  int        tmplen;
  ub1       *dat = (ub1 *)data;
  ub1       *datsrc;

  if ((hdl->offset_rodbichdl + (int)sizeof(rodbivcol)) >
                                                       (hdl)->pgsize_rodbichdl)
  {
    if (hdl->currpg_rodbichdl->next_rodbiPg)
      hdl->currpg_rodbichdl = hdl->currpg_rodbichdl->next_rodbiPg;
    else
      return ROOCI_DRV_ERR_NO_DATA;
    hdl->offset_rodbichdl = 0;
  }
  col=(rodbivcol *)&(hdl->currpg_rodbichdl->buf_rodbiPg[hdl->offset_rodbichdl]);
  tmplen = col->len_rodbivcol;
  if (col->flag_rodbivcol & RODBI_VCOL_FLG_ELEM_IN_NEXT_PG)
  {
    hdl->offset_rodbichdl = 0;
    hdl->currpg_rodbichdl = hdl->currpg_rodbichdl->next_rodbiPg;
    datsrc = (ub1 *)&hdl->currpg_rodbichdl->buf_rodbiPg[hdl->offset_rodbichdl];
  }
  else
  {
    hdl->offset_rodbichdl += offsetof(struct rodbivcol, dat_rodbivcol);
    datsrc = &col->dat_rodbivcol[0];
  }

  if (col->flag_rodbivcol & RODBI_VCOL_FLG_NULL)
  {
    /* align offset to 4 or 8 byte boundary to access next item */
    hdl->offset_rodbichdl += (sizeof(char *) - 
                              (hdl->offset_rodbichdl % sizeof(char *)));
    return RODBI_VCOL_NULL;
  }

  while (tmplen > 0)
  {
    int nbytes = ((hdl)->pgsize_rodbichdl - hdl->offset_rodbichdl) > tmplen ?
                    tmplen : ((hdl)->pgsize_rodbichdl - hdl->offset_rodbichdl);
    memcpy(dat, datsrc, nbytes);
    tmplen -= nbytes;
    dat += nbytes;
    if (tmplen)
    {
      hdl->currpg_rodbichdl = hdl->currpg_rodbichdl->next_rodbiPg;
      hdl->offset_rodbichdl = 0;
      datsrc = &hdl->currpg_rodbichdl->buf_rodbiPg[0];
    }
    else
      hdl->offset_rodbichdl += nbytes;
  }

  /* align offset to 4 or 8 byte boundary to access next item */
  hdl->offset_rodbichdl += (sizeof(char *) - 
                            (hdl->offset_rodbichdl % sizeof(char *)));

  return (col->len_rodbivcol);
} /* RODBI_GET_VAR_DATA_ITEM */


/* end of file rodbi.c */
