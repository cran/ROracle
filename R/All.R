## This file defines some functions that mimic S4 functionality,
## namely:  new, as, show.

usingR <- function(major=0, minor=0){
  if(is.null(version$language))
    return(FALSE)
  if(version$language!="R")
    return(FALSE)
  version$major>=major && version$minor>=minor
}

## constant holding the appropriate error class returned by try() 
if(usingR()){
  ErrorClass <- "try-error"
} else {
  ErrorClass <- "Error"  
}

as <- function(object, classname)
{
  get(paste("as", as.character(classname), sep = "."))(object)
}

new <- function(classname, ...)
{
  if(!is.character(classname))
    stop("classname must be a character string")
  #class(classname) <- classname
  #UseMethod("new")
  do.call(paste("new", classname[1], sep="."), list(...))
}

new.default <- function(classname, ...)
{
  structure(list(...), class = unclass(classname))
}

show <- function(object, ...)
{
  UseMethod("show")
}

show.default <- function(object)
{
   print(object)
   invisible(NULL)
}

oldClass <- class

"oldClass<-" <- function(x, value)
{
  class(x) <- value
  x
}
##$
##
## DBI.S  Database Interface Definition
## For full details see http://www.omegahat.org
##
## Copyright (C) 1999,2000 The Omega Project for Statistical Computing.
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

## Class: dbManager 
## This class identifies the DataBase Management System (oracle, informix, etc)

dbManager <- function(obj, ...)
{
  do.call(as.character(obj), list(...))
}
load <- function(mgr, ...)
{
  UseMethod("load")
}
unload <- function(mgr, ...)
{
  UseMethod("unload")
}
getManager <- function(obj, ...)
{
  UseMethod("getManager")
}
getConnections <- function(mgr, ...)
{
  UseMethod("getConnections")
}
## Class: dbConnection

dbConnect <- function(mgr, ...)
{
  UseMethod("dbConnect")
}
dbExecStatement <- function(con, statement, ...)
{
  UseMethod("dbExecStatement")
}
dbExec <- function(con, statement, ...)
{
  UseMethod("dbExec")
}
commit <- function(con, ...)
{
  UseMethod("commit")
}
rollback <- function(con, ...)
{
  UseMethod("rollback")
}
callProc <- function(con, ...)
{
  UseMethod("callProc")
}
close.dbConnection <- function(con, ...)
{
  stop("close for dbConnection objects needs to be written")
}

getResultSets <- function(con, ...)
{
   UseMethod("getResultSets")
}
getException <- function(con, ...)
{
   UseMethod("getException")
}

## close is already a generic function in R

## Class: dbResult
## This is the base class for arbitrary results from TDBSM (INSERT,
## UPDATE, RELETE, etc.)  SELECT's (and SELECT-lie) statements produce
## "dbResultSet" objects, which extend dbResult.

## Class: dbResultSet
fetch <- function(res, n, ...)
{
  UseMethod("fetch")
}
setDataMappings <- function(res, ...)
{
  UseMethod("setDataMappings")
}
close.resultSet <- function(con, ...)
{
  stop("close method for dbResultSet objects need to be written")
}

## Need to elevate the current load() to the load.default
if(!exists("load.default")){
  if(exists("load", mode = "function", where = match("package:base",
search())))
    load.default <- get("load", mode = "function", 
                                 pos = match("package:base", search()))
  else
    load.default <- function(file, ...) stop("method must be overriden")
}

## Need to elevate the current getConnection to a default method,
## and define getConnection to be a generic

