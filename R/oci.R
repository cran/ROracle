#
# Copyright (c) 2011, 2014, Oracle and/or its affiliates. All rights reserved.
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
#    ssjaiswa    09/10/14 - Add bulk_write
#    rpingte     05/27/14 - use ORA_SDTZ to format binds
#    rpingte     05/02/14 - Date and Time stamp(with zone and local) are
#                           internally defined as datetime class
#    lzhang      03/20/14 - bug 18263136: for POSIXct with integer internal
#                         - type, convert to double internal first.
#    rpingte     03/10/14 - add end of result
#    rkanodia    10/03/13 - Add session mode
#    rkanodia    08/30/13 - [17383542] Enhance .oci.WriteTable() to work on
#                           tables of global space
#    qinwan      03/01/13 - avoid unnecessary data copy in type check
#    rkanodia    12/10/12 - Changed default value of bulk_read  to 1000
#    rpingte     11/28/12 - 15930335: use timestamp data type for POSIXct value
#    paboyoun    09/17/12 - add difftime support
#    demukhin    09/04/12 - add Extproc driver
#    rkanodia    08/02/12 - Removed redundant arguments passed to functions
#                           and removed LOB prefetch support bug [145082788888888]
#    paboyoun    08/01/12 - optimize .oci.data.frame
#    jfeldhau    06/18/12 - ROracle support for TimesTen.
#    paboyoun    06/04/12 - add data.frame support for list of raw vectors
#    rpingte     05/24/12 - Date time and raw support
#    rkanodia    05/13/12 - LOB prefetch
#    rkanodia    05/12/12 - Statement caching
#    demukhin    05/10/12 - translation changes
#    rpingte     04/23/12 - add interrupt enable
#    rpingte     04/21/12 - add prefetch & array fetch options
#    rkanodia    04/16/12 - Fixing review comments
#    demukhin    04/09/12 - translation
#    paboyoun    03/22/12 - fix typo
#    rkanodia    03/05/12 - obs2 bugfix (13843807)
#    rkanodia    03/05/12 - obs1_bugfix (13843805)
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

.oci.Driver <- function(drv, interruptible = FALSE, extproc.ctx = NULL)
{
  .Call("rociDrvInit", drv@handle, interruptible, extproc.ctx,
        PACKAGE = "ROracle")
  drv
}

.oci.UnloadDriver <- function(drv)
{
  .Call("rociDrvTerm", drv@handle, PACKAGE = "ROracle")
  TRUE
}

.oci.DriverInfo <- function(drv, what)
{
  info <- .Call("rociDrvInfo", drv@handle, PACKAGE = "ROracle")
  info$connections <- lapply(info$connections,
                             function(hdl) new("OraConnection", handle = hdl))
  if (!missing(what))
    info <- info[what]
  info
}

.oci.DriverSummary <- function(drv)
{
  info <- .oci.DriverInfo(drv)
  cat("Driver name:           ", info$driverName,    "\n")
  cat("Driver version:        ", info$driverVersion, "\n")
  cat("Client version:        ", info$clientVersion, "\n")
  cat("Connections processed: ", info$conTotal,      "\n")
  cat("Open connections:      ", info$conOpen,       "\n")
  cat("Interruptible:         ", info$interruptible, "\n")
  invisible(info)
}

###############################################################################
##  (*) OraConnection                                                        ##
###############################################################################

