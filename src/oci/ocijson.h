/* Copyright (c) 2018, 2021, Oracle and/or its affiliates.*/
/* All rights reserved.*/
 
/* 
   NAME 
     ocijson.h - Oracle Call Interface - Public interfaces for JSON

   DESCRIPTION 
     This header file contains C language callable interfaces, public types,
     and constants for JSON.

   PUBLIC FUNCTION(S) 
     OCIJsonBinaryBufferLoad
     OCIJsonBinaryLengthGet
     OCIJsonBinaryStreamLoad
     OCIJsonClone
     OCIJsonDomDocGet
     OCIJsonDomDocSet
     OCIJsonSchemaValidate
     OCIJsonTextBufferParse
     OCIJsonTextStreamParse
     OCIJsonToBinaryBuffer
     OCIJsonToBinaryStream
     OCIJsonToTextBuffer
     OCIJsonToTextStream

   NOTES


   MODIFIED   (MM/DD/YY)
   sriksure    11/01/21 - Project 83238: JSON schema validation support
   sriksure    08/26/19 - Bug 30193814: Add OCI_JSON_TEXT_ENV_NLS
   sriksure    03/15/19 - Bug 29455764: OCIJsonDomDocSet() requires void*
                          instead of OCISvcCtx*
   sriksure    11/15/18 - Project 77400: OCI and TTC support for JSON Type
   sriksure    09/16/18 - Creation

*/

#ifndef OCIJSON_ORACLE
# define OCIJSON_ORACLE

#ifndef ORATYPES 
# include <oratypes.h> 
#endif

#ifndef ORASTRUC
# include <orastruc.h>
#endif

#ifndef ORAJSON_ORACLE
# include <orajson.h>
#endif

#ifndef OCI_ORACLE
# include <oci.h>
#endif


/*---------------------------------------------------------------------------
                           PUBLIC TYPES AND CONSTANTS
  ---------------------------------------------------------------------------*/
/*------------------------------ OCI JSON Modes -----------------------------*/

/* OCIJsonToText specific modes */
#define OCI_JSON_TEXT_ENV_NLS      0x00010000  /* Output text in envh's csid */

/* Schema validator error mode */
#define  OCI_JSON_SCHEMA_ERROR_NONE    0     /* No error messages requested  */
#define  OCI_JSON_SCHEMA_ERROR_SIMPLE  1     /* Simplest, boolean field only */
#define  OCI_JSON_SCHEMA_ERROR_BASIC   2  /* Flat list of error output units */

/*---------------------------------------------------------------------------
                               PUBLIC FUNCTIONS
  ---------------------------------------------------------------------------*/

/*
  NOTE:
  !!! The descriptions of the functions are alphabetically arranged. Please 
      maintain the arrangement when adding a new function description. The
      actual prototypes are below this comment section and do not follow any
      alphabetical ordering.
*/

/*------------------------- OCIJsonBinaryBufferLoad -------------------------*/
/*
  NAME
    OCIJsonBinaryBufferLoad ()

  DESCRIPTION
    Loads a binary image (encoded JSON) from a buffer into the descriptor.

  SYNTAX
    sword OCIJsonBinaryBufferLoad (
      void        *hndlp,
      OCIJson     *jsond,
      ub1         *bufp,
      oraub8       buf_sz,
      OCIError    *errhp,
      ub4          mode
    );

  PARAMETERS
    hndlp   IN      An allocated OCI Service Context handle or working
                    OCI Environment handle.
    jsond   IN/OUT  An allocated OCI JSON descriptor.
    bufp    IN      Pointer to the input buffer.
    buf_sz  IN      Size of the input buffer, in bytes.
    errhp   IN/OUT  An allocated OCI Error handle.
    mode    IN      Specifies the mode of execution. Pass OCI_DEFAULT.

  SERVER ROUND TRIPS
    0

  RETURNS
    OCI_SUCCESS, if the read stream contained a valid JSON.
    OCI_SUCCESS_WITH_INFO, if input data was NULL.
    OCI_ERROR, if not. The OCIError parameter has the necessary error
    information.

  NOTES
  o  A subsequent read function can be called on this descriptor only if this
     write operation succeeded without errors. The descriptor is not restored
     to its previous state if the operation failed.

*/