if(!exists("getConnection.default")){
  if(exists("getConnection", mode="function", where=match("package:base",search())))
    getConnection.default <- get("getConnection", mode = "function",
                                 pos=match("package:base", search()))
  else
    getConnection.default <- function(what, ...) 
      stop("method must be overriden")
}
if(!usingR(1,2.1)){
  close <- function(con, ...) UseMethod("close")
}
getConnection <- function(what, ...)
{
  UseMethod("getConnection")
}
getFields <- function(res, ...)
{
  UseMethod("getFields")
}
getStatement <- function(res, ...)
{
  UseMethod("getStatement")
}
getRowsAffected <- function(res, ...)
{
  UseMethod("getRowsAffected")
}
getRowCount <- function(res, ...)
{
  UseMethod("getRowCount")
}
getNullOk <- function(res, ...)
{
  UseMethod("getNullOk")
}
hasCompleted <- function(res, ...)
{
  UseMethod("hasCompleted")
}
## these next 2 are meant to be used with tables (not general purpose
## result sets) thru connections
getNumRows <- function(con, name, ...)
{
   UseMethod("getNumRows")
}
getNumCols <- function(con, name, ...)
{
   UseMethod("getNumCols")
}
getNumCols.default <- function(con, name, ...)
{
   nrow(getFields(con, name))
}
## (I don't know how to efficiently and portably get num of rows of a table)

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

getInfo <- function(obj, ...)
{
  UseMethod("getInfo")
}
describe <- function(obj, verbose = F, ...)
{
  UseMethod("describe")
}
getVersion <- function(obj, ...)
{
  UseMethod("getVersion")
}
getCurrentDatabase <- function(obj, ...)
{
  UseMethod("getCurrentDatabase")
}
getDatabases <- function(obj, ...)
{
  UseMethod("getDatabases")
}
getTables <- function(obj, dbname, row.names, ...) 
{
  UseMethod("getTables")
}
getTableFields <- function(res, table, dbname, ...)
{
  UseMethod("getTableFields")
}
getTableIndices <- function(res, table, dbname, ...) 
{
  UseMethod("getTableIndices")
}

## Class: dbObjectId
##
## This helper class is *not* part of the database interface definition,
## but it is extended by both the Oracle and MySQL implementations to
## MySQLObject and OracleObject to allow us to conviniently implement 
## all database foreign objects methods (i.e., methods for show(), 
## print() format() the dbManger, dbConnection, dbResultSet, etc.) 
## A dbObjectId is an  identifier into an actual remote database objects.  
## This class and its derived classes <driver-manager>Object need to 
## be VIRTUAL to avoid coercion (green book, p.293) during method dispatching.

##setClass("dbObjectId", representation(Id = "integer", VIRTUAL))

new.dbObjectId <- function(Id, ...)
{
  new("dbObjectId", Id = Id)
}
## Coercion: the trick as(dbObject, "integer") is very useful
## (in R this needs to be define for each of the "mixin" classes -- Grr!)
as.integer.dbObjectId <- 
function(object)
{
  as.integer(object$Id)
}

"isIdCurrent" <- 
function(obj)
## verify that obj refers to a currently open/loaded database
{ 
  obj <- as(obj, "integer")
  .Call("RS_DBI_validHandle", obj)
}

"format.dbObjectId" <- 
function(x, ...)
{
  id <- as(x, "integer")
  paste("(", paste(id, collapse=","), ")", sep="")
}
"print.dbObjectId" <- 
function(x, ...)
{
  str <- paste(class(x)[1], " id = ", format(x), sep="")
  if(isIdCurrent(x))
    cat(str, "\n")
  else
    cat("Expired", str, "\n")
  invisible(NULL)
}

## These are convenience functions that mimic S database access methods 
## get(), assign(), exists(), and remove().

"getTable" <-  function(con, name, ...)
{
  UseMethod("getTable")
}

"getTable.dbConnection" <- 
function(con, name, row.names = "row.names", check.names = T, ...)
## Should we also allow row.names to be a character vector (as in read.table)?
## is it "correct" to set the row.names of output data.frame?
## Use NULL, "", or 0 as row.names to prevent using any field as row.names.
{
  out <- quickSQL(con, paste("SELECT * from", name))
  if(check.names)
     names(out) <- make.names(names(out), unique = T)
  ## should we set the row.names of the output data.frame?
  nms <- names(out)
  j <- switch(mode(row.names),
         "character" = if(row.names=="") 0 else
                       match(tolower(row.names), tolower(nms), 
                             nomatch = if(missing(row.names)) 0 else -1),
         "numeric" = row.names,
         "NULL" = 0,
         0)
  if(j==0) 
     return(out)
  if(j<0 || j>ncol(out)){
     warning("row.names not set on output data.frame (non-existing field)")
     return(out)
  }
  rnms <- as.character(out[,j])
  if(all(!duplicated(rnms))){
      out <- out[,-j, drop = F]
      row.names(out) <- rnms
  } else warning("row.names not set on output (duplicate elements in field)")
  out
} 

