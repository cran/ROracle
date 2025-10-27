/* Copyright (c) 2011, 2025, Oracle and/or its affiliates. */
/* All rights reserved.*/

/*
   NAME
     rooci.h 

   DESCRIPTION
     All OCI related data types and functions for OCI based DBI driver for R.

   NOTES

   MODIFIED   (MM/DD/YY)
   rpingte     10/17/25 - change __FUNCTION__ to __func__
   rpingte     05/05/25 - add sparse support via Matrix library
   rpingte     04/25/25 - Bug 37777349: support data longer than 32767 in bind to CLOB
   rpingte     09/19/24 - improve error reporting
   rpingte     07/11/24 - fix compiler warnigs with pre-19c clients
   rpingte     04/09/24 - use dynamic loading
   rpingte     03/20/24 - add vector supprt
   rpingte     04/03/20 - add bndnm_roociColType for duplicate bind
   rpingte     03/19/19 - Object support
   rpingte     10/05/16 - add c headers
   ssjaiswa    03/10/16 - Added statement handle buffer support field
   ssjaiswa    03/08/16 - Changed roociReadBLOBData() and roociReadLOBData()
                          signature to support Plsql OUT/IN OUT return
   ssjaiswa    03/04/16 - Added Plsql OUT/IN OUT parameter name support field 
                          param_name_roociRes
   rpingte     08/05/15 - added epoch_roociRes and diff_roociRes fields
   rpingte     08/05/15 - 21128853: changing roociReadDateTimeData and 
                          roociWriteDateTimeData prototype
   rpingte     01/29/15 - add unicode_as_utf8
   ssjaiswa    09/12/14 - add bulk_write support field nrows_write_roociRes
   rpingte     05/21/14 - add time zone to connection
   rpingte     05/02/14 - maintain date, time stamp, time stamp with time zone
                          and time stamp with local time zone as string
   rpingte     04/24/14 - remove epoch, temp_ts, diff, and inited unused fields
                          from roociRes
   rpingte     04/09/14 - change bsiz_roociRes is sb4
   rpingte     04/03/14 - remove tzdiff unused field
   rpingte     04/01/14 - remove secs_UTC_roociCon
   rpingte     03/12/14 - add boolean for TX epoch initialization
   rpingte     03/06/14 - lobinres_roociRes -> nocache_roociRes
   rpingte     01/09/14 - Copyright update
   rpingte     11/18/13 - add lobinres_roociRes
   rpingte     10/24/13 - Cache resultset in memory before transferring to R to
                          avoid unnecessary alloc and free using allocVector
   rkanodia    10/03/13 - Add session mode
   rpingte     11/20/12 - 15900089: remove avoidable errors reported with date
                          time types
   rpingte     09/21/12 - roociAllocDescBindBuf
   paboyoun    09/17/12 - add difftime support
   demukhin    09/05/12 - add Extproc driver
   rkanodia    08/08/12 - Removed redundant arguments passed to functions
                          and removed LOB prefetch support, bug [14508278]
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


#include <R.h>
#include <Rdefines.h>
#include "roociload.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#ifndef OCI_ORACLE
# include <oci.h>
#endif

#ifndef ORID_ORACLE
# include <orid.h>
#endif

#ifndef _rooci_H
#define _rooci_H

#define ROOCI_ERR_LEN              ROOCILOAD_ERR_LEN         /* rodbi ERRor */
                                                           /* buffer LENgth */
#define ROOCI_VERSION_LEN          64        /* rodbi Version Number Length */
#define ROOCI_MAX_IDENTIFIER_LEN   30       /* max length of db identifiers */
#define ROOCI_DRV_ERR_MEM_FAIL    -10   /* memory allocation fail error no. */
#define ROOCI_DRV_ERR_CON_FAIL    -11  /* connection creation fail error no */
#define ROOCI_DRV_ERR_NO_DATA     -12              /* no more data in cache */
#define ROOCI_DRV_ERR_TYPE_FAIL   -13
                        /* type other than UDT and COLLECTION not supported */
#define ROOCI_DRV_ERR_ENCODE_FAIL -14             /* encoding not supported */
#define ROOCI_DRV_ERR_LOAD_FAIL   -15
                        /* Oracle client function or library failed to load */

