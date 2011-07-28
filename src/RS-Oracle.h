#ifndef _RS_Oracle_H
#define _RS_Oracle_H 1
/*  $Id: RS-Oracle.h st_server_demukhin_r/1 2011/07/22 22:11:38 vsashika Exp $
 *
 * Copyright (C) 1999 The Omega Project for Statistical Computing.
 *
 * http://www.omegahat.org
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifdef _cplusplus
extern "C" {
#endif
 
#define  RS_ORA_VERSION "$Revision: st_server_demukhin_r/1 $"   
#include "RS-DBI.h"

#define RS_Ora_Min(a, b)  ((a)<=(b) ? (a) : (b))
#define RS_Ora_Max(a, b)  ((a)>=(b) ? (a) : (b))

/* connections parameters that oracle understand. */
typedef struct st_ora_conparams{
  char *dbname;         /* i.e., Oracle SID (system id?) */
  char *user;
  char *passwd;
} RS_Ora_conParams;

EXEC SQL INCLUDE SQLCA;    /* #include <sqlca.h>, defines the sqlca struct*/
EXEC SQL INCLUDE SQLDA;    /* i.e., #include <sqlda.h> */

/* We use these (instead of the SQLAlloc, etc.) for Oracle Version 7's sake*/
#if 1
  extern void sqlnul();   /* reads/clears NULL column attributes */
  extern void sqlprc();   /* decodes Oracles' data types precision/scale */
  extern void sqlglm();   /* extracts detail error messages/codes (p. 11-23) */
  extern void sqlgls();   /* returns SQL in dyn statement (p. 11-32) */
  extern void sqlclu();   /* copied from Oracle's sqlcpr.h */
  extern SQLDA *sqlald(); /* allocates bind variables, field-descriptors */
#else
  EXEC SQL INCLUDE sqlcpr;
#endif

/* Oracle-specific magic numbers */
#define RS_ORA_MAX_STRING      4000  /* max VARCHAR2/String we'll import */
#define RS_ORA_STATEMENT_LEN  200000 /* dynamic statement length */
#define RS_ORA_MAX_ITEMS        256  /* max items in selects, SQL92 is 100 */
#define RS_ORA_MAX_VNAME_LEN     30  /* name len (ANSI SQL92 max is 18) */
#define RS_ORA_NUM_CURSORS       10  /* SQL92 max is 10, Oracle's 100 */
#define RS_ORA_MAX_BUFFER_SIZE 4096  /* max size of host arrays */
#define RS_ORA_DEFAULT_BUFFER_SIZE 500  /* should this be connection specific?*/

/* end of data (when proc's MODE=ORACLE) */
#define ORA_END_OF_DATA       1403  /* no more data (+100 in SQL92)*/


/* Oracle manager */
Mgr_Handle *RS_Ora_init(s_object *config_params, s_object *reload);           
s_object   *RS_Ora_close(Mgr_Handle *mgrHandle);          
Con_Handle *RS_Ora_newConnection(Mgr_Handle *mgrHandle, 
				 s_object *conn_params,
				 s_object *max_res);  
/* Oracle connections */
Con_Handle *RS_Ora_cloneConnection(Con_Handle *conHandle);
s_object   *RS_Ora_closeConnection(Con_Handle *conHandle);

/* Oracle Result sets */
Res_Handle *
RS_Ora_prepareStatement(Con_Handle *conHandle, s_object *statement, 
   s_object *s_col_classes);

Res_Handle *
RS_Ora_exec(Res_Handle *rsHandle, s_object *input, s_object *s_col_classes,
   s_object *ora_buf_size);

s_object *
RS_Ora_boundParamsInfo(Res_Handle *psHandle);

s_object *
RS_Ora_fetch(Res_Handle *rsHandle, s_object *max_rec, s_object *ora_buf_size);

s_object *RS_Ora_closeResultSet(Res_Handle *rsHandle);  
void      RS_Ora_closeCursor(Res_Handle *rsHandle);

/* Transactions (un-implemented) */
s_object *RS_Ora_commit(/* Con_Handle *conHandle */);


/* the following functions deal with mapping and moving data from
 * Oracle's buffers into data.frames and viceversa.  Note the heavy 
 * reliance on the descriptor areas -- two structs that fully describe 
 * the fields coming from Oracle as a result of a SELECT query and
 * another very similar used to move data from S data.frames to
 * Oracle (bind_dp).
 */

