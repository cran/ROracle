##
## $Id: OraSupport.R st_server_demukhin_r/2 2011/07/27 13:16:05 paboyoun Exp $
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

## RS-Oracle Support functions (actual interface to the C code).

"oraInitDriver" <- 
function(max.con=10, fetch.default.rec = 500, force.reload=FALSE)
## create an Oracle database driver.   By default we allow up to
## "max.con" connections and single fetches of up to "fetch.default.rec"
## records.  These settings may be changed by re-loading the driver
## using the "force.reload" = T flag (note that this will close all 
## currently open connections).
## Returns an object of class "OraDriver".  
## Note: This class is a singleton.
{
   if(fetch.default.rec <= 0L)
      stop("default num of records per fetch must be positive")
   config.params <- as.integer(c(max.con, fetch.default.rec))
   reload <- as.logical(force.reload)[1L]
   id <- .Call("RS_Ora_init", config.params, reload, PACKAGE = .OraPkgName)
   new("OraDriver", Id = id)
}

"oraCloseDriver" <- 
function(drv, ...)
{
   .Call("RS_Ora_close", as(drv, "integer"), PACKAGE = .OraPkgName)
}

"oraNewConnection"<- 
function(drv, username="", password="", 
   dbname = if(is.R()) Sys.getenv("ORACLE_SID") else getenv("ORACLE_SID"),
   max.results=1)
{
   con.params <- oraParseConParams(username, password, dbname)
   drvId <- as(drv, "integer")
   max.results <- as.integer(max.results)
   .OraMaxResults <- 1L
   if(max.results > .OraMaxResults){
      warning(paste("can only have up to", .OraMaxResults, 
         "results per connection"))
      max.results <- .OraMaxResults
   }
   id <- .Call("RS_Ora_newConnection", drvId, con.params, max.results, 
               PACKAGE = .OraPkgName)
   new("OraConnection", Id = id)
}

"oraCloneConnection" <- 
function(drv, ...)
{
   id <- .Call("RS_Ora_cloneConnection", as(drv, "integer"), PACKAGE=.OraPkgName)
   new("OraConnection", Id = id)
}

"oraParseConParams" <-
function(username="", password="", 
   dbname=ifelse(is.R(), Sys.getenv("ORACLE_SID"), getenv("ORACLE_SID")))
{
## split a connection string into the tuple (username, password, dbname),
## possibly overriding with supplied params (handles Oracle's usr/pwd@dbname)
   msg <- "invalid connection string user/password@dbname"
   posAt <- regexpr("@", username)
   posSlash <- regexpr("/", username)
   if(posAt > 0L){  ## extract dbname 
      if(posSlash < 0L) 
         stop(paste(msg, "(must supply password)"))
      dbn <- substring(username, first = posAt + 1L)
      username <- substring(username, first = 1L, last = posAt - 1L)
      if(dbname == "") dbname <- dbn
   }
   if(posSlash > 0L){
      pwd <- substring(username, first = posSlash + 1L)
      username <- substring(username, first = 1L, last = posSlash - 1L)
      if(password == "") password <- pwd
   }
   if(username == "" && password == "")
      username <- "/"
   if(username == "")
      stop(paste(msg, "(must supply username)"))
   c(username, password, dbname)
}

"oraCloseConnection" <- 
function(con, ..., force = FALSE)
## close connection (force=TRUE to close its pending result sets, if any)
{
   if(!isIdCurrent(con))
      return(TRUE)
   rs <- dbListResults(con)
   if(length(rs) > 0L){    ## any open result sets?
      done <- sapply(rs, dbHasCompleted)
      if(all(done) || force){
         cl <- sapply(rs, dbClearResult)   ## safe to close result sets
         if(any(!cl))
            stop("error while closing result sets")
      }
      else 
         stop("pending result sets in the Oracle server -- must close manually")
   }
   .Call("RS_Ora_closeConnection", as(con, "integer"), PACKAGE = .OraPkgName)
}

"oraPrepareStatement" <-
function(con, statement, bind)
{
   if(!isIdCurrent(con))
      stop("expired connection")
   con.id <- as(con, "integer")
   if(is.data.frame(bind))
      bind <- sapply(bind, class)
   ps.id <- .Call("RS_Ora_prepareStatement",
                  con.id = con.id, statement = as.character(statement), 
                  bind.classes = as.character(bind),
                  PACKAGE = .OraPkgName)
   new("OraPreparedStatement", Id = ps.id)
}