"existsTable" <- function(con, name, ...)
{
  UseMethod("existsTable")
}
"existsTable.dbConnection" <- function(con, name, ...)
{
    ## name is an SQL (not an R/S!) identifier.
    match(name, getTables(con), nomatch = 0) > 0
}
"removeTable" <- function(con, name, ...)
{
  UseMethod("removeTable")
}
"removeTable.dbConnection" <- function(con, name, ...)
{
  if(existsTable(con, name, ...)){
    rc <- try(quickSQL(con, paste("DROP TABLE", name)))
    !inherits(rc, "Error")
  } 
  else  FALSE
}

"assignTable" <- function(con, name, value, row.names, ...)
{
  UseMethod("assignTable")
}

## The following generic returns the closest data type capable 
## of representing an R/S object in a DBMS.  
## TODO:  Lots! We should have a base SQL92 method that individual
## drivers extend?  Currently there is no default.  Should
## we also allow data type mapping from SQL -> R/S?

"SQLDataType" <- function(mgr, obj, ...)
{
  UseMethod("SQLDataType")
}
SQLDataType.default <- function(mgr, obj, ...)
{
   ## should we supply an SQL89/SQL92 default implementation?
   stop("must be implemented by a specific driver")
}
"make.SQL.names" <- 
function(snames, unique = T, allow.keywords = T)
## produce legal SQL identifiers from strings in a character vector
## unique, in this function, means unique regardless of lower/upper case
{
   makeUnique <- function(x, sep="_"){
     out <- x
     lc <- make.names(tolower(x), unique=F)
     i <- duplicated(lc)
     lc <- make.names(lc, unique = T)
     out[i] <- paste(out[i], substring(lc[i], first=nchar(out[i])+1), sep=sep)
     out
   }
   snames  <- make.names(snames, unique=F)
   if(unique) 
     snames <- makeUnique(snames)
   if(!allow.keywords){
     snames <- makeUnique(c(.SQLKeywords, snames))
     snames <- snames[-seq(along = .SQLKeywords)]
   } 
   .Call("RS_DBI_makeSQLNames", snames)
}

