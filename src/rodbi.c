/* Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
All rights reserved. */

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
         rodbiResBindCopy
         rodbiResAlloc
         rodbiResExpand
         rodbiResSplit
         rodbiResAccum
         rodbiResTrim
         rodbiResDataFrame
         rodbiResStateNext
         rodbiResInfoStmt
         rodbiResInfoFields

     (*) ERROR CHECK FUNCTIONS
         rodbiCheck

   NOTES

   MODIFIED   (MM/DD/YY)
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
#define RODBI_ERR_MEMORY_ALC       _("memory could not be allocated")
#define RODBI_ERR_MANY_ROWS        _("bind data has too many rows")
#define RODBI_ERR_BIND_MISMATCH    _("bind data does not match bind specification")
#define RODBI_ERR_BIND_EMPTY       _("bind data is empty")
#define RODBI_ERR_UNSUPP_BIND_TYPE _("unsupported bind type")
#define RODBI_ERR_UNSUPP_COL_TYPE  _("unsupported column type")
#define RODBI_ERR_INTERNAL         _("ROracle internal error [%s, %d, %d]")
#define RODBI_ERR_BIND_VAL_TOOBIG  _("bind data is too big")
#define RODBI_ERR_UNSUPP_BIND_ENC  _("bind data can only be in native or utf-8 encoding")
#define RODBI_ERR_UNSUPP_SQL_ENC   _("sql text can only be in native or utf-8 encoding")
#define RODBI_ERR_PREF_STMT_CACHE  _("prefetch should be enabled for statement cache")

#define RODBI_DRV_ERR_CHECKWD     -1                      /* Invalid object */
#define RODBI_BULK_READ           25               /* rodbi BULK READ count */ 
#define RODBI_BULK_WRITE         100              /* rodbi BULK WRITE count */


/* RODBI FATAL error */
#define RODBI_FATAL(fun, pos, info) \
        error(RODBI_ERR_INTERNAL, (fun), (pos), (info))

/* RODBI ERROR */
#define RODBI_ERROR(err) \
        error(err)

/* RODBI WARNING */
#define RODBI_WARNING(war) \
        warning(war)

#ifdef DEBUG_ro
# define RODBI_TRACE(txt)  Rprintf("ROracle: %s\n", (txt))
#else
# define RODBI_TRACE(txt)
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

/*----------------------------------------------------------------------------
                          PRIVATE TYPES AND CONSTANTS
 ---------------------------------------------------------------------------*/

/* RODBI DRiVer version */
#define RODBI_DRV_NAME       "Oracle (OCI)"
#define RODBI_DRV_MAJOR       1
#define RODBI_DRV_MINOR       1
#define RODBI_DRV_UPDATE      5

/* RODBI R classes */
#define RODBI_R_LOG           1                                  /* LOGICAL */
#define RODBI_R_INT           2                                  /* INTEGER */
#define RODBI_R_NUM           3                                  /* NUMERIC */
#define RODBI_R_CHR           4                                /* CHARACTER */
#define RODBI_R_LST           5                                     /* LIST */
#define RODBI_R_DAT           6                                  /* POSIXct */
#define RODBI_R_RAW           7                                      /* RAW */

/* RODBI R classes NaMes */
#define RODBI_R_LOG_NM       "logical"
#define RODBI_R_INT_NM       "integer"
#define RODBI_R_NUM_NM       "numeric"
#define RODBI_R_CHR_NM       "character"
#define RODBI_R_LST_NM       "list"
#define RODBI_R_DAT_NM       "POSIXct"
#define RODBI_R_RAW_NM       "raw"
  
/* rodbi internal Oracle types */
/* These values are used as index to rodbiIType[] table */
#define RODBI_VARCHAR2        1                            /* VARCHAR2 TYPE */ 
#define RODBI_NUMBER          2                              /* NUMBER TYPE */
#define RODBI_INTEGER         3                             /* INTEGER TYPE */
#define RODBI_LONG            4                                /* LONG TYPE */
#define RODBI_DATE            5                                /* DATE TYPE */
#define RODBI_RAW             6                                 /* RAW TYPE */
#define RODBI_LONG_RAW        7                            /* LONG_RAW TYPE */
#define RODBI_ROWID           8                               /* ROWID TYPE */
#define RODBI_CHAR            9                           /* CHARACTER TYPE */
#define RODBI_BFLOAT         10                             /* BINARY_FLOAT */
#define RODBI_BDOUBLE        11                            /* BINARY_DOUBLE */
#define RODBI_UDT            12                        /* USER-DEFINED TYPE */
#define RODBI_REF            13                           /* REFERENCE TYPE */
#define RODBI_CLOB           14                       /* CHARACTER LOB TYPE */
#define RODBI_BLOB           15                          /* BINARY LOB TYPE */
#define RODBI_BFILE          16                         /* BINARY FILE TYPE */
#define RODBI_TIME           17                                /* TIMESTAMP */
#define RODBI_TIME_TZ        18                 /* TIMESTAMP WITH TIME ZONE */
#define RODBI_INTER_YM       19                   /* INTERVAL YEAR TO MONTH */
#define RODBI_INTER_DS       20                   /* INTERVAL DAY TO SECOND */
#define RODBI_TIME_LTZ       21           /* TIMESTAMP WITH LOCAL TIME ZONE */


/* RODBI internal Oracle types NaMes */
#define RODBI_VARCHAR2_NM    "VARCHAR2"
#define RODBI_NUMBER_NM      "NUMBER"
#define RODBI_INTEGER_NM     "NUMBER"
#define RODBI_LONG_NM        "LONG"
#define RODBI_DATE_NM        "DATE"
#define RODBI_RAW_NM         "RAW"
#define RODBI_LONG_RAW_NM    "LONG RAW"
#define RODBI_ROWID_NM       "ROWID"
#define RODBI_CHAR_NM        "CHAR"
#define RODBI_BFLOAT_NM      "BINARY_FLOAT"
#define RODBI_BDOUBLE_NM     "BINARY_DOUBLE"
#define RODBI_UDT_NM         "USER-DEFINED TYPE"
#define RODBI_REF_NM         "REF"
#define RODBI_CLOB_NM        "CLOB"
#define RODBI_BLOB_NM        "BLOB"
#define RODBI_BFILE_NM       "BFILE"
#define RODBI_TIME_NM        "TIMESTAMP"
#define RODBI_TIME_TZ_NM     "TIMESTAMP WITH TIME ZONE"
#define RODBI_INTER_YM_NM    "INTERVAL YEAR TO MONTH"
#define RODBI_INTER_DS_NM    "INTERVAL DAY TO SECOND"
#define RODBI_TIME_LTZ_NM    "TIMESTAMP WITH LOCAL TIME ZONE"

#define RODBI_CHECKWD        0xf8e9dacb          /* magic no. for checkword */


/* forward declarations */
struct rodbiCon;
struct rodbiRes;

