##
## $Id: S4R.R,v 1.1 2002/05/20 21:04:23 dj Exp dj $
##
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

## When we move to version 4 style classes, we should replace 
## the calls to the following by their lower-case counerpart, 
## as defined in library(methods)
AS <- function(object, classname)
{
  get(paste("as", as.character(classname), sep = "."))(object)
}

NEW <- function(classname, ...)
{
  if(!is.character(classname))
    stop("classname must be a character string")
  do.call(paste("NEW", classname[1], sep="."), list(...))
}

NEW.default <- function(classname, ...)
{
  structure(list(...), class = unclass(classname))
}

##
## $Id: DBI.R,v 1.1 2002/05/20 21:04:23 dj Exp dj $
##
## DBI.R  Database Interface Definition
## For full details see http://www.omegahat.org
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
getTables <- function(obj, dbname, ...) 
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
  NEW("dbObjectId", Id = Id)
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
  obj <- AS(obj, "integer")
  .Call("RS_DBI_validHandle", obj)
}

"format.dbObjectId" <- 
function(x, ...)
{
  id <- AS(x, "integer")
  paste("(", paste(id, collapse=","), ")", sep="")
}
"print.dbObjectId" <- 
function(x, ...)
{
  if(isIdCurrent(x))
    str <- paste("<",class(x)[1], ":", format(x), ">", sep="")
  else
    str <- paste("<Expired ",class(x)[1], ":", format(x), ">", sep="")
  cat(str, "\n")
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
    match(tolower(name), tolower(getTables(con)), nomatch = 0) > 0
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
function(snames, keywords = .SQL92Keywords, unique = T, allow.keywords = T)
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
     snames <- makeUnique(c(keywords, snames))
     snames <- snames[-seq(along = keywords)]
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
".SQL92Keywords" <- 
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
##
## $Id: Oracle.R,v 1.1 2002/05/20 21:04:23 dj Exp dj $
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

## Class: dbManager

## The calls to NEW() and AS() should be replaced with new(), as()
## when we move to version 4 style classes
NEW.OraObject <- function(Id)
{
   out <- list(Id = as.integer(Id))
   class(out) <- c("OraObject", "dbObjectId")
   out
}
NEW.OraManager <- function(Id)
{
   out <- list(Id = as.integer(Id))
   class(out) <- c("OraManager", "dbManger", "OraObject", "dbObjectId")
   out
}
NEW.OraConnection <- function(Id)
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
  NEW("OraManager", Id = id)
}

as.integer.dbObjectId <- function(x, ...)
{
  x <- x$Id
  NextMethod("as.integer")
}
as.OraManager <- function(object)
{
  NEW("OraManager", Id = AS(object, "integer")[1])
}
as.OraConnection <- function(object)
{
  NEW("OraConnection", Id=AS(object, "integer")[1:2])
}
as.OraResultSet <- function(object)
{
  NEW("OraResultSet", Id=AS(object, "integer")[1:3])
}
loadManager.OraManager <- function(mgr, ...)
  load.OraManager(...)

