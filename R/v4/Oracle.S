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

setClass("OraManager", representation("dbManager", "dbObjectId"))

"Oracle" <- "OraManager" <- 
function(max.con=10, fetch.default.rec = 500)
## create an Oracle database connection manager.  By default we allow
## up to "max.con" connections and single fetches of up to "fetch.default.rec"
## records.
## Returns an object of class "OraManger".  
## Note: This class is a singleton.
{
  if(fetch.default.rec<=0)
    stop("default num of records per fetch must be positive")
  id <- load.OraManager(max.con, fetch.default.rec)
  new("OraManager", Id = id)
}

setMethod("describe", "OraManager", 
	  def = function(obj, verbose = F,  ...){
	    describe.OraManager(obj, verbose = verbose, ...)
	    invisible(NULL)
	  })
setMethod("getInfo", "OraManager",
	  def = function(obj, ...) getInfo.OraManager(obj, ...))
setMethod("load", "OraManager", 
	  def = function(mgr, ...) load.OraManager(...))
setMethod("unload", "OraManager", 
	  def = function(mgr, ...) {
	    if(!isIdCurrent(mgr))
	      stop(paste("expired", class(mgr), deparse(substitute(mgr))))
	    unload.OraManager(mgr,...)
	})
setMethod("getVersion", "OraManager", 
	  def = function(obj, ...) getVersion.OraManager(obj,...))
setMethod("getConnections", "OraManager",
	  def = function(mgr, ...) getConnections.OraManager(mgr,...))
##
## Class: dbConnection
##

setClass("OraConnection", representation("dbConnection", "dbObjectId"))

## Coercion: To extract a manager object from a connection is trivial: 
## just extract the manager id from the connection.

setAs("OraConnection", "OraManager", def = function(object){
   new("OraManager", Id = as(object, "integer")[1])
})

setMethod("dbConnect", "OraManager",
	  def = function(mgr, ...){
	    if(!isIdCurrent(mgr))
	      stop(paste("expired", class(mgr), deparse(substitute(mgr))))
	    id <- newConnection.OraManager(mgr, ...)
	    new("OraConnection", Id = id)
	  })

setMethod("dbConnect", "OraConnection",
	  def = function(mgr, ...){
	    if(!isIdCurrent(mgr))
	      stop(paste("expired", class(mgr), deparse(substitute(mgr))))
	    con.id <- as(mgr, "integer")
	    new.id <- .Call("RS_Ora_cloneConnection", con.id)
	    new("OraConnection", Id = new.id)
	  })

setGeneric("quickSQL", function(con, statement, ...)
	   standardGeneric("quickSQL"))
setMethod("quickSQL", "OraConnection", 
	  def = function(con, statement, ...){
	    quickSQL.OraConnection(con, statement, ...)
	  })
setMethod("getInfo", "OraConnection",
	  def = function(obj, ...) getInfo.OraConnection(obj,...))
setMethod("describe", "OraConnection", 
	  def = function(obj, verbose = F, ...){
	    describe.OraConnection(obj, verbose = verbose, ...)
	    invisible(NULL)
	  })
setMethod("getException", "OraConnection",
	  def = function(con, ...) {
	    id <- as(con, "integer")
	    .Call("RS_Ora_getException", id)
	  })
if(usingR(1,4)){
   ## problem with close
   setMethod("close", signature(con="OraConnection"),
	  def = function(con, ...){ 
	    if(!isIdCurrent(con))
	      stop(paste("expired", class(con), deparse(substitute(con))))
	    close.OraConnection(con)
	  })
} else {
   setMethod("close", signature(con="OraConnection", type= "missing"),
	  def = function(con, type){ 
	    if(!isIdCurrent(con))
	      stop(paste("expired", class(con), deparse(substitute(con))))
	    close.OraConnection(con)
	  })
}
setMethod("dbExecStatement", 
	  signature = list(con = "OraConnection", statement = "character"),
	  def = function(con, statement, ...){
	        execStatement.OraConnection(con, statement, ...)
	  })
setMethod("dbExec", 
	  signature = list(con = "OraConnection", statement = "character"),
	  def = function(con, statement, ...){
	        execStatement.OraConnection(con, statement, ...)
	  })
setMethod("commit", "OraConnection",
	  def = function(con, ...){
	    commit.OraConnection(con) 
	  })
