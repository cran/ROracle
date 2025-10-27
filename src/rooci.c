/* Copyright (c) 2011, 2025, Oracle and/or its affiliates.*/
/* All rights reserved.*/

/*
   NAME
     rooci.c 

   DESCRIPTION
     OCI calls used in implementing DBI driver for R.

   NOTES

   MODIFIED   (MM/DD/YY)
   rpingte     10/17/25 - change __FUNCTION__ to __func__
   rpingte     05/10/25 - add sparse vector support
   rpingte     04/25/25 - Bug 37777349: support data > 32767 in bind to CLOB
   brusures    10/23/24 - add format specifiers for warnings and errors
   rpingte     09/19/24 - improve error reporting
   rpingte     07/11/24 - fix compiler warnigs with pre-19c clients
   rpingte     04/09/24 - use dynamic loading
   rpingte     03/20/24 - add vector supprt
   rpingte     01/26/22 - add support for PLSQL boolean
   msavanur    07/25/19 - read scalar values for nested tables (30040995)
   rpingte     03/19/19 - Object support
   rpingte     10/05/16 - fix compilation on windows
   ssjaiswa    08/03/16 - 22329115: Initialize CursorCount by 1 instead of 0
   ssjaiswa    03/15/16 - Adjust CursorPosition for cursor handle buffer index,
                          Bug [22329115]
   ssjaiswa    03/12/16 - Adding OCI_SUCCESS_WITH_INFO check, Bug [22233938]
   ssjaiswa    03/11/16 - Free Ref cursor(s) handle buffer(s)
   ssjaiswa    03/11/16 - Added support for define,fetch and describe for result
                          columns returned by Ref cursor(s) using cursor handle
   ssjaiswa    03/10/16 - Added support for Ref cursor handle allocation and
                          binding by OCIBindByName() and OciBindByPos()
   ssjaiswa    03/08/16 - Free CLOB/BLOB/BFILE data buffers
   ssjaiswa    03/08/16 - Added fetching for Plsql CLOB/BLOB/BFILE datatype of
                          OUT/IN OUT parameter mode 
   ssjaiswa    03/04/16 - Free bind parameter name buffers
   ssjaiswa    03/04/16 - Added OCIBindByName() support using param_name field
   rpingte     02/29/16 - Use ArrayDescriptorAlloc for performance
   rpingte     02/23/16 - remove unused variables
   rpingte     08/05/15 - 21128853: performance improvements for datetime types
   rpingte     03/25/15 - add NCHAR, NVARCHAR2 and NCLOB
   rpingte     01/29/15 - add unicode_as_utf8
   rpingte     12/04/14 - NLS support
   ssjaiswa    09/10/14 - Add bulk_write
   rpingte     06/24/14 - reset stmt hdl
   rpingte     05/26/14 - add time zone to connection
   rpingte     05/24/14 - maintain date, time stamp, time stamp with time zone
                          and time stamp with local time zone as string
   rpingte     05/24/14 - remove epoch, temp_ts, diff, and inited unused fields
                          from roociRes
   rpingte     05/22/14 - reset stmt hdl
   rpingte     05/13/14 - fix compiler warning on Sparc
   rpingte     04/21/14 - use SQLT_LVC & SQLT_LVB for large bind data
   rpingte     04/12/14 - add more diagnostics for AIX srg
   rpingte     04/03/14 - remove tzdiff unused field
   rpingte     04/01/14 - remove secs_UTC_roociCon
   rpingte     03/12/14 - add boolean for TX epoch initialization
   rpingte     03/06/14 - lobinres_roociRes -> nocache_roociRes
   rpingte     02/12/14 - OCI_ATTR_DRIVER_NAME available only in 11g
   rpingte     01/09/14 - Copyright update
   rpingte     11/18/13 - add lobinres_roociRes
   rkanodia    10/03/13 - Add session mode
   rpingte     04/09/13 - use SQLT_FLT instead of SQLT_BDOUBLE
   rpingte     11/20/12 - 15900089: remove avoidable errors reported with date
                          time types
   rpingte     11/01/12 - use OCI_ATTR_CHARSET_FORM
   rpingte     09/21/12 - add roociAllocDescBindBuf and use macros
   demukhin    09/20/12 - bug 14653686: crash on connection init
   paboyoun    09/17/12 - add difftime support
   rkanodia    09/10/12 - Checking pointer validity during connection
                          termination
   demukhin    09/04/12 - add Extproc driver
   rkanodia    08/16/12 - Removed redundant arguments passed to functions
                          and removed LOB prefetch support, bug [14508278]
   rpingte     08/13/12 - OCI_ATTR_DATA_SIZE if ub2
   rkanodia    07/26/12 - corrected buffer length to get server version
   rkanodia    07/01/12 - block statement caching without prefetch 
   rpingte     06/21/12 - UTC changes
   rpingte     06/21/12 - convert utf-8 sql to env handle character set
   jfeldhau    06/18/12 - ROracle support for TimesTen.
   rkanodia    06/13/12 - remove unused code
   rpingte     06/06/12 - use charset form for NLS
   rpingte     05/26/12 - POSIXct, POSIXlt and RAW support
   surikuma    05/25/12 - aix: ub2 data_size
   rkanodia    05/20/12 - LOB prefetch
   rkanodia    05/20/12 - Statement caching
   rpingte     05/19/12 - Fix windows build and warnings
   rpingte     05/03/12 - Use array interface
   rpingte     05/01/12 - add navigation of conn and result
   rpingte     04/30/12 - cleanup
   rkanodia    04/27/12 - Namespace change
   rpingte     04/19/12 - normalize structures
   rpingte     04/12/12 - Implement ctrl+c handler
   rkanodia    04/11/12 - Free partial allocated memory 
   rpingte     04/10/12 - use assertion functions
   rkanodia    04/08/12 - Add function description
   rkanodia    04/02/12 - Removing hard coded constant
   rkanodia    03/30/12 - Implement error handle at connection level
   rkanodia    03/25/12 - DBI calls implementation
   rkanodia    03/25/12 - Creation 

*/

#ifdef WIN32
# include <windows.h>
#endif

#include "rooci.h"
#include "rodbi.h"

/*
** This define is used for threaded execution to handle ctrl-C and is
** used for sleep function call. Check if R provides a portable sleep routine.
*/
#ifndef WIN32
# include <unistd.h>
#endif

/*---------------------------------------------------------------------------
                          PRIVATE TYPES AND CONSTANTS
  --------------------------------------------------------------------------*/

#define ROOCI_CON_DEF            5   /* rooci DEFault number of CONnections */
#define ROOCI_RES_DEF            5       /* rooci DEFault number of RESults */
#define ROOCI_LOB_RND         1000                    /* rooci LOB RouNDing */

#define ROOCI_MAJOR_NUMVSN(v)          ((sword)(((v) >> 24) & 0x000000FF))
                                                          /* version number */
#define ROOCI_MINOR_NUMRLS(v)          ((sword)(((v) >> 20) & 0x0000000F))
                                                          /* release number */
#define ROOCI_UPDATE_NUMUPD(v)         ((sword)(((v) >> 12) & 0x000000FF))
                                                           /* update number */
#define ROOCI_PORT_REL_NUMPRL(v)       ((sword)(((v) >> 8) & 0x0000000F))
                                                     /* port release number */
#define ROOCI_PORT_UPDATE_NUMPUP(v)    ((sword)(((v) >> 0) & 0x000000FF))
                                                      /* port update number */

#define ROOCI_TIMESTEN_ID     "TimesTen"       /* TimesTen server id string */

struct roociThrCtx
{
  roociCon         *pcon_roociThrCtx;   /* Pointer to the current conection */
  roociRes         *pres_roociThrCtx;              /* pointer to result set */
  ub4               nrows_roociThrCtx;
  sword             rc_roociThrCtx;
  ub4              *aff_rows_roociThrCtx; /* Number of rows affected by cmd */
  ub2               styp_roociThrCtx;                     /* Statement type */
  OCIThreadId      *tid_roociThrCtx;                       /* OCI Thread ID */
  OCIThreadHandle  *thdhp_roociThrCtx;                     /* thread handle */
  boolean           bExecOver_roociThrCtx;           /* OCIStmtExecute done */
};
typedef struct roociThrCtx roociThrCtx;

/* Construct seconds from days, hours, minutes, secs and fractional sec */
#define ROOCI_SECONDS_FROM_DAYS(seconds_, dy_, hr_, mm_, ss_, fsec_)        \
  (*seconds_) = ((double)(dy_)*86400.0 + (double)(hr_)*3600.0 +             \
                 (double)(mm_)*60.0 + (double)(ss_) + (double)(fsec_)/1e9);


/* Construct day, hours, sec and fractional sec from date in seconds */
#define ROOCI_DAYS_FROM_SECONDS(seconds_, dy_, hr_, mm_, ss_, fsec_)      \
do                                                                        \
{                                                                         \
  (dy_)       = (seconds_) / 86400.0;                                     \
  (seconds_) -= ((dy_) * 86400.0);                                        \
  (hr_)       = (seconds_) / 3600.0;                                      \
  (seconds_) -= ((hr_) * 3600.0);                                         \
  (mm_)       = (seconds_) / 60.0;                                        \
  (seconds_) -= ((mm_) * 60.0);                                           \
  (ss_)       = (sb4)(seconds_);                                          \
  (fsec_)     = ((seconds_) - (double)(ss_)) * 1e9;                       \
}                                                                         \
while (0)

#define ROOCI_REPORT_WARNING(pctx, pcon, msg)                             \
do                                                                        \
{                                                                         \
  sb4   errNum = 0;                                                       \
  text *errMsg = &(pctx->loadCtx_roociCtx.message_roociloadCtx[0]);       \
  roociGetError((pctx), (pcon), (const char *)(msg),                      \
                &errNum, errMsg, (ub4)ROOCI_ERR_LEN);                     \
  warning((const char *)"%s",(const char *)errMsg);                       \
  return rc;                                                              \
}                                                                         \
while (0)

static sword roociFreeObjs(roociObjType *objtyp);

static SEXP roociVecAlloc(roociColType *coltyp, roociObjType *parentobj,
                          int ncol, boolean ora_attributes);

static sword read_attr_val(roociRes *pres, text *names,
                           OCITypeCode typecode, void  *attr_value,
                           OCIInd ind, SEXP Vec, ub2 pos,
                           roociColType *coltyp, cetype_t enc);

static sword write_attr_val(roociRes *pres, text *names,
                            OCITypeCode typecode, void  *attr_value,
                            OCIInd *attr_null_status, SEXP Vec,
                            roociColType *coltyp, ub1 form);

#if defined(OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
/* Write Sparse Vector data */
static sword roociWriteSparseVectorData(roociRes *pres, roociColType *btyp,
                           OCIVector *vecdp, SEXP lst, ub1 form_of_use,
                           sb2 *pind);
#endif

/* ------------------------- roociThrExecCmd ------------------------------ */

static void roociThrExecCmd(void *pctx)
{
  roociThrCtx *pthrctx = (roociThrCtx *)pctx;

  /* execute statement */
  pthrctx->rc_roociThrCtx = OCIStmtExecute(
                                      pthrctx->pcon_roociThrCtx->svc_roociCon,
                                      pthrctx->pres_roociThrCtx->stm_roociRes, 
                                      pthrctx->pcon_roociThrCtx->err_roociCon,
                                      pthrctx->nrows_roociThrCtx, 0, 
                                      NULL, NULL, OCI_DEFAULT);
  pthrctx->bExecOver_roociThrCtx = TRUE;

  /* Bug 22233938 */
  if ((pthrctx->rc_roociThrCtx == OCI_ERROR) ||
      (pthrctx->rc_roociThrCtx == OCI_SUCCESS_WITH_INFO))
    return;
  
  if (pthrctx->styp_roociThrCtx != OCI_STMT_SELECT)
  {
    /* get no of rows affected by last statement execution */
    pthrctx->rc_roociThrCtx = OCIAttrGet(
                                     pthrctx->pres_roociThrCtx->stm_roociRes,
                                     OCI_HTYPE_STMT, 
                                     pthrctx->aff_rows_roociThrCtx,
                                     NULL, OCI_ATTR_ROW_COUNT,
                                     pthrctx->pcon_roociThrCtx->err_roociCon);
  }
} /* end of roociThrExecCmd */

/* ---------------------------- roociThrCtrlCHandler ---------------------- */

void roociThrCtrlCHandler(void *pctx)
{
  roociThrCtx *pthrctx = (roociThrCtx *)pctx;

  while (1)
  {
    /*
      R_checkActivity(1000, FALSE);
    */
#ifdef WIN32
    Sleep(1000);
#else
    sleep(1);
#endif

    if (rodbicheckInterrupt())
    {
      if (OCI_SUCCESS != OCIBreak(pthrctx->pcon_roociThrCtx->svc_roociCon,
                                  pthrctx->pcon_roociThrCtx->err_roociCon))
      {
        return;
      }
      else
      {
        if (OCI_SUCCESS != OCIReset(pthrctx->pcon_roociThrCtx->svc_roociCon, 
                                    pthrctx->pcon_roociThrCtx->err_roociCon))
        {
          return;
        }
      }
      return;
    }
    else if (pthrctx->bExecOver_roociThrCtx)
      return;
  }
} /* end of roociThrCtrlCHandler */

/* ---------------------------- roociBeginThrdHndler ---------------------- */

sword roociBeginThrdHndler(roociThrCtx *pthrctx)
{
  sword            error = OCI_SUCCESS;
  OCIEnv          *penvh = 
                        pthrctx->pcon_roociThrCtx->ctx_roociCon->env_roociCtx;
  OCIError        *perrh = pthrctx->pcon_roociThrCtx->err_roociCon;

  /* create and spawn thread to interrupt the server */
  if ((error = OCIThreadIdInit(penvh, perrh, &pthrctx->tid_roociThrCtx)) ||
      (error = OCIThreadHndInit(penvh, perrh, &pthrctx->thdhp_roociThrCtx)))
    return error;

  return (OCIThreadCreate((void *)penvh, perrh,
                          roociThrExecCmd, (void *)pthrctx,
                          pthrctx->tid_roociThrCtx,
                          pthrctx->thdhp_roociThrCtx));
} /* end of roociBeginThrdHndler */

/* ----------------------------- roociNewConID ---------------------------- */

static int roociNewConID(roociCtx *pctx)
{
  roociCon  **conTemp;
  int         conID;

  /* check connection validity */
  for (conID = 0; conID < pctx->max_roociCtx; conID++)
    if (pctx->con_roociCtx[conID] &&
        !rodbiAssertCon((pctx->con_roociCtx[conID])->parent_roociCon, 
                        __func__, 1))
    {   
      roociTerminateCon(pctx->con_roociCtx[conID], FALSE);
      pctx->con_roociCtx[conID] = NULL;
    }   

  /* find next available connection ID */
  for (conID = 0; conID < pctx->max_roociCtx; conID++)
    if (!pctx->con_roociCtx[conID])
      break;

  /* check vector size */
  if (conID == pctx->max_roociCtx)
  {
    ROOCI_MEM_ALLOC(conTemp, (2*pctx->max_roociCtx), sizeof(roociCon *));
    if (!conTemp)
      return ROOCI_DRV_ERR_MEM_FAIL;

    memcpy(conTemp, pctx->con_roociCtx, 
           (size_t)pctx->max_roociCtx*sizeof(roociCon *));
    ROOCI_MEM_FREE(pctx->con_roociCtx);
    pctx->con_roociCtx = conTemp;
    pctx->max_roociCtx = 2*pctx->max_roociCtx;
  }
  conTemp = NULL;

  return conID;
} /* end roociNewConID */

/* ---------------------------- roociNewResID ----------------------------- */

static int roociNewResID(roociCon *pcon)
{
  roociRes  **resTemp;
  int         resID;

  /* check result validity */
  for (resID = 0; resID < pcon->max_roociCon; resID++)
  {
    if (pcon->res_roociCon[resID] &&
        !rodbiAssertRes((pcon->res_roociCon[resID])->parent_roociRes,
                         __func__, 1))
    { 
      roociResFree(pcon->res_roociCon[resID]);
      pcon->res_roociCon[resID] = NULL;
    }
  }

  /* find next available result ID */
  for (resID = 0; resID < pcon->max_roociCon; resID++)
    if (!pcon->res_roociCon[resID])
      break;

  /* check vector size */
  if (resID == pcon->max_roociCon)
  {
    ROOCI_MEM_ALLOC(resTemp, (2*pcon->max_roociCon), sizeof(roociRes *)); 
    if (!resTemp)
      return ROOCI_DRV_ERR_MEM_FAIL;

    memcpy(resTemp, pcon->res_roociCon, 
           (size_t)pcon->max_roociCon*sizeof(roociRes *));
    ROOCI_MEM_FREE(pcon->res_roociCon);
    pcon->res_roociCon = resTemp;
    pcon->max_roociCon = 2*pcon->max_roociCon;
  }

  return resID;
} /* end roociNewResID */

/* ----------------------------- roociInitializeCtx ----------------------- */

sword roociInitializeCtx (roociCtx *pctx, void *epx, boolean interrupt_srv,
                          boolean unicode_as_utf8, boolean ora_objects)
{
  sword    rc = OCI_ERROR;
  ub4      mode = OCI_DEFAULT;

  /* create OCI environment */
  if (epx)
  {
    rc = OCIExtProcGetEnv(epx, &pctx->env_roociCtx, &pctx->svc_roociCtx,
                          &pctx->err_roociCtx);
    pctx->extproc_roociCtx = TRUE;
  }
  else
  {
    ub2 csid;

    if (ora_objects)
      mode |= OCI_OBJECT;

    if (unicode_as_utf8)
    {
      rc = OCINlsEnvironmentVariableGet((void *)&csid, sizeof(csid),
                                        (ub2)OCI_NLS_CHARSET_ID, (ub2)0,
                                        (size_t *)0);

      if (rc == OCI_SUCCESS)
        /* Create env handle using default chracater set & AL32UTF8 NCHAR */
        rc = OCIEnvNlsCreate(&pctx->env_roociCtx, mode,
                             NULL, NULL, NULL, NULL, (size_t)0, (void **)NULL,
                             csid, (ub2)873);
      else
        /* On failure use OCIEnvCreate */
        rc = OCIEnvCreate(&pctx->env_roociCtx, mode, NULL, 
                          NULL, NULL, NULL, (size_t)0, (void **)NULL);
    }
    else
      rc = OCIEnvCreate(&pctx->env_roociCtx, mode, NULL, 
                        NULL, NULL, NULL, (size_t)0, (void **)NULL);
  }

  if (rc == OCI_SUCCESS)
  {  
    /* get OCI client version */
    OCIClientVersion(&pctx->ver_roociCtx.maj_roociloadVersion,
                     &pctx->ver_roociCtx.minor_roociloadVersion,
                     &pctx->ver_roociCtx.update_roociloadVersion,
                     &pctx->ver_roociCtx.patch_roociloadVersion,
                     &pctx->ver_roociCtx.port_roociloadVersion);
    pctx->compiled_maj_roociCtx = OCI_MAJOR_VERSION;
    pctx->compiled_min_roociCtx = OCI_MINOR_VERSION;
    
    /* allocate connection vector */
    ROOCI_MEM_ALLOC(pctx->con_roociCtx, ROOCI_CON_DEF, sizeof(roociCon *));
    if (!(pctx->con_roociCtx))
    {
      if (!epx)
        OCIHandleFree(pctx->env_roociCtx, OCI_HTYPE_ENV);
      pctx->env_roociCtx = (OCIEnv *)0;
      return ROOCI_DRV_ERR_MEM_FAIL;
    }
    else
    {
      pctx->max_roociCtx       = ROOCI_CON_DEF;
      pctx->control_c_roociCtx = interrupt_srv;
    }
  }

  return rc;
} /* end of roociInitializeCtx */

/* ----------------------------- roociInitializeCon ----------------------- */

sword roociInitializeCon(roociCtx *pctx, roociCon *pcon,
                         char *user, char *pass, char *cstr,
                         ub4 stmt_cache_siz, ub4 session_mode)
{
  sword     rc                             = OCI_ERROR; 
  int       conid;
  char      srvVersion [ROOCI_VERSION_LEN] = "";
  void     *temp                           = NULL;
                              /* pointer to remove strict-aliasing warnings */

  /* update driver reference in connection context */
  pcon->ctx_roociCon = pctx;

  /* get connection ID */
  conid = roociNewConID(pctx);
  if (conid == ROOCI_DRV_ERR_MEM_FAIL)
    return ROOCI_DRV_ERR_MEM_FAIL;
  else
    pcon->conID_roociCon = conid;

  /* set error handle */
  if (pctx->extproc_roociCtx)
    pcon->err_roociCon = pctx->err_roociCtx;
  else
  {
    /* allocate error handle */
    rc = OCIHandleAlloc(pctx->env_roociCtx, (void **)&temp,
                        OCI_HTYPE_ERROR, (size_t)0, (void **)NULL);
    if (rc == OCI_ERROR)
      return rc;
    pcon->err_roociCon  = temp;
  }

  /* set service context handle */
  if (pctx->extproc_roociCtx)
    pcon->svc_roociCon = pctx->svc_roociCtx;
  else
  {
    /* allocate authentication handle */
    temp  = NULL;
    rc = OCIHandleAlloc(pctx->env_roociCtx, (void **)&temp, 
                        OCI_HTYPE_AUTHINFO, (size_t)0, (void **)NULL);
    if (rc == OCI_ERROR)
      return ROOCI_DRV_ERR_CON_FAIL;
    pcon->auth_roociCon = temp;

    /* set username */
    rc = OCIAttrSet((void *)(pcon->auth_roociCon), OCI_HTYPE_AUTHINFO,
                    (void *)user, strlen(user), OCI_ATTR_USERNAME, 
                    pcon->err_roociCon);
    if (rc == OCI_ERROR)
      return ROOCI_DRV_ERR_CON_FAIL;

    /* set password */
    rc = OCIAttrSet(pcon->auth_roociCon, OCI_HTYPE_AUTHINFO, (void *)pass, 
                    strlen(pass), OCI_ATTR_PASSWORD, pcon->err_roociCon);
    if (rc == OCI_ERROR)
      return ROOCI_DRV_ERR_CON_FAIL;

#if OCI_MAJOR_VERSION > 10
    /* set driver name */
    rc = OCIAttrSet(pcon->auth_roociCon, OCI_HTYPE_AUTHINFO,
                    (void *)"ROracle", sizeof("ROracle") - 1, 
                    OCI_ATTR_DRIVER_NAME, pcon->err_roociCon);
    if (rc == OCI_ERROR)
      return ROOCI_DRV_ERR_CON_FAIL;
#endif

    /* start user session */
    rc = OCISessionGet(pctx->env_roociCtx, pcon->err_roociCon, 
                       &pcon->svc_roociCon, pcon->auth_roociCon, 
                       (OraText *)cstr, strlen(cstr), 
                       NULL, 0, NULL, NULL, NULL, session_mode);
    if (rc == OCI_ERROR)
    return ROOCI_DRV_ERR_CON_FAIL;
  }

  /* TimesTen IMDB or Oracle RDBMS connection? */
  pcon->timesten_rociCon = FALSE;
  rc =  OCIServerVersion ((void*)pcon->svc_roociCon, pcon->err_roociCon,
                          (OraText *)&srvVersion, sizeof(srvVersion),
                          OCI_HTYPE_SVCCTX);
  if (rc == OCI_ERROR)
    return ROOCI_DRV_ERR_CON_FAIL;

  if (strstr (srvVersion, ROOCI_TIMESTEN_ID) != NULL)
    pcon->timesten_rociCon = TRUE;

  /* enable statement caching by setting cache size */
  rc = OCIAttrSet((void*)pcon->svc_roociCon, OCI_HTYPE_SVCCTX,
                  (void *)&stmt_cache_siz, (ub4)0, OCI_ATTR_STMTCACHESIZE,
                  pcon->err_roociCon);
  if (rc == OCI_ERROR)
    return ROOCI_DRV_ERR_CON_FAIL;

  /* get session handle */
  rc = OCIAttrGet(pcon->svc_roociCon, OCI_HTYPE_SVCCTX,
                  (void *)&pcon->usr_roociCon, NULL, OCI_ATTR_SESSION, 
                  pcon->err_roociCon);
  if (rc == OCI_ERROR)
    return ROOCI_DRV_ERR_CON_FAIL;

  /* set connection string */
  ROOCI_MEM_ALLOC(pcon->cstr_roociCon, (strlen(cstr) + 1), sizeof(char));
  if (!(pcon->cstr_roociCon))
    return ROOCI_DRV_ERR_MEM_FAIL;
  
  memcpy(pcon->cstr_roociCon, cstr, strlen(cstr));

  /* allocate result vector */
  ROOCI_MEM_ALLOC(pcon->res_roociCon, ROOCI_RES_DEF, sizeof(roociRes *));
  if (!(pcon->res_roociCon))
    return ROOCI_DRV_ERR_MEM_FAIL;

  /* get character maximum byte size */
  rc = OCINlsNumericInfoGet(pctx->env_roociCtx, pcon->err_roociCon, 
                            &(pcon->nlsmaxwidth_roociCon),
                            OCI_NLS_CHARSET_MAXBYTESZ);
  if (rc == OCI_ERROR)
    return ROOCI_DRV_ERR_CON_FAIL;

  /* add to the connections vector */
  pctx->con_roociCtx[pcon->conID_roociCon] = pcon;

  /* bump up the number of open/total connections */
  pctx->num_roociCtx++;
  pctx->tot_roociCtx++;

  pcon->max_roociCon = ROOCI_RES_DEF; 
  pctx->acc_roociCtx.conID_roociConAccess = ROOCI_RES_DEF;

  return rc;
} /* end of roociInitializeCon */

/*----------------------------roociGetError-------------------------------- */

sword roociGetError(roociCtx *pctx, roociCon *pcon, const char *msgText,
                    sb4 *errNum, text *errMsg, ub4 errMsgSize)
{
  sword rc = OCI_ERROR;  
#ifdef DEBUG
  text  msg[ROOCI_ERR_LEN];
#endif

  /* if error handle defined */
  if (pcon && pcon->err_roociCon)
  {
    rc =  OCIErrorGet(pcon->err_roociCon, 1, (text *)NULL, errNum, 
                      errMsg, errMsgSize, (ub4)OCI_HTYPE_ERROR);
#ifdef DEBUG
  fprintf(stdout, "err_roociCon=%p errMsgSize=%d\n", pcon->err_roociCon, errMsgSize);
    snprintf(msg, ROOCI_ERR_LEN, "%s: %s\n", msgText, errMsg);
#endif
  } 
  else if (!pcon && (pctx && pctx->env_roociCtx)) /* if environment handle defined */
  {
    rc =  OCIErrorGet(pctx->env_roociCtx, 1, (text *)NULL, errNum, 
                      errMsg, errMsgSize, (ub4)OCI_HTYPE_ENV);
#ifdef DEBUG
    snprintf(msg, ROOCI_ERR_LEN, "%s: %s\n", msgText, errMsg);
#endif
  }

  if (*errNum == 1403 || rc == OCI_NO_DATA)                /* no data found */ 
  {
    *errNum = 0;
    strcpy((char *)errMsg,"");
    rc      = 0;
  }

#ifdef DEBUG
    fprintf(stdout, "%s", msg);
#endif
  return rc;
} /* end of roociGetError */

/* -------------------------- roociGetConInfo ----------------------------- */

