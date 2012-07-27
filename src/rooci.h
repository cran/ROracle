/* Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   NAME
     rooci.h 

   DESCRIPTION
     All OCI related data types and functions for OCI based DBI driver for R.

   NOTES

   MODIFIED   (MM/DD/YY)
   rpingte     06/21/12 - UTC changes
   rpingte     06/21/12 - convert utf-8 sql to env handle character set
   jfeldhau    06/18/12 - ROracle support for TimesTen.
   rpingte     06/06/12 - prototype changes for NLS support
   rpingte     05/22/12 - POSIXct, POSIXlt and RAW support
   rkanodia    05/13/12 - LOB prefetch
   rkanodia    05/12/12 - Statement caching
   demukhin    05/10/12 - translation changes
   rpingte     04/30/12 - add navigation of conn and result
   rkanodia    04/27/12 - Namespace change
   rpingte     04/19/12 - normalize structures
   rpingte     04/10/12 - decouple rodbi and rooci functionality
   rkanodia    04/08/12 - Add function description
   rpingte     04/02/12 - add OCI-specific structures
   rkanodia    03/25/12 - DBI calls implementation
   rkanodia    03/25/12 - Creation 

*/


#ifndef _rooci_H
#define _rooci_H

#ifndef OCI_ORACLE
# include <oci.h>
#endif

#define ROOCI_ERR_LEN              3072                      /* rodbi ERRor */
                                                           /* buffer LENgth */
#define ROOCI_VERSION_LEN          64        /* rodbi Version Number Length */
#define ROOCI_MAX_IDENTIFIER_LEN   30       /* max length of db identifiers */
#define ROOCI_DRV_ERR_MEM_FAIL    -10   /* memory allocation fail error no. */
#define ROOCI_DRV_ERR_CON_FAIL    -11  /* connection creation fail error no */

/* macro for memory allocation */
#ifdef ROOCI_MEM_DEBUG
/* Intentionally left in one line to get the exact line number */
# define ROOCI_MEM_ALLOC(buf_, no_of_elem, siz_of_elem) \
  (buf_) = calloc((size_t)(no_of_elem), (siz_of_elem)); fprintf(stdout, "%p allocated in %s at line# %d\n", (buf_), __FUNCTION__, __LINE__);
#else
# define ROOCI_MEM_ALLOC(buf_, no_of_elem, siz_of_elem) \
  do \
  { \
    (buf_) = calloc((size_t)(no_of_elem), (siz_of_elem)); \
  } \
  while (0)
#endif

/* macro to free memory */
#ifdef ROOCI_MEM_DEBUG
/* Intentionally left in one line to get the exact line number */
# define ROOCI_MEM_FREE(buf_) \
  free(buf_); fprintf(stdout, "%p freed in %s at line# %d\n", (buf_), __FUNCTION__, __LINE__); (buf_) = NULL;
#else
# define ROOCI_MEM_FREE(buf_) \
  do \
  { \
    free(buf_); \
    (buf_) = NULL; \
  } \
  while (0)
#endif

#define ROOCI_QRY_UTF8   (ub1)0x01
#define ROOCI_QRY_NATIVE (ub1)0x02
#define ROOCI_QRY_LATIN1 (ub1)0x04

/* forward declarations */
struct roociCon;
struct roociRes;

/* Conn access structure for traversing list of connections using first/next */
struct roociConAccess
{
  int conID_roociConAccess;                    /* Next connection to process */
  int num_roociConAccess;                 /* Number of connections processed */
};
typedef struct roociConAccess roociConAccess;

/* Driver OCI Context */
struct roociCtx
{
  OCIEnv           *env_roociCtx;                     /* ENVironment handle */
  struct roociCon **con_roociCtx;                      /* CONnection vector */
  int               num_roociCtx;             /* NUMber of open connections */
  int               max_roociCtx;          /* MAXimum number of connections */
  int               tot_roociCtx;  /* TOTal number of connections processed */
  sword             maj_roociCtx;             /* OCI CLIENT Library VERsion */
                                 /* <major>.<minor>.<update>.<patch>.<port> */
  sword             minor_roociCtx;
  sword             update_roociCtx;
  sword             patch_roociCtx;
  sword             port_roociCtx;
  boolean           control_c_roociCtx;     /* Handle control C interrupt ? */
  roociConAccess    acc_roociCtx;    /* sequential traversal of connections */
  /* TODO: add mutex when R is thread-safe */
};
typedef struct roociCtx roociCtx;

