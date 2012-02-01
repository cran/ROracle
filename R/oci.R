#
# Copyright (c) 2011, 2012, Oracle and/or its affiliates. All rights reserved. 
#
#    NAME
#      oci.R - OCI based implementaion for DBI
#
#    DESCRIPTION
#      OCI based implementaion for DBI.
#
#    NOTES
#
#    MODIFIED   (MM/DD/YY)
#    demukhin    01/20/12 - cleanup
#    paboyoun    01/04/12 - minor code cleanup
#    demukhin    12/08/11 - more OraConnection and OraResult methods
#    demukhin    12/01/11 - add support for more methods
#    paboyoun    11/30/11 - don't check column names in oraWriteTable
#    demukhin    10/12/11 - creation
#

###############################################################################
##  (*) OraDriver                                                            ##
###############################################################################

.oci.Driver <- function()
{
  drv <- .oci.drv()
  .Call("rociDrvInit", drv@handle, PACKAGE = "ROracle")
  drv
}

.oci.UnloadDriver <- function()
{
  drv <- .oci.drv()
  .Call("rociDrvTerm", drv@handle, PACKAGE = "ROracle")
  TRUE
}

.oci.DriverInfo <- function(what)
{
  drv <- .oci.drv()
  info <- .Call("rociDrvInfo", drv@handle, PACKAGE = "ROracle")
  info$connections <- lapply(info$connections,
                             function(hdl) new("OraConnection", handle = hdl))
  if (!missing(what))
    info <- info[what]
  info
}

.oci.DriverSummary <- function()
{
  info <- .oci.DriverInfo()
  cat("Driver name:           ", info$driverName,    "\n")
  cat("Driver version:        ", info$driverVersion, "\n")
  cat("Client version:        ", info$clientVersion, "\n")
  cat("Connections processed: ", info$conTotal,      "\n")
  cat("Open connections:      ", info$conOpen,       "\n")
  invisible(info)
}

###############################################################################
##  (*) OraConnection                                                        ##
###############################################################################

.oci.Connect <- function(username = "", password = "", dbname = "")
{
  # validate
  username <- as.character(username)
  if (length(username) != 1L)
    stop("'username' must be a single string")
  password <- as.character(password)
  if (length(password) != 1L)
    stop("'password' must be a single string")
  dbname <- as.character(dbname)
  if (length(dbname) != 1L)
    stop("'dbname' must be a single string")

  # connect
  drv <- .oci.drv()
  params <- c(username, password, dbname)
  hdl <- .Call("rociConInit", drv@handle, params, PACKAGE = "ROracle")
  new("OraConnection", handle = hdl)
}

.oci.Disconnect <- function(con)
{
  drv <- .oci.drv()
  .Call("rociConTerm", drv@handle, con@handle, PACKAGE = "ROracle")
  TRUE
}

.oci.SendQuery <- function(con, stmt, data = NULL)
{
  stmt <- as.character(stmt)
  if (length(stmt) != 1L)
    stop("'statement' must be a single string")

  if (!is.null(data))
  {
    data <- as.data.frame(data)
    data <- data.frame(lapply(data, .oci.dbCoerce), check.names = FALSE,
                       stringsAsFactors = FALSE)
  }

  drv <- .oci.drv()
  hdl <- .Call("rociResInit", drv@handle, con@handle, stmt, data,
               PACKAGE = "ROracle")
  new("OraResult", handle = hdl)
}

.oci.GetQuery <- function(con, stmt, data = NULL)
{
  stmt <- as.character(stmt)
  if (length(stmt) != 1L)
    stop("'statement' must be a single string")

  if (!is.null(data))
  {
    data <- as.data.frame(data)
    data <- data.frame(lapply(data, .oci.dbCoerce), check.names = FALSE,
                       stringsAsFactors = FALSE)
  }

  drv <- .oci.drv()
  hdl <- .Call("rociResInit", drv@handle, con@handle, stmt, data,
               PACKAGE = "ROracle")
  res <- try(
  {
    info <- .Call("rociResInfo", drv@handle, hdl, PACKAGE = "ROracle")
    if (info["completed"][[1L]])
      TRUE
    else
      .Call("rociResFetch", drv@handle, hdl, -1L, PACKAGE = "ROracle")
  }, silent = TRUE)
  .Call("rociResTerm", drv@handle, hdl, PACKAGE = "ROracle")
  if (inherits(res, "try-error"))
    stop(res)
  res
}

.oci.GetException <- function(con)
{
  drv <- .oci.drv()
  .Call("rociConError", drv@handle, con@handle, PACKAGE = "ROracle")
}

.oci.ConnectionInfo <- function(con, what)
{
  drv <- .oci.drv()
  info <- .Call("rociConInfo", drv@handle, con@handle, PACKAGE = "ROracle")
  info$results <- lapply(info$results,
                         function(hdl) new("OraResult", handle = hdl))
  if (!missing(what))
    info <- info[what]
  info
}

