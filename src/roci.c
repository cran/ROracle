/* Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   NAME
     roci.c - ROCI

   DESCRIPTION
     OCI based DBI driver for R.

   EXPORT FUNCTION(S)
     (*) DRIVER FUNCTIONS
         rociDrvAlloc   - DRiVer ALLOCate handle
         rociDrvInit    - DRiVer INITialize handle
         rociDrvInfo    - DRiVer get INFO
         rociDrvTerm    - DRiVer TERMinate handle

     (*) CONNECTION FUNCTIONS
         rociConInit    - CONnection INITialize handle
         rociConError   - CONnection get and reset last ERRor
         rociConInfo    - CONnection get INFO
         rociConTerm    - CONnection TERMinate handle

     (*) RESULT FUNCTIONS
         rociResInit    - RESult INITialize handle and execute statement
         rociResExec    - RESult re-EXECute
         rociResFetch   - RESult FETCH data
         rociResInfo    - RESult get INFO
         rociResTerm    - RESult TERMinate handle

   INTERNAL FUNCTION(S)
     NONE

   STATIC FUNCTION(S)
     (*) DRIVER FUNCTIONS
         rociGetDrv
         rociDrvInfoConnections
         rociDrvFree

     (*) CONNECTION FUNCTIONS
         rociGetConID
         rociNewConID
         rociConInfoResults
         rociConFree

     (*) RESULT FUNCTIONS
         rociGetResID
         rociNewResID
         rociResExecStmt
         rociResExecQuery
         rociResExecBind
         rociResExecOnce
         rociResBind
         rociResBindCopy
         rociResDefine
         rociResAlloc
         rociResRead
         rociResExpand
         rociResSplit
         rociResAccum
         rociResTrim
         rociResDataFrame
         rociResStateNext
         rociResInfoStmt
         rociResInfoFields
         rociResFree

     (*) OCI FUNCTIONS
         rociTypeInt
         rociTypeExt
         rociCheck

   NOTES

   MODIFIED   (MM/DD/YY)
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

#include <R.h>
#include <Rdefines.h>

#ifdef ENABLE_NLS
# include <libintl.h>
# define _(String) dgettext("ROracle", String)
#else
# define _(String) (String)
#endif

#ifndef OCI_ORACLE
# include <oci.h>
#endif

#ifdef DEBUG_ROCI
# define ROCI_TRACE(txt)  Rprintf("ROracle: %s\n", (txt))
#else
# define ROCI_TRACE(txt)
#endif

/*---------------------------------------------------------------------------
                          PRIVATE TYPES AND CONSTANTS
  ---------------------------------------------------------------------------*/

/* ROCI DRiVer version */
#define ROCI_DRV_NAME       "Oracle (OCI)"
#define ROCI_DRV_MAJOR       1
#define ROCI_DRV_MINOR       1
#define ROCI_DRV_UPDATE      2

/* ROCI internal Oracle types */
#define ROCI_VARCHAR2        1
#define ROCI_NUMBER          2
#define ROCI_INTEGER         3
#define ROCI_LONG            4
#define ROCI_DATE            5
#define ROCI_RAW             6
#define ROCI_LONG_RAW        7
#define ROCI_ROWID           8
#define ROCI_CHAR            9
#define ROCI_BFLOAT         10                               /* BINARY_FLOAT */
#define ROCI_BDOUBLE        11                              /* BINARY_DOUBLE */
#define ROCI_UDT            12                          /* USER-DEFINED TYPE */
#define ROCI_REF            13
#define ROCI_CLOB           14
#define ROCI_BLOB           15
#define ROCI_BFILE          16
#define ROCI_TIME           17                                  /* TIMESTAMP */
#define ROCI_TIME_TZ        18                   /* TIMESTAMP WITH TIME ZONE */
#define ROCI_INTER_YM       19                     /* INTERVAL YEAR TO MONTH */
#define ROCI_INTER_DS       20                     /* INTERVAL DAY TO SECOND */
#define ROCI_TIME_LTZ       21             /* TIMESTAMP WITH LOCAL TIME ZONE */

/* ROCI internal Oracle types NaMes */
#define ROCI_VARCHAR2_NM    "VARCHAR2"
#define ROCI_NUMBER_NM      "NUMBER"
#define ROCI_INTEGER_NM     "NUMBER"
#define ROCI_LONG_NM        "LONG"
#define ROCI_DATE_NM        "DATE"
#define ROCI_RAW_NM         "RAW"
#define ROCI_LONG_RAW_NM    "LONG RAW"
#define ROCI_ROWID_NM       "ROWID"
#define ROCI_CHAR_NM        "CHAR"
#define ROCI_BFLOAT_NM      "BINARY_FLOAT"
#define ROCI_BDOUBLE_NM     "BINARY_DOUBLE"
#define ROCI_UDT_NM         "USER-DEFINED TYPE"
#define ROCI_REF_NM         "REF"
#define ROCI_CLOB_NM        "CLOB"
#define ROCI_BLOB_NM        "BLOB"
#define ROCI_BFILE_NM       "BFILE"
#define ROCI_TIME_NM        "TIMESTAMP"
#define ROCI_TIME_TZ_NM     "TIMESTAMP WITH TIME ZONE"
#define ROCI_INTER_YM_NM    "INTERVAL YEAR TO MONTH"
#define ROCI_INTER_DS_NM    "INTERVAL DAY TO SECOND"
#define ROCI_TIME_LTZ_NM    "TIMESTAMP WITH LOCAL TIME ZONE"

/* ROCI R classes */
#define ROCI_R_LOG           1                                    /* LOGICAL */
#define ROCI_R_INT           2                                    /* INTEGER */
#define ROCI_R_NUM           3                                    /* NUMERIC */
#define ROCI_R_CHR           4                                  /* CHARACTER */
#define ROCI_R_LST           5                                       /* LIST */

/* ROCI R classes NaMes */
#define ROCI_R_LOG_NM       "logical"
#define ROCI_R_INT_NM       "integer"
#define ROCI_R_NUM_NM       "numeric"
#define ROCI_R_CHR_NM       "character"
#define ROCI_R_LST_NM       "list"
  
/* ROCI BULK READ count */
#define ROCI_BULK_READ    1000

/* ROCI BULK WRITE count */
#define ROCI_BULK_WRITE   1000

/* ROCI DEFault number of CONnections */
#define ROCI_CON_DEF         5

/* ROCI DEFault number of RESults */
#define ROCI_RES_DEF         5

/* ROCI ERRor buffer LENgth */
#define ROCI_ERR_LEN      2048

/* ROCI LOB RouNDing */
#define ROCI_LOB_RND      1000

/* forward declarations */ 
struct rociCon;
struct rociRes;

/* ROCI fetch STATEs */
enum rociState {
  FETCH_rociState,                                   /* pre-FETCH query data */
  SPLIT_rociState,                                 /* SPLIT pre-fetch buffer */
  ACCUM_rociState,          /* ACCUMulate pre-fetched data into a data frame */
  OUTPUT_rociState,                                   /* OUTPUT a data frame */
  CLOSE_rociState                                      /* CLOSE the satement */
};
typedef enum rociState rociState;

/* ROCI DRiVer */
struct rociDrv
{
  OCIEnv          *env_rociDrv;                        /* ENVironment handle */
  OCIError        *err_rociDrv;                              /* ERRor handle */
  struct rociCon **con_rociDrv;                         /* CONnection vector */
  int              num_rociDrv;                /* NUMber of open connections */
  int              max_rociDrv;             /* MAXimum number of connections */
  int              tot_rociDrv;     /* TOTal number of connections processed */
  char             verClient_rociDrv[64];              /* OCI CLIENT VERsion */
  boolean          valid_rociDrv;                           /* VALIDity flag */
};
typedef struct rociDrv rociDrv;

/* ROCI CONnection */
struct rociCon
{
  rociDrv         *drv_rociCon;                               /* ROCI DRiVer */
  OCIAuthInfo     *aut_rociCon;                     /* AUThentication handle */
  OCISvcCtx       *svc_rociCon;                    /* SerViCe context handle */
  OCISession      *usr_rociCon;                       /* USeR session handle */
  struct rociRes **res_rociCon;                             /* RESult vector */
  int              num_rociCon;                    /* NUMber of open results */
  int              max_rociCon;                 /* MAXimum number of results */
  int              tot_rociCon;         /* TOTal number of results processed */
  char            *user_rociCon;                                /* USER name */
  char            *cstr_rociCon;                           /* Connect STRing */
  char             verServer_rociCon[128];                 /* SERVER VERsion */
  sb4              errNum_rociCon;                      /* last ERRor NUMber */
  text             errMsg_rociCon[ROCI_ERR_LEN];       /* last ERRor MesSaGe */
  boolean          valid_rociCon;                           /* VALIDity flag */
};
typedef struct rociCon rociCon;

/* ROCI RESult */
struct rociRes
{
  rociCon         *con_rociRes;                           /* ROCI CONnection */
  OCIStmt         *stm_rociRes;                          /* STateMent handle */
  ub2              styp_rociRes;                           /* Statement TYPe */
  boolean          valid_rociRes;                           /* VALIDity flag */

  /* -------------------------------- BIND --------------------------------- */
  int              bcnt_rociRes;                               /* Bind CouNT */
  int              bmax_rociRes;                            /* Bind MAX rows */
  void           **bdat_rociRes;                        /* Bind DATa buffers */
  sb2            **bind_rociRes;                   /* Bind INDicator buffers */
  ub2             *bsiz_rociRes;                /* Bind buffer maximum SIZes */
  ub2             *btyp_rociRes;                        /* Bind buffer TYPes */

  /* ------------------------------- DEFINE -------------------------------- */
  int              ncol_rociRes;                        /* Number of COLumns */
  ub1             *typ_rociRes;                            /* internal TYPes */
  void           **dat_rociRes;                              /* DATa buffers */
  sb2            **ind_rociRes;                         /* INDicator buffers */
  ub2            **len_rociRes;                            /* LENgth buffers */
  sb4             *siz_rociRes;                      /* buffer maximum SIZes */
  char            *lobbuf_rociRes;                        /* temp LOB BUFfer */
  size_t           loblen_rociRes;                 /* temp LOB buffer LENgth */