/*------------------------- OCIJsonBinaryLengthGet --------------------------*/
/*
  NAME
    OCIJsonBinaryLengthGet ()

  Description
    Returns the size, in bytes, of the binary representation of JSON.

  SYNTAX
    sword OCIJsonBinaryLengthGet (
      OCISvcCtx    *svchp,
      OCIJson      *jsond,
      oraub8       *byte_amtp,
      OCIError     *errhp,
      ub4           mode
    );

  PARAMETERS
    svchp      IN      An allocated OCI Service Context handle.
    jsond      IN      A valid JSON Document descriptor.
    byte_amtp  OUT     The number of bytes in the JSON image.
    errhp      IN/OUT  An allocated OCI Error handle
    mode       IN      Specifies the mode of execution. Pass OCI_DEFAULT.

  SERVER ROUND TRIPS
    0 or 1

  RETURNS
    OCI_SUCCESS, if the length of the document image was read successfully.
    OCI_ERROR, if not. The OCIError parameter has the necessary error 
    information.
   
  NOTES
  o  If the JSON descriptor holds a mutable DOM, then this function returns
     the length of bytes corresponding to the linear binary representation.

*/

/*------------------------- OCIJsonBinaryStreamLoad -------------------------*/
/*
  NAME
    OCIJsonBinaryStreamLoad ()

  DESCRIPTION
    Loads a binary image (encoded JSON) from a stream into the descriptor.

  SYNTAX
    sword OCIJsonBinaryStreamLoad (
      void         *hndlp,
      OCIJson      *jsond,
      orastream    *r_stream,
      OCIError     *errhp,
      ub4           mode
    );

  PARAMETERS
    hndlp     IN      An allocated OCI Service Context handle or working
                      OCI Environment handle.
    jsond     IN/OUT  An allocated OCI JSON descriptor.
    r_stream  IN      Pointer to the orastream (read stream) input.
    errhp     IN/OUT  An allocated OCI Error handle.
    mode      IN      Specifies the mode of execution. Pass OCI_DEFAULT.

  SERVER ROUND TRIPS
    0

  RETURNS
    OCI_SUCCESS, if the read stream contained a valid JSON.
    OCI_SUCCESS_WITH_INFO, if input data was NULL.
    OCI_ERROR, if not. The OCIError parameter has the necessary error
    information.

  NOTES
  o  A subsequent read function can be called on this descriptor only if this
     write operation succeeded without errors. The descriptor is not restored
     to its previous state if the operation failed.
  o  If the input read stream is not open, it will be opened automatically.
     It is the user's responsibility to close it.

*/

/*------------------------------- OCIJsonClone ------------------------------*/
/*
  NAME
    OCIJsonClone ()

  DESCRIPTION
    Clones the descriptor and its associated binary image. Can be used to deep
    copy a JSON descriptor from one image form to the other.

  SYNTAX
    sword OCIJsonClone (
      OCISvcCtx    *svchp,
      OCIJson      *src_jsond,
      OCIJson      *dest_jsond,  
      OCIError     *errhp,
      ub4           mode
    );

  PARAMETERS
    svchp       IN      An allocated OCI Service Context handle.
    src_jsond   IN      A valid source JSON Document descriptor.
    dest_jsond  IN/OUT  Destination descriptor to be cloned to
    errhp       IN/OUT  An allocated OCI Error handle
    mode        IN      Specifies the mode of execution. Pass OCI_DEFAULT.

  SERVER ROUND TRIPS
    0 or 1

  RETURNS
    OCI_SUCCESS, if the descriptor is successfully cloned.
    OCI_ERROR, if not. The OCIError parameter has the necessary error
    information.

  NOTES
  o  A subsequent read function can be called on this descriptor only if this
     write operation succeeded without errors. The descriptor is not restored
     to its previous state if the operation failed.
*/

