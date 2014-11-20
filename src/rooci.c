/* Copyright (c) 2011, 2014, Oracle and/or its affiliates. 
All rights reserved.*/

/*
   NAME
     rooci.c 

   DESCRIPTION
     OCI calls used in implementing DBI driver for R.

   NOTES

   MODIFIED   (MM/DD/YY)
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

  if (pthrctx->rc_roociThrCtx == OCI_ERROR)
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
                        __FUNCTION__, 1))
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
                         __FUNCTION__, 1))
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

sword roociInitializeCtx (roociCtx *pctx, void *epx, boolean interrupt_srv)
{
  sword    rc = OCI_ERROR;

  /* create OCI environment */
  if (epx)
  {
    rc = OCIExtProcGetEnv(epx, &pctx->env_roociCtx, &pctx->svc_roociCtx,
                          &pctx->err_roociCtx);
    pctx->extproc_roociCtx = TRUE;
  }
  else
    rc = OCIEnvCreate(&pctx->env_roociCtx, OCI_DEFAULT | OCI_OBJECT, NULL, 
                      NULL, NULL, NULL, (size_t)0, (void **)NULL);
  if (rc == OCI_SUCCESS)
  {  
    /* get OCI client version */
    OCIClientVersion(&pctx->maj_roociCtx, &pctx->minor_roociCtx,
                     &pctx->update_roociCtx, &pctx->patch_roociCtx,
                     &pctx->port_roociCtx);
    
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
  char      srvVersion [ROOCI_VERSION_LEN] = "";
  void     *temp                           = NULL;
                              /* pointer to remove strict-aliasing warnings */

  /* update driver reference in connection context */
  pcon->ctx_roociCon = pctx;

  /* get connection ID */
  rc = roociNewConID(pctx);
  if (rc == ROOCI_DRV_ERR_MEM_FAIL)
    return ROOCI_DRV_ERR_MEM_FAIL;
  else
    pcon->conID_roociCon = rc;

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

sword roociGetError(roociCtx *pctx, roociCon *pcon, sb4 *errNum, text *errMsg)
{
  sword rc = OCI_ERROR;  

  /* if error handle defined */
  if (pcon && pcon->err_roociCon)
  {
    rc =  OCIErrorGet(pcon->err_roociCon, 1, (text *)NULL, errNum, 
                      errMsg, ROOCI_ERR_LEN, (ub4)OCI_HTYPE_ERROR);
  } 
  else if (pctx && pctx->env_roociCtx)      /* if environment handle defined */
  {
    rc =  OCIErrorGet(pctx->env_roociCtx, 1, (text *)NULL, errNum, 
                      errMsg, ROOCI_ERR_LEN, (ub4)OCI_HTYPE_ENV);
  }

  if (*errNum == 1403 || rc == OCI_NO_DATA)                /* no data found */ 
  {
    *errNum = 0;
    strcpy((char *)errMsg,"");
    rc      = 0;
  }
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
    ub2     envcsid;
    ub2     cnvcid        = 0;

    rc = OCIAttrGet(pcon->ctx_roociCon->env_roociCtx, OCI_HTYPE_ENV, 
                    (void *)&envcsid, NULL,
                    OCI_ATTR_ENV_CHARSET_ID, pcon->err_roociCon);
    if (rc == OCI_ERROR)
      return rc;

    if (qry_encoding == ROOCI_QRY_UTF8)
      cnvcid = OCINlsCharSetNameToId(pcon->ctx_roociCon->env_roociCtx,
                                     (const oratext *)"AL32UTF8");
     else if (qry_encoding == ROOCI_QRY_LATIN1)
      cnvcid = OCINlsCharSetNameToId(pcon->ctx_roociCon->env_roociCtx,
                                     (const oratext *)"WE8ISO8859P1");

    if (envcsid != cnvcid)
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
  if (pcon->auth_roociCon)
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

sword roociBindData(roociRes *pres, ub4 bufPos, ub1 form_of_use)
{
  OCIBind   *bndp;
  sword      rc;
  roociCon  *pcon = pres->con_roociRes;

  /* bind data */
  rc = OCIBindByPos(pres->stm_roociRes, &bndp, pcon->err_roociCon, bufPos,
                    (void *)pres->bdat_roociRes[bufPos-1],
                    pres->bsiz_roociRes[bufPos-1],
                    pres->btyp_roociRes[bufPos-1],
                    pres->bind_roociRes[bufPos-1],
                    ((pres->btyp_roociRes[bufPos-1] == SQLT_LVC) ||
                     (pres->btyp_roociRes[bufPos-1] == SQLT_LVB))
                                               ? 0 :
                                                 pres->alen_roociRes[bufPos-1],
                    NULL, (ub4)0, NULL, OCI_DEFAULT);
  if (rc == OCI_ERROR)
    return rc;

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
  size_t          nrows;
  void          **tsdt;
  roociCon       *pcon              = pres->con_roociRes;
  roociCtx       *pctx              = pcon->ctx_roociCon;
  int             fcur              = 0;
  ub1            *dat               = NULL; 

  /* get number of columns */
  rc = OCIAttrGet(pres->stm_roociRes, OCI_HTYPE_STMT, &pres->ncol_roociRes, 
                  NULL, OCI_ATTR_PARAM_COUNT, pcon->err_roociCon);
  if (rc == OCI_ERROR)
    return rc;

  /* allocate column vectors */
  ROOCI_MEM_ALLOC(pres->typ_roociRes, pres->ncol_roociRes, sizeof(ub1));
  ROOCI_MEM_ALLOC(pres->form_roociRes, pres->ncol_roociRes, sizeof(ub1));
  ROOCI_MEM_ALLOC(pres->dat_roociRes, pres->ncol_roociRes, sizeof(void *));
  ROOCI_MEM_ALLOC(pres->ind_roociRes, pres->ncol_roociRes, sizeof(sb2 *));
  ROOCI_MEM_ALLOC(pres->len_roociRes, pres->ncol_roociRes, sizeof(ub2 *));
  ROOCI_MEM_ALLOC(pres->siz_roociRes, pres->ncol_roociRes, sizeof(sb4));

  if (!pres->typ_roociRes || !pres->form_roociRes || !pres->dat_roociRes ||
      !pres->ind_roociRes || !pres->len_roociRes || !pres->siz_roociRes)
    return ROOCI_DRV_ERR_MEM_FAIL;

  /* describe columns */
  for (cid = 0; cid < pres->ncol_roociRes; cid++)
  {
    /* get column parameters */
    rc = roociDescCol(pres, (ub4)(cid + 1), &etyp, NULL, NULL, NULL, 
                      NULL, NULL, NULL, &pres->form_roociRes[cid]);
    if (rc == OCI_ERROR)
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
        (etyp == SQLT_BFILE))
    {
      dat = (ub1 *)pres->dat_roociRes[cid];
      pres->nocache_roociRes = TRUE;

      for (fcur = 0; fcur < nrows; fcur++)
      {
        lob = (OCILobLocator **)(dat + fcur * (pres->siz_roociRes[cid]));
        rc  = OCIDescriptorAlloc(pctx->env_roociCtx, (void **)lob,
                                 (etyp == SQLT_BFILE) ? OCI_DTYPE_FILE :
                                                          OCI_DTYPE_LOB,
                                 0, NULL);
        if (rc == OCI_ERROR)
          return rc;
      }
    }

    /* allocate OCIDateTime locators */
    if ((etyp == SQLT_TIMESTAMP_LTZ) ||
        (etyp == SQLT_TIMESTAMP)    ||
        (etyp == SQLT_INTERVAL_DS))
    {
      dat = (ub1 *)pres->dat_roociRes[cid];

      for (fcur = 0; fcur < nrows; fcur++)
      {
        tsdt = (void **)(dat + fcur * (pres->siz_roociRes[cid]));
        if (pcon->timesten_rociCon)
        {
          /* TimesTen does not support SQLT_TIMESTAMP_TZ, use SQLT_TIMESTAMP */
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
    }

    /* define fetch buffers */
    rc = OCIDefineByPos(pres->stm_roociRes, &defp, pcon->err_roociCon,
                        (ub4)(cid + 1), (pres->dat_roociRes[cid]),
                        pres->siz_roociRes[cid], etyp, 
                        pres->ind_roociRes[cid], pres->len_roociRes[cid], 
                        NULL, OCI_DEFAULT);
    if (rc == OCI_ERROR)
      return rc;

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
                   ub4 *colNameLen, ub4 *maxColDataSizeInByte, 
                   sb2 *colpre, sb1 *colsca, ub1 *nul, ub1 *form)
{
  sword       rc        = OCI_ERROR;
  OCIParam   *colhd     = NULL;                            /* column handle */
  ub2         colTyp    = 0;                                 /* column type */
  ub2         collen    = 0;                               /* column length */
  sb4         coldisplen= 0;                       /* column display length */
  sb2         precision = 0;                         /* precision of column */
  sb1         scale     = 0;                             /* scale of column */
  ub2         size      = 0;                     /* size in bytes of column */
  roociCon   *pcon      = pres->con_roociRes;
  void       *temp      = NULL;/* pointer to remove strict-aliasing warning */

  /* get column parameters */
  rc = OCIParamGet(pres->stm_roociRes, OCI_HTYPE_STMT, pcon->err_roociCon, 
                   (void **)&temp, colId);
  if (rc == OCI_ERROR)
      return rc;
  colhd = temp;

  /* get column type */
  rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, &colTyp, NULL,
                  OCI_ATTR_DATA_TYPE, pcon->err_roociCon);
  if (rc == OCI_ERROR)
  {
    OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);    
    return rc;
  }

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
  if (maxColDataSizeInByte || pcon->timesten_rociCon)
  {
    rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, &size,
                    NULL, OCI_ATTR_DATA_SIZE, pcon->err_roociCon);
    if (rc == OCI_ERROR)
    {
      OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);
      return rc;
    }

    if (maxColDataSizeInByte)
      *maxColDataSizeInByte = size;
  }

  /* get precision */
  rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, &precision,
                  NULL, OCI_ATTR_PRECISION, pcon->err_roociCon);
  if (rc == OCI_ERROR)
  {
    OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);    
    return rc;
  }

  if (colpre)
  {
    *colpre = precision;
  }

  /* get scale */
  rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, &scale,
                  NULL, OCI_ATTR_SCALE, pcon->err_roociCon);
  if (rc == OCI_ERROR)
  {
    OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);    
    return rc;
  }

  if (colsca)
  {
    *colsca = scale;
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
  if (form)
  {
    rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, (void *)form,
                    NULL, OCI_ATTR_CHARSET_FORM, pcon->err_roociCon);
    if (rc == OCI_ERROR)
    {
      OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);
      return rc;
    }
  }

  if (pres->typ_roociRes)
  {
    /* get internal data type */
    pres->typ_roociRes[colId-1] = rodbiTypeInt(colTyp, precision, scale, size,
                                               pcon->timesten_rociCon);
  }

  if (pres->typ_roociRes && extTyp && pres->siz_roociRes)
  {
    /* get external type */
    *extTyp = rodbiTypeExt(pres->typ_roociRes[colId-1]);

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

      case SQLT_BIN:
        rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, &collen, NULL,
                        OCI_ATTR_DATA_SIZE, pcon->err_roociCon);
        if(rc == OCI_ERROR)
        {
          OCIDescriptorFree(colhd, OCI_DTYPE_PARAM);
          return rc;
        }

        /* adjust for NULL terminator & account for NLS expansion */
        pres->siz_roociRes[colId-1] = (size_t)((collen + 1));
        break;

      default:
        rc = OCIAttrGet(colhd, OCI_DTYPE_PARAM, &coldisplen, NULL,
                        OCI_ATTR_DISP_SIZE, pcon->err_roociCon);
        if(rc == OCI_ERROR)
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