typedef struct st_sdbi_oraDesc {
  SQLDA  *bindVars;     /* SQL Desc Area for bind vars */
  SQLDA  *selectFlds;   /* SQL Desc Area for selecte'd fields */
  Sint   bufferSize;    /* actual size of data buffers (host arrays) */
  int    batchNum;      /* num of times buffers have been filled */
  Sint   numParams;     /* num of bound R/S-Plus variables (parameters) */
  Stype  *Sclass;       /* types of R/S-Plus bound fields */
  Sint   *which;        /* column numbers of the bound params in data.frame */
} RS_Ora_desArea;       /* TODO: should we add S bound df and its *fields? */

RS_Ora_desArea *
RS_Ora_allocDescriptors(int size, int max_vname_len, 
   int max_iname_len, Sint buf_size);

void RS_Ora_freeDescriptors(RS_Ora_desArea *desArea);

/* the following creates a fields description from which a data.frame 
 * can be created from the Oracle's buffers. 
 */
RS_DBI_fields *RS_Ora_setOraToSMappings(RS_Ora_desArea *desArea);

/* this copies nrows from Oracle's buffers into an existing data.frame */
void 
RS_Ora_cpyOraToDataFrame(SQLDA *select_dp, int nrows, 
   s_object *output, int from, RS_DBI_fields *flds);

/* the following two functions deal with "bind parameters" -- this
 * is how S users can bind columns in a data.frame to dynamic SQL
 * statements.  The RS_Ora_setSToOraMappins() (only) describes S objects
 * bound in an SQL statement into the bind_dp Oracle description 
 * area object suitable for eventual transfer into the DB server.
 * The RS_Ora_dataFrameToDesArea() actually copies subsets of the
 * data.frame into Oracle's buffers.
 */
int  RS_Ora_setSToOraMappings(RS_Ora_desArea *desArea, s_object *s_col_classes);
int RS_Ora_cpyDataFrameToOra(s_object *input, s_object *s_data_class,
       int from, int nrows, RS_Ora_desArea *desArea);

/* some facilities to get around some ProC/C++ limitations (see the code) */

#define ALIAS_PATTERN "RSORA_%02d" /* fake dbname for ea resultSet/Cursor */

EXEC SQL BEGIN DECLARE SECTION;
  VARCHAR db_alias[1024];          /* TODO: make this thread-safe */
EXEC SQL END DECLARE SECTION;

int  RS_Ora_getCursorNum(Res_Handle *rsHandle);

/* helper functions */

void     RS_Ora_varCharCpy(void *to, const char *from);
s_object *RS_Ora_typeNames(s_object *types);
Stype    *RS_SclassNames_To_StypeIds(s_object *s_col_classes);
void     RS_Ora_error();

/* The following are the oracle internal (IN) data types (See Tables
 * 14-1 and 14-2 in the Oracle's ProC/C++ Manual).  Internal, in this
 * case, means internal to the Oracle server.
 */
#define ORA_IN_VARCHAR2  1  /* VARCHAR2(n), n<=4000 */
#define ORA_IN_NUMBER    2  /* NUMBER(p, s) 1<=p<=38, -84<=s<=127 
			     * NUMBER (w.o p/s) is a float */
#define ORA_IN_LONG      8  /* char[n], n <= 2**16 - 1 */
#define ORA_IN_ROWID    11  /* unique id for a row (as char) */
#define ORA_IN_DATE     12  /* 7-byte Oracle's internal date format */
#define ORA_IN_RAW      23  /* RAW(size) size up to 2000 */
#define ORA_IN_LONGRAW  24  /* RAW up to 2 gigabytes */
#define ORA_IN_CHAR     96  /* fixed CHAR(size) 1(default) up to 2000 */
#define ORA_IN_MLSLABEL 106 /* this are op. sys. labels? */
#define ORA_IN_CLOB    112  /* character (byte) large object */
#define ORA_IN_BLOB    113  /* binary large object */
#define ORA_IN_BFILE   114  /* binary file locator */

/* Oracle external (EX) data types with C equivalents (See Ch 14, p14
 * and Table 3-2), "external" to Oracle, e.g., C types.
 * We use these "external" types during fetching to specify how the 
 * Oracle automatic conversion should export to our C host variables 
 * the server internal types.
 */
