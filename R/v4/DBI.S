## $Id$
##
## DBI.S  Database Interface Definition
## For full details see http://www.omegahat.org
##
## Copyright (C) 1999 The Omega Project for Statistical Computing.
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##

## Define all the classes and methods to be used by an implementation
## of the RS-DataBase Interface.  All these classes are virtual
## and each driver should extend them to provide the actual implementation.
## See the files Oracle.S and MySQL.S for the Oracle and MySQL 
## S implementations, respectively.  The support files (they have "support"
## in their names) for code that is R-friendly and may be easily ported
## to R. 

usingR <- function(major=0, minor=0){
  if(is.null(version$language))
    return(FALSE)
  if(version$language!="R")
    return(FALSE)
  version$major>=major && version$minor>=minor
}

## Class: dbManager 
## This class identifies the DataBase Management System (oracle, informix, etc)

setClass("dbManager")

dbManager <- function(obj, ...){
  do.call(as.character(obj), ...)
}
setGeneric("load", def = function(mgr,...){
  standardGeneric("load")
})
setGeneric("unload", def = function(mgr,...){
  standardGeneric("unload")
})
setGeneric("getConnections", def = function(mgr, ...){
  standardGeneric("getConnections")
})

## Class: dbConnections 

setClass("dbConnection")

setGeneric("dbConnect", def = function(mgr, ...){
  standardGeneric("dbConnect")
})
setGeneric("dbExecStatement", def = function(con, statement, ...){
  standardGeneric("dbExecStatement")
})
setGeneric("dbExec", def = function(con, statement, ...){
  standardGeneric("dbExec")
})
setGeneric("getResultSets", def = function(con, ...){
  standardGeneric("getResultSets")
})
setGeneric("commit", def = function(con, ...){
  standardGeneric("commit")
})
setGeneric("rollback", def = function(con, ...){
  standardGeneric("rollback")
})
setGeneric("callProc", def = function(con, ...){
  standardGeneric("callProc")
})
setGeneric("getException",  def = function(con, ...){
  standardGeneric("getException")
})

## Note that close() is not a generic function.  Therefore, the
## following will elevate it to such, but this will generate
## a harmless (if annoying) warning
## (signatures in R and Splus are different)
if(usingR(1,4)){
  setMethod("close", "dbConnection", def = function(con, ... ) NULL)
} else
  setMethod("close", signature = list(con = "dbConnection", type = "missing"),
	    definition = function(con, type) NULL)

## Class: dbResult
## This is a base class for arbitrary results from the RDBMS (INSERT, 
## UPDATE, DELETE).  SELECTs (and SELECT-like) statements produce
## "resultSet" objects, which extend dbResult.

if(F){
  setClass("dbResult")
  setMethod("close", signature = list(con = "dbResult", type = "missing"),
	    definition = function(con, type) NULL)
}
## Class: dbResultSet
## Note that we define a dbResultSet as the result of a SELECT  SQL statement

if(F)
  setClass("dbResultSet", "dbResult")

setClass("dbResultSet")

setGeneric("fetch", def = function(res, n, ...){
  standardGeneric("fetch")
})
setGeneric("hasCompleted",  def = function(res, ...){
  standardGeneric("hasCompleted")
})
## getConnection in "main" is not a generic -- thus the following will
## generate a harmless, but annoying warning.
setGeneric("getConnection", def = function(what){
  standardGeneric("getConnection")
})
setGeneric("setDataMappings",  def = function(res, ...){
  standardGeneric("setDataMappings")
})
setGeneric("getFields", def = function(res, table, dbname, ...){
  standardGeneric("getFields")
})
setGeneric("getTableFields", def = function(res, table, dbname, ...){
  standardGeneric("getTableFields")
})
setGeneric("getTableIndices", def = function(res, table, dbname, ...) {
  standardGeneric("getTableIndices")
})
setGeneric("getStatement", def = function(res, ...){
  standardGeneric("getStatement")
})
setGeneric("getRowsAffected", def = function(res, ...){
  standardGeneric("getRowsAffected")
})
setGeneric("getRowCount", def = function(res, ...) {
  standardGeneric("getRowCount")
})

## Meta-data: 
## The approach in the current implementation is to have .Call()
##  functions return named lists with all the known features for
## the various objects (dbManager, dbConnection, dbResultSet, 
## etc.) and then each meta-data function (e.g., getVersion) extract 
## the appropriate field from the list.  Of course, there are meta-data
## elements that need to access to DBMS data dictionaries (e.g., list
## of databases, priviledges, etc) so they better be implemented using 
## the SQL inteface itself, say thru quickSQL.
## 
## It may be possible to get some of the following meta-data from the
## dbManager object iteslf, or it may be necessary to get it from a
## dbConnection because the dbManager does not talk itself to the
## actual DBMS.  The implementation will be driver-specific.  
##
## TODO: what to do about permissions? privileges? users? Some 
## databses, e.g., mSQL, do not support multiple users.  Can we get 
## away without these?  The basis for defining the following meta-data 
## is to provide the basics for writing methods for attach(db) and 
## related methods (objects, exist, assign, remove) so that we can even
## abstract from SQL and the RS-Database interface itself.

setGeneric("describe", def = function(obj, verbose=F, ...){
  standardGeneric("describe")
})
setGeneric("getInfo", def = function(obj, ...) {
  standardGeneric("getInfo")
})
setGeneric("getVersion", def = function(obj,...) {
  standardGeneric("getVersion")
})
setGeneric("getCurrentDatabase",  def = function(obj, ...){
  standardGeneric("getCurrentDatabase")
})
setGeneric("getDatabases", def = function(obj, ...){
  standardGeneric("getDatabases")
})
setGeneric("getTables", def = function(obj, dbname, ...){
  standardGeneric("getTables")
})

## Class: dbObjectId
##
## This helper class is *not* part of the database interface definition,
## but is used by both the Oracle and MySQL implementations to allows us 
## to conviniently implement all database foreign objects methods 
## (i.e., methods for show(), print() format() the dbManger, 
## dbConnection, dbResultSet, etc.) A dbObjectId is an  identifier into 
## an actual remote database objects.  The class needs to be VIRTUAL to 
## avoid coercion (green book, p.293) during method dispatching.

if(usingR(1,4)){
   setClass("dbObjectId", representation(Id = "integer", "VIRTUAL"))
} else {
   setClass("dbObjectId", representation(Id = "integer", VIRTUAL))
}
## Coercion: the trick as(dbObject, "integer") is very useful

setAs("dbObjectId", "integer", function(object) as(object@Id, "integer"))

setMethod("format", "dbObjectId", def = function(x, ...){
  format.dbObjectId(x)
})
setMethod("show", "dbObjectId", def = function(object){
  print.dbObjectId(object)
})

if(usingR(1,4))
   setMethod("print", "dbObjectId", def = function(x, ...){
      print.dbObjectId(x, ...)
   })