  /* -------------------------------- FETCH -------------------------------- */
  SEXP             name_rociRes;                      /* column NAMEs vector */
  SEXP             list_rociRes;                                /* data LIST */
  int              rows_rociRes;       /* current number of ROWS in the list */
  int              nrow_rociRes;     /* allocated Number of ROWs in the list */
  int              fchNum_rociRes;             /* NUMber of pre-FetCHed rows */
  int              fchBeg_rociRes;      /* pre-FetCH buffer BEGinning offset */
  int              fchEnd_rociRes;         /* pre-FetCH buffer ENDing offset */
  rociState        state_rociRes;                  /* query processing STATE */
  boolean          done_rociRes;                            /* DONE fetching */
  boolean          expand_rociRes;            /* adaptively EXPAND data list */
};
typedef struct rociRes rociRes;

/* ROCI internal TYPe */
struct rociITyp
{
  char   *name_rociITyp;                                        /* type NAME */
  ub1     rtyp_rociITyp;                                           /* R TYPe */
  ub2     etyp_rociITyp;                                    /* External TYPe */
  size_t  size_rociITyp;                                      /* buffer SIZE */
};
typedef struct rociITyp rociITyp;

/* ROCI R TYPe */
struct rociRTyp
{
  char      *name_rociRTyp;                                     /* type NAME */
  SEXPTYPE   styp_rociRTyp;                                     /* SEXP TYPe */
};
typedef struct rociRTyp rociRTyp;

/* ROCI CHECK error using DRiVer handle */
#define rociCheckDrv(drv, fun, pos, status) \
  rociCheck((drv), (fun), (pos), NULL, NULL, (status))

/* ROCI CHECK error using Connection handle */
#define rociCheckCon(con, fun, pos, status) \
  rociCheck((con)->drv_rociCon, (fun), (pos), &(con)->errNum_rociCon, \
            (con)->errMsg_rociCon, (status))

/* ROCI FATAL error */
#define rociFatal(fun, pos, info) \
  error("ROracle internal error [%s, %d, %d]", (fun), (pos), (info))

/* ROCI ERROR */
#define rociError(err) \
  error(err)

/* ROCI WARNING */
#define rociWarning(war) \
  warning(war)

/* ROCI Internal TYPe TABle */
static const rociITyp rociITypTab[] =
{
  {"",               0,          0,            0},
  {ROCI_VARCHAR2_NM, ROCI_R_CHR, SQLT_STR,     0},
  {ROCI_NUMBER_NM,   ROCI_R_NUM, SQLT_BDOUBLE, sizeof(double)},
  {ROCI_INTEGER_NM,  ROCI_R_INT, SQLT_INT,     sizeof(int)},
  {ROCI_LONG_NM,     0,          0,            0},
  {ROCI_DATE_NM,     ROCI_R_CHR, SQLT_STR,     0},
  {ROCI_RAW_NM,      ROCI_R_CHR, SQLT_STR,     0},
  {ROCI_LONG_RAW_NM, 0,          0,            0},
  {ROCI_ROWID_NM,    ROCI_R_CHR, SQLT_STR,     0},
  {ROCI_CHAR_NM,     ROCI_R_CHR, SQLT_STR,     0},
  {ROCI_BFLOAT_NM,   ROCI_R_NUM, SQLT_BDOUBLE, sizeof(double)},
  {ROCI_BDOUBLE_NM,  ROCI_R_NUM, SQLT_BDOUBLE, sizeof(double)},
  {ROCI_UDT_NM,      0,          0,            0},
  {ROCI_REF_NM,      0,          0,            0},
  {ROCI_CLOB_NM,     ROCI_R_CHR, SQLT_CLOB,    sizeof(OCILobLocator *)},
  {ROCI_BLOB_NM,     0,          0,            0},
  {ROCI_BFILE_NM,    0,          0,            0},
  {ROCI_TIME_NM,     ROCI_R_CHR, SQLT_STR,     0},
  {ROCI_TIME_TZ_NM,  ROCI_R_CHR, SQLT_STR,     0},
  {ROCI_INTER_YM_NM, ROCI_R_CHR, SQLT_STR,     0},
  {ROCI_INTER_DS_NM, ROCI_R_CHR, SQLT_STR,     0},
  {ROCI_TIME_LTZ_NM, ROCI_R_CHR, SQLT_STR,     0}
};

/* ROCI R TYPe TABle */
static const rociRTyp rociRTypTab[] =
{
  {"",            NILSXP},
  {ROCI_R_LOG_NM, LGLSXP},
  {ROCI_R_INT_NM, INTSXP},
  {ROCI_R_NUM_NM, REALSXP},
  {ROCI_R_CHR_NM, STRSXP},
  {ROCI_R_LST_NM, VECSXP}
};

#define rociTypeR(ityp) \
  rociITypTab[ityp].rtyp_rociITyp

#define rociTypeSXP(ityp) \
  rociRTypTab[rociITypTab[ityp].rtyp_rociITyp].styp_rociRTyp

#define rociNameInt(ityp) \
  rociITypTab[ityp].name_rociITyp

#define rociSizeExt(ityp) \
  rociITypTab[ityp].size_rociITyp

#define rociNameClass(ityp) \
  rociRTypTab[rociITypTab[ityp].rtyp_rociITyp].name_rociRTyp

/* version number */
#define ROCI_MAJOR_NUMVSN(v)       ((sword)(((v) >> 24) & 0x000000FF))

/* release number */
#define ROCI_MINOR_NUMRLS(v)       ((sword)(((v) >> 20) & 0x0000000F))

/* update number */
#define ROCI_UPDATE_NUMUPD(v)      ((sword)(((v) >> 12) & 0x000000FF))

/* port release number */
#define ROCI_PORT_REL_NUMPRL(v)    ((sword)(((v) >> 8) & 0x0000000F))

/* port update number */
#define ROCI_PORT_UPDATE_NUMPUP(v) ((sword)(((v) >> 0) & 0x000000FF))

/*---------------------------------------------------------------------------
                          EXPORT FUNCTION DECLARATIONS
  ---------------------------------------------------------------------------*/

SEXP rociDrvAlloc(void);
SEXP rociDrvInit(SEXP ptrDrv);
SEXP rociDrvInfo(SEXP ptrDrv);
SEXP rociDrvTerm(SEXP ptrDrv);

SEXP rociConInit(SEXP ptrDrv, SEXP params);
SEXP rociConError(SEXP ptrDrv, SEXP hdlCon);
SEXP rociConInfo(SEXP ptrDrv, SEXP hdlCon);
SEXP rociConTerm(SEXP ptrDrv, SEXP hdlCon);

SEXP rociResInit(SEXP ptrDrv, SEXP hdlCon, SEXP statement, SEXP data);
SEXP rociResExec(SEXP ptrDrv, SEXP hdlRes, SEXP data);
SEXP rociResFetch(SEXP ptrDrv, SEXP hdlRes, SEXP numRec);
SEXP rociResInfo(SEXP ptrDrv, SEXP hdlRes);
SEXP rociResTerm(SEXP ptrDrv, SEXP hdlRes);

/*---------------------------------------------------------------------------
                          STATIC FUNCTION DECLARATIONS 
  ---------------------------------------------------------------------------*/

static rociDrv * rociGetDrv(SEXP ptrDrv);
static SEXP rociDrvInfoConnections(rociDrv *drv);
static void rociDrvFree(rociDrv *drv);

static int rociGetConID(rociDrv *drv, SEXP hdlCon);
static int rociNewConID(rociDrv *drv);
static SEXP rociConInfoResults(rociDrv *drv, int conID);
static void rociConFree(rociCon *con);

static int rociGetResID(rociCon *con, SEXP hdlRes);
static int rociNewResID(rociCon *con);
static void rociResExecStmt(rociRes *res, SEXP data);
static void rociResExecQuery(rociRes *res, SEXP data);
static void rociResExecBind(rociRes *res, SEXP data);
static void rociResExecOnce(rociRes *res);
static void rociResBind(rociRes *res, SEXP data);
static void rociResBindCopy(rociRes *res, SEXP data, int beg, int end);
static void rociResDefine(rociRes *res);
static void rociResAlloc(rociRes *res, int nrow);
static void rociResRead(rociRes *res);
static void rociResExpand(rociRes *res);
static void rociResSplit(rociRes *res);
static void rociResAccum(rociRes *res);
static void rociResTrim(rociRes *res);
static void rociResDataFrame(rociRes *res);
static void rociResStateNext(rociRes *res);
static SEXP rociResInfoStmt(rociRes *res);
static SEXP rociResInfoFields(rociRes *res);
static void rociResFree(rociRes *res);

static ub1 rociTypeInt(ub2 ctyp);
static ub2 rociTypeExt(ub1 ityp);
static void rociCheck(rociDrv *drv, char *fun, int pos, sb4 *errNum,
                      text *errMsg, sword status);

/*---------------------------------------------------------------------------
                               EXPORT FUNCTIONS
  ---------------------------------------------------------------------------*/

/*****************************************************************************/
/*  (*) DRIVER FUNCTIONS                                                     */
/*****************************************************************************/

/* ----------------------------- rociDrvAlloc ------------------------------ */

SEXP rociDrvAlloc(void)
{
  SEXP  ptrDrv;

  /* make external pointer */
  ptrDrv = R_MakeExternalPtr(NULL, R_NilValue, R_NilValue);

  ROCI_TRACE("driver allocated");

  return ptrDrv;
} /* end rociDrvAlloc */

/* ------------------------------ rociDrvInit ------------------------------ */

SEXP rociDrvInit(SEXP ptrDrv)
{
  rociDrv  *drv = R_ExternalPtrAddr(ptrDrv);
  OCIEnv   *envhp = NULL;
  OCIError *errhp = NULL;
  sword    major; 
  sword    minor;
  sword    update;
  sword    patch;
  sword    port;

  /* check validity */
  if (drv)
  {
    if (drv->valid_rociDrv)                           /* already initialized */
      return R_NilValue;
    else                                      /* clean up partial allocation */
    {
      R_ClearExternalPtr(ptrDrv);
      rociDrvFree(drv);
    }
  }

  /* allocate ROCI driver */
  drv = Calloc((size_t)1, rociDrv);

  /* set external pointer */
  R_SetExternalPtrAddr(ptrDrv, drv);

  /* create OCI environment */
  rociCheckDrv(drv, "rociDrvInit", 1,
    OCIEnvCreate(&envhp, OCI_DEFAULT | OCI_OBJECT, NULL, NULL, NULL, NULL,
                 (size_t)0, (void **)NULL));
  drv->env_rociDrv = envhp;

  /* allocate error handle */
  rociCheckDrv(drv, "rociDrvInit", 2,
    OCIHandleAlloc(envhp, (void **)&errhp, OCI_HTYPE_ERROR,
                   (size_t)0, (void **)NULL));
  drv->err_rociDrv = errhp;

  /* get OCI client version */
  OCIClientVersion(&major, &minor, &update, &patch, &port);
  snprintf(drv->verClient_rociDrv, sizeof(drv->verClient_rociDrv),
           "%d.%d.%d.%d.%d", major, minor, update, patch, port);

  /* allocate connection vector */
  drv->con_rociDrv = Calloc((size_t)ROCI_CON_DEF, rociCon *);
  drv->max_rociDrv = ROCI_CON_DEF;

  /* mark as valid */
  drv->valid_rociDrv = TRUE;

  ROCI_TRACE("driver created");

  return R_NilValue;
} /* end rociDrvInit */

