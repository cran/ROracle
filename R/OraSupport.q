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