## Class: dbConnection
dbConnect.OraManager <- function(mgr, ...)
{
  id <- newConnection.OraManager(mgr, ...)
  NEW("OraConnection",Id = id)
}
dbConnect.OraConnection <- function(mgr, ...)
{
  con.id <- AS(mgr, "integer")
  con <- .Call("RS_Ora_cloneConnection", con.id)
  NEW("OraConnection", Id = con)
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
   AS(obj, "OraManager")
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

NEW.OraResultSet <- function(Id)
{
  out <- list(Id = as.integer(Id))
  class(out) <- c("OraResultSet", "dbResultSet", "OraObject", "dbObjectId")
  out
}

getConnection.OraConnection <-
getConnection.OraResultSet <- 
function(object)
{
  NEW("OraConnection", Id=AS(object, "integer")[1:2])
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

".Oracle.NA.string" <- ""

"assignTable.OraConnection" <-
function(con, name, value, field.types, row.names = T, 
   overwrite=F, append=F, ...)
## Create table "name" (must be an SQL identifier) and populate
## it with the values of the data.frame "value" (possibly after coercion
## to data.frame).
## 
## BUG: In the unlikely event that value has a field called "row.names"
## we could inadvertently overwrite it (here the user should set row.names=F)
##
## TODO: This function should execute its sql as a single transaction,
## and allow converter functions.
##
## Hack alert: we silently accept the "rhost" argument (as part of ...)
## if set, we run the SQL*Loader on the remote host pointed by "rhost";
## in this case we need to set/guess values for ORACLE_HOME on the remote
## host, our heuristic is
## (1) use the arg "ora.home" (if part of ...); if not specified,
## (2) set it to `dbhome`, which is an Oracle utility in rhost:/usr/local/bin
## which supposedly returns the ORACLE_HOME (I didn't find this too reliable).
##
## We also look for the "rcp" and "rsh" arguments in "..." to tells
## us which remote shell utilities to use, if not set, we use scp and ssh.
## (This song and dance allows us to create a static linked version of 
## ROracle and run it on machines that don't even have the client Oracle 
## software.)  I'm not sure yet this is a good idea.
{
   if(overwrite && append)
      stop("overwrite and append cannot both be TRUE")
   if(!is.data.frame(value))
      value <- as.data.frame(value)
   if(row.names && !is.null(row.names(value))){
      value <- cbind(row.names(value), value)  ## can't use row.names= here
      names(value)[1] <- "row.names"
   }
   if(missing(field.types) || is.null(field.types)){
      ## the following mapping should be coming from some kind of table
      ## also, need to use converter functions (for dates, etc.)
      field.types <- sapply(value, SQLDataType, mgr = con)
   } 
   names(field.types) <- make.SQL.names(names(field.types), 
                             keywords = .OraSQLKeywords,
                             allow.keywords=F)
   if(length(getResultSets(con))!=0){ ## do we need to clone the connection?
      new.con <- dbConnect(con)       ## there's pending work, so clone
      on.exit(close(new.con))
   } 
   else 
      new.con <- con
   tbl.exists <- existsTable(new.con, name)
   if(tbl.exists){
      if(overwrite){
         if(removeTable(new.con, name))
            tbl.exists <- FALSE    ## not anymore!
         else {
            warning(paste("table", name, "couldn't be overwritten"))
            return(FALSE)
         }
      }
      else if(!append){
         warning(paste("table",name,"exists in database: aborting assignTable"))
         return(FALSE)
      }
   } 
   if(!tbl.exists){     ## need to create a new (empty) table
      sql1 <- paste("create table ", name, "\n(\n\t", sep="")
      sql2 <- paste(paste(names(field.types), field.types), collapse=",\n\t", sep="")
      sql3 <- "\n)\n"
      sql <- paste(sql1, sql2, sql3, sep="")
      rs <- try(dbExecStatement(new.con, sql))
      if(inherits(rs, ErrorClass)){
         warning("aborting assignTable: could not create table")
         return(FALSE)
      } 
      else 
         close(rs)
   }

   fn <- tempfile("ora")
   ctl.fname <- paste(fn, ".ctl", sep="")   ## SQL*Load control file
   ctl.file <- file(ctl.fname, "w")
   log.file <- paste(fn, ".log", sep="")    ## SQL*Load log file

   ## Step 1: form a connection string of the form user/passwd@dbname
   conPars <- getInfo(con, c("user", "passwd", "dbname"))
   con.string <- paste(conPars$user,"/",conPars$passwd,"@",conPars$dbname,sep="")

   ## Step 2: create control file
   hdr <- paste("LOAD DATA\nINFILE  *", "\n", 
                ifelse(append, "APPEND\n",""),
                "INTO TABLE ", name, 
                "FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'\n",
                "\nTRAILING NULLCOLS ")
   hdr <- paste(hdr, "(\n", 
                paste(names(field.types), '\t', "char", collapse=",\n"),
                "\n)\n", sep = "")
   hdr <- paste(hdr, "BEGINDATA\n", sep="")
   cat(hdr, file = ctl.file)
   dots <- list(...)

   ## Step 3: append the data.frame to the control file (actual data)
   safe.write(value, file = ctl.file, batch = dots$batch)
   close(ctl.file)

   ## Step 4: invoke SQL*Loader, possibly on a remote system!
   rhost <- dots$rhost
   if(is.null(rhost)){    ## locally
      cmd <- paste("sqlldr userid=", con.string, " control=", ctl.fname, 
                   " log=", log.file, " silent=all", sep = "")
      rc <- system(cmd, ignore.stderr=TRUE)
      if(rc!=0){
         warning("could not load data into Oracle table")
         unlink(ctl.fname)
         unlink(log.file)
         if(!tbl.exists)
            removeTable(new.con, name)
         return(FALSE)
      } 
   } 
   else {
      ## hack allert: the following allows remote execution of sqlldr, but
      ## I'm not sure if it's really useful (nor portable from one Oracle
      ## installation to another). 

      ## rcp the control file to rhost, rsh sqlldr there, and then
      ## bring back the SQL*Loader log file
      rsh <- ifelse(is.null(dots$rsh), "ssh", dots$rsh)
      rcp <- ifelse(is.null(dots$rcp), "scp", dots$rcp)
      ora.home <- ifelse(is.null(dots$ora.home), "`dbhome`", dots$ora.home)
      ## write a mini Bourne shell script to run on rhost
      sh.fname <- paste(fn, ".sh", sep="")
      sh.file <- file(sh.fname, "w")
      cat("#!/bin/sh\n", file = sh.file)
      cat("ORACLE_HOME=", ora.home, "\n", sep = "", file = sh.file)
      cat("PATH=$PATH:", ora.home, "/bin", "\n", sep = "", file = sh.file)
      cat("export ORACLE_HOME PATH\n", file = sh.file)
      cat("sqlldr userid=", con.string, " control=", ctl.fname, 
          " log=", log.file, " silent=all\n", sep = "", file = sh.file)
      close(sh.file)
      ## string to copy control file and shell script to rhost
      push <- paste(rcp, ctl.fname, paste(rhost, ctl.fname, sep=":"), "\n",
                    rcp, sh.fname,  paste(rhost, sh.fname, sep=":"), "\n",
                    collapse=" ")
      ## string to run shell script
      run <- paste(rsh, rhost, "/bin/sh", sh.fname)
      ## string to clean on rhost and to bring back log file
      pull <- paste(rcp, paste(rhost, log.file, sep=":"), log.file, "\n",
                    rsh, rhost, "rm -rf", log.file, ctl.fname, sh.fname,"\n",
                    collapse=" ")
      rc <- system(push, ignore.stderr = TRUE)
      if(rc!=0){
         warning(paste("aborting assignTable: could not", rcp, 
            "data into remote host", rhost))
         unlink(sh.fname)
         unlink(ctl.fname)
         if(!tbl.exists)
            removeTable(new.con, name)
         return(FALSE)
      }
      rc <- system(run, ignore.stderr=TRUE)
      if(rc!=0){
         warning(paste("aborting assignTable:",
            "could not run SQL*Loader in the remote host", rhost))
         unlink(sh.fname)
         unlink(ctl.fname)
         if(!tbl.exists)
            removeTable(new.con, name)
         return(FALSE)
      }
      rc <- system(pull, ignore.stderr=T)
      if(rc!=0){
         warning(paste("could not bring SQL*Loader log file from", rhost))
         unlink(sh.fname)
         unlink(ctl.fname)
         unlink(log.file)
         if(!tbl.exists)
            removeTable(new.con, name)
         return(FALSE)
      }
   } 
   TRUE
}

"SQLDataType.OraConnection" <-
"SQLDataType.OraManager" <- 
function(mgr, obj, ...)
## find a suitable SQL data type for the R/S object obj
## TODO: Lots and lots!! (this is a very rough first draft)
## need to register converters, abstract out Ora and generalize 
## to Oracle, Informix, etc.  Perhaps this should be table-driven.
## NOTE: Oracle data types differ from the SQL92, "varchar2" data
## can hold character data up to 4000 characters, if larger than this,
## we use "long"
{
   rs.class <- data.class(obj)
   rs.mode <- storage.mode(obj)
   if(rs.class=="numeric"){
      sql.type <- if(rs.mode=="integer") "integer" else  "double precision"
   } 
   else {
      "OraCharType" <- function(x){
         n <- max(nchar(as.character(x)))+1  ## do we really the +1?
         if(n>4000)
            "long"
         else
            paste("varchar2(",n,")", sep="")
      }
      sql.type <- switch(rs.class, 
                         logical = "smallint",
                         character = OraCharType(obj), 
                         factor = OraCharType(obj), 
                         ordered =OraCharType(obj),
                         OraCharType(obj)
                         )
   }
   sql.type
}

".OraSQLKeywords" <-
c( "ACCESS", "ADD", "ALL", "ALTER", "AND", "ANY", "ARRAY", "AS", "ACS",
   "AUDIT", "AUTHID", "AVG", "BEGIN", "BETWEEN", "BINARY INTEGER",
   "BODY", "BOOLEAN", "BULK", "BY", "CHAR", "CHAR_BASE", "CHECK", "CLOSE",
   "CLUSTER", "COLUMN", "COLLECT", "COMMENT", "COMMIT", "COMPRESS", 
   "CONNECT", "CONSTANT", "CREATE", "CURRENT", "CURRVAL", "CURSORS", "DATE",
   "DAY", "DECLARE", "DECIMAL", "DEFAULT", "DELETE", "DESC", "DISTINCT",
   "DO", "DROP", "ELSE", "ELSEIF", "END", "EXCEPTION", "EXCLUSIVE",
   "EXECUTE", "EXISTS", "EXIT", "EXTENDS", "FALSE", "FETCH", "FILE", "FLOAT",
   "FOR", "FORALL", "FROM", "FUNCTION", "GOTO", "GRANT", "GROUP", "HAVING",
   "HEAP", "HOUR", "IDENTIFIED", "IF", "IMMEDIATE", "IN", "INCREMENT",
   "INDEX", "INDICATOR", "INITIAL", "INSERT", "INTEGER", "INTERFACE", 
   "INTERSECT", "INTERVAL", "INTI", "IS", "ISOLATION", "JAVA", "LEVEL", 
   "LIKE", "LIMITED", "LOCK", "LONG", "LOOP", "MAX", "MAXEXTENTS", "MIN",
   "MINUS", "MINUTE", "MSLABEL", "MOD", "MODE", "MODIFY", "MONTH", "NATURALN",
   "NEW", "NEXTVAL", "NOAUDIT", "NOCOMPRESS", "NOCOPY", "NOT", "NOWAIT", 
   "NULL", "NUMBER", "NUMBER_BASE", "OCIROWID", "OF", "OFFLINE", "ON", 
   "ONLINE", "OPAQUE", "OPEN", "OPERATOR", "OPTION", "OR", "ORDER", 
   "ORGANIZATION", "OTHER", "OUT", "PACKAGE", "PARTITION", "PCTFREE", 
   "PLS_INTEGER", "POSITIVE", "POSITIVEN", "PRAGMA", "PRIOR", "PRIVATE",
   "PRIVILEGES", "PROCEDURE", "PUBLIC", "RAISE", "RANGE", "RAW", "REAL", 
   "RECORDS", "REF", "RELEASE", "RENAME", "RESOURCE",
   "RETURN", "REVERSE", "REVOKE", "ROLLBACK", "ROW", "ROWS", "ROWID",
   "ROWLABEL", "ROWNUM", "ROWTYPE", "SAVEPOINT", "SECOND", "SELECT",
   "SEPARATE", "SESSION", "SET", "SHARE", "SIZE", "SMALLINT", "SPACE",
   "SQL", "SQLCODE", "SQLERRM", "START", "STDDEV", "SUBTYPE", "SUCCESSFUL",
   "SUM", "SYNONYM", "SYSDATE", "TABLE", "THEN", "TIME", "TIMESTAMP", "TO",
   "TRIGGER", "TRUE", "TYPE", "UID", "UNION", "UNIQUE", "UPDATE", "USE",
   "USER", "VALIDATE", "VALUES", "VARCHAR", "VARCHAR2", 
   "VARIANCE", "VIEW", "WHEN", "WHENEVER", "WHERE", "WHILE", "WITH", "WORK",
   "WRITE", "YEAR", "ZONE"
)
##
## $Id: OraSupport.q,v 1.1 2002/05/20 21:04:23 dj Exp dj $
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
   reload <- AS(reload, "logical")[1]
   .Call("RS_Ora_init", config.params, reload)
}

"describe.OraManager" <-
function(obj, verbose = F, ...)
## Print out nicely a brief description of the connection Manager
{
  info <- getInfo.OraManager(obj)
  print(obj)
  cat("  Driver name: ", info$drvName, "\n")
  cat("  Max  connections:", info$length, "\n")
  cat("  Conn. processed:", info$counter, "\n")
  cat("  Default records per fetch:", info$"fetch_default_rec", "\n")
  if(verbose){
    cat("  Oracle R/S client version: ", info$clientVersion, "\n")
    cat("  RS-DBI version: ", "0.2", "\n")
  }
  cat("  Open connections:", info$"num_con", "\n")
  if(verbose && !is.null(info$connectionIds)){
    for(i in seq(along = info$connectionIds)){
      cat("   ", i, " ")
      print(info$connectionIds[[i]])
    }
  }
  invisible(NULL)
}

"unload.OraManager"<- 
function(dbMgr, ...)
{
  mgrId <- AS(dbMgr, "integer")
  .Call("RS_Ora_close", mgrId)
}

"getInfo.OraManager" <- 
function(obj, what)
{
  if(!isIdCurrent(obj)){
     print(obj)
     return(invisible(NULL))
  }
  mgrId <- AS(obj, "integer")
  info <- .Call("RS_Ora_managerInfo", mgrId)
  mgrId <- info$managerId
  ## replace mgr/connection id w. actual mgr/connection objects
  conObjs <- vector("list", length = info$"num_con")
  ids <- info$connectionIds
  for(i in seq(along = ids))
    conObjs[[i]] <- NEW("OraConnection", Id = c(mgrId, ids[i]))
  info$connectionIds <- conObjs
  info$managerId <- NEW("OraManager", Id = mgrId)
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
  con.params <- parse.OraConParams(username, password, dbname)
  mgrId <- AS(dbMgr, "integer")
  max.results <- AS(max.results, "integer")
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
  print(obj)
  if(!isIdCurrent(obj))
     return(invisible(NULL))
  info <- getInfo(obj)
  cat("  User:", info$user, "\n")
  cat("  Dbname:", info$dbname, "\n")
  if(verbose){
    cat("  Server version: \n")
    srvVersion <- getVersion(obj)
    for(v in srvVersion)
      cat(paste("    ", v, sep=""), "\n")
    cat("  Oracle R/S client version: ", 
	getInfo(AS(obj, "OraManager"),what="clientVersion"), "\n")
  }
  resIds <- info$resultSetIds
  if(!is.null(resIds)){
    for(i in seq(along = resIds)){
      if(verbose)
        describe(resIds[[i]], verbose = F)
      else
        print(resIds[[i]])
    }
  } else cat("  No resultSet available\n")
  invisible(NULL)
}

"close.OraConnection" <- 
function(con, ..., force = F)
## close connection (force=T to close its pending result sets, if any)
{
  if(!isIdCurrent(con))
    return(TRUE)
  rs <- getResultSets(con)
  if(length(rs)>0){    ## any open result sets?
    done <- sapply(rs, hasCompleted)
    if(all(done) || force){
      cl <- sapply(rs, close)   ## safe to close result sets
      if(any(!cl))
         stop("error while closing result sets")
    }
    else 
       stop("pending result sets -- must close manually")
  }
  conId <- AS(con, "integer")
  .Call("RS_Ora_closeConnection", conId)
}
"getVersion.OraConnection" <-
function(obj)
{
  con <- AS(obj, "OraConnection")
  quickSQL(con, "select * from V$VERSION")[[1]]
}
"getInfo.OraConnection" <-
function(obj, what)
{
  if(!isIdCurrent(obj)){
     print(obj)
     return(invisible(NULL))
  }
  id <- AS(obj, "integer")[1:2]
  info <- .Call("RS_Ora_connectionInfo", id)
  rs <- vector("list", length(info$resultSetIds))
  for(i in seq(along = rs))
    rs[[i]] <- NEW("OraResultSet", Id = c(id, info$resultSetIds[i]))
  info$resultSetIds <- rs
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
  if(!isIdCurrent(con))
     stop("expired connection")
  conId <- AS(con, "integer")
  statement <- AS(statement, "character")
  rsId <- .Call("RS_Ora_exec", conId, statement)
  NEW("OraResultSet", Id = rsId)
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
    return(invisible(rs))
  }
  out <- fetch(rs, n = -1)
  if(hasCompleted(rs))
    close(rs)
  else 
    warning(paste("pending rows in resultSet", rs))
  out
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
  n <- AS(n, "integer")
  rsId <- AS(res, "integer")
  rel <- .Call("RS_Ora_fetch", rsId, nrec = n)
  if(length(rel)==0)
    return(NULL)
  ## we don't want to coerce character data to factors
  cnt <- getInfo(res, what = "rowCount")
  nrec <- length(rel[[1]])
  indx <- seq(from = cnt - nrec + 1, length = nrec)
  attr(rel, "row.names") <- as.character(indx)
  if(usingR())
     class(rel) <- "data.frame"
  else
     oldClass(rel) <- "data.frame"   ## Splus
  rel
}

