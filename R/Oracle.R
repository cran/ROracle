##
## $Id: Oracle.R st_server_demukhin_r/1 2011/07/22 22:11:36 vsashika Exp $
##
## Copyright (C) 1999-2002 The Omega Project for Statistical Computing.
##
## This library is free software; you can redistribute it and/or
## modify it under the terms of the GNU Lesser General Public
## License as published by the Free Software Foundation; either
## version 2 of the License, or (at your option) any later version.
##
## This library is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## Lesser General Public License for more details.
##
## You should have received a copy of the GNU Lesser General Public
## License along with this library; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

##
## Constants (.OraSQLKeywords is defined in OraSupport.q)
##

.OraPkgName <- "ROracle"  
.OraPkgRCS  <- "$Id: Oracle.R st_server_demukhin_r/1 2011/07/22 22:11:36 vsashika Exp $"
.OraPkgVersion <- "0.5-9" #package.description(.OraPkgName, fields = "Version")
.Ora.NA.string <- ""         ## char that Oracle maps to NULL

setOldClass("data.frame") ## to appease setMethod's signature warnings...

## ------------------------------------------------------------------
## Begin DBI extensions: 
##
## class DBIPreparedStatment and generics dbPrepareStatement, and
## dbExecStatement
##
setClass("DBIPreparedStatement", representation("DBIObject", "VIRTUAL"))
setGeneric("dbPrepareStatement", 
   def = function(conn, statement, bind, ...) {
      standardGeneric("dbPrepareStatement")
   },
   valueClass = "DBIPreparedStatement"
)
setGeneric("dbExecStatement",
   def = function(ps, data, ...){
      standardGeneric("dbExecStatement")
   },
   valueClass = "DBIPreparedStatement"
)
##
## End DBI extensions
## ------------------------------------------------------------------


##
## Class: DBIObject
##
## (OraObject needs to be virtual to prevent coercion, see Green Book)
setClass("OraObject", representation("DBIObject", "dbObjectId", "VIRTUAL"))

##
## Class: DBIDriver
##
setClass("OraDriver", representation("DBIDriver", "OraObject"))

## coerce (extract) any OraObject into a OraDriver
setAs("OraObject", "OraDriver", 
   def = function(from) new("OraDriver", Id = as(from, "integer")[1])
)

"Oracle" <- 
function(max.con=10, fetch.default.rec = 500, force.reload=FALSE)
{
   oraInitDriver(max.con, fetch.default.rec, force.reload)
}

setMethod("dbUnloadDriver", "OraDriver",
   def = function(drv, ...) oraCloseDriver(drv, ...),
   valueClass = "logical"
)

setMethod("dbGetInfo", "OraDriver", 
   def = function(dbObj, ...) oraDriverInfo(dbObj, ...)
)

setMethod("dbListConnections", "OraDriver",
   def = function(drv, ...) dbGetInfo(drv, "connectionIds")[[1]]
)

setMethod("summary", "OraDriver", 
   def = function(object, ...) oraDescribeDriver(object, ...)
)

##
## Class: DBIConnection
##
setClass("OraConnection", representation("DBIConnection", "OraObject"))

setMethod("dbConnect", "OraDriver",
   def = function(drv, ...) oraNewConnection(drv, ...),
   valueClass = "OraConnection"
)

## TODO: should this be moved to DBI? (short hand for dbConnect("Oracle", ...))
setMethod("dbConnect", "character",
   def = function(drv, ...) oraNewConnection(dbDriver(drv), ...),
   valueClass = "OraConnection"
)

## clone a connection
setMethod("dbConnect", "OraConnection",
   def = function(drv, ...) oraCloneConnection(drv, ...),
   valueClass = "OraConnection"
)

setMethod("dbDisconnect", "OraConnection",
   def = function(conn, ...) oraCloseConnection(conn, ...),
   valueClass = "logical"
)

setMethod("dbSendQuery", 
   signature(conn = "OraConnection", statement = "character"),
   def = function(conn, statement, ...) oraExecDirect(conn, statement, ...),
   valueClass = "OraResult"
)

setMethod("dbGetQuery", 
   signature(conn = "OraConnection", statement = "character"),
   def = function(conn, statement, ...) oraQuickSQL(conn, statement, ...)
)

