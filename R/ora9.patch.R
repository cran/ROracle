##
## This file contains a patch to be used only with Oracle 9 (client).
##
## Bug description:
##
## Apparently there is a bug (either in the Oracle 9 ProC/C++ function 
## sqlgls or in the ROracle code) that causes a SELECT on a newly opened 
## connection to be misidentified by sqlgls() as fun code 0, instead of 
## the correct 04, causing ROracle to incorrectly generate the error 
## message "cannot retrieve data from non-select" (or somthing like this).
##
## Workaround:
##
## Source this file either in your global environment, or append it
## to $R_PACKAGE_DIR/R/ROracle, prior to invoking R.  E.g., 
##
##    cat ora9.patch.R >> /home/local/lib/R/library/ROracle/R/ROracle
##
## Note: This is a horrible hack that forces a trivial SELECT on every 
## new connection.

## NOTE: We're defining the default behavior to assume it is 
## using Oracle 9.  

"ora9.workaround" <-
function(con)
{
   if(exists(".Oracle9") && !.Oracle9)
      return(FALSE)
   rs <- dbSendQuery(con, "select * from V$VERSION")
   dbClearResult(rs)
}

"oraNewConnection"<- 
function(drv, username="", password="", 
   dbname = if(usingR()) Sys.getenv("ORACLE_SID") else getenv("ORACLE_SID"),
   max.results=1)
{
   con.params <- oraParseConParams(username, password, dbname)
   drvId <- as(drv, "integer")
   max.results <- as(max.results, "integer")
   .OraMaxResults <- 1
   if(max.results>.OraMaxResults){
      warning(paste("can only have up to", .OraMaxResults, 
         "results per connection"))
      max.results <- .OraMaxResults
   }
   id <- .Call("RS_Ora_newConnection", drvId, con.params, max.results, 
               PACKAGE = .OraPkgName)
   con <- new("OraConnection", Id = id)
   ora9.workaround(con)
   con
}

"oraCloneConnection" <- 
function(drv, ...)
{
   id <- .Call("RS_Ora_cloneConnection", as(drv,"integer"), PACKAGE=.OraPkgName)
   con <- new("OraConnection", Id = id)
   ora9.workaround(con)
   con
}