sword roociGetConInfo(roociCon *pcon, text **user, ub4 *userLen,
                      text *verServer, ub4 *stmt_cache_size)
{
  sword     rc  = OCI_ERROR;
  ub4       ver = 0;

  /* get username */
  if (user)
  {
    rc = OCIAttrGet((void *)(pcon->usr_roociCon), OCI_HTYPE_SESSION, user,
                    userLen, OCI_ATTR_USERNAME, pcon->err_roociCon);
    if (rc == OCI_ERROR)
      return rc;
  }

  /* get server release version */
  if (verServer)
  {
    rc = OCIServerRelease(pcon->svc_roociCon, pcon->err_roociCon, verServer,
                          ROOCI_VERSION_LEN, OCI_HTYPE_SVCCTX, &ver);
    if (rc == OCI_ERROR)
      return rc;
  
    snprintf((char *)verServer, ROOCI_VERSION_LEN,
             "%d.%d.%d.%d.%d", ROOCI_MAJOR_NUMVSN(ver), ROOCI_MINOR_NUMRLS(ver),
             ROOCI_UPDATE_NUMUPD(ver), ROOCI_PORT_REL_NUMPRL(ver),
             ROOCI_PORT_UPDATE_NUMPUP(ver));
  }

  /* get statement cache size */
  if (stmt_cache_size)
  {
    rc = OCIAttrGet (pcon->svc_roociCon, OCI_HTYPE_SVCCTX, 
                     (void *)stmt_cache_size, 0, OCI_ATTR_STMTCACHESIZE,
                     pcon->err_roociCon);
    if (rc == OCI_ERROR)
      return rc;
  }

  return rc;

} /* end of roociGetConInfo */

/* --------------------- roociAllocateDateTimeDescriptors ------------------ */
static sword roociAllocateDateTimeDescriptors(roociRes *pres)
{
  sword     rc    = OCI_SUCCESS;
  roociCon *pcon  = pres->con_roociRes;
  roociCtx *pctx  = pcon->ctx_roociCon;
  void     *temp  = NULL;      /* pointer to remove strict-aliasing warning */

  /* allocate POSIXct beginning datetime descriptor and interval descriptor */
  rc = OCIDescriptorAlloc(pctx->env_roociCtx, (void **)&temp,
                          pcon->timesten_rociCon ? OCI_DTYPE_TIMESTAMP :
                                                   OCI_DTYPE_TIMESTAMP_LTZ,
                          0, NULL);
  if (rc == OCI_ERROR)
    return rc;

  pres->epoch_roociRes = temp;
    
  /* construct the beginning of 1970 (in the UTC timezone) */
  rc = OCIDateTimeConstruct(pcon->usr_roociCon, pcon->err_roociCon,
                            pres->epoch_roociRes, 1970, 1, 1, 0, 0, 0, 0,
                            (OraText*)"+00:00", 6);
  if (rc == OCI_ERROR) 
  {
    OCIDescriptorFree(pres->epoch_roociRes,
                      pcon->timesten_rociCon ? OCI_DTYPE_TIMESTAMP :
                                               OCI_DTYPE_TIMESTAMP_LTZ);
    pres->epoch_roociRes = NULL;
    return rc;
  }

  temp = NULL;
  rc = OCIDescriptorAlloc(pctx->env_roociCtx, (void **)&temp,
                          OCI_DTYPE_INTERVAL_DS, 0, NULL);
  if (rc == OCI_ERROR) 
  {
    OCIDescriptorFree(pres->epoch_roociRes,
                      pcon->timesten_rociCon ? OCI_DTYPE_TIMESTAMP :
                                               OCI_DTYPE_TIMESTAMP_LTZ);
    pres->epoch_roociRes = NULL;
    return rc;
  }

  pres->diff_roociRes = temp;

  if (pcon->timesten_rociCon)
  {
    sb1          tzhr = 0;
    sb1          tzmm = 0;
    OCIDateTime *systime;

    temp  = NULL;
    rc = OCIDescriptorAlloc(pctx->env_roociCtx, (void **)&temp,
                           OCI_DTYPE_TIMESTAMP_TZ, 0, NULL);
    if (rc == OCI_SUCCESS)
    {
      systime = temp;

      /* get the current datetime containing the OCI environment's timezone */
      rc = OCIDateTimeSysTimeStamp(pctx->env_roociCtx, pcon->err_roociCon,
                                   systime);
      if (rc == OCI_ERROR)
        OCIDescriptorFree (systime, OCI_DTYPE_TIMESTAMP_TZ);
      else
      {
        /* get the offsets for the OCI environment's timezone */
        rc = OCIDateTimeGetTimeZoneOffset(pctx->env_roociCtx, 
                                          pcon->err_roociCon,
                                          systime, &tzhr, &tzmm);
        OCIDescriptorFree(systime, OCI_DTYPE_TIMESTAMP_TZ);
        if (rc == OCI_SUCCESS)
          /* this may be a positive or a negative value depending on 
           * local time */
          pcon->secs_UTC_roociCon = 
                                ((double)tzhr * 3600.0) + ((double)tzmm * 60.0);
      }
    }
  }

  if (rc == OCI_ERROR) 
  {
    OCIDescriptorFree(pres->epoch_roociRes,
                      pcon->timesten_rociCon ? OCI_DTYPE_TIMESTAMP :
                                               OCI_DTYPE_TIMESTAMP_LTZ);
    pres->epoch_roociRes = NULL;
    OCIDescriptorFree(pres->diff_roociRes, OCI_DTYPE_INTERVAL_DS);
    pres->diff_roociRes = NULL;
    return rc;
  }

  return rc;
} /* end of roociAllocateDateTimeDescriptors */


/* -------------------------- roociInitializeRes -------------------------- */

sword roociInitializeRes(roociCon *pcon, roociRes *pres, text *qry, int qrylen,
                         ub1 qry_encoding, ub2 *styp, boolean prefetch,
                         int rows_per_fetch, int rows_per_write)
{
  sword rc = OCI_ERROR;

  /* get result ID */
  rc = roociNewResID(pcon);
  if (pres->resID_roociRes == ROOCI_DRV_ERR_MEM_FAIL)
    return ROOCI_DRV_ERR_MEM_FAIL;
  else
    pres->resID_roociRes = rc;

  pres->prefetch_roociRes    = prefetch;
  pres->nrows_roociRes       = rows_per_fetch;
  pres->nrows_write_roociRes = rows_per_write;

  if (qry_encoding == ROOCI_QRY_NATIVE)
    /* prepare statement */
    rc = OCIStmtPrepare2(pcon->svc_roociCon, &pres->stm_roociRes,
                         pcon->err_roociCon, qry, (ub4)qrylen,
                         NULL, 0, OCI_NTV_SYNTAX, OCI_DEFAULT);
  else
  {
    text   *xlatqry;
    size_t  xlatqrylen;
    boolean conv_needed = FALSE;
    ub2     envcsid;
    ub2     cnvcid        = 0;

    rc = OCIAttrGet(pcon->ctx_roociCon->env_roociCtx, OCI_HTYPE_ENV, 
                    (void *)&envcsid, NULL,
                    OCI_ATTR_ENV_CHARSET_ID, pcon->err_roociCon);
    if (rc == OCI_ERROR)
      return rc;

    if (qry_encoding == ROOCI_QRY_UTF8)
    {
      cnvcid = OCINlsCharSetNameToId(pcon->ctx_roociCon->env_roociCtx,
                                     (const oratext *)"AL32UTF8");
      conv_needed = (boolean)(envcsid != cnvcid);
    }
     else if (qry_encoding == ROOCI_QRY_LATIN1)
    {
      cnvcid = OCINlsCharSetNameToId(pcon->ctx_roociCon->env_roociCtx,
                                     (const oratext *)"WE8ISO8859P1");

      if (envcsid != cnvcid)
      {
        cnvcid = OCINlsCharSetNameToId(pcon->ctx_roociCon->env_roociCtx,
                                       (const oratext *)"WE8MSWIN1252");
        if (envcsid != cnvcid)
          conv_needed = TRUE;
      }
    }

    if (conv_needed)
    {
      /* FIXME: Multiply by ratio of 4. There is no OCI API to get max width */
      ROOCI_MEM_ALLOC(xlatqry, qrylen * 4, sizeof(ub1));
      xlatqrylen = qrylen;
      rc = OCINlsCharSetConvert(pcon->ctx_roociCon->env_roociCtx,
                                pcon->err_roociCon, envcsid,
                                (void *)xlatqry, xlatqrylen, cnvcid,
                                (const void *)qry, (size_t)qrylen,
                                &xlatqrylen);
      if (rc == OCI_SUCCESS)
      {
        /* prepare statement */
        rc = OCIStmtPrepare2(pcon->svc_roociCon, &pres->stm_roociRes, 
                             pcon->err_roociCon, xlatqry, (ub4)xlatqrylen, 
                             NULL, 0, OCI_NTV_SYNTAX, OCI_DEFAULT);
        ROOCI_MEM_FREE(xlatqry);
      }
      else
      {
        ROOCI_MEM_FREE(xlatqry);
        return rc;
      }
    }
    else
      /* prepare statement */
      rc = OCIStmtPrepare2(pcon->svc_roociCon, &pres->stm_roociRes,
                           pcon->err_roociCon, qry, (ub4)qrylen,
                           NULL, 0, OCI_NTV_SYNTAX, OCI_DEFAULT);
  }

  if (rc == OCI_ERROR)
    return rc;

  /* get statement type */
  rc = OCIAttrGet(pres->stm_roociRes, OCI_HTYPE_STMT, 
                  (void *)styp, NULL,
                  OCI_ATTR_STMT_TYPE, pcon->err_roociCon);
  if (rc == OCI_ERROR)
  {
    OCIStmtRelease(pres->stm_roociRes, pcon->err_roociCon,
                  (OraText *)NULL, 0, OCI_DEFAULT);
    pres->stm_roociRes = NULL;
    return rc;
  }

  /* get bind count */
  rc = OCIAttrGet(pres->stm_roociRes, OCI_HTYPE_STMT, 
                  (void *)&pres->bcnt_roociRes, NULL,
                  OCI_ATTR_BIND_COUNT, pcon->err_roociCon);
  if (rc == OCI_ERROR)
  {
    OCIStmtRelease(pres->stm_roociRes, pcon->err_roociCon,
                   (OraText *)NULL, 0, OCI_DEFAULT);
    pres->stm_roociRes = NULL;
    return rc;
  }

  pcon->res_roociCon[pres->resID_roociRes] = pres;

  /* update connection reference in result context */
  pres->con_roociRes = pcon;
    
  return rc;
} /* end of roociInitializeRes */


/* -------------------------- roociExecTTOpt ------------------------------ */

sword roociExecTTOpt(roociCon *pcon)
{
  sword         rc     = OCI_ERROR;
  OCIStmt      *stmthp = NULL;
  void         *temp   = NULL; /* pointer to remove strict-aliasing warning */
  const OraText opthint [] = "CALL ttOptSetFlag ('RowLock', 0)";

  rc = OCIHandleAlloc((void *)pcon->ctx_roociCon->env_roociCtx,
                      (void **)&temp, OCI_HTYPE_STMT, 0, 0);
  if (rc != OCI_SUCCESS)
    return rc;
  stmthp  = temp;

  /* tell the TimesTen optimizer to turn off row locks */
  rc = OCIStmtPrepare(stmthp, pcon->err_roociCon,
                      (const OraText *)opthint, sizeof (opthint),
                       OCI_NTV_SYNTAX, OCI_DEFAULT);
  if (rc == OCI_ERROR)
  {
    OCIHandleFree((void *)stmthp, OCI_HTYPE_STMT);
    return rc;
  }

  rc = OCIStmtExecute(pcon->svc_roociCon, stmthp, pcon->err_roociCon, 1, 0,
                      NULL, NULL, OCI_DEFAULT);

  OCIHandleFree((void *)stmthp, OCI_HTYPE_STMT);

  return rc;
} /* end of roociExecTTOpt */


/* ----------------------------- roociTerminateCtx ------------------------ */

sword roociTerminateCtx(roociCtx *pctx)
{
  sword rc    = OCI_SUCCESS;
  int   conID = 0;

  /* free connection vector */
  if (pctx->con_roociCtx)
  {
    for(conID = 0; conID < pctx->max_roociCtx; conID++)
    {
      if (pctx->con_roociCtx[conID])
      {
        rc = roociTerminateCon(pctx->con_roociCtx[conID], TRUE);
        if (rc == OCI_ERROR)
          return rc;
      }
    }
    ROOCI_MEM_FREE(pctx->con_roociCtx);
  }

  /* free environment handle */
  if (pctx->env_roociCtx && !pctx->extproc_roociCtx)
    rc = OCIHandleFree(pctx->env_roociCtx, OCI_HTYPE_ENV);

  return rc;
} /* end of roociTerminateCtx */

/* -------------------------- roociTerminateCon --------------------------- */

sword roociTerminateCon(roociCon *pcon, boolean validCon)
{
  sword      rc   = OCI_SUCCESS;
  int        resID;
  roociCtx  *pctx = pcon->ctx_roociCon;

  /* free connect string */
  if (pcon->cstr_roociCon)
  {
    ROOCI_MEM_FREE(pcon->cstr_roociCon);
  }
    
  /* clean up results */
  if (pcon->res_roociCon)
  {
    for (resID = 0; resID < pcon->max_roociCon; resID++)
    {    
      if (pcon->res_roociCon[resID])
      {    
        rc = roociResFree(pcon->res_roociCon[resID]);
        if (rc == OCI_ERROR)
          return rc;
      }    
    }    

    /* free result vector */
    ROOCI_MEM_FREE(pcon->res_roociCon);
  }

  /* release service context session */
  if (pcon->svc_roociCon && !pctx->extproc_roociCtx)
  {
    rc = OCISessionRelease(pcon->svc_roociCon, pcon->err_roociCon, NULL, 
                           0, OCI_DEFAULT);
    if (rc == OCI_ERROR)
      return rc;
  }

  /* free authentication handle */    
  if (pcon->auth_roociCon && !pctx->extproc_roociCtx)
  {
    rc = OCIHandleFree(pcon->auth_roociCon, OCI_HTYPE_AUTHINFO);
    if (rc == OCI_ERROR)
      return rc;
  }

  /* free error handle */
  if (pcon->err_roociCon && !pctx->extproc_roociCtx)
  {
    rc = OCIHandleFree(pcon->err_roociCon, OCI_HTYPE_ERROR);
    if (rc == OCI_ERROR)
      return rc;
  }
  
  pctx->con_roociCtx[pcon->conID_roociCon] = NULL;
    
  if (validCon == TRUE)
    pctx->num_roociCtx--;

  return rc;
} /* end of roociTerminateCon */

/* -------------------------- roociCommitCon ------------------------------ */

sword roociCommitCon(roociCon *pcon)
{
  sword rc = OCI_ERROR;
  rc = OCITransCommit(pcon->svc_roociCon, pcon->err_roociCon, OCI_DEFAULT);
  return rc;
} /* end of roociCommitCon */


/* -------------------------- roociRollbackCon ----------------------------- */

sword roociRollbackCon(roociCon *pcon)
{
  sword rc = OCI_ERROR;
  rc = OCITransRollback(pcon->svc_roociCon, pcon->err_roociCon, OCI_DEFAULT);
  return rc;
} /* end of roociRollbackCon */

/* ------------------------- roociStmtExec -------------------------------- */

sword roociStmtExec(roociRes *pres, ub4 noOfRows, ub2 styp, int *rows_affected)
{
  sword         rc              = OCI_ERROR;
  roociThrCtx   thrCtx;
  ub4           aff_rows        = 0;
  ub4           RowsToFetch     = 
                        pres->prefetch_roociRes ? pres->nrows_roociRes : 0;
  roociCon     *pcon            = pres->con_roociRes;

  rc = OCIAttrSet(pres->stm_roociRes, OCI_HTYPE_STMT, &RowsToFetch, 0,
                  OCI_ATTR_PREFETCH_ROWS, pcon->err_roociCon);
  if (rc == OCI_ERROR)
    return rc;

  /* set up the thread context */
  thrCtx.pcon_roociThrCtx      = pcon;
  thrCtx.pres_roociThrCtx      = pres;
  thrCtx.nrows_roociThrCtx     = noOfRows;
  thrCtx.styp_roociThrCtx      = styp;
  thrCtx.aff_rows_roociThrCtx  = &aff_rows;
  thrCtx.bExecOver_roociThrCtx = FALSE;
  thrCtx.tid_roociThrCtx       = NULL;
  thrCtx.thdhp_roociThrCtx     = NULL;

  /*
  ** With threaded execution, R seems to be way too slow, check with
  ** R Development first before enabling it.
  */
  if (pcon->ctx_roociCon->control_c_roociCtx)
  {
    /* begin a thread to execute the query */
    rc = roociBeginThrdHndler(&thrCtx);

    /* Wait for query to finish or user to interrupt it */
    roociThrCtrlCHandler((void *)&thrCtx);


    OCIThreadJoin(pcon->ctx_roociCon->env_roociCtx,
                  pcon->err_roociCon, thrCtx.thdhp_roociThrCtx);
  }
  else
    roociThrExecCmd(&thrCtx);

  *rows_affected = (int)aff_rows;
  return thrCtx.rc_roociThrCtx;
} /* end of roociStmtExec */

/* --------------------------- roociBindData ------------------------------ */

sword roociBindData(roociRes *pres, ub4 bufPos, ub1 form_of_use,
                    const char *name)
{
  OCIBind   *bndp;
  sword      rc;
  roociCon  *pcon = pres->con_roociRes;
  void      *bind_data;

  if (pres->btyp_roociRes[bufPos-1].extyp_roociColType == SQLT_RSET)
  {
    /* REF CURSORs are bound to a statement handle for later data retrieval 
     * with a bind datatype of SQLT_RSET and CursorPosition is used to address 
     * statement handle for a particular cursor (multiple cursors scenario) */
    int CursorPosition = pres->bsiz_roociRes[bufPos-1];

    /* Bug 22329115 */
    /* stm_cur_roociRes addresses to pool of statement handles which are bound 
     * to each REF CURSOR for later data retrieval */
    rc = OCIHandleAlloc((void *)pres->con_roociRes->ctx_roociCon->env_roociCtx,
                        (void **)&pres->stm_cur_roociRes[CursorPosition-1],
                        OCI_HTYPE_STMT, 0, 0);
    if (rc == OCI_ERROR)
      return rc;
    else
      bind_data = (void *)&pres->stm_cur_roociRes[CursorPosition-1];
  }
  else
    bind_data = (void *)pres->bdat_roociRes[bufPos-1];

  /* bind data */
  if (name)
  {
    /* since ora.parameter_name is given, so use OCIBindByName */
    rc = OCIBindByName(pres->stm_roociRes, &bndp, pcon->err_roociCon,
                       (const OraText *)name,
                       (sb4)-1, bind_data, pres->bsiz_roociRes[bufPos-1],
                       (pres->btyp_roociRes[bufPos-1].bndflg_roociColType &
                         ROOCI_COL_VEC_AS_CLOB) ?
                           SQLT_CLOB : 
                           pres->btyp_roociRes[bufPos-1].extyp_roociColType,
                       pres->bind_roociRes[bufPos-1],
                       ((pres->btyp_roociRes[bufPos-1].extyp_roociColType == SQLT_LVC) ||
                       (pres->btyp_roociRes[bufPos-1].extyp_roociColType == SQLT_LVB)) ? 0 : 
                       pres->alen_roociRes[bufPos-1],
                       NULL, (ub4)0, NULL, OCI_DEFAULT);
  }
  else
  {
    rc = OCIBindByPos(pres->stm_roociRes, &bndp, pcon->err_roociCon, bufPos,
                      bind_data, pres->bsiz_roociRes[bufPos-1],
                      (pres->btyp_roociRes[bufPos-1].bndflg_roociColType &
                       ROOCI_COL_VEC_AS_CLOB) ?
                         SQLT_CLOB : 
                         pres->btyp_roociRes[bufPos-1].extyp_roociColType,
                      pres->bind_roociRes[bufPos-1],
                      ((pres->btyp_roociRes[bufPos-1].extyp_roociColType == SQLT_LVC) ||
                      (pres->btyp_roociRes[bufPos-1].extyp_roociColType == SQLT_LVB)) ? 0 :
                      pres->alen_roociRes[bufPos-1],
                      NULL, (ub4)0, NULL, OCI_DEFAULT);
  }

  if (rc == OCI_ERROR)
    return rc;

  if (pres->btyp_roociRes[bufPos-1].extyp_roociColType == SQLT_NTY)
  {
    rc = OCIBindObject(bndp, pcon->err_roociCon,
            pres->btyp_roociRes[bufPos-1].obtyp_roociColType.otyp_roociObjType,
            (void **)bind_data, NULL,
            (void **)pres->objbind_roociRes[bufPos-1], 0);
  }

  if (rc == OCI_ERROR)
    return rc;
  else if (form_of_use)
    rc = OCIAttrSet(bndp, (ub4)OCI_HTYPE_BIND, &form_of_use, (ub4)0,
                    (ub4)OCI_ATTR_CHARSET_FORM, pcon->err_roociCon);

  return rc;
} /* end of roociBindData */

/* ----------------------------- roociResDefine --------------------------- */

sword roociResDefine(roociRes *pres)
{
  ub2             etyp              = SQLT_CHR;
  int             cid;
  sword           rc                = OCI_ERROR;
  OCIDefine      *defp;                                    /* define handle */
  OCILobLocator **lob;
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
  OCIVector     **lvec;
#endif
  int             nrows;
  void          **tsdt;
  roociCon       *pcon              = pres->con_roociRes;
  roociCtx       *pctx              = pcon->ctx_roociCon;
  int             fcur              = 0;
  ub1            *dat               = NULL; 

  /* get number of columns */
  /* if cursor is present, use statement handle bound to that cursor */
  pres->curstm_roociRes = (pres->stm_cur_roociRes ? *pres->stm_cur_roociRes :
                    pres->stm_roociRes);
  rc = OCIAttrGet(pres->curstm_roociRes, OCI_HTYPE_STMT, &pres->ncol_roociRes,
                  NULL, OCI_ATTR_PARAM_COUNT, pcon->err_roociCon);
  if (rc == OCI_ERROR)
    return rc;

  /* allocate column vectors */
  ROOCI_MEM_ALLOC(pres->typ_roociRes, pres->ncol_roociRes, 
                  sizeof(roociColType));
  ROOCI_MEM_ALLOC(pres->form_roociRes, pres->ncol_roociRes, sizeof(ub1));
  ROOCI_MEM_ALLOC(pres->dat_roociRes, pres->ncol_roociRes, sizeof(void *));
  ROOCI_MEM_ALLOC(pres->ind_roociRes, pres->ncol_roociRes, sizeof(sb2 *));
  ROOCI_MEM_ALLOC(pres->len_roociRes, pres->ncol_roociRes, sizeof(ub2 *));
  ROOCI_MEM_ALLOC(pres->siz_roociRes, pres->ncol_roociRes, sizeof(sb4));

  if (!pres->typ_roociRes  || !pres->form_roociRes || !pres->dat_roociRes ||
      !pres->ind_roociRes  || !pres->len_roociRes  || !pres->siz_roociRes)
    return ROOCI_DRV_ERR_MEM_FAIL;

  /* describe columns */
  for (cid = 0; cid < pres->ncol_roociRes; cid++)
  {
    /* get column parameters */
    rc = roociDescCol(pres, (ub4)(cid + 1), &etyp, NULL, NULL, NULL, 
                      NULL, NULL, NULL, &pres->form_roociRes[cid]);
    if (rc != OCI_SUCCESS)
      return rc;

    nrows = pres->prefetch_roociRes ? 1 : pres->nrows_roociRes;
    /* allocate define buffers */
    ROOCI_MEM_ALLOC(pres->dat_roociRes[cid], 
                    (nrows* pres->siz_roociRes[cid]), sizeof(ub1));
    ROOCI_MEM_ALLOC(pres->ind_roociRes[cid], nrows, sizeof(sb2));
    ROOCI_MEM_ALLOC(pres->len_roociRes[cid], nrows, sizeof(ub2));

    if (!pres->dat_roociRes[cid] || !pres->ind_roociRes[cid] ||
        !pres->len_roociRes[cid])
      return ROOCI_DRV_ERR_MEM_FAIL;

    /* allocate LOB locators */
    if ((etyp == SQLT_CLOB) ||
        (etyp == SQLT_BLOB) ||
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
        (etyp == SQLT_VEC) ||
#endif /* OCI_MAJOR_VERSION >= 23 */
        (etyp == SQLT_BFILE))
    {
      pres->nocache_roociRes = TRUE;

#if OCI_MAJOR_VERSION > 10
# if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
      if (etyp == SQLT_VEC)
      {
        lvec = (OCIVector **)(pres->dat_roociRes[cid]);
        rc  = OCIArrayDescriptorAlloc(pctx->env_roociCtx, (void **)lvec,
                                      OCI_DTYPE_VECTOR, nrows, 0, NULL);
      }
      else
# endif /* OCI_MAJOR_VERSION >= 23 */
      {
        lob = (OCILobLocator **)(pres->dat_roociRes[cid]);
        rc  = OCIArrayDescriptorAlloc(pctx->env_roociCtx, (void **)lob,
                                      (etyp == SQLT_BFILE) ? OCI_DTYPE_FILE :
                                                             OCI_DTYPE_LOB,
                                      nrows, 0, NULL);
      }
      if (rc == OCI_ERROR)
        return rc;
#else
      dat = (ub1 *)pres->dat_roociRes[cid];
      for (fcur = 0; fcur < nrows; fcur++)
      {
# if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
        if (etyp == SQLT_VEC)
        {
          lvec = (OCILobLocator **)(pres->dat_roociRes[cid]);
          rc  = OCIDescriptorAlloc(pctx->env_roociCtx, (void **)lvec,
                                   OCI_DTYPE_VECTOR, 0, NULL);
        }
        else
# endif /* OCI_MAJOR_VERSION >= 23 */
        {
          lob = (OCILobLocator **)(dat + fcur * (pres->siz_roociRes[cid]));
          rc  = OCIDescriptorAlloc(pctx->env_roociCtx, (void **)lob,
                                   (etyp == SQLT_BFILE) ? OCI_DTYPE_FILE :
                                                          OCI_DTYPE_LOB,
                                   0, NULL);
        }

        if (rc == OCI_ERROR)
          return rc;
      }
#endif
    }

    /* allocate OCIDateTime locators */
    if ((etyp == SQLT_TIMESTAMP_LTZ) ||
        (etyp == SQLT_TIMESTAMP)    ||
        (etyp == SQLT_INTERVAL_DS))
    {
#if OCI_MAJOR_VERSION > 10
      tsdt = (void **)(pres->dat_roociRes[cid]);
      if (pcon->timesten_rociCon)
      {
        /* TimesTen does not support SQLT_TIMESTAMP_TZ, use SQLT_TIMESTAMP */
        rc = OCIArrayDescriptorAlloc(pctx->env_roociCtx, (void **)tsdt,
                                     OCI_DTYPE_TIMESTAMP, nrows, 0, NULL);

        /* adjust define type */
        etyp = SQLT_TIMESTAMP;
      }
      else
        rc = OCIArrayDescriptorAlloc(pctx->env_roociCtx, (void **)tsdt,
               (etyp == SQLT_TIMESTAMP_LTZ) ?  OCI_DTYPE_TIMESTAMP_LTZ :
               (etyp == SQLT_TIMESTAMP) ? OCI_DTYPE_TIMESTAMP :
                                          OCI_DTYPE_INTERVAL_DS,
               nrows, 0, NULL);
      if (rc == OCI_ERROR)
        return rc;
#else
      dat = (ub1 *)pres->dat_roociRes[cid];
      tsdt = (void **)(dat + fcur * (pres->siz_roociRes[cid]));

      for (fcur = 0; fcur < nrows; fcur++)
      {
        tsdt = (void **)(dat + fcur * (pres->siz_roociRes[cid]));
        if (pcon->timesten_rociCon)
        {
          /* TimesTen does not support SQLT_TIMESTAMP_TZ, 
             use SQLT_TIMESTAMP */
          rc = OCIDescriptorAlloc(pctx->env_roociCtx, (void **)tsdt,
                                  OCI_DTYPE_TIMESTAMP, 0, NULL);

          /* adjust define type */
          etyp = SQLT_TIMESTAMP;
        }
        else
          rc = OCIDescriptorAlloc(pctx->env_roociCtx, (void **)tsdt,
                 (etyp == SQLT_TIMESTAMP_LTZ) ?  OCI_DTYPE_TIMESTAMP_LTZ :
                 (etyp == SQLT_TIMESTAMP) ? OCI_DTYPE_TIMESTAMP :
                                            OCI_DTYPE_INTERVAL_DS, 0, NULL);
        if (rc == OCI_ERROR)
          return rc;
      }
#endif
    }

    /* define fetch buffers */
    if (etyp == SQLT_NTY ||
        etyp == SQLT_REF)
    {
      void **pobj;
      pres->nocache_roociRes = TRUE;

      dat = (ub1 *)pres->dat_roociRes[cid];
      if (etyp == SQLT_NTY)
      {
        for (fcur = 0; fcur < nrows; fcur++)
        {
          pobj = (void **)(dat + fcur * (pres->siz_roociRes[cid]));
          rc = OCIObjectNew(pctx->env_roociCtx, pcon->err_roociCon,
                 pcon->svc_roociCon,
                 pres->typ_roociRes[cid].obtyp_roociColType.otc_roociObjType,
                 pres->typ_roociRes[cid].obtyp_roociColType.otyp_roociObjType,
                 (void *)NULL, OCI_DURATION_SESSION, FALSE,
                 pobj);
          if (rc == OCI_ERROR)
            return rc;
        }
      }
      else
      {
        for (fcur = 0; fcur < nrows; fcur++)
        {
          pobj = (void **)(dat + fcur * (pres->siz_roociRes[cid]));
          rc = OCIObjectNew(pctx->env_roociCtx, pcon->err_roociCon,
                 pcon->svc_roociCon,
                 OCI_TYPECODE_REF, (OCIType *)0,
                 (void *)NULL, OCI_DURATION_SESSION, FALSE,
                 pobj);
          if (rc == OCI_ERROR)
            return rc;
        }
      }

      rc = OCIDefineByPos(pres->curstm_roociRes, &defp, pcon->err_roociCon,
                          (ub4)(cid + 1), (pres->dat_roociRes[cid]),
                          pres->siz_roociRes[cid], etyp, NULL, NULL,
                          NULL, OCI_DEFAULT);
    }
    else
      rc = OCIDefineByPos(pres->curstm_roociRes, &defp, pcon->err_roociCon,
                          (ub4)(cid + 1), (pres->dat_roociRes[cid]),
                          pres->siz_roociRes[cid], etyp, 
                          pres->ind_roociRes[cid], pres->len_roociRes[cid], 
                          NULL, OCI_DEFAULT);
    if (rc == OCI_ERROR)
      return rc;

    if (etyp == SQLT_NTY)
      rc = OCIDefineObject(defp, pcon->err_roociCon,
                 pres->typ_roociRes[cid].obtyp_roociColType.otyp_roociObjType,
                           (void **)pres->dat_roociRes[cid], NULL, NULL, 0);


    if (etyp == SQLT_REF)
      rc = OCIDefineObject(defp, pcon->err_roociCon, (OCIType *)0,
                           (void **)pres->dat_roociRes[cid], NULL, NULL, 0);


    if (pres->form_roociRes[cid])
    {
      rc = OCIAttrSet(defp, (ub4)OCI_HTYPE_DEFINE, &pres->form_roociRes[cid],
                      (ub4)0, (ub4)OCI_ATTR_CHARSET_FORM, pcon->err_roociCon);
      if (rc == OCI_ERROR)
        return rc;
    }

  }

  return rc;

} /* end roociResDefine */