/* RODBI fetch STATEs */
enum rodbiState
{
  FETCH_rodbiState,                                 /* pre-FETCH query data */
  SPLIT_rodbiState,                               /* SPLIT pre-fetch buffer */
  ACCUM_rodbiState,        /* ACCUMulate pre-fetched data into a data frame */
  OUTPUT_rodbiState,                                 /* OUTPUT a data frame */
  CLOSE_rodbiState                                    /* CLOSE the satement */
};
typedef enum rodbiState rodbiState;

/* RODBI DRiVer */
struct rodbiDrv
{
  ub4        magicWord_rodbiDrv;  /* Magic word to check structure validity */
  roociCtx   ctx_rodbiDrv;                                   /* OCI context */
  boolean    interrupt_rodbiDrv;   /* Use ^C handler for long running query */
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
  int        rows_rodbiRes;           /* current number of ROWS in the list */
  int        nrow_rodbiRes;         /* allocated Number of ROWs in the list */
  int        fchNum_rodbiRes;                 /* NUMber of pre-FetCHed rows */
  int        fchBeg_rodbiRes;          /* pre-FetCH buffer BEGinning offset */
  int        fchEnd_rodbiRes;             /* pre-FetCH buffer ENDing offset */
  boolean    done_rodbiRes;                                /* DONE fetching */
  boolean    expand_rodbiRes;                /* adaptively EXPAND data list */
  int        affrows_rodbiRes;           /* No of rows affected; [13843811] */
  SEXP       name_rodbiRes;                          /* column NAMEs vector */
  SEXP       list_rodbiRes;                                    /* data LIST */
  rodbiState state_rodbiRes;                      /* query processing STATE */
};
typedef struct rodbiRes rodbiRes;


/* RODBI internal TYPe */
struct rodbiITyp
{
  char      *name_rodbiITyp;                                   /* type NAME */
  ub1        rtyp_rodbiITyp;                                      /* R TYPe */
  ub2        etyp_rodbiITyp;                               /* External TYPe */
  size_t     size_rodbiITyp;                                 /* buffer SIZE */
};
typedef struct rodbiITyp rodbiITyp;

/* rodbi Internal TYPe TABle */
const rodbiITyp rodbiITypTab[] =
{
  {"",                0,           0,                 0},
  {RODBI_VARCHAR2_NM, RODBI_R_CHR, SQLT_STR,          0}, 
  {RODBI_NUMBER_NM,   RODBI_R_NUM, SQLT_BDOUBLE,      sizeof(double)},
  {RODBI_INTEGER_NM,  RODBI_R_INT, SQLT_INT,          sizeof(int)},
  {RODBI_LONG_NM,     0,           0,                 0},
  {RODBI_DATE_NM,     RODBI_R_DAT, SQLT_TIMESTAMP_TZ, sizeof(OCIDateTime *)}, 
  {RODBI_RAW_NM,      RODBI_R_RAW, SQLT_BIN,          0}, 
  {RODBI_LONG_RAW_NM, 0,           0,                 0},
  {RODBI_ROWID_NM,    RODBI_R_CHR, SQLT_STR,          0}, 
  {RODBI_CHAR_NM,     RODBI_R_CHR, SQLT_STR,          0}, 
  {RODBI_BFLOAT_NM,   RODBI_R_NUM, SQLT_BDOUBLE,      sizeof(double)},
  {RODBI_BDOUBLE_NM,  RODBI_R_NUM, SQLT_BDOUBLE,      sizeof(double)},
  {RODBI_UDT_NM,      0,           0,                 0},
  {RODBI_REF_NM,      0,           0,                 0},
  {RODBI_CLOB_NM,     RODBI_R_CHR, SQLT_CLOB,         sizeof(OCILobLocator *)},
  {RODBI_BLOB_NM,     RODBI_R_RAW, SQLT_BLOB,         sizeof(OCILobLocator *)},
  {RODBI_BFILE_NM,    RODBI_R_RAW, SQLT_BFILE,        sizeof(OCILobLocator *)},
  {RODBI_TIME_NM,     RODBI_R_DAT, SQLT_TIMESTAMP_TZ, sizeof(OCIDateTime *)}, 
  {RODBI_TIME_TZ_NM,  RODBI_R_DAT, SQLT_TIMESTAMP_TZ, sizeof(OCIDateTime *)}, 
  {RODBI_INTER_YM_NM, RODBI_R_CHR, SQLT_STR,          0},
  {RODBI_INTER_DS_NM, RODBI_R_CHR, SQLT_STR,          0},
  {RODBI_TIME_LTZ_NM, RODBI_R_DAT, SQLT_TIMESTAMP_TZ, sizeof(OCIDateTime *)}
};

/* RODBI CHECK error using DRiVer handle */
#define RODBI_CHECK_DRV(drv, fun, pos, free_drv, function_to_invoke)   \
do                                                                     \
{                                                                      \
  sword  rc;                                                           \
  if ((rc = (function_to_invoke)) != OCI_SUCCESS)                      \
  {                                                                    \
    text   errMsg[ROOCI_ERR_LEN];                                      \
    rodbiCheck((drv), NULL, (fun), (pos), rc, errMsg,                  \
               sizeof(errMsg));                                        \
    if (free_drv)                                                      \
    {                                                                  \
      rodbiDrvFree(drv);                                               \
      ROOCI_MEM_FREE(drv);                                             \
    }                                                                  \
    RODBI_ERROR((const char *)errMsg);                                 \
  }                                                                    \
}                                                                      \
while (0)

/* RODBI CHECK error using Connection handle */
#define RODBI_CHECK_CON(con, fun, pos, free_con, function_to_invoke)   \
do                                                                     \
{                                                                      \
  sword  rc;                                                           \
  if ((rc = (function_to_invoke)) != OCI_SUCCESS)                      \
  {                                                                    \
    text   errMsg[ROOCI_ERR_LEN];                                      \
    rodbiCheck((con)->drv_rodbiCon, con, (fun), (pos), rc,             \
               errMsg, sizeof(errMsg));                                \
    if (free_con)                                                      \
    {                                                                  \
      roociTerminateCon(&((con)->con_rodbiCon), 1);                    \
      ROOCI_MEM_FREE((con));                                           \
    }                                                                  \
    RODBI_ERROR((const char *)errMsg);                                 \
  }                                                                    \
}                                                                      \
while (0)

#define RODBI_CHECK_RES(res, fun, pos, free_res, function_to_invoke)   \
do                                                                     \
{                                                                      \
  sword  rc;                                                           \
  if ((rc = (function_to_invoke)) != OCI_SUCCESS)                      \
  {                                                                    \
    text   errMsg[ROOCI_ERR_LEN];                                      \
    rodbiCheck((res)->con_rodbiRes->drv_rodbiCon, (res)->con_rodbiRes, \
               (fun), (pos), rc, errMsg, sizeof(errMsg));              \
    if (free_res)                                                      \
    {                                                                  \
      roociResFree(&(res)->res_rodbiRes);                              \
      ROOCI_MEM_FREE((res));                                           \
    }                                                                  \
    RODBI_ERROR((const char *)errMsg);                                 \
  }                                                                    \
}                                                                      \
while (0)