/* ------------------------------ rociDrvInfo ------------------------------ */

SEXP rociDrvInfo(SEXP ptrDrv)
{
  rociDrv  *drv = rociGetDrv(ptrDrv);
  char      version[64];
  SEXP      info;
  SEXP      names;

  /* allocate output list */
  PROTECT(info = allocVector(VECSXP, 6));

  /* allocate list element names */
  names = allocVector(STRSXP, 6);
  setAttrib(info, R_NamesSymbol, names);                   /* protects names */

  /* driverName */
  SET_VECTOR_ELT(info,  0, mkString(ROCI_DRV_NAME));
  SET_STRING_ELT(names, 0, mkChar("driverName"));

  /* driverVersion */
  snprintf(version, sizeof(version), "%d.%d-%d",
           ROCI_DRV_MAJOR, ROCI_DRV_MINOR, ROCI_DRV_UPDATE);
  SET_VECTOR_ELT(info,  1, mkString(version));
  SET_STRING_ELT(names, 1, mkChar("driverVersion"));

  /* clientVersion */
  SET_VECTOR_ELT(info,  2, mkString(drv->verClient_rociDrv));
  SET_STRING_ELT(names, 2, mkChar("clientVersion"));

  /* conTotal */
  SET_VECTOR_ELT(info,  3, ScalarInteger(drv->tot_rociDrv));
  SET_STRING_ELT(names, 3, mkChar("conTotal"));

  /* conOpen */
  SET_VECTOR_ELT(info,  4, ScalarInteger(drv->num_rociDrv));
  SET_STRING_ELT(names, 4, mkChar("conOpen"));

  /* connections */
  SET_VECTOR_ELT(info,  5, rociDrvInfoConnections(drv));
  SET_STRING_ELT(names, 5, mkChar("connections"));

  /* release info list */
  UNPROTECT(1);

  ROCI_TRACE("driver described");

  return info;
} /* end rociDrvInfo */

/* ------------------------------ rociDrvTerm ------------------------------ */

SEXP rociDrvTerm(SEXP ptrDrv)
{
  rociDrv  *drv = rociGetDrv(ptrDrv);

  /* clean up */
  R_ClearExternalPtr(ptrDrv);
  rociDrvFree(drv);

  ROCI_TRACE("driver removed");

  return R_NilValue;
} /* end rociDrvTerm */

/*****************************************************************************/
/*  (*) CONNECTION FUNCTIONS                                                 */
/*****************************************************************************/

/* ----------------------------- rociConCreate ----------------------------- */

SEXP rociConInit(SEXP ptrDrv, SEXP params)
{
  char         *user = (char *)CHAR(STRING_ELT(params, 0));
  char         *pass = (char *)CHAR(STRING_ELT(params, 1));
  char         *cstr = (char *)CHAR(STRING_ELT(params, 2));
  rociDrv      *drv = rociGetDrv(ptrDrv);
  OCIEnv       *envhp = drv->env_rociDrv;;
  OCIError     *errhp = drv->err_rociDrv;
  OCIAuthInfo  *authp = NULL;
  OCISvcCtx    *svchp = NULL;
  OCISession   *usrhp = NULL;;
  rociCon      *con;
  int           conID;
  SEXP          hdlCon;
  ub4           ver;
  /* is oracle wallet being used for authentication?
     for oracle wallet authentication, user needs to pass empty
     strings for username and password */
  boolean       wallet = (!strcmp(user, "") && !strcmp(pass, ""));
  /* get connection ID */
  conID = rociNewConID(drv);

  /* allocate ROCI connection */
  con = Calloc((size_t)1, rociCon);
  con->drv_rociCon = drv;

  /* add to the connections vector */
  drv->con_rociDrv[conID] = con;

  /* allocate authentication handle */
  rociCheckCon(con, "rociConInit", 1,
    OCIHandleAlloc(envhp, (void **)&authp, OCI_HTYPE_AUTHINFO,
                   (size_t)0, (void **)NULL));
  con->aut_rociCon = authp;

  /* set user name */
  con->user_rociCon = Calloc(strlen(user) + 1, char);
  memcpy(con->user_rociCon, user, strlen(user));
  rociCheckCon(con, "rociConInit", 2,
    OCIAttrSet(authp, OCI_HTYPE_AUTHINFO, (void *)user, strlen(user),
               OCI_ATTR_USERNAME, errhp));

  /* set password */
  rociCheckCon(con, "rociConInit", 3,
    OCIAttrSet(authp, OCI_HTYPE_AUTHINFO, (void *)pass, strlen(pass),
               OCI_ATTR_PASSWORD, errhp));

  /* set connection string */
  con->cstr_rociCon = Calloc(strlen(cstr) + 1, char);
  memcpy(con->cstr_rociCon, cstr, strlen(cstr));

  /* start user session */
  rociCheckCon(con, "rociConInit", 4,
    OCISessionGet(envhp, errhp, &svchp, authp, (OraText *)cstr, strlen(cstr),
                  NULL, 0, NULL, NULL, NULL, 
                  (wallet)? OCI_SESSGET_CREDEXT:OCI_DEFAULT));
  con->svc_rociCon = svchp;

  /* get session handle */
  rociCheckCon(con, "rociConInit", 5,
    OCIAttrGet(svchp, OCI_HTYPE_SVCCTX, (void *)&usrhp, NULL,  
               OCI_ATTR_SESSION, errhp));
  con->usr_rociCon = usrhp;

  /* get server version */
  rociCheckCon(con, "rociConInit", 6,
    OCIServerRelease(svchp, errhp, (OraText *)con->verServer_rociCon,
                     sizeof(con->verServer_rociCon), OCI_HTYPE_SVCCTX, &ver));
  snprintf(con->verServer_rociCon, sizeof(con->verServer_rociCon),
           "%d.%d.%d.%d.%d", ROCI_MAJOR_NUMVSN(ver), ROCI_MINOR_NUMRLS(ver),
           ROCI_UPDATE_NUMUPD(ver), ROCI_PORT_REL_NUMPRL(ver),
           ROCI_PORT_UPDATE_NUMPUP(ver));

  /* allocate result vector */
  con->res_rociCon = Calloc((size_t)ROCI_RES_DEF, rociRes *);
  con->max_rociCon = ROCI_RES_DEF;

  /* allocate connection handle */
  hdlCon = ScalarInteger(conID);

  /* mark connection as valid */
  con->valid_rociCon = TRUE;

  /* bump up the number of open/total connections */
  drv->num_rociDrv++;
  drv->tot_rociDrv++;

  ROCI_TRACE("connection created");

  return hdlCon;
} /* end rociConInit */

/* ----------------------------- rociConError ------------------------------ */

SEXP rociConError(SEXP ptrDrv, SEXP hdlCon)
{
  rociDrv  *drv = rociGetDrv(ptrDrv);
  int       conID = rociGetConID(drv, hdlCon);
  rociCon  *con = drv->con_rociDrv[conID];
  SEXP      info;
  SEXP      names;

  /* allocate output list */
  PROTECT(info = allocVector(VECSXP, 2));

  /* allocate list element names */
  names = allocVector(STRSXP, 2);
  setAttrib(info, R_NamesSymbol, names);                   /* protects names */

  /* errorNum */
  SET_VECTOR_ELT(info,  0, ScalarInteger((int)con->errNum_rociCon));
  SET_STRING_ELT(names, 0, mkChar("errorNum"));

  /* errorMsg */
  SET_VECTOR_ELT(info,  1, mkString((char *)con->errMsg_rociCon));
  SET_STRING_ELT(names, 1, mkChar("errorMsg"));

  /* release info list */
  UNPROTECT(1);

  /* reset connection error */
  con->errNum_rociCon = 0;
  con->errMsg_rociCon[0] = '\0';

  ROCI_TRACE("connection error");

  return info;
} /* end rociConError */

/* ------------------------------ rociConInfo ------------------------------ */

SEXP rociConInfo(SEXP ptrDrv, SEXP hdlCon)
{
  rociDrv  *drv = rociGetDrv(ptrDrv);
  int       conID = rociGetConID(drv, hdlCon);
  rociCon  *con = drv->con_rociDrv[conID];
  SEXP      info;
  SEXP      names;

  /* allocate output list */
  PROTECT(info = allocVector(VECSXP, 6));

  /* allocate list element names */
  names = allocVector(STRSXP, 6);
  setAttrib(info, R_NamesSymbol, names);                   /* protects names */

  /* username */
  SET_VECTOR_ELT(info,  0, mkString(con->user_rociCon));
  SET_STRING_ELT(names, 0, mkChar("username"));

  /* dbname */
  SET_VECTOR_ELT(info,  1, mkString(con->cstr_rociCon));
  SET_STRING_ELT(names, 1, mkChar("dbname"));

  /* serverVersion */
  SET_VECTOR_ELT(info,  2, mkString(con->verServer_rociCon));
  SET_STRING_ELT(names, 2, mkChar("serverVersion"));

  /* resTotal */
  SET_VECTOR_ELT(info,  3, ScalarInteger(con->tot_rociCon));
  SET_STRING_ELT(names, 3, mkChar("resTotal"));

  /* resOpen */
  SET_VECTOR_ELT(info,  4, ScalarInteger(con->num_rociCon));
  SET_STRING_ELT(names, 4, mkChar("resOpen"));

  /* results */
  SET_VECTOR_ELT(info,  5, rociConInfoResults(drv, conID));
  SET_STRING_ELT(names, 5, mkChar("results"));

  /* release info list */
  UNPROTECT(1);

  ROCI_TRACE("connection described");

  return info;
} /* end rociConInfo */