/*----------------------------- OCIJsonDomDocGet ----------------------------*/
/*
  NAME
    OCIJsonDomDocGet ()

  DESCRIPTION
    Returns the DOM Document container from a descriptor in the form set in the
    descriptor. This function is a single getter for a given descriptor.

  SYNTAX
    sword OCIJsonDomDocGet (
      OCISvcCtx      *svchp,
      OCIJson        *jsond,
      JsonDomDoc    **jDomDoc,
      OCIError       *errhp,
      ub4             mode
    );

  PARAMETERS
    svchp     IN      An allocated OCI Service Context handle.
    jsond     IN      An allocated OCI JSON descriptor
    jDomDoc   OUT     JSON DOM document container pointed by the JSON descriptor
    errhp     IN/OUT  An allocated OCI Error handle
    mode      IN      Specifies the mode of execution. Pass OCI_DEFAULT.

  RETURNS
    OCI_SUCCESS, if the document is successfully returned.
    OCI_ERROR, if not. The OCIError parameter has the necessary error
    information.

  SERVER ROUND TRIPS
    0 or 1

  NOTES
  o  By default, the function returns a Document Container (JsonDomDoc *) in
     the mode specified earlier. If it was never specified earlier, the
     function returns an immutable DOM.
  o  The JSON DOM Document returned by this function is freed automatically
     when the descriptor is freed, and should not be hard freed by the caller.

*/

/*----------------------------- OCIJsonDomDocSet ----------------------------*/
/*
  NAME
    OCIJsonDomDocSet ()

  DESCRIPTION
    Deep-copies the JSON DOM Document container and sets the new JSON DOM
    document in the descriptor.

  SYNTAX
    sword OCIJsonDomDocSet (
      void          *hndlp,
      OCIJson       *jsond,
      JsonDomDoc    *jDomDoc,
      OCIError      *errhp,
      ub4            mode
    );

  PARAMETERS
    hndlp     IN      An allocated OCI Service Context handle or working
                      OCI Environment handle.
    jsond     IN/OUT  An allocated OCI JSON descriptor.
    jDomDoc   IN      JSON DOM document container.
    errhp     IN/OUT  An allocated OCI Error handle.
    mode      IN      Specifies the mode of execution. Pass OCI_DEFAULT.

  RETURNS
    OCI_SUCCESS, if the document was set successfully.
    OCI_ERROR, if not. The OCIError parameter has the necessary error
    information. 

  SERVER ROUND TRIPS
    0

  NOTES
  o  It is the caller's responsibility to free the source DOM document
     supplied as input to this function.
  o  A subsequent read function can be called on this descriptor only if this
     write operation succeeded without errors. The descriptor is not restored
     to its previous state if the operation failed.

*/

/*--------------------------- OCIJsonSchemaValidate -------------------------*/
/*
  NAME
    OCIJsonSchemaValidate ()

  DESCRIPTION
    Validates a JSON document instance against a JSON schema. Detailed error
    messages are reported as a JSON instance in errors JSON descriptor.

  SYNTAX
    sword OCIJsonSchemaValidate (
      OCISvcCtx    *svchp,
      OCIJson      *jsond,
      OCIJson      *schemad,
      ub4           sflags,
      OCIJson      *errors,
      ub1           errmode,
      OCIError     *errhp,
      ub4           mode
    );

  PARAMETERS
    svchp      IN      An allocated OCI Service Context handle.
    jsond      IN      Document instance as a JSON descriptor
    schemad    IN      Schema instance as a JSON descriptor
    sflags     IN      Schema flags
    errors     IN/OUT  Error message report as a JSON descriptor
    errmode    IN      Mode of error reporting. Valid values are
                         o OCI_JSON_SCHEMA_ERROR_NONE   -
                            No error messages requested
                         o OCI_JSON_SCHEMA_ERROR_SIMPLE -
                            Simplest, with a boolean field only
                         o OCI_JSON_SCHEMA_ERROR_BASIC  - 
                            Flat list of error output units
    errhp      IN/OUT  An allocated OCI Error handle.
    mode       IN      Specifies the mode of execution.
                         o  OCI_DEFAULT - Is the default mode. It means execute
                            the operation as is with no special modes.

  SERVER ROUND TRIPS
    0 or 1

  RETURNS
    OCI_SUCCESS, if the schema validation was successful.
    OCI_ERROR, if not. The OCIError parameter has the necessary error
    information. More information are available in errors JSON descriptor
    based on error mode requested.

  NOTES

*/