/* macro for memory allocation */
#ifdef ROOCI_MEM_DEBUG
/* Intentionally left in one line to get the exact line number */
# define ROOCI_MEM_ALLOC(buf_, no_of_elem, siz_of_elem) \
  (buf_) = calloc((size_t)(no_of_elem), (siz_of_elem)); fprintf(stdout, "%p allocated in %s at line# %d\n", (buf_), __func__, __LINE__);
#else
# define ROOCI_MEM_ALLOC(buf_, no_of_elem, siz_of_elem) \
  do \
  { \
    (buf_) = calloc((size_t)(no_of_elem), (siz_of_elem)); \
  } \
  while (0)
#endif

/* macro for memory allocation without clearing it */
#ifdef ROOCI_MEM_DEBUG
/* Intentionally left in one line to get the exact line number */
# define ROOCI_MEM_MALLOC(buf_, no_of_elem, siz_of_elem) \
  (buf_) = malloc((size_t)(no_of_elem) * (siz_of_elem)); fprintf(stdout, "%p allocated in %s at line# %d\n", (buf_), __func__, __LINE__);
#else
# define ROOCI_MEM_MALLOC(buf_, no_of_elem, siz_of_elem) \
  do \
  { \
    (buf_) = malloc((size_t)(no_of_elem) * (siz_of_elem)); \
  } \
  while (0)
#endif

/* macro to free memory */
#ifdef ROOCI_MEM_DEBUG
/* Intentionally left in one line to get the exact line number */
# define ROOCI_MEM_FREE(buf_) \
  free(buf_); fprintf(stdout, "%p freed in %s at line# %d\n", (buf_), __func__, __LINE__); (buf_) = NULL;
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

#define ROOCI_OCI_RET_ERR(fun, retval) \
do { \
  retval = (fun); \
  if (retval != OCI_SUCCESS) { \
    return retval;\
  }\
} while (0)

/*
   Date and time string representation is: YYYY-MM-DD HH24:MM:SSXFF

   Fixed value will be: "YYYY-MM-DD HH:MM:SS.FFFFFFFFF"

   NOTE: Date will not have fdractional seconds and represents the maximum
         length for Date, timestamp, timestamp with time zone and
         timestamp with local time zone.
*/
#define ROOCI_DATE_TIME_STR_LEN 30

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
  roociloadVersion  ver_roociCtx;
  boolean           control_c_roociCtx;     /* Handle control C interrupt ? */
  roociConAccess    acc_roociCtx;    /* sequential traversal of connections */
  /* TODO: add mutex when R is thread-safe */

  /* extproc environment fields */
  boolean           extproc_roociCtx;            /* EXTPROC environment flag */
  OCISvcCtx        *svc_roociCtx;          /* extproc SerViCe context handle */
  OCIError         *err_roociCtx;                    /* extproc ERRor handle */
  roociloadCtx      loadCtx_roociCtx; 
                       /* library context for dynamically loaded OCI library */
  sword             compiled_maj_roociCtx;
  sword             compiled_min_roociCtx;
  boolean           bMatrixPkgLoaded;
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
  double             secs_UTC_roociCon;     /* LocalTZ, UTC diff in seconds
                    * used for timesten as TSTZ and TSLTZ are not supported */
  sb4                nlsmaxwidth_roociCon;    /* NLS max width of character */
  roociResAccess     acc_roociCon;       /* sequential traversal of results */
  /* TODO: add mutex when R is thread-safe */
};
typedef struct roociCon roociCon;

/* Attribute value in User Defined Type object */
struct roociAttrVal
{
  union
  {
    double   flt_roociData;
    int      int_roociData;
    boolean  bol_roociData;
    char    *str_roociData; 
  } roociData;
  ub4 len_roociData;
};
typedef struct roociAttrVal roociAttrVal;

typedef struct roociObjType roociObjType;
typedef struct roociColType roociColType;