/* ------------------------------ rociConTerm ------------------------------ */

SEXP rociConTerm(SEXP ptrDrv, SEXP hdlCon)
{
  rociDrv  *drv = rociGetDrv(ptrDrv);
  int       conID = rociGetConID(drv, hdlCon);
  rociCon  *con = drv->con_rociDrv[conID];

  /* free connection */
  drv->con_rociDrv[conID] = NULL;
  drv->num_rociDrv--;
  rociConFree(con);

  ROCI_TRACE("connection removed");

  return R_NilValue;
} /* end rociConTerm */

/*****************************************************************************/
/*  (*) RESULT FUNCTIONS                                                     */
/*****************************************************************************/

/* ------------------------------ rociResInit ------------------------------ */

SEXP rociResInit(SEXP ptrDrv, SEXP hdlCon, SEXP statement, SEXP data)
{
  char         *qry = (char *)CHAR(STRING_ELT(statement, 0));
  rociDrv      *drv = rociGetDrv(ptrDrv);
  int           conID = rociGetConID(drv, hdlCon);
  rociCon      *con = drv->con_rociDrv[conID];
  OCIError     *errhp = drv->err_rociDrv;
  OCISvcCtx    *svchp = con->svc_rociCon;
  OCIStmt      *stmthp = NULL;
  ub2           stmtType;
  ub4           bcnt;
  rociRes      *res;
  int           resID;
  SEXP          hdlRes;

  /* get result ID */
  resID = rociNewResID(con);

  /* allocate ROCI result */
  res = Calloc((size_t)1, rociRes);
  res->con_rociRes = con;

  /* add to the result vector */
  con->res_rociCon[resID] = res;

  /* prepare statement */
  rociCheckCon(con, "rociResInit", 1,
    OCIStmtPrepare2(svchp, &stmthp, errhp,
                    (const OraText *)qry, strlen((char *)qry),
                    NULL, 0, OCI_NTV_SYNTAX, OCI_DEFAULT));
  res->stm_rociRes = stmthp;

  /* get statement type */
  rociCheckCon(con, "rociResInit", 2,
    OCIAttrGet(stmthp, OCI_HTYPE_STMT, (void *)&stmtType, NULL,
               OCI_ATTR_STMT_TYPE, errhp));
  res->styp_rociRes = stmtType;

  /* get number of binds */
  rociCheckCon(con, "rociResInit", 3,
    OCIAttrGet(stmthp, OCI_HTYPE_STMT, (void *)&bcnt, NULL,
               OCI_ATTR_BIND_COUNT, errhp));
  res->bcnt_rociRes = (int)bcnt;

  /* bind data */
  if (res->bcnt_rociRes)
    rociResBind(res, data);

  /* execute the statement */
  rociResExecStmt(res, data);

  /* define data */
  if (res->styp_rociRes == OCI_STMT_SELECT)
    rociResDefine(res);

  /* allocate result handle */
  hdlRes = allocVector(INTSXP, 2);
  INTEGER(hdlRes)[0] = conID;
  INTEGER(hdlRes)[1] = resID;

  /* mark result as valid */
  res->valid_rociRes = TRUE;

  /* bump up the number open/total results */
  con->num_rociCon++;
  con->tot_rociCon++;

  ROCI_TRACE("result created");

  return hdlRes;
} /* end rociResInit */

/* ------------------------------ rociResExec ------------------------------ */

SEXP rociResExec(SEXP ptrDrv, SEXP hdlRes, SEXP data)
{
  rociDrv  *drv = rociGetDrv(ptrDrv);
  int       conID = rociGetConID(drv, hdlRes);
  rociCon  *con = drv->con_rociDrv[conID];
  int       resID = rociGetResID(con, hdlRes);
  rociRes  *res = con->res_rociCon[resID];

  /* execute the statement */
  rociResExecStmt(res, data);

  ROCI_TRACE("result executed");

  return R_NilValue;
} /* end rociResExec */

/* ----------------------------- rociResFetch ------------------------------ */

SEXP rociResFetch(SEXP ptrDrv, SEXP hdlRes, SEXP numRec)
{
  rociDrv  *drv = rociGetDrv(ptrDrv);
  int       conID = rociGetConID(drv, hdlRes);
  rociCon  *con = drv->con_rociDrv[conID];
  int       resID = rociGetResID(con, hdlRes);
  rociRes  *res = con->res_rociCon[resID];
  int       nrow = INTEGER(numRec)[0];
  boolean   hasOutput = FALSE;

  /* setup adaptive fetching */
  if (nrow <= 0)
  {
    nrow = ROCI_BULK_READ;
    res->expand_rociRes = TRUE;
  }

  /* allocate output data frame */
  rociResAlloc(res, nrow);

  /* state machine */
  while (!hasOutput)
  {
    switch (res->state_rociRes)
    {
    case FETCH_rociState:
      rociResRead(res);
      break;
    case SPLIT_rociState:
      rociResExpand(res);
      rociResSplit(res);
      break;
    case ACCUM_rociState:
      rociResAccum(res);
      break;
    case OUTPUT_rociState: 
      rociResTrim(res);
      rociResDataFrame(res);
      hasOutput = TRUE;
      break;
    default:
      rociFatal("rociResFetch", 1, res->state_rociRes);
      break;
    }
    rociResStateNext(res);
  }

  /* release output data frame and column names vector */
  UNPROTECT(2);

  ROCI_TRACE("result fetched");

  return res->list_rociRes;
} /* end rociResFetch */

/* ------------------------------ rociResInfo ------------------------------ */

SEXP rociResInfo(SEXP ptrDrv, SEXP hdlRes)
{
  rociDrv  *drv = rociGetDrv(ptrDrv);
  int       conID = rociGetConID(drv, hdlRes);
  rociCon  *con = drv->con_rociDrv[conID];
  int       resID = rociGetResID(con, hdlRes);
  rociRes  *res = con->res_rociCon[resID];
  SEXP      info;
  SEXP      names;

  /* allocate output list */
  PROTECT(info = allocVector(VECSXP, 6));

  /* allocate list element names */
  names = allocVector(STRSXP, 6);
  setAttrib(info, R_NamesSymbol, names);                   /* protects names */

  /* statement */
  SET_VECTOR_ELT(info,  0, rociResInfoStmt(res));
  SET_STRING_ELT(names, 0, mkChar("statement"));

  /* isSelect */
  SET_VECTOR_ELT(info,  1,
                 ScalarLogical(res->styp_rociRes == OCI_STMT_SELECT));
  SET_STRING_ELT(names, 1, mkChar("isSelect"));

  /* rowsAffected */
  SET_VECTOR_ELT(info,  2, ScalarInteger(0));
  SET_STRING_ELT(names, 2, mkChar("rowsAffected"));

  /* rowCount */
  SET_VECTOR_ELT(info,  3, ScalarInteger(0));
  SET_STRING_ELT(names, 3, mkChar("rowCount"));

  /* completed */
  SET_VECTOR_ELT(info,  4,
                 ScalarLogical(res->state_rociRes == CLOSE_rociState));
  SET_STRING_ELT(names, 4, mkChar("completed"));

  /* fields */
  SET_VECTOR_ELT(info,  5, rociResInfoFields(res));
  SET_STRING_ELT(names, 5, mkChar("fields"));

  /* release info list */
  UNPROTECT(1);

  ROCI_TRACE("result described");

  return info;
} /* end rociResInfo */

/* ------------------------------- rociResTerm ----------------------------- */

SEXP rociResTerm(SEXP ptrDrv, SEXP hdlRes)
{
  rociDrv  *drv = rociGetDrv(ptrDrv);
  int       conID = rociGetConID(drv, hdlRes);
  rociCon  *con = drv->con_rociDrv[conID];
  int       resID = rociGetResID(con, hdlRes);
  rociRes  *res = con->res_rociCon[resID];

  /* free connection */
  con->res_rociCon[resID] = NULL;
  con->num_rociCon--;
  rociResFree(res);

  ROCI_TRACE("result removed");

  return R_NilValue;
} /* end rociResTerm */

/*---------------------------------------------------------------------------
                              INTERNAL FUNCTIONS
  ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
                               STATIC FUNCTIONS
  ---------------------------------------------------------------------------*/

/*****************************************************************************/
/*  (*) DRIVER FUNCTIONS                                                     */
/*****************************************************************************/

/* ------------------------------- rociGetDrv ------------------------------ */

static rociDrv * rociGetDrv(SEXP ptrDrv)
{
  rociDrv  *drv = R_ExternalPtrAddr(ptrDrv);

  /* check validity */
  if (!drv || !drv->valid_rociDrv)
    rociError("invalid driver");

  return drv;
} /* rociGetDrv */

/* ------------------------ rociDrvInfoConnections ------------------------- */

static SEXP rociDrvInfoConnections(rociDrv *drv)
{
  SEXP  vec;
  int   conID;
  int   vecID = 0;

  /* allocate output vector */
  vec = allocVector(INTSXP, drv->num_rociDrv);

  /* set valid connection IDs */ 
  for (conID = 0; conID < drv->max_rociDrv; conID++)
    if (drv->con_rociDrv[conID] && drv->con_rociDrv[conID]->valid_rociCon)
      INTEGER(vec)[vecID++] = conID;

  return vec;
} /* end rociDrvInfoConnections */

/* ------------------------------ rociDrvFree ------------------------------ */

static void rociDrvFree(rociDrv *drv)
{
  int           conID;

  /* clean up connections */
  if (drv->con_rociDrv)
  {
    for (conID = 0; conID < drv->max_rociDrv; conID++)
      if (drv->con_rociDrv[conID])
        rociConFree(drv->con_rociDrv[conID]);

    /* free connection vector */
    Free(drv->con_rociDrv);
  }

  /* free environment handle and all it's children */
  if (drv->env_rociDrv)
    rociCheckDrv(drv, "rociDrvFree", 1,
      OCIHandleFree(drv->env_rociDrv, OCI_HTYPE_ENV));

  /* free ROCI driver */
  Free(drv);

  ROCI_TRACE("driver freed");
} /* end rociDrvFree */

/*****************************************************************************/
/*  (*) CONNECTION FUNCTIONS                                                 */
/*****************************************************************************/

/* ------------------------------ rociGetConID ----------------------------- */