#define ORA_EX_VARCHAR2  1  /* char[n] (n<=65530) */
#define ORA_EX_NUMBER    2  /* char[n] n=22 */
#define ORA_EX_INTEGER   3  /* int */
#define ORA_EX_FLOAT     4  /* float */
#define ORA_EX_STRING    5  /* char[n+1] (n<=2000?) */
#define ORA_EX_VARNUM    6  /* char[n] n=22 */
#define ORA_EX_DECIMAL   7  /* float */
#define ORA_EX_LONG      8  /* char[n] (n<=65330?) */
#define ORA_EX_VARCHAR   9  /* char[n+2] (n<=65530) */
#define ORA_EX_ROWID    11  /* char[n] (n = 13, "typically")*/
#define ORA_EX_DATE     12  /* char[n] */
#define ORA_EX_VARRAW   15  /* char[n] (n <= 65330) */
#define ORA_EX_RAW      23  /* unsigned char[n] (n<=255) */
#define ORA_EX_LONGRAW  24  /* unsigned char[n] (n <= 2**31-1) */
#define ORA_EX_UNSIGNED 68  /* unsigned int  */
#define ORA_EX_DISPLAY  91  /* char[n] */
#define ORA_EX_LONG_VARCHAR 94  /* char[n+4] */
#define ORA_EX_LONG_VARRAW  95  /* unsigned char[n+4] (n<=2**31-1) */
#define ORA_EX_CHAR     96  /* char[n] (n <= 255) */
#define ORA_EX_CHARF    96  /* char[n] (fixed) (n <= 255) */
#define ORA_EX_CHARZ    97  /* char[n+1] (fixed + null-term, n<=255) */
#define ORA_EX_MLSLABEL 106  /* char[n] (n is os-dependent) */

/* User-friendly Oracle (external) datatype */
static struct data_types RS_Ora_dataTypes[] = {
   {"CHAR",	ORA_EX_CHAR	},
   {"VARCHAR",	ORA_EX_VARCHAR	},
   {"VARCHAR2",	ORA_EX_VARCHAR2	},
   {"STRING",	ORA_EX_STRING	},
   {"NUMBER",	ORA_EX_NUMBER	},
   {"FLOAT",	ORA_EX_FLOAT	},
   {"DECIMAL",	ORA_EX_DECIMAL	},
   {"INTEGER",	ORA_EX_INTEGER	},
   {"DATE",	ORA_EX_DATE	},
   {"LONG",	ORA_EX_LONG	},
   {"LONGRAW",	ORA_EX_LONGRAW	},
   {"LONG_VARCHAR", ORA_EX_LONG_VARCHAR	},
   {"VARNUM",	ORA_EX_VARNUM	},
   {"CHARF",	ORA_EX_CHARF	},
   {"CHARZ",	ORA_EX_CHARZ	},
   {"DISPLAY",	ORA_EX_DISPLAY	},
   {"MLSLABEL",	ORA_EX_MLSLABEL	},
   {"RAW",	ORA_EX_RAW	},
   {"ROWID",	ORA_EX_ROWID	},
   {"UNSIGNED",	ORA_EX_UNSIGNED	},
   {"VARRAW",	ORA_EX_VARRAW	},
   {"CLOB",	ORA_IN_CLOB	},    /* TODO: Not yet implemented */
   {"BLOB",	ORA_IN_BLOB	},    /* TODO: Not yet implemented */
   {"BFILE",	ORA_IN_BFILE	},    /* TODO: Not yet implemented */
   {(char *)NULL,  -1 }
};

/* These codes are what sqlgls() returns. Note that sqlgls() does not
 * return the text for CONNECT, COMMIT, ROLLBACK and FETCH, and there
 * are no codes for these.  See page 11-33 in the ProC/C++ manual.
 */