"isSQLKeyword" <-
function(x, keywords = .SQLKeywords, case = c("lower", "upper", "any")[3])
{
   n <- pmatch(case, c("lower", "upper", "any"), nomatch=0)
   if(n==0)
     stop('case must be one of "lower", "upper", or "any"')
   kw <- switch(c("lower", "upper", "any")[n],
           lower = tolower(keywords),
           upper = toupper(keywords),
           any = toupper(keywords))
   if(n==3)
     x <- toupper(x)
   match(x, keywords, nomatch=0) > 0
}
## SQL ANSI 92 (plus ISO's) keywords --- all 220 of them!
## (See pp. 22 and 23 in X/Open SQL and RDA, 1994, isbn 1-872630-68-8)
".SQLKeywords" <- 
c("ABSOLUTE", "ADD", "ALL", "ALLOCATE", "ALTER", "AND", "ANY", "ARE", "AS",
  "ASC", "ASSERTION", "AT", "AUTHORIZATION", "AVG", "BEGIN", "BETWEEN",
  "BIT", "BIT_LENGTH", "BY", "CASCADE", "CASCADED", "CASE", "CAST", 
  "CATALOG", "CHAR", "CHARACTER", "CHARACTER_LENGTH", "CHAR_LENGTH",
  "CHECK", "CLOSE", "COALESCE", "COLLATE", "COLLATION", "COLUMN", 
  "COMMIT", "CONNECT", "CONNECTION", "CONSTRAINT", "CONSTRAINTS", 
  "CONTINUE", "CONVERT", "CORRESPONDING", "COUNT", "CREATE", "CURRENT",
  "CURRENT_DATE", "CURRENT_TIMESTAMP", "CURRENT_TYPE", "CURSOR", "DATE",
  "DAY", "DEALLOCATE", "DEC", "DECIMAL", "DECLARE", "DEFAULT", 
  "DEFERRABLE", "DEFERRED", "DELETE", "DESC", "DESCRIBE", "DESCRIPTOR",
  "DIAGNOSTICS", "DICONNECT", "DICTIONATRY", "DISPLACEMENT", "DISTINCT",
  "DOMAIN", "DOUBLE", "DROP", "ELSE", "END", "END-EXEC", "ESCAPE", 
  "EXCEPT", "EXCEPTION", "EXEC", "EXECUTE", "EXISTS", "EXTERNAL", 
  "EXTRACT", "FALSE", "FETCH", "FIRST", "FLOAT", "FOR", "FOREIGN", 
  "FOUND", "FROM", "FULL", "GET", "GLOBAL", "GO", "GOTO", "GRANT", 
  "GROUP", "HAVING", "HOUR", "IDENTITY", "IGNORE", "IMMEDIATE", "IN",
  "INCLUDE", "INDEX", "INDICATOR", "INITIALLY", "INNER", "INPUT", 
  "INSENSITIVE", "INSERT", "INT", "INTEGER", "INTERSECT", "INTERVAL",
  "INTO", "IS", "ISOLATION", "JOIN", "KEY", "LANGUAGE", "LAST", "LEFT",
  "LEVEL", "LIKE", "LOCAL", "LOWER", "MATCH", "MAX", "MIN", "MINUTE",
  "MODULE", "MONTH", "NAMES", "NATIONAL", "NCHAR", "NEXT", "NOT", "NULL",
  "NULLIF", "NUMERIC", "OCTECT_LENGTH", "OF", "OFF", "ONLY", "OPEN",
  "OPTION", "OR", "ORDER", "OUTER", "OUTPUT", "OVERLAPS", "PARTIAL",
  "POSITION", "PRECISION", "PREPARE", "PRESERVE", "PRIMARY", "PRIOR",
  "PRIVILEGES", "PROCEDURE", "PUBLIC", "READ", "REAL", "REFERENCES",
  "RESTRICT", "REVOKE", "RIGHT", "ROLLBACK", "ROWS", "SCHEMA", "SCROLL",
  "SECOND", "SECTION", "SELECT", "SET", "SIZE", "SMALLINT", "SOME", "SQL",
  "SQLCA", "SQLCODE", "SQLERROR", "SQLSTATE", "SQLWARNING", "SUBSTRING",
  "SUM", "SYSTEM", "TABLE", "TEMPORARY", "THEN", "TIME", "TIMESTAMP",
  "TIMEZONE_HOUR", "TIMEZONE_MINUTE", "TO", "TRANSACTION", "TRANSLATE",
  "TRANSLATION", "TRUE", "UNION", "UNIQUE", "UNKNOWN", "UPDATE", "UPPER",
  "USAGE", "USER", "USING", "VALUE", "VALUES", "VARCHAR", "VARYING",
  "VIEW", "WHEN", "WHENEVER", "WHERE", "WITH", "WORK", "WRITE", "YEAR",
  "ZONE"
)

## $Id$
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

## Class: dbManager

new.OraObject <- function(Id)
{
   out <- list(Id = as.integer(Id))
   class(out) <- c("OraObject", "dbObjectId")
   out
}
new.OraManager <- function(Id)
{
   out <- list(Id = as.integer(Id))
   class(out) <- c("OraManager", "dbManger", "OraObject", "dbObjectId")
   out
}
new.OraConnection <- function(Id)
{
   out <- list(Id = as.integer(Id))
   class(out) <- c("OraConnection", "dbConnection", "OraObject", "dbObjectId")
   out
}

"Oracle" <- "OraManager" <- 
function(max.con=10, fetch.default.rec = 500, force.reload=F)
## create a MySQL database connection manager.  By default we allow
## up to "max.con" connections and single fetches of up to "fetch.default.rec"
## records.  These settings may be changed by re-loading the driver
## using the "force.reload" = T flag (note that this will close all 
## currently open connections).
## Returns an object of class "OraManager".  
## Note: This class is a singleton.
{
  if(fetch.default.rec<=0)
    stop("default num of records per fetch must be positive")
  id <- load.OraManager(max.con, fetch.default.rec, force.reload)
  new("OraManager", Id = id)
}