.oci.Connect <- function(drv, username = "", password = "", dbname = "",
                         prefetch = FALSE, bulk_read = 1000L,
                         bulk_write = 1000L, stmt_cache = 0L,
                         external_credentials = FALSE, sysdba = FALSE)
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

  prefetch <- as.logical(prefetch)
  if (length(prefetch) != 1L)
    stop(gettextf("argument '%s' must be a single logical value", "prefetch"))

  bulk_read <- as.integer(bulk_read)
  if (length(bulk_read) != 1L)
    stop(gettextf("argument '%s' must be a single integer", "bulk_read"))
  if (bulk_read < 1L)
    stop(gettextf("argument '%s' must be greater than 0", "bulk_read")) 


  bulk_write <- as.integer(bulk_write)
  if (length(bulk_write) != 1L)
    stop(gettextf("argument '%s' must be a single integer", "bulk_write"))
  if (bulk_write < 1L)
    stop(gettextf("argument '%s' must be greater than 0", "bulk_write")) 

  stmt_cache <- as.integer(stmt_cache)
  if (length(stmt_cache) != 1L)
    stop(gettextf("argument '%s' must be a single integer", "stmt_cache"))
  if (stmt_cache < 0L)
    stop(gettextf("argument '%s' must be a positive integer", "stmt_cache"))

  # Validate external_credentials parameter 
  external_credentials <- as.logical(external_credentials)
  if (length(external_credentials) != 1L)
    stop(gettextf("argument '%s' must be a single logical value",
                  "external_credentials"))
  
  # Validate sysdba parameter 
  sysdba <- as.logical(sysdba)
  if (length(sysdba) != 1L)
    stop(gettextf("argument '%s' must be a single logical value", "sysdba"))
  
  # connect
  params <- c(username, password, dbname)
  hdl <- .Call("rociConInit", drv@handle, params, prefetch, bulk_read,
                bulk_write, stmt_cache, external_credentials, sysdba,
                PACKAGE = "ROracle")
  timesten <- (.Call("rociConInfo", hdl, 
                      PACKAGE = "ROracle")$serverType == "TimesTen IMDB")
  new("OraConnection", handle = hdl, timesten = timesten)
}

.oci.Disconnect <- function(con)
{
  .Call("rociConTerm", con@handle, PACKAGE = "ROracle")
  TRUE
}

.oci.SendQuery <- function(con, stmt, data = NULL, prefetch = FALSE,
                           bulk_read = 1000L, bulk_write = 1000L)
{
  #validate
  prefetch <- as.logical(prefetch)
  if (length(prefetch) != 1L)
    stop(gettextf("argument '%s' must be a single logical value", "prefetch"))

  bulk_read <- as.integer(bulk_read)
  if (length(bulk_read) != 1L)
    stop(gettextf("argument '%s' must be a single integer", "bulk_read"))
  if (bulk_read < 1L)
    stop(gettextf("argument '%s' must be greater than 0", "bulk_read")) 

  bulk_write <- as.integer(bulk_write)
  if (length(bulk_write) != 1L)
    stop(gettextf("argument '%s' must be a single integer", "bulk_write"))
  if (bulk_write < 1L)
    stop(gettextf("argument '%s' must be greater than 0", "bulk_write"))

  stmt <- as.character(stmt)
  .oci.ValidateString("statement",stmt)

  if (!is.null(data))
    data <- .oci.data.frame(data, TRUE)

  hdl <- .Call("rociResInit", con@handle, stmt, data, prefetch,
               bulk_read, bulk_write, PACKAGE = "ROracle")
  new("OraResult", handle = hdl)
}

.oci.GetQuery <- function(con, stmt, data = NULL, prefetch = FALSE,
                          bulk_read = 1000L, bulk_write = 1000L)
{
  #validate
  prefetch <- as.logical(prefetch)
  if (length(prefetch) != 1L)
    stop(gettextf("argument '%s' must be a single logical value", "prefetch"))

  bulk_read <- as.integer(bulk_read)
  if (length(bulk_read) != 1L)
    stop(gettextf("argument '%s' must be a single integer", "bulk_read"))
  if (bulk_read < 1L)
    stop(gettextf("argument '%s' must be greater than 0", "bulk_read")) 

  bulk_write <- as.integer(bulk_write)
  if (length(bulk_write) != 1L)
    stop(gettextf("argument '%s' must be a single integer", "bulk_write"))
  if (bulk_write < 1L)
    stop(gettextf("argument '%s' must be greater than 0", "bulk_write")) 

  stmt <- as.character(stmt)
  .oci.ValidateString("statement",stmt)

  if (!is.null(data))
    data <- .oci.data.frame(data, TRUE)

  hdl <- .Call("rociResInit", con@handle, stmt, data,
               prefetch, bulk_read, bulk_write, PACKAGE = "ROracle")
  res <- try(
  {
    eof_res <- .Call("rociEOFRes", hdl, PACKAGE = "ROracle")
    if (eof_res)
      TRUE
    else
      .Call("rociResFetch", hdl, -1L, PACKAGE = "ROracle")
  }, silent = TRUE)
  .Call("rociResTerm", hdl, PACKAGE = "ROracle")
  if (inherits(res, "try-error"))
    stop(res)

  if (!is.null(res))
  {
    for (i in 1:length(res))
    {
      col <- res[[i]]
      if (class(col) == "datetime")
      {
        class(col) <- "character"
        res[[i]] <- as.POSIXct(strftime(col, "%Y-%m-%d %H:%M:%OS6"))
        attr(res[[i]], "tzone") <- NULL
      }
    }
  }
  res
}

