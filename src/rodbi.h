/* Copyright (c) 2011, 2016, Oracle and/or its affiliates. 
All rights reserved.*/

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
# define _(String) dgettext("ROracle", String)
#else
# define _(String) (String)
#endif

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
ub1 rodbiTypeInt(ub2 ctyp, sb2 precision, sb1 scale, ub4 size,
                 boolean timesten, ub1 form);

#endif   /* end of _rodbi_H */