## Note that originally we had only resultSet both for SELECTs
## and INSERTS, ...  Later on we created a base class dbResult
## for non-Select SQL and a derived class resultSet for SELECTS.

"getInfo.OraResultSet" <- 
#"getInfo.OraResult" <- 
function(obj, what)
{
   if(!isIdCurrent(obj)){
      print(obj)
      return(NULL)
   }
   id <- AS(obj, "integer")
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
	  print(obj)
	  invisible(return(NULL))
	}
	print(obj)
	cat("  Statement:", getStatement(obj), "\n")
	cat("  Has completed?", if(hasCompleted(obj)) "yes" else "no", "\n")
	cat("  Affected rows:", getRowsAffected(obj), "\n")
	invisible(NULL)
      }
}
"describe.OraResultSet" <- 
function(obj, verbose = F, ...)
{
  print(obj)
  if(!isIdCurrent(obj))
    return(invisible(NULL))
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
  if(!isIdCurrent(con))
    return(TRUE)
  rsId <- AS(con, "integer")
  .Call("RS_Ora_closeResultSet", rsId)
}

"isIdCurrent" <- 
function(obj)
## verify that dbObjectId refers to a currently open/loaded database
{ 
  obj <- AS(obj, "integer")
  .Call("RS_DBI_validHandle", obj)
}