.oci.GetException <- function(con)
{
  .Call("rociConError", con@handle, PACKAGE = "ROracle")
}

.oci.ConnectionInfo <- function(con, what)
{
  info <- .Call("rociConInfo", con@handle, PACKAGE = "ROracle")
  info$results <- lapply(info$results,
                         function(hdl) new("OraResult", handle = hdl))
  if (!missing(what))
    info <- info[what]
  info
}

.oci.ConnectionSummary <- function(con)
{
  info <- .oci.ConnectionInfo(con)
  cat("User name:            ", info$username,      "\n")
  cat("Connect string:       ", info$dbname,        "\n")
  cat("Server version:       ", info$serverVersion, "\n")
  cat("Server type:          ", info$serverType,    "\n")
  cat("Results processed:    ", info$resTotal,      "\n")
  cat("OCI prefetch:         ", info$prefetch,      "\n")
  cat("Bulk read:            ", info$bulk_read,     "\n")
  cat("Bulk write:           ", info$bulk_write,    "\n")
  cat("Statement cache size: ", info$stmt_cache,    "\n")
  cat("Open results:         ", info$resOpen,       "\n")
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

    #Bug 13843807 : Modify query to list views also
    qry <- "select owner, object_name \
                from all_objects where object_type = 'TABLE' \
                or object_type = 'VIEW'"
    res <- .oci.GetQuery(con, qry)
  }
  else if (!is.null(schema))
  {
    # validate schema
    schema <- as.character(schema)
    .oci.ValidateString("schema", schema, TRUE)

    bnd <- paste(':', seq_along(schema), sep = '', collapse = ',')
    #Bug 13843807 : Modify query to list views also
    qry <- paste("select owner, object_name",
                    "from all_objects",
                    "where owner in (", bnd, ")",
                    " and (object_type = 'TABLE'",
                    " or object_type = 'VIEW')")
    res <- .oci.GetQuery(con, qry,
                         data = data.frame(matrix(schema, nrow = 1L)))
  }
  else
  {
    #Bug 13843807 : Modify query to list views also
    qry <- "select user, object_name from \
                    user_objects where (object_type = 'TABLE' \ 
                    or object_type = 'VIEW')"
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
  .oci.ValidateString("name", name)

  # validate schema
  if (!is.null(schema))
  {
    schema <- as.character(schema)
    .oci.ValidateString("schema", schema)
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
    if (length(row.names) != 1L)
      stop("'row.names' must be a single column")
    if (row.names < 1L || row.names > length(cols))
      stop("'row.names' not found")

    names.col <- as.character(res[, row.names])
    res <- res[, -row.names, drop = FALSE]
    row.names(res) <- names.col
  }

  res
}

