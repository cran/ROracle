#ifndef _RS_Oracle_H
#define _RS_Oracle_H 1
/*  $Id: RS-Oracle.h,v 1.1 2002/08/24 02:16:13 dj Exp dj $
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
 
#define  RS_ORA_VERSION "0.3-3"   /* R/S to Oracle client version */
#include "RS-DBI.h"

/* connections parameters that oracle understand. */
typedef struct st_ora_conparams{
  char *dbname;         /* i.e., Oracle SID (system id?) */
  char *user;
  char *passwd;
} RS_Ora_conParams;

/* We use these (instead of the SQLAlloc, etc.) for Oracle Version 7's sake*/
extern void sqlnul();   /* reads/clears NULL column attributes */
extern void sqlprc();   /* decodes Oracles' data types precision/scale */
extern void sqlglm();   /* extracts detail error messages/codes */
extern void sqlgls();   /* identifies SQL statements used in a dyn statment*/

EXEC SQL INCLUDE sqlca; /* #include <sqlca.h>, defines the sqlca struct*/
EXEC SQL INCLUDE sqlda; /* i.e., #include <sqlda.h> */
extern SQLDA *sqlald(); /* allocates bind variables, field-descriptors */

/* Oracle-specific magic numbers */
#define RS_ORA_MAX_STRING     4000  /* max VARCHAR2/String we'll import */
#define RS_ORA_STATEMENT_LEN  4000  /* dynamic statement length */
#define RS_ORA_MAX_ITEMS       256  /* max items in selects, SQL92 is 100 */
#define RS_ORA_MAX_VNAME_LEN    30  /* name len (ANSI SQL92 max is 18) */
#define RS_ORA_NUM_CURSORS      10  /* SQL92 max is 10, Oracle's 100 */

/* the following code is for the MODE=ORACLE default 
 * proc option.  The ORA_END_OF_DATA code should be 100 for
 * MODE=ANSI.
 */
#define ORA_END_OF_DATA       1403  /* no more data (+100 in SQL92)*/
#define ORA_SELECT_CODE         04  /* code for SELECT statement */

typedef struct st_sdbi_oraDesc {
  SQLDA  *bindVars;     /* SQL Desc Area for bind vars */
  SQLDA  *selectFlds;   /* SQL Desc Area for selecte'd fields */
} RS_Ora_desArea;

/* TODO: I can't believe this could be thread-safe */
EXEC SQL BEGIN DECLARE SECTION;
  VARCHAR db_alias[1024];
EXEC SQL END DECLARE SECTION;

#define ALIAS_PATTERN "RSORA_%02d" /* fake dbname for ea resultSet/Cursor */

/* The following functions are the S/R entry into the C implementation;
 * we use the prefix "RS_Ora" in functions to denote this.
 */
Mgr_Handle *RS_Ora_init(s_object *config_params, s_object *reload);           
s_object   *RS_Ora_close(Mgr_Handle *mgrHandle);          
Con_Handle *RS_Ora_newConnection(Mgr_Handle *mgrHandle, 
				 s_object *conn_params,
				 s_object *max_res);  
Con_Handle *RS_Ora_cloneConnection(Con_Handle *conHandle);
s_object   *RS_Ora_closeConnection(Con_Handle *conHandle);
Res_Handle *RS_Ora_exec(Con_Handle *conHandle, s_object *statement);
s_object   *RS_Ora_fetch(Res_Handle *rsHandle, s_object *max_rec);          

s_object *RS_Ora_closeResultSet(Res_Handle *rsHandle);  
void      RS_Ora_closeCursor(Res_Handle *rsHandle);
void      RS_Ora_commit();
void      RS_Ora_error();
void      RS_Ora_alloc_descriptors(int size, int max_vname, int max_iname);
void      RS_Ora_set_bind_variables();
RS_Ora_desArea *RS_Ora_allocDescriptors(int size,
					int max_vname_len,
					int max_iname_len);
void  RS_Ora_freeDescriptors(RS_Ora_desArea *desArea);
RS_DBI_fields *RS_Ora_setOraToSMappings(RS_Ora_desArea *desArea);

void  RS_Ora_varCharCpy(void *to, const char *from);
int   RS_Ora_getCursorNum(Res_Handle *rsHandle);
          
s_object *RS_Ora_typeNames(s_object *types);

/* The following are the oracle internal (IN) data types (See Tables
 * 14-1 and 14-2 in the Oracle's ProC/C++ Manual).  Internal, in this
 * case means internal to the Oracle server.
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

#ifdef _cplusplus
}
#endif
#endif    /* _RS_Oracle_H */