static int rociGetConID(rociDrv *drv, SEXP hdlCon)
{
  int  conID = INTEGER(hdlCon)[0];

  /* check validity */
  if (conID >= drv->max_rociDrv || !drv->con_rociDrv[conID] ||
      !drv->con_rociDrv[conID]->valid_rociCon)
    rociError("invalid connection");

  return conID;
} /* rociGetConID */

/* ------------------------------ rociNewConID ----------------------------- */

static int rociNewConID(rociDrv *drv)
{
  rociCon **con;
  int       conID;

  /* check connection validity */
  for (conID = 0; conID < drv->max_rociDrv; conID++)
    if (drv->con_rociDrv[conID] && !drv->con_rociDrv[conID]->valid_rociCon)
    {
      rociConFree(drv->con_rociDrv[conID]);
      drv->con_rociDrv[conID] = NULL;
    }

  /* find next available connection ID */
  for (conID = 0; conID < drv->max_rociDrv; conID++)
    if (!drv->con_rociDrv[conID])
      break;

  /* check vector size */
  if (conID == drv->max_rociDrv)
  {
    con = Calloc((size_t)(2*drv->max_rociDrv), rociCon *);
    memcpy(con, drv->con_rociDrv, (size_t)drv->max_rociDrv*sizeof(rociCon *));
    Free(drv->con_rociDrv);
    drv->con_rociDrv = con;
    drv->max_rociDrv = 2*drv->max_rociDrv;
  }

  return conID;
} /* end rociNewConID */

/* -------------------------- rociConInfoResults --------------------------- */

static SEXP rociConInfoResults(rociDrv *drv, int conID)
{
  rociCon  *con = drv->con_rociDrv[conID];
  SEXP      list;
  SEXP      vec;
  int       resID;
  int       lstID = 0;

  /* allocate output list */
  PROTECT(list = allocVector(VECSXP, con->num_rociCon));

  /* set valid result IDs */ 
  for (resID = 0; resID < con->max_rociCon; resID++)
    if (con->res_rociCon[resID] && con->res_rociCon[resID]->valid_rociRes)
    {
      vec = allocVector(INTSXP, 2);
      INTEGER(vec)[0] = conID;
      INTEGER(vec)[1] = resID;
      SET_VECTOR_ELT(list, lstID++, vec);                    /* protects vec */
    }

  /* release output list */
  UNPROTECT(1);

  return list;
} /* end rociConInfoResults */

/* ------------------------------ rociConFree ------------------------------ */

static void rociConFree(rociCon *con)
{
  rociDrv      *drv = con->drv_rociCon;
  OCIError     *errhp = drv->err_rociDrv;
  int           resID;

  /* clean up results */
  if (con->res_rociCon)
  {
    for (resID = 0; resID < con->max_rociCon; resID++)
      if (con->res_rociCon[resID])
        rociResFree(con->res_rociCon[resID]);

    /* free result vector */
    Free(con->res_rociCon);
  }

  /* release user session */
  if (con->svc_rociCon)
    rociCheckCon(con, "rociConFree", 1,
      OCISessionRelease(con->svc_rociCon, errhp, NULL, 0, OCI_DEFAULT));

  /* free authentication handle */
  if (con->aut_rociCon)
    rociCheckCon(con, "rociConFree", 2,
      OCIHandleFree(con->aut_rociCon, OCI_HTYPE_AUTHINFO));

  /* free user name */
  if (con->user_rociCon)
    Free(con->user_rociCon);

  /* free connect string */
  if (con->cstr_rociCon)
    Free(con->cstr_rociCon);

  /* free ROCI conection */
  Free(con);

  ROCI_TRACE("connection freed");
} /* end rociConFree */

/*****************************************************************************/
/*  (*) STATEMENT FUNCTIONS                                                  */
/*****************************************************************************/

/* ------------------------------ rociGetResID ----------------------------- */

static int rociGetResID(rociCon *con, SEXP hdlRes)
{
  int  resID = INTEGER(hdlRes)[1];

  /* check validity */
  if (resID >= con->max_rociCon || !con->res_rociCon[resID] ||
      !con->res_rociCon[resID]->valid_rociRes)
    rociError("invalid result");

  return resID;
} /* rociGetResID */

/* ------------------------------ rociNewResID ----------------------------- */

static int rociNewResID(rociCon *con)
{
  rociRes **res;
  int       resID;

  /* check result validity */
  for (resID = 0; resID < con->max_rociCon; resID++)
    if (con->res_rociCon[resID] && !con->res_rociCon[resID]->valid_rociRes)
    {
      rociResFree(con->res_rociCon[resID]);
      con->res_rociCon[resID] = NULL;
    }

  /* find next available result ID */
  for (resID = 0; resID < con->max_rociCon; resID++)
    if (!con->res_rociCon[resID])
      break;

  /* check vector size */
  if (resID == con->max_rociCon)
  {
    res = Calloc((size_t)(2*con->max_rociCon), rociRes *);
    memcpy(res, con->res_rociCon, (size_t)con->max_rociCon*sizeof(rociRes *));
    Free(con->res_rociCon);
    con->res_rociCon = res;
    con->max_rociCon = 2*con->max_rociCon;
  }

  return resID;
} /* end rociNewResID */

/* ---------------------------- rociResExecStmt ---------------------------- */

static void rociResExecStmt(rociRes *res, SEXP data)
{
  switch (res->styp_rociRes)
  {
  case OCI_STMT_SELECT:
    rociResExecQuery(res, data);
    break;
  default:
    if (res->bcnt_rociRes)
      rociResExecBind(res, data);
    else
      rociResExecOnce(res);
    break;
  }
} /* end rociResExecStmt */

/* ---------------------------- rociResExecQuery --------------------------- */

static void rociResExecQuery(rociRes *res, SEXP data)
{
  rociCon      *con = res->con_rociRes;
  rociDrv      *drv = con->drv_rociCon;
  OCIError     *errhp = drv->err_rociDrv;
  OCISvcCtx    *svchp = con->svc_rociCon;
  OCIStmt      *stmthp = res->stm_rociRes;

  /* copy bind data */
  if (res->bmax_rociRes > 1)
    rociError("bind data has too many rows");
  else
    rociResBindCopy(res, data, 0, 1);

  /* execute the statement */
  rociCheckCon(con, "rociResExecQuery", 1,
    OCIStmtExecute(svchp, stmthp, errhp, 0, 0, NULL, NULL, OCI_DEFAULT));

  /* set state */
  res->state_rociRes = FETCH_rociState;
} /* end rociResExecQuery */

/* ---------------------------- rociResExecBind ---------------------------- */

static void rociResExecBind(rociRes *res, SEXP data)
{
  rociCon      *con = res->con_rociRes;
  rociDrv      *drv = con->drv_rociCon;
  OCIError     *errhp = drv->err_rociDrv;
  OCISvcCtx    *svchp = con->svc_rociCon;
  OCIStmt      *stmthp = res->stm_rociRes;
  int           beg = 0;
  int           end;
  int           iters;
  int           rows;

  /* execute the statement */
  rows = LENGTH(VECTOR_ELT(data, 0));
  while (rows)
  {
    /* get number of rows to process */
    iters = rows > res->bmax_rociRes ? res->bmax_rociRes : rows;

    /* copy bind data */
    end = beg + iters;
    rociResBindCopy(res, data, beg, end);
    beg = end;

    /* execute the statement */
    rociCheckCon(con, "rociResExecBind", 1,
      OCIStmtExecute(svchp, stmthp, errhp, (ub4)iters, 0, NULL, NULL,
                     OCI_DEFAULT));

    /* next chunk */
    rows -= iters;
  }

  /* set state */
  res->state_rociRes = CLOSE_rociState;
} /* end rociResExecBind */

/* ---------------------------- rociResExecOnce ---------------------------- */

static void rociResExecOnce(rociRes *res)
{
  rociCon      *con = res->con_rociRes;
  rociDrv      *drv = con->drv_rociCon;
  OCIError     *errhp = drv->err_rociDrv;
  OCISvcCtx    *svchp = con->svc_rociCon;
  OCIStmt      *stmthp = res->stm_rociRes;

  /* execute the statement */
  rociCheckCon(con, "rociResExecOnce", 1,
    OCIStmtExecute(svchp, stmthp, errhp, 1, 0, NULL, NULL, OCI_DEFAULT));

  /* set state */
  res->state_rociRes = CLOSE_rociState;
} /* end rociResExecOnce */

/* ------------------------------ rociResBind ------------------------------ */

static void rociResBind(rociRes *res, SEXP data)
{
  rociCon      *con = res->con_rociRes;
  rociDrv      *drv = con->drv_rociCon;
  OCIError     *errhp = drv->err_rociDrv;
  OCIStmt      *stmthp = res->stm_rociRes;
  int           bid;

  /* validate data */
  if (isNull(data) || LENGTH(data) != res->bcnt_rociRes)
    rociError("data does not match binds");

  /* set bind buffer size */
  res->bmax_rociRes = LENGTH(VECTOR_ELT(data, 0));
  if (!res->bmax_rociRes)
    rociError("bind data is empty");
  else if (res->bmax_rociRes > ROCI_BULK_WRITE)
    res->bmax_rociRes = ROCI_BULK_WRITE;

  /* allocate bind vectors */
  res->bdat_rociRes = Calloc((size_t)res->bcnt_rociRes, void *);
  res->bind_rociRes = Calloc((size_t)res->bcnt_rociRes, sb2 *);
  res->bsiz_rociRes = Calloc((size_t)res->bcnt_rociRes, ub2);
  res->btyp_rociRes = Calloc((size_t)res->bcnt_rociRes, ub2);

  /* bind data */
  for (bid = 0; bid < res->bcnt_rociRes; bid++)
  {
    SEXP      vec = VECTOR_ELT(data, bid);
    OCIBind  *bndp = NULL;

    /* set bind parameters */
    if (isReal(vec))
    {
      res->btyp_rociRes[bid] = SQLT_BDOUBLE;
      res->bsiz_rociRes[bid] = (ub2)sizeof(double);
    }
    else if (isInteger(vec) || isLogical(vec))
    {
      res->btyp_rociRes[bid] = SQLT_INT;
      res->bsiz_rociRes[bid] = (ub2)sizeof(int);
    }
    else if (isString(vec))
    {
      res->btyp_rociRes[bid] = SQLT_STR;
      res->bsiz_rociRes[bid] = (ub2)(4000 + 1);
    }
    else
      rociError("unsupported bind type");

    /* allocate bind buffers */
    res->bdat_rociRes[bid] =
      Calloc((size_t)(res->bmax_rociRes * res->bsiz_rociRes[bid]), ub1);
    res->bind_rociRes[bid] = Calloc((size_t)res->bmax_rociRes, sb2);

    /* bind data buffers */
    rociCheckCon(con, "rociResBind", 1,
      OCIBindByPos(stmthp, &bndp, errhp, (ub4)(bid + 1),
                   (void *)res->bdat_rociRes[bid], (sb4)res->bsiz_rociRes[bid],
                   res->btyp_rociRes[bid], res->bind_rociRes[bid],
                   NULL, NULL, (ub4)0, NULL, OCI_DEFAULT));
  }
} /* end rociResBind */