"oraExecStatement" <-
function(ps, data = NULL, ora.buf.size = -1)
{
   ## Note that the current implementation matches placeholders (bindings)
   ## to data fields by position, not by name.
   if(!is(ps, "OraPreparedStatement") || !isIdCurrent(ps))
      stop("expired or invalid prepared statement")
   df.classes <- as.character(sapply(data, class))
   out.id <- .Call("RS_Ora_exec",
                   ps = as(ps, "integer"), 
                   data = data, data.classes = df.classes, 
                   buf.size = as.integer(ora.buf.size),
                   PACKAGE = .OraPkgName)
   new("OraPreparedStatement", Id = out.id)  ## we assert this is identical ps
}

"oraExecDirect" <- 
function(con, statement, ora.buf.size = 500)
## submits the sql statement to Oracle and creates a
## dbResult object if the SQL operation does not produce
## output, otherwise it produces a result that can
## be used for fetching rows.
{
   if(!isIdCurrent(con))
      stop("expired connection object")
   ps <- rs <- NULL
   rc <- try({
           ps <- oraPrepareStatement(con, statement, bind=NULL)
           rs <- oraExecStatement(ps, ora.buf.size =
                    as.integer(ora.buf.size))
   })
   if(inherits(rc, ErrorClass)){
      if(!is.null(ps) && !isIdCurrent(ps)) dbClearResult(ps)
      if(!is.null(rs) && !isIdCurrent(rs)) dbClearResult(rs)
      stop(paste("could not exec direct statement", statement))
   } 
   as(rs, "OraResult")      ## must NOT be a prepared statement
}

"oraQuickSQL" <- 
function(con, statement, ...)
{
## this function relies critically in dbHasCompleted() being TRUE
## in the case of non-select statements!
   if(!isIdCurrent(con))
      stop(paste("expired", class(con), deparse(substitute(con))))
   if(length(dbListResults(con)) > 0L){
      new.con <- dbConnect(con)
      on.exit(dbDisconnect(new.con))
      rs <- oraExecDirect(new.con, statement, ...)
   } else  rs <- oraExecDirect(con, statement, ...)
   ## ProC/C++ bug (or "side-effect") 9.2.0 (see the description for 
   ## bug 471975 in the README file for product Pro*C/C++ RELEASE 9.2.0)
   ## (note that we don't look for comments before 'select')
   hack <- grep("^[ \\t]*select ", tolower(dbGetInfo(rs)$statement))
   if(dbHasCompleted(rs) || length(hack) == 0L){
      dbClearResult(rs)
      return(invisible(rs))
   }
   out <- oraFetch(rs, n = -1L)
   if(dbHasCompleted(rs))
      dbClearResult(rs)
   else 
      warning(paste("pending rows in result", rs))
   out
}

"oraFetch" <- 
function(res, n=0, ..., ora.buf.size=-1)
## Fetch at most n records from the opened result (n = -1 means
## all records, n=0 means extract as many as "default_fetch_rec",
## as defined by OraDriver (see summary(mgr, T)).
## The returned object is a data.frame. 
## Note: The method dbHasCompleted() on the result tells you whether
## or not there are pending records to be fetched. See also the methods
## summary(), dbColumnInfo(), dbGetRowCount(), dbGetAffectedRows(),
## as(res, "OraConnection",  dbGetException().
## 
## TODO: Make sure we don't exhaust all the memory, or generate
## an object whose size exceeds option("object.size").  Also,
## are we sure we want to return a data.frame?
{    
   if(dbHasCompleted(res)){
      warning("no more records to fetch")
      return(NULL)
   }
   n <- as.integer(n)
   rsId <- as(res, "integer")
   rel <- .Call("RS_Ora_fetch", rsId, nrec = n, 
              ora.buf.size = as.integer(ora.buf.size), 
              PACKAGE = .OraPkgName)
   if(length(rel) == 0L)
      return(NULL)
   ## we don't want to coerce character data to factors
   cnt <- dbGetInfo(res, what = "rowCount")[[1L]]
   nrec <- length(rel[[1L]])
   indx <- seq(from = cnt - nrec + 1L, length = nrec)
   attr(rel, "row.names") <- as.character(indx)
   if(is.R())
      class(rel) <- "data.frame"
   else
      oldClass(rel) <- "data.frame"   ## Splus
   rel
}

"oraCloseResult" <- 
function(res, ...)
{
   if(!isIdCurrent(res))
      return(TRUE)   ## nothing to do
   .Call("RS_Ora_closeResultSet", as(res, "integer"), PACKAGE = .OraPkgName)
}

