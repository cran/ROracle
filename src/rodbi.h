/* Copyright (c) 2011, 2025, Oracle and/or its affiliates.*/
/* All rights reserved.*/

/*
   NAME
     rodbi.h 

   DESCRIPTION
     All DBI calls for OCI based DBI driver for R.

   EXPORT FUNCTION(S)
         rodbicheckInterrupt - Driver check for user interrupt
         rodbiAssertCon      - Validate Connection object
         rodbiAssertRes      - Validate result set object
         rodbiTypeExt        - Map OCI type from R's internal type
         rodbiTypeInt        - Map OCI type to R internal type

   INTERNAL FUNCTION(S)
     NONE

   NOTES

   MODIFIED   (MM/DD/YY)
   rpingte     04/25/25 - version 1.5-1
   rpingte     10/02/24 - do not display flex for now
   rpingte     09/19/24 - improve error reporting
   rpingte     05/01/24 - change version to 1.5-0
   rpingte     03/19/24 - add vector supprt
   rpingte     01/26/22 - Add support for PLSQL boolean
   rpingte     03/19/19 - Object support
   rpingte     10/05/16 - move R includes into rodbi.c
   rpingte     03/25/15 - add NCHAR, NVARCHAR2 and NCLOB
   rpingte     01/09/14 - Copyright update
   jfeldhau    06/18/12 - ROracle support for TimesTen.
   demukhin    05/10/12 - translation changes
   rpingte     04/10/12 - only include what is necessary
   rkanodia    04/08/12 - Add function description
   rkanodia    03/25/12 - DBI calls implementation
   rkanodia    03/25/12 - Creation
*/


#ifndef _rodbi_H
#define _rodbi_H

#ifdef ENABLE_NLS
# include <libintl.h>
# define _(PkgString) dgettext("ROracle", PkgString)
#else
# define _(PkgString) (PkgString)
#endif

/* RODBI DRiVer version */
#define RODBI_DRV_NAME       "Oracle (OCI)"
#define RODBI_DRV_EXTPROC    "Oracle (extproc)"
#define RODBI_DRV_MAJOR       1
#define RODBI_DRV_MINOR       5
#define RODBI_DRV_UPDATE      1

/* RODBI R classes */
#define RODBI_R_LOG           1                                  /* LOGICAL */
#define RODBI_R_INT           2                                  /* INTEGER */
#define RODBI_R_NUM           3                                  /* NUMERIC */
#define RODBI_R_CHR           4                                /* CHARACTER */
#define RODBI_R_LST           5                                     /* LIST */
#define RODBI_R_DAT           6                                  /* POSIXct */
#define RODBI_R_DIF           7                                 /* DIFFTIME */
#define RODBI_R_RAW           8                                      /* RAW */

/* RODBI R classes NaMes */
#define RODBI_R_LOG_NM       "logical"
#define RODBI_R_INT_NM       "integer"
#define RODBI_R_NUM_NM       "numeric"
#define RODBI_R_CHR_NM       "character"
#define RODBI_R_LST_NM       "list"
#define RODBI_R_DAT_NM       "POSIXct"
#define RODBI_R_DIF_NM       "difftime"
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
#define RODBI_NVARCHAR2      22                           /* NVARCHAR2 TYPE */ 
#define RODBI_NCHAR          23                               /* NCHAR TYPE */ 
#define RODBI_NCLOB          24                               /* NCLOB TYPE */ 
#define RODBI_BOOLEAN        25                             /* BOOLEAN TYPE */
#define RODBI_VEC            26                              /* VECTOR TYPE */