setMethod("rollback", "OraConnection",
	  def = function(con, ...){
	    rollback.OraConnection(con)
	  })
setMethod("getVersion", "OraConnection", 
	  def = function(obj, ...) getVersion.OraConnection(obj))

setMethod("getResultSets", "OraConnection",
	  def = function(con, ...) getResultSets.OraConnection(con,...))

setMethod("getCurrentDatabase", "OraConnection",
	  def = function(obj, ...){
	    if(!isIdCurrent(obj))
	      stop("expired", class(obj), deparse(substitute(obj)))
	    getInfo(obj, what = "dbname")
	  })
if(F){
  ##
  ## Class: OraResult
  ##

  setClass("OraResult", representation("dbResult", "dbObjectId"))

  setMethod("getInfo", "OraResult",
	    def = function(obj, ...) getInfo.OraResult(obj, ...))
  setMethod("describe", "OraResult", 
	    def = function(obj, verbose = F, ...){
	      describe.OraResult(obj, verbose = verbose, ...)
	      invisible(NULL)
	})
  setMethod("getDBconnection", "OraResult",
	    def = function(obj, ...){
	      as(obj, "OraConnection")
	    })
  setMethod("getStatement", "OraResult",
	    def = function(res, ...){
	      getInfo.OraResult(res, "statement", ...)
	    })
  setMethod("getRowsAffected", "OraResult",
	    def= function(res, ...)
	    getInfo.OraResult(res, "rowsAffected"))
  setMethod("hasCompleted", "OraResultSet",
	    def = function(res, ...) 
	    as.logical(getInfo.OraResult(res, "completed")))
  setMethod("getException", "OraResult",
	    def = function(res, ...){
	      id <- as(res, "integer")
	      .Call("RS_Ora_getException", id[1:2])
	    })
  setMethod("close", 
	    signature = list(con = "OraResult", type = "missing"),
	    def = function(con, type){
	    if(!isIdCurrent(con))
	      stop(paste("expired", class(con), deparse(substitute(con))))
	      close.OraResult(con)
	    })
}

##
## Class: dbResultSet
##

if(F)
  setClass("OraResultSet", "OraResult")

setClass("OraResultSet", representation("dbResultSet", "dbObjectId"))

## Coercion: Again, extracting the connection and manager objects 
## from a dbResultSet is trivial -- just get the object ids.

setAs("OraResultSet", "OraConnection", def = function(object){
   new("OraConnection", Id = as(object, "integer")[1:2])
})

setAs("OraResultSet", "OraManager", def = function(object){
   new("OraManager", Id = as(object, "integer")[1])
})

setMethod("getInfo", "OraResultSet",
	  def = function(obj, ...) getInfo.OraResultSet(obj, ...))
setMethod("describe", "OraResultSet", 
	  def = function(obj, verbose = F, ...){
	  describe.OraResultSet(obj, verbose = verbose, ...)
	  invisible(NULL)
	})
if(T){
  ## these should be defined for dbResult (the base class for dbResultSet)
  setMethod("getRowsAffected", "OraResultSet",
	    def = function(res, ...) {
	      getInfo.OraResultSet(res, "rowsAffected")
	    })
  setMethod("getConnection", "OraResultSet",
	    def = function(what){
	      new("OraConnection", Id = what@Id[1:2])
	    })
  setMethod("getStatement", "OraResultSet",
	    def = function(res, ...){
	      getInfo.OraResultSet(res, "statement")
	    })
  setMethod("hasCompleted", "OraResultSet",
	    def = function(res, ...){
	      as.logical(getInfo.OraResultSet(res, "completed"))
	    })
  setMethod("getException", "OraResultSet",
	    def = function(con, ...){
	      id <- as(con, "integer")
	      .Call("RS_Ora_getException", id[1:2])
	    })
}

setMethod("getFields", "OraResultSet",
	  def = function(res, table, dbname, ...){
	    flds <- getInfo(res, "fields")[[1]]
	    n <- as(flds$Sclass, "integer")
	    flds$Sclass <- .Call("RS_DBI_SclassNames", n)
	    n <- as(flds$type, "integer")
            flds$type <- .Call("RS_Ora_typeNames", n)
	    data.frame(flds)
	  })
setMethod("getRowCount", "OraResultSet",
	  def = function(res, ...){
	    getInfo.OraResultSet(res, "rowCount")
	  })