/*-------------------------- OCIJsonTextBufferParse -------------------------*/
/*
  NAME
    OCIJsonTextBufferParse ()

  DESCRIPTION
    Parses a JSON text buffer of fixed size and writes to the descriptor,
    manifesting the binary image in a form specified by the mode.

  SYNTAX
    sword OCIJsonTextBufferParse (
      void        *hndlp,
      OCIJson     *jsond,
      void        *bufp,
      oraub8       buf_sz,
      ub4          validation,
      ub4          encoding,
      OCIError    *errhp,
      ub4          mode
    );

  PARAMETERS
    hndlp       IN      An allocated OCI Service Context handle or working
                        OCI Environment handle.
    jsond       IN/OUT  An allocated OCI JSON descriptor.
    bufp        IN      Pointer to the input buffer.
    buf_sz      IN      Size of the input buffer, in bytes.
    validation  IN      Parser validation mode. Valid values are:
                          o  JZN_ALLOW_UNQUOTED_NAMES
                          o  JZN_ALLOW_SINGLE_QUOTES
                          o  JZN_ALLOW_UNQUOTED_UNICODE
                          o  JZN_ALLOW_NUMERIC_QUIRKS
                          o  JZN_ALLOW_CONTROLS_WHITESPACE
                          o  JZN_ALLOW_TRAILING_COMMAS
                          o  JZN_ALLOW_MIXEDCASE_KEYWORDS
                          o  JZN_ALLOW_SCALAR_DOCUMENTS
                          o  JZN_ALLOW_RUBOUT
                          o  JZN_ALLOW_LEADING_BOM
                          o  JZN_ALLOW_NONE
                          o  JZN_ALLOW_ALL
                        See <jznev.h> for details on above values.
    encoding    IN      Character-set encoding of input textual JSON. Valid
                        values are:
                          o  JZN_INPUT_UTF8
                          o  JZN_INPUT_DETECT
                          o  JZN_INPUT_CONVERT
                          o  JZN_INPUT_UTF16
                          o  JZN_INPUT_UTF16_SWAP
                        See <jznev.h> for details on above values.
    errhp       IN/OUT  An allocated OCI Error handle.
    mode        IN      Specifies the mode of execution. Pass OCI_DEFAULT.

  SERVER ROUND TRIPS
    0

  RETURNS
    OCI_SUCCESS, if the buffer contained a valid JSON content.
    OCI_SUCCESS_WITH_INFO, if input data was NULL.
    OCI_ERROR, if not. The OCIError parameter has the necessary error
    information. 

  NOTES
  o  A subsequent read function can be called on this descriptor only if this
     write operation succeeded without errors. The descriptor is not restored
     to its previous state if the operation failed.

*/