/* RODBI internal Oracle types NaMes */
#define RODBI_VARCHAR2_NM    "VARCHAR2"
#define RODBI_NVARCHAR2_NM   "NVARCHAR2"
#define RODBI_NUMBER_NM      "NUMBER"
#define RODBI_INTEGER_NM     "NUMBER"
#define RODBI_LONG_NM        "LONG"
#define RODBI_DATE_NM        "DATE"
#define RODBI_RAW_NM         "RAW"
#define RODBI_LONG_RAW_NM    "LONG RAW"
#define RODBI_ROWID_NM       "ROWID"
#define RODBI_CHAR_NM        "CHAR"
#define RODBI_NCHAR_NM       "NCHAR"
#define RODBI_BFLOAT_NM      "BINARY_FLOAT"
#define RODBI_BDOUBLE_NM     "BINARY_DOUBLE"
#define RODBI_UDT_NM         "USER-DEFINED TYPE"
#define RODBI_REF_NM         "REF"
#define RODBI_CLOB_NM        "CLOB"
#define RODBI_NCLOB_NM       "NCLOB"
#define RODBI_BLOB_NM        "BLOB"
#define RODBI_BFILE_NM       "BFILE"
#define RODBI_TIME_NM        "TIMESTAMP"
#define RODBI_TIME_TZ_NM     "TIMESTAMP WITH TIME ZONE"
#define RODBI_INTER_YM_NM    "INTERVAL YEAR TO MONTH"
#define RODBI_INTER_DS_NM    "INTERVAL DAY TO SECOND"
#define RODBI_TIME_LTZ_NM    "TIMESTAMP WITH LOCAL TIME ZONE"
#define RODBI_BOOLEAN_NM     "BOOLEAN"
#define RODBI_VECTOR_NM      "VECTOR(%s)"

#define RODBI_CHECKWD        0xf8e9dacb          /* magic no. for checkword */


/* RODBI internal TYPe */
struct rodbiITyp
{
  char      *name_rodbiITyp;                                   /* type NAME */
  ub1        rtyp_rodbiITyp;                                      /* R TYPe */
  ub2        etyp_rodbiITyp;                               /* External TYPe */
  size_t     size_rodbiITyp;                                 /* buffer SIZE */
};
typedef struct rodbiITyp rodbiITyp;

extern const rodbiITyp rodbiITypTab[];

/* rodbi R TYPe */
struct rodbiRTyp
{
  char      *name_rodbiRTyp;                                   /* type NAME */
  SEXPTYPE   styp_rodbiRTyp;                                   /* SEXP TYPe */
};
typedef struct rodbiRTyp rodbiRTyp;


extern const rodbiRTyp rodbiRTypTab[];


#define RODBI_TYPE_R(ityp) rodbiITypTab[ityp].rtyp_rodbiITyp

#define RODBI_TYPE_SXP(ityp) \
                rodbiRTypTab[rodbiITypTab[ityp].rtyp_rodbiITyp].styp_rodbiRTyp

#define RODBI_NAME_INT(ityp) rodbiITypTab[ityp].name_rodbiITyp

#define RODBI_SIZE_EXT(ityp) rodbiITypTab[ityp].size_rodbiITyp

#define RODBI_NAME_CLASS(ityp) \
                rodbiRTypTab[rodbiITypTab[ityp].rtyp_rodbiITyp].name_rodbiRTyp


/*---------------------------------------------------------------------------
                          EXPORT FUNCTION DECLARATIONS
  ------------------------------------------------------------------------- */

/* ----------------------------- rodbicheckInterrupt ---------------------- */
/* check for user interrupt */
boolean rodbicheckInterrupt(void);

/* --------------------------- rodbiAssertCon ---------------------------- */
/* Assert that the connection is valid */
boolean rodbiAssertCon(void *proCon, const char *func, size_t pos);

/* --------------------------- rodbiAssertRes ---------------------------- */
/* Assert that the result set is valid */
boolean rodbiAssertRes(void *proRes, const char *func, size_t pos);

/* ----------------------------- rodbiTypeExt ---------------------------- */
/* Maps ROracle defined internal data type to Oracle external data type */
ub2 rodbiTypeExt(ub1 ityp);

/* ----------------------------- rodbiTypeInt ---------------------------- */
/* Maps Oracle external data type to ROracle defined internal data type */
ub1 rodbiTypeInt(roociCtx *pctx, ub2 ctyp, sb2 precision, sb1 scale, ub4 size,
                 boolean timesten, ub1 form);

/* Convert UCS2 to UTF8 */
sword rodbiTTConvertUCS2UTF8Data(roociRes *res, const ub2 *src,
                                 size_t srclen, char **tempbuf,
                                 size_t *tempbuflen);

#endif   /* end of _rodbi_H */