/* -------------------------- roociGetColProperties ----------------------- */

sword roociGetColProperties(roociRes *pres, ub4 colId, ub4 *len, oratext **buf)
{
  OCIParam   *par;
  sword       rc    = OCI_ERROR;
  roociCon   *pcon  = pres->con_roociRes;
  void       *temp  = NULL;    /* pointer to remove strict-aliasing warning */
   
  /* get column parameters */
  rc = OCIParamGet(pres->stm_roociRes, OCI_HTYPE_STMT, 
                   pcon->err_roociCon, (void **)&temp, colId);
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
  rc = OCIStmtFetch2(pres->stm_roociRes, pcon->err_roociCon, 
                     pres->prefetch_roociRes ? 1 : pres->nrows_roociRes,
                     OCI_FETCH_NEXT, 0, OCI_DEFAULT);

  if (rc == OCI_NO_DATA)                                   /* done fetching */
    *end_of_fetch = TRUE;
  else
    *end_of_fetch = FALSE;
       
  if (rc == OCI_ERROR)
    return rc;
    
  /* get no of rows fetched */
  rc = OCIAttrGet(pres->stm_roociRes, OCI_HTYPE_STMT, rows_fetched,
                  NULL, OCI_ATTR_ROWS_FETCHED, pcon->err_roociCon);
    
  return rc;
} /* end of roociFetchData */