/* ------------------------- roociDescCol --------------------------------- */

sword roociDescCol(roociRes *pres, ub4 colId, ub2 *extTyp, oratext **colName,
                   ub4 *colNameLen, ub4 *maxColDataSizeInByte, sb2 *colpre,
                   sb1 *colsca, ub1 *nul, ub1 *form)
{
  sword         rc        = OCI_ERROR;
  OCIParam     *colhd;                                       /* column handle */
  ub2           size;                              /* size in bytes of column */
  ub1           tmpform;
  sb2           precision;
  sb1           scale;
  void         *tdoRef;
  roociColType *coltyp = &pres->typ_roociRes[colId-1];
  roociCon     *pcon = pres->con_roociRes;

  /* get column parameters */
  rc = OCIParamGet(pres->curstm_roociRes, OCI_HTYPE_STMT, pcon->err_roociCon, 
                   (void **)&colhd, colId);
  if (rc == OCI_ERROR)
      return rc;

  /* get column name */
  if (colName && colNameLen)
  {
    rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, colName, colNameLen,
                    OCI_ATTR_NAME, pcon->err_roociCon);
    if (rc == OCI_ERROR)
    {
      OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);    
      return rc;
    }
  }

  /* get maximum column data size in bytes */
  if (extTyp || maxColDataSizeInByte)
  {
    rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, &size,
                    NULL, OCI_ATTR_DATA_SIZE, pcon->err_roociCon);
    if (rc == OCI_ERROR)
    {
      OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);
      return rc;
    }

    if (maxColDataSizeInByte)
      *maxColDataSizeInByte = (ub4)size;
  }

  /* get precision */
  if (!colpre && extTyp)
    colpre = &precision;

  if (colpre)
  {
    rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, colpre,
                    NULL, OCI_ATTR_PRECISION, pcon->err_roociCon);
    if (rc == OCI_ERROR)
    {
      OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);    
      return rc;
    }
  }

  /* get scale */
  if (!colsca && extTyp)
    colsca = &scale;

  if (colsca)
  {
    rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, colsca,
                    NULL, OCI_ATTR_SCALE, pcon->err_roociCon);
    if (rc == OCI_ERROR)
    {
      OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);    
      return rc;
    }
  }

  /* is Null */
  if (nul)
  {
    rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, nul,
                    NULL, OCI_ATTR_IS_NULL, pcon->err_roociCon);
    if (rc == OCI_ERROR)
    {
      OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);    
      return rc;
    }
  }

  /* get form of use */
  if (!form)
    form = &tmpform;

  rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, (void *)form,
                  NULL, OCI_ATTR_CHARSET_FORM, pcon->err_roociCon);
  if (rc == OCI_ERROR)
  {
    OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);
    return rc;
  }

  if (extTyp)
  {
    ub2  colTyp     = 0;                           /* column type */
    ub2  collen     = 0;                           /* column length */
    sb4  coldisplen = 0;                           /* column display length */

    /* get column type */
    rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, &colTyp, NULL,
                    OCI_ATTR_DATA_TYPE, pcon->err_roociCon);
    if (rc == OCI_ERROR)
    {
      OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);    
      return rc;
    }

    /* get internal data type */
    coltyp->typ_roociColType = rodbiTypeInt(pres->con_roociRes->ctx_roociCon,
                                            colTyp, *colpre, *colsca,
                                            size, pcon->timesten_rociCon,
                                            *form);

    /* get external type */
    pres->typ_roociRes[colId-1].extyp_roociColType = *extTyp =
                    rodbiTypeExt(pres->typ_roociRes[colId-1].typ_roociColType);

    /* get buffer length */
    switch(*extTyp)
    {
      case SQLT_BDOUBLE:
      case SQLT_FLT:
        pres->siz_roociRes[colId-1] = sizeof(double);
        break;

      case SQLT_INT:
        pres->siz_roociRes[colId-1] = sizeof(int);
        break;

#if (OCI_MAJOR_VERSION >= 12 && OCI_MINOR_VERSION > 1)
      case SQLT_BOL:
        pres->siz_roociRes[colId-1] = sizeof(int);
        break;
#endif

      case SQLT_TIMESTAMP:
      case SQLT_TIMESTAMP_LTZ:
        pres->siz_roociRes[colId-1] = sizeof(OCIDateTime *);
        break;

      case SQLT_INTERVAL_DS:
        pres->siz_roociRes[colId-1] = sizeof(OCIInterval *);
        break;

      case SQLT_CLOB:
      case SQLT_BLOB:
      case SQLT_BFILE:
        pres->siz_roociRes[colId-1] = sizeof(OCILobLocator *);
        break;

#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
      case SQLT_VEC:
        pres->siz_roociRes[colId-1] = sizeof(OCIVector *);
        rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, &coltyp->vdim_roociColType, 0,
                        OCI_ATTR_VECTOR_DIMENSION, pcon->err_roociCon);
        if (rc == OCI_ERROR)
        {
          OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);
          return rc;
        }

        rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM,  &coltyp->vfmt_roociColType, 0,
                        OCI_ATTR_VECTOR_DATA_FORMAT, pcon->err_roociCon);
        if (rc == OCI_ERROR)
        {
          OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);
          return rc;
        }

        rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM,  &coltyp->vprop_roociColType, 0,
                        OCI_ATTR_VECTOR_PROPERTY, pcon->err_roociCon);
        if (rc == OCI_ERROR)
        {
          OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);
          return rc;
        }

#ifdef DEBUG
fprintf(stdout, "vdim=%d vfmt=%d vprop=%d\n", coltyp->vdim_roociColType,
        coltyp->vfmt_roociColType, coltyp->vprop_roociColType);
#endif
        break;
#endif /* OCI_MAJOR_VERSION >= 23 */

      case SQLT_BIN:
        rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, &collen, NULL,
                        OCI_ATTR_DATA_SIZE, pcon->err_roociCon);
        if (rc == OCI_ERROR)
        {
          OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);
          return rc;
        }

        /* adjust for NULL terminator & account for NLS expansion */
        pres->siz_roociRes[colId-1] = (size_t)((collen + 1));
        break;

      case SQLT_REF:
      case SQLT_NTY:
        pres->siz_roociRes[colId-1] = sizeof(void *);

        /* acquire TDO from the parameter */
        rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, &tdoRef, 0, OCI_ATTR_REF_TDO,
                        pcon->err_roociCon);
        if (rc == OCI_ERROR)
        {
          OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);    
          return rc;
        }

        /* pin the type in object cache to get the TDO */
        rc = OCIObjectPin(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                          pcon->err_roociCon, tdoRef, NULL,
                          OCI_PIN_ANY, OCI_DURATION_SESSION, OCI_LOCK_NONE,
                  (void **)&(coltyp->obtyp_roociColType.otyp_roociObjType));
        if (rc == OCI_ERROR)
        {
          OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);    
          return rc;
        }

        rc = OCIObjectFree(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                           pcon->err_roociCon, tdoRef,
                           OCI_OBJECTFREE_FORCE);
        if (rc == OCI_ERROR)
        {
          OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);
          return rc;
        }

        rc = roociFillAllTypeInfo(pcon, pres, coltyp);

        break;

      default:
        rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, &coldisplen, NULL,
                        OCI_ATTR_DISP_SIZE, pcon->err_roociCon);
        if (rc == OCI_ERROR)
        {
          OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);    
          return rc;
        }

        /* adjust for NULL terminator & account for NLS expansion */
        pres->siz_roociRes[colId-1] = (size_t)((coldisplen + 1) *
                                             pcon->nlsmaxwidth_roociCon);
        break;
    }
  }

  OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);    
  return rc;
} /* end of roociDescCol */

/* ------------------------ roociFillAllTypeInfo -------------------------- */

sword roociFillAllTypeInfo(roociCon *pcon, roociRes *pres, 
                           roociColType *coltyp)
{
  OCIDescribe *mydschp = (OCIDescribe *)0;
  OCIParam    *myparmp = (OCIParam *)0;
  OCIRef      *typeref;
  sword        rc;
  OCIParam    *parmdp;
  OCIParam    *typeParam;
  OCIDescribe *hndlDescribe = (OCIDescribe *)0;

  /* allocate a describe handle */
  if ((rc = OCIHandleAlloc(pcon->ctx_roociCon->env_roociCtx,
                           (void **)&hndlDescribe,
                           OCI_HTYPE_DESCRIBE,
                           0, NULL)) == OCI_ERROR)
    goto exitroociFillAllTypeInfo;

  /* describe the type */
  if ((rc = OCIDescribeAny(pcon->svc_roociCon,
                         pcon->err_roociCon,
                         (void *)coltyp->obtyp_roociColType.otyp_roociObjType,
                         0,
                         OCI_OTYPE_PTR,
                         OCI_DEFAULT,
                         OCI_PTYPE_TYPE,
                         hndlDescribe)) == OCI_ERROR)
    goto exitroociFillAllTypeInfo;

  if ((rc = OCIAttrGet(hndlDescribe,
                       OCI_HTYPE_DESCRIBE,
                       (void *)&typeParam,
                       NULL,
                       OCI_ATTR_PARAM,
                       pcon->err_roociCon)) == OCI_ERROR)
    goto exitroociFillAllTypeInfo;

  /* get the typecode */
  if ((rc = OCIAttrGet(typeParam,
                       OCI_DTYPE_PARAM,
                       (void *)&(coltyp->obtyp_roociColType.otc_roociObjType),
                       NULL,
                       OCI_ATTR_TYPECODE,
                       pcon->err_roociCon)) == OCI_ERROR)
    goto exitroociFillAllTypeInfo;

  if (coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_OBJECT ||
      coltyp->obtyp_roociColType.otc_roociObjType == 
      OCI_TYPECODE_NAMEDCOLLECTION)
  {
    if ((rc = OCIAttrGet((void *)hndlDescribe, (ub4)OCI_HTYPE_DESCRIBE,
                         (void *)&parmdp, (ub4 *)0, (ub4)OCI_ATTR_PARAM,
                         pcon->err_roociCon)) == OCI_ERROR)
      goto exitroociFillAllTypeInfo;
  }
  else
  {
    rc = ROOCI_DRV_ERR_TYPE_FAIL;
    goto exitroociFillAllTypeInfo;
  }

  /* get ref to attribute/column type */
  if ((rc = OCIAttrGet((void *)parmdp, (ub4)OCI_DTYPE_PARAM, (void *)&typeref,
                      (ub4 *)0, (ub4)OCI_ATTR_REF_TDO, pcon->err_roociCon)) ==
                                                                    OCI_ERROR)
    goto exitroociFillAllTypeInfo;

  /* describe it */
  if ((rc = OCIHandleAlloc(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                           (void **)&mydschp, OCI_HTYPE_DESCRIBE, 0, NULL)) ==
       OCI_ERROR)
    goto exitroociFillAllTypeInfo;

  if ((rc = OCIDescribeAny(pcon->svc_roociCon, pcon->err_roociCon,
                           (void *)typeref, 0, OCI_OTYPE_REF, (ub1)1,
                           OCI_PTYPE_TYPE, mydschp)) == OCI_ERROR)
    goto exitroociFillAllTypeInfo;

  if ((rc = OCIAttrGet((void *)mydschp, (ub4)OCI_HTYPE_DESCRIBE,
                       (void *)&myparmp, (ub4 *)0, (ub4)OCI_ATTR_PARAM,
                       pcon->err_roociCon)) == OCI_ERROR)
    goto exitroociFillAllTypeInfo;

  rc = roociFillTypeInfo(pcon, pres, &coltyp->obtyp_roociColType, myparmp);

exitroociFillAllTypeInfo:
  /* free describe handle */
  if (mydschp)
    OCIHandleFree((void *)mydschp, (ub4) OCI_HTYPE_DESCRIBE);

  if (hndlDescribe)
    OCIDescriptorFree(hndlDescribe, OCI_HTYPE_DESCRIBE);
  return rc;

} /* end of roociFillAllTypeInfo */

/*----------------------------------------------------------------------*/

sword roociFillTypeInfo(roociCon *pcon, roociRes *pres, roociObjType *objtyp,
                        OCIParam *parmp)
{
  sword     rc;
  text     *namep;
/*
  ub4       size;
  ub1       is_incomplete,
            is_system,
            is_predefined,
            is_transient,
            is_sysgen,
            has_table,
            has_lob,
            has_file;
*/
  OCIParam *list_attr,
           *collection_parmp;

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                    (void *)&(objtyp->otyp_roociObjType), (ub4 *)0,
                    (ub4)OCI_ATTR_TDO, pcon->err_roociCon), rc);

  /* verify magic number of TDO */
  ROOCI_OCI_RET_ERR((*(ub4*)objtyp->otyp_roociObjType != 0xae9a0001), rc);

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                    (void *)&(objtyp->nattr_roociObjType), (ub4 *)0,
                    (ub4)OCI_ATTR_NUM_TYPE_ATTRS, pcon->err_roociCon), rc);

  if (objtyp->otc_roociObjType == OCI_TYPECODE_NAMEDCOLLECTION)
  {
    objtyp->nattr_roociObjType = 1;
    ROOCI_MEM_ALLOC(objtyp->typ_roociObjType,
                    objtyp->nattr_roociObjType, sizeof(roociColType));
  }
  else
    ROOCI_MEM_ALLOC(objtyp->typ_roociObjType,
                    objtyp->nattr_roociObjType, sizeof(roociColType));

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                    (void *)&namep,
                    (ub4 *)&(objtyp->namsz_roociObjType),
                    (ub4)OCI_ATTR_NAME, pcon->err_roociCon), rc);
  memcpy((void *)&(objtyp->name_roociObjType), (void *)namep,
         objtyp->namsz_roociObjType);

/*
  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                    (void *)&namep, (ub4 *)&size,
                    (ub4)OCI_ATTR_SCHEMA_NAME, pcon->err_roociCon), rc);
  strncpy((char *)schema, (char *)namep, (size_t) size);
  schema[size] = '\0';
*/

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                    (void *)&(objtyp->otc_roociObjType), (ub4 *)0,
                    (ub4)OCI_ATTR_TYPECODE, pcon->err_roociCon), rc);

  if (objtyp->otc_roociObjType == OCI_TYPECODE_NAMEDCOLLECTION)
  {
    ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                      (void *)&(objtyp->colltc_roociObjType), (ub4 *)0,
                      (ub4)OCI_ATTR_COLLECTION_TYPECODE, pcon->err_roociCon),
                      rc);

    ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                      (void *)&collection_parmp, (ub4 *)0,
                      (ub4)OCI_ATTR_COLLECTION_ELEMENT, pcon->err_roociCon),
                      rc);
  }

/*
  ROOCI_OCI_RET_ERR(OCIAttrGet((void*)parmp, (ub4) OCI_DTYPE_PARAM,
                    (void*)&namep, (ub4 *)&size,
                    (ub4)OCI_ATTR_VERSION, pcon->err_roociCon), rc);

  strncpy((char *)version, (char *)namep, (size_t) size);
  version[size] = '\0';

  ROOCI_OCI_RET_ERR(OCIAttrGet((void*)parmp, (ub4)OCI_DTYPE_PARAM,
                   (void*)&is_incomplete, (ub4 *)0,
                   (ub4)OCI_ATTR_IS_INCOMPLETE_TYPE, pcon->err_roociCon), rc);

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4) OCI_DTYPE_PARAM,
                    (void *)&is_system, (ub4 *) 0,
                    (ub4)OCI_ATTR_IS_SYSTEM_TYPE, pcon->err_roociCon), rc);

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                   (void *)&is_predefined, (ub4 *)0,
                   (ub4)OCI_ATTR_IS_PREDEFINED_TYPE, pcon->err_roociCon), rc);

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                  (void *)&is_transient, (ub4 *)0,
                  (ub4)OCI_ATTR_IS_TRANSIENT_TYPE, pcon->err_roociCon), rc);

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                  (void *)&is_sysgen, (ub4 *)0,
                  (ub4)OCI_ATTR_IS_SYSTEM_GENERATED_TYPE, pcon->err_roociCon),
                  rc);

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                    (void *)&has_table, (ub4 *)0,
                    (ub4)OCI_ATTR_HAS_NESTED_TABLE, pcon->err_roociCon), rc);

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                    (void *)&has_lob, (ub4 *)0,
                    (ub4)OCI_ATTR_HAS_LOB, pcon->err_roociCon), rc);

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                    (void *)&has_file, (ub4 *)0,
                    (ub4)OCI_ATTR_HAS_FILE, pcon->err_roociCon), rc);
*/

  /* test calling this twice */
  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                    (void *)&list_attr, (ub4 *)0,
                    (ub4)OCI_ATTR_LIST_TYPE_ATTRS, pcon->err_roociCon), rc);

  if (objtyp->otc_roociObjType == OCI_TYPECODE_NAMEDCOLLECTION)
    rc = roociFillTypeCollInfo(pcon, pres, objtyp->typ_roociObjType,
                               collection_parmp,
                          objtyp->colltc_roociObjType == OCI_TYPECODE_VARRAY);
  else
    rc = roociFillTypeAttrInfo(pcon, pres, objtyp->typ_roociObjType, objtyp,
                      list_attr, objtyp->nattr_roociObjType);

  objtyp->tattr_roociObjType += objtyp->nattr_roociObjType;

  return rc;
}

/*----------------------------------------------------------------------*/
sword roociFillTypeAttrInfo(roociCon *pcon, roociRes *pres,
                            roociColType *coltyp, roociObjType *parentobj,
                            OCIParam *parmp, ub4 parmcnt)
{
  text        *namep;
  OCITypeCode  coltype;
  OCIParam    *parmdp;
  ub4          pos;
  sword        rc = OCI_SUCCESS;

  for (pos = 1; pos <= parmcnt; pos++, coltyp++)
  {
    ROOCI_OCI_RET_ERR(OCIParamGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                      pcon->err_roociCon, 
                      (void *)&parmdp, (ub4) pos), rc);
    
    ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmdp, (ub4) OCI_DTYPE_PARAM, 
                      (void *)&(coltyp->colsz_roociColType), (ub4 *)0, 
                      (ub4)OCI_ATTR_DATA_SIZE, pcon->err_roociCon), rc);

    ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmdp, (ub4)OCI_DTYPE_PARAM,
                      (void *)&namep,
                      (ub4 *)&(coltyp->namsz_roociColType), 
                      (ub4)OCI_ATTR_NAME, pcon->err_roociCon), rc);
    memcpy((void *)&(coltyp->name_roociColType), (void *)namep,
           coltyp->namsz_roociColType);

    ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmdp, (ub4)OCI_DTYPE_PARAM,
                      (void *)&namep,
                      (ub4 *)&(coltyp->attrnmsz_roociColType), 
                      (ub4)OCI_ATTR_TYPE_NAME, pcon->err_roociCon), rc);
    memcpy((void *)&(coltyp->attrnm_roociColType), (void *)namep,
           coltyp->attrnmsz_roociColType);

    ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmdp, (ub4)OCI_DTYPE_PARAM,
                      (void *)&(coltyp->obtyp_roociColType.otc_roociObjType),
                      (ub4 *)0, (ub4)OCI_ATTR_TYPECODE, pcon->err_roociCon),
                      rc);

    ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmdp, (ub4)OCI_DTYPE_PARAM,
                      (void *)&(coltyp->prec_roociColType), (ub4 *)0,
                      (ub4)OCI_ATTR_PRECISION, pcon->err_roociCon), rc);

    ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmdp, (ub4)OCI_DTYPE_PARAM,
                      (void *)&(coltyp->scale_roociColType), (ub4 *)0,
                      (ub4)OCI_ATTR_SCALE, pcon->err_roociCon), rc);

    ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmdp, (ub4)OCI_DTYPE_PARAM,
                      (void *)&coltype, (ub4 *)0, 
                      (ub4)OCI_ATTR_DATA_TYPE, pcon->err_roociCon), rc);

    ROOCI_OCI_RET_ERR(OCIAttrGet(parmdp, OCI_DTYPE_PARAM,
                      (void *)&(coltyp->form_roociColType), NULL,
                      OCI_ATTR_CHARSET_FORM, pcon->err_roociCon), rc);

    /* get internal data type */
    coltyp->typ_roociColType = rodbiTypeInt(pres->con_roociRes->ctx_roociCon,
                                            coltype,
                                            coltyp->prec_roociColType,
                                            coltyp->scale_roociColType,
                                            coltyp->colsz_roociColType,
                                            pcon->timesten_rociCon,
                                            coltyp->form_roociColType);
    coltyp->extyp_roociColType = rodbiTypeExt(coltyp->typ_roociColType);

    /* if column or attribute is type OBJECT/COLLECTION, describe it by ref */
    if (coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_OBJECT ||
        coltyp->obtyp_roociColType.otc_roociObjType == 
        OCI_TYPECODE_NAMEDCOLLECTION ||
        coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_REF ||
        coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_TABLE ||
        coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_VARRAY)
    {
      OCIDescribe *mydschp;
      OCIParam    *myparmp;
      OCIRef      *typeref;
      OCIParam    *list_attr;

      /* get ref to attribute/column type */
      ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmdp, (ub4)OCI_DTYPE_PARAM,
                        (void *)&typeref, (ub4 *)0,
                        (ub4)OCI_ATTR_REF_TDO, pcon->err_roociCon), rc);

      /* describe it */
      ROOCI_OCI_RET_ERR(
                OCIHandleAlloc(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                              (void **)&mydschp,
                              (ub4)OCI_HTYPE_DESCRIBE, (size_t)0,
                              (void **)0), rc);

      rc = OCIDescribeAny(pcon->svc_roociCon, pcon->err_roociCon,
                          (void *)typeref, (ub4)0,
                          OCI_OTYPE_REF, (ub1)1, OCI_PTYPE_TYPE, mydschp);
      if (rc == OCI_ERROR)
      {
        OCIHandleFree((void *)mydschp, (ub4)OCI_HTYPE_DESCRIBE);
        return rc;
      }

      rc = OCIAttrGet((void *)mydschp, (ub4)OCI_HTYPE_DESCRIBE,
                      (void *)&myparmp, (ub4 *)0, (ub4)OCI_ATTR_PARAM,
                      pcon->err_roociCon);
      if (rc == OCI_ERROR)
      {
        OCIHandleFree((void *)mydschp, (ub4)OCI_HTYPE_DESCRIBE);
        return rc;
      }

      ROOCI_OCI_RET_ERR(OCIAttrGet((void *)myparmp, (ub4)OCI_DTYPE_PARAM,
                      (void *)&list_attr, (ub4 *)0,
                      (ub4)OCI_ATTR_LIST_TYPE_ATTRS, pcon->err_roociCon), rc);

#if 0
      coltyp->obtyp_roociColType.nattr_roociObjType = 1;
      coltyp->obtyp_roociColType.tattr_roociObjType +=
                                coltyp->obtyp_roociColType.nattr_roociObjType;
#endif
      if ((coltyp->attrnmsz_roociColType == parentobj->namsz_roociObjType) &&
          (memcmp((const void *)coltyp->attrnm_roociColType,
                  (const void *)parentobj->name_roociObjType,
                  coltyp->attrnmsz_roociColType)) == 0)
      {
        coltyp->obtyp_roociColType.tattr_roociObjType +=
                                                parentobj->nattr_roociObjType;
      }
      else
      {
        if ((rc = roociFillTypeInfo(pcon, pres, &coltyp->obtyp_roociColType,
                           myparmp)) != OCI_SUCCESS)
        {
          OCIHandleFree((void *)mydschp, (ub4)OCI_HTYPE_DESCRIBE);
          return rc;
        }
        coltyp->obtyp_roociColType.tattr_roociObjType +=
                                coltyp->obtyp_roociColType.nattr_roociObjType;
      }

#if 0
      ROOCI_MEM_ALLOC(coltyp->obtyp_roociColType.typ_roociObjType,
                      1, sizeof(roociColType));

      roociFillTypeInfo(pcon, pres,
           &coltyp->obtyp_roociColType.typ_roociObjType->obtyp_roociColType,
           myparmp);
  
      coltyp->obtyp_roociColType.tattr_roociObjType +=
      coltyp->obtyp_roociColType.typ_roociObjType->obtyp_roociColType.nattr_roociObjType;
#endif
 
      /* free describe handle */
      OCIHandleFree((void *)mydschp, (ub4)OCI_HTYPE_DESCRIBE);
    }
    else
    {
      coltyp->obtyp_roociColType.tattr_roociObjType += 1;
    }
  }

  return rc;
}

/*----------------------------------------------------------------------*/