/* User defined Object type for each object in column or embedded in object */
struct roociObjType
{
  ub4               nelem_roociObjType; /* number of elements in collection */
  OCITypeCode       otc_roociObjType;                   /* Object Type Code */
  OCITypeCode       colltc_roociObjType;            /* Collection Type Code */
  text              name_roociObjType[SB1MAXVAL];            /* object name */
  ub4               namsz_roociObjType;      /* length of name_roociObjType */
  int               nattr_roociObjType;      /* number of attributes in ADT */
  int               tattr_roociObjType;/* total number of attributes in ADT */
  roociColType     *typ_roociObjType;                     /* internal TYPes */
  struct OCIType   *otyp_roociObjType;                      /* Object TYPes */
};

/* Column Type information for each column */
struct roociColType
{
  ub1            typ_roociColType;                        /* internal TYPes */
  ub2            extyp_roociColType;                       /* external type */
  oratext        name_roociColType[SB1MAXVAL];               /* column name */
  ub4            namsz_roociColType;               /* length of column name */
  oratext        attrnm_roociColType[SB1MAXVAL];   /* column attribute name */
  ub4            attrnmsz_roociColType;            /* length of column name */
  ub2            colsz_roociColType;                    /* length of column */
  sb2            prec_roociColType;                  /* precision of column */
  ub1            scale_roociColType;                     /* scale of column */
  ub1            null_roociColType;                              /* null OK */
  ub1            form_roociColType;                          /* form of use */
  ub4            vdim_roociColType;           /* dimension of vector column */
  ub4            vfmt_roociColType;              /* format of vector column */
  ub4            vprop_roociColType;           /* property of vector column */
  OCILobLocator *loc_roociColType;                 /* temp locator for bind */
  const char    *bndtyp_roociColType;/* ora.type specifying type name to bind */
  const char    *bndnm_roociColType;     /* ora.parameter_name name to bind */
  roociAttrVal   val_roociColType;               /* current attribute value */
  struct roociObjType  obtyp_roociColType;   /* Object/UDT type information */
  ub4            bndflg_roociColType;                /* flags for bind type */
#define ROOCI_COL_VEC_AS_CLOB 0x00000001    /* vector bound as CLOB(STRSXP) */
#define ROOCI_COL_PLS_AS_CLOB 0x00000002  /* PLSQL IN param as CLOB(STRSXP) */
#define ROOCI_COL_PLS_AS_BLOB 0x00000004  /* PLSQL IN param as BLOB(RAWSXP) */
};

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
  void           **param_name_roociRes;    /* parameter name for OUT/IN OUT */
  sb2            **bind_roociRes;                 /* Bind INDicator buffers */
  void           **objbind_roociRes;       /* Object Bind INDicator buffers */
  ub2            **alen_roociRes;                     /* Bind actual length */
  sb4             *bsiz_roociRes;              /* Bind buffer maximum SIZes */
  roociColType    *btyp_roociRes;                      /* Bind buffer TYPes */
  int             *bform_roociRes;    /* character set form for PL/SQL bind */
  /* ------------------------------- DEFINE ------------------------------- */
  int              ncol_roociRes;                      /* Number of COLumns */
  roociColType    *typ_roociRes;                          /* internal TYPes */
  ub1             *form_roociRes;        /* character set form (CHAR/NCHAR) */
  void           **dat_roociRes;                            /* DATa buffers */
  sb2            **ind_roociRes;                       /* INDicator buffers */
  ub2            **len_roociRes;                          /* LENgth buffers */
  sb4             *siz_roociRes;                    /* buffer maximum SIZes */
  ub1             *lobbuf_roociRes;                      /* temp LOB BUFfer */
  int              loblen_roociRes;               /* temp LOB buffer LENgth */
  boolean          nocache_roociRes;   /* TRUE - do not cache result in mem */
  boolean          prefetch_roociRes;    /* TRUE - use OCI prefetch buffers */
  int              nrows_roociRes;     /* number of rows to fetch at a time */
  int              nrows_write_roociRes; /* # of elements to bind at a time */
  OCIDateTime     *epoch_roociRes;             /* epoch from 1970/01/01 UTC */
  OCIInterval     *diff_roociRes; /* time interval difference from 1970 UTC */
  OCIDateTime     *tsdes_roociRes;  /* temp descriptor to convert date type */
  OCIStmt        **stm_cur_roociRes;   /* statement handle buffer which are */
                                              /* bound to each plsql cursor */
  OCIStmt         *curstm_roociRes;    /* statement handle based on whether */
                                    /* fetch from main SELECT or REF cursor */
  void            *vecarr_roociRes; /* array of double to convert integer   */
                                     /* to float64 there is only in8 format */
  ub4              lvecarr_roociRes;           /* length of vecarr_roociRes */
  void            *indarr_roociRes; /* array of indices for sparse vectors  */
  ub4              lindarr_roociRes;           /* length of indarr_roociRes */
  boolean         sparse_vec_roociRes;/* TRUE: vector data may contain 0s,  */
                                      /* & the column is defined as sparse  */
                                      /* in Oracle database for DMLs. Useful*/
                                      /* when Matrix package is not used &  */
                                      /* some other package is used instead */
                                      /* ROracle will construct index array */
                                      /* in this case for noon-zero elements*/
  /* TODO: add mutex when R is thread-safe */
};
typedef struct roociRes roociRes;