/*-------------------------- OCIJsonTextStreamParse -------------------------*/
/*
  NAME
    OCIJsonTextStreamParse ()

  DESCRIPTION
    Parses textual JSON from a read orastream and writes to the descriptor,
    manifesting the binary image in a form specified by the mode.

  SYNTAX
    sword OCIJsonTextStreamParse (
      void         *hndlp,
      OCIJson      *jsond,
      orastream    *r_stream,
      ub4           validation,
      ub2           encoding,
      OCIError     *errhp,
      ub4           mode
    );

  PARAMETERS
    hndlp       IN      An allocated OCI Service Context handle or working
                        OCI Environment handle.
    jsond       IN/OUT  An allocated OCI JSON descriptor.
    r_stream    IN      Pointer to the orastream (read stream) input.
    errhp       IN/OUT  An allocated OCI Error handle.
    validation  IN      Parser validation mode. Valid values are:
                          o  JZN_ALLOW_UNQUOTED_NAMES
                          o  JZN_ALLOW_SINGLE_QUOTES
                          o  JZN_ALLOW_UNQUOTED_UNICODE
                          o  JZN_ALLOW_NUMERIC_QUIRKS
                          o  JZN_ALLOW_CONTROLS_WHITESPACE
                          o  JZN_ALLOW_TRAILING_COMMAS
                          o  JZN_ALLOW_MIXEDCASE_KEYWORDS
                          o  JZN_ALLOW_SCALAR_DOCUMENTS
                          o  JZN_ALLOW_RUBOUT
                          o  JZN_ALLOW_LEADING_BOM
                          o  JZN_ALLOW_NONE
                        See <jznev.h> for details on above values.
    encoding    IN      Character-set encoding of input textual JSON. Valid
                        values are:
                          o  JZN_INPUT_UTF8
                          o  JZN_INPUT_DETECT
                          o  JZN_INPUT_CONVERT
                          o  JZN_INPUT_UTF16
                          o  JZN_INPUT_UTF16_SWAP
                        See <jznev.h> for details on above values.
    mode        IN      Specifies the mode of execution. Pass OCI_DEFAULT.

  SERVER ROUND TRIPS
    0

  RETURNS
    OCI_SUCCESS, if the read stream contained a valid JSON.
    OCI_SUCCESS_WITH_INFO, if input data was NULL.
    OCI_ERROR, if not. The OCIError parameter has the necessary error
    information. 

  NOTES
  o  A subsequent read function can be called on this descriptor only if this
     write operation succeeded without errors. The descriptor is not restored
     to its previous state if the operation failed.
  o  If the input read stream is not open, it will be opened automatically.
     It is the user's responsibility to close it.

*/

/*--------------------------- OCIJsonToBinaryBuffer -------------------------*/
/*
  NAME
    OCIJsonToBinaryBuffer ()

  DESCRIPTION
    Returns the binary image bytes in a JSON document descriptor into the
    user's buffer.

  SYNTAX
    sword OCIJsonToBinaryBuffer (
      OCISvcCtx    *svchp,
      OCIJson      *jsond,
      ub1          *bufp,
      oraub8       *byte_amtp,
      OCIError     *errhp,
      ub4           mode
    );

  PARAMETERS
    svchp      IN      An allocated OCI Service Context handle.
    jsond      IN      A valid JSON Document descriptor.
    bufp       IN/OUT  The pointer to a buffer into which the piece will be
                       read. The length of the allocated memory is assumed to
                       be bufl.
    byte_amtp  IN/OUT  IN - The size of the input buffer.
                       OUT - The number of bytes read into the user buffer.
    errhp      IN/OUT  An allocated OCI Error handle
    mode       IN      Specifies the mode of execution. Pass OCI_DEFAULT. 

  SERVER ROUND TRIPS
    0 or 1

  RETURNS
    OCI_SUCCESS, if the document image was read successfully.
    OCI_SUCCESS_WITH_INFO, if the descriptor was empty.
    OCI_ERROR, if not. The OCIError parameter has the necessary error
    information. 

  NOTES
  o  An error is raised if the input size buffer is not big enough to
     accommodate the binary image size. In that case, the user might use a
     streaming interface, or find the actual image size using 
     OCIJsonBinaryLengthGet ().
  o  If the JSON descriptor holds a mutable DOM, then this function returns
     the bytes corresponding to the linear binary representation.

*/

/*--------------------------- OCIJsonToBinaryStream -------------------------*/
/*
  NAME
    OCIJsonToBinaryStream ()

  DESCRIPTION
    Returns the binary image bytes in a JSON document descriptor into the
    user's write-stream.

  SYNTAX
    sword OCIJsonToBinaryStream (
      OCISvcCtx    *svchp,
      OCIJson      *jsond,
      orastream    *w_stream,
      oraub8       *byte_amtp,
      OCIError     *errhp,
      ub4           mode
    );

  PARAMETERS
    svchp      IN      An allocated OCI Service Context handle.
    jsond      IN      An allocated OCI JSON descriptor.
    w_stream   IN      Pointer to the orastream (write stream) input.
    byte_amtp  OUT     Total number of bytes corresponding the textual JSON
                       written to the stream.
    errhp      IN/OUT  An allocated OCI Error handle.
    mode       IN      Specifies the mode of execution. Pass OCI_DEFAULT. 

  SERVER ROUND TRIPS
    0 or 1

  RETURNS
    OCI_SUCCESS, if the textual string was written to the steam successfully.
    OCI_SUCCESS_WITH_INFO, if the descriptor was empty.
    OCI_ERROR, if not. The OCIError parameter has the necessary error
    information. 

  NOTES
  o  If the JSON descriptor holds a mutable DOM, then this function returns
     the bytes corresponding to the linear binary representation.
  o  If the output write stream is not open, it will be opened automatically.
     It is the user's responsibility to close it.
     

*/