struct roociResAccess
{
  int resID_roociResAccess;                        /* Next result to process */
  int num_roociResAccess;                      /* Number of result processed */
};
typedef struct roociResAccess roociResAccess;

/* CONnection OCI context */
struct roociCon
{
  void              *parent_roociCon;        /* parent connection reference */
  roociCtx          *ctx_roociCon;                          /* rooci DRiVer */
  OCIError          *err_roociCon;                          /* ERRor handle */
  OCIAuthInfo       *auth_roociCon;                /* AUThentication handle */
  OCISvcCtx         *svc_roociCon;                /* SerViCe context handle */
  OCISession        *usr_roociCon;                   /* USeR session handle */
  struct roociRes  **res_roociCon;                         /* RESult vector */
  int                num_roociCon;                /* NUMber of open results */
  int                max_roociCon;             /* MAXimum number of results */
  int                tot_roociCon;     /* TOTal number of results processed */
  char              *cstr_roociCon;                       /* Connect STRing */
  int                conID_roociCon;                       /* connection ID */
  boolean            timesten_rociCon;          /* TIMESTEN connection flag */
  sb4                nlsmaxwidth_roociCon;    /* NLS max width of character */
  roociResAccess     acc_roociCon;       /* sequential traversal of results */
  OCIInterval       *tzdiff_roociCon;    /* interval from UTC to session TZ */
  /* TODO: add mutex when R is thread-safe */
};
typedef struct roociCon roociCon;

/* RESult OCI context */
struct roociRes
{
  void            *parent_roociRes;          /* parent result set reference */ 
  roociCon        *con_roociRes;                          /* OCI CONnection */
  OCIStmt         *stm_roociRes;                        /* STateMent handle */
  int              resID_roociRes;                             /* Result ID */
  /* -------------------------------- BIND -------------------------------- */
  int              bcnt_roociRes;                             /* Bind CouNT */
  int              bmax_roociRes;                          /* Bind MAX rows */
  void           **bdat_roociRes;                      /* Bind DATa buffers */
  sb2            **bind_roociRes;                 /* Bind INDicator buffers */
  ub2            **alen_roociRes;                     /* Bind actual length */
  ub2             *bsiz_roociRes;              /* Bind buffer maximum SIZes */
  ub2             *btyp_roociRes;                      /* Bind buffer TYPes */
  /* ------------------------------- DEFINE ------------------------------- */
  int              ncol_roociRes;                      /* Number of COLumns */
  ub1             *typ_roociRes;                          /* internal TYPes */
  ub1             *form_roociRes;        /* character set form (CHAR/NCHAR) */
  void           **dat_roociRes;                            /* DATa buffers */
  sb2            **ind_roociRes;                       /* INDicator buffers */
  ub2            **len_roociRes;                          /* LENgth buffers */
  sb4             *siz_roociRes;                    /* buffer maximum SIZes */
  ub1             *lobbuf_roociRes;                      /* temp LOB BUFfer */
  size_t           loblen_roociRes;               /* temp LOB buffer LENgth */
  boolean          prefetch_roociRes;    /* TRUE - use OCI prefetch buffers */
  int              nrows_roociRes;    /* nuumber of rows to fetch at a time */
  OCIDateTime     *epoch_roociRes;             /* epoch from 1970/01/01 UTC */
  OCIInterval     *diff_roociRes; /* time interval difference from 1970 UTC */
  /* TODO: add mutex when R is thread-safe */
};
typedef struct roociRes roociRes;


/*----------------------------------------------------------------------------
                        FUNCTION DECLARATIONS
----------------------------------------------------------------------------*/

/* ----------------------------- roociInitializeCtx ----------------------- */
/* Intialize driver oci context */
sword roociInitializeCtx (roociCtx *pctx, boolean interrupt_srv);

/* ----------------------------- roociInitializeCon ----------------------- */
/* Initialize connection oci context */
sword roociInitializeCon(roociCtx *pctx, roociCon *pcon,
                         char *user, char *pass, char *cstr, boolean bwallet,
                         ub4 stmt_cache_siz, ub4 lob_prefetch_siz);

/* ----------------------------- roociGetError ---------------------------- */
/* Retrieve error message and and error number */
sword roociGetError(roociCtx *pctx, roociCon *pcon,sb4 *errNum, text *errMsg);

/* ----------------------------- roociGetConInfo -------------------------- */
/* Retrieve connection related information */
sword roociGetConInfo(roociCon *pcon, text **user, ub4 *userLen,
                      text *verServer, ub4 *stmt_cache_size);