setMethod("dbGetException", "OraConnection",
   def = function(conn, ...)
      .Call("RS_Ora_getException", as(conn, "integer"), PACKAGE = .OraPkgName),
   valueClass = "list"
)

setMethod("dbGetInfo", "OraConnection",
   def = function(dbObj, ...) oraConnectionInfo(dbObj, ...)
)

setMethod("dbListResults", "OraConnection",
   def = function(conn, ...) dbGetInfo(conn, "resultSetIds")[[1]]
)

setMethod("summary", "OraConnection",
   def = function(object, ...) oraDescribeConnection(object, ...)
)

## convenience methods 
setMethod("dbListTables", "OraConnection",
   def = function(conn, ...){
      tbls <- oraQuickSQL(conn, "select table_name from all_tables")[,1]
      if(is.null(tbls)) 
         tbls <- character()
      tbls
   },
   valueClass = "character"
)

setMethod("dbReadTable", signature(conn="OraConnection", name="character"),
   def = function(conn, name, ...) oraReadTable(conn, name, ...),
   valueClass = "data.frame"
)

setMethod("dbWriteTable", 
   signature(conn="OraConnection", name="character", value="data.frame"),
   def = function(conn, name, value, ...){
      oraWriteTable(conn, name, value, ...)
   },
   valueClass = "logical"
)

setMethod("dbExistsTable", 
   signature(conn="OraConnection", name="character"),
   def = function(conn, name, ...){
      ## TODO: find out the appropriate query to the Oracle metadata
      match(tolower(name), tolower(dbListTables(conn)), nomatch=0)>0
   },
   valueClass = "logical"
)

setMethod("dbRemoveTable", 
   signature(conn="OraConnection", name="character"),
   def = function(conn, name, ...){
      if(dbExistsTable(conn, name)){
         rc <- try(dbGetQuery(conn, paste("DROP TABLE", name)))
         !inherits(rc, ErrorClass)
      } 
      else FALSE
   },
   valueClass = "logical"
)

## return field names (no metadata)
setMethod("dbListFields", 
   signature(conn="OraConnection", name="character"),
   def = function(conn, name, ...){
      flds <- oraTableFields(conn, name, ...)
      if(is.null(flds))
         flds <- character()
      flds
   },
  valueClass = "character"
)

## need to define begin transaction, which Oracle does not explicitly does
## Limitations: Apparently we cannot use savepoints w. ProC/C++,
##   thus if you need savepoints, code them as a regular sql statement
##   and dbGetQuery() them.
setMethod("dbCommit", "OraConnection",
   def = function(conn, ...) oraCommit(conn, ...)
)

setMethod("dbRollback", "OraConnection",
   def = function(conn, ...) oraRollback(conn,...)
)

setMethod("dbCallProc", "OraConnection",
   def = function(conn, ...) .NotYetImplemented()
)

##
## Class: DBIResult
##
setClass("OraResult", representation("DBIResult", "OraObject"))

setAs("OraConnection", "OraResult",
   def = function(from) new("OraConnection", Id = as(from, "integer")[1:2])
)

setMethod("dbClearResult", "OraResult",
   def = function(res, ...) oraCloseResult(res, ...)
   ,
   valueClass = "logical"
)

setMethod("fetch", signature(res="OraResult", n="numeric"),
   def = function(res, n, ...){ 
      out <- oraFetch(res, n, ...)
      if(is.null(out))
         out <- data.frame(out)
      out
   },
   valueClass = "data.frame"
)

setMethod("fetch", 
   signature(res="OraResult", n="missing"),
   def = function(res, n, ...){
      out <-  oraFetch(res, n=0, ...)
      if(is.null(out))
         out <- data.frame(out)
      out
   },
   valueClass = "data.frame"
)

setMethod("dbGetInfo", "OraResult",
   def = function(dbObj, ...) oraResultInfo(dbObj, ...)
)

setMethod("dbGetStatement", "OraResult",
   def = function(res, ...){
      st <-  dbGetInfo(res, "statement")[[1]]
      if(is.null(st))
         st <- character()
      st
   },
   valueClass = "character"
)