/*----------------------------------------------------------------------------
                        FUNCTION DECLARATIONS
----------------------------------------------------------------------------*/

/* ----------------------------- roociInitializeCtx ----------------------- */
/* Intialize driver oci context */
sword roociInitializeCtx (roociCtx *pctx, void *epx, boolean interrupt_srv,
                          boolean unicode_as_utf8, boolean ora_objects);

/* ----------------------------- roociInitializeCon ----------------------- */
/* Initialize connection oci context */
sword roociInitializeCon(roociCtx *pctx, roociCon *pcon,
                         char *user, char *pass, char *cstr,
                         ub4 stmt_cache_siz, ub4 session_mode);

/* ----------------------------- roociGetError ---------------------------- */
/* Retrieve error message and and error number */
sword roociGetError(roociCtx *pctx, roociCon *pcon, const char *msgText,
                    sb4 *errNum, text *errMsg, ub4 errMsgSize);

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
sword roociTerminateCon(roociCon *pcon, boolean validCon);

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
                         int bulk_read, int bulk_write);

/* ----------------------------- roociExecTTOpt --------------------------- */
/* Execute TimesTen optimizer hints */
sword roociExecTTOpt(roociCon *pcon);

/* ----------------------------- roociStmtExec ---------------------------- */
/* Execute statement and 
   get number of rows affected by statement execution */
sword roociStmtExec(roociRes *pres, ub4 noOfRows, ub2 styp, 
                    int *rows_affected);

/* ----------------------------- roociBindData ---------------------------- */
/* Bind input data for statement execution */
sword roociBindData(roociRes *pres, ub4 bufPos, ub1 form_of_use, 
                    const char *name);

/* ----------------------------- roociResDefine --------------------------- */
/* Allocate memory and define ouput buffer */
sword roociResDefine(roociRes *pres);

/* ----------------------------- roociDescCol ----------------------------- */
/* Desribe result set coulmn properties */
sword roociDescCol(roociRes *pres, ub4 colId, ub2 *extTyp, oratext **colName, 
                   ub4 *colNameLen, ub4 *maxColDataSizeInByte, sb2 *colpre, 
                   sb1 *colsca, ub1 *nul, ub1 *form);

/* -------------------------- roociFillAllTypeInfo ------------------------ */
/* Fill type information of all attributes of UDT column */
sword roociFillAllTypeInfo(roociCon *pcon, roociRes *pres,
                           roociColType *coltyp);

/* Fill type information of UDT */
sword roociFillTypeInfo(roociCon *pcon, roociRes *pres, roociObjType *objtyp,
                        OCIParam *parmp);

/* Fill type information of UDT type attributes */
sword roociFillTypeAttrInfo(roociCon *pcon, roociRes *pres,
                            roociColType *coltyp, roociObjType *parentobj,
                            OCIParam *parmp, ub4 parmcnt);

/* Fill type information of UDT collection attributes */
sword roociFillTypeCollInfo(roociCon *pcon, roociRes *pres,
                            roociColType *coltyp,
                            OCIParam *parmp, boolean is_array);