as.integer.dbObjectId <- function(x, ...)
{
  x <- x$Id
  NextMethod("as.integer")
}
as.OraManager <- function(object)
{
  new("OraManager", Id = as(object, "integer")[1])
}
as.OraConnection <- function(object)
{
  new("OraConnection", Id=as(object, "integer")[1:2])
}
as.OraResultSet <- function(object)
{
  new("OraResultSet", Id=as(object, "integer")[1:3])
}
loadManager.OraManager <- function(mgr, ...)
  load.OraManager(...)

## Class: dbConnection
dbConnect.OraManager <- function(mgr, ...)
{
  id <- newConnection.OraManager(mgr, ...)
  new("OraConnection",Id = id)
}
dbConnect.OraConnection <- function(mgr, ...)
{
  con.id <- as(mgr, "integer")
  con <- .Call("RS_Ora_cloneConnection", con.id)
  new("OraConnection", Id = con)
}
dbConnect.default <- function(mgr, ...)
{
## dummy default (it only works for Ora)  See the S4 for the
## real default method
  if(!is.character(mgr)) 
    stop("mgr must be a string with the driver name")
  id <- do.call(mgr, list())
  dbConnect(id, ...)
}
getConnections.OraManager <- function(mgr, ...)
{
   getInfo(mgr, what = "connectionIds")
}
getManager.OraConnection <- getManager.OraResultSet <-
function(obj, ...)
{
   as(obj, "OraManager")
}
quickSQL <- function(con, statement, ...)
{
  UseMethod("quickSQL")
}
getException.OraConnection <- function(object)
{
  id <- as.integer(object)
  .Call("RS_Ora_getException", id)
}
dbExec.OraConnection <- 
dbExecStatement.OraConnection <- 
function(con, statement, ...)
{
  if(!is.character(statement))
    stop("non character statement")
  execStatement.OraConnection(con, statement, ...)
}


## Class: resultSet

new.OraResultSet <- function(Id)
{
  out <- list(Id = as.integer(Id))
  class(out) <- c("OraResultSet", "dbResultSet", "OraObject", "dbObjectId")
  out
}

getConnection.OraConnection <-
getConnection.OraResultSet <- 
function(object)
{
  new("OraConnection", Id=as(object, "integer")[1:2])
}

getStatement.OraResultSet <- function(object)
{
  getInfo.OraResultSet(object, "statement")
}

## ???
getFields.OraResultSet <- function(res)
{
  flds <- getInfo.OraResultSet(res, "fields")[[1]]
  flds$Sclass <- .Call("RS_DBI_SclassNames", flds$Sclass)
  flds$type <- .Call("RS_Ora_typeNames", as.integer(flds$type))
  structure(flds, row.names = paste(seq(along=flds$type)), class="data.frame")
}
getFields.OraConnection <- 
function(con, table, dbname)
{
   if(missing(dbname)) {
      sql <- paste("select * from ALL_TAB_COLUMNS ",
		   "where TABLE_NAME = '", table, "'", sep = "")
   } else {
      sql <- paste("select * from ALL_TAB_COLUMNS ",
		   "where TABLE_NAME = '", table, "@", dbname,"'", sep = "")
   }
   quickSQL(con, sql)
}

getRowsAffected.OraResultSet <- function(object)
  getInfo.OraResultSet(object, "rowsAffected")

getRowCount.OraResultSet <- function(object)
  getInfo.OraResultSet(object, "rowCount")

hasCompleted.OraResultSet <- function(object)
  getInfo.OraResultSet(object, "completed")

getException.OraResultSet <- function(object)
{
  id <- as.integer(object)
  .Call("RS_Ora_getException", id[1:2])
}

getCurrentDatabase.OraConnection <- function(object, ...)
{
  getInfo(object, "dbname")
}