#define RODBI_ERROR_RES(err_msg, free_res)                             \
do                                                                     \
{                                                                      \
  if (free_res)                                                        \
  {                                                                    \
    roociResFree(&(res)->res_rodbiRes);                                \
    ROOCI_MEM_FREE((res));                                             \
  }                                                                    \
  RODBI_ERROR((const char *)err_msg);                                  \
}                                                                      \
while (0)


/* rodbi R TYPe */
struct rodbiRTyp
{
  char      *name_rodbiRTyp;                                   /* type NAME */
  SEXPTYPE   styp_rodbiRTyp;                                   /* SEXP TYPe */
};
typedef struct rodbiRTyp rodbiRTyp;


/* RODBI R TYPe TABle */
static const rodbiRTyp rodbiRTypTab[] =
{
  {"",             NILSXP},
  {RODBI_R_LOG_NM, LGLSXP},
  {RODBI_R_INT_NM, INTSXP},
  {RODBI_R_NUM_NM, REALSXP},
  {RODBI_R_CHR_NM, STRSXP},
  {RODBI_R_LST_NM, VECSXP},
  {RODBI_R_DAT_NM, REALSXP},
  {RODBI_R_RAW_NM, VECSXP}
};

#define RODBI_TYPE_R(ityp) rodbiITypTab[ityp].rtyp_rodbiITyp

#define RODBI_TYPE_SXP(ityp) \
                rodbiRTypTab[rodbiITypTab[ityp].rtyp_rodbiITyp].styp_rodbiRTyp

#define RODBI_NAME_INT(ityp) rodbiITypTab[ityp].name_rodbiITyp

#define RODBI_SIZE_EXT(ityp) rodbiITypTab[ityp].size_rodbiITyp

#define RODBI_NAME_CLASS(ityp) \
                rodbiRTypTab[rodbiITypTab[ityp].rtyp_rodbiITyp].name_rodbiRTyp


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

/* ------------------------- rodbiResExecBind ----------------------------- */
/* bind input data and execute query */
static void rodbiResExecBind(rodbiRes *res, SEXP data, boolean free_res);

/* ------------------------- rodbiResBind --------------------------------- */
/* bind input data */
static void rodbiResBind(rodbiRes *res, SEXP data, boolean free_res);

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

/* ---------------------- rodbiResTrim ------------------------------------ */
/* trim result set column vector  */
static void rodbiResTrim(rodbiRes *res);

/* ---------------------- rodbiResDataFrame ------------------------------- */
/* make input data list a data frame  */
static void rodbiResDataFrame(rodbiRes *res);

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

/* --------------------- rodbichkIntFn ------------------------------------ */
/* Check for cntl-C interrupt */
void rodbichkIntFn(void *dummy)
{
  R_CheckUserInterrupt();
}

/*----------------------------------------------------------------------------
                               EXPORT FUNCTIONS
 ---------------------------------------------------------------------------*/

/* ----------------------------- rociDrvAlloc ----------------------------- */
/* create external pointer of driver */
SEXP rociDrvAlloc(void);

/* ----------------------------- rociDrvInit ------------------------------ */
/* Initialize driver  context */
SEXP rociDrvInit(SEXP ptrDrv, SEXP interruptible);

/* ----------------------------- rociDrvInfo ------------------------------ */
/* get driver info */
SEXP rociDrvInfo(SEXP ptrDrv);

/* ----------------------------- rociDrvTerm ------------------------------ */
/* terminate driver */
SEXP rociDrvTerm(SEXP ptrDrv);

/* ---------------------------- rociConInit ------------------------------- */
/* initialize connection context */
SEXP rociConInit(SEXP ptrDrv, SEXP params, SEXP prefetch, SEXP nrows,
                 SEXP stmtCacheSize);

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
                 SEXP prefetch, SEXP nrows);

/* --------------------------- rociResExec -------------------------------- */
/* execute statement */
SEXP rociResExec(SEXP hdlRes, SEXP data);

/* --------------------------- rociResFetch ------------------------------- */
/* fetch result */
SEXP rociResFetch(SEXP hdlRes, SEXP numRec);

/* --------------------------- rociResInfo -------------------------------- */
SEXP rociResInfo(SEXP hdlRes);

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
  SEXP  ptrDrv;

  /* make external pointer */
  ptrDrv = R_MakeExternalPtr(NULL, R_NilValue, R_NilValue);

  RODBI_TRACE("driver allocated");

  return ptrDrv;
} /* end rociDrvAlloc */

/* ------------------------------ rociDrvInit ----------------------------- */