/* ------------------------------ roociGetColProperties ------------------- */
/* Get result set column name */
sword roociGetColProperties(roociRes *pres, ub4 colId, ub4 *len, 
                            oratext **buf);

/* ------------------------------- roociFetchData ------------------------- */
/* Fetch output data */
sword roociFetchData(roociRes *pres, ub4 *rows_affected, 
                     boolean *end_of_fetch);

/* ------------------------------ roociReadLOBData ------------------------ */
/* Read CLOB data */
sword roociReadLOBData(roociRes *pres, OCILobLocator *lob_loc, int *lob_len,
                       ub1 form);

/* ----------------------------- roociReadBLOBData ------------------------ */
/* Read BLOB/BFILE data */
sword roociReadBLOBData(roociRes *pres, OCILobLocator *lob_loc, int *lob_len,
                        ub1 form, ub2 exttyp);

/* -------------------------- rociReadDateTimeData ------------------------- */
/* Read DateTime data */
sword roociReadDateTimeData(roociRes *pres, OCIDateTime *tstm, double *date,
                            boolean isDate);


/* ---------------------------- roociReadUDTData --------------------------- */
/* Read UDT data */
sword roociReadUDTData(roociRes *pres, roociColType *coltyp,
                       roociObjType *parentobj, void *obj, void *null_obj,
                       SEXP *lst, cetype_t enc, boolean ora_attributes);

#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
/* --------------------------- roociReadVectorData --------------------------- */
/* Read Vector data */
sword roociReadVectorData(roociRes *pres, OCIVector *vecdp, SEXP *lst,
                          boolean ora_attributes, int cid, boolean isOutbind);
#endif /* OCI_MAJOR_VERSION >= 23 */

/* ------------------------- roociWriteDateTimeData ------------------------ */
/* Write DateTime data */
sword roociWriteDateTimeData(roociRes *pres, OCIDateTime *tstm, double date);

/* -------------------------- rociReadDiffTimeData ------------------------- */
/* Read DiffTime data */
sword roociReadDiffTimeData(roociRes *pres, OCIInterval *tstm, double *time);

/* ------------------------- roociWriteDiffTimeData ------------------------ */
/* Write DiffTime data */
sword roociWriteDiffTimeData(roociRes *pres, OCIInterval *tstm, double time);

/* --------------------------- roociWriteUDTData --------------------------- */
/* Write UDT data */
sword roociWriteUDTData(roociRes *pres, roociColType *coltyp,
                        roociObjType *parentobj, void *obj, void *null_struct,
                        OCIInd *objind, SEXP lst, ub1 form);

/* --------------------------- roociWriteBLOBData --------------------------- */
/* Write BLOB data */
sword roociWriteBLOBData(roociRes *pres, OCILobLocator *lob_loc,
                         const ub1 *lob_buf, int lob_len, ub2 exttyp, ub1 form);

/* --------------------------- roociWriteLOBData --------------------------- */
/* Write LOB data */
sword roociWriteLOBData(roociRes *pres, OCILobLocator *lob_loc,
                        const oratext *lob_buf, int lob_len, ub1 form);

#if (OCI_MAJOR_VERSION == 23 && OCI_MINOR_VERSION > 3) || (OCI_MAJOR_VERSION > 23)
/* --------------------------- roociWriteVectorData --------------------------- */
/* Write Vector data */
sword roociWriteVectorData(roociRes *pres, roociColType *btyp,
                           OCIVector *vecdp, SEXP lst, ub1 form_of_use,
                           sb2 *pind);
#endif /* OCI_MAJOR_VERSION >= 23 */

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
sword roociResFree(roociRes *pres);

/* --------------------------- roociAllocDescBindBuf ----------------------- */
/* allocate bind buffer for timestamp/interval descriptor data */
sword roociAllocDescBindBuf(roociRes *pres, void **buf, sb4 bndsz,
                            ub4 dsc_type);

/* -------------------------- roociAllocObjectBindBuf ---------------------- */
/* allocate bind buffer for timestamp/interval descriptor data */
sword roociAllocObjectBindBuf(roociRes *pres, void **buf, void **indbuf,
                              int bid);

#endif /*end of _rooci_H */