getDatabases.OraConnection <- function(obj, ...)
{
  stop("not yet implemented")
  quickSQL(obj, "show databases")
}

getTables.OraConnection <- function(object, dbname, ...)
{
  if (missing(dbname))
    quickSQL(object, "select table_name from all_tables")[,1]
  else quickSQL(object, paste("select table_name from all_tables", dbname))[,1]
}

getTableFields.OraResultSet <- function(object, table, dbname, ...)
{
  getFields(object)
}

getTableFields.OraConnection <- function(object, table, dbname, ...)
{
  if (missing(dbname)){
      cmd <- paste("select * from ALL_TAB_COLUMNS ",
		  "where TABLE_NAME = '", table, "'", sep = "")
  } else  {
      cmd <- paste("select * from ALL_TAB_COLUMNS ",
		  "where TABLE_NAME = '", table, "@", dbname,"'", sep = "")
  }
  quickSQL(object, cmd)
}

getTableIndices.OraConnection <- function(obj, table, dbname, ...)
{
  if (missing(dbname))
    cmd <- paste("show index from", table)
  else cmd <- paste("show index from", table, "from", dbname)
  quickSQL(obj, cmd)
}


SQLDataType.OraConnection <-
SQLDataType.OraManager <- 
function(obj, ...)
## find a suitable SQL data type for the R/S object obj
## TODO: Lots and lots!! (this is a very rough first draft)
## need to register converters, abstract out Ora and generalize 
## to Oracle, Informix, etc.  Perhaps this should be table-driven.
## NOTE: MySQL data types differ from the SQL92 (e.g., varchar truncate
## trailing spaces).  MySQL enum() maps rather nicely to factors (with
## up to 65535 levels)
{
  rs.class <- data.class(obj)
  rs.mode <- storage.mode(obj)
  if(rs.class=="numeric"){
    sql.type <- if(rs.mode=="integer") "bigint" else  "double"
  } 
  else {
    sql.type <- switch(rs.class,
                  character = "text",
                  logical = "tinyint",
                  factor = "text",	## up to 65535 characters
                  ordered = "text",
                  "text")
  }
  sql.type
}
## $Id$
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

## RS-Oracle Support functions.  These functions are named
## following S3/R convention "<method>.<class>" (e.g., close.Oraconnection)
## to allow easy porting to R and S3(?).  Also, we tried to minimize
## S4 specific construct as much as possible (there're still a few
## S4 idioms left, but Saikat DebRoy defined a few S3-style classes
## that makes it easy for porting ---e.g., "new")
##

"load.OraManager" <- 
function(max.con = 1, fetch.default.rec = 500, reload = F)
## return a manager id
{
  config.params <- as.integer(c(max.con, fetch.default.rec))
  reload <- as(reload, "logical")[1]
  .Call("RS_Ora_init", config.params, reload)
}

"describe.OraManager" <-
function(obj, verbose = F, ...)
## Print out nicely a brief description of the connection Manager
{
  info <- getInfo.OraManager(obj)
  show(obj)
  cat("  Driver name: ", info$drvName, "\n")
  cat("  Max  connections:", info$length, "\n")
  cat("  Conn. processed:", info$counter, "\n")
  cat("  Default records per fetch:", info$"fetch_default_rec", "\n")
  if(verbose){
    cat("  Oracle client version: ", info$clientVersion, "\n")
    cat("  RS-DBI version: ", "0.2", "\n")
  }
  cat("  Open connections:", info$"num_con", "\n")
  if(verbose && !is.null(info$connectionIds)){
    for(i in seq(along = info$connectionIds)){
      cat("   ", i, " ")
      show(info$connectionIds[[i]])
    }
  }
  invisible(NULL)
}

"unload.OraManager"<- 
function(dbMgr, ...)
{
  mgrId <- as(dbMgr, "integer")
  .Call("RS_Ora_close", mgrId)
}