/*---------------------------- OCIJsonToTextBuffer --------------------------*/
/*
  NAME
    OCIJsonToTextBuffer ()

  DESCRIPTION
    Returns the textual string representation of the JSON content in the
    descriptor. The textual string is written to the user's buffer.

  SYNTAX
    sword OCIJsonToTextBuffer (
      OCISvcCtx    *svchp,
      OCIJson      *jsond,
      oratext      *bufp,
      oraub8       *byte_amtp,
      ub4           print,
      OCIError     *errhp,
      ub4           mode
    );

  PARAMETERS
    svchp      IN      An allocated OCI Service Context handle.
    jsond      IN      An allocated OCI JSON descriptor.
    bufp       IN      The pointer to a buffer into which the textual JSON 
                       will be written. The length of the allocated memory is
                       assumed to be byte_amtp.
    byte_amtp  IN/OUT  IN - The input size of the linear buffer.
                       OUT - The number of bytes read into the user buffer.
    print     IN       Writer flags for output textual JSON. Valid values are:
                         o  JZNU_PRINT_PRETTY
                         o  JZNU_PRINT_ASCII
                         o  JZNU_PRINT_NUMFORMAT
                       See <jznev.h> for details on above values.
    errhp      IN/OUT  An allocated OCI Error handle.
    mode       IN      Specifies the mode of execution.
                         o  OCI_DEFAULT - Is the default mode. It means execute
                            the operation as is with no special modes.
                         o  OCI_JSON_TEXT_ENV_NLS - When the function is called
                            in this mode, the output textual JSON is returned
                            in the character set of the working environment.

  SERVER ROUND TRIPS
    0 or 1

  RETURNS
    OCI_SUCCESS, if the textual string was written to the steam successfully.
    OCI_SUCCESS_WITH_INFO, if the descriptor was empty.
    OCI_ERROR, if not. The OCIError parameter has the necessary error
    information. 

  NOTES
  o  An error is raised if the input buffer it not big enough to accommodate
     the textual JSON. In that case, the user may use the streaming interface
     or provide a bigger buffer.
  o  The textual JSON returned will be in AL32UTF8 character set, unless 
     OCI_JSON_TEXT_ENV_NLS mode is set.

*/

/*---------------------------- OCIJsonToTextStream --------------------------*/
/*
  NAME
    OCIJsonToTextStream ()

  DESCRIPTION
    Returns the textual string representation of the JSON content in the
    descriptor. The textual string is written to the user's write stream.

  SYNTAX
    sword OCIJsonToTextStream (
      OCISvcCtx    *svchp,
      OCIJson      *jsond,
      orastream    *w_stream,
      oraub8       *byte_amtp,
      ub4           print,
      OCIError     *errhp,
      ub4           mode
    );

  PARAMETERS
    svchp      IN      An allocated OCI Service Context handle.
    jsond      IN      An allocated OCI JSON descriptor.
    w_stream   IN      Pointer to the orastream (write stream) input.
    byte_amtp  OUT     Total number of bytes corresponding the textual JSON
                       written to the stream.
    print     IN       Writer flags for output textual JSON. Valid values are:
                         o  JZNU_PRINT_PRETTY
                         o  JZNU_PRINT_ASCII
                         o  JZNU_PRINT_NUMFORMAT
                       See <jznev.h> for details on above values.
    errhp      IN/OUT  An allocated OCI Error handle.
    mode       IN      Specifies the mode of execution.
                         o  OCI_DEFAULT - Is the default mode. It means execute
                            the operation as is with no special modes.
                         o  OCI_JSON_TEXT_ENV_NLS - When the function is called
                            in this mode, the output textual JSON is returned
                            in the character set of the working environment.

  SERVER ROUND TRIPS
    0 or 1

  RETURNS
    OCI_SUCCESS, if the textual string was written to the steam successfully.
    OCI_SUCCESS_WITH_INFO, if the descriptor was empty.
    OCI_ERROR, if not. The OCIError parameter has the necessary error
    information. 

  NOTES
  o  The textual JSON returned will be in AL32UTF8 character set, unless 
     OCI_JSON_TEXT_ENV_NLS mode is set.
  o  If the output write stream is not open, it will be opened automatically.
     It is the user's responsibility to close it.

*/


