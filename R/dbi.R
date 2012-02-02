#
# Copyright (c) 2011, 2012, Oracle and/or its affiliates. All rights reserved. 
#
#    NAME
#      dbi.R - DBI implementation for Oracle RDBMS based on OCI
#
#    DESCRIPTION
#      DBI implementation for Oracle RDBMS based on OCI.
#
#    NOTES
#
#    MODIFIED   (MM/DD/YY)
#    demukhin    01/20/12 - cleanup
#    paboyoun    01/04/12 - minor code cleanup
#    demukhin    12/08/11 - more OraConnection and OraResult methods
#    demukhin    12/01/11 - add support for more methods
#    demukhin    10/12/11 - creation
#

##
## Class: DBIDriver
##
setClass("OraDriver",
  representation(
    handle = "externalptr"),
  contains = "DBIDriver"
)

Oracle <- function() .oci.Driver()

setMethod("dbUnloadDriver",
signature(drv = "OraDriver"),
function(drv, ...) .oci.UnloadDriver()
)

setMethod("dbListConnections",
signature(drv = "OraDriver"),
function(drv, ...) .oci.DriverInfo("connections")[[1L]]
)

setMethod("dbGetInfo",
signature(dbObj = "OraDriver"),
function(dbObj, ...) .oci.DriverInfo(...)
)

setMethod("summary",
signature(object = "OraDriver"),
function(object, ...) .oci.DriverSummary()
)

setMethod("show",
signature(object = "OraDriver"),
function (object)
{
  .oci.DriverSummary()
  invisible()
}
)

##
## Class: DBIConnection
##
setClass("OraConnection",
  representation(
    handle = "integer"),
  contains = "DBIConnection"
)

setMethod("dbConnect",
signature(drv = "OraDriver"),
function(drv, ...) .oci.Connect(...)
)

setMethod("dbDisconnect",
signature(conn = "OraConnection"),
function(conn, ...) .oci.Disconnect(conn)
)

setMethod("dbSendQuery",
signature(conn = "OraConnection", statement = "character"),
function(conn, statement, ...) .oci.SendQuery(conn, statement, ...)
)

setMethod("dbGetQuery",
signature(conn = "OraConnection", statement = "character"),
function(conn, statement, ...) .oci.GetQuery(conn, statement, ...)
)

setMethod("dbGetException",
signature(conn = "OraConnection"),
function(conn, ...) .oci.GetException(conn)
)

setMethod("dbListResults",
signature(conn = "OraConnection"),
function(conn, ...) .oci.ConnectionInfo(conn, "results")[[1L]]
)

setMethod("dbGetInfo",
signature(dbObj = "OraConnection"),
function(dbObj, ...) .oci.ConnectionInfo(dbObj, ...)
)

setMethod("summary",
signature(object = "OraConnection"),
function(object, ...) .oci.ConnectionSummary(object)
)

setMethod("show",
signature(object = "OraConnection"),
function (object)
{
  .oci.ConnectionSummary(object)
  invisible()
}
)

##
## DBIConnection: Convenience methods
##
setMethod("dbListTables",
signature(conn = "OraConnection"),
function(conn, ...) .oci.ListTables(conn, ...)
)

setMethod("dbReadTable",
signature(conn = "OraConnection", name = "character"),
function(conn, name, ...) .oci.ReadTable(conn, name, ...)
)

setMethod("dbWriteTable",
signature(conn = "OraConnection", name = "character", value = "data.frame"),
function(conn, name, value, ...) .oci.WriteTable(conn, name, value, ...)
)

setMethod("dbExistsTable",
signature(conn = "OraConnection", name = "character"),
function(conn, name, ...) .oci.ExistsTable(conn, name, ...)
)

setMethod("dbRemoveTable",
signature(conn = "OraConnection", name = "character"),
function(conn, name, ...) .oci.RemoveTable(conn, name, ...)
)

setMethod("dbListFields",
signature(conn = "OraConnection", name = "character"),
function(conn, name, ...) .oci.ListFields(conn, name, ...)
)

##
## DBIConnection: Transaction management
##
setMethod("dbCommit",
signature(conn = "OraConnection"),
function(conn, ...) .oci.Commit(conn, ...)
)

setMethod("dbRollback",
signature(conn = "OraConnection"),
function(conn, ...) .oci.Rollback(conn, ...)
)

##
## DBIConnection: Stored procedures
##
setMethod("dbCallProc",
signature(conn = "OraConnection"),
function(conn, ...) .NotYetImplemented()
)

##
## Class: DBIResult
##
setClass("OraResult",
  representation(
    handle = "integer"),
  contains = "DBIResult"
)

setMethod("fetch",
signature(res = "OraResult", n = "numeric"),
function(res, n, ...) .oci.fetch(res, as.integer(n))
)

setMethod("fetch",
signature(res = "OraResult", n = "missing"),
function(res, n, ...) .oci.fetch(res)
)

setMethod("dbClearResult",
signature(res = "OraResult"),
function(res, ...) .oci.ClearResult(res)
)

setMethod("dbColumnInfo",
signature(res = "OraResult"),
function(res, ...) .oci.ResultInfo(res, "fields")[[1L]]
)

setMethod("dbGetStatement",
signature(res = "OraResult"),
function(res, ...) .oci.ResultInfo(res, "statement")[[1L]]
)

setMethod("dbHasCompleted",
signature(res = "OraResult"),
function(res, ...) .oci.ResultInfo(res, "completed")[[1L]]
)

setMethod("dbGetRowsAffected",
signature(res = "OraResult"),
function(res, ...) .oci.ResultInfo(res, "rowsAffected")[[1L]]
)

setMethod("dbGetRowCount",
signature(res = "OraResult"),
function(res, ...) .oci.ResultInfo(res, "rowCount")[[1L]]
)

setMethod("dbGetInfo",
signature(dbObj = "OraResult"),
function(dbObj, ...) .oci.ResultInfo(dbObj, ...)
)

setMethod("summary",
signature(object = "OraResult"),
function(object, ...) .oci.ResultSummary(object)
)

setMethod("show",
signature(object = "OraResult"),
function (object)
{
  .oci.ResultSummary(object)
  invisible()
}
)

##
## DBIResult: Data conversion
##
setMethod("dbSetDataMappings",
signature(res = "OraResult", flds = "data.frame"),
function(res, flds, ...) .NotYetImplemented()
)

##
## DBIResult: DBI extensions
##
setGeneric("execute",
function(res, ...) standardGeneric("execute")
)

setMethod("execute",
signature(res = "OraResult"),
function(res, ...) .oci.execute(res, ...)
)