"getInfo.OraManager" <- 
function(obj, what)
{
  mgrId <- as(obj, "integer")
  info <- .Call("RS_Ora_managerInfo", mgrId)
  mgrId <- info$managerId
  ## replace mgr/connection id w. actual mgr/connection objects
  conObjs <- vector("list", length = info$"num_con")
  ids <- info$connectionIds
  for(i in seq(along = ids))
    conObjs[[i]] <- new("OraConnection", Id = c(mgrId, ids[i]))
  info$connectionIds <- conObjs
  info$managerId <- new("OraManager", Id = mgrId)
  if(!missing(what))
    info <- info[what]
  if(length(info)==1)
    info[[1]]
  else
    info
}

"getVersion.OraManager" <- 
function(dbMgr)
{
  list("RS-DBI" = "0.2",
       "Oracle (client) library" = getInfo(dbMgr, what="clientVersion"))
}

"getConnections.OraManager" <-
function(dbMgr, ...)
{ 
  getInfo(dbMgr, what = "connectionIds")
}
"newConnection.OraManager"<- 
function(dbMgr, username="", password="", dbname = 
         if(usingR()) Sys.getenv("ORACLE_SID") else getenv("ORACLE_SID"),
	 max.results=1)
{
  con.params <- as.character(c(username, password, dbname))
  mgrId <- as(dbMgr, "integer")
  max.results <- as(max.results, "integer")
  if(max.results!=1){
    warning("currently we can only have one open resultSet")
    max.results <- 1
  }
  .Call("RS_Ora_newConnection", mgrId, con.params, max.results)
}

## functions/methods not implementable
"commit.OraConnection" <- 
"rollback.OraConnection" <- 
function(con) 
{
  warning("Oracle does not support transactions")
}

"describe.OraConnection" <- 
function(obj, verbose = F, ...)
{
  info <- getInfo(obj)
  show(obj)
  cat("  User:", info$user, "\n")
  cat("  Dbname:", info$dbname, "\n")
  if(verbose){
    cat("  Server version: \n")
    srvVersion <- getVersion(obj)
    for(v in srvVersion)
      cat(paste("    ", v, sep=""), "\n")
    cat("  Oracle client version: ", 
	getInfo(as(obj, "OraManager"),what="clientVersion"), "\n")
  }
  resIds <- info$resultSetIds
  if(!is.null(resIds)){
    for(i in seq(along = resIds)){
      if(verbose)
        describe(resIds[[i]], verbose = F)
      else
        show(resIds[[i]])
    }
  } else cat("  No resultSet available\n")
  invisible(NULL)
}

"close.OraConnection" <- 
function(con, ...)
{
  conId <- as(con, "integer")
  .Call("RS_Ora_closeConnection", conId)
}
"getVersion.OraConnection" <-
function(obj)
{
  con <- as(obj, "OraConnection")
  quickSQL(con, "select * from V$VERSION")[[1]]
}
"getInfo.OraConnection" <-
function(obj, what)
{
  id <- as(obj, "integer")[1:2]
  info <- .Call("RS_Ora_connectionInfo", id)
  if(length(info$resultSetIds)){
    rs <- vector("list", length(info$resultSetIds))
    for(i in seq(along = rs))
      rs[[i]] <- new("OraResultSet", Id = c(id, info$resultSetIds[i]))
    info$resultSetIds <- rs
  }
  if(!missing(what))
    info <- info[what]
  if(length(info)==1)
    info[[1]]
  else
    info
}

"getResultSets.OraConnection" <-      
function(con, ...)
{
  getInfo(con, "resultSetIds")
}
"execStatement.OraConnection" <- 
function(con, statement)
## submits the sql statement to Oracle and creates a
## dbResult object if the SQL operation does not produce
## output, otherwise it produces a resultSet that can
## be used for fetching rows.
{
  conId <- as(con, "integer")
  statement <- as(statement, "character")
  rsId <- .Call("RS_Ora_exec", conId, statement)
#  out <- new("OraResult", Id = rsId)
#  if(getInfo(out)$isSelect)
#    out <- new("OraResultSet", Id = rsId)
#  out
  new("OraResultSet", Id = rsId)
}