.oci.ConnectionSummary <- function(con)
{
  info <- .oci.ConnectionInfo(con)
  cat("User name:         ", info$username,      "\n")
  cat("Connect string:    ", info$dbname,        "\n")
  cat("Server version:    ", info$serverVersion, "\n")
  cat("Results processed: ", info$resTotal,      "\n")
  cat("Open results:      ", info$resOpen,       "\n")
  invisible(info)
}

###############################################################################
##  (*) OraConnection: Convenience methods                                   ##
###############################################################################

.oci.ListTables <- function(con, schema = NULL, all = FALSE, full = FALSE)
{
  if (all)
  {
    # validate schema
    if (!is.null(schema))
      stop("cannot specify 'schema' when 'all' is TRUE")

    qry <- paste('select owner, table_name',
                   'from all_tables')
    res <- .oci.GetQuery(con, qry)
  }
  else if (!is.null(schema))
  {
    # validate schema
    schema <- as.character(schema)

    bnd <- paste(':', seq_along(schema), sep = '', collapse = ',')
    qry <- paste('select owner, table_name',
                   'from all_tables',
                  'where owner in (', bnd, ')')
    res <- .oci.GetQuery(con, qry,
                         data = data.frame(matrix(schema, nrow = 1L)))
  }
  else
  {
    qry <- paste('select user, table_name',
                   'from user_tables')
    res <- .oci.GetQuery(con, qry)
  }

  if (full)
    c(res[, 1L], res[, 2L])
  else
    res[, 2L]
}

.oci.ReadTable <- function(con, name, schema = NULL, row.names = NULL)
{
  # validate name
  name <- as.character(name)
  if (length(name) != 1L)
    stop("'name' must be a single string")

  # validate schema
  if (!is.null(schema))
  {
    schema <- as.character(schema)
    if (length(schema) != 1L)
      stop("'schema' must be a single string")
  }

  # form name
  if (is.null(schema))
    tab <- sprintf('"%s"', name)
  else
    tab <- sprintf('"%s"."%s"', schema, name)

  # read table
  qry <- paste('select *',
                 'from', tab)
  res <- .oci.GetQuery(con, qry)

  # add row.names
  if (!is.null(row.names))
  {
    cols <- names(res)

    if (is(row.names, "logical") || is(row.names, "numeric"))
      row.names <- cols[row.names]
    else
      row.names <- as.character(row.names)

    row.names <- match(row.names, cols, nomatch = 0)
    if (length(row.names) != 1)
      stop("'row.names' must be a single column")
    if (row.names < 1 || row.names > length(cols))
      stop("'row.names' not found")

    names.col <- as.character(res[, row.names])
    res <- res[, -row.names, drop = FALSE]
    row.names(res) <- names.col
  }

  res
}

.oci.WriteTable <- function(con, name, value, row.names = FALSE,
                            overwrite = FALSE, append = FALSE,
                            ora.number = TRUE)
{
  # commit
  .oci.Commit(con)

  # validate overwite and append
  if (overwrite && append)
    stop("overwrite and append cannot both be TRUE")

  # validate name
  name <- as.character(name)
  if (length(name) != 1L)
    stop("'name' must be a single string")

  # add row.names column
  if(row.names && !is.null(row.names(value)))
  {
    value <- cbind(row.names(value), value)
    names(value)[1L] <- "row.names"
  }

  # coerce data
  value <- data.frame(lapply(value, .oci.dbCoerce), check.names = FALSE,
                      stringsAsFactors = FALSE)

  # get column names and types
  ctypes <- sapply(value, .oci.dbType, ora.number = ora.number)
  cnames <- sprintf('"%s"', names(value))

  # create table
  drop <- TRUE
  if (.oci.ExistsTable(con, name))
  {
    if (overwrite)
    {
      .oci.RemoveTable(con, name)
      .oci.CreateTable(con, name, cnames, ctypes)
    }
    else if (append)
      drop <- FALSE
    else
      stop("table or view already exists")
  }
  else
    .oci.CreateTable(con, name, cnames, ctypes)

  # insert data
  res <- try(
  {
    stmt <- sprintf('insert into "%s" values (%s)', name,
                    paste(":", seq_along(cnames), sep = "", collapse = ","))
    .oci.GetQuery(con, stmt, data = value)
  }, silent = TRUE)
  if (inherits(res, "try-error"))
  {
    if (drop)
      .oci.RemoveTable(con, name)
    stop(res)
  }
  else
    .oci.Commit(con)
  TRUE
}

.oci.ExistsTable <- function(con, name, schema = NULL)
{
  # validate name
  name <- as.character(name)
  if (length(name) != 1L)
    stop("'name' must be a single string")

  # validate schema
  if (!is.null(schema))
  {
    schema <- as.character(schema)
    if (length(schema) != 1L)
      stop("'schema' must be a single string")
  }

  # check for existence
  if (!is.null(schema))
  {
    qry <- paste('select 1',
                   'from all_tables',
                  'where table_name = :1',
                    'and owner = :2')
    res <- .oci.GetQuery(con, qry,
                         data = data.frame(name = name, schema = schema))
  }
  else
  {
    qry <- paste('select 1',
                   'from user_tables',
                  'where table_name = :1')
    res <- .oci.GetQuery(con, qry,
                         data = data.frame(name = name))
  }
  nrow(res) == 1L
}