setMethod("fetch", 
	  signature = list(res = "OraResultSet", n = "integer"),
	  def = function(res, n, ...){
	    fetch.OraResultSet(res, n, ...)
	  })
setMethod("fetch",
	  signature = list(res = "OraResultSet", n = "missing"),
	  def = function(res, n, ...){
	    fetch.OraResultSet(res, ...)
	  })
if(usingR(1,4)){
   ## problem with close
   setMethod("close", 
	  signature = list(con = "OraResultSet"),
	  def = function(con, ...){
	    if(!isIdCurrent(con))
	      stop(paste("expired", class(con), deparse(substitute(con))))
	    close.OraResultSet(con)
	  })
} else {
   setMethod("close", 
	  signature = list(con = "OraResultSet", type = "missing"),
	  def = function(con, type){
	    if(!isIdCurrent(con))
	      stop(paste("expired", class(con), deparse(substitute(con))))
	    close.OraResultSet(con)
	  })
}
setMethod("getCurrentDatabase", "OraResultSet",
	  def = function(obj, ...){
	    if(!isIdCurrent(obj))
	      stop("expired", class(obj), deparse(substitute(obj)))
	    con <- as(obj, "OraConnection")
	    getInfo(con, what = "dbname")
	  })

## To run the following meta-data functions the user needs to be able 
## to connect to a database.
setMethod("getDatabases", "dbObjectId", 
	  def = function(obj, ...){
	    con <- as(obj, "OraConnection")
	    quickSQL(con, "show databases")
	  })
setMethod("getTables", 
	  signature(obj = "dbObjectId", dbname = "character"),
	  def = function(obj, dbname, ...){
	    con <- as(obj, "OraConnection")
	    sql <- paste("select table_name from all_tables", dbname)
	    quickSQL(con, sql)
	  })
setMethod("getTables",
	  signature(obj = "dbObjectId", dbname = "missing"),
	  def = function(obj, dbname, ...){
	    con <- as(obj, "OraConnection")
	    quickSQL(con, "select table_name from all_tables")
	  })
## fields are already store in the dbResultSet -- no need to connect to Ora
setMethod("getTableFields", 
	  signature(res ="OraResultSet", 
		    table="missing", 
		    dbname = "missing"),
	  def = function(res, table, dbname, ...){
	    getFields(res)
	  })
setMethod("getFields", 
	  signature(res = "dbObjectId",
		    table = "character",
		    dbname = "character"),
	  def = function(res, table, dbname, ...){
	    con <- as(res, "OraConnection")
	    sql <- paste("select * from ALL_TAB_COLUMNS ",
			 "where TABLE_NAME = '", table, "@", dbname,"'",
			 sep = "")
	    quickSQL(con, sql)
	  })
setMethod("getFields",
	  signature(res = "dbObjectId",
		    table = "character", 
		    dbname = "missing"),
	  def = function(res, table, dbname, ...){
	    table <- table[1]
	    sql <- paste("select * from ALL_TAB_COLUMNS ",
			 "where TABLE_NAME = '", table, "'", sep="")
	    con <- as(res, "OraConnection")
	    quickSQL(con, sql)
	  })
## Don't re-use/perturbe open connections -- open a new one;
## this method does the job for all but dbResultSet objects.
setMethod("getTableFields", 
	  signature(res = "dbObjectId",
		    table = "character",
		    dbname = "missing"),
	  def = function(res, table, dbname, ...){
	    con <- as(res, "OraConnection")
	    getFields(con, table, ...)
	  })
## 
setMethod("getTableIndices",
	  signature(res = "dbObjectId",
		    table = "character", 
		    dbname = "missing"),
	  def = function(res, table, dbname, ...){
	    con <- as(res, "OraConnection")
	    quickSQL(con, paste("show index from", table))
	  })
setMethod("getTableIndices",
	  signature(res = "OraConnection",
		    table = "character",
		    dbname = "missing"),
	  def = function(res, table, dbname, ...){
	    con <- getConnection(res)
	    quickSQL(con, paste("show index from", table))
	  })
setMethod("getTableIndices",
	  signature(res = "OraConnection",
		    table = "character",
		    dbname = "character"),
	  def = function(res, table, dbname, ...){
	    con <- as(res, "OraConnection")
	    quickSQL(object, paste("show indeces from", table, "from", dbname))
	  })