/*---------------------------------------------------------------------------
                           PROTOTYPE DEFINITIONS
  ---------------------------------------------------------------------------*/

sword OCIJsonBinaryBufferLoad (
  void          *hndlp,
  OCIJson       *jsond,
  ub1           *bufp,
  oraub8         buf_sz,
  OCIError      *errhp,
  ub4            mode
);


sword OCIJsonBinaryLengthGet (
  OCISvcCtx     *svchp,
  OCIJson       *jsond,
  oraub8        *byte_amtp,
  OCIError      *errhp,
  ub4            mode
);


sword OCIJsonBinaryStreamLoad (
  void          *hndlp,
  OCIJson       *jsond,
  orastream     *r_stream,
  OCIError      *errhp,
  ub4            mode
);


sword OCIJsonClone (
  OCISvcCtx    *svchp,
  OCIJson      *src_jsond,
  OCIJson      *dest_jsond,  
  OCIError     *errhp,
  ub4           mode
);


sword OCIJsonDomDocGet (
  OCISvcCtx      *svchp,
  OCIJson        *jsond,
  JsonDomDoc    **jDomDoc,
  OCIError       *errhp,
  ub4             mode
);


sword OCIJsonDomDocSet (
  void          *hndlp,
  OCIJson       *jsond,
  JsonDomDoc    *jDomDoc,
  OCIError      *errhp,
  ub4            mode
);


sword OCIJsonTextBufferParse (
  void          *hndlp,
  OCIJson       *jsond,
  void          *bufp,
  oraub8         buf_sz,
  ub4            validation,
  ub2            encoding,
  OCIError      *errhp,
  ub4            mode
);


sword OCIJsonTextStreamParse (
  void          *hndlp,
  OCIJson       *jsond,
  orastream     *r_stream,
  ub4            validation,
  ub2            encoding,
  OCIError      *errhp,
  ub4            mode
);


sword OCIJsonToBinaryBuffer (
  OCISvcCtx    *svchp,
  OCIJson      *jsond,
  ub1          *bufp,
  oraub8       *byte_amtp,
  OCIError     *errhp,
  ub4           mode
);


sword OCIJsonToBinaryStream (
  OCISvcCtx    *svchp,
  OCIJson      *jsond,
  orastream    *w_stream,
  oraub8       *byte_amtp,
  OCIError     *errhp,
  ub4           mode
);


sword OCIJsonToTextBuffer (
  OCISvcCtx    *svchp,
  OCIJson      *jsond,
  oratext      *bufp,
  oraub8       *byte_amtp,
  ub4           print,
  OCIError     *errhp,
  ub4           mode
);


sword OCIJsonToTextStream (
  OCISvcCtx    *svchp,
  OCIJson      *jsond,
  orastream    *w_stream,
  oraub8       *byte_amtp,
  ub4           print,
  OCIError     *errhp,
  ub4           mode
);

sword OCIJsonSchemaValidate (
  OCISvcCtx    *svchp,
  OCIJson      *jsond,
  OCIJson      *schemad,
  ub4           sflags,
  OCIJson      *errors,
  ub1           errmode,
  OCIError     *errhp,
  ub4           mode
);


#endif                                              /* OCIJSON_ORACLE */