/* ----------------------------- roociTerminateCtx ------------------------ */
/* Clear driver context */
sword roociTerminateCtx(roociCtx *pctx);

/* ------------------------- roociGetFirstParentCon ----------------------- */
/* Get first parent connection */
void *roociGetFirstParentCon(roociCtx *pctx);

/* -------------------------- roociGetNextParentCon ----------------------- */
/* Get next parent connection */
void *roociGetNextParentCon(roociCtx *pctx);

/* ----------------------------- roociTerminateCon ------------------------ */
/* clear connection context */
sword roociTerminateCon(roociCtx *pctx, roociCon *pcon, boolean validCon);

/* -------------------------- roociCommitCon ------------------------------ */
/* commit connection transaction */
sword roociCommitCon(roociCon *pcon);

/* -------------------------- roociRollbackCon ---------------------------- */
/* roll back connection transaction */
sword roociRollbackCon(roociCon *pcon);

/* ----------------------------- roociInitializeRes ----------------------- */
/* Initialize result set oci context */
sword roociInitializeRes(roociCon *pcon, roociRes *pres, text *qry, int qrylen,
                         ub1 qry_encoding, ub2 *styp, boolean prefetch,
                         int bulk_read);

/* ----------------------------- roociExecTTOpt --------------------------- */
/* Execute TimesTen optimizer hints */
sword roociExecTTOpt(roociCon *pcon);

/* ----------------------------- roociStmtExec ---------------------------- */
/* Execute statement and 
   get number of rows affected by statement execution */
sword roociStmtExec(roociCon *pcon, roociRes *pres, ub4 noOfRows,
                    ub2 styp, int *rows_affected);

/* ----------------------------- roociBindData ---------------------------- */
/* Bind input data for statement execution */
sword roociBindData(roociCon *pcon, roociRes *pres, ub4 bufPos,
                    ub1 form_of_use);

/* ----------------------------- roociResDefine --------------------------- */
/* Allocate memory and define ouput buffer */
sword roociResDefine(roociCtx *pctx, roociCon *pcon, roociRes *pres, 
                     ub4 lobPrefetchSize);

/* ----------------------------- roociDescCol ----------------------------- */
/* Desribe result set coulmn properties */
sword roociDescCol(roociRes *pres, ub4 colId, ub2 *extTyp, oratext **colName, 
                   ub4 *colNameLen, ub4 *maxColDataSizeInByte, sb2 *colpre, 
                   sb1 *colsca, ub1 *nul, ub1 *form);

/* ------------------------------ roociGetColProperties ------------------- */
/* Get result set column name */
sword roociGetColProperties(roociCon *pcon, roociRes *pres,                 
                            ub4 colId, ub4 *len, oratext **buf);

/* ------------------------------- roociFetchData ------------------------- */
/* Fetch output data */
sword roociFetchData(roociCon *pcon, roociRes *pres,
                     ub4 *rows_affected, boolean *end_of_fetch);

/* ------------------------------ roociReadLOBData ------------------------ */
/* Read CLOB data */
sword roociReadLOBData(roociRes *pres, int *lob_len, int rowpos, int cid);

/* ----------------------------- roociReadBLOBData ------------------------ */
/* Read BLOB/BFILE data */
sword roociReadBLOBData(roociRes *pres, int *lob_len, int rowpos, int cid);

/* -------------------------- rociReadDateTimeData ------------------------- */
/* Read DateTime data */
sword roociReadDateTimeData(roociRes *pres, OCIDateTime *tstm, double *date,
                            boolean isDateCol);

/* ------------------------- roociWriteDateTimeData ------------------------ */
/* Write DateTime data */
sword roociWriteDateTimeData(roociRes *pres, OCIDateTime *tstm, double date);

/* ------------------------------ roociGetResStmt ------------------------- */
/* Get statement related to result set */
sword roociGetResStmt(roociRes *pres, oratext **qrybuf, ub4 *qrylen);

/* ------------------------- roociGetFirstParentRes ----------------------- */
/* Get first parent result */
void *roociGetFirstParentRes(roociCon *pcon);

/* -------------------------- roociGetNextParentRes ----------------------- */
/* Get next parent result */
void *roociGetNextParentRes(roociCon *pcon);

/* ----------------------------- roociResFree ----------------------------- */
/* clear result set context */
sword roociResFree(roociCon *pcon, roociRes *pres);


#endif /*end of _rooci_H */
