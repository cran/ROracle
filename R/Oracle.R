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