SEXP rociDrvInit(SEXP ptrDrv, SEXP interruptible)
{
  rodbiDrv  *drv = R_ExternalPtrAddr(ptrDrv);

  /* check validity */
  if (drv)
  {
    if (drv->magicWord_rodbiDrv == RODBI_CHECKWD)    /* already initialized */
      return R_NilValue;
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

  /* set external pointer */
  R_SetExternalPtrAddr(ptrDrv, drv);
 
  /* create OCI environment, get client version */
  RODBI_CHECK_DRV(drv, __FUNCTION__, 1, TRUE,
               roociInitializeCtx(&(drv->ctx_rodbiDrv),
                                  *LOGICAL(interruptible)));
  
  /* set magicWord for driver */
  drv->magicWord_rodbiDrv = RODBI_CHECKWD;
  drv->interrupt_rodbiDrv = *LOGICAL(interruptible);

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
  PROTECT(info = allocVector(VECSXP, 7));

  /* allocate list element names */
  names = allocVector(STRSXP, 7);
  setAttrib(info, R_NamesSymbol, names);                  /* protects names */

  /* driverName */
  SET_VECTOR_ELT(info,  0, mkString(RODBI_DRV_NAME));
  SET_STRING_ELT(names, 0, mkChar("driverName"));

  /* driverVersion */
  snprintf(version, ROOCI_VERSION_LEN, "%d.%d-%d",
           RODBI_DRV_MAJOR, RODBI_DRV_MINOR, RODBI_DRV_UPDATE);
  SET_VECTOR_ELT(info,  1, mkString(version));
  SET_STRING_ELT(names, 1, mkChar("driverVersion"));

  /* clientVersion */
  snprintf(version, ROOCI_VERSION_LEN, "%d.%d.%d.%d.%d",
           drv->ctx_rodbiDrv.maj_roociCtx, drv->ctx_rodbiDrv.minor_roociCtx,
           drv->ctx_rodbiDrv.update_roociCtx, 
           drv->ctx_rodbiDrv.patch_roociCtx,
           drv->ctx_rodbiDrv.port_roociCtx);
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

  /* connections */
  SET_VECTOR_ELT(info,  6, rodbiDrvInfoConnections(drv));
  SET_STRING_ELT(names, 6, mkChar("connections"));

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
                 SEXP stmtCacheSize)
{
  char      *user              = (char *)CHAR(STRING_ELT(params, 0));
  char      *pass              = (char *)CHAR(STRING_ELT(params, 1));
  char      *conStr            = (char *)CHAR(STRING_ELT(params, 2));
  rodbiDrv  *drv               = rodbiGetDrv(ptrDrv);
  rodbiCon  *con;
  SEXP       hdlCon;
  boolean    wallet            = (!strcmp(user, "") && !strcmp(pass, ""));
                            /* is oracle wallet being used for authentication?
                               for oracle wallet authentication, user needs to
                               pass empty strings for username and password */

  /* allocate rodbi connection */
  ROOCI_MEM_ALLOC(con, 1, sizeof(rodbiCon));
  if (!con)
    RODBI_ERROR(RODBI_ERR_MEMORY_ALC);
  
  con->drv_rodbiCon = drv;

  /* Initialize connection environment */
  RODBI_CHECK_CON(con, __FUNCTION__, 1, FALSE,
                  roociInitializeCon(&drv->ctx_rodbiDrv, &(con->con_rodbiCon),
                                     user, pass, conStr, wallet,
                                     (ub4)INTEGER(stmtCacheSize)[0])); 
  
  (con->con_rodbiCon).parent_roociCon = con;
  con->ociprefetch_rodbiCon           = (*LOGICAL(prefetch) == TRUE) ? 
                                                                 TRUE : FALSE;
  con->nrows_rodbiCon                 = INTEGER(nrows)[0];

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
  text         errMsg[ROOCI_ERR_LEN];

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
      RODBI_CHECK_CON(con, __FUNCTION__, 1, FALSE,
                      roociGetError(&drv->ctx_rodbiDrv, &con->con_rodbiCon,
                                    &errNum, errMsg));
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
    PROTECT(info = allocVector(VECSXP, 10));

    /* allocate list element names */
    names = allocVector(STRSXP, 10);
    setAttrib(info, R_NamesSymbol, names);                /* protects names */

    RODBI_CHECK_CON(con, __FUNCTION__, 1, FALSE,
                    roociGetConInfo(&con->con_rodbiCon, &user, &userLen,
                                    verServer, &stmt_cache_size));

    /* username */
    usr_string = allocVector(STRSXP, 1);
    SET_STRING_ELT(usr_string, 0, mkCharLen((const char *)user, (int)userLen));
    SET_VECTOR_ELT(info,  0, usr_string);
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

    /* stmt_cache */
    SET_VECTOR_ELT(info,  8, ScalarInteger((int)stmt_cache_size));
    SET_STRING_ELT(names, 8, mkChar("stmt_cache"));
    
    /* results */
    SET_VECTOR_ELT(info,  9, rodbiConInfoResults(hdlCon));
    SET_STRING_ELT(names, 9, mkChar("results"));

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
    RODBI_CHECK_CON(con, __FUNCTION__, 1, FALSE, status);

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
    RODBI_CHECK_CON(con, __FUNCTION__, 1, FALSE, status);

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
                 SEXP prefetch, SEXP nrows)
{
  rodbiCon   *con             = rodbiGetCon(hdlCon);
  rodbiRes   *res;
  SEXP        hdlRes;
  boolean     pref;
  int         rows_per_fetch;
  cetype_t    enc;                                 /* encoding of statement */
  ub1         qry_encoding    = CE_NATIVE;
  ub4         stmt_cache_size = 0;

  pref = ((*LOGICAL(prefetch) == TRUE) ? TRUE :
                                        (con->ociprefetch_rodbiCon ? TRUE : 
                                                                     FALSE));
  /* There is some problem with statement cache and prefetch = FALSE optons.
     Hence blocking this combination for time being. */
  RODBI_CHECK_CON(con, __FUNCTION__, 1, FALSE,
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

  rows_per_fetch = (INTEGER(nrows)[0] == RODBI_BULK_READ) ?
                                   ((con->nrows_rodbiCon == RODBI_BULK_READ) ? 
                                      RODBI_BULK_READ : con->nrows_rodbiCon) :
                                                            INTEGER(nrows)[0];
  
  enc = Rf_getCharCE(STRING_ELT(statement, 0));
  if (enc == CE_NATIVE)
    qry_encoding = ROOCI_QRY_NATIVE;
  else if (enc == CE_LATIN1)
    qry_encoding = ROOCI_QRY_LATIN1;
  else if (enc == CE_UTF8)
    qry_encoding = ROOCI_QRY_UTF8;
  else
    RODBI_ERROR_RES(RODBI_ERR_UNSUPP_SQL_ENC, TRUE);

  enc = Rf_getCharCE(STRING_ELT(statement, 0));
  if (enc == CE_NATIVE)
    res->cnvtxt_rodbiRes = FALSE;
  else if (enc == CE_UTF8)
    res->cnvtxt_rodbiRes = TRUE;
  else
    RODBI_ERROR_RES(RODBI_ERR_UNSUPP_SQL_ENC, TRUE);

  if (res->con_rodbiRes->con_rodbiCon.timesten_rociCon)
  {
    /* execute optimizer statements for TimesTen connections */  
    sword status = roociExecTTOpt(&(res->con_rodbiRes->con_rodbiCon));
    RODBI_CHECK_RES(res, __FUNCTION__, 1, TRUE, status);
  }

  /* Initialize result set */
  RODBI_CHECK_RES(res, __FUNCTION__, 2, TRUE,
                  roociInitializeRes(&(con->con_rodbiCon), 
                                     &(res->res_rodbiRes),
                                     (oratext *)CHAR(STRING_ELT(statement, 0)),
                                     LENGTH(STRING_ELT(statement, 0)),
                                     qry_encoding,
                                     &(res->styp_rodbiRes), pref, 
                                     rows_per_fetch));

  (res->res_rodbiRes).parent_roociRes = res;

  /* bind data */
  if  ((res->res_rodbiRes).bcnt_roociRes)
    rodbiResBind(res, data, TRUE);

  /* execute the statement */
  rodbiResExecStmt(res, data, TRUE);

  if (res->styp_rodbiRes == OCI_STMT_SELECT)
  {
    /* define data */
    RODBI_CHECK_RES(res, __FUNCTION__, 3, TRUE,
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

  con->err_checked_rodbiCon = FALSE;

  /* setup adaptive fetching */
  if (nrow <= 0)
  {
    nrow                 = res->nrows_rodbiRes;
    res->expand_rodbiRes = TRUE;
  }

  /* allocate output data frame */
  rodbiResAlloc(res, nrow);

  /* state machine */
  while (!hasOutput)
  {
    switch (res->state_rodbiRes)
    {
    case FETCH_rodbiState:
        /* fetch data */
        RODBI_CHECK_RES(res, __FUNCTION__, 1, FALSE,
                        roociFetchData(&(res->res_rodbiRes), &fch_rows, 
                                       &(res->done_rodbiRes)));
       res->fchNum_rodbiRes = (int)fch_rows;
       /* set state */
       res->fchBeg_rodbiRes = 0;
      break;

    case SPLIT_rodbiState:
      rodbiResExpand(res);
      rodbiResSplit(res);
      break;

    case ACCUM_rodbiState:
      rodbiResAccum(res);
      break;

    case OUTPUT_rodbiState: 
      rodbiResTrim(res);
      rodbiResDataFrame(res);
      hasOutput = TRUE;
      break;

    default:
      RODBI_FATAL(__FUNCTION__, 1, res->state_rodbiRes);
      break;
    }
    rodbiResStateNext(res);
  }

  /* release output data frame and column names vector */
  UNPROTECT(2);

  RODBI_TRACE("result fetched");

  return res->list_rodbiRes;
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
  PROTECT(info = allocVector(VECSXP, 8));

  /* allocate list element names */
  names = allocVector(STRSXP, 8);
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

  /* fields */
  SET_VECTOR_ELT(info,  7, rodbiResInfoFields(res));
  SET_STRING_ELT(names, 7, mkChar("fields"));

  /* release info list */
  UNPROTECT(1);

  RODBI_TRACE("result described");

  return info;
} /* end rociResInfo */

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
  RODBI_DRV_ASSERT(drv, __FUNCTION__, 1);

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
    vec = allocVector(VECSXP, (drv->ctx_rodbiDrv).num_roociCtx);

    /* set valid connection IDs */ 
    for (conID = 0; conID < (drv->ctx_rodbiDrv).max_roociCtx; conID++)
      if ((drv->ctx_rodbiDrv).con_roociCtx[conID] &&
          rodbiAssertCon(
                   ((drv->ctx_rodbiDrv).con_roociCtx[conID])->parent_roociCon, 
                    __FUNCTION__, 1))
      {
        /* allocate connection handle */
        SEXP hdlCon = R_MakeExternalPtr(
                   ((drv->ctx_rodbiDrv).con_roociCtx[conID])->parent_roociCon,
                   R_NilValue, R_NilValue);
        SET_VECTOR_ELT(vec, vecID++, hdlCon);               /* protects vec */
      }
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
    if (!rodbiAssertCon(con, __FUNCTION__, 1))
      RODBI_ERROR(RODBI_ERR_INVALID_CON);

    rodbiConTerm(con);
    con = roociGetNextParentCon(&(drv->ctx_rodbiDrv));
  }

  /* free driver oci context */
  RODBI_CHECK_DRV(drv, __FUNCTION__, 1, FALSE,
                  roociTerminateCtx(&(drv->ctx_rodbiDrv)));

  /* free rodbi driver */
  ROOCI_MEM_FREE(drv);

  RODBI_TRACE("driver freed");
} /* end rodbiDrvFree */


/****************************************************************************/
/*  (*) CONNECTION FUNCTIONS                                                */
/****************************************************************************/

/* ------------------------------ rodbiGetCon ----------------------------- */

static rodbiCon *rodbiGetCon(SEXP hdlCon)
{
  rodbiCon  *con = R_ExternalPtrAddr(hdlCon);

  /* check validity */
  if (!con || (con && !rodbiAssertCon(con, __FUNCTION__, 1)))
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
      if (res && rodbiAssertRes(res->parent_roociRes, __FUNCTION__, 1))
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
    if (!rodbiAssertRes(res, __FUNCTION__, 1))
      RODBI_ERROR(RODBI_ERR_INVALID_RES);
    rodbiResTerm(res);
    res = roociGetNextParentRes(&(con->con_rodbiCon));
  }

  /* free connection */
  RODBI_CHECK_CON(con, __FUNCTION__, 1, FALSE,
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
  if (!res || (res && !rodbiAssertRes(res, __FUNCTION__, 1)))
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
       RODBI_CHECK_RES(res, __FUNCTION__, 1, free_res,
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
    RODBI_ERROR_RES(RODBI_ERR_MANY_ROWS, free_res);
  else
    rodbiResBindCopy(res, data, 0, 1, free_res);

  /* execute the statement */
  RODBI_CHECK_RES(res, __FUNCTION__, 1, free_res,
                  roociStmtExec(&(res->res_rodbiRes), 0, res->styp_rodbiRes, 
                                &(res->affrows_rodbiRes)));

  /* set state */
  res->state_rodbiRes = FETCH_rodbiState;
} /* end rodbiResExecQuery */

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
    RODBI_CHECK_RES(res, __FUNCTION__, 1, free_res,
                    roociStmtExec(&(res->res_rodbiRes), iters, 
                                  res->styp_rodbiRes, 
                                  &(res->affrows_rodbiRes)));
  
    /* next chunk */
    rows -= (int)iters;
  }

  /* set state */
  res->state_rodbiRes = CLOSE_rodbiState;
} /* end rodbiResExecBind */


/* ----------------------------- rodbiResBind ----------------------------- */

static void rodbiResBind(rodbiRes *res, SEXP data, boolean free_res)
{
  int       bid;

  /* validate data */
  if (isNull(data) || LENGTH(data) != (res->res_rodbiRes).bcnt_roociRes)
    RODBI_ERROR_RES(RODBI_ERR_BIND_MISMATCH, free_res);

  /* set bind buffer size */
  (res->res_rodbiRes).bmax_roociRes = LENGTH(VECTOR_ELT(data, 0));
  if (!(res->res_rodbiRes).bmax_roociRes)
    RODBI_ERROR_RES(RODBI_ERR_BIND_EMPTY, free_res);
  else if ((res->res_rodbiRes).bmax_roociRes > RODBI_BULK_WRITE)
    (res->res_rodbiRes).bmax_roociRes = RODBI_BULK_WRITE;

  /* allocate bind vectors */
  ROOCI_MEM_ALLOC((res->res_rodbiRes).bdat_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(void *));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).bind_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(sb2 *));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).alen_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(ub2 *));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).bsiz_roociRes, 
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(ub2));

  ROOCI_MEM_ALLOC((res->res_rodbiRes).btyp_roociRes,
                  (res->res_rodbiRes).bcnt_roociRes, sizeof(ub2));

  if (!((res->res_rodbiRes).bdat_roociRes) ||
      !((res->res_rodbiRes).bind_roociRes) ||
      !((res->res_rodbiRes).alen_roociRes) ||
      !((res->res_rodbiRes).bsiz_roociRes) ||
      !((res->res_rodbiRes).btyp_roociRes))
    RODBI_ERROR_RES(RODBI_ERR_MEMORY_ALC, free_res);

  /* bind data */
  for (bid = 0; bid < (res->res_rodbiRes).bcnt_roociRes; bid++)
  {
    SEXP      vec = VECTOR_ELT(data, bid);

    /* set bind parameters */
    if (isReal(vec))
    {
      SEXP  clsName = GET_CLASS(vec);
      if (isNull(clsName) ||
          strcmp(CHAR(STRING_ELT(clsName, 0)), RODBI_R_DAT_NM)) 
      {
        (res->res_rodbiRes).btyp_roociRes[bid] = SQLT_BDOUBLE;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (ub2)sizeof(double);
      }
      else
      {
        (res->res_rodbiRes).btyp_roociRes[bid] = SQLT_TIMESTAMP_TZ;
        (res->res_rodbiRes).bsiz_roociRes[bid] = (ub2)sizeof(OCIDateTime *);
      }
    }
    else if (isInteger(vec) || isLogical(vec))
    {
      (res->res_rodbiRes).btyp_roociRes[bid] = SQLT_INT;
      (res->res_rodbiRes).bsiz_roociRes[bid] = (ub2)sizeof(int);
    }
    else if (isString(vec))
    {
      (res->res_rodbiRes).btyp_roociRes[bid] = SQLT_STR;
      (res->res_rodbiRes).bsiz_roociRes[bid] = (ub2)((4000 + 1) *
                         res->con_rodbiRes->con_rodbiCon.nlsmaxwidth_roociCon);
    }
    else if (IS_LIST(vec) && IS_RAW(VECTOR_ELT(vec, 0)))
    {
      (res->res_rodbiRes).btyp_roociRes[bid] = SQLT_BIN;
      (res->res_rodbiRes).bsiz_roociRes[bid] = (ub2)(2000);
    }
    else
      RODBI_ERROR_RES(RODBI_ERR_UNSUPP_BIND_TYPE, free_res);

    /* allocate bind buffers */
    ROOCI_MEM_ALLOC((res->res_rodbiRes).bdat_roociRes[bid], 
                    ((res->res_rodbiRes).bmax_roociRes * 
                    (res->res_rodbiRes).bsiz_roociRes[bid]), sizeof(ub1));

    if ((res->res_rodbiRes).btyp_roociRes[bid] == SQLT_TIMESTAMP_TZ)
    {
      void **tsdt = (void **)((res->res_rodbiRes).bdat_roociRes[bid]);
      RODBI_CHECK_RES(res, __FUNCTION__, 1, free_res,
                      roociAllocTSBindBuf(&(res->res_rodbiRes), tsdt, bid));
    } 
    
    ROOCI_MEM_ALLOC((res->res_rodbiRes).bind_roociRes[bid],
                    (res->res_rodbiRes).bmax_roociRes, sizeof(sb2));

    ROOCI_MEM_ALLOC((res->res_rodbiRes).alen_roociRes[bid],
                    (res->res_rodbiRes).bmax_roociRes, sizeof(ub2));

    if (!((res->res_rodbiRes).bdat_roociRes[bid]) ||
        !((res->res_rodbiRes).bind_roociRes[bid]) ||
        !((res->res_rodbiRes).alen_roociRes[bid]))
      RODBI_ERROR_RES(RODBI_ERR_MEMORY_ALC, free_res);
  }
} /* end rodbiResBind */