.oci.RemoveTable <- function(con, name, purge = FALSE)
{
  # validate name
  name <- as.character(name)
  if (length(name) != 1L)
    stop("'name' must be a single string")

  # remove
  parm <- if (purge) "purge" else ""
  stmt <- sprintf('drop table "%s" %s', name, parm)
  .oci.GetQuery(con, stmt)
  TRUE
}

.oci.ListFields <- function(con, name, schema = NULL)
{
  # validate name
  name <- as.character(name)
  if (length(name) != 1L)
    stop("'name' must be a single string")

  # validate schema
  if (!is.null(schema))
  {
    schema <- as.character(schema)
    if (length(schema) != 1L)
      stop("'schema' must be a single string")
  }

  # get column names
  if (!is.null(schema))
  {
    qry <- paste('select column_name',
                   'from all_tab_columns',
                  'where table_name = :1',
                    'and owner = :2',
                  'order by column_id')
    res <- .oci.GetQuery(con, qry,
                         data = data.frame(name = name, schema = schema))
  }
  else
  {
    qry <- paste('select column_name',
                   'from user_tab_columns',
                  'where table_name = :1',
                  'order by column_id')
    res <- .oci.GetQuery(con, qry,
                         data = data.frame(name = name))
  }
  res[, 1L]
}

###############################################################################
##  (*) OraConnection: Transaction management                                ##
###############################################################################

.oci.Commit   <- function(con) .oci.GetQuery(con, "commit")

.oci.Rollback <- function(con) .oci.GetQuery(con, "rollback")

###############################################################################
##  (*) OraResult                                                            ##
###############################################################################

.oci.fetch <- function(res, n = -1L)
{
  drv <- .oci.drv()
  inf <- .Call("rociResInfo", drv@handle, res@handle, PACKAGE = "ROracle")
  if (inf$completed)
    stop("no more data")

  .Call("rociResFetch", drv@handle, res@handle, n, PACKAGE = "ROracle")
}

.oci.ClearResult <- function(res)
{
  drv <- .oci.drv()
  .Call("rociResTerm", drv@handle, res@handle, PACKAGE = "ROracle")
  TRUE
}

.oci.ResultInfo <- function(res, what)
{
  drv <- .oci.drv()
  info <- .Call("rociResInfo", drv@handle, res@handle, PACKAGE = "ROracle")
  if (!missing(what))
    info <- info[what]
  info
}

.oci.ResultSummary <- function(res)
{
  info <- .oci.ResultInfo(res)
  cat("Statement:           ", info$statement,    "\n")
  cat("Rows affected:       ", info$rowsAffected, "\n")
  cat("Row count:           ", info$rowCount,     "\n")
  cat("Select stament:      ", info$isSelect,     "\n")
  cat("Statement completed: ", info$completed,    "\n")
  invisible(info)
}

###############################################################################
##  (*) OraResult: DBI extensions                                            ##
###############################################################################

.oci.execute <- function(res, data = NULL)
{
  if (!is.null(data))
  {
    data <- as.data.frame(data)
    data <- data.frame(lapply(data, .oci.dbCoerce), check.names = FALSE,
                       stringsAsFactors = FALSE)
  }

  drv <- .oci.drv()
  .Call("rociResExec", drv@handle, res@handle, data, PACKAGE = "ROracle")
}

## ------------------------------------------------------------------------- ##
##                            INTERNAL FUNCTIONS                             ##
## ------------------------------------------------------------------------- ##

.oci.drv <- function() get("driver", envir = .oci.GlobalEnv)

.oci.dbCoerce <- function(obj)
{
  ## use is() to avoid is.* function overloads
  ##
  if (is(obj, "logical") || is(obj, "integer") || is(obj, "numeric") ||
      is(obj, "character"))
    obj
  else
    as.character(obj)
}

.oci.dbType <- function(obj, ora.number = FALSE)
{
  ## use is() to avoid is.* function overloads
  ##
  if (is(obj, "logical") || is(obj, "integer"))
    "integer"
  else if (is(obj, "numeric"))
  {
    if (ora.number) "number"
    else            "binary_double"
  }
  else if (is(obj, "character"))
    "varchar2(4000)"
  else
    stop("ROracle internal error [.oci.dbType, 1, ", class(obj), "]")
}

.oci.CreateTable <- function(con, name, cnames, ctypes)
{
  stmt <- sprintf('create table "%s" (%s)', name,
                  paste(cnames, ctypes, collapse = ","))
  .oci.GetQuery(con, stmt)
}

# end of file oci.R