sword roociFillTypeCollInfo(roociCon *pcon, roociRes *pres,
                            roociColType *coltyp,
                            OCIParam *parmp, boolean is_array)
{
  text        *namep;
  ub4          size;         
  ub2          datatype;
  sword        rc;

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM, 
                  (void *)&(coltyp->colsz_roociColType), (ub4 *)0, 
                  (ub4) OCI_ATTR_DATA_SIZE, pcon->err_roociCon), rc);

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                  (void *)&namep,
                  (ub4 *)&(coltyp->namsz_roociColType), 
                  (ub4)OCI_ATTR_TYPE_NAME, pcon->err_roociCon), rc);
  memcpy((void *)&(coltyp->name_roociColType), (void *)namep,
         coltyp->namsz_roociColType);

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                  (void *)&namep, (ub4 *)&size, 
                  (ub4)OCI_ATTR_SCHEMA_NAME, pcon->err_roociCon), rc);

  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                  (void *)&(coltyp->obtyp_roociColType.otc_roociObjType),
                  (ub4 *)0, (ub4)OCI_ATTR_TYPECODE, pcon->err_roociCon), rc);
  
  ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                  (void *)&datatype, (ub4 *)0, (ub4)OCI_ATTR_DATA_TYPE, 
                  pcon->err_roociCon), rc);
 
  /* get internal data type */
  coltyp->typ_roociColType = rodbiTypeInt(pcon->ctx_roociCon,
                                          datatype, coltyp->prec_roociColType,
                                          coltyp->scale_roociColType,
                                          coltyp->colsz_roociColType,
                                          pcon->timesten_rociCon,
                                          coltyp->form_roociColType);
  coltyp->extyp_roociColType = rodbiTypeExt(coltyp->typ_roociColType);

  if (is_array)
    ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                    (void *)&(coltyp->obtyp_roociColType.nelem_roociObjType),
                    (ub4 *)0,
                    (ub4)OCI_ATTR_NUM_ELEMS, pcon->err_roociCon), rc);

  /* if column or attribute is type OBJECT/COLLECTION, describe it by ref */
  if (coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_OBJECT ||
      coltyp->obtyp_roociColType.otc_roociObjType == 
      OCI_TYPECODE_NAMEDCOLLECTION ||
      coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_REF ||
      coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_TABLE ||
      coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_VARRAY)
  {
    OCIDescribe *mydschp;
    OCIParam    *myparmp;
    OCIRef      *typeref;

    /* get ref to attribute/column type */
    ROOCI_OCI_RET_ERR(OCIAttrGet((void *)parmp, (ub4)OCI_DTYPE_PARAM,
                      (void *)&typeref, (ub4 *)0,
                      (ub4)OCI_ATTR_REF_TDO, pcon->err_roociCon), rc);

    /* describe it */
    ROOCI_OCI_RET_ERR(
               OCIHandleAlloc(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                              (void **)&mydschp,
                              (ub4)OCI_HTYPE_DESCRIBE, (size_t)0,
                              (void **)0), rc);

    rc = OCIDescribeAny(pcon->svc_roociCon, pcon->err_roociCon,
                        (void *)typeref, (ub4)0,
                        OCI_OTYPE_REF, (ub1)1, OCI_PTYPE_TYPE, mydschp);
    if (rc == OCI_ERROR)
    {
      OCIHandleFree((void *)mydschp, (ub4)OCI_HTYPE_DESCRIBE);
      return rc;
    }

    rc = OCIAttrGet((void *)mydschp, (ub4)OCI_HTYPE_DESCRIBE,
                    (void *)&myparmp, (ub4 *)0, (ub4)OCI_ATTR_PARAM,
                    pcon->err_roociCon);
    if (rc == OCI_ERROR)
    {
      OCIHandleFree((void *)mydschp, (ub4)OCI_HTYPE_DESCRIBE);
      return rc;
    }

#if 0
    ROOCI_MEM_ALLOC(coltyp->obtyp_roociColType.typ_roociObjType,
                    1, sizeof(roociColType));

    roociFillTypeInfo(pcon, pres,
             &coltyp->obtyp_roociColType.typ_roociObjType->obtyp_roociColType,
             myparmp);
#endif

    roociFillTypeInfo(pcon, pres, &coltyp->obtyp_roociColType, myparmp);

    coltyp->obtyp_roociColType.tattr_roociObjType +=
    coltyp->obtyp_roociColType.nattr_roociObjType;

    /* free describe handle */
    OCIHandleFree((void *)mydschp, (ub4)OCI_HTYPE_DESCRIBE);
  }

  return rc;
}           

/* -------------------------- roociGetColProperties ----------------------- */

sword roociGetColProperties(roociRes *pres, ub4 colId, ub4 *len, 
                            oratext **buf)
{
  OCIParam   *par;
  sword       rc    = OCI_ERROR;
  roociCon   *pcon  = pres->con_roociRes;
  void       *temp  = NULL;    /* pointer to remove strict-aliasing warning */
   
  /* get column parameters */
  rc = OCIParamGet(pres->curstm_roociRes, OCI_HTYPE_STMT, pcon->err_roociCon, 
                   (void **)&temp, colId);
  par = temp;
  if (rc == OCI_ERROR)
  {
    OCIDescriptorFree(par, OCI_DTYPE_PARAM);
    return rc;
  }

  /* get column name */
  rc = OCIAttrGet(par, OCI_DTYPE_PARAM, buf, len, OCI_ATTR_NAME,
                  pcon->err_roociCon);
  if (rc == OCI_ERROR)
  {
    OCIDescriptorFree(par, OCI_DTYPE_PARAM);
    return rc;
  }

  OCIDescriptorFree(par, OCI_DTYPE_PARAM);
  return rc;
} /* end of roociGetColProperties */

/* -------------------------- roociFetchData ------------------------------ */

sword roociFetchData(roociRes *pres, ub4 *rows_fetched, boolean *end_of_fetch)
{
  sword      rc   = OCI_ERROR;
  roociCon  *pcon = pres->con_roociRes;

  *rows_fetched = 0;

  /* fetch data */
  rc = OCIStmtFetch2(pres->curstm_roociRes, pcon->err_roociCon, 
                     pres->prefetch_roociRes ? 1 : pres->nrows_roociRes,
                     OCI_FETCH_NEXT, 0, OCI_DEFAULT);

  if (rc == OCI_NO_DATA)                                   /* done fetching */
    *end_of_fetch = TRUE;
  else
    *end_of_fetch = FALSE;
       
  if (rc == OCI_ERROR)
    return rc;
    
  /* get no of rows fetched */
  rc = OCIAttrGet(pres->curstm_roociRes, OCI_HTYPE_STMT, rows_fetched,
                  NULL, OCI_ATTR_ROWS_FETCHED, pcon->err_roociCon);
    
  return rc;
} /* end of roociFetchData */

/* --------------------------- roociReadLOBData --------------------------- */

sword roociReadLOBData(roociRes *pres, OCILobLocator *lob_loc, int *lob_len,
                       ub1 form)
{
  sword            rc   = OCI_ERROR;
  oraub8           len;
  oraub8           char_len;
  roociCon        *pcon = pres->con_roociRes;

  /* get lob length */
  rc =  OCILobGetLength2(pcon->svc_roociCon, pcon->err_roociCon, 
                         lob_loc, &char_len);
  if (rc == OCI_ERROR)
    return rc;

  if (char_len == 0)
  {
    *lob_len = (int)char_len;
    return rc;
  }

  /* compute buffer size in bytes */
  len = char_len * (oraub8)(pcon->nlsmaxwidth_roociCon);

  if (!pres->lobbuf_roociRes || pres->loblen_roociRes < (int)len)
  {
    if (pres->lobbuf_roociRes)
      ROOCI_MEM_FREE(pres->lobbuf_roociRes);

    pres->loblen_roociRes = (len / ROOCI_LOB_RND + 1);
    pres->loblen_roociRes = (pres->loblen_roociRes * ROOCI_LOB_RND);
    ROOCI_MEM_ALLOC(pres->lobbuf_roociRes, pres->loblen_roociRes, 
                    sizeof(ub1));
    if (!pres->lobbuf_roociRes)
      return ROOCI_DRV_ERR_MEM_FAIL;
  }

  /* read LOB data */
  rc = OCILobRead2(pcon->svc_roociCon, pcon->err_roociCon, lob_loc,
                   &len, &char_len, 1, pres->lobbuf_roociRes, len,
                   OCI_ONE_PIECE, NULL, (OCICallbackLobRead2)0, 0,
                   form);
  if (rc == OCI_ERROR)
    return rc;

  *lob_len = (int)len;
  return rc;
} /* end of roociReadLOBData */

/* -------------------------- roociReadBLOBData --------------------------- */

sword roociReadBLOBData(roociRes *pres, OCILobLocator *lob_loc, int *lob_len,
                        ub1 form, ub2 exttyp)
{
  sword            rc   = OCI_ERROR;
  oraub8           len;
  oraub8           char_len;
  roociCon        *pcon = pres->con_roociRes;

  if (exttyp == SQLT_BFILE)
  {
    rc = OCILobFileOpen(pcon->svc_roociCon, pcon->err_roociCon, lob_loc,
                        (ub1)OCI_FILE_READONLY);
    if (rc == OCI_ERROR)
      return rc;
  }

  /* get lob length */
  rc =  OCILobGetLength2(pcon->svc_roociCon, pcon->err_roociCon, 
                         lob_loc, &len);
  if (rc == OCI_ERROR)
    return rc;

  if (len == 0)
  {
    *lob_len = (int)len;
    return rc;
  }

  if (!pres->lobbuf_roociRes || pres->loblen_roociRes < (int)len)
  {
    if (pres->lobbuf_roociRes)
      ROOCI_MEM_FREE(pres->lobbuf_roociRes);

    pres->loblen_roociRes = (len / ROOCI_LOB_RND + 1);
    pres->loblen_roociRes = (pres->loblen_roociRes * ROOCI_LOB_RND);
    ROOCI_MEM_ALLOC(pres->lobbuf_roociRes, pres->loblen_roociRes, 
                    sizeof(ub1));
    if (!pres->lobbuf_roociRes)
      return ROOCI_DRV_ERR_MEM_FAIL;
  }

  /* read LOB data */
  rc = OCILobRead2(pcon->svc_roociCon, pcon->err_roociCon, lob_loc,
                   &len, &char_len, 1, pres->lobbuf_roociRes, len,
                   OCI_ONE_PIECE, NULL, (OCICallbackLobRead2)0, 0,
                   form);
  if (rc == OCI_ERROR)
    return rc;

  *lob_len = (int)len;

  if (exttyp == SQLT_BFILE)
  {
    rc = OCILobFileClose(pcon->svc_roociCon, pcon->err_roociCon, lob_loc);
    if (rc == OCI_ERROR)
      return rc;
  }

  return rc;
} /* end of roociReadBLOBData */

/* ------------------------- roociReadDateTimeData ------------------------ */

sword roociReadDateTimeData(roociRes *pres, OCIDateTime *tstm, double *date,
                            boolean isDate)
{
  sword          rc = OCI_ERROR;
  roociCon      *pcon = pres->con_roociRes;
  sb4            dy = 0;
  sb4            hr = 0;
  sb4            mm = 0;
  sb4            ss = 0;
  sb4            fsec = 0;

  if (!pres->epoch_roociRes)
  {
    rc = roociAllocateDateTimeDescriptors(pres);
    if (rc == OCI_ERROR)
      return rc;
  }

  /* compute the difference from the epoch */
  rc = OCIDateTimeSubtract(pres->con_roociRes->usr_roociCon,
                           pcon->err_roociCon, tstm, pres->epoch_roociRes,
                           pres->diff_roociRes);
  if (rc == OCI_ERROR)
    return rc;

  /* extract interval components */
  rc = OCIIntervalGetDaySecond(pres->con_roociRes->usr_roociCon, 
                               pcon->err_roociCon, &dy,
                               &hr, &mm, &ss, &fsec, pres->diff_roociRes);

  if (rc == OCI_ERROR)
    return rc;

  /* number of seconds since the beginning of 1970 in UTC timezone */
  ROOCI_SECONDS_FROM_DAYS(date, dy, hr, mm, ss, 0);

  if (pcon->timesten_rociCon)
    *date -= pcon->secs_UTC_roociCon;

  if (!isDate)
    *date += ((double)fsec)/1e9;

  return rc;
} /* end of roociReadDateTimeData */

/* ------------------------- roociWriteDateTimeData ----------------------- */

sword roociWriteDateTimeData(roociRes *pres, OCIDateTime *tstm, double date)
{
  sword          rc = OCI_ERROR;
  roociCon      *pcon = pres->con_roociRes;
  sb4            dy = 0;
  sb4            hr = 0;
  sb4            mm = 0;
  sb4            ss = 0;
  sb4            fsec = 0; 

  if (!pres->epoch_roociRes)
  {
    rc = roociAllocateDateTimeDescriptors(pres);

    if (rc == OCI_ERROR)
      return rc;
  }

  if (pcon->timesten_rociCon)
    date += pcon->secs_UTC_roociCon;

  /* construct, day, hours, sec and fractional sec from date */
  ROOCI_DAYS_FROM_SECONDS(date, dy, hr, mm, ss, fsec);

  /* set interval components */
  rc = OCIIntervalSetDaySecond(pres->con_roociRes->usr_roociCon, 
                               pcon->err_roociCon,
                               dy, hr, mm, ss, fsec, pres->diff_roociRes);
  if (rc == OCI_ERROR)
    return rc;

  /* compute the date time from epoch */
  rc = OCIDateTimeIntervalAdd(pres->con_roociRes->usr_roociCon, 
                              pcon->err_roociCon,
                              pres->epoch_roociRes, pres->diff_roociRes,
                              tstm);
  return rc;
} /* end of roociWriteDateTimeData */

/* ------------------------- roociReadDiffTimeData ------------------------ */

sword roociReadDiffTimeData(roociRes *pres, OCIInterval *tstm, double *time)
{
  sword          rc = OCI_ERROR;
  roociCon      *pcon = pres->con_roociRes;
  roociCtx      *pctx = pcon->ctx_roociCon;
  sb4            dy = 0;
  sb4            hr = 0;
  sb4            mm = 0;
  sb4            ss = 0;
  sb4            fsec = 0;

  /* extract interval components */
  rc = OCIIntervalGetDaySecond(pctx->env_roociCtx, pcon->err_roociCon,
                               &dy, &hr, &mm, &ss, &fsec, tstm);
  if (rc == OCI_ERROR)
    return rc;

  /* number of seconds */
  ROOCI_SECONDS_FROM_DAYS(time, dy, hr, mm, ss, fsec);

  return rc;
} /* end of roociReadDiffTimeData */

/* ------------------------ roociWriteDiffTimeData ------------------------ */

sword roociWriteDiffTimeData(roociRes *pres, OCIInterval *tstm, double time)
{
  sword          rc = OCI_ERROR;
  roociCon      *pcon = pres->con_roociRes;
  roociCtx      *pctx = pcon->ctx_roociCon;
  sb4            dy = 0;
  sb4            hr = 0;
  sb4            mm = 0;
  sb4            ss = 0;
  sb4            fsec = 0; 

  /* construct, day, hours, sec and fractional sec from time */
  ROOCI_DAYS_FROM_SECONDS(time, dy, hr, mm, ss, fsec);

  /* extract interval components */
  rc = OCIIntervalSetDaySecond(pctx->env_roociCtx, pcon->err_roociCon,
                               dy, hr, mm, ss, fsec, tstm);

  return rc;
} /* end of roociWriteDiffTimeData */

/* --------------------------- roociGetResStmt ---------------------------- */

sword roociGetResStmt(roociRes *pres, oratext **qrybuf, ub4 *qrylen)
{
  sword rc = OCI_ERROR;

  /* get statement */
  rc = OCIAttrGet(pres->stm_roociRes, OCI_HTYPE_STMT, qrybuf, qrylen,
                  OCI_ATTR_STATEMENT, pres->con_roociRes->err_roociCon);

  return rc;
} /* end of roociGetResStmt */

/* ------------------------------ roociResFree ---------------------------- */

sword roociResFree(roociRes *pres)
{
  int           bid;
  int           cid;
  sword         rc    = OCI_SUCCESS;
  ub2           exttype;
  roociCon     *pcon  = pres->con_roociRes;
  int           numrows = 0;
  int           fcur  = 0;
  ub1          *dat   = NULL;
#if OCI_MAJOR_VERSION <= 10

  numrows = pres->prefetch_roociRes ? 1 : pres->nrows_roociRes;
#endif

  /* free bind data buffers */
  if (pres->bdat_roociRes)
  {
    for (bid = 0; bid < pres->bcnt_roociRes; bid++)
      if (pres->bdat_roociRes[bid])
      {    
        /* free OCIDateTime and OCIInterval data */
        if ((pres->btyp_roociRes[bid].extyp_roociColType == 
             SQLT_TIMESTAMP_TZ) ||
            (pres->btyp_roociRes[bid].extyp_roociColType == SQLT_INTERVAL_DS))
        {
#if OCI_MAJOR_VERSION > 10
          rc = OCIArrayDescriptorFree((void **)pres->bdat_roociRes[bid],
           (pres->btyp_roociRes[bid].extyp_roociColType == 
                                     SQLT_TIMESTAMP_TZ) ?
                                     OCI_DTYPE_TIMESTAMP_TZ :
                                     OCI_DTYPE_INTERVAL_DS);
          if (rc == OCI_ERROR)
            return rc;
#else
          dat = (ub1 *)pres->bdat_roociRes[bid];
          for (fcur = 0; fcur < pres->bmax_roociRes; fcur++)
          {
            void *tsdt = *(void **)(dat + fcur * (pres->bsiz_roociRes[bid]));
            if (tsdt)
            {
              rc = OCIDescriptorFree(tsdt,
           (pres->btyp_roociRes[bid].extyp_roociColType == 
                                     SQLT_TIMESTAMP_TZ) ?
                                     OCI_DTYPE_TIMESTAMP_TZ :
                                     OCI_DTYPE_INTERVAL_DS);
              if (rc != OCI_SUCCESS)
                return rc;
            }
          }
#endif
        }

        /* free lob data */
        if ((pres->btyp_roociRes[bid].extyp_roociColType == SQLT_CLOB) ||
            (pres->btyp_roociRes[bid].extyp_roociColType == SQLT_BLOB) ||
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
            (pres->btyp_roociRes[bid].extyp_roociColType == SQLT_VEC)  ||
#endif /* OCI_MAJOR_VERSION >= 23 */
            (pres->btyp_roociRes[bid].extyp_roociColType == SQLT_BFILE))
        {
#if OCI_MAJOR_VERSION > 10
          rc = OCIArrayDescriptorFree((void **)pres->bdat_roociRes[bid],
                  (pres->btyp_roociRes[bid].extyp_roociColType == SQLT_BFILE) ?
                                     OCI_DTYPE_FILE : 
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
                  (pres->btyp_roociRes[bid].extyp_roociColType == SQLT_VEC) ?
                                     OCI_DTYPE_VECTOR :
# endif /* OCI_MAJOR_VERSION >= 23 */
                                     OCI_DTYPE_LOB);
          if (rc == OCI_ERROR)
            return rc;
#else
          dat = (ub1 *)pres->bdat_roociRes[bid];
          for (fcur = 0; fcur < pres->bmax_roociRes; fcur++)
          {
            void *tsdt = *(void **)(dat + fcur * (pres->bsiz_roociRes[bid]));
            if (tsdt)
            {
              rc = OCIDescriptorFree(tsdt,
                 (pres->btyp_roociRes[bid].extyp_roociColType == SQLT_BFILE) ?
                                     OCI_DTYPE_FILE :
# if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
                  (pres->btyp_roociRes[bid].extyp_roociColType == SQLT_VEC) ?
                                     OCI_DTYPE_VECTOR :
# endif /* OCI_MAJOR_VERSION >= 23 */
                                     OCI_DTYPE_LOB);
              if (rc != OCI_SUCCESS)
                return rc;
            }
          }
#endif
        }
        else if (pres->btyp_roociRes[bid].extyp_roociColType == SQLT_NTY)
        {
          for (fcur = 0; fcur < pres->bmax_roociRes; fcur++)
          {
            void **pobj;
            dat  = (ub1 *)pres->bdat_roociRes[bid];
            pobj = (void **)(dat + fcur * (pres->bsiz_roociRes[bid]));
            rc = OCIObjectFree(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                               pcon->err_roociCon, *pobj,
                               OCI_OBJECTFREE_FORCE);
            if (rc != OCI_SUCCESS)
              return rc;
          }
        }
        else
          ROOCI_MEM_FREE(pres->bdat_roociRes[bid]);
      }

    ROOCI_MEM_FREE(pres->bdat_roociRes);
  }

  /* free bind parameter name buffers */
  if (pres->param_name_roociRes)
  {
    for (bid = 0; bid < pres->bcnt_roociRes; bid++)
      if (pres->param_name_roociRes[bid])
      {
        ROOCI_MEM_FREE(pres->param_name_roociRes[bid]);
      }

    ROOCI_MEM_FREE(pres->param_name_roociRes);
  }

  /* free bind indicator buffers */
  if (pres->bind_roociRes)
  {
    for (bid = 0; bid < pres->bcnt_roociRes; bid++)
      if (pres->bind_roociRes[bid])
      {
        ROOCI_MEM_FREE(pres->bind_roociRes[bid]);
      }

    ROOCI_MEM_FREE(pres->bind_roociRes);
  }

  /* free Object bind indicator buffers */
  if (pres->objbind_roociRes)
  {
    for (bid = 0; bid < pres->bcnt_roociRes; bid++)
      if (pres->objbind_roociRes[bid])
      {
        ROOCI_MEM_FREE(pres->objbind_roociRes[bid]);
      }

    ROOCI_MEM_FREE(pres->objbind_roociRes);
  }

  /* free bind actual length buffers */
  if (pres->alen_roociRes)
  {
    for (bid = 0; bid < pres->bcnt_roociRes; bid++)
      if (pres->alen_roociRes[bid])
      {
        ROOCI_MEM_FREE(pres->alen_roociRes[bid]);
      }

    ROOCI_MEM_FREE(pres->alen_roociRes);
  }

  /* free bind sizes */
  if (pres->bsiz_roociRes)
  {
    ROOCI_MEM_FREE(pres->bsiz_roociRes);
  }

  /* free bind types */
  if (pres->btyp_roociRes)
  {
    for (bid = 0; bid < pres->bcnt_roociRes; bid++)
    {
      if (pres->btyp_roociRes[bid].obtyp_roociColType.otyp_roociObjType)
      {
        rc = OCIObjectFree(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                           pcon->err_roociCon,
                 pres->btyp_roociRes[bid].obtyp_roociColType.otyp_roociObjType,
                           OCI_OBJECTFREE_FORCE);
        if (rc != OCI_SUCCESS)
          return rc;
      }

      if (pres->btyp_roociRes[bid].loc_roociColType)
        rc = OCIDescriptorFree(pres->btyp_roociRes[bid].loc_roociColType,
                               OCI_DTYPE_LOB);

      rc= roociFreeObjs(&pres->btyp_roociRes[bid].obtyp_roociColType);
      if (rc != OCI_SUCCESS)
        return rc;
    }

    ROOCI_MEM_FREE(pres->btyp_roociRes);
  }

  /* free bind form of use */
  if (pres->bform_roociRes)
  {
    ROOCI_MEM_FREE(pres->bform_roociRes);
  }

  /* free data buffers */
  if (pres->dat_roociRes)
  {
    for (cid = 0; cid < pres->ncol_roociRes; cid++)
      if (pres->dat_roociRes[cid])
      {
        exttype = pres->typ_roociRes[cid].extyp_roociColType;
        /* free lob data */
        if ((exttype == SQLT_CLOB) ||
            (exttype == SQLT_BLOB) ||
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
            (exttype == SQLT_VEC)  ||
#endif /* OCI_MAJOR_VERSION >= 23 */
            (exttype == SQLT_BFILE))
        {
#if OCI_MAJOR_VERSION > 10
          rc = OCIArrayDescriptorFree((void **)pres->dat_roociRes[cid],
                      (exttype == SQLT_BFILE) ? OCI_DTYPE_FILE :
#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
                      (exttype == SQLT_VEC)   ? OCI_DTYPE_VECTOR :
# endif /* OCI_MAJOR_VERSION >= 23 */
                                                OCI_DTYPE_LOB);
          if (rc == OCI_ERROR)
            return rc;
#else
          dat = (ub1 *)pres->dat_roociRes[cid];

          for (fcur = 0; fcur < numrows; fcur++)
          {
            OCILobLocator *lob = *(OCILobLocator **)(dat + fcur * 
                                                   (pres->siz_roociRes[cid]));
            if (lob)
            {
              rc = OCIDescriptorFree(lob,
                                     (exttype == SQLT_BFILE) ? OCI_DTYPE_FILE :
# if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
                                     (exttype == SQLT_VEC)   ? OCI_DTYPE_VECTOR :
# endif /* OCI_MAJOR_VERSION >= 23 */
                                                               OCI_DTYPE_LOB);
              if (rc != OCI_SUCCESS)
                return rc;
            }
          }
#endif
        }

        /* free OCIDateTime and OCIInterval data */
        if ((exttype == SQLT_TIMESTAMP_LTZ) ||
            (exttype == SQLT_TIMESTAMP)    ||
            (exttype == SQLT_INTERVAL_DS))
        {
#if OCI_MAJOR_VERSION > 10
          OCIDateTime **tsdt = (OCIDateTime **)(pres->dat_roociRes[cid]);
          rc = OCIArrayDescriptorFree((void **)tsdt, OCI_DTYPE_TIMESTAMP_TZ);
          if (rc == OCI_ERROR)
            return rc;
#else
          dat = (ub1 *)pres->dat_roociRes[cid];

          for (fcur = 0; fcur < numrows; fcur++)
          {
            void *tsdt = *(void **)(dat + fcur * (pres->siz_roociRes[cid]));
            if (tsdt)
            {
              rc = OCIDescriptorFree(tsdt,
                  (exttype == SQLT_TIMESTAMP_LTZ) ?  OCI_DTYPE_TIMESTAMP_LTZ :
                  (exttype == SQLT_TIMESTAMP) ? OCI_DTYPE_TIMESTAMP :
                                                OCI_DTYPE_INTERVAL_DS);
              if (rc != OCI_SUCCESS)
                return rc;
            }
          }
#endif
        }

        if (exttype == SQLT_NTY ||
            exttype == SQLT_REF)
        {
          void **pobj;
          dat = (ub1 *)pres->dat_roociRes[cid];

          for (fcur = 0; fcur < numrows; fcur++)
          {
            pobj = *(void **)(dat + fcur * (pres->siz_roociRes[cid]));
            if (pobj)
            {
              rc = OCIObjectFree(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                                 pcon->err_roociCon, pobj,
                                 OCI_OBJECTFREE_FORCE);
              if (rc != OCI_SUCCESS)
                return rc;
            }
          }
        }

        ROOCI_MEM_FREE(pres->dat_roociRes[cid]);
      }

    ROOCI_MEM_FREE(pres->dat_roociRes);
  }

  /* free types */
  if (pres->typ_roociRes)
  {
    /* free object types */
    for (cid = 0; cid < pres->ncol_roociRes; cid++)
    {
      if (pres->typ_roociRes[cid].obtyp_roociColType.otyp_roociObjType)
      {
        rc = OCIObjectFree(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                           pcon->err_roociCon,
                 pres->typ_roociRes[cid].obtyp_roociColType.otyp_roociObjType,
                           OCI_OBJECTFREE_FORCE);
        if (rc != OCI_SUCCESS)
          return rc;
      }

      rc= roociFreeObjs(&pres->typ_roociRes[cid].obtyp_roociColType);
      if (rc != OCI_SUCCESS)
        return rc;
    }

    ROOCI_MEM_FREE(pres->typ_roociRes);
  }

  /* free form of use */
  if (pres->form_roociRes)
  {
    ROOCI_MEM_FREE(pres->form_roociRes);
  }

  /* free indicator buffers */
  if (pres->ind_roociRes)
  {
    for (cid = 0; cid < pres->ncol_roociRes; cid++)
      if (pres->ind_roociRes[cid])
      {
        ROOCI_MEM_FREE(pres->ind_roociRes[cid]);
      }

    ROOCI_MEM_FREE(pres->ind_roociRes);
  }

  /* free length buffers */
  if (pres->len_roociRes)
  {
    for (cid = 0; cid < pres->ncol_roociRes; cid++)
      if (pres->len_roociRes[cid])
      {
        ROOCI_MEM_FREE(pres->len_roociRes[cid]);
      }

    ROOCI_MEM_FREE(pres->len_roociRes);
  }

  /* free buffer sizes */
  if (pres->siz_roociRes)
  {
    ROOCI_MEM_FREE(pres->siz_roociRes);
  }

  /* free temp LOB buffer */
  if (pres->lobbuf_roociRes)
  {
    ROOCI_MEM_FREE(pres->lobbuf_roociRes);
  }

  /* free epoch descriptor */
  if (pres->epoch_roociRes)
    OCIDescriptorFree(pres->epoch_roociRes,
                      pcon->timesten_rociCon ? OCI_DTYPE_TIMESTAMP :
                                               OCI_DTYPE_TIMESTAMP_LTZ);

  /* free interval descriptor */
  if (pres->diff_roociRes)
    OCIDescriptorFree(pres->diff_roociRes, OCI_DTYPE_INTERVAL_DS);

  if (pres->tsdes_roociRes)
    OCIDescriptorFree(pres->tsdes_roociRes,
                      pcon->timesten_rociCon ? OCI_DTYPE_TIMESTAMP :
                                               OCI_DTYPE_TIMESTAMP_LTZ);
  /* release the statement */
  if (pres->stm_roociRes)
  {
    rc = OCIStmtRelease(pres->stm_roociRes, pcon->err_roociCon, 
                        (OraText *)NULL, 0, OCI_DEFAULT);
    pres->stm_roociRes = NULL;

    if (rc != OCI_SUCCESS)
      return rc;
  }

  if (pres->vecarr_roociRes)
    ROOCI_MEM_FREE(pres->vecarr_roociRes);

  if (pres->indarr_roociRes)
    ROOCI_MEM_FREE(pres->indarr_roociRes);

  /* free cursor handle */
  if (pres->stm_cur_roociRes)
  {
    /* free cursor statement handle buffer */
    rc = OCIHandleFree(*pres->stm_cur_roociRes, OCI_HTYPE_STMT);
    *pres->stm_cur_roociRes = NULL;

    if (rc != OCI_SUCCESS)
      return rc;
  }

  /* free ro result */
  if (pcon)
    pcon->res_roociCon[pres->resID_roociRes] = NULL;

  return rc;
} /* end roociResFree */