"safe.write" <- function(value, file, batch, ...)
## safe.write makes sure write.table don't exceed available memory by batching
## at most batch rows (but it is still slowww)
{  
   N <- nrow(value)
   if(N<1){
      warning("no rows in data.frame")
      return(NULL)
   }
   if(missing(batch) || is.null(batch))
      batch <- 10000
   else if(batch<=0) 
      batch <- N
   from <- 1 
   to <- min(batch, N)
   while(from<=N){
      if(usingR())
         write.table(value[from:to, drop=FALSE], file = file, append = T, 
               quote = T, sep=",", na = .Oracle.NA.string, 
               row.names=F, col.names=F, eol = '\n', ...)
      else
         write.table(value[from:to, drop=FALSE], file = file, append = T, 
               quote.string = T, sep=",", na = .Oracle.NA.string, 
               dimnames.write=F, end.of.row = '\n', ...)
      from <- to+1
      to <- min(to+batch, N)
   }
   invisible(NULL)
}
"parse.OraConParams" <-
function(username="", password="", 
   dbname=ifelse(usingR(), Sys.getenv("ORACLE_SID"), getenv("ORACLE_SID")))
{
## split an Oracle conenction string into the tuple (username, password, dbname),
## possibly overriding with supplied params
   pos <- regexpr("@", username)
   if(pos>0){  ## extract dbname 
      dbn <- substring(username, first = pos+1)
      username <- substring(username, first = 1, last=pos-1)
      if(dbname=="") dbname <- dbn
   }
   pos <- regexpr("/", username)
   if(pos>0){
      pwd <- substring(username, first = pos+1)
      username <- substring(username, first = 1, last = pos-1)
      if(password=="") password <- pwd
   }
   if(username=="" && password=="")
      username <- "/"
   c(username, password, dbname)
}
.conflicts.OK <- TRUE
.First.lib <- function(lib, pkg) {
  library.dynam("ROracle", pkg, lib)
}