.oci.WriteTable <- function(con, name, value, row.names = FALSE,
                            overwrite = FALSE, append = FALSE,
                            ora.number = TRUE, schema = NULL)
{
  # commit
  .oci.Commit(con)

  # validate overwite and append
  if (overwrite && append)
    stop("'overwrite' and 'append' cannot both be TRUE")

  # validate name
  name <- as.character(name)
  .oci.ValidateString("name", name)

  # validate schema
  if (!is.null(schema))
  {
    schema <- as.character(schema)
    .oci.ValidateString("schema", schema)
  }

  # add row.names column
  if (row.names && !is.null(row.names(value)))
  {
    value <- cbind(row.names(value), value)
    names(value)[1L] <- "row.names"
  }

  # coerce data
  value <- .oci.data.frame(value)

  # get column names and types
  ctypes <- sapply(head(value,0), .oci.dbType, ora.number = ora.number, 
                   timesten = con@timesten)
  cnames <- sprintf('"%s"', names(value))

  # create table
  drop <- TRUE
  if (.oci.ExistsTable(con, name, schema))
  {
    if (overwrite)
    {
      .oci.RemoveTable(con, name, FALSE, schema)
      .oci.CreateTable(con, name, cnames, ctypes, schema)
    }
    else if (append)
      drop <- FALSE
    else
      stop("table or view already exists")
  }
  else
    .oci.CreateTable(con, name, cnames, ctypes, schema)

  # insert data
  res <- try(
  {
    # [17383542] create query to insert data in table of global space also
    if (is.null(schema))
    {
      stmt <- sprintf('insert into "%s" values (%s)', name,
                      paste(":", seq_along(cnames), sep = "",
                      collapse = ","))
    }
    else
    {
      stmt <- sprintf('insert into "%s"."%s" values (%s)', schema, name,
                      paste(":", seq_along(cnames), sep = "",
                      collapse = ","))
    }
    .oci.GetQuery(con, stmt, data = value)
  }, silent = TRUE)
  if (inherits(res, "try-error"))
  {
    if (drop)
      .oci.RemoveTable(con, name, FALSE, schema)
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
  .oci.ValidateString("name", name)

  # validate schema
  if (!is.null(schema))
  {
    schema <- as.character(schema)
    .oci.ValidateString("schema", schema)
  }

  # check for existence
  if (!is.null(schema))
  {
# Bug 13843805 : Changed table name from all_tables to all_objects
    qry <- "select 1 from all_objects \
                  where (object_name = :1 and owner = :2) \
                  and (object_type = 'TABLE' or object_type = 'VIEW')"
    res <- .oci.GetQuery(con, qry,
                         data = data.frame(name = name, schema = schema))
  }
  else
  {
# Bug 13843805 : Changed table name from user_tables to user_objects
    qry <- "select 1 from user_objects where object_name = :1 \
                   and (object_type = 'TABLE' or object_type = 'VIEW')"
    res <- .oci.GetQuery(con, qry,
                         data = data.frame(name = name))
  }
  nrow(res) == 1L
}

.oci.RemoveTable <- function(con, name, purge = FALSE, schema = NULL)
{
  # validate name
  name <- as.character(name)
  .oci.ValidateString("name", name)

  # validate schema
  if (!is.null(schema))
  {
    schema <- as.character(schema)
    .oci.ValidateString("schema", schema)
  }

  # remove
  parm <- if (purge) "purge" else ""

  #Bug 13843809 : Modify query to find out that given
  # name is table or view
  qry <- "select object_type from all_objects \
                    where object_name = :1 and object_type = 'VIEW'"
  res <- .oci.GetQuery(con, qry,  data = data.frame(name = name))

  if (nrow(res) == 1L)
  {
    if (is.null(schema))
      stmt <- sprintf('drop view "%s"', name)
    else
      stmt <- sprintf('drop view "%s"."%s"', schema, name)
  }
  else
  {
    if (is.null(schema))
      stmt <- sprintf('drop table "%s" %s', name, parm)
    else
      stmt <- sprintf('drop table "%s"."%s" %s', schema, name, parm)
  }

  .oci.GetQuery(con, stmt)
  TRUE
}

.oci.ListFields <- function(con, name, schema = NULL)
{
  name <- as.character(name)
  if (!is.null(schema))
    schema <- as.character(schema)

  #Bug 13843805 : Check table exist or not. 
  #               If table does not exist then throw error
  validTab = .oci.ExistsTable(con,name, schema)

  if (!validTab)
    stop(gettextf('table "%s" does not exist', name))

  # get column names
  if (!is.null(schema))
  {
    if (con@timesten)
    {
      qry <- paste('select rtrim (columns.colname) as column_name ',
                   'from sys.tables, sys.columns ',
                   'where tables.tblid = columns.id ',
                   'and tables.tblname = :1 ',
                   'and tables.owner = :2 ',
                   'order by columns.colnum')     
    }
    else
    {
      qry <- "select column_name from all_tab_columns \
                    where table_name = :1 and owner = :2 \
                    order by column_id"
    }
    res <- .oci.GetQuery(con, qry,
                         data = data.frame(name = name, schema = schema))
  }
  else
  {
    if (con@timesten)
    {
      qry <- paste('select rtrim (columns.colname) as column_name ',
                   'from sys.tables, sys.columns ',
                   'where tables.tblid = columns.id ',
                   'and tables.tblname = :1 ',
                   'order by columns.colnum')     
    }
    else
    {
      qry <- "select column_name from user_tab_columns \
                    where table_name = :1 order by column_id"
    }
    res <- .oci.GetQuery(con, qry,
                         data = data.frame(name = name))
  }
  res[, 1L]
}

###############################################################################
##  (*) OraConnection: Transaction management                                ##
###############################################################################

.oci.Commit   <- function(con)
{
  info <- .oci.ConnectionInfo(con)
  if (info$serverType == "Oracle Extproc")
    .oci.GetQuery(con, "commit")
  else  
    .Call("rociConCommit", con@handle, PACKAGE = "ROracle")
  TRUE
}

.oci.Rollback <- function(con)
{
  info <- .oci.ConnectionInfo(con)
  if (info$serverType == "Oracle Extproc")
    .oci.GetQuery(con, "rollback")
  else  
    .Call("rociConRollback", con@handle, PACKAGE = "ROracle")  
  TRUE
}

###############################################################################
##  (*) OraResult                                                            ##
###############################################################################

.oci.fetch <- function(res, n = -1L)
{
  eof_res <- .Call("rociEOFRes", res@handle, PACKAGE = "ROracle")
  if (eof_res)
    stop("no more data to fetch")

  df <- try(
  {
    .Call("rociResFetch", res@handle, n, PACKAGE = "ROracle")
  }, silent = TRUE)

  if (inherits(res, "try-error"))
    stop(res)

  if (!is.null(df))
  {
    for (i in 1:length(df))
    {
      col <- df[[i]]
      if (class(col) == "datetime")
      {
        class(col) <- "character"
        df[[i]] <- as.POSIXct(strftime(col, "%Y-%m-%d %H:%M:%OS6"))
      }
    }
  }

  df
}

.oci.ClearResult <- function(res)
{
  .Call("rociResTerm", res@handle, PACKAGE = "ROracle")
  TRUE
}

.oci.ResultInfo <- function(res, what)
{
  info <- .Call("rociResInfo", res@handle, PACKAGE = "ROracle")
  if (!missing(what))
    info <- info[what]
  info
}

.oci.EOFResult <- function(res)
{
  eof_res <- .Call("rociEOFRes", res@handle, PACKAGE = "ROracle")
  eof_res
}

.oci.ResultSummary <- function(res)
{
  info <- .oci.ResultInfo(res)
  cat("Statement:           ", info$statement,    "\n")
  cat("Rows affected:       ", info$rowsAffected, "\n")
  cat("Row count:           ", info$rowCount,     "\n")
  cat("Select statement:    ", info$isSelect,     "\n")
  cat("Statement completed: ", info$completed,    "\n")
  cat("OCI prefetch:        ", info$prefetch,     "\n")
  cat("Bulk read:           ", info$bulk_read,    "\n")
  cat("Bulk write:          ", info$bulk_write,   "\n")
  invisible(info)
}

###############################################################################
##  (*) OraResult: DBI extensions                                            ##
###############################################################################

.oci.execute <- function(res, data = NULL)
{
  if (!is.null(data))
    data <- .oci.data.frame(data, TRUE)

  .Call("rociResExec", res@handle, data, PACKAGE = "ROracle")
}

## ------------------------------------------------------------------------- ##
##                            INTERNAL FUNCTIONS                             ##
## ------------------------------------------------------------------------- ##

.oci.drv <- function() get("ora.driver", envir = .oci.GlobalEnv)

.ext.drv <- function() get("ext.driver", envir = .oci.GlobalEnv)

.oci.dbTypeCheck <- function(obj)
{
  (inherits(obj, c("logical", "integer", "numeric", "character",
                    "difftime")) ||
   (inherits(obj, "POSIXct") && typeof(obj) == "double") ||
   (is.list(obj) && all(unlist(lapply(obj, is.raw), use.names = FALSE))))
}

.oci.data.frame <- function(obj, datetime = FALSE)
{
  tzone <- FALSE
  if (!is.data.frame(obj))
    obj <- as.data.frame(obj)
  for (i in seq_len(ncol(obj)))
  {
    col <- obj[[i]]
    if (!.oci.dbTypeCheck(col))
    {
      if (inherits(col, "Date"))
      {
        if (!tzone)
        {
          .oci.ValidateZoneInEnv(FALSE)
          tzone <- TRUE
        }

        if (datetime)
        {
          obj[[i]] <- strftime(col, "%Y-%m-%d %H:%M:%OS6")
          class(obj[[i]]) <- "datetime"
        }
        else
          obj[[i]] <- as.POSIXct(strptime(col, "%Y-%m-%d"))
      }
      else if (inherits(col, "POSIXct")) # integer storage mode
      {
        if (!tzone)
        {
          .oci.ValidateZoneInEnv(FALSE)
          tzone <- TRUE
        }


        if (datetime)
        {
          obj[[i]] <- strftime(col, "%Y-%m-%d %H:%M:%OS6")
          class(obj[[i]]) <- "datetime"
        }
        else
          storage.mode(obj[[i]]) <- "double"
      }
      else
        obj[[i]] <- as.character(col)
    }
    else if (inherits(col, "POSIXct") && datetime)
    {
      if (!tzone)
      {
        .oci.ValidateZoneInEnv(FALSE)
        tzone <- TRUE
      }

      obj[[i]] <- strftime(col, "%Y-%m-%d %H:%M:%OS6")
      class(obj[[i]]) <- "datetime"
    }
    else if (inherits(col, "difftime"))
      obj[[i]] <- as.difftime(as.numeric(col, units = "secs"), units = "secs")
  }
  obj
}

.oci.dbType <- function(obj, ora.number = FALSE, timesten = FALSE)
{

  if (timesten)
  {
    # TimesTen type map
    switch(typeof(obj),
           logical   = if (ora.number) 
                         "number"
                       else
                         "tt_tinyint",
           integer   = if (ora.number)
                         "integer"
                       else
                         "tt_integer",
           double  = if (inherits(obj, "POSIXct"))
                       "timestamp"
                     else if (ora.number)
                       "number"
                     else
                       "binary_double",
           character = "varchar2(128) inline",
           list      = "varbinary(2000)",
           stop(gettextf("ROracle internal error [%s, %d, %s]",
                         ".oci.dbType", 1L, class(obj))))    
  }
  else
  {
    # Oracle type map
    switch(typeof(obj),
           logical   =,
           integer   = "integer",
           double  = if (inherits(obj, "POSIXct"))
                       "timestamp"
                     else if (inherits(obj, "difftime"))
                       "interval day to second"
                     else if (ora.number)
                       "number"
                     else
                       "binary_double",
           character = "varchar2(4000)",
           list      = "raw(2000)",
           stop(gettextf("ROracle internal error [%s, %d, %s]",
                         ".oci.dbType", 1L, class(obj))))
  }
}

.oci.CreateTable <- function(con, name, cnames, ctypes, schema = NULL)
{
  if (is.null(schema))
  {
    stmt <- sprintf('create table "%s" (%s)', name,
                    paste(cnames, ctypes, collapse = ","))
  }
  else
  {
    stmt <- sprintf('create table "%s"."%s" (%s)', schema, name,
                    paste(cnames, ctypes, collapse = ","))
  }
  .oci.GetQuery(con, stmt)
}

.oci.ValidateString <- function(name, value, multi_val = FALSE)
{
  if (!multi_val)
  {
    if (length(value) != 1L)
      stop(gettextf("'%s' must be a single string", name))
  
    if (!nchar(value))
      stop(gettextf("'%s' must be a non-empty string", name))
  }
  else
  {
    if (all(!nchar(value)))
      stop(gettextf("'%s' must be non-empty strings", name))
  }
}

.oci.ValidateZoneInEnv <- function(warning = TRUE)
{
  sdtz <- Sys.getenv("ORA_SDTZ")
  tzone <- Sys.getenv("TZ")

  if (!nchar(sdtz) || !nchar(tzone) || (sdtz != tzone))
  {
    if (warning)
      warning(gettextf("environment variable 'ORA_SDTZ(%s)' must be set to the same time zone region as the the environment variable 'TZ(%s)'", sdtz, tzone))
    else
      stop(gettextf("environment variable 'ORA_SDTZ(%s)' must be set to the same time zone region as the the environment variable 'TZ(%s)'", sdtz, tzone))
  }
}

# end of file oci.R