static sword roociFreeObjs(roociObjType *objtyp)
{
  sword rc = 0;
  int   i;
  int   nattr = objtyp->nattr_roociObjType;
  for (i = 0; i < nattr; i++)
  {
    roociObjType *embobj = &objtyp->typ_roociObjType[i].obtyp_roociColType;
    rc = roociFreeObjs(embobj);

    if (objtyp->typ_roociObjType[i].loc_roociColType)
      rc = OCIDescriptorFree(objtyp->typ_roociObjType[i].loc_roociColType,
                             OCI_DTYPE_LOB);
  }

  ROOCI_MEM_FREE(objtyp->typ_roociObjType);
  return rc;
}

/* ------------------------- roociGetFirstParentCon ----------------------- */

void *roociGetFirstParentCon(roociCtx *pctx)
{
  if (pctx->con_roociCtx)
  {
    int conID;

    for (conID = 0; conID < pctx->max_roociCtx; conID++)
    {
      if (pctx->con_roociCtx[conID])
        break;
    }

    if (conID != pctx->max_roociCtx)
    {
      pctx->acc_roociCtx.conID_roociConAccess = conID;
      pctx->acc_roociCtx.num_roociConAccess   = 1;
      return (pctx->con_roociCtx[conID]->parent_roociCon);
    }
  }

  return ((void *)NULL);
} /* end roociGetFirstParentCon */

/* -------------------------- roociGetNextParentCon ----------------------- */

void *roociGetNextParentCon(roociCtx *pctx)
{
  if (pctx->con_roociCtx)
  {
    int conID = pctx->acc_roociCtx.conID_roociConAccess;

    for (; conID < pctx->max_roociCtx; conID++)
    {
      if (pctx->con_roociCtx[conID])
        break;
    }

    if (conID != pctx->max_roociCtx)
    {
      pctx->acc_roociCtx.conID_roociConAccess = conID;
      pctx->acc_roociCtx.num_roociConAccess++;
      return (pctx->con_roociCtx[conID]->parent_roociCon);
    }
  }

  return ((void *)NULL);
} /* end roociGetNextParentCon */


/* ------------------------- roociGetFirstParentRes ----------------------- */

void *roociGetFirstParentRes(roociCon *pcon)
{
  if (pcon->res_roociCon)
  {
    int resID;

    for (resID = 0; resID < pcon->max_roociCon; resID++)
    {
      if (pcon->res_roociCon[resID])
        break;
    }

    if (resID != pcon->max_roociCon)
    {
      pcon->acc_roociCon.resID_roociResAccess = resID;
      pcon->acc_roociCon.num_roociResAccess   = 1;
      return ((pcon->res_roociCon[resID])->parent_roociRes);
    }
  }

  return ((void *)NULL);
} /* end roociGetFirstParentRes */

/* -------------------------- roociGetNextParentRes ----------------------- */

void *roociGetNextParentRes(roociCon *pcon)
{
  if (pcon->res_roociCon)
  {
    int resID = pcon->acc_roociCon.resID_roociResAccess;

    for (; resID < pcon->max_roociCon; resID++)
    {
      if (pcon->res_roociCon[resID])
        break;
    }

    if (resID != pcon->max_roociCon)
    {
      pcon->acc_roociCon.resID_roociResAccess = resID;
      pcon->acc_roociCon.num_roociResAccess   = 1;
      return ((pcon->res_roociCon[resID])->parent_roociRes);
    }
  }

  return ((void *)NULL);
} /* end roociGetNextParentRes */

/* --------------------------- roociAllocDescBindBuf ---------------------- */

sword roociAllocDescBindBuf(roociRes *pres, void **buf, sb4 bndsz,
                            ub4 desc_type)
{
  void        **tsdt;
  sword         rc    = OCI_SUCCESS;

#if OCI_MAJOR_VERSION > 10
  tsdt = buf;
  rc = OCIArrayDescriptorAlloc(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                               tsdt, desc_type, pres->bmax_roociRes, 0, NULL);
  if (rc == OCI_ERROR)
    return rc;
#else
  ub1          *dat   = (ub1 *)buf;
  int           fcur  = 0;

  for (fcur = 0; fcur < pres->bmax_roociRes; fcur++)
  {
    tsdt = (void **)(dat + fcur * bndsz);
    rc = OCIDescriptorAlloc(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                            tsdt, desc_type, 0, NULL);
    if (rc == OCI_ERROR)
      return rc;
  }
#endif
  return rc;
} /* end roociAllocDescBindBuf */


#if defined(OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
static SEXP call_sparseVector_from_c(void *vecarr, ub4 *indarray,
                                     ub4 dimension, ub4 indices, ub4 vformat)
{
  SEXP sparse_Vec_call;
  SEXP x;
  SEXP i;
  SEXP length;
  SEXP out;
  int  j;

  // equivalent of:
  // sparseVector(arg1 = x, arg2 = i, arg3 = length)
  sparse_Vec_call = PROTECT(Rf_allocVector(LANGSXP, 4)); // 4 = # of args + 1 
  SETCAR(sparse_Vec_call, install("sparseVector")); 
  
#ifdef DEBUG
      printf("Beg call_sparseVector_from_c: dimension=%d indices=%d\n",
             dimension, indices);
#endif
  SEXP s = CDR(sparse_Vec_call);
  if (vformat == OCI_ATTR_VECTOR_FORMAT_BINARY)
  {
    ub1 *ub1varr  = (ub1 *)vecarr;
    PROTECT(x = NEW_RAW((int)indices));
    for (j = 0; j < (int)indices; j++)
    {
#ifdef DEBUG
      printf("j=%d indarray[j]=%d ub1varr[j]=%d\n", j, indarray[j], ub1varr[j]);
#endif
      if (ub1varr[j])
        RAW(x)[j] = (ub1)ub1varr[j];
    }
  }
  else
  {
    double *dblvarr  = (double *)vecarr;

    PROTECT(x = NEW_NUMERIC((int)indices));

    for (j = 0; j < (int)indices; j++)
    {
#ifdef DEBUG
      printf("j=%d indarray[j]=%d dblvarr[j]=%f\n", j, indarray[j], dblvarr[j]);
#endif
      if (dblvarr[j])
        REAL(x)[j] = (double)dblvarr[j];
    }
  }
#ifdef DEBUG

  Rf_PrintValue(x);
#endif
  SETCAR(s, x);
  SET_TAG(s, Rf_install("x"));

  /* BUG 37969986 : Indices not returned correctly in sparse vector */ 
  /* Fixed in RDBMS MAIN; remove loop once backported to older clients */
  for (j = 0; j < indices; j ++)
  {
    if ((j > 0) && (indarray[j] == 0))
    {
      indices = j;
      break;
    }
  }
 
  s = CDR(s);
  PROTECT(i = NEW_INTEGER((int)indices));
  for (j = 0; j < indices; j ++)
  {
#ifdef DEBUG
    printf("j=%d indarr[j]=%d\n", j, indarray[j]);
#endif
    /* Oracle index is 0-based, R is 1-based */
    INTEGER(i)[j] = indarray[j]+1;
  }
#ifdef DEBUG

  Rf_PrintValue(i);
#endif
  SETCAR(s, i);
  SET_TAG(s, Rf_install("i"));

  s = CDR(s);
  PROTECT(length = NEW_INTEGER(1));
  INTEGER(length)[0] = (int)dimension;
  SETCAR(s, length);
  SET_TAG(s, Rf_install("length"));

#ifdef DEBUG
  Rf_PrintValue(length);
#endif

  out = PROTECT(Rf_eval(sparse_Vec_call,  R_GlobalEnv));

  UNPROTECT(5);

#ifdef DEBUG
      printf("End call_sparseVector_from_c: dimension=%d indices=%d\n",
             dimension, indices);
#endif
  return (out);
}
#endif

#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
/* --------------------------- roociReadVectorData --------------------------- */
/* Read Vector data */
sword roociReadVectorData(roociRes *pres, OCIVector *vecdp,
                          SEXP *lst, boolean ora_attributes, int cid, boolean isOutbind)
{
  sword          rc = OCI_SUCCESS;
#if OCI_MAJOR_VERSION < 23
  char      warnmsg[UB1MAXVAL];
  roociCtx *pctx = pres->con_roociRes->ctx_roociCon;
  snprintf(warnmsg, sizeof(warnmsg),
       "Vector data or type can only be specified with compiled version 23.4 "
       "or higher of Oracle Client, current version of client: %d.%d "
       "ROracle compiled using Oracle Client version %d",
       pctx->ver_roociCtx.maj_roociloadVersion,
       pctx->ver_roociCtx.minor_roociloadVersion,
       pctx->compiled_maj_roociCtx);
  warning((const char *)"%s",warnmsg);
#else
  roociCon      *pcon = pres->con_roociRes;
  OCIError      *errhp = pcon->err_roociCon;
  SEXP           Vec = (SEXP)0;
  SEXP           VecArray = (SEXP)0;
  ub4            dimension;
  ub4            vprop_roociColType  = FALSE;
  ub1            vformat   = 0;
  
  if(!isOutbind)
  {
    vformat =  pres->typ_roociRes[cid].vfmt_roociColType;
    vprop_roociColType =  pres->typ_roociRes[cid].vprop_roociColType;
  }
  else
  {
    if ((rc = OCIAttrGet(vecdp, OCI_DTYPE_VECTOR, &vprop_roociColType, NULL,
                         OCI_ATTR_VECTOR_PROPERTY, pcon->err_roociCon)) !=
        OCI_SUCCESS)
      ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                           "roociReadVectorData - OCI_ATTR_VECTOR_PROPERTY");

    if ((rc = OCIAttrGet(vecdp, OCI_DTYPE_VECTOR, &vformat, NULL,
                         OCI_ATTR_VECTOR_DATA_FORMAT, pcon->err_roociCon)) !=
        OCI_SUCCESS)
      ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                           "roociReadVectorData - OCI_ATTR_VECTOR_PROPERTY");
  }

  if ((rc = OCIAttrGet(vecdp, OCI_DTYPE_VECTOR, &dimension,
                       NULL, OCI_ATTR_VECTOR_DIMENSION, pcon->err_roociCon)) !=
      OCI_SUCCESS)
    ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                         "roociReadVectorData - OCI_ATTR_VECTOR_DIMENSION");
#ifdef DEBUG
{
   char buf[1024];
   ub4  len = 1024;
   OCIVectorToText(vecdp, errhp, buf, &len, OCI_DEFAULT);
   fprintf(stdout, "text-%.*s dimension=%d prop=%d\n", len, buf, dimension,
           vprop_roociColType);
}
#endif

  PROTECT(Vec = NEW_LIST((int)1));
#if ((OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 4) || (OCI_MAJOR_VERSION > 23))
# if defined(OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
  if (vprop_roociColType & OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
  {
    ub4   indices  = dimension;
    ub4  *indarray = (ub4 *)0;
    int   dim = (int)dimension/8;

    ROOCI_MEM_ALLOC(indarray, dimension, sizeof(ub4));
    if (vformat == OCI_ATTR_VECTOR_FORMAT_BINARY)
    {
      ub1  *vecarr =  (ub1 *)0;
      ROOCI_MEM_ALLOC(vecarr, dim, sizeof(ub1));
      rc = OCIVectorToSparseArray(vecdp, errhp, vformat, &dimension,
                                  &indices, (void *)indarray, (void *)vecarr,
                                  OCI_DEFAULT);
      if (rc == OCI_SUCCESS)
      {
        int i;

        /* compute the number of indices which are non-zero */
        indices = 0;
        for (i = 0; i < (int)dimension; i++)
        {
          if (vecarr[i])
            indices++;
        }

        if (pres->sparse_vec_roociRes)
          VecArray = call_sparseVector_from_c((void *)vecarr, indarray,
                                              dimension, indices, vformat);
        else
        {
          int i;
          PROTECT(VecArray = NEW_RAW(dim));
          for (i = 0; i < (int)dim; i++)
            REAL(VecArray)[i] = 0;

          for (i = 0; i < (int)indices; i++)
          {
            if (vecarr[i])
              RAW(VecArray)[indarray[i]+1] = (ub1)vecarr[i];
                                    /* Oracle index is 0-based, R is 1-based */
          }
        }
      }
      ROOCI_MEM_FREE(vecarr);
    }
    else
    {
      double  *vecarr =  (double *)0;

      ROOCI_MEM_ALLOC(vecarr, dimension, sizeof(double));
      rc = OCIVectorToSparseArray(vecdp, errhp,
                                  (ub1)OCI_ATTR_VECTOR_FORMAT_FLOAT64,
                                  &dimension, &indices, (void *)indarray,
                                  (void *)vecarr, OCI_DEFAULT);
      if (rc == OCI_SUCCESS)
      {
        int i;

        /* compute the number of indices which are non-zero */
        indices = 0;
        for (i = 0; i < (int)dimension; i++)
        {
          if (vecarr[i])
            indices++;
        }

        if (pres->sparse_vec_roociRes)
          VecArray = call_sparseVector_from_c((void *)vecarr, indarray,
                                              dimension, indices, vformat);
        else
        {
          PROTECT(VecArray = NEW_NUMERIC((int)dimension));
          for (i = 0; i < (int)dimension; i++)
            REAL(VecArray)[i] = 0.0;

          for (i = 0; i < (int)indices; i++)
          {
            if (vecarr[i])
              REAL(VecArray)[indarray[i]] = (double)vecarr[i];
                                    /* Oracle index is 0-based, R is 1-based */
          }
        }
      }
      ROOCI_MEM_FREE(vecarr);
    }

    ROOCI_MEM_FREE(indarray);
  }
  else
  {
    if (vformat == OCI_ATTR_VECTOR_FORMAT_BINARY)
    {
      PROTECT(VecArray = NEW_RAW((int)dimension/8));
      rc = OCIVectorToArray(vecdp, errhp, OCI_ATTR_VECTOR_FORMAT_BINARY,
                            &dimension, &RAW(VecArray)[0], OCI_DEFAULT);
    }
  else 
    {
      PROTECT(VecArray = NEW_NUMERIC((int)dimension));
      rc = OCIVectorToArray(vecdp, errhp, OCI_ATTR_VECTOR_FORMAT_FLOAT64,
                            &dimension, &REAL(VecArray)[0], OCI_DEFAULT);
    }
  }
# else
  if (vformat == OCI_ATTR_VECTOR_FORMAT_BINARY)
  {
    PROTECT(VecArray = NEW_RAW((int)dimension/8));
    rc = OCIVectorToArray(vecdp, errhp, OCI_ATTR_VECTOR_FORMAT_BINARY,
                          &dimension, &RAW(VecArray)[0], OCI_DEFAULT);
  }
  else 
  {
    PROTECT(VecArray = NEW_NUMERIC((int)dimension));
    rc = OCIVectorToArray(vecdp, errhp, OCI_ATTR_VECTOR_FORMAT_FLOAT64,
                          &dimension, &REAL(VecArray)[0], OCI_DEFAULT);
  }
# endif
#endif

  if (rc != OCI_SUCCESS)
  {
#if defined(OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
    if (vprop_roociColType & OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
      ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                         "roociReadVectorData - OCIVectorToSparseArray");
    else
#endif
    ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                         "roociReadVectorData - OCIVectorToArray");
  }

#if defined(OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
  if ((vprop_roociColType & OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE) || 
      (vprop_roociColType & OCI_ATTR_VECTOR_COL_PROPERTY_IS_FLEX ))
#else
  if (vprop_roociColType & OCI_ATTR_VECTOR_COL_PROPERTY_IS_FLEX )
#endif
  {
    // Sparse or flex: return a list with VecArray inside
    SET_VECTOR_ELT(Vec, 0, VecArray);
    *lst = Vec;
    UNPROTECT(2);  // VecArray and Vec
  }
  else
  {
    // fixed-dimension: return VecArray directly
    *lst = VecArray;
    UNPROTECT(1);  // Only VecArray was protected
  }

#endif
// #undef vformat
// #undef vprop_roociColType
  return rc;
}


/* --------------------------- roociWriteVectorData --------------------------- */
/* Write Vector data */
sword roociWriteVectorData(roociRes *pres, roociColType *btyp,
                           OCIVector *vecdp, SEXP lst, ub1 form_of_use,
                           sb2 *pind)
{ 
  sword          rc = OCI_SUCCESS;
#if OCI_MAJOR_VERSION < 23
  char       warnmsg[UB1MAXVAL];
  roociCtx  *pctx = pres->con_rodbiRes->ctx_rodbiDrv;
  snprintf(warnmsg, UB1MAXVAL - 1,
       "Vector data or type can only be specified with compiled version 23.4 "
       "or higher of Oracle client, current version of client: %d.%d "
       "ROracle compiled using Oracle cleint version %d",
       pctx->ver_roociCtx.maj_roociloadVersion,
       pctx->ver_roociCtx.minor_roociloadVersion,
       pctx->compiled_maj_roociCtx);
  warning((const char *)"%s",warnmsg);
#else
  roociCon      *pcon = pres->con_roociRes;
  OCIError      *errhp = pcon->err_roociCon;
  ub4            dimension;
  SEXP           elem = ((TYPEOF(lst) == VECSXP) ? VECTOR_ELT(lst, 0) : lst);
  int            i;

  if (isNull(elem))
    dimension = 0;
  else
    dimension = length(elem);

  if (dimension == 0)
  {
    *pind = OCI_IND_NULL;
    return (rc);
  }

#ifdef DEBUG
  {
    SEXP    class = (SEXP)0;
    fprintf(stdout,
            "Beg roociWriteVectorData: lst=%p TYPEOF(lst) = %d elem = %p TYPEOF(elem) =%d\n",
            lst, TYPEOF(lst), elem, elem ? TYPEOF(elem) : -1);
     Rf_PrintValue(lst);
     if (elem)
       Rf_PrintValue(elem);
     Rf_PrintValue(class = Rf_getAttrib(elem, R_ClassSymbol));
     if (class && (TYPEOF(class) == STRSXP))
     {
       fprintf(stdout, "class=%s\n", CHAR(STRING_ELT(class, 0)));
     }
     else
       fprintf(stdout, "No class in elem\n");
     fprintf(stdout,
             "End roociWriteVectorData: TYPEOF(lst) = %d TYPEOF(elem) =%d\n",
             TYPEOF(lst), elem ? TYPEOF(elem) : -1);
  }
#endif

  if (TYPEOF(elem) == REALSXP)
  {
    if (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_BINARY)
    {
      ub1 *ptmpvec;

      if (dimension > pres->lvecarr_roociRes)
      {
        if (pres->vecarr_roociRes)
          ROOCI_MEM_FREE(pres->vecarr_roociRes);

        ROOCI_MEM_ALLOC(pres->vecarr_roociRes, dimension, sizeof(ub1));
        pres->lvecarr_roociRes = dimension;
      }

      ptmpvec = (ub1 *)pres->vecarr_roociRes;

#if defined(OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
      if (pres->sparse_vec_roociRes)
      {
        ub4    *ptmpind;
        ub4     indices = 0;

        /* vector data in data frame has elements with zeros */
        if (pres->sparse_vec_roociRes)
        {
          if (pres->indarr_roociRes)
            ROOCI_MEM_FREE(pres->indarr_roociRes);

          ROOCI_MEM_ALLOC(pres->indarr_roociRes, dimension, sizeof(ub4));
          pres->lindarr_roociRes = dimension;
        }
        ptmpind = (ub4 *)pres->indarr_roociRes;
        for (i = 0; i < dimension; i++)
        {
          if (REAL(elem)[i])
          {
            *ptmpvec++ = (ub1)(REAL(elem)[i]);
            *ptmpind++ = i;
            indices++;
          }
        }

        dimension *= 8;

        rc = OCIVectorFromSparseArray(vecdp, errhp,
                                      OCI_ATTR_VECTOR_FORMAT_BINARY,
                                      dimension, indices, pres->indarr_roociRes,
                                      pres->vecarr_roociRes, OCI_DEFAULT);
      }
      else
#endif
      {
        for (i = 0; i < dimension; i++)
        {
          *ptmpvec++ = (ub1)(REAL(elem)[i]);
        }

        dimension *= 8;

        rc = OCIVectorFromArray(vecdp, errhp, OCI_ATTR_VECTOR_FORMAT_BINARY,
                                dimension, pres->vecarr_roociRes, OCI_DEFAULT);
      }
    }
    else
    {
#if defined(OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
      if (pres->sparse_vec_roociRes)
      {
        ub4    *ptmpind;
        ub4     indices = 0;
        double *ptmpvec;

        if (dimension > pres->lvecarr_roociRes)
        { 
          if (pres->vecarr_roociRes)
            ROOCI_MEM_FREE(pres->vecarr_roociRes);

          ROOCI_MEM_ALLOC(pres->vecarr_roociRes, dimension, sizeof(double));
          pres->lvecarr_roociRes = dimension;
        
          /* vector data in data frame has elements with zeros */
          if (pres->indarr_roociRes)
            ROOCI_MEM_FREE(pres->indarr_roociRes);

          ROOCI_MEM_ALLOC(pres->indarr_roociRes, dimension, sizeof(ub4));
          pres->lindarr_roociRes = dimension;
        }
        
        ptmpvec = (double *)pres->vecarr_roociRes;
        ptmpind = (ub4 *)pres->indarr_roociRes;
        for (i = 0; i < dimension; i++)
        {
          if (REAL(elem)[i])
          {
            *ptmpvec++ = (REAL(elem)[i]);
            *ptmpind++ = i;
            indices++;
          }
        }

        rc = OCIVectorFromSparseArray(vecdp, errhp,
                                      OCI_ATTR_VECTOR_FORMAT_FLOAT64,
                                      dimension, indices, pres->indarr_roociRes,
                                      pres->vecarr_roociRes, OCI_DEFAULT);
      }
      else
#endif
        rc = OCIVectorFromArray(vecdp, errhp, OCI_ATTR_VECTOR_FORMAT_FLOAT64,
                                dimension, &REAL(elem)[0], OCI_DEFAULT);
    }
  }
#if ((OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 4) || (OCI_MAJOR_VERSION > 23))
  else if (TYPEOF(elem) == RAWSXP)
  {
    if ((btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_BINARY) ||
        (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_INT8))
    {
#if defined(OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
      ub1 *ptmpvec;

      if (dimension > pres->lvecarr_roociRes)
      {
        if (pres->vecarr_roociRes)
          ROOCI_MEM_FREE(pres->vecarr_roociRes);

        ROOCI_MEM_ALLOC(pres->vecarr_roociRes, dimension, sizeof(ub1));
        pres->lvecarr_roociRes = dimension;
      }

      ptmpvec = (ub1 *)pres->vecarr_roociRes;

      if (pres->sparse_vec_roociRes)
      {
        ub4 *ptmpind;
        ub4  indices = 0;

        /* vector data in data frame has elements with zeros */
        if (pres->sparse_vec_roociRes)
        {
          if (pres->indarr_roociRes)
            ROOCI_MEM_FREE(pres->indarr_roociRes);

          ROOCI_MEM_ALLOC(pres->indarr_roociRes, dimension, sizeof(ub4));
          pres->lindarr_roociRes = dimension;
        }
        ptmpind = (ub4 *)pres->indarr_roociRes;

        for (i = 0; i < dimension; i++)
        {
          if (RAW(elem)[i])
          {
            *ptmpvec++ = (ub1)(RAW(elem)[i]);
            *ptmpind++ = i;
            indices++;
          }
        }

        if (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_BINARY)
          dimension *= 8;

        rc = OCIVectorFromSparseArray(vecdp, errhp,
                                      btyp->vfmt_roociColType,
                                      dimension, indices, pres->indarr_roociRes,
                                      pres->vecarr_roociRes, OCI_DEFAULT);
      }
      else
#endif
      {
        if (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_BINARY)
          dimension *= 8;

        rc = OCIVectorFromArray(vecdp, errhp, btyp->vfmt_roociColType,
                                dimension, &RAW(elem)[0], OCI_DEFAULT);
      }
    }
    else
      Rf_error(_("RAWSXP can only have binary or int8 specified in ora.format,"));
  }
#endif
  else if (TYPEOF(elem) == INTSXP)
  {
    if (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_BINARY)
    {
      ub1 *ptmpvec;

      if (dimension > pres->lvecarr_roociRes)
      {
        if (pres->vecarr_roociRes)
          ROOCI_MEM_FREE(pres->vecarr_roociRes);

        ROOCI_MEM_ALLOC(pres->vecarr_roociRes, dimension, sizeof(ub1));
        pres->lvecarr_roociRes = dimension;
      }

      ptmpvec = (ub1 *)pres->vecarr_roociRes;

#if defined(OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
      if (pres->sparse_vec_roociRes)
      {
        ub4    *ptmpind;
        ub4     indices = 0;

        /* vector data in data frame has elements with zeros */
        if (pres->sparse_vec_roociRes)
        {
          if (pres->indarr_roociRes)
            ROOCI_MEM_FREE(pres->indarr_roociRes);

          ROOCI_MEM_ALLOC(pres->indarr_roociRes, dimension, sizeof(ub4));
          pres->lindarr_roociRes = dimension;
        }

        ptmpind = (ub4 *)pres->indarr_roociRes;
        for (i = 0; i < dimension; i++)
        {
          if (INTEGER(elem)[i])
          {
            *ptmpvec++ = (ub1)(INTEGER(elem)[i]);
            *ptmpind++ = i;
            indices++;
          }
        }

        dimension *= 8;

        rc = OCIVectorFromSparseArray(vecdp, errhp,
                                      OCI_ATTR_VECTOR_FORMAT_BINARY,
                                      dimension, indices, pres->indarr_roociRes,
                                      pres->vecarr_roociRes, OCI_DEFAULT);
      }
      else
#endif
      {
        for (i = 0; i < dimension; i++)
        {
          *ptmpvec++ = (ub1)(INTEGER(elem)[i]);
        }

        dimension *= 8;

        rc = OCIVectorFromArray(vecdp, errhp, OCI_ATTR_VECTOR_FORMAT_BINARY,
                                dimension, pres->vecarr_roociRes, OCI_DEFAULT);
      }
    }
    else
    {
      double *ptmpvec;

      if (dimension > pres->lvecarr_roociRes)
      { 
        if (pres->vecarr_roociRes)
          ROOCI_MEM_FREE(pres->vecarr_roociRes);

        ROOCI_MEM_ALLOC(pres->vecarr_roociRes, dimension, sizeof(double));
        pres->lvecarr_roociRes = dimension;
      }
        
      ptmpvec = (double *)pres->vecarr_roociRes;
                                      
#if defined(OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
      if (pres->sparse_vec_roociRes)
      {
        ub4    *ptmpind;
        ub4     indices = 0;

        /* vector data in data frame has elements with zeros */
        if (pres->sparse_vec_roociRes)
        {
          if (pres->indarr_roociRes)
            ROOCI_MEM_FREE(pres->indarr_roociRes);

          ROOCI_MEM_ALLOC(pres->indarr_roociRes, dimension, sizeof(ub4));
          pres->lindarr_roociRes = dimension;
        }
        
        ptmpind = (ub4 *)pres->indarr_roociRes;
        for (i = 0; i < dimension; i++)
        {
          if (INTEGER(elem)[i])
          {
            *ptmpvec++ = (double)(INTEGER(elem)[i]);
            *ptmpind++ = i;
            indices++;
          }
        }

        rc = OCIVectorFromSparseArray(vecdp, errhp,
                                      OCI_ATTR_VECTOR_FORMAT_FLOAT64,
                                      dimension, indices, pres->indarr_roociRes,
                                      pres->vecarr_roociRes, OCI_DEFAULT);
      }
      else
#endif
      {
        for (i = 0; i < dimension; i++)
        {
          *ptmpvec++ = (double)(INTEGER(elem)[i]);
        }

        rc = OCIVectorFromArray(vecdp, errhp, OCI_ATTR_VECTOR_FORMAT_FLOAT64,
                                dimension, pres->vecarr_roociRes, OCI_DEFAULT);
      }
    }
  }
  else if (TYPEOF(elem) == STRSXP) /* add support */
  {
    const char *str = CHAR(STRING_ELT(elem, 0));
    ub4         textlen = (ub4)strlen(str);
    ub4         i;

    if(btyp->bndflg_roociColType & ROOCI_COL_VEC_AS_CLOB){
      rc = OCILobCreateTemporary(pres->con_roociRes->svc_roociCon,
                                pres->con_roociRes->err_roociCon,
                                (OCILobLocator *)vecdp,
                                (ub2)OCI_DEFAULT,
                                form_of_use,
                                OCI_TEMP_CLOB, FALSE,
                                OCI_DURATION_SESSION);

      if (rc== OCI_SUCCESS)
        rc = roociWriteLOBData(pres, (OCILobLocator *)vecdp,
                              (const oratext *)str, textlen,
                              form_of_use);
    }
    else 
    {
      dimension = 0;
      if (str[0] == '[' && strchr(str + 1, '[')) 
      {
        // Likely sparse vector (e.g., [5,[2,4],[10,20]])
        dimension = atoi(&str[1]); // Extract first number
        rc = OCIVectorFromText(vecdp, errhp, OCI_ATTR_VECTOR_FORMAT_FLOAT64,
                            dimension, (const OraText *)str, strlen(str),
                            OCI_DEFAULT);   
      } 
      else 
      {
        //  dense vector (e.g., [1,2,3])
        for (i = 0; i < textlen; i++) {
          if (str[i] == ',') dimension++;
        }
        dimension++;
        if (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_BINARY)
        {
          dimension *= 8;
          rc = OCIVectorFromText(vecdp, errhp, OCI_ATTR_VECTOR_FORMAT_BINARY,
                            dimension, (const OraText *)str, strlen(str),
                            OCI_DEFAULT);  
        }
        else
        {
          rc = OCIVectorFromText(vecdp, errhp, OCI_ATTR_VECTOR_FORMAT_FLOAT64,
                            dimension, (const OraText *)str, strlen(str),
                            OCI_DEFAULT);  
        } 
      }
    }
  }
#if defined(OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
  else if (elem && (TYPEOF(elem) == OBJSXP))
    rc = roociWriteSparseVectorData(pres, btyp, vecdp, lst, form_of_use, pind);
#endif
  else
    warning("Only real, integer or character data in vector supported");

#endif
  if (rc)
    ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                         "roociWriteVectorData - OCIVectorFromArray");

  *pind = OCI_IND_NOTNULL;
  return rc;
}
#endif