#define ORA_SQL_CODE_CREATE_TABLE             01
#define ORA_SQL_CODE_SET_ROLEA                02
#define ORA_SQL_CODE_INSERT                   03
#define ORA_SQL_CODE_SELECT                   04
#define ORA_SQL_CODE_UPDATE                   05
#define ORA_SQL_CODE_DROP_ROLE                06
#define ORA_SQL_CODE_DROP_VIEW                07
#define ORA_SQL_CODE_DROP_TABLE               08
#define ORA_SQL_CODE_DELETE                   09
#define ORA_SQL_CODE_CREATE_VIEW              10
#define ORA_SQL_CODE_DROP_USER                11
#define ORA_SQL_CODE_CREATE_ROLE              12
#define ORA_SQL_CODE_CREATE_SEQUENCE          13
#define ORA_SQL_CODE_ALTER_SEQUENCE           14
#define ORA_SQL_CODE_DROP_SEQUENCE            16
#define ORA_SQL_CODE_CREATE_SCHEMA            17
#define ORA_SQL_CODE_CREATE_CLUSTER           18
#define ORA_SQL_CODE_CREATE_USER              19
#define ORA_SQL_CODE_CREATE_INDEX             20
#define ORA_SQL_CODE_DROP_INDEX               21
#define ORA_SQL_CODE_DROP_CLUSTER             22
#define ORA_SQL_CODE_VALIDATE_INDEX           23
#define ORA_SQL_CODE_CREATE_PROCEDURE         24
#define ORA_SQL_CODE_ALTER_PROCEDURE          25
#define ORA_SQL_CODE_ALTER_TABLE              26
#define ORA_SQL_CODE_EXPLAIN                  27
#define ORA_SQL_CODE_GRANT                    28
#define ORA_SQL_CODE_REVOKE                   29
#define ORA_SQL_CODE_CREATE_SYNONYM           31
#define ORA_SQL_CODE_DROP_SYNONYM             31
#define ORA_SQL_CODE_ALTER_SYSTEM_SWITCH_LOG  32
#define ORA_SQL_CODE_SET_TRANSACTION          33
#define ORA_SQL_CODE_PL_SQL_EXECUTE           34
#define ORA_SQL_CODE_LOCK_TABLE               35
#define ORA_SQL_CODE_RENAME                   37
#define ORA_SQL_CODE_COMMENT                  38
#define ORA_SQL_CODE_AUDIT                    39
#define ORA_SQL_CODE_NOAUDIT                  40
#define ORA_SQL_CODE_ALTER_INDEX              41
#define ORA_SQL_CODE_CREATE_EXTERNAL_DATABASE 42
#define ORA_SQL_CODE_DROP_EXTERNAL_DATABASE   43
#define ORA_SQL_CODE_CREATE_DATABASE          44
#define ORA_SQL_CODE_ALTER_DATABASE           45
#define ORA_SQL_CODE_CREATE_ROLLBACK_SEGMENT  46
#define ORA_SQL_CODE_ALTER_ROLLBACK_SEGMENT   47
#define ORA_SQL_CODE_DROP_ROLLBACK_SEGMENT    48
#define ORA_SQL_CODE_CREATE_TABLESPACE        49
#define ORA_SQL_CODE_ALTERTABLESPACE          50
#define ORA_SQL_CODE_DROP_TABLESPACE          51
#define ORA_SQL_CODE_ALTER_SESSION            52
#define ORA_SQL_CODE_ALTER_USER               53
#define ORA_SQL_CODE_COMMIT                   54
#define ORA_SQL_CODE_ROLLBACK                 55
#define ORA_SQL_CODE_SAVEPOINT                56
#define ORA_SQL_CODE_CREATE_CONTROL_FILE      57
#define ORA_SQL_CODE_ALTER_TRACING            58
#define ORA_SQL_CODE_CREATE_TRIGGER           59
#define ORA_SQL_CODE_ALTERTRIGGER             60
#define ORA_SQL_CODE_DROP_TRIGGER             61
#define ORA_SQL_CODE_ANALYZE_TABLE            62
#define ORA_SQL_CODE_ANALYZE_INDEX            63
#define ORA_SQL_CODE_ANALYZE_CLUSTER          64
#define ORA_SQL_CODE_CREATE_PROFILE           65
#define ORA_SQL_CODE_DROP_PROFILE             66
#define ORA_SQL_CODE_ALTER_PROFILE            67
#define ORA_SQL_CODE_DROP_PROCEDURE           68
#define ORA_SQL_CODE_ALTER_RESOURCE_COST      70
#define ORA_SQL_CODE_CREATE_SNAPSHOT_LOG      71
#define ORA_SQL_CODE_ALTER_SNAPSHOT_LOG       72
#define ORA_SQL_CODE_DROP_SNAPSHOT_LOG        73
#define ORA_SQL_CODE_CREATE_SNAPSHOT          74
#define ORA_SQL_CODE_ALTER_SNAPSHOT           75
#define ORA_SQL_CODE_DROP_SNAPSHOT            76

#ifdef _cplusplus
}
#endif
#endif    /* _RS_Oracle_H */