/* ---------------------------- rodbiResBindCopy -------------------------- */

static void rodbiResBindCopy(rodbiRes *res, SEXP data, int beg, int end,
                             boolean free_res)
{
  int  bid;
  int  i;

  for (bid = 0; bid < (res->res_rodbiRes).bcnt_roociRes; bid++)
  {
    SEXP  elem = VECTOR_ELT(data, bid);
    ub1  *dat  = (ub1 *)(res->res_rodbiRes).bdat_roociRes[bid];
    sb2  *ind  = (res->res_rodbiRes).bind_roociRes[bid];
    ub2  *alen  = (res->res_rodbiRes).alen_roociRes[bid];
    ub1   form_of_use = 0;

    /* copy vector */
    for (i = beg; i < end; i++)
    {
      *ind = OCI_IND_NOTNULL;
      *alen = (res->res_rodbiRes).bsiz_roociRes[bid];

      if (isReal(elem))
      {

        if (ISNA(REAL(elem)[i]))
          *ind = OCI_IND_NULL;
        else
        {
          if ((res->res_rodbiRes).btyp_roociRes[bid] == SQLT_TIMESTAMP_TZ)
            RODBI_CHECK_RES(res, __FUNCTION__, 1, free_res,
                            roociWriteDateTimeData(&(res->res_rodbiRes),
                                                   *(OCIDateTime **)dat,
                                                   REAL(elem)[i]));
          else
            *(double *)dat = REAL(elem)[i];
        }
      }
      else if (isInteger(elem))
      {
        if (INTEGER(elem)[i] == NA_INTEGER)
          *ind = OCI_IND_NULL;
        else
          *(int *)dat = INTEGER(elem)[i];
      }
      else if (isLogical(elem))
      {
        if (LOGICAL(elem)[i] == NA_LOGICAL)
          *ind = OCI_IND_NULL;
        else
          *(int *)dat = LOGICAL(elem)[i];
      }
      else if (isString(elem))
      {
        if (STRING_ELT(elem, i) == NA_STRING)
          *ind = OCI_IND_NULL;
        else
        {
          const char *str = CHAR(STRING_ELT(elem, i));
          size_t      len = (ub2)strlen(str);
          cetype_t    enc;
         
          /* raise error if i/p data size is bigger than supported size */
          if (len >= (res->res_rodbiRes).bsiz_roociRes[bid])
            RODBI_ERROR_RES(RODBI_ERR_BIND_VAL_TOOBIG, free_res);
          
          memcpy(dat, str, len);
          dat[len] = (ub1)0;

          /*
          ** Get the character encoding, we only look at first element and
          ** assume that the remaining ones are of same encoding.
          */
          if (form_of_use == 0)
          {
            enc = Rf_getCharCE(STRING_ELT(elem, i));
            if (enc == CE_NATIVE)
              form_of_use = SQLCS_IMPLICIT;
            else if (enc == CE_UTF8)
              form_of_use = SQLCS_NCHAR;
            else
              RODBI_ERROR_RES(RODBI_ERR_UNSUPP_BIND_ENC, free_res);
          }
        }
      }
      else if (IS_LIST(elem) && IS_RAW(VECTOR_ELT(elem, i)))
      {
        SEXP  x = VECTOR_ELT(elem, i);

        if (isNull(x))
          *ind = OCI_IND_NULL;
        else
        {
          int   k;

          if (LENGTH(x) > (res->res_rodbiRes).bsiz_roociRes[bid])
            RODBI_ERROR_RES(RODBI_ERR_BIND_VAL_TOOBIG, free_res);

          *alen = (ub2)LENGTH(x);
          for (k=0; k<*alen; k++)
            dat[k] = RAW(x)[k];
        }
      }

      /* next row */
      dat += (res->res_rodbiRes).bsiz_roociRes[bid];
      ind++;
      alen++;
    }

    /* bind data buffers */
    RODBI_CHECK_RES(res, __FUNCTION__, 1, free_res,
                    roociBindData(&(res->res_rodbiRes), (ub4)(bid+1), 
                                  form_of_use));

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
                        RODBI_TYPE_SXP((res->res_rodbiRes).typ_roociRes[cid]),
                                       nrow));

    /* get column name & parameters */
    RODBI_CHECK_RES(res, __FUNCTION__, 1, FALSE,
                    roociGetColProperties(&(res->res_rodbiRes), 
                                          (ub4)(cid+1), &len, &buf));

    /* set column name */
    SET_STRING_ELT(res->name_rodbiRes, cid,
                   mkCharLen((const char *)buf, (int)len));
  }

  /* set names attribute */
  setAttrib(res->list_rodbiRes, R_NamesSymbol, res->name_rodbiRes);

  /* set the state */
  res->nrow_rodbiRes = nrow;
  res->rows_rodbiRes = 0;
} /* end rodbiResAlloc */