/* ------------------------- roociAllocObjectBindBuf ---------------------- */

sword roociAllocObjectBindBuf(roociRes *pres, void **buf,
                              void **indbuf, int bid)
{
  void        **pobj;
  void        **pindobj;
  sword         rc    = OCI_SUCCESS;
  ub1          *dat   = (ub1 *)buf;
  ub1          *bdat  = (ub1 *)indbuf;
  int           fcur  = 0;
  roociCon    *pcon = pres->con_roociRes;
  OCIEnv      *envhp = pcon->ctx_roociCon->env_roociCtx;
  OCIError    *errhp = pcon->err_roociCon;

  for (fcur = 0; fcur < pres->bmax_roociRes; fcur++)
  {
    pobj    = (void **)(dat + fcur * (pres->bsiz_roociRes[bid]));
    pindobj = (void **)(bdat + fcur * (pres->bsiz_roociRes[bid]));
    rc = OCIObjectNew(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                pres->con_roociRes->err_roociCon,
                pres->con_roociRes->svc_roociCon,
                pres->btyp_roociRes[bid].obtyp_roociColType.otc_roociObjType,
                pres->btyp_roociRes[bid].obtyp_roociColType.otyp_roociObjType,
                (void *)NULL, OCI_DURATION_SESSION, FALSE,
                pobj);
    if (rc == OCI_ERROR)
      ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                           "roociAllocObjectBindBuf - OCIObjectNew");

    if ((rc = OCIObjectGetInd(envhp, errhp, *((void **)pobj),
                              (void **)pindobj)) == OCI_ERROR)  
      ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                           "roociAllocObjectBindBuf - OCIObjectGetInd");
  }

  return rc;
} /* end roociAllocObjectBindBuf */

/* ----------------------------- roociVecAlloc ---------------------------- */
static SEXP roociVecAlloc(roociColType *coltyp, roociObjType *parentobj,
                          int ncol, boolean ora_attributes)
{
  int           cid;
  roociObjType *objtyp = parentobj ? parentobj : &(coltyp->obtyp_roociColType);
  SEXP          Vec, VecName;
  SEXP          row_names;
  SEXP          cla; 
  SEXPTYPE      styp = VECSXP;

  /* allocates column list and names vector */
  if (ncol == 1)
  {
    roociColType *embcol = coltyp->obtyp_roociColType.typ_roociObjType;
    styp = RODBI_TYPE_SXP(embcol->typ_roociColType);
  }

  PROTECT(Vec = allocVector(VECSXP, ncol));
  PROTECT(VecName = allocVector(STRSXP, ncol));

  /* allocate column vectors */
  for (cid = 0; cid < ncol; cid++)
  {
    roociColType *embcol;

    if ((coltyp->obtyp_roociColType.otc_roociObjType ==
                                              OCI_TYPECODE_NAMEDCOLLECTION) ||
        (coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_VARRAY) ||
        (coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_REF) ||
        (coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_TABLE))
    {
      if (ncol == 1)
        embcol = coltyp;
      else
        embcol = &objtyp->typ_roociObjType[0];

      /* set column name */
      if (embcol->attrnmsz_roociColType)
        SET_STRING_ELT(VecName, cid,
                       mkCharLen((const char *)embcol->attrnm_roociColType,
                       embcol->attrnmsz_roociColType));
      else
        SET_STRING_ELT(VecName, cid,
                  Rf_mkCharLen(
                    (const char *)embcol->obtyp_roociColType.name_roociObjType,
                    embcol->obtyp_roociColType.namsz_roociObjType));
    }
    else
    {
      embcol = &objtyp->typ_roociObjType[cid];
      SET_STRING_ELT(VecName, cid,
                Rf_mkCharLen(
                   (const char *)embcol->obtyp_roociColType.name_roociObjType,
                   embcol->obtyp_roociColType.namsz_roociObjType));
    }

    /* allocate column vector */
    if (ncol == 1)
      SET_VECTOR_ELT(Vec, cid, allocVector(styp, 1));
    else
      SET_VECTOR_ELT(Vec, cid,
                    allocVector(RODBI_TYPE_SXP(embcol->typ_roociColType), 1));

    if (RODBI_TYPE_R(embcol->typ_roociColType) == RODBI_R_DAT)
    {
      PROTECT(cla = allocVector(STRSXP, 2));
      SET_STRING_ELT(cla, 0, mkChar(RODBI_R_DAT_NM));
      SET_STRING_ELT(cla, 1, mkChar("POSIXt"));
      setAttrib(VECTOR_ELT(Vec, cid), R_ClassSymbol, cla);
      UNPROTECT(1);
    }
    else if (RODBI_TYPE_R(embcol->typ_roociColType) == RODBI_R_DIF)
    {
      setAttrib(VECTOR_ELT(Vec, cid), install("units"),
                ScalarString(mkChar("secs")));
      setAttrib(VECTOR_ELT(Vec, cid), R_ClassSymbol,
                ScalarString(mkChar(RODBI_R_DIF_NM)));
    }

    if ((((coltyp->obtyp_roociColType.otc_roociObjType ==
                                               OCI_TYPECODE_NAMEDCOLLECTION) ||
        (coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_VARRAY) ||
        (coltyp->obtyp_roociColType.otc_roociObjType == OCI_TYPECODE_TABLE)) &&
         embcol->obtyp_roociColType.nattr_roociObjType) &&
         embcol->namsz_roociColType)
      setAttrib(VECTOR_ELT(Vec, cid), install("ora.type"),
                ScalarString(
                       Rf_mkCharLen((const char *)embcol->name_roociColType,
                                    embcol->namsz_roociColType)));
    else if ((coltyp->obtyp_roociColType.otc_roociObjType ==
                                                        OCI_TYPECODE_OBJECT) &&
                 ((embcol->typ_roociColType == RODBI_UDT) ||
                  (embcol->typ_roociColType == RODBI_REF)))
      setAttrib(VECTOR_ELT(Vec, cid), install("ora.type"),
         ScalarString(
                Rf_mkCharLen(
                    (const char *)embcol->obtyp_roociColType.name_roociObjType,
                    embcol->obtyp_roociColType.namsz_roociObjType)));

    if (ora_attributes)
    {
      if (embcol->typ_roociColType == RODBI_NCHAR ||
          embcol->typ_roociColType == RODBI_NVARCHAR2)
      {
        ub4 sz = (embcol->colsz_roociColType / 2);

        setAttrib(VECTOR_ELT(Vec, cid), install("ora.encoding"),
                  ScalarString(mkChar("UTF-8")));
        setAttrib(VECTOR_ELT(Vec, cid), install("ora.maxlength"),
                  ScalarInteger(sz));

        if (embcol->typ_roociColType == RODBI_NCHAR)
          setAttrib(VECTOR_ELT(Vec, cid), install("ora.type"),
                  ScalarString(mkChar("char")));
      }
      else
      {
        if (embcol->typ_roociColType == RODBI_CHAR)
        {
          setAttrib(VECTOR_ELT(Vec, cid), install("ora.type"),
                  ScalarString(mkChar("char")));
          setAttrib(VECTOR_ELT(Vec, cid),
                    install("ora.maxlength"),
                    ScalarInteger(embcol->colsz_roociColType));
        }
        else if (embcol->typ_roociColType == RODBI_VARCHAR2)
        {
          setAttrib(VECTOR_ELT(Vec, cid),
                    install("ora.maxlength"),
                    ScalarInteger(embcol->colsz_roociColType));
        }
        else if (embcol->typ_roociColType == RODBI_NCLOB)
        {
          setAttrib(VECTOR_ELT(Vec, cid), install("ora.type"),
                    ScalarString(mkChar("clob")));
          setAttrib(VECTOR_ELT(Vec, cid), install("ora.encoding"),
                    ScalarString(mkChar("UTF-8")));
        }
        else if (embcol->typ_roociColType == RODBI_CLOB)
        {
          setAttrib(VECTOR_ELT(Vec, cid), install("ora.type"),
                    ScalarString(mkChar("clob")));
        }
        else if (embcol->typ_roociColType == RODBI_BLOB)
        {
          setAttrib(VECTOR_ELT(Vec, cid), install("ora.type"),
                    ScalarString(mkChar("blob")));
        }
        else if (embcol->typ_roociColType == RODBI_VEC)
        {
          setAttrib(VECTOR_ELT(Vec, cid), install("ora.type"),
                    ScalarString(mkChar("vector")));
        }
        else if (embcol->typ_roociColType == RODBI_BFILE)
        {
          setAttrib(VECTOR_ELT(Vec, cid), install("ora.type"),
                    ScalarString(mkChar("bfile")));
        }
      }
    }
  }

  /* set names attribute */
  setAttrib(Vec, R_NamesSymbol, VecName);

  /* make input data list a data.frame */
  PROTECT(row_names     = allocVector(INTSXP, 2));
  INTEGER(row_names)[0] = NA_INTEGER;
  INTEGER(row_names)[1] = - LENGTH(VECTOR_ELT(Vec, 0));
  setAttrib(Vec, R_RowNamesSymbol, row_names);
  setAttrib(Vec, R_ClassSymbol, mkString("data.frame"));
  UNPROTECT(1);

  return Vec;
} /* end roociVecAlloc */

/****************************************************************************
* Read data from attribute from DB */
static sword read_attr_val(roociRes *pres, text *names,
                           OCITypeCode typecode, void  *attr_value,
                           OCIInd ind, SEXP Vec, ub2 pos,
                           roociColType *coltyp, cetype_t enc)
{
  double       dnum;
  int          inum;
  OCIRaw      *raw = (OCIRaw *) 0;
  OCIString   *vs = (OCIString *) 0;
  ub4          rawsize = 0;
  sword        rc = OCI_SUCCESS;
  SEXP         vec  = VECTOR_ELT(Vec, pos);
  roociCon    *pcon = pres->con_roociRes;
  OCIEnv      *envhp = pcon->ctx_roociCon->env_roociCtx;
  OCIError    *errhp = pcon->err_roociCon;
  int          lob_len;
  char        *tempbuf= (char *)0;
  size_t       tempbuflen = 0;

  /* display the data based on the type code */
  switch (typecode)
  {
    case OCI_TYPECODE_DATE:
    case OCI_TYPECODE_TIME_TZ:
    case OCI_TYPECODE_TIMESTAMP:
    case OCI_TYPECODE_TIMESTAMP_TZ:
    case OCI_TYPECODE_TIMESTAMP_LTZ:

      if (!pres->epoch_roociRes)
      {
        rc = roociAllocateDateTimeDescriptors(pres);
        if (rc == OCI_ERROR)
          return rc;
      }

      if (ind == OCI_IND_NOTNULL)
      {
        if (typecode == OCI_TYPECODE_DATE)
        {
          OCIDate *pdat = (OCIDate *)attr_value;
          if (!pres->tsdes_roociRes)
            rc = OCIDescriptorAlloc(envhp, (void **)&(pres->tsdes_roociRes),
                                    pcon->timesten_rociCon ?
                                                       OCI_DTYPE_TIMESTAMP :
                                                       OCI_DTYPE_TIMESTAMP_LTZ,
                                    0, NULL);
          if (rc == OCI_ERROR)
            return rc;

          /* construct the beginning of 1970 (in the UTC timezone) */
          rc = OCIDateTimeConstruct(pcon->usr_roociCon, pcon->err_roociCon,
                                    pres->tsdes_roociRes, pdat->OCIDateYYYY,
                                    pdat->OCIDateMM, pdat->OCIDateDD,
                                    pdat->OCIDateTime.OCITimeHH,
                                    pdat->OCIDateTime.OCITimeMI,
                                    pdat->OCIDateTime.OCITimeSS, 0,
                                    (OraText*)"+00:00", 6);
          if (rc == OCI_ERROR) 
          {
            OCIDescriptorFree(pres->tsdes_roociRes,
                              pcon->timesten_rociCon ?OCI_DTYPE_TIMESTAMP :
                                                      OCI_DTYPE_TIMESTAMP_LTZ);
            return rc;
          }

          rc = roociReadDateTimeData(pres, pres->tsdes_roociRes, &dnum, 1);
        }
        else
          rc = roociReadDateTimeData(pres, (OCIDateTime *)attr_value, &dnum, 0);

        REAL(vec)[0] = dnum;
      }
      else
        REAL(vec)[0] = NA_REAL;
      break;

    case OCI_TYPECODE_RAW :                                          /* RAW */
      if (ind == OCI_IND_NOTNULL)
      {
        SEXP   rawVec;
        Rbyte *b;
        raw = *(OCIRaw **) attr_value;

        rawsize = OCIRawSize (envhp, raw);
        PROTECT(rawVec = NEW_RAW(rawsize));
        b = RAW(rawVec);
        memcpy((void *)b, (void *)OCIRawPtr(envhp, raw), rawsize);
        SET_VECTOR_ELT(vec, 0, rawVec);
        UNPROTECT(1);
      }
      else
      {
        int  len = 0;
        SEXP rawVec;

        PROTECT(rawVec = NEW_RAW(len));
        SET_VECTOR_ELT(vec, 0, rawVec);
        UNPROTECT(1);
      }
      break;

    case OCI_TYPECODE_CHAR :                         /* fixed length string */
    case OCI_TYPECODE_VARCHAR :                                 /* varchar  */
    case OCI_TYPECODE_VARCHAR2 :                                /* varchar2 */
      if (ind == OCI_IND_NOTNULL)
      {
        vs = *(OCIString **) attr_value;
        SET_STRING_ELT(vec, 0,
                       Rf_mkCharLenCE((char *)OCIStringPtr(envhp, vs),
                              OCIStringSize(envhp, vs), enc));
      }
      else
        SET_STRING_ELT(vec, 0, NA_STRING);

      break;

    case OCI_TYPECODE_SIGNED8 :                              /* BYTE - sb1  */
    case OCI_TYPECODE_UNSIGNED8 :                   /* UNSIGNED BYTE - ub1  */
    case OCI_TYPECODE_OCTET :                                       /* OCT  */
      if (ind == OCI_IND_NOTNULL)
        INTEGER(vec)[0] = *((ub1 *)attr_value);
      else
        INTEGER(vec)[0] = NA_INTEGER;
      break;

    case OCI_TYPECODE_UNSIGNED16 :                       /* UNSIGNED SHORT  */
    case OCI_TYPECODE_UNSIGNED32 :                        /* UNSIGNED LONG  */
    case OCI_TYPECODE_INTEGER :                                     /* INT  */
    case OCI_TYPECODE_SIGNED16 :                                  /* SHORT  */
    case OCI_TYPECODE_SIGNED32 :                                   /* LONG  */
    case OCI_TYPECODE_DECIMAL :                                 /* DECIMAL  */
    case OCI_TYPECODE_SMALLINT :                                /* SMALLINT */
    case OCI_TYPECODE_NUMBER :                                  /* NUMBER   */
    case OCI_TYPECODE_REAL :                                     /* REAL    */
    case OCI_TYPECODE_DOUBLE :                                   /* DOUBLE  */
    case OCI_TYPECODE_FLOAT :                                   /* FLOAT    */
      if (coltyp->extyp_roociColType == SQLT_INT)
      {
        if (ind == OCI_IND_NOTNULL)
        {
          rc = OCINumberToInt(errhp, (const OCINumber *)attr_value,
                              (uword)sizeof(inum), OCI_NUMBER_UNSIGNED,
                                     (void  *)&inum);
          INTEGER(vec)[0] = inum;
        }
        else
          INTEGER(vec)[0] = NA_INTEGER;
      }
      else
      {
        if (ind == OCI_IND_NOTNULL)
        {
          rc = OCINumberToReal(errhp, (const OCINumber *)attr_value,
                               (uword) sizeof(dnum), (void *) &dnum);
          REAL(vec)[0] = dnum;
        }
        else
          REAL(vec)[0] = NA_REAL;
      }
      break;

    case OCI_TYPECODE_CLOB:
      {
        /* read LOB data */
        if (ind == OCI_IND_NULL)
          SET_STRING_ELT(vec, 0, NA_STRING);
        else
        {
          rc = roociReadLOBData(pres, *(OCILobLocator **)attr_value, &lob_len,
                                enc);
          if ((pres->con_roociRes->timesten_rociCon) &&
              (enc == CE_UTF8))
          {
            rodbiTTConvertUCS2UTF8Data(pres,
                                       (const ub2 *)pres->lobbuf_roociRes,
                                       (size_t)(lob_len),
                                       &tempbuf, &tempbuflen);

            SET_STRING_ELT(vec, 0,
                           Rf_mkCharLenCE((char *)tempbuf, tempbuflen, enc));
          }
          else
            /* make character element */
            SET_STRING_ELT(vec, 0,
                           mkCharLenCE((const char *) pres->lobbuf_roociRes,
                                       lob_len, enc));
        }
      }
      break;

    case OCI_TYPECODE_BLOB:
    case OCI_TYPECODE_BFILE:
      if (ind == OCI_IND_NULL)
      {
        int  len = 0;
        SEXP rawVec;

        PROTECT(rawVec = NEW_RAW(len));
        SET_VECTOR_ELT(vec, 0, rawVec);
        UNPROTECT(1);
      }
      else
      {
        SEXP rawVec;
        Rbyte *b;

        /* read LOB data */
        rc = roociReadBLOBData(pres, *(OCILobLocator **)attr_value,
                               &lob_len, SQLCS_IMPLICIT,
                               coltyp->extyp_roociColType);

        PROTECT(rawVec = NEW_RAW(lob_len));
        b = RAW(rawVec);
        memcpy((void *)b, (void *)pres->lobbuf_roociRes,
               lob_len);
        SET_VECTOR_ELT(vec, 0, rawVec);
        UNPROTECT(1);
      }
      break;

    default:
      {
        Rf_error("read_attr_val: attr %s - typecode %d\n", names, typecode);
      }
      return ROOCI_DRV_ERR_TYPE_FAIL;
      break;
  }

  return rc;
}

/* --------------------------- roociReadCollData --------------------------- */
/* Read Collection data */
static sword roociReadCollData(roociRes *pres, roociColType *coltyp, void *obj,
                               void *null_obj, SEXP *lst, cetype_t enc,
                               boolean ora_attributes)
{
  ub2            pos = 1;
  OCITypeCode    typecode;
  void          *element = (void *)0,
                *null_element = (void *) 0;
  boolean        exist, eoc;
  sb4            index;
  OCIIter       *itr = (OCIIter *) 0;
  sword          rc = OCI_SUCCESS;
  roociObjType  *objtyp = &(coltyp->obtyp_roociColType);
  roociCon      *pcon = pres->con_roociRes;
  OCIEnv        *envhp = pcon->ctx_roociCon->env_roociCtx;
  OCIError      *errhp = pcon->err_roociCon;
  roociColType  *embcol = &objtyp->typ_roociObjType[0];
  roociObjType  *embobj = &(embcol->obtyp_roociColType);
  SEXP           Vec, VecName;
  SEXP           tmpVec;
  sb4            sz;

  if ((null_obj == (void *)0) &&
      (rc = OCIObjectGetInd(envhp, errhp, (void *)obj, (void **)&null_obj))
                                                                == OCI_ERROR)
    ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                         "roociReadCollData - OCIObjectGetInd");

  OCICollSize(envhp, errhp, obj, &sz);
  if (sz == 0)
  {
    Vec = R_NilValue;
    *lst = Vec;
    return (rc);
  }
  else
  {
    PROTECT(Vec = roociVecAlloc(coltyp, (roociObjType *)0, sz, ora_attributes));
    PROTECT(VecName = allocVector(STRSXP, sz));
  }

  typecode = objtyp->otc_roociObjType;

  /* support only fixed length string, ref and embedded ADT */
  switch (typecode)
  {
    case OCI_TYPECODE_NAMEDCOLLECTION :
      typecode = objtyp->colltc_roociObjType;

      switch (typecode)
      {
        case OCI_TYPECODE_VARRAY :                    /* variable array */
          typecode = embobj->otc_roociObjType;
          /* initialize the iterator */
          if ((rc = OCIIterCreate(envhp, errhp, (const OCIColl*)obj,
                                  &itr)) != OCI_SUCCESS)
            ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                                 "roociReadCollData(OCI_TYPECODE_VARRAY) - OCIIterCreate");

          /* loop through the iterator */
          for (eoc = FALSE;
               !(rc = OCIIterNext(envhp, errhp, itr, (void **)&element,
                                  (void **)&null_element, &eoc)) && !eoc;)
          {
            /* if type is named type, call the same function recursively */
            if (typecode == OCI_TYPECODE_OBJECT)
            {
              if ((rc = roociReadUDTData(pres, embcol, objtyp, element,
                                 null_element,
                                 &tmpVec, enc, ora_attributes)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                              "roociReadCollData(OCI_TYPECODE_VARRAY) - roociReadUDTData");
              SET_VECTOR_ELT(Vec, pos-1, tmpVec);
            }
            else /* else, display the scaler type attribute */
              if ((rc = read_attr_val(pres, objtyp->name_roociObjType,
                                         typecode, element,
                                         *((OCIInd *)(null_element)),
                                         Vec, pos-1, embcol, enc)) !=
                                                                   OCI_SUCCESS)
                ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                                "roociReadCollData(OCI_TYPECODE_VARRAY) - read_attr_val");

            /* set column name */
            SET_STRING_ELT(VecName, pos-1,
                           mkCharLen((const char *)embobj->name_roociObjType,
                                     (int)embobj->namsz_roociObjType));

            pos++;
          }
          break;

          case OCI_TYPECODE_TABLE :                       /* nested table */
            typecode = embobj->otc_roociObjType;
            /* move to the first element in the nested table */
            if ((rc = OCITableFirst(envhp, errhp,
                                    (const OCITable*)obj, &index)) !=
                                                                   OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                              "roociReadCollData(OCI_TYPECODE_TABLE) - OCITableFirst");

            /* read the element */
            if ((rc = OCICollGetElem(envhp, errhp,
                                     (const OCIColl *)obj, index,
                                     &exist, (void **)&element,
                                     (void **)&null_element)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                              "roociReadCollData(OCI_TYPECODE_TABLE) - OCICollGetElem");

            /* if it is named type, recursively call the same function */
            if (embobj->otc_roociObjType == OCI_TYPECODE_OBJECT ||
                embobj->otc_roociObjType == OCI_TYPECODE_NAMEDCOLLECTION )
            {
              if ((rc = roociReadUDTData(pres, embcol, objtyp, element,
                                         null_element, &tmpVec, enc,
                                         ora_attributes)) != OCI_SUCCESS)
                ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                                "roociReadCollData(OCI_TYPECODE_TABLE) - roociReadUDTData");
              SET_VECTOR_ELT(Vec, pos-1, tmpVec);
            }
            else
              if((rc = read_attr_val(pres, objtyp->name_roociObjType,
                                     typecode, element,
                                     *((OCIInd *)(null_element)),
                                     Vec, pos-1, embcol, enc)) != OCI_SUCCESS)
                ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                                "roociReadCollData(OCI_TYPECODE_TABLE) - read_attr_val");

            /* set column name */
            SET_STRING_ELT(VecName, pos-1,
                           mkCharLen((const char *)embobj->name_roociObjType,
                                     (int)embobj->namsz_roociObjType));

            for(;!(rc = OCITableNext(envhp, errhp, index,
                                     (const OCITable *)obj,
                                     &index, &exist)) && exist;)
            {
              if ((rc = OCICollGetElem(envhp, errhp,
                                       (const OCIColl *)obj, index,
                                       &exist, (void **)&element,
                                       (void **)&null_element)) !=
                                                                 OCI_SUCCESS)
                ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                                "roociReadCollData(OCI_TYPECODE_TABLE) - OCICollGetElem");

              pos++;
              if (embobj->otc_roociObjType == OCI_TYPECODE_OBJECT)
              {
                if ((rc = roociReadUDTData(pres, embcol, objtyp, element,
                                 null_element,
                                 &tmpVec, enc, ora_attributes)) != OCI_SUCCESS)
                  ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                                  "roociReadCollData(OCI_TYPECODE_TABLE) - roociReadUDTData");
                SET_VECTOR_ELT(Vec, pos-1, tmpVec);
              }
              else
                if ((rc = read_attr_val(pres, objtyp->name_roociObjType,
                                           typecode, element,
                                           *((OCIInd *)(null_element)),
                                           Vec, pos-1, embcol, enc)) !=
                                                                   OCI_SUCCESS)
                  ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                                  "roociReadCollData(OCI_TYPECODE_TABLE) - read_attr_val");

              /* set column name */
              SET_STRING_ELT(VecName, pos-1,
                             mkCharLen((const char *)embobj->name_roociObjType,
                                       (int)embobj->namsz_roociObjType));
            }
          break;

          default:
            break;
        }
        break;
      default:   /* scaler type, display the attribute value */
        rc = ROOCI_DRV_ERR_TYPE_FAIL;
        break;
  }

  /* set names attribute */
  setAttrib(Vec, R_NamesSymbol, VecName);
  *lst = Vec;
  UNPROTECT(4);
  return rc;
}