setMethod("dbListFields", 
   signature(conn="OraResult", name="missing"),
   def = function(conn, name, ...){
       flds <- dbGetInfo(conn, "fields")$fields$name
       if(is.null(flds))
          flds <- character()
       flds
   },
   valueClass = "character"
)

setMethod("dbColumnInfo", "OraResult", 
   def = function(res, ...) dbGetInfo(res, ...)$fields,
   valueClass = "data.frame"
)

setMethod("dbGetRowsAffected", "OraResult",
   def = function(res, ...) dbGetInfo(res, "rowsAffected")[[1]],
   valueClass = "numeric"
)

setMethod("dbGetRowCount", "OraResult",
   def = function(res, ...) dbGetInfo(res, "rowCount")[[1]],
   valueClass = "numeric"
)

setMethod("dbHasCompleted", "OraResult",
   def = function(res, ...) dbGetInfo(res, "completed")[[1]] == 1,
   valueClass = "logical"
)

setMethod("dbGetException", "OraResult",
   def = function(conn, ...){
      id <- as(conn, "integer")
      .Call("RS_Ora_getException", id[1:2], PACKAGE = .OraPkgName)
   },
   valueClass = "list"    ## TODO: should be a DBIException?
)

setMethod("summary", "OraResult", 
   def = function(object, ...) oraDescribeResult(object, ...)
)

##
## Class: DBIPreparedStatement  (ROracle extension to DBI 0.1-5)
##
##  Currently we define prepare statements as (implementation) extensions 
##  of results sets.  To be precise, the current C implementation uses 
##  one struct to hold all aspect of a statement: its string represenation,
##  whether it produces output or not, if so, a description of the output
##  fields, and in the case of prepared statements, a pointer to a full
##  description of the buffers bound to the data.frame columns.  Thus,
##  a prepared statements signals the code to these bound buffers, and
##  in addition, allows us to dispatch properly dbExecStatements()
##  (we could overload dbSendQuery and dbGetQuery, but I find those
##  methods too PostgrSQL-specific, and semantically not quite what we're
##  trying to do with bindings).

setClass("OraPreparedStatement", 
   representation("DBIPreparedStatement", "OraResult"))

setMethod("dbPrepareStatement",
   sig = signature(conn = "OraConnection", statement = "character",
                   bind = "character"),
   def = function(conn, statement, bind, ...){
      oraPrepareStatement(conn, statement, bind, ...)
   }, 
   valueClass = "OraPreparedStatement"
)

setMethod("dbPrepareStatement",
   sig = signature(conn = "OraConnection", statement = "character",
                   bind = "data.frame"),
   def = function(conn, statement, bind, ...){
      oraPrepareStatement(conn, statement, bind, ...)
   }, 
   valueClass = "OraPreparedStatement"
)

setMethod("dbExecStatement",
   sig = signature(ps = "OraPreparedStatement",
                   data = "data.frame"),
   def = function(ps, data, ...) oraExecStatement(ps, data, ...),
   valueClass = "OraPreparedStatement"
)

setMethod("dbGetInfo", "OraPreparedStatement",
   def = function(dbObj, ...) oraPreparedStatementInfo(dbObj, ...)
)

setMethod("summary", "OraPreparedStatement",
   def = function(object, ...) oraDescribePreparedStatement(object, ...)
)

setMethod("dbDataType", 
   signature(dbObj = "OraObject", obj = "ANY"),
   def = function(dbObj, obj, ...) oraDataType(obj, ...),
   valueClass = "character"
)

setMethod("make.db.names", 
   signature(dbObj="OraObject", snames = "character"),
   def = function(dbObj, snames, keywords = .OraSQLKeywords, unique,
     allow.keywords, ...){
      make.db.names.default(snames, keywords = .OraSQLKeywords, unique = unique,
                            allow.keywords = allow.keywords)
   },
   valueClass = "character"
)
      
setMethod("SQLKeywords", "OraObject",
   def = function(dbObj, ...) .OraSQLKeywords,
   valueClass = "character"
)

setMethod("isSQLKeyword",
   signature(dbObj="OraObject", name="character"),
   def = function(dbObj, name, keywords = .OraSQLKeywords, case, ...){
        isSQLKeyword.default(name, keywords = .OraSQLKeywords, case = case)
   },
   valueClass = "character"
)