## transactions 
"oraCommit" <- 
function(conn, ...)
{
   if(!isIdCurrent(conn))
      stop("expired connection")
   .Call("RS_Ora_commit", as(conn, "integer"), PACKAGE = .OraPkgName)
}

"oraRollback" <-
function(conn, ...)
{
   ## currently we define transactions at the connection level,
   ## thus when we rollback we close all open results/cursors in
   ## that one connection.
   if(!isIdCurrent(conn))
      stop("expired connection")
   rs.ids <- dbListResults(conn)
   out <- .Call("RS_Ora_rollback", as(conn, "integer"), PACKAGE = .OraPkgName)
   for(rs in rs.ids)
      dbClearResult(rs)       ## TODO: move to .Call("RS_Ora_rollbac")
   out
}

"oraTableFields" <-
function(con, name, ...)
{
   sql <- paste("select COLUMN_NAME from ALL_TAB_COLUMNS ",
                "where TABLE_NAME = '", name, "'", sep = "")
   oraQuickSQL(con, sql)[,1L]
}

"oraDescribeDriver" <-
function(obj, verbose = FALSE, ...)
## print out nicely a brief description of the driver
{
   info <- oraDriverInfo(obj)
   print(obj)
   cat("  Driver name: ", info$drvName, "\n")
   cat("  Max  connections:", info$length, "\n")
   cat("  Conn. processed:", info$counter, "\n")
   cat("  Default records per fetch:", info$"fetch_default_rec", "\n")
   if(verbose){
      cat("  Oracle R/S client version:", .OraPkgVersion, "\n")
      cat("  RS-DBI version: ", dbGetDBIVersion(), "\n")
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

"oraDriverInfo" <- 
function(obj, what)
{
   if(!isIdCurrent(obj)){
      print(obj)
      return(invisible(NULL))
   }
   drvId <- as(obj, "integer")
   info <- .Call("RS_Ora_managerInfo", drvId, PACKAGE = .OraPkgName)
   info$clientVersion <- .OraPkgVersion
   drvId <- info$managerId
   ## replace mgr/connection id w. actual mgr/connection objects
   conObjs <- vector("list", length = info$"num_con")
   ids <- info$connectionIds
   for(i in seq(along = ids))
      conObjs[[i]] <- new("OraConnection", Id = c(drvId, ids[i]))
   info$connectionIds <- conObjs
   info$managerId <- new("OraDriver", Id = drvId)
   if(!missing(what))
      info <- info[what]
   info
}

"oraDescribeConnection" <- 
function(obj, verbose = FALSE, ...)
{
   print(obj)
   if(!isIdCurrent(obj))
      return(invisible(NULL))
   info <- oraConnectionInfo(obj)
   cat("  User:", info$user, "\n")
   cat("  Dbname:", info$dbname, "\n")
   if(verbose){
      cat("  Oracle Server version: \n")
      con <- as(obj, "OraConnection")
      srvVersion <- oraQuickSQL(con, "select * from V$VERSION")[[1L]]
      for(v in srvVersion)
         cat(paste("    ", v, sep=""), "\n")
   }
   resIds <- info$resultSetIds
   if(!is.null(resIds)){
      for(i in seq(along = resIds)){
         if(verbose)
            summary(resIds[[i]], verbose = FALSE)
         else
            print(resIds[[i]])
      }
   } else cat("  No result available\n")
   invisible(NULL)
}

"oraConnectionInfo" <-
function(obj, what)
{
   if(!isIdCurrent(obj)){
      print(obj)
      return(invisible(NULL))
   }
   id <- as(obj, "integer")[1:2]
   info <- .Call("RS_Ora_connectionInfo", id, PACKAGE = .OraPkgName)
   rs <- vector("list", length(info$resultSetIds))
   for(i in seq(along = rs))
      rs[[i]] <- new("OraResult", Id = c(id, info$resultSetIds[i]))
   info$resultSetIds <- rs
   if(!missing(what))
      info <- info[what]
   info
}

"oraResultInfo" <- 
function(obj, what)
{
   if(!isIdCurrent(obj)){
      print(obj)
      return(NULL)
   }
   id <- as(obj, "integer")
   info <- .Call("RS_Ora_resultSetInfo", id, PACKAGE = .OraPkgName)
   ## turn fields into a data.frame
   ## TODO: should move this to the C code.
   flds <- info$fields[[1L]]
   if(!is.null(flds)){
      flds$Sclass <- .Call("RS_DBI_SclassNames", flds$Sclass, 
                        PACKAGE = .OraPkgName)
      flds$type <- .Call("RS_Ora_typeNames", as.integer(flds$type), 
                        PACKAGE = .OraPkgName)
      ## no factors
      info$fields <- structure(flds, row.names = paste(seq(along=flds$type)),
                            class = "data.frame")
   }
   if(!missing(what))
     info <- info[what]
   info
}

"oraDescribeResult" <- 
function(obj, verbose = FALSE, ...)
{
  print(obj)
  if(!isIdCurrent(obj))
    return(invisible(NULL))
  cat("  Statement:", dbGetStatement(obj), "\n")
  cat("  Has completed?", if(dbHasCompleted(obj)) "yes" else "no", "\n")
  cat("  Affected rows:", dbGetRowsAffected(obj), "\n")
  cat("  Rows fetched:", dbGetRowCount(obj), "\n")
  flds <- dbListFields(obj)
  if(verbose && !is.null(flds)){
    cat("  Fields:\n")  
    print(dbGetInfo(obj, "fields")[[1L]])
  }
  invisible(NULL)
}

"oraPreparedStatementInfo" <-
function(obj, what, ...)
{
   info <- oraResultInfo(obj, what, ...)  ## next method
   info$boundParams <- oraBoundParamsInfo(obj)
   if(!missing(what))
     info <- info[what]
   info
}

"oraBoundParamsInfo" <- 
function(obj)
{
   if(!isIdCurrent(obj) || !inherits(obj, "OraPreparedStatement")){
      return(NULL)
   }
   id <- as(obj, "integer")
   info <- .Call("RS_Ora_boundParamsInfo", id, PACKAGE = .OraPkgName)
   if(!is.null(info)){
      info$Sclass <- .Call("RS_DBI_SclassNames", info$Sclass, 
                        PACKAGE = .OraPkgName)
      ## no factors
      info <- structure(info, row.names = paste(seq(along=info[[1L]])),
                            class = "data.frame")
   }
   info
}

"oraDescribePreparedStatement" <-
function(obj, verbose = FALSE, ...)
{
   oraDescribeResult(obj, verbose, ...)
   if(verbose){
      cat("  Bound parameters:\n")
      info <- dbGetInfo(obj)
      print(info$boundParams)
   }
   invisible(NULL)
}

"safe.write" <- function(value, file, batch, ...)
## safe.write makes sure write.table don't exceed available memory by batching
## at most batch rows (but it is still slowww)
{  
   N <- nrow(value)
   if(N < 1L){
      warning("no rows in data.frame")
      return(NULL)
   }
   if(missing(batch) || is.null(batch))
      batch <- 10000L
   else if(batch <= 0L) 
      batch <- N
   from <- 1L
   to <- min(batch, N)
   while(from<=N){
      if(is.R())
         write.table(value[from:to,, drop=FALSE], file = file, append = TRUE, 
               quote = TRUE, sep=",", na = .Ora.NA.string, 
               row.names=FALSE, col.names=FALSE, eol = '\n', ...)
      else
         write.table(value[from:to,, drop=FALSE], file = file, append = TRUE, 
               quote.string = TRUE, sep=",", na = .Ora.NA.string, 
               dimnames.write=FALSE, end.of.row = '\n', ...)
      from <- to + 1L
      to <- min(to + batch, N)
   }
   invisible(NULL)
}

"oraDataType" <-
function(obj, ...)
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
   if(rs.class == "numeric"){
      sql.type <- if(rs.mode == "integer") "integer" else "double precision"
   } 
   else {
      "OraCharType" <- function(x){
         n <- unique(nchar(as.character(x)))
         if (length(n) > 1L)
            n <- 2^(ceiling(log2(max(n))) + 1) ## add padding
         else if (n == 0L)
            n <- 2
         if(n > 4000L)
            "long"
         else
            paste("varchar2(", n, ")", sep="")
      }
      sql.type <- switch(rs.class, 
                         logical = "smallint",
                         OraCharType(obj))
   }
   sql.type
}


"oraReadTable" <-
function(con, name, row.names = "row_names", check.names = TRUE, ...)
## Should we also allow row.names to be a character vector (as in read.table)?
## is it "correct" to set the row.names of output data.frame?
## Use NULL, "", or 0 as row.names to prevent using any field as row.names.
{
   out <- try(dbGetQuery(con, paste("SELECT * from", name)))
   if(inherits(out, ErrorClass))
      stop(paste("could not find table", name))
   if(check.names)
       names(out) <- make.names(names(out), unique = TRUE)
   ## should we set the row.names of the output data.frame?
   nms <- names(out)
   j <- switch(mode(row.names),
           "character" = if(row.names == "") 0L else
               match(tolower(row.names), tolower(nms), 
                     nomatch = if(missing(row.names)) 0L else -1L),
           "numeric", "logical" = row.names,
           "NULL" = 0L,
           0L)
   if(j == 0L) 
      return(out)
   if(is.logical(j)) ## Must be TRUE
      j <- match(row.names, tolower(nms), nomatch = 0L) 
   if(j < 1L || j > ncol(out)){
      warning("row.names not set on output data.frame (non-existing field)")
      return(out)
   }
   rnms <- as.character(out[,j])
   if(all(!duplicated(rnms))){
      out <- out[, -j, drop = FALSE]
      row.names(out) <- rnms
   } else warning("row.names not set on output (duplicate elements in field)")
   out
} 

"oraWriteTable" <-
function(con, name, value, field.oraTypes, row.names = TRUE, 
   overwrite=FALSE, append=FALSE, ...)
## Create table "name" (must be an SQL identifier) and populate
## it with the values of the data.frame "value" (possibly after coercion
## to data.frame).
## 
## BUG: In the unlikely event that value has a field called "row.names"
## we could inadvertently overwrite it (here the user should set row.names=F)
## 
## Note: transactions are being defined... Here I need a "savepoint foo"
##
{
   if(overwrite && append)
      stop("overwrite and append cannot both be TRUE")
   if(!is.data.frame(value))
      value <- as.data.frame(value)
   if(row.names && !is.null(row.names(value))){
      value <- cbind(row.names(value), value)  ## can't use row.names= here
      names(value)[1L] <- "row.names"
   }
   if(missing(field.oraTypes) || is.null(field.oraTypes)){
      ## the following mapping should be coming from some kind of table
      ## also, need to use converter functions (for dates, etc.)
      field.oraTypes <- sapply(value, oraDataType, mgr = con)
   } 
   names(field.oraTypes) <- make.db.names.default(names(field.oraTypes), 
                             keywords = .OraSQLKeywords,
                             allow.keywords=FALSE)
   if(length(dbListResults(con)) != 0L){ ## do we need to clone the connection?
      new.con <- dbConnect(con)          ## there's pending work, so clone
      on.exit(dbDisconnect(new.con))
   } 
   else 
      new.con <- con
   tbl.exists <- dbExistsTable(new.con, name)
   if(tbl.exists){
      if(overwrite){
         if(dbRemoveTable(new.con, name))
            tbl.exists <- FALSE    ## not anymore!
         else {
            warning(paste("table", name, "couldn't be overwritten"))
            return(FALSE)
         }
      }
      else if(!append){
         warning(paste("table", name, 
                       "exists in database: aborting oraWriteTable"))
         return(FALSE)
      }
   } 
   if(!tbl.exists){     ## need to create a new (empty) table
      sql1 <- paste("create table ", name, "\n(\n\t", sep="")
      sql2 <- paste(paste(names(field.oraTypes), field.oraTypes), collapse=",\n\t", sep="")
      sql3 <- "\n)\n"
      sql <- paste(sql1, sql2, sql3, sep="")
      rs <- try(oraExecDirect(new.con, sql))
      if(inherits(rs, ErrorClass)){
         warning("aborting oraWriteTable: could not create table")
         return(FALSE)
      } 
      else 
         dbClearResult(rs)
   }

   ## we now bind the data
   fld.names <- names(field.oraTypes)
   istmt <- paste("insert into ", name, 
                      "(", paste(fld.names, collapse=","), ")",
                      "VALUES (", 
                      paste(":", seq(along=fld.names), sep="", collapse=","), 
                      ")"
                     )
   fields.Sclass <- sapply(value, class)
   ## should we convert any columns before we ship data?
   prim.types <- c("numeric", "integer", "logical", "character")
   for(i in seq(along = fields.Sclass)){
      if(!(fields.Sclass[i] %in% prim.types)){
         value[[i]] <- as.character(value[[i]])
         fields.Sclass[i] <- "character"
      }
   }

   ## Begin transaction
   rc <- try({
      ps <- dbPrepareStatement(new.con, istmt, bind = fields.Sclass, ...)
      rs <- dbExecStatement(ps, data = value, ...)
      dbClearResult(rs)
   })
   if(inherits(rc, ErrorClass)){
      if(!tbl.exists)
         dbRemoveTable(con, name)
      out <- FALSE
   }
   else {
      dbCommit(new.con)
      out <- TRUE
   }
   out
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