/* ---------------------------- roociReadUDTData --------------------------- */
/* Read UDT data */
sword roociReadUDTData(roociRes *pres, roociColType *coltyp,
                       roociObjType *parentobj, void *obj,
                       void *null_obj, SEXP *lst, cetype_t enc,
                       boolean ora_attributes)
{
  ub2            count, pos;
  OCITypeCode    typecode;
  OCIInd         attr_null_status;
  void          *attr_null_struct;
  void          *attr_value;
  text          *namep;
  OCIType       *attr_tdo;
  void          *object;
  void          *null_object;
  OCIType       *object_tdo;
  OCIRef        *type_ref;
  sword          rc = OCI_SUCCESS;
  roociObjType  *objtyp = &(coltyp->obtyp_roociColType);
  roociCon      *pcon = pres->con_roociRes;
  OCIEnv        *envhp = pcon->ctx_roociCon->env_roociCtx;
  OCIError      *errhp = pcon->err_roociCon;
  OCISvcCtx     *svchp = pcon->svc_roociCon;
  SEXP           Vec;
  SEXP           tmpVec;

  if ((coltyp->extyp_roociColType == SQLT_REF) &&
      (parentobj &&
       ((coltyp->attrnmsz_roociColType == parentobj->namsz_roociObjType) &&
       (!memcmp(coltyp->attrnm_roociColType, parentobj->name_roociObjType,
                coltyp->attrnmsz_roociColType)))))
  {
    objtyp = parentobj;
    count = (ub2)objtyp->nattr_roociObjType;
    PROTECT(Vec = roociVecAlloc(coltyp, parentobj, count, ora_attributes));
  }
  else
  {
    count = (ub2)objtyp->nattr_roociObjType;
    PROTECT(Vec = roociVecAlloc(coltyp, (roociObjType *)0, count,
                                ora_attributes));
  }

  if (objtyp->otc_roociObjType == OCI_TYPECODE_NAMEDCOLLECTION)
  {
    rc = roociReadCollData(pres, coltyp, obj, null_obj, &tmpVec, enc,
                           ora_attributes);
    SET_VECTOR_ELT(Vec, 0, tmpVec);
    *lst = Vec;
    UNPROTECT(3);
    return (rc);
  }

  if ((coltyp->extyp_roociColType == SQLT_REF) &&
      (!parentobj ||
       (parentobj &&
       !((coltyp->attrnmsz_roociColType == parentobj->namsz_roociObjType) &&
         (!memcmp(coltyp->attrnm_roociColType, parentobj->name_roociObjType,
                  coltyp->attrnmsz_roociColType))))))
  {
    void *tmpobj;
    /* pin the ref and get the typed table to get to person */
    rc = OCIObjectPin(envhp, errhp, obj, (OCIComplexObject *)0,
                      OCI_PIN_ANY, OCI_DURATION_SESSION,
                      OCI_LOCK_NONE, &tmpobj);
    if (rc == OCI_ERROR)
      ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                           "roociReadUDTData - OCIObjectPin");
    obj = tmpobj;
  }

  if ((null_obj == (void *)0) &&
      (rc = OCIObjectGetInd(envhp, errhp, (void *)obj, (void **)&null_obj))
                                                                == OCI_ERROR)
    ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                         "roociReadUDTData - OCIObjectGetInd");

  /* loop through all attributes in the type */
  for (pos = 1; pos <= count; pos++)
  {
    roociColType *embcol = &objtyp->typ_roociObjType[pos-1];
    roociObjType *embobj = &(embcol->obtyp_roociColType);

    attr_value = obj;
    namep = &embcol->name_roociColType[0];
    /* get the attribute */
    if ((rc = OCIObjectGetAttr(envhp, errhp, obj, null_obj,
                               objtyp->otyp_roociObjType,
                               (const oratext **)&namep,
                               &embcol->namsz_roociColType, 1,
                               (ub4 *)0, 0, &attr_null_status,
                               &attr_null_struct, &attr_value,
                               &attr_tdo)) == OCI_ERROR)
      ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                           "roociReadUDTData - OCIObjectGetAttr");

    typecode = embobj->otc_roociObjType;

    /* support only fixed length string, ref and embedded ADT */
    switch (typecode)
    {
      case OCI_TYPECODE_OBJECT :                            /* embedded ADT */
        /* recursive call to dump nested ADT data */
        if (embcol->extyp_roociColType == SQLT_REF)
          rc = roociReadUDTData(pres, embcol, objtyp, *(OCIRef **)attr_value,
                                attr_null_struct, &tmpVec, enc,
                                ora_attributes);
        else
          rc = roociReadUDTData(pres, embcol, objtyp, attr_value,
                                attr_null_struct, &tmpVec, enc,
                                ora_attributes);
          
        if (rc != OCI_SUCCESS)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociReadUDTData - roociReadUDTData");
        SET_VECTOR_ELT(Vec, pos-1, tmpVec);
        break;

      case OCI_TYPECODE_REF :                               /* embedded ADT */
        /* pin the object */
        if ((rc = OCIObjectPin(envhp, errhp, *(OCIRef **)attr_value,
                               (OCIComplexObject *)0, OCI_PIN_ANY,
                               OCI_DURATION_SESSION, OCI_LOCK_NONE,
                               &object)) != OCI_SUCCESS)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociReadUDTData(OCI_TYPECODE_REF) - OCIObjectPin");

        /* allocate the ref */
        if ((rc = OCIObjectNew(envhp, errhp, svchp,
                               OCI_TYPECODE_REF, (OCIType *)0,
                               (void *)0, OCI_DURATION_DEFAULT, FALSE,
                               (void **) &type_ref)) != OCI_SUCCESS)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociReadUDTData(OCI_TYPECODE_REF) - OCIObjectNew");

        /* get the ref of the type from the object */
        if ((rc = OCIObjectGetTypeRef(envhp, errhp, object, type_ref))
                                                                != OCI_SUCCESS)
        {
          OCIObjectFree(envhp, errhp, type_ref, OCI_OBJECTFREE_FORCE);
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociReadUDTData(OCI_TYPECODE_REF) - OCIObjectGetTypeRef");
        }

        /* pin the type ref to get the type object */
        if ((rc = OCIObjectPin(envhp, errhp, type_ref, (OCIComplexObject *)0,
                               OCI_PIN_ANY, OCI_DURATION_SESSION,
                               OCI_LOCK_NONE, (void **) &object_tdo))
                                                                != OCI_SUCCESS)
        {
          OCIObjectFree(envhp, errhp, type_ref, OCI_OBJECTFREE_FORCE);
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociReadUDTData(OCI_TYPECODE_REF) - OCIObjectPin2");
        }

        rc = OCIObjectFree(envhp, errhp, type_ref, OCI_OBJECTFREE_FORCE);
        if (rc == OCI_ERROR)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociReadUDTData(OCI_TYPECODE_REF) - OCIObjectFree");

        /* get null struct of the object */
        if ((rc = OCIObjectGetInd(envhp, errhp, object,
                                  &null_object)) != OCI_SUCCESS)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociReadUDTData(OCI_TYPECODE_REF) - OCIObjectGetInd");

        /* call the function recursively to dump the pinned object */
        if ((rc = roociReadUDTData(pres, embcol, objtyp, object, null_object,
                                   &tmpVec, enc, ora_attributes))!=OCI_SUCCESS)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociReadUDTData(OCI_TYPECODE_REF) - roociReadUDTData");
        SET_VECTOR_ELT(Vec, pos-1, tmpVec);
        break;

      case OCI_TYPECODE_NAMEDCOLLECTION :
        typecode = embobj->colltc_roociObjType;

        switch (typecode)
        {
          case OCI_TYPECODE_VARRAY :                    /* variable array */
          case OCI_TYPECODE_TABLE :                       /* nested table */
            rc = roociReadCollData(pres, embcol, *(OCIColl **)attr_value,
                                   attr_null_struct, &tmpVec, enc,
                                   ora_attributes);
            if (rc != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                        "roociReadUDTData(OCI_TYPECODE_NAMEDCOLLECTION) - roociReadCollData");
            SET_VECTOR_ELT(Vec, pos-1, tmpVec);
            break;

          case OCI_TYPECODE_OBJECT:                          /* embedded ADT */
            /* recursive call to dump nested ADT data */
            if (embcol->extyp_roociColType == SQLT_REF)
              rc = roociReadUDTData(pres, embcol, objtyp,
                                    *(OCIRef **)attr_value,
                                    attr_null_struct, &tmpVec, enc,
                                    ora_attributes);
            else
              rc = roociReadUDTData(pres, embcol, objtyp, attr_value,
                                    attr_null_struct,
                                    &tmpVec, enc, ora_attributes);
          
            if (rc != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                        "roociReadUDTData(OCI_TYPECODE_NAMEDCOLLECTION) - roociReadUDTData");
            SET_VECTOR_ELT(Vec, pos-1, tmpVec);
            break;

          case OCI_TYPECODE_REF :                            /* embedded ADT */
            /* pin the object */
            if ((rc = OCIObjectPin(envhp, errhp, *(OCIRef **)attr_value,
                                   (OCIComplexObject *)0, OCI_PIN_ANY,
                                   OCI_DURATION_SESSION, OCI_LOCK_NONE,
                                   &object)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                        "roociReadUDTData(OCI_TYPECODE_NAMEDCOLLECTION) - OCIObjectPin");

            /* allocate the ref */
            if ((rc = OCIObjectNew(envhp, errhp, svchp,
                                   OCI_TYPECODE_REF, (OCIType *)0,
                                   (void *)0, OCI_DURATION_DEFAULT, FALSE,
                                   (void **)&type_ref)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                        "roociReadUDTData(OCI_TYPECODE_NAMEDCOLLECTION) - OCIObjectNew");

            /* get the ref of the type from the object */
            if ((rc = OCIObjectGetTypeRef(envhp, errhp, object, type_ref))
                                                                != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                    "roociReadUDTData(OCI_TYPECODE_NAMEDCOLLECTION) - OCIObjectGetTypeRef");

            /* pin the type ref to get the type object */
            if ((rc = OCIObjectPin(envhp, errhp, type_ref,
                                   (OCIComplexObject *)0, OCI_PIN_ANY,
                                   OCI_DURATION_SESSION, OCI_LOCK_NONE,
                                   (void **)&object_tdo)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                        "roociReadUDTData(OCI_TYPECODE_NAMEDCOLLECTION) - OCIObjectPin2");

            rc = OCIObjectFree(envhp, errhp, type_ref, OCI_OBJECTFREE_FORCE);
            if (rc == OCI_ERROR)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                        "roociReadUDTData(OCI_TYPECODE_NAMEDCOLLECTION) - OCIObjectFree");

            /* get null struct of the object */
            if ((rc = OCIObjectGetInd(envhp, errhp, object,
                                      &null_object)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                        "roociReadUDTData(OCI_TYPECODE_NAMEDCOLLECTION) - OCIObjectGetInd");

            /* call the function recursively to dump the pinned object */
            if ((rc = roociReadUDTData(pres, embcol, objtyp, object,
                                       null_object, &tmpVec, enc,
                                       ora_attributes)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                        "roociReadUDTData(OCI_TYPECODE_NAMEDCOLLECTION) - roociReadUDTData");
            SET_VECTOR_ELT(Vec, pos-1, tmpVec);
            break;

          default:
            if ((rc = read_attr_val(pres, namep, typecode,
                                    attr_value, attr_null_status,
                                    Vec, pos-1, embcol, enc)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                        "roociReadUDTData(OCI_TYPECODE_NAMEDCOLLECTION) - read_attr_val");
            break;
        }
        break;

      default:   /* scaler type, display the attribute value */
        if ((rc = read_attr_val(pres, namep, typecode,
                                attr_value, attr_null_status,
                                Vec, pos-1, embcol, enc)) != OCI_SUCCESS)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociReadUDTData - read_attr_val");
        break;
    }
  }

  *lst = Vec;
  UNPROTECT(3);
  return rc;
}


/* --------------------------- roociWriteLOBData --------------------------- */

sword roociWriteLOBData(roociRes *pres, OCILobLocator *lob_loc,
                        const oratext *lob_buf, int lob_len, ub1 form)
{
  sword     rc   = OCI_ERROR;
  oraub8    len = lob_len;
  roociCon *pcon = pres->con_roociRes;

  /* write LOB data */
  rc = OCILobWrite2(pcon->svc_roociCon, pcon->err_roociCon, lob_loc,
                    &len, (oraub8 *)0, 1, (void *)lob_buf, len,
                    OCI_ONE_PIECE, NULL, (OCICallbackLobWrite2)0, 0,
                    form);
  if (rc == OCI_ERROR)
    return rc;

  return rc;
} /* end of roociWriteLOBData */

/* -------------------------- roociWriteBLOBData --------------------------- */

sword roociWriteBLOBData(roociRes *pres, OCILobLocator *lob_loc,
                         const ub1 *lob_buf, int lob_len, ub2 exttyp, ub1 form)
{
  sword     rc   = OCI_ERROR;
  oraub8    len = lob_len;
  roociCon *pcon = pres->con_roociRes;

  if (exttyp == SQLT_BFILE)
  {
    rc = OCILobFileOpen(pcon->svc_roociCon, pcon->err_roociCon, lob_loc,
                        (ub1)OCI_LOB_WRITEONLY);
    if (rc == OCI_ERROR)
      return rc;
  }

  /* write LOB data */
  rc = OCILobWrite2(pcon->svc_roociCon, pcon->err_roociCon, lob_loc,
                    &len, (oraub8 *)0, 1, (void *)lob_buf, len,
                    OCI_ONE_PIECE, NULL, (OCICallbackLobWrite2)0, 0,
                    form);
  if (rc == OCI_ERROR)
    return rc;

  if (exttyp == SQLT_BFILE)
  {
    rc = OCILobFileClose(pcon->svc_roociCon, pcon->err_roociCon, lob_loc);
    if (rc == OCI_ERROR)
      return rc;
  }

  return rc;
} /* end of roociWriteBLOBData */


/****************************************************************************
 * Display attribute value of an ADT 
 * Parameters:                                     
 *   res       :        environment handle
 *   names     :        name of the attribute
 *   typecode  :        type code
 *   attr_value:        attribute value pointer
 *   Vec       :        R data to write
 *   pos       :        poistion of data n R data vector
 *   coltyp    :        column type
 *   form      :        form of use
 ****************************************************************************/
static sword write_attr_val(roociRes *pres, text *names,
                            OCITypeCode typecode, void  *attr_value,
                            OCIInd *attr_null_status, SEXP vec,
                            roociColType *coltyp, ub1 form)
{
  double       dnum;
  int          inum;
  ub4          rawsize = 0;
  sword        rc = OCI_SUCCESS;
  roociCon    *pcon = pres->con_roociRes;
  OCISvcCtx   *svchp = pcon->svc_roociCon;
  OCIEnv      *envhp = pcon->ctx_roociCon->env_roociCtx;
  OCIError    *errhp = pcon->err_roociCon;
  cetype_t     enc;

  *attr_null_status = OCI_IND_NOTNULL;

  /* display the data based on the type code */
  switch (typecode)
  {
    case OCI_TYPECODE_DATE:
      {
        if (ISNA(REAL(vec)[0]))
          *attr_null_status = OCI_IND_NULL;
        else
        {
          OCIDate *pdat = (OCIDate *)attr_value;
          ub4      fs;
          if (!pres->tsdes_roociRes)
            rc = OCIDescriptorAlloc(envhp, (void **)&(pres->tsdes_roociRes),
                                    pcon->timesten_rociCon ?
                                                       OCI_DTYPE_TIMESTAMP :
                                                       OCI_DTYPE_TIMESTAMP_LTZ,
                                    0, NULL);
          if (rc == OCI_ERROR)
            return rc;

          rc = roociWriteDateTimeData(pres, pres->tsdes_roociRes, REAL(vec)[0]);
          if (rc == OCI_ERROR)
            return rc;

          rc = OCIDateTimeGetDate(pcon->usr_roociCon, errhp,
                                  (const OCIDateTime *)pres->tsdes_roociRes,
                                  &pdat->OCIDateYYYY, &pdat->OCIDateMM,
                                  &pdat->OCIDateDD);
          if (rc == OCI_ERROR)
            return rc;

          rc = OCIDateTimeGetTime(pcon->usr_roociCon, errhp,
                                  pres->tsdes_roociRes,
                                  &pdat->OCIDateTime.OCITimeHH,
                                  &pdat->OCIDateTime.OCITimeMI,
                                  &pdat->OCIDateTime.OCITimeSS,
                                  (ub4 *)&fs);
          if (rc == OCI_ERROR)
            return rc;
        }
        break;
      }

    case OCI_TYPECODE_TIME_TZ:
    case OCI_TYPECODE_TIMESTAMP:
    case OCI_TYPECODE_TIMESTAMP_TZ:
    case OCI_TYPECODE_TIMESTAMP_LTZ:
      if (ISNA(REAL(vec)[0]))
        *attr_null_status = OCI_IND_NULL;
      else
        rc = roociWriteDateTimeData(pres, (OCIDateTime *)attr_value,
                                    REAL(vec)[0]);
      break;

    case OCI_TYPECODE_RAW :                                          /* RAW */
        if (isNull(vec))
          *attr_null_status = OCI_IND_NULL;
        else
        {
          rawsize = (ub4)LENGTH(vec);
          rc= OCIRawAssignBytes(envhp, errhp, (const ub1 *)RAW(vec), rawsize,
                                (OCIRaw **)attr_value);
        }
      break;

    case OCI_TYPECODE_CHAR :                         /* fixed length string */
    case OCI_TYPECODE_VARCHAR :                                 /* varchar  */
    case OCI_TYPECODE_VARCHAR2 :                                /* varchar2 */
          if (((TYPEOF(vec) == LGLSXP) && (LOGICAL(vec)[0] == NA_LOGICAL)) ||
              (isNull(vec)))
            *attr_null_status = OCI_IND_NULL;
          else
          {
            if (form == 0)
            {
              const char *bind_enc  = NULL;
              enc = Rf_getCharCE(STRING_ELT(vec, 0));
              if (enc == CE_NATIVE)
                form = SQLCS_IMPLICIT;
              else if (enc == CE_LATIN1)
                form = SQLCS_IMPLICIT;
              else if (enc == CE_UTF8)
                form = SQLCS_NCHAR;
              else
                return (ROOCI_DRV_ERR_ENCODE_FAIL);

              /* "ora.encoding" for deciding bind_length for OUT string/raw */
              if (Rf_getAttrib(vec, Rf_mkString((const char *)"ora.encoding"))
                                                                 != R_NilValue)
                bind_enc = CHAR(STRING_ELT(Rf_getAttrib(vec,
                              Rf_mkString((const char *)"ora.encoding")), 0));
              else
              if (Rf_getAttrib(vec, Rf_mkString((const char *)"ora.encoding"))
                                                                 != R_NilValue)
                bind_enc = CHAR(STRING_ELT(Rf_getAttrib(vec,
                              Rf_mkString((const char *)"ora.encoding")), 0));

              if (bind_enc && !strcmp(bind_enc, "UTF-8"))
                form = SQLCS_NCHAR;

            }
            rc = OCIStringAssignText(envhp, errhp,
                                     (const oratext *)CHAR(STRING_ELT(vec, 0)),
                                     (ub4)strlen(CHAR(STRING_ELT(vec, 0))),
                                     (OCIString **)attr_value);
          }
      break;

    case OCI_TYPECODE_SIGNED8 :                              /* BYTE - sb1  */
    case OCI_TYPECODE_UNSIGNED8 :                   /* UNSIGNED BYTE - ub1  */
    case OCI_TYPECODE_OCTET :                                       /* OCT  */
        if (INTEGER(vec)[0] == NA_INTEGER)
          *attr_null_status = OCI_IND_NULL;
        else
          *((ub1 *)attr_value) = INTEGER(vec)[0];
      break;

    case OCI_TYPECODE_UNSIGNED16 :                       /* UNSIGNED SHORT  */
    case OCI_TYPECODE_UNSIGNED32 :                        /* UNSIGNED LONG  */
    case OCI_TYPECODE_INTEGER :                                     /* INT  */
    case OCI_TYPECODE_SIGNED16 :                                  /* SHORT  */
    case OCI_TYPECODE_SIGNED32 :                                   /* LONG  */
    case OCI_TYPECODE_DECIMAL :                                 /* DECIMAL  */
    case OCI_TYPECODE_SMALLINT :                                /* SMALLINT */
    case OCI_TYPECODE_NUMBER :                                  /* NUMBER   */
    case OCI_TYPECODE_REAL :                                     /* REAL    */
    case OCI_TYPECODE_DOUBLE :                                   /* DOUBLE  */
    case OCI_TYPECODE_FLOAT :                                   /* FLOAT    */
      if (coltyp->extyp_roociColType == SQLT_INT)
      {
        if (TYPEOF(vec) == INTSXP)
        {
          if (INTEGER(vec)[0] == NA_INTEGER)
            *attr_null_status = OCI_IND_NULL;
          else
          {
            inum = INTEGER(vec)[0];
            rc = OCINumberFromInt(errhp, (const void *)&inum, (uword)sizeof(inum),
                                  OCI_NUMBER_UNSIGNED, (OCINumber *)attr_value);
          }
        }
        else if (TYPEOF(vec) == REALSXP)
        {
          if (ISNA(REAL(vec)[0]))
            *attr_null_status = OCI_IND_NULL;
          else
          {
            dnum = REAL(vec)[0];
            rc = OCINumberFromReal(errhp, (const void *)&dnum,
                                   (uword)sizeof(dnum),
                                   (OCINumber *)attr_value);
          }
        }
      }
      else
      {
        if (ISNA(REAL(vec)[0]))
          *attr_null_status = OCI_IND_NULL;
        else
        {
          dnum = REAL(vec)[0];
          rc = OCINumberFromReal(errhp, (const void *)&dnum,
                                 (uword)sizeof(dnum),
                                 (OCINumber *)attr_value);
        }
      }
      break;

    case OCI_TYPECODE_CLOB:
      {
        if (((TYPEOF(vec) == LGLSXP) && (LOGICAL(vec)[0] == NA_LOGICAL)) ||
            (isNull(vec)))
          *attr_null_status = OCI_IND_NULL;
        else
        {
          const char *str = CHAR(STRING_ELT(vec, 0));
          int         len = (int)strlen(str);

          if (form == 0)
          {
            const char *bind_enc  = NULL;
            enc = Rf_getCharCE(STRING_ELT(vec, 0));
            if (enc == CE_NATIVE)
              form = SQLCS_IMPLICIT;
            else if (enc == CE_LATIN1)
              form = SQLCS_IMPLICIT;
            else if (enc == CE_UTF8)
              form = SQLCS_NCHAR;
            else
              return (ROOCI_DRV_ERR_ENCODE_FAIL);

            /* "ora.encoding" for deciding bind_length for OUT string/raw */
            if (Rf_getAttrib(vec, Rf_mkString((const char *)"ora.encoding"))
                                                                 != R_NilValue)
              bind_enc = CHAR(STRING_ELT(Rf_getAttrib(vec,
                              Rf_mkString((const char *)"ora.encoding")), 0));
            else
            if (Rf_getAttrib(vec, Rf_mkString((const char *)"ora.encoding"))
                                                                 != R_NilValue)
              bind_enc = CHAR(STRING_ELT(Rf_getAttrib(vec,
                              Rf_mkString((const char *)"ora.encoding")), 0));

            if (bind_enc && !strcmp(bind_enc, "UTF-8"))
              form = SQLCS_NCHAR;

          }

#if 0
          if (!coltyp->loc_roociColType)
          {
#endif
            if ((rc = OCIDescriptorAlloc(envhp,
                                         (void **)&coltyp->loc_roociColType,
                                         (ub4)OCI_DTYPE_LOB, (size_t)0,
                                         (void **)0)) != OCI_SUCCESS)
              return rc;

            if ((rc = OCILobCreateTemporary(svchp, errhp,
                                         coltyp->loc_roociColType,
                                         (ub2)OCI_DEFAULT,
                                         coltyp->form_roociColType,
                                         OCI_TEMP_CLOB, FALSE,
                                         OCI_DURATION_SESSION)) != OCI_SUCCESS)
              return rc;

            /* write LOB data */
            if ((rc = roociWriteLOBData(pres, coltyp->loc_roociColType,
                                        (const oratext *)str, len,
                                    coltyp->form_roociColType)) != OCI_SUCCESS)
              return rc;

            if ((rc = OCILobLocatorAssign(svchp, errhp,
                                          coltyp->loc_roociColType,
                                 (OCILobLocator **)attr_value)) != OCI_SUCCESS)
              return rc;
#if 0
          }
          else
            rc = roociWriteLOBData(pres, coltyp->loc_roociColType,
                                   (const oratext *)str, len,
                                   coltyp->form_roociColType);
#endif
        }
      }
      break;

    case OCI_TYPECODE_BLOB:
    case OCI_TYPECODE_BFILE:
      {
        if (((TYPEOF(vec) == LGLSXP) && (LOGICAL(vec)[0] == NA_LOGICAL)) ||
            (isNull(vec)))
          *attr_null_status = OCI_IND_NULL;
        else
        {
          int len = (int)LENGTH(vec);

          if (!coltyp->loc_roociColType)
          {
            if ((rc = OCIDescriptorAlloc(envhp,
                                         (void **)&coltyp->loc_roociColType,
                                         (ub4)OCI_DTYPE_LOB, (size_t)0,
                                         (void **)0)) != OCI_SUCCESS)
              return rc;

            if ((rc = OCILobCreateTemporary(svchp, errhp,
                                         coltyp->loc_roociColType,
                                         (ub2)OCI_DEFAULT, (ub1)form,
                                         OCI_TEMP_BLOB, FALSE,
                                         OCI_DURATION_SESSION)) != OCI_SUCCESS)
              return rc;

          /* write LOB data */
          if ((rc = roociWriteBLOBData(pres, coltyp->loc_roociColType,
                                    (const ub1 *)RAW(vec), len,
                                    coltyp->extyp_roociColType,
                                    coltyp->form_roociColType)) != OCI_SUCCESS)
            return rc;

          if ((rc = OCILobLocatorAssign(svchp, errhp, coltyp->loc_roociColType,
                                 (OCILobLocator **)attr_value)) != OCI_SUCCESS)
            return rc;
          }
          else
            rc = roociWriteBLOBData(pres, coltyp->loc_roociColType,
                                    (const ub1 *)RAW(vec), len,
                                    coltyp->extyp_roociColType,
                                    coltyp->form_roociColType);
        }
      }
      break;

    default:
      {
        Rf_error("attr %s - typecode %d\n", names, typecode);
        return ROOCI_DRV_ERR_TYPE_FAIL;
      }
      break;
  }

  return rc;
}

/* --------------------------- roociWriteCollData --------------------------- */
/* Write Collection data */
static sword roociWriteCollData(roociRes *pres, roociColType *coltyp,
                                void *obj, void *null_obj, OCIInd *objind,
                                SEXP lst, ub1 form)
{
  OCITypeCode    typecode;
  void          *element = (void *)0,
                *null_element = (void *) 0;
  OCIInd         attr_null_status;
  boolean        exists;
  sb4            index;
  sword          rc = OCI_SUCCESS;
  roociObjType  *objtyp = &(coltyp->obtyp_roociColType);
  roociCon      *pcon = pres->con_roociRes;
  OCIEnv        *envhp = pcon->ctx_roociCon->env_roociCtx;
  OCIError      *errhp = pcon->err_roociCon;
  roociColType  *embcol = &objtyp->typ_roociObjType[0];
  roociObjType  *embobj = &(embcol->obtyp_roociColType);
  SEXP           tmpVec;
  int            sz;
  sb4            collsz;
  boolean        all_elements_null = TRUE;

  if (!null_obj &&
      ((rc = OCIObjectGetInd(envhp, errhp, (void *)obj, (void **)&null_obj)))
                                                                == OCI_ERROR)
    ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                         "roociWriteCollData - OCIObjectGetInd");

  if (isNull(lst))
    sz = 0;
  else
  {
    sz = length(lst);
    for (index = 0; index < sz; index++)
    {
      if (!isNull(VECTOR_ELT(lst, index)))
        all_elements_null = FALSE;
      if (!all_elements_null)
        break;
    }

    if (all_elements_null)
      sz = 0;
  }
  if (sz == 0)
  {
    OCIInd *nulladt = (OCIInd *)null_obj;
    *nulladt = OCI_IND_NULL;
    if (objind)
      *objind = OCI_IND_NULL;
    return (rc);
  }

  typecode = objtyp->otc_roociObjType;

  if (objtyp->colltc_roociObjType == OCI_TYPECODE_VARRAY)
  {
    OCICollSize(envhp, errhp, obj, &collsz);
    if (collsz > sz)
    {
      rc = OCICollTrim(envhp, errhp, (collsz - sz), obj);
      if (rc == OCI_ERROR)
        ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                             "roociWriteCollData - OCICollTrim");
    }
  }
/*
  else
  {
    OCITableSize(envhp, errhp, (const OCITable *)obj, &collsz);
    if (collsz > sz)
    {
      rc = OCICollTrim(envhp, errhp, (collsz - sz), obj);
      if (rc == OCI_ERROR)
        ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                             "roociWriteCollData - OCICollTrim2");
    }
  }
*/

/*
  lst = VECTOR_ELT(lst, index);
*/

  /* support only fixed length string, ref and embedded ADT */
  switch (typecode)
  {
    case OCI_TYPECODE_NAMEDCOLLECTION :
      typecode = objtyp->colltc_roociObjType;

/*
      if ((TYPEOF(lst) == VECSXP))
        lst = VECTOR_ELT(lst, index);
*/
      switch (typecode)
      {
        case OCI_TYPECODE_VARRAY :                    /* variable array */
        case OCI_TYPECODE_TABLE :                       /* nested table */
          typecode = embobj->otc_roociObjType;

          for (index = 0; index < sz; index++)
          {
            tmpVec = VECTOR_ELT(lst, index);
            exists = FALSE;
            element = NULL;
            null_element = NULL;
            rc = OCICollGetElem(envhp, errhp, (const OCIColl *)obj, index,
                                &exists, (void **)&element,
                                (void **)&null_element);
            if (!exists)
            {
              element = NULL;
              null_element = NULL;
              if ((rc = OCIObjectNew(envhp, errhp, pcon->svc_roociCon, typecode,
                                     (OCIType *)embobj->otyp_roociObjType,
                                     (void *)0, OCI_DURATION_DEFAULT, FALSE,
                                     (void **)&element)) != OCI_SUCCESS)
                ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                                     "roociWriteCollData - OCIObjectNew");
            }
            else if (rc != OCI_SUCCESS)
                ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                                     "roociWriteCollData - OCICollGetElem");

            /* if type is named type, call the same function recursively */
            if (typecode == OCI_TYPECODE_OBJECT)
            {
              if ((rc = OCIObjectGetInd(envhp, errhp, element,
                                          (void **)&null_element)) == OCI_ERROR)
                ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                                 "roociWriteCollData(OCI_TYPECODE_OBJECT) - OCIObjectGetInd");

              if ((rc = roociWriteUDTData(pres, embcol, objtyp, element,
                                          null_element, &attr_null_status,
                                          tmpVec, form)) != OCI_SUCCESS)
                ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociWriteCollData(OCI_TYPECODE_OBJECT) - roociWriteUDTData");
            }
            else /* else, write the scaler type attribute */
            {
              if ((rc = write_attr_val(pres, objtyp->name_roociObjType, typecode,
                          ((typecode == OCI_TYPECODE_RAW) ||
                           (typecode == OCI_TYPECODE_CHAR) ||
                           (typecode == OCI_TYPECODE_VARCHAR) ||
                           (typecode == OCI_TYPECODE_VARCHAR2)) ? &element : element,
                          (OCIInd *)&attr_null_status,
                          tmpVec, embcol, form)) != OCI_SUCCESS)
                ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociWriteCollData - write_attr_val");

              if (attr_null_status == OCI_IND_NOTNULL)
                null_element = (void *)0;
              else
                null_element = (void *)&attr_null_status;
            }

            if (exists)
            {
              if (((rc = OCICollAssignElem(envhp, errhp, index,
                                           (const void *)element,
                                           (const void *)null_element,
                                           (OCIColl *)obj))) != OCI_SUCCESS)
                ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociWriteCollData - OCICollAssignElem");
            }
            else
            {
              if (((rc = OCICollAppend(envhp, errhp, (const void *)element,
                                       (const void *)0,
                                       (OCIColl *)obj))) != OCI_SUCCESS)
                ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociWriteCollData - roociWriteCollData");
            }
          }
          break;

          default:
            break;
        }
        break;
      default:   /* scaler type, display the attribute value */
        rc = ROOCI_DRV_ERR_TYPE_FAIL;
        break;
  }

  return rc;
}