/* ---------------------------- rociResBindCopy ---------------------------- */

static void rociResBindCopy(rociRes *res, SEXP data, int beg, int end)
{
  int  bid;
  int  i;

  for (bid = 0; bid < res->bcnt_rociRes; bid++)
  {
    SEXP  elem = VECTOR_ELT(data, bid);
    ub1  *dat = (ub1 *)res->bdat_rociRes[bid];
    sb2  *ind = res->bind_rociRes[bid];

    /* copy vector */
    for (i = beg; i < end; i++)
    {
      *ind = OCI_IND_NOTNULL;
      if (isReal(elem))
      {
        if (ISNA(REAL(elem)[i]))
          *ind = OCI_IND_NULL;
        else
          *(double *)dat = REAL(elem)[i];
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
          size_t      len = strlen(str);

          memcpy(dat, str, len);
          dat[len] = (ub1)0;
        }
      }

      /* next row */
      dat += res->bsiz_rociRes[bid];
      ind++;
    }
  }
} /* end rociResBindCopy */

/* ----------------------------- rociResDefine ----------------------------- */

static void rociResDefine(rociRes *res)
{
  rociCon      *con = res->con_rociRes;
  rociDrv      *drv = con->drv_rociCon;
  OCIEnv       *envhp = drv->env_rociDrv;
  OCIError     *errhp = drv->err_rociDrv;
  OCISvcCtx    *svchp = con->svc_rociCon;
  OCIStmt      *stmthp = res->stm_rociRes;
  ub4           ncol;
  ub2           collen;
  sb2           colpre;
  sb1           colsca;
  ub2           ctyp;
  ub2           etyp;
  size_t        siz;
  int           cid;
  int           fcur;

  /* get number of columns */
  rociCheckCon(con, "rociResDefine", 1,
    OCIAttrGet(stmthp, OCI_HTYPE_STMT, &ncol, NULL,
               OCI_ATTR_PARAM_COUNT, errhp));
  res->ncol_rociRes = (int)ncol;

  /* allocate column vectors */
  res->typ_rociRes = Calloc((size_t)res->ncol_rociRes, ub1);
  res->dat_rociRes = Calloc((size_t)res->ncol_rociRes, void *);
  res->ind_rociRes = Calloc((size_t)res->ncol_rociRes, sb2 *);
  res->len_rociRes = Calloc((size_t)res->ncol_rociRes, ub2 *);
  res->siz_rociRes = Calloc((size_t)res->ncol_rociRes, sb4);

  /* describe columns */
  for (cid = 0; cid < res->ncol_rociRes; cid++)
  {
    OCIDefine *defp = NULL;                                 /* define handle */
    OCIParam  *colhd = NULL;                                /* column handle */

    /* get column parameters */
    rociCheckCon(con, "rociResDefine", 2,
      OCIParamGet(stmthp, OCI_HTYPE_STMT, errhp, (void **)&colhd,
                  (ub4)(cid + 1)));

    /* get column type */
    rociCheckCon(con, "rociResDefine", 3,
      OCIAttrGet(colhd, OCI_DTYPE_PARAM, &ctyp, NULL,
                 OCI_ATTR_DATA_TYPE, errhp));

    /* get internal type */
    res->typ_rociRes[cid] = rociTypeInt(ctyp);
    if (res->typ_rociRes[cid] == ROCI_NUMBER)
    {
      /* get precision */
      rociCheckCon(con, "rociResDefine", 4,
        OCIAttrGet(colhd, OCI_DTYPE_PARAM, &colpre, NULL,
                   OCI_ATTR_PRECISION, errhp));

      /* get scale */
      rociCheckCon(con, "rociResDefine", 5,
        OCIAttrGet(colhd, OCI_DTYPE_PARAM, &colsca, NULL,
                   OCI_ATTR_SCALE, errhp));

      if (colpre > 0 && colpre < 10 && colsca == 0)
        res->typ_rociRes[cid] = ROCI_INTEGER;
    }

    /* get external type */
    etyp = rociTypeExt(res->typ_rociRes[cid]);

    /* get buffer length */
    if (etyp == SQLT_BDOUBLE)
      siz = sizeof(double);
    else if (etyp == SQLT_INT)
      siz = sizeof(int);
    else if (etyp == SQLT_CLOB)
      siz = sizeof(OCILobLocator *);
    else
    {
      rociCheckCon(con, "rociResDefine", 6,
        OCIAttrGet(colhd, OCI_DTYPE_PARAM, &collen, NULL,
                   OCI_ATTR_DISP_SIZE, errhp));
      siz = (size_t)(collen + 1);              /* adjust for NULL terminator */
    }
    res->siz_rociRes[cid] = (sb4)siz;

    /* allocate define buffers */
    res->dat_rociRes[cid] = Calloc((size_t)(ROCI_BULK_READ * siz), ub1);
    res->ind_rociRes[cid] = Calloc((size_t)ROCI_BULK_READ, sb2);
    res->len_rociRes[cid] = Calloc((size_t)ROCI_BULK_READ, ub2);

    /* allocate LOB locators */
    if (etyp == SQLT_CLOB)
    {
      ub1 *dat = (ub1 *)res->dat_rociRes[cid];

      for (fcur = 0; fcur < ROCI_BULK_READ; fcur++)
      {
        OCILobLocator **lob = (OCILobLocator **)(dat + fcur*siz);

        rociCheckCon(con, "rociResDefine", 7,
          OCIDescriptorAlloc(envhp, (void **)lob, OCI_DTYPE_LOB, 0, NULL));
      }
    }

    /* define fetch buffers */
    rociCheckCon(con, "rociResDefine", 8,
      OCIDefineByPos(stmthp, &defp, errhp, (ub4)(cid + 1),
                     res->dat_rociRes[cid], res->siz_rociRes[cid], etyp,
                     res->ind_rociRes[cid], res->len_rociRes[cid],
                     NULL, OCI_DEFAULT));
  }
} /* end rociResDefine */

/* ----------------------------- rociResAlloc ------------------------------ */

static void rociResAlloc(rociRes *res, int nrow)
{
  rociCon      *con = res->con_rociRes;
  rociDrv      *drv = con->drv_rociCon;
  OCIError     *errhp = drv->err_rociDrv;
  OCIStmt      *stmthp = res->stm_rociRes;
  int           ncol = res->ncol_rociRes;
  OCIParam     *par;
  ub4           len;
  oratext      *buf;
  int           cid;

  /* allocates column list and names vector */
  PROTECT(res->list_rociRes = allocVector(VECSXP, ncol));
  PROTECT(res->name_rociRes = allocVector(STRSXP, ncol));

  /* allocate column vectors */
  for (cid = 0; cid < ncol; cid++)
  {
    /* allocate column vector */
    SET_VECTOR_ELT(res->list_rociRes, cid,
                   allocVector(rociTypeSXP(res->typ_rociRes[cid]), nrow));

    /* get column parameters */
    rociCheckCon(con, "rociResAlloc", 1,
      OCIParamGet(stmthp, OCI_HTYPE_STMT, errhp, (void **)&par, (ub4)(cid+1)));

    /* get column name */
    rociCheckCon(con, "rociResAlloc", 2,
      OCIAttrGet(par, OCI_DTYPE_PARAM, &buf, &len, OCI_ATTR_NAME, errhp));

    /* set column name */
    SET_STRING_ELT(res->name_rociRes, cid,
                   mkCharLen((const char *)buf, (int)len));
  }

  /* set names attribute */
  setAttrib(res->list_rociRes, R_NamesSymbol, res->name_rociRes);

  /* set the state */
  res->nrow_rociRes = nrow;
  res->rows_rociRes = 0;
} /* end rociResAlloc */

/* ----------------------------- rociResRead ------------------------------- */

static void rociResRead(rociRes *res)
{
  rociCon   *con = res->con_rociRes;
  rociDrv   *drv = con->drv_rociCon;
  OCIError  *errhp = drv->err_rociDrv;
  OCIStmt   *stmthp = res->stm_rociRes;
  ub4        fcnt;                                            /* Fetch CouNT */
  sword      status;

  /* fetch data */
  status = OCIStmtFetch2(stmthp, errhp, ROCI_BULK_READ, OCI_FETCH_NEXT, 0,
                         OCI_DEFAULT);
  if (status == OCI_NO_DATA)                                /* done fetching */
    res->done_rociRes = TRUE;
  else
    rociCheckCon(con, "rociResRead", 1, status);

  /* find actual number of rows fetched */
  rociCheckCon(con, "rociResRead", 2,
    OCIAttrGet(stmthp, OCI_HTYPE_STMT, &fcnt, NULL,
               OCI_ATTR_ROWS_FETCHED, errhp));

  /* set state */
  res->fchNum_rociRes = (int)fcnt;
  res->fchBeg_rociRes = 0;
} /* end rociResRead */

/* ----------------------------- rociResExpand ----------------------------- */

static void rociResExpand(rociRes *res)
{
  int  nrow = res->rows_rociRes + res->fchNum_rociRes - res->fchBeg_rociRes;
  int  ncol = res->ncol_rociRes;
  int  cid;

  if (!res->expand_rociRes || res->nrow_rociRes > nrow)
    return;

  /* compute new size */
  while (res->nrow_rociRes <= nrow)
    res->nrow_rociRes *= 2;

  /* expand column vectors */
  for (cid = 0; cid < ncol; cid++)
  {
    SEXP vec = VECTOR_ELT(res->list_rociRes, cid);
    vec = lengthgets(vec, res->nrow_rociRes);
    SET_VECTOR_ELT(res->list_rociRes, cid, vec);             /* protects vec */
  }
} /* end rociResExpand */

/* ----------------------------- rociResSplit ------------------------------ */