/* --------------------------- roociReadLOBData --------------------------- */

sword roociReadLOBData(roociRes *pres, int *lob_len, int rowpos, int cid)
{
  sword            rc   = OCI_ERROR;
  oraub8           len;
  oraub8           char_len;
  OCILobLocator   *lob_loc;
  roociCon        *pcon = pres->con_roociRes;

  lob_loc = *(OCILobLocator **)((ub1 *)pres->dat_roociRes[cid] +
                                (rowpos * pres->siz_roociRes[cid]));

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

  if (!pres->lobbuf_roociRes || pres->loblen_roociRes < (size_t)len)
  {
    if (pres->lobbuf_roociRes)
      ROOCI_MEM_FREE(pres->lobbuf_roociRes);

    pres->loblen_roociRes = (size_t)(len / ROOCI_LOB_RND + 1);
    pres->loblen_roociRes = (size_t)(pres->loblen_roociRes * ROOCI_LOB_RND);
    ROOCI_MEM_ALLOC(pres->lobbuf_roociRes, pres->loblen_roociRes, 
                    sizeof(ub1));
    if (!pres->lobbuf_roociRes)
      return ROOCI_DRV_ERR_MEM_FAIL;
  }

  /* read LOB data */
  rc = OCILobRead2(pcon->svc_roociCon, pcon->err_roociCon, lob_loc, 
                   &len, &char_len, 1, pres->lobbuf_roociRes, len,
                   OCI_ONE_PIECE, NULL, (OCICallbackLobRead2)0, 0,
                   pres->form_roociRes[cid]);
  if (rc == OCI_ERROR)
    return rc;

  *lob_len = (int)len;
  return rc;
} /* end of roociReadLOBData */