/* ---------------------------- rodbiResExpand ---------------------------- */

static void rodbiResExpand(rodbiRes *res)
{
  int nrow = res->rows_rodbiRes + res->fchNum_rodbiRes - res->fchBeg_rodbiRes;
  int ncol = (res->res_rodbiRes).ncol_roociRes;
  int cid;

  if (!(res->expand_rodbiRes) || (res->nrow_rodbiRes > nrow))
    return;

  /* compute new size */
  while (res->nrow_rodbiRes <= nrow)
    res->nrow_rodbiRes *= 2;

  /* expand column vectors */
  for (cid = 0; cid < ncol; cid++)
  {
    SEXP vec = VECTOR_ELT(res->list_rodbiRes, cid);
    vec = lengthgets(vec, res->nrow_rodbiRes);
    SET_VECTOR_ELT(res->list_rodbiRes, cid, vec);           /* protects vec */
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

  /* accumulate data */
  for (cid = 0; cid < (res->res_rodbiRes).ncol_roociRes; cid++)
  {
    ub1  *dat = (ub1 *)(res->res_rodbiRes).dat_roociRes[cid] 
                + (fbeg * (res->res_rodbiRes).siz_roociRes[cid]);

    for (fcur = fbeg, lcur = rows; fcur < fend; fcur++, lcur++)
    {
      SEXP  vec  = VECTOR_ELT(list, cid);
      ub1   rtyp = RODBI_TYPE_R((res->res_rodbiRes).typ_roociRes[cid]);
      ub2   etyp = rodbiTypeExt((res->res_rodbiRes).typ_roociRes[cid]);

      /* copy data */
      if ((res->res_rodbiRes).ind_roociRes[cid][fcur] == OCI_IND_NULL)
      {
        switch(rtyp)
        {
        case RODBI_R_INT:
          INTEGER(vec)[lcur] = NA_INTEGER;
          break;

        case RODBI_R_NUM:
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
          SET_VECTOR_ELT(vec,  lcur, rawVec);
          UNPROTECT(1);
        }
          break;

        default:
          RODBI_FATAL(__FUNCTION__, 1, rtyp);
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
          REAL(vec)[lcur] = *(double *)dat;
          break;

        case SQLT_STR:
        {
          cetype_t    enc;

          if ((res->res_rodbiRes).form_roociRes[cid] == SQLCS_NCHAR)
            enc = CE_UTF8;
          else
            enc = CE_NATIVE;

          SET_STRING_ELT(vec, lcur,
                         Rf_mkCharLenCE((char *)dat,
                           (res->res_rodbiRes).len_roociRes[cid][fcur], enc));
        }
        break;

        case SQLT_BIN:
        {
          int  len = (int)((res->res_rodbiRes).len_roociRes[cid][fcur]);
          SEXP rawVec;
          int  i;
          Rbyte *b;

          PROTECT(rawVec = NEW_RAW(len));
          b = RAW(rawVec);
          for (i=0; i<len; i++)
            b[i] = dat[i];
          SET_VECTOR_ELT(vec,  lcur, rawVec);
          UNPROTECT(1);
        }
        break;

        case SQLT_CLOB:
        {
          cetype_t    enc;

          if ((res->res_rodbiRes).form_roociRes[cid] == SQLCS_NCHAR)
            enc = CE_UTF8;
          else
            enc = CE_NATIVE;

          /* read LOB data */
          RODBI_CHECK_RES(res, __FUNCTION__, 2, FALSE,
                          roociReadLOBData(&(res->res_rodbiRes), &lob_len,
                                           fcur, cid));

          /* make character element */
          SET_STRING_ELT(vec, lcur, mkCharLenCE((const char *)
                         ((res->res_rodbiRes).lobbuf_roociRes), lob_len, enc));
        }
        break;

        case SQLT_BLOB:
        case SQLT_BFILE:
        {
          SEXP rawVec;
          int  i;
          Rbyte *b;

          /* read LOB data */
          RODBI_CHECK_RES(res, __FUNCTION__, 3, FALSE,
                          roociReadBLOBData(&(res->res_rodbiRes), &lob_len,
                                            fcur, cid));

          PROTECT(rawVec = NEW_RAW(lob_len));
          b = RAW(rawVec);
          for (i=0; i<lob_len; i++)
            b[i] = (res->res_rodbiRes).lobbuf_roociRes[i];
          SET_VECTOR_ELT(vec,  lcur, rawVec);
          UNPROTECT(1);
        }
        break;

        case SQLT_TIMESTAMP_TZ:
          RODBI_CHECK_RES(res, __FUNCTION__, 4, FALSE,
               roociReadDateTimeData(&(res->res_rodbiRes),
               *(OCIDateTime **)dat, &tstm,
               !strcmp(RODBI_NAME_INT((res->res_rodbiRes).typ_roociRes[cid]),
                       RODBI_DATE_NM)));
          REAL(vec)[lcur] = tstm;
          break;

        default:
          RODBI_FATAL(__FUNCTION__, 5, etyp);
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
} /* end rodbiResAccum */

/* ----------------------------- rodbiResTrim ----------------------------- */

static void rodbiResTrim(rodbiRes *res)
{
  int  cid;

  /* nothing to trim */
  if (res->rows_rodbiRes == res->nrow_rodbiRes)
    return;

  /* trim column vectors to the actual size */
  for (cid = 0; cid < (res->res_rodbiRes).ncol_roociRes; cid++)
  {
    SEXP vec = VECTOR_ELT(res->list_rodbiRes, cid);
    vec = lengthgets(vec, res->rows_rodbiRes);
    SET_VECTOR_ELT(res->list_rodbiRes, cid, vec);           /* protects vec */
  }
} /* end rodbiResTrim */

/* -------------------------- rodbiResDataFrame --------------------------- */

static void rodbiResDataFrame(rodbiRes *res)
{
  SEXP row_names;
  SEXP cla; 
  int  ncol = (res->res_rodbiRes).ncol_roociRes;
  int  cid; 

  /* make datetime columns a POSIXct */
  for (cid = 0; cid < ncol; cid++)
  {
    if (RODBI_TYPE_R((res->res_rodbiRes).typ_roociRes[cid]) == RODBI_R_DAT)
    {    
      PROTECT(cla = allocVector(STRSXP, 2)); 
      SET_STRING_ELT(cla, 0, mkChar(RODBI_R_DAT_NM));
      SET_STRING_ELT(cla, 1, mkChar("POSIXt"));
      setAttrib(VECTOR_ELT(res->list_rodbiRes, cid), R_ClassSymbol, cla);
      UNPROTECT(1);
    }
  }

  /* make input data list a data.frame */
  PROTECT(row_names     = allocVector(INTSXP, 2));
  INTEGER(row_names)[0] = NA_INTEGER;
  INTEGER(row_names)[1] = LENGTH(VECTOR_ELT(res->list_rodbiRes, 0));
  setAttrib(res->list_rodbiRes, R_RowNamesSymbol, row_names);
  setAttrib(res->list_rodbiRes, R_ClassSymbol, mkString("data.frame"));
  UNPROTECT(1);
} /* end rodbiResDataFrame */

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
  default:
    RODBI_FATAL(__FUNCTION__, 1, res->state_rodbiRes);
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
  RODBI_CHECK_RES(res, __FUNCTION__, 1, FALSE,
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

  /* allocate output list */
  PROTECT(list = allocVector(VECSXP, 7));

  /* allocate and set names */
  names = allocVector(STRSXP, 7);
  setAttrib(list, R_NamesSymbol, names);                  /* protects names */

  /* allocate and set row names */
  row_names = allocVector(INTSXP, 2);
  INTEGER(row_names)[0] = NA_INTEGER;
  INTEGER(row_names)[1] = (res->res_rodbiRes).ncol_roociRes;
  setAttrib(list, R_RowNamesSymbol, row_names);       /* protects row_names */

  /* set class to data frame */
  setAttrib(list, R_ClassSymbol, mkString("data.frame"));

  /* name */
  PROTECT(vecName = allocVector(STRSXP, (res->res_rodbiRes).ncol_roociRes));
  /* Sclass */
  PROTECT(vecType = allocVector(STRSXP, (res->res_rodbiRes).ncol_roociRes));
  /* len */
  PROTECT(vecLen = allocVector(INTSXP, (res->res_rodbiRes).ncol_roociRes));
  /* type */
  PROTECT(vecClass = allocVector(STRSXP, (res->res_rodbiRes).ncol_roociRes));
  /* precision */
  PROTECT(vecPrec = allocVector(INTSXP, (res->res_rodbiRes).ncol_roociRes));
  /* scale */
  PROTECT(vecScale = allocVector(INTSXP, (res->res_rodbiRes).ncol_roociRes));
  /* nullOK */
  PROTECT(vecInd = allocVector(LGLSXP, (res->res_rodbiRes).ncol_roociRes));
  for (cid = 0; cid < (res->res_rodbiRes).ncol_roociRes; cid++)
  {
    RODBI_CHECK_RES(res, __FUNCTION__, 1, FALSE,
                    roociDescCol(&(res->res_rodbiRes), 
                                 (ub4)(cid+1), NULL, &buf, &len, 
                                 &siz, &pre, &sca, &nul, NULL));
    SET_STRING_ELT(vecName, cid, mkCharLen((const char *)buf, (int)len));
    SET_STRING_ELT(vecType, cid, mkChar(RODBI_NAME_CLASS(
                                     (res->res_rodbiRes).typ_roociRes[cid])));
    SET_STRING_ELT(vecClass, cid, mkChar(RODBI_NAME_INT(
                                     (res->res_rodbiRes).typ_roociRes[cid])));
    INTEGER(vecLen)[cid]   = (int)siz;
    INTEGER(vecPrec)[cid]  = (int)pre;
    INTEGER(vecScale)[cid] = (int)sca;
    LOGICAL(vecInd)[cid]   = nul ? TRUE : FALSE;
  }
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

  /* release output list */
  UNPROTECT(8);

  return list;
} /* end rodbiResInfoFields */

/* ------------------------------- rodbiResTerm ---------------------------- */

static void rodbiResTerm(rodbiRes  *res)
{
  rodbiCon  *con = res->con_rodbiRes;
  
  con->err_checked_rodbiCon = FALSE;

  /* free result set */
  RODBI_CHECK_RES(res, __FUNCTION__, 1, FALSE,
                  roociResFree(&(res->res_rodbiRes)));
  (con->con_rodbiCon).num_roociCon--;

  ROOCI_MEM_FREE(res);
} /* end rodbiResTerm */
  
  
/* ------------------------------- rodbiCheck ----------------------------- */

static void rodbiCheck(rodbiDrv *drv, rodbiCon *con, const char *fun, 
                       int pos, sword status, text *errMsg, size_t errMsgLen)
{
  sb4    errNum;
  int    msglen;
  
  switch (status)
  {
  case OCI_SUCCESS:
  case OCI_SUCCESS_WITH_INFO:
    break;

  case OCI_ERROR:
    /* get error */
    roociGetError(&(drv->ctx_rodbiDrv), &(con->con_rodbiCon), 
                  &errNum, errMsg);
    break;

  case ROOCI_DRV_ERR_MEM_FAIL:
    msglen = (int)((errMsgLen < strlen(RODBI_ERR_MEMORY_ALC)+1) ?
                    errMsgLen : strlen(RODBI_ERR_MEMORY_ALC)+1);
    memcpy(errMsg, RODBI_ERR_MEMORY_ALC, msglen);
    *(errMsg + msglen) = 0;
    break;

  case ROOCI_DRV_ERR_CON_FAIL:
    /* get error */
    roociGetError(&(drv->ctx_rodbiDrv), &(con->con_rodbiCon), 
                  &errNum, errMsg);
    /* free connection */
    roociTerminateCon(&(con->con_rodbiCon), 0);
    ROOCI_MEM_FREE(con);                                           
    break;

  default:
    {
      msglen = snprintf((char *)errMsg, errMsgLen, RODBI_ERR_INTERNAL,
                        fun, pos, status);
      if (msglen >= errMsgLen)
        *(errMsg + errMsgLen - 1) = 0;
      else
        *(errMsg + msglen + 1) = 0;
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

ub1 rodbiTypeInt(ub2 ctyp, sb2 precision, sb1 scale, ub2 size,
                 boolean timesten)
{
  ub1 ityp;

  switch (ctyp)
  {
  case SQLT_CHR:                                     /* VARCHAR2, NVARCHAR2 */
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
    ityp = RODBI_CHAR;
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
  case SQLT_NTY:              /* USER-DEFINED TYPE (OBJECT, VARRAY, TABLE ) */
    ityp = RODBI_UDT;
    break;
  case SQLT_REF:
    ityp = RODBI_REF;
    break;
  case SQLT_CLOB:                                          /* Character LOB */
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
  default:
    ityp = 0;
    RODBI_FATAL("roTypeInt", 1, ctyp);
    break;
  }

  return ityp;
} /* end rodbiTypeInt */


/* ---------------------------- rawVecToListCall ------------------------------ */
SEXP rawVecToListCall(SEXP val, SEXP chunksz) {

  const int CHUNKSZ = *(INTEGER(chunksz));
  R_len_t k, idx=0, seglen=0, rawlen=LENGTH(val);
  Rbyte * valraw;
  Rbyte * valout;
  PROTECT_INDEX px;
  SEXP out;

  valraw = RAW(val);
  PROTECT_WITH_INDEX(out = allocVector(VECSXP, rawlen>0 ? (rawlen-1)/CHUNKSZ+1 : 0), &px);
  for (k=0; k < rawlen; k+=CHUNKSZ) {
    seglen =  k+CHUNKSZ <= rawlen ? CHUNKSZ : rawlen-k;
    SET_VECTOR_ELT(out, idx, allocVector(RAWSXP, seglen));
    valout = RAW(VECTOR_ELT(out, idx));
    memcpy(valout, valraw+k, seglen);
    idx++;
  }

  UNPROTECT(1);
  return out;

} /* end of rawVecToListCall */

/* end of file rodbi.c */