## helper function: it exec's *and* retrieves a statement. It should
## be named something else.
quickSQL.OraConnection <- function(con, statement)
{
  if(!isIdCurrent(con))
    stop(paste("expired", class(con), deparse(substitute(con))))
  if(length(getResultSets(con))>0){
    new.con <- dbConnect(con)
    on.exit(close(new.con))
    rs <- dbExecStatement(new.con, statement)
  } else  rs <- dbExecStatement(con, statement)
  if(hasCompleted(rs)){
    close(rs)
    invisible()
    return(rs)
  }
  res <- fetch(rs, n = -1)
  if(hasCompleted(rs))
    close(rs)
  else 
    warning(paste("pending rows in resultSet", rs))
  res
}

"fetch.OraResultSet" <- 
function(res, n=0)   
## Fetch at most n records from the opened resultSet (n = -1 means
## all records, n=0 means extract as many as "default_fetch_rec",
## as defined by OraManager (see describe(mgr, T)).
## The returned object is a data.frame. 
## Note: The method hasCompleted() on the resultSet tells you whether
## or not there are pending records to be fetched. See also the methods
## describe(), getFieldDescrition(), getRowCount(), getAffectedRows(),
## getDBConnection(), getException().
## 
## TODO: Make sure we don't exhaust all the memory, or generate
## an object whose size exceeds option("object.size").  Also,
## are we sure we want to return a data.frame?
{    
  if(hasCompleted(res)){
    warning("no more records to fetch")
    return(NULL)
  }
  n <- as(n, "integer")
  rsId <- as(res, "integer")
  rel <- .Call("RS_Ora_fetch", rsId, nrec = n)
  if(length(rel)==0)
    return(NULL)
  ## we don't want to coerce character data to factors
  cnt <- getInfo(res, what = "rowCount")
  nrec <- length(rel[[1]])
  indx <- seq(from = cnt - nrec + 1, length = nrec)
  attr(rel, "row.names") <- as.character(indx)
  if(usingR(1,4))
     class(rel) <- "data.frame"
  else
     oldClass(rel) <- "data.frame"
  rel
}

## Note that originally we had only resultSet both for SELECTs
## and INSERTS, ...  Later on we created a base class dbResult
## for non-Select SQL and a derived class resultSet for SELECTS.

"getInfo.OraResultSet" <- 
#"getInfo.OraResult" <- 
function(obj, what)
{
   id <- as(obj, "integer")
   info <- .Call("RS_Ora_resultSetInfo", id)
   if(!missing(what))
     info <- info[what]
   if(length(info)==1)
     info[[1]]
   else
     info
}


if(F){
  ##"describe.OraResultSet" <- 
  "describe.OraResult" <- 
    function(obj, verbose = F, ...)
      {
	if(!isIdCurrent(obj)){
	  show(obj)
	  invisible(return(NULL))
	}
	show(obj)
	cat("  Statement:", getStatement(obj), "\n")
	cat("  Has completed?", if(hasCompleted(obj)) "yes" else "no", "\n")
	cat("  Affected rows:", getRowsAffected(obj), "\n")
	invisible(NULL)
      }
}
"describe.OraResultSet" <- 
function(obj, verbose = F, ...)
{

  if(!isIdCurrent(obj)){
    show(obj)
    invisible(return(NULL))
  }
  show(obj)
  cat("  Statement:", getStatement(obj), "\n")
  cat("  Has completed?", if(hasCompleted(obj)) "yes" else "no", "\n")
  cat("  Affected rows:", getRowsAffected(obj), "\n")
  cat("  Rows fetched:", getRowCount(obj), "\n")
  flds <- getFields(obj)
  if(verbose && !is.null(flds)){
    cat("  Fields:\n")  
    out <- print(getFields(obj))
  }
  invisible(NULL)
}

"close.OraResultSet" <- 
function(con, ...)
{
  rsId <- as(con, "integer")
  .Call("RS_Ora_closeResultSet", rsId)
}

"isIdCurrent" <- 
function(obj)
## verify that dbObjectId refers to a currently open/loaded database
{ 
  obj <- as(obj, "integer")
  .Call("RS_DBI_validHandle", obj)
}

.conflicts.OK <- TRUE
.First.lib <- function(lib, pkg) {
  library.dynam("ROracle", pkg, lib)
}