/* -------------------------- roociReadBLOBData --------------------------- */

sword roociReadBLOBData(roociRes *pres, int *lob_len, int rowpos, int cid)
{
  sword            rc   = OCI_ERROR;
  oraub8           len;
  oraub8           char_len;
  OCILobLocator   *lob_loc;
  roociCon        *pcon = pres->con_roociRes;
  ub2              exttye = rodbiTypeExt(pres->typ_roociRes[cid]);

  lob_loc = *(OCILobLocator **)((ub1 *)pres->dat_roociRes[cid] +
                                (rowpos * pres->siz_roociRes[cid]));

  if (exttye == SQLT_BFILE)
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

  if (!pres->lobbuf_roociRes || pres->loblen_roociRes < (size_t)len)
  {
    if (pres->lobbuf_roociRes)
      ROOCI_MEM_FREE(pres->lobbuf_roociRes);

    pres->loblen_roociRes = (size_t)(len / ROOCI_LOB_RND + 1);
    pres->loblen_roociRes = (size_t)(pres->loblen_roociRes * ROOCI_LOB_RND);
    ROOCI_MEM_ALLOC(pres->lobbuf_roociRes, pres->loblen_roociRes, 
                    sizeof(ub1));
    if (!pres->lobbuf_roociRes)
      return ROOCI_DRV_ERR_MEM_FAIL;
  }

  /* read LOB data */
  rc = OCILobRead2(pcon->svc_roociCon, pcon->err_roociCon, lob_loc, 
                   &len, &char_len, 1, pres->lobbuf_roociRes, len,
                   OCI_ONE_PIECE, NULL, (OCICallbackLobRead2)0, 0,
                   pres->form_roociRes[cid]);
  if (rc == OCI_ERROR)
    return rc;

  *lob_len = (int)len;

  if (exttye == SQLT_BFILE)
  {
    rc = OCILobFileClose(pcon->svc_roociCon, pcon->err_roociCon, lob_loc);
    if (rc == OCI_ERROR)
      return rc;
  }

  return rc;
} /* end of roociReadBLOBData */