static void rociResSplit(rociRes *res)
{
  int fchEnd;

  /* set position after the end of the chunk */
  fchEnd = res->fchBeg_rociRes + res->nrow_rociRes - res->rows_rociRes;

  /* adjust based on the buffer size */
  if (fchEnd > res->fchNum_rociRes)
    res->fchEnd_rociRes = res->fchNum_rociRes;
  else
    res->fchEnd_rociRes = fchEnd;
} /* end rociResSplit */

/* ----------------------------- rociResAccum ------------------------------ */

static void rociResAccum(rociRes *res)
{
  rociCon       *con = res->con_rociRes;
  rociDrv       *drv = con->drv_rociCon;
  OCIEnv        *envhp = drv->env_rociDrv;;
  OCIError      *errhp = drv->err_rociDrv;
  OCISvcCtx     *svchp = con->svc_rociCon;
  SEXP           list = res->list_rociRes;
  int            rows = res->rows_rociRes;
  int            fbeg = res->fchBeg_rociRes;
  int            fend = res->fchEnd_rociRes;
  OCILobLocator *lob_loc;
  oraub8         lob_len;
  char          *lob_buf;
  sb4            bytesz;
  int            fcur;
  int            lcur;
  int            cid;

  /* get character maximum byte size */
  rociCheckCon(con, "rociResAccum", 1,
    OCINlsNumericInfoGet(envhp, errhp, &bytesz, OCI_NLS_CHARSET_MAXBYTESZ));

  /* accumulate data */
  for (cid = 0; cid < res->ncol_rociRes; cid++)
  {
    ub1  *dat = (ub1 *)res->dat_rociRes[cid] + (fbeg * res->siz_rociRes[cid]);

    for (fcur = fbeg, lcur = rows; fcur < fend; fcur++, lcur++)
    {
      SEXP  vec = VECTOR_ELT(list, cid);
      ub2   etyp = rociTypeExt(res->typ_rociRes[cid]);
      ub1   rtyp = rociTypeR(res->typ_rociRes[cid]);

      /* copy data */
      if (res->ind_rociRes[cid][fcur] == OCI_IND_NULL)               /* NULL */
      {
        switch(rtyp)
        {
        case ROCI_R_INT:
          INTEGER(vec)[lcur] = NA_INTEGER;
          break;
        case ROCI_R_NUM:
          REAL(vec)[lcur] = NA_REAL;
          break;
        case ROCI_R_CHR:
          SET_STRING_ELT(vec, lcur, NA_STRING);
          break;
        default:
          rociFatal("rociResAccum", 1, rtyp);
          break;
        }
      }
      else                                                       /* NOT NULL */
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
          SET_STRING_ELT(vec, lcur, mkChar((char *)dat));
          break;
        case SQLT_CLOB:
          /* get LOB locator */
          lob_loc = *(OCILobLocator **)dat;

          /* get LOB length */
          rociCheckCon(con, "rociResAccum", 2,
            OCILobGetLength2(svchp, errhp, lob_loc, &lob_len));

          /* compute buffer size in bytes */
          lob_len = lob_len * (oraub8)bytesz;

          /* allocate memory */
          if (!res->lobbuf_rociRes || res->loblen_rociRes < (size_t)lob_len)
          {
            if (res->lobbuf_rociRes)
              Free(res->lobbuf_rociRes);

            res->loblen_rociRes = (size_t)(lob_len / ROCI_LOB_RND + 1);
            res->loblen_rociRes = (size_t)(res->loblen_rociRes * ROCI_LOB_RND);
            res->lobbuf_rociRes = Calloc(res->loblen_rociRes, char);
          }
          lob_buf = res->lobbuf_rociRes;

          /* read LOB data */
          rociCheckCon(con, "rociResAccum", 3,
            OCILobRead2(svchp, errhp, lob_loc, &lob_len, NULL, 1,
                        lob_buf, lob_len, OCI_ONE_PIECE, NULL,
                        (OCICallbackLobRead2)0, 0, SQLCS_IMPLICIT));

          /* make character element */
          SET_STRING_ELT(vec, lcur,
                         mkCharLen((const char *)lob_buf, (int)lob_len));
          break;
        default:
          rociFatal("rociResAccum", 2, etyp);
          break;
        }
      }
      /* next row */
      dat += res->siz_rociRes[cid];
    }
  }

  /* set state */
  res->rows_rociRes  += res->fchEnd_rociRes - res->fchBeg_rociRes;
  res->fchBeg_rociRes = res->fchEnd_rociRes;
} /* end rociResAccum */

/* ------------------------------ rociResTrim ------------------------------ */

static void rociResTrim(rociRes *res)
{
  int  ncol = res->ncol_rociRes;
  int  cid;

  /* nothing to trim */
  if (res->rows_rociRes == res->nrow_rociRes)
    return;

  /* trim column vectors to the actual size */
  for (cid = 0; cid < ncol; cid++)
  {
    SEXP vec = VECTOR_ELT(res->list_rociRes, cid);
    vec = lengthgets(vec, res->rows_rociRes);
    SET_VECTOR_ELT(res->list_rociRes, cid, vec);             /* protects vec */
  }
} /* end rociResTrim */

/* --------------------------- rociResDataFrame ---------------------------- */

static void rociResDataFrame(rociRes *res)
{
  SEXP row_names;

  /* make input data list a data.frame */
  PROTECT(row_names = allocVector(INTSXP, 2));
  INTEGER(row_names)[0] = NA_INTEGER;
  INTEGER(row_names)[1] = LENGTH(VECTOR_ELT(res->list_rociRes, 0));
  setAttrib(res->list_rociRes, R_RowNamesSymbol, row_names);
  setAttrib(res->list_rociRes, R_ClassSymbol, mkString("data.frame"));
  UNPROTECT(1);
} /* end rociResDataFrame */

/* --------------------------- rociResStateNext ---------------------------- */

static void rociResStateNext(rociRes *res)
{
  switch(res->state_rociRes)
  {
  case FETCH_rociState:
    res->state_rociRes = SPLIT_rociState;
    break;
  case SPLIT_rociState:
    res->state_rociRes = ACCUM_rociState;
    break;
  case ACCUM_rociState:
    if (res->rows_rociRes < res->nrow_rociRes && !res->done_rociRes)
      res->state_rociRes = FETCH_rociState;
    else
      res->state_rociRes = OUTPUT_rociState;
    break;
  case OUTPUT_rociState:
    if (res->fchBeg_rociRes < res->fchNum_rociRes || !res->done_rociRes)
      res->state_rociRes = SPLIT_rociState;
    else
      res->state_rociRes = CLOSE_rociState;
    break;
  default:
    rociFatal("rociStateNext", 1, res->state_rociRes);
    break;
  }
} /* end rociResStateNext */

/* ---------------------------- rociResInfoStmt ---------------------------- */

static SEXP rociResInfoStmt(rociRes *res)
{
  rociCon      *con = res->con_rociRes;
  rociDrv      *drv = con->drv_rociCon;
  OCIError     *errhp = drv->err_rociDrv;
  OCIStmt      *stmthp = res->stm_rociRes;
  ub4           qrylen;
  oratext      *qrybuf;
  SEXP          vec;

  /* get statement */
  rociCheckCon(con, "rociResInfoStmt", 1,
    OCIAttrGet(stmthp, OCI_HTYPE_STMT, &qrybuf, &qrylen,
               OCI_ATTR_STATEMENT, errhp));

  /* allocate result vector */
  PROTECT(vec = allocVector(STRSXP, 1));
  SET_STRING_ELT(vec, 0, mkCharLen((char *)qrybuf, (int)qrylen));
  UNPROTECT(1);

  return vec;
} /* end rociResInfoStmt */

/* --------------------------- rociResInfoFields --------------------------- */

