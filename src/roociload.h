/* Copyright (c) 2011, 2024, Oracle and/or its affiliates. */
/* All rights reserved.*/

/*
   NAME
     roociload.h

   DESCRIPTION
     Load OCI functions from Oracle Client library used by ROracle.so for R.
   On Linux/UNIX libclntsh.so is loaded and all OCI public functions are
   resolved dyanmically. On Windows OCI.DLL is used to load the various
   OCI public functiosn used by ROracle.

   EXPORT FUNCTION(S)
     roociload__loadLib - Dynamially LOAD Oracle Client LIBrary

   INTERNAL FUNCTION(S)
     NONE

   NOTES

   MODIFIED   (MM/DD/YY)
   rpingte     01/24/24 - Creation from odpi-c
*/

#include <oci.h>

#ifndef _roociload_H
#define _roociload_H

/* define constants for success and failure of methods */
#define ROOCILOAD_FAILURE -1

// error numbers
typedef enum
{
  RORACLE_ERR_NO_ERR = 1000,
  RORACLE_ERR_CREATE_ENV,
  RORACLE_ERR_LOAD_LIBRARY,
  RORACLE_ERR_LOAD_SYMBOL,
  RORACLE_ERR_ORACLE_CLIENT_UNSUPPORTED,
  RORACLE_ERR_GET_FAILED,
  RORACLE_ERR_NO_MEMORY,
  RORACLE_ERR_NLS_ENV_VAR_GET,
  RORACLE_ERR_OS,
  RORACLE_ERR_UNKNOWN,
  RORACLE_ERR_INVALID_HANDLE,
  RORACLE_ERR_NOT_INITIALIZED,
  RORACLE_ERR_OCI_ERROR,
  RORACLE_ERR_MAX
} roociloadErrorNum;


struct roociloadVersion
{
  sword             maj_roociloadVersion;     /* OCI CLIENT Library VERsion */
                                 /* <major>.<minor>.<update>.<patch>.<port> */
  sword             minor_roociloadVersion;
  sword             update_roociloadVersion;
  sword             patch_roociloadVersion;
  sword             port_roociloadVersion;
};
typedef struct roociloadVersion roociloadVersion;

#define ROOCILOAD_ERR_LEN 4096

/*
  used to manage all errors that take place in the library; the implementation
  for the functions that use this structure are found in roociload.c; a pointer
  to this structure is passed to all internal functions and the first thing
  that takes place in every public function is a call to this this error
  structure                     
*/
struct roociloadCtx
{
  roociloadErrorNum  errorNum_roociloadCtx;                 /* error number */
  const char        *fnName_roociloadCtx;                  /* function name */
  const char        *action_roociloadCtx;                /* internal action */
  text               message_roociloadCtx[ROOCILOAD_ERR_LEN];
                                                    /* error message buffer */
  int                messageLength; 
  void              *loadLibHandle__roociloadCtx;
                        /* library handle for dynamically loaded OCI library */

};
typedef struct roociloadCtx roociloadCtx;


sword roociload__loadLib(roociloadVersion *clientVersionInfo,
                         roociloadCtx *loadCtx);

#endif /*end of _roociload_H */