/* ------------------------- roociReadDateTimeData ------------------------ */

sword roociReadDateTimeData(roociRes *pres, OCIDateTime *tstm,
                            char *date_time, ub4 *date_time_len,
                            boolean isDate)
{
  return (OCIDateTimeToText(pres->con_roociRes->usr_roociCon,
                            pres->con_roociRes->err_roociCon,
                            (const OCIDateTime *)tstm,
                            (OraText*)"YYYY-MM-DD HH24:MI:SSXFF",
                            24, (ub1)(isDate ? 0 : 9), (OraText*)0, 0,
                            date_time_len, (OraText *)date_time));
} /* end of roociReadDateTimeData */

/* ------------------------- roociWriteDateTimeData ------------------------ */

sword roociWriteDateTimeData(roociRes *pres, OCIDateTime *tstm,
                             const char *date_time, size_t date_time_len)
{
  return (OCIDateTimeFromText(pres->con_roociRes->usr_roociCon,
                   pres->con_roociRes->err_roociCon,
                   (const OraText *)date_time, date_time_len,
                   (const OraText *)"YYYY-MM-DD HH24:MI:SSXFF", 24,
                   (OraText *)0, 0, tstm));
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

/* ------------------------- roociWriteDiffTimeData ------------------------ */

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
  ub1          *dat   = NULL;
  int           fcur  = 0;
  size_t        nrows = 0;

  nrows = pres->prefetch_roociRes ? 1 : pres->nrows_roociRes;

  /* free bind data buffers */
  if (pres->bdat_roociRes)
  {
    for (bid = 0; bid < pres->bcnt_roociRes; bid++)
      if (pres->bdat_roociRes[bid])
      {    
        if ((pres->btyp_roociRes[bid] == SQLT_TIMESTAMP_TZ) ||
            (pres->btyp_roociRes[bid] == SQLT_INTERVAL_DS))
        {
          dat = (ub1 *)pres->bdat_roociRes[bid];
          for (fcur = 0; fcur < pres->bmax_roociRes; fcur++)
          {
            void *tsdt = *(void **)(dat + fcur * (pres->bsiz_roociRes[bid]));
            if (tsdt)
            {
              rc = OCIDescriptorFree(tsdt,
                             (pres->btyp_roociRes[bid] == SQLT_TIMESTAMP_TZ) ?
                                     OCI_DTYPE_TIMESTAMP_TZ :
                                     OCI_DTYPE_INTERVAL_DS);
              if (rc != OCI_SUCCESS)
                return rc;
            }
          }
        }
        ROOCI_MEM_FREE(pres->bdat_roociRes[bid]);
      }

    ROOCI_MEM_FREE(pres->bdat_roociRes);
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
    ROOCI_MEM_FREE(pres->btyp_roociRes);
  }

  /* free data buffers */
  if (pres->dat_roociRes)
  {
    for (cid = 0; cid < pres->ncol_roociRes; cid++)
      if (pres->dat_roociRes[cid])
      {
        exttype = rodbiTypeExt(pres->typ_roociRes[cid]);
        /* free lob data */
        if ((exttype == SQLT_CLOB) ||
            (exttype == SQLT_BLOB) ||
            (exttype == SQLT_BFILE))
        {
          dat = (ub1 *)pres->dat_roociRes[cid];

          for (fcur = 0; fcur < nrows; fcur++)
          {
            OCILobLocator *lob = *(OCILobLocator **)(dat + fcur * 
                                                   (pres->siz_roociRes[cid]));
            if (lob)
            {
              rc = OCIDescriptorFree(lob, (exttype == SQLT_BFILE) ?
                                                               OCI_DTYPE_FILE :
                                                               OCI_DTYPE_LOB);
              if (rc != OCI_SUCCESS)
                return rc;
            }
          }
        }

        /* free OCIDateTime and OCIInterval data */
        if ((exttype == SQLT_TIMESTAMP_LTZ) ||
            (exttype == SQLT_TIMESTAMP)    ||
            (exttype == SQLT_INTERVAL_DS))
        {
          dat = (ub1 *)pres->dat_roociRes[cid];

          for (fcur = 0; fcur < nrows; fcur++)
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
        }

        ROOCI_MEM_FREE(pres->dat_roociRes[cid]);
      }

    ROOCI_MEM_FREE(pres->dat_roociRes);
  }

  /* free types */
  if (pres->typ_roociRes)
  {
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

  /* free column types */
  if (pres->typ_roociRes)
  {
    ROOCI_MEM_FREE(pres->typ_roociRes);
  }

  /* free temp LOB buffer */
  if (pres->lobbuf_roociRes)
  {
    ROOCI_MEM_FREE(pres->lobbuf_roociRes);
  }

  /* release the statement */
  if (pres->stm_roociRes)
  {
    rc = OCIStmtRelease(pres->stm_roociRes, pcon->err_roociCon, 
                        (OraText *)NULL, 0, OCI_DEFAULT);
    pres->stm_roociRes = NULL;

    if (rc != OCI_SUCCESS)
      return rc;
  }

  /* free ro result */
  if (pcon)
    pcon->res_roociCon[pres->resID_roociRes] = NULL;

  return rc;
} /* end roociResFree */


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

/* ---------------------------- roociAllocDescBindBuf ---------------------- */

sword roociAllocDescBindBuf(roociRes *pres, void **buf, int bid, ub4 desc_type)
{
  ub1          *dat   = NULL;
  int           fcur  = 0;
  void        **tsdt;
  sword         rc    = OCI_SUCCESS;

  dat = (ub1 *)buf;
  for (fcur = 0; fcur < pres->bmax_roociRes; fcur++)
  {
    tsdt = (void **)(dat + fcur * (pres->bsiz_roociRes[bid]));
    rc = OCIDescriptorAlloc(pres->con_roociRes->ctx_roociCon->env_roociCtx,
                            tsdt, desc_type, 0, NULL);
    if (rc == OCI_ERROR)
      return rc;
  }
  return rc;
} /* end roociAllocDescBindBuf */

/* end of file rooci.c */