static SEXP rociResInfoFields(rociRes *res)
{
  rociCon      *con = res->con_rociRes;
  rociDrv      *drv = con->drv_rociCon;
  OCIError     *errhp = drv->err_rociDrv;
  OCIStmt      *stmthp = res->stm_rociRes;
  OCIParam     *par;
  SEXP          list;
  SEXP          names;
  SEXP          row_names;
  SEXP          vec;
  ub4           len;
  oratext      *buf;
  ub2           siz;
  sb2           pre;
  sb1           sca;
  ub1           nul;
  int           cid;

  /* allocate output list */
  PROTECT(list = allocVector(VECSXP, 7));

  /* allocate and set names */
  names = allocVector(STRSXP, 7);
  setAttrib(list, R_NamesSymbol, names);                   /* protects names */

  /* allocate and set row names */
  row_names = allocVector(INTSXP, 2);
  INTEGER(row_names)[0] = NA_INTEGER;
  INTEGER(row_names)[1] = res->ncol_rociRes;
  setAttrib(list, R_RowNamesSymbol, row_names);        /* protects row_names */

  /* set class to data frame */
  setAttrib(list, R_ClassSymbol, mkString("data.frame"));

  /* name */
  PROTECT(vec = allocVector(STRSXP, res->ncol_rociRes));
  for (cid = 0; cid < res->ncol_rociRes; cid++)
  {
    rociCheckCon(con, "rociResInfoFields", 1,
      OCIParamGet(stmthp, OCI_HTYPE_STMT, errhp, (void **)&par, (ub4)(cid+1)));
    rociCheckCon(con, "rociResInfoFields", 2,
      OCIAttrGet(par, OCI_DTYPE_PARAM, &buf, &len, OCI_ATTR_NAME, errhp));
    SET_STRING_ELT(vec, cid, mkCharLen((const char *)buf, (int)len));
  }
  SET_VECTOR_ELT(list, 0, vec);
  SET_STRING_ELT(names, 0, mkChar("name"));
  UNPROTECT(1);

  /* Sclass */
  PROTECT(vec = allocVector(STRSXP, res->ncol_rociRes));
  for (cid = 0; cid < res->ncol_rociRes; cid++)
    SET_STRING_ELT(vec, cid, mkChar(rociNameClass(res->typ_rociRes[cid])));
  SET_VECTOR_ELT(list, 1, vec);
  SET_STRING_ELT(names, 1, mkChar("Sclass"));
  UNPROTECT(1);

  /* type */
  PROTECT(vec = allocVector(STRSXP, res->ncol_rociRes));
  for (cid = 0; cid < res->ncol_rociRes; cid++)
    SET_STRING_ELT(vec, cid, mkChar(rociNameInt(res->typ_rociRes[cid])));
  SET_VECTOR_ELT(list, 2, vec);
  SET_STRING_ELT(names, 2, mkChar("type"));
  UNPROTECT(1);

  /* len */
  PROTECT(vec = allocVector(INTSXP, res->ncol_rociRes));
  for (cid = 0; cid < res->ncol_rociRes; cid++)
  {
    rociCheckCon(con, "rociResInfoFields", 3,
      OCIParamGet(stmthp, OCI_HTYPE_STMT, errhp, (void **)&par, (ub4)(cid+1)));
    rociCheckCon(con, "rociResInfoFields", 4,
      OCIAttrGet(par, OCI_DTYPE_PARAM, &siz, NULL, OCI_ATTR_DATA_SIZE, errhp));
    INTEGER(vec)[cid] = (int)siz;
  }
  SET_VECTOR_ELT(list, 3, vec);
  SET_STRING_ELT(names, 3, mkChar("len"));
  UNPROTECT(1);

  /* precision */
  PROTECT(vec = allocVector(INTSXP, res->ncol_rociRes));
  for (cid = 0; cid < res->ncol_rociRes; cid++)
  {
    rociCheckCon(con, "rociResInfoFields", 5,
      OCIParamGet(stmthp, OCI_HTYPE_STMT, errhp, (void **)&par, (ub4)(cid+1)));
    rociCheckCon(con, "rociResInfoFields", 6,
      OCIAttrGet(par, OCI_DTYPE_PARAM, &pre, NULL, OCI_ATTR_PRECISION, errhp));
    INTEGER(vec)[cid] = (int)pre;
  }
  SET_VECTOR_ELT(list, 4, vec);
  SET_STRING_ELT(names, 4, mkChar("precision"));
  UNPROTECT(1);

  /* scale */
  PROTECT(vec = allocVector(INTSXP, res->ncol_rociRes));
  for (cid = 0; cid < res->ncol_rociRes; cid++)
  {
    rociCheckCon(con, "rociResInfoFields", 7,
      OCIParamGet(stmthp, OCI_HTYPE_STMT, errhp, (void **)&par, (ub4)(cid+1)));
    rociCheckCon(con, "rociResInfoFields", 8,
      OCIAttrGet(par, OCI_DTYPE_PARAM, &sca, NULL, OCI_ATTR_SCALE, errhp));
    INTEGER(vec)[cid] = (int)sca;
  }
  SET_VECTOR_ELT(list, 5, vec);
  SET_STRING_ELT(names, 5, mkChar("scale"));
  UNPROTECT(1);

  /* nullOK */
  PROTECT(vec = allocVector(LGLSXP, res->ncol_rociRes));
  for (cid = 0; cid < res->ncol_rociRes; cid++)
  {
    rociCheckCon(con, "rociResInfoFields", 9,
      OCIParamGet(stmthp, OCI_HTYPE_STMT, errhp, (void **)&par, (ub4)(cid+1)));
    rociCheckCon(con, "rociResInfoFields", 10,
      OCIAttrGet(par, OCI_DTYPE_PARAM, &nul, NULL, OCI_ATTR_IS_NULL, errhp));
    LOGICAL(vec)[cid] = nul ? TRUE : FALSE;
  }
  SET_VECTOR_ELT(list, 6, vec);
  SET_STRING_ELT(names, 6, mkChar("nullOK"));
  UNPROTECT(1);

  /* release output list */
  UNPROTECT(1);

  return list;
} /* end rociResInfoFields */

/* ------------------------------ rociResFree ------------------------------ */

static void rociResFree(rociRes *res)
{
  rociCon      *con = res->con_rociRes;
  rociDrv      *drv = con->drv_rociCon;
  OCIError     *errhp = drv->err_rociDrv;
  int           bid;
  int           cid;
  int           fcur;

  /* free bind data buffers */
  if (res->bdat_rociRes)
  {
    for (bid = 0; bid < res->bcnt_rociRes; bid++)
      if (res->bdat_rociRes[bid])
        Free(res->bdat_rociRes[bid]);

    Free(res->bdat_rociRes);
  }

  /* free bind indicator buffers */
  if (res->bind_rociRes)
  {
    for (bid = 0; bid < res->bcnt_rociRes; bid++)
      if (res->bind_rociRes[bid])
        Free(res->bind_rociRes[bid]);

    Free(res->bind_rociRes);
  }

  /* free bind sizes */
  if (res->bsiz_rociRes)
    Free(res->bsiz_rociRes);

  /* free bind types */
  if (res->btyp_rociRes)
    Free(res->btyp_rociRes);

  /* free data buffers */
  if (res->dat_rociRes)
  {
    for (cid = 0; cid < res->ncol_rociRes; cid++)
      if (res->dat_rociRes[cid])
      {
        if (rociTypeExt(res->typ_rociRes[cid]) == SQLT_CLOB)
        {
          ub1 *dat = (ub1 *)res->dat_rociRes[cid];
          sb4  siz = res->siz_rociRes[cid];

          for (fcur = 0; fcur < ROCI_BULK_READ; fcur++)
          {
            OCILobLocator *lob = *(OCILobLocator **)(dat + fcur*siz);

            if (lob)
              rociCheckCon(con, "rociResFree", 1,
                OCIDescriptorFree(lob, OCI_DTYPE_LOB));
          }
        }

        Free(res->dat_rociRes[cid]);
      }

    Free(res->dat_rociRes);
  }

  /* free indicator buffers */
  if (res->ind_rociRes)
  {
    for (cid = 0; cid < res->ncol_rociRes; cid++)
      if (res->ind_rociRes[cid])
        Free(res->ind_rociRes[cid]);

    Free(res->ind_rociRes);
  }

  /* free length buffers */
  if (res->len_rociRes)
  {
    for (cid = 0; cid < res->ncol_rociRes; cid++)
      if (res->len_rociRes[cid])
        Free(res->len_rociRes[cid]);

    Free(res->len_rociRes);
  }

  /* free buffer sizes */
  if (res->siz_rociRes)
    Free(res->siz_rociRes);

  /* free column types */
  if (res->typ_rociRes)
    Free(res->typ_rociRes);

  /* free temp LOB buffer */
  if (res->lobbuf_rociRes)
    Free(res->lobbuf_rociRes);

  /* release the statement */
  if (res->stm_rociRes)
    rociCheckCon(con, "rociResFree", 2,
      OCIStmtRelease(res->stm_rociRes, errhp, (OraText *)NULL, 0,
                     OCI_DEFAULT));

  /* free ROCI result */
  Free(res);

  ROCI_TRACE("result freed");
} /* end rociResFree */

/*****************************************************************************/
/*  (*) OCI FUNCTIONS                                                        */
/*****************************************************************************/

/* ----------------------------- rociTypeInt ------------------------------- */

static ub1 rociTypeInt(ub2 ctyp)
{
  ub1 ityp;

  switch (ctyp)
  {
  case SQLT_CHR:                                      /* VARCHAR2, NVARCHAR2 */
    ityp = ROCI_VARCHAR2;
    break;
  case SQLT_NUM:
    ityp = ROCI_NUMBER;
   break;
  case SQLT_LNG:
    ityp = ROCI_LONG;
    break;
  case SQLT_DAT:
    ityp = ROCI_DATE;
    break;
  case SQLT_BIN:
    ityp = ROCI_RAW;
    break;
  case SQLT_LBI:
    ityp = ROCI_LONG_RAW;
    break;
  case SQLT_AFC:
    ityp = ROCI_CHAR;
    break;
  case SQLT_IBFLOAT:
    ityp = ROCI_BFLOAT;                                      /* BINARY_FLOAT */
    break;
  case SQLT_IBDOUBLE:
    ityp = ROCI_BDOUBLE;                                    /* BINARY_DOUBLE */
    break;
  case SQLT_RDD:
    ityp = ROCI_ROWID;
    break;
  case SQLT_NTY:                /* USER-DEFINED TYPE (OBJECT, VARRAY, TABLE) */
    ityp = ROCI_UDT;
    break;
  case SQLT_REF:
    ityp = ROCI_REF;
    break;
  case SQLT_CLOB:
    ityp = ROCI_CLOB;
    break;
  case SQLT_BLOB:
    ityp = ROCI_BLOB;
    break;
  case SQLT_BFILEE:
    ityp = ROCI_BFILE;
    break;
  case SQLT_TIMESTAMP:
    ityp = ROCI_TIME;
    break;
  case SQLT_TIMESTAMP_TZ:
    ityp = ROCI_TIME_TZ;
    break;
  case SQLT_INTERVAL_YM:
    ityp = ROCI_INTER_YM;
    break;
  case SQLT_INTERVAL_DS:
    ityp = ROCI_INTER_DS;
    break;
  case SQLT_TIMESTAMP_LTZ:
    ityp = ROCI_TIME_LTZ;
    break;
  default:
    rociFatal("rociTypeInt", 1, ctyp);
    break;
  }

  return ityp;
} /* end rociTypeInt */

/* ----------------------------- rociTypeExt ------------------------------- */

static ub2 rociTypeExt(ub1 ityp)
{
  ub2  etyp;

  etyp = rociITypTab[ityp].etyp_rociITyp;
  if (!etyp)
    rociError("unsupported column type");

  return etyp;
} /* rociTypeExt */

/* ------------------------------- rociCheck ------------------------------- */

static void rociCheck(rociDrv *drv, char *fun, int pos, sb4 *errNum,
                      text *errMsg, sword status)
{
  text   buf[ROCI_ERR_LEN];
  sb4    num;
  ub4    htype = 0;
  void  *hdl = NULL;

  switch (status)
  {
  case OCI_SUCCESS:
  case OCI_SUCCESS_WITH_INFO:
    break;
  case OCI_ERROR:
    /* choose handle */
    if (drv->err_rociDrv)
    {
      hdl = drv->err_rociDrv;
      htype = OCI_HTYPE_ERROR;
    }
    else if (drv->env_rociDrv)
    {
      hdl = drv->env_rociDrv;
      htype = OCI_HTYPE_ENV;
    }
    else
      rociFatal(fun, pos, status);

    /* choose buffer */
    if (!errMsg)
    {
      errMsg = buf;
      errNum = &num;
    }

    /* get error */
    OCIErrorGet(hdl, 1, (text *)NULL, errNum, errMsg, ROCI_ERR_LEN, htype);
    rociError((char *)errMsg);
    break;
  default:
    rociFatal(fun, pos, status);
    break;
    break;
  }
} /* end rociCheck */

/* end of file roci.c */