/* ---------------------------- roociWriteUDTData -------------------------- */
/* Write UDT data */
sword roociWriteUDTData(roociRes *pres, roociColType *coltyp,
                        roociObjType *parentobj, void *obj, void *null_obj,
                        OCIInd *objind, SEXP lst, ub1 form)
{
  ub2            count, pos;
  OCITypeCode    typecode;
  OCIInd         attr_null_status;
  void          *attr_null_struct;
  void          *attr_value;
  text          *namep;
  OCIType       *attr_tdo;
  void          *object;
  void          *null_object;
  OCIType       *object_tdo;
  OCIRef        *type_ref;
  sword          rc = OCI_SUCCESS;
  roociObjType  *objtyp = &(coltyp->obtyp_roociColType);
  roociCon      *pcon = pres->con_roociRes;
  OCIEnv        *envhp = pcon->ctx_roociCon->env_roociCtx;
  OCIError      *errhp = pcon->err_roociCon;
  OCISvcCtx     *svchp = pcon->svc_roociCon;
  SEXP           tmpVec;
  boolean        all_attributes_null = TRUE;
  int            len;

  if ((coltyp->extyp_roociColType == SQLT_REF) &&
      (parentobj &&
       ((coltyp->attrnmsz_roociColType == parentobj->namsz_roociObjType) &&
       (!memcmp(coltyp->attrnm_roociColType, parentobj->name_roociObjType,
                coltyp->attrnmsz_roociColType)))))
  {
    objtyp = parentobj;
    count = (ub2)objtyp->nattr_roociObjType;
  }
  else
  {
    count = (ub2)objtyp->nattr_roociObjType;
  }

  if (objtyp->otc_roociObjType == OCI_TYPECODE_NAMEDCOLLECTION)
  {
    SEXP  x = VECTOR_ELT(lst, 0);

    rc = roociWriteCollData(pres, coltyp, obj, null_obj,
                            &attr_null_status, x, form);
    return (rc);
  }

  if ((coltyp->extyp_roociColType == SQLT_REF) &&
      (!parentobj ||
       (parentobj &&
       !((coltyp->attrnmsz_roociColType == parentobj->namsz_roociObjType) &&
         (!memcmp(coltyp->attrnm_roociColType, parentobj->name_roociObjType,
                  coltyp->attrnmsz_roociColType))))))
  {
    void *tmpobj;
    /* pin the ref and get the typed table to get to person */
    rc = OCIObjectPin(envhp, errhp, obj, (OCIComplexObject *)0,
                      OCI_PIN_ANY, OCI_DURATION_SESSION,
                      OCI_LOCK_NONE, &tmpobj);
    if (rc == OCI_ERROR)
      ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                           "roociWriteUDTData - OCIObjectPin");
    obj = tmpobj;
  }

  if (!null_obj &&
      (rc = OCIObjectGetInd(envhp, errhp, (void *)obj, (void **)&null_obj))
                                                                == OCI_ERROR)
      ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                           "roociWriteUDTData - OCIObjectGetInd");

  len = length(lst);
  if (isNull(lst) || (len == 0))
  {
    OCIInd *nulladt = (OCIInd *)null_obj;
    *nulladt = OCI_IND_NULL;
    if (objind)
      *objind = OCI_IND_NOTNULL;
    return rc;
  }
  else if (null_obj)
  {
    if (objind)
      *objind = OCI_IND_NOTNULL;
  }

  /* loop through all attributes in the type */
  for (pos = 1; pos <= count; pos++)
  {
    roociColType *embcol = &objtyp->typ_roociObjType[pos-1];
    roociObjType *embobj = &(embcol->obtyp_roociColType);

    attr_value = obj;
    namep = &embcol->name_roociColType[0];
    /* get the attribute */
    if ((rc = OCIObjectGetAttr(envhp, errhp, obj, null_obj,
                               objtyp->otyp_roociObjType,
                               (const oratext **)&namep,
                               &embcol->namsz_roociColType, 1,
                               (ub4 *)0, 0, &attr_null_status,
                               &attr_null_struct, &attr_value,
                               &attr_tdo)) == OCI_ERROR)
    {
      char msg[SB1MAXVAL];
      snprintf(msg, SB1MAXVAL, "roociWriteUDTData - OCIObjectGetAttr %.*s\n",
               embcol->namsz_roociColType, namep);
      ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon, msg);
    }

    typecode = embobj->otc_roociObjType;
    tmpVec = VECTOR_ELT(lst, pos-1);

    /* support only fixed length string, ref and embedded ADT */
    switch (typecode)
    {
      case OCI_TYPECODE_OBJECT :                            /* embedded ADT */
        /* recursive call to dump nested ADT data */
        if (embcol->extyp_roociColType == SQLT_REF)
          rc = roociWriteUDTData(pres, embcol, objtyp, *(OCIRef **)attr_value,
                                 attr_null_struct, &attr_null_status, tmpVec,
                                 form);
        else
          rc = roociWriteUDTData(pres, embcol, objtyp, attr_value,
                                 attr_null_struct, &attr_null_status, tmpVec,
                                 form);
          
        if (rc != OCI_SUCCESS)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociWriteUDTData - roociWriteUDTData");
        break;

      case OCI_TYPECODE_REF :                               /* embedded ADT */
        /* pin the object */
        if ((rc = OCIObjectPin(envhp, errhp, *(OCIRef **)attr_value,
                               (OCIComplexObject *)0, OCI_PIN_ANY,
                               OCI_DURATION_SESSION, OCI_LOCK_NONE,
                               &object)) != OCI_SUCCESS)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociWriteUDTData(OCI_TYPECODE_REF) - OCIObjectPin");

        /* allocate the ref */
        if ((rc = OCIObjectNew(envhp, errhp, svchp,
                               OCI_TYPECODE_REF, (OCIType *)0,
                               (void *)0, OCI_DURATION_DEFAULT, FALSE,
                               (void **) &type_ref)) != OCI_SUCCESS)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociWriteUDTData(OCI_TYPECODE_REF) - OCIObjectNew");

        /* get the ref of the type from the object */
        if ((rc = OCIObjectGetTypeRef(envhp, errhp, object, type_ref))
                                                                != OCI_SUCCESS)
        {
          OCIObjectFree(envhp, errhp, type_ref, OCI_OBJECTFREE_FORCE);
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociWriteUDTData(OCI_TYPECODE_REF) - OCIObjectGetTypeRef");
        }

        /* pin the type ref to get the type object */
        if ((rc = OCIObjectPin(envhp, errhp, type_ref, (OCIComplexObject *)0,
                               OCI_PIN_ANY, OCI_DURATION_SESSION,
                               OCI_LOCK_NONE, (void **) &object_tdo))
                                                                != OCI_SUCCESS)
        {
          OCIObjectFree(envhp, errhp, type_ref, OCI_OBJECTFREE_FORCE);
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociWriteUDTData(OCI_TYPECODE_REF) - OCIObjectPin2");
        }

        rc = OCIObjectFree(envhp, errhp, type_ref, OCI_OBJECTFREE_FORCE);
        if (rc == OCI_ERROR)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociWriteUDTData(OCI_TYPECODE_REF) - OCIObjectFree");

        /* get null struct of the object */
        if ((rc = OCIObjectGetInd(envhp, errhp, object,
                                  &null_object)) != OCI_SUCCESS)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociWriteUDTData(OCI_TYPECODE_REF) - OCIObjectGetInd");

        /* call the function recursively to dump the pinned object */
        if ((rc = roociWriteUDTData(pres, embcol, objtyp, object,
                                    null_object, &attr_null_status, tmpVec,
                                    form)) != OCI_SUCCESS)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                               "roociWriteUDTData(OCI_TYPECODE_REF) - roociWriteUDTData");
        break;

      case OCI_TYPECODE_NAMEDCOLLECTION :
        typecode = embobj->colltc_roociObjType;

        switch (typecode)
        {
          case OCI_TYPECODE_VARRAY :                    /* variable array */
          case OCI_TYPECODE_TABLE :                       /* nested table */
          {
/*
            SEXP tmpVec2;
            tmpVec2 = VECTOR_ELT(tmpVec, 0);
*/
            rc = roociWriteCollData(pres, embcol, *(OCIColl **)attr_value,
                                    attr_null_struct, &attr_null_status,
                                    tmpVec, form);
            if (rc != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                      "roociWriteUDTData(OCI_TYPECODE_NAMEDCOLLECTION) - roociWriteCollData");
            break;
          }

          case OCI_TYPECODE_OBJECT:                          /* embedded ADT */
            /* recursive call to dump nested ADT data */
            if (embcol->extyp_roociColType == SQLT_REF)
              rc = roociWriteUDTData(pres, embcol, objtyp,
                                     *(OCIRef **)attr_value, attr_null_struct,
                                     &attr_null_status, tmpVec, form);
            else
              rc = roociWriteUDTData(pres, embcol, objtyp, attr_value,
                                     attr_null_struct, &attr_null_status,
                                     tmpVec, form);
          
            if (rc != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                      "roociWriteUDTData(OCI_TYPECODE_OBJECT) - roociWriteUDTData");
            break;

          case OCI_TYPECODE_REF :                            /* embedded ADT */
            /* pin the object */
            if ((rc = OCIObjectPin(envhp, errhp, *(OCIRef **)attr_value,
                                   (OCIComplexObject *)0, OCI_PIN_ANY,
                                   OCI_DURATION_SESSION, OCI_LOCK_NONE,
                                   &object)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                      "roociWriteUDTData(OCI_TYPECODE_REF) - OCIObjectPin");

            /* allocate the ref */
            if ((rc = OCIObjectNew(envhp, errhp, svchp,
                                   OCI_TYPECODE_REF, (OCIType *)0,
                                   (void *)0, OCI_DURATION_DEFAULT, FALSE,
                                   (void **) &type_ref)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                      "roociWriteUDTData(OCI_TYPECODE_REF) - OCIObjectNew");

            /* get the ref of the type from the object */
            if ((rc = OCIObjectGetTypeRef(envhp, errhp, object, type_ref))
                                                                != OCI_SUCCESS)
            {
              OCIObjectFree(envhp, errhp, type_ref, OCI_OBJECTFREE_FORCE);
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                      "roociWriteUDTData(OCI_TYPECODE_REF) - OCIObjectGetTypeRef");
            }

            /* pin the type ref to get the type object */
            if ((rc = OCIObjectPin(envhp, errhp, type_ref,
                                   (OCIComplexObject *)0,
                                   OCI_PIN_ANY, OCI_DURATION_SESSION,
                                   OCI_LOCK_NONE, (void **) &object_tdo))
                                                                != OCI_SUCCESS)
            {
              OCIObjectFree(envhp, errhp, type_ref, OCI_OBJECTFREE_FORCE);
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                      "roociWriteUDTData(OCI_TYPECODE_REF) - OCIObjectPin2");
            }

            rc = OCIObjectFree(envhp, errhp, type_ref, OCI_OBJECTFREE_FORCE);
            if (rc == OCI_ERROR)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                      "roociWriteUDTData(OCI_TYPECODE_REF) - OCIObjectFree");

            /* get null struct of the object */
            if ((rc = OCIObjectGetInd(envhp, errhp, object,
                                      &null_object)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                      "roociWriteUDTData(OCI_TYPECODE_REF) - OCIObjectGetInd");

            /* call the function recursively to dump the pinned object */
            if ((rc = roociWriteUDTData(pres, embcol, objtyp, object,
                                        null_object, &attr_null_status, tmpVec,
                                        form)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                      "roociWriteUDTData(OCI_TYPECODE_REF) - roociWriteUDTData");
            break;

          default:
            if ((rc = write_attr_val(pres, namep, typecode,
                                     attr_value, &attr_null_status, tmpVec,
                                     embcol, form)) != OCI_SUCCESS)
              ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                                   "roociWriteUDTData - write_attr_val");
            break;
        }
        break;

      default:   /* scaler type, display the attribute value */
        if ((rc = write_attr_val(pres, namep, typecode,
                                 attr_value, &attr_null_status, tmpVec,
                                 embcol, form)) != OCI_SUCCESS)
          ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                      "roociWriteUDTData - write_attr_val2");
        break;
    }

    rc = OCIObjectSetAttr(envhp, errhp, obj, null_obj,
              (struct OCIType *)coltyp->obtyp_roociColType.otyp_roociObjType,
              (const oratext **)&namep,
              (const ub4 *)&(embcol->namsz_roociColType),
              (const ub4)1, (const ub4 *)0,
              (const ub4)0, attr_null_status,
              (const void *)attr_null_struct, (const void *)0);
    if (rc == OCI_ERROR)
      ROOCI_REPORT_WARNING(pcon->ctx_roociCon, pcon,
                           "roociWriteUDTData - OCIObjectSetAttr");
    if (attr_null_status == OCI_IND_NOTNULL)
      all_attributes_null = FALSE;
  }

  if (all_attributes_null)
  {
    OCIInd *nulladt = (OCIInd *)null_obj;
    *nulladt = OCI_IND_NULL;
    if (objind)
      *objind = OCI_IND_NULL;
  }

  return rc;
}

#if defined(OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
/* ----------------------- roociWriteSparseVectorData ------------------------ */
/* Write Sparse Vector data */
static sword roociWriteSparseVectorData(roociRes *pres, roociColType *btyp,
                  OCIVector *vecdp, SEXP lst, ub1 form_of_use, sb2 *pind)
{
  sword          rc = OCI_SUCCESS;
#if OCI_MAJOR_VERSION < 23
  char       warnmsg[UB1MAXVAL];
  roociCtx  *pctx = pres->con_rodbiRes->ctx_rodbiDrv;
  snprintf(warnmsg, UB1MAXVAL - 1,
       "Vector data or type can only be specified with compiled version 23.4 "
       "or higher of Oracle client, current version of client: %d.%d "
       "ROracle compiled using Oracle cleint version %d",
       pctx->ver_roociCtx.maj_roociloadVersion,
       pctx->ver_roociCtx.minor_roociloadVersion,
       pctx->compiled_maj_roociCtx);
  warning((const char *)"%s",warnmsg);
#else
  roociCon      *pcon = pres->con_roociRes;
  OCIError      *errhp = pcon->err_roociCon;
  ub4            dimension;
  SEXP           elem = ((TYPEOF(lst) == VECSXP) ? VECTOR_ELT(lst, 0) : lst);
  SEXP           x = (SEXP)0;
  SEXP           length = (SEXP)0;
  SEXP           i = (SEXP)0; 
  SEXP           class = (SEXP)0;
  ub4           *ptmpind = (ub4 *)0;
  int            lvals;
  double        *ptmpdblvec = (double *)0;
  float         *ptmpfltvec = (float *)0;
  ub1           *ptmpub1vec = (ub1 *)0;
  ub2           *ptmpub2vec = (ub2 *)0;
  ub4            indices = 0;
  int            indx = 0;

  class = Rf_getAttrib(elem, R_ClassSymbol);
  if ((class && (TYPEOF(class) == STRSXP)) &&
      (!strcmp(CHAR(STRING_ELT(class, 0)), "dsparseVector")))
  {
    x = Rf_getAttrib(elem, install("x"));
#ifdef DEBUG
    if (x)
    {
      Rf_PrintValue(x);
      printf("x is not NULL type=%d\n", TYPEOF(x));
    }
    else
      printf("x is NULL type=%d\n", TYPEOF(x));
#endif

    length = Rf_getAttrib(elem, install("length"));
#ifdef DEBUG
    if (length)
      Rf_PrintValue(length);
    else
      printf("length is NULL\n");
#endif

    i = Rf_getAttrib(elem, install("i"));
#ifdef DEBUG
    if (i)
      Rf_PrintValue(i);
    else
      printf("i is NULL\n");
#endif

    if ((isNull(x) || (x == 0)) ||
        (isNull(length) || (length == 0)) ||
        (isNull(i) || (i == 0)))
    {
      *pind = OCI_IND_NULL;
      return (rc);
    }

    if (btyp->vprop_roociColType &
        OCI_ATTR_VECTOR_COL_PROPERTY_IS_SPARSE)
    {
      dimension = INTEGER(length)[0];
      indices = length(i);
      lvals = length(x);
      if (lvals > pres->lvecarr_roociRes)
      {
        if (pres->vecarr_roociRes)
          ROOCI_MEM_FREE(pres->vecarr_roociRes);

        if (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_FLOAT16)
          ROOCI_MEM_ALLOC(pres->vecarr_roociRes, dimension, sizeof(ub2));
        else if (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_FLOAT32)
          ROOCI_MEM_ALLOC(pres->vecarr_roociRes, dimension, sizeof(float));
        else
        if ((btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_INT8) ||
              (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_BINARY))
            ROOCI_MEM_ALLOC(pres->vecarr_roociRes, dimension, sizeof(ub1));
        else
        /*
        **  ((btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_FLOAT64) ||
        **   (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_FLEX))
        */
          {
            ROOCI_MEM_ALLOC(pres->vecarr_roociRes, dimension, sizeof(double));
            btyp->vfmt_roociColType = OCI_ATTR_VECTOR_FORMAT_FLOAT64;
          }

        pres->lvecarr_roociRes = dimension;
      }

      if (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_FLOAT16)
      {
        ptmpub2vec = (ub2 *)pres->vecarr_roociRes;

        for (indx = 0; indx < indices; indx++)
        {
          *ptmpub2vec++ = (ub2)((TYPEOF(x) == REALSXP) ? REAL(x)[indx] :
                                                         INTEGER(x)[indx]);
#ifdef DEBUG
          printf("REAL(x)[%d]=%f\n", indx, REAL(x)[indx]);
#endif
        }
      }
      else if (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_FLOAT32)
      {
        ptmpfltvec = (float *)pres->vecarr_roociRes;

        for (indx = 0; indx < indices; indx++)
        {
          *ptmpfltvec++ = (float)((TYPEOF(x) == REALSXP) ? REAL(x)[indx] :
                                                           INTEGER(x)[indx]);
#ifdef DEBUG
          printf("REAL(x)[%d]=%f\n", indx, REAL(x)[indx]);
#endif
        }
      }
      else
        if ((btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_INT8) ||
            (btyp->vfmt_roociColType == OCI_ATTR_VECTOR_FORMAT_BINARY))
      {
        ptmpub1vec = (ub1 *)pres->vecarr_roociRes;

        for (indx = 0; indx < indices; indx++)
        {
          *ptmpub1vec++ = (ub1)((TYPEOF(x) == REALSXP) ? REAL(x)[indx] :
                                                         INTEGER(x)[indx]);
#ifdef DEBUG
          printf("REAL(x)[%d]=%f\n", indx, REAL(x)[indx]);
#endif
        }
      }
      else
      {
        ptmpdblvec = (double *)pres->vecarr_roociRes;

        for (indx = 0; indx < indices; indx++)
        {
          *ptmpdblvec++ = (double)((TYPEOF(x) == REALSXP) ? REAL(x)[indx] :
                                                            INTEGER(x)[indx]);
#ifdef DEBUG
          printf("REAL(x)[%d]=%f\n", indx, REAL(x)[indx]);
#endif
        }
      }

      if (indices > pres->lindarr_roociRes)
      {
        if (pres->indarr_roociRes)
          ROOCI_MEM_FREE(pres->indarr_roociRes);

        ROOCI_MEM_ALLOC(pres->indarr_roociRes, dimension, sizeof(ub4));
        pres->lindarr_roociRes = indices;
      }
      ptmpind = (ub4 *)pres->indarr_roociRes;

      for (indx = 0; indx < indices; indx++)
      {
        *ptmpind++ = (INTEGER(i)[indx] - 1);
#ifdef DEBUG
        printf("INTEGER(i)[%d]=%d\n", indx, INTEGER(i)[indx]);
#endif
      }

      rc = OCIVectorFromSparseArray(vecdp, errhp,
                                    btyp->vfmt_roociColType,
                                    dimension, indices, pres->indarr_roociRes,
                                    pres->vecarr_roociRes, OCI_DEFAULT);
    }
  }
  else
  {
    roociCtx *pctx = pcon->ctx_roociCon;
#define RODBI_ERR_SPARSE_VECTOR_USAGE                                         \
      _("Sparse vector data type cannot be used with ROracle package that was"\
        " built with higher version(%d.%d) of Oracle client. Oracle Client "  \
        "version installed is %d.%d, please use Oracle Client 23.7 or higher.")

    Rf_error(RODBI_ERR_SPARSE_VECTOR_USAGE,
             pctx->compiled_maj_roociCtx,
             pctx->compiled_min_roociCtx,
             pctx->ver_roociCtx.maj_roociloadVersion,
             pctx->ver_roociCtx.minor_roociloadVersion);

    *pind = OCI_IND_NULL;
  }
  return rc;
#endif
}
#endif
/* end of file rooci.c */
