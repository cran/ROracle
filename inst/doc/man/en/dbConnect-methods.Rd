\name{dbConnect-methods}
\docType{methods}
\alias{dbConnect}
\alias{dbDisconnect}
\alias{dbConnect,OraDriver-method}
\alias{dbConnect,ExtDriver-method}
\alias{dbDisconnect,OraConnection-method}
\title{
  Create a Connection Object to an Oracle DBMS
}
\description{
   These methods are straightforward implementations of the corresponding
   generic functions.
}
\usage{
\S4method{dbConnect}{OraDriver}(drv, username = "", password = "", dbname = "", prefetch = FALSE,
          bulk_read = 1000L, bulk_write = 1000L, stmt_cache = 0L,
          external_credentials = FALSE, sysdba = FALSE, ...)
\S4method{dbConnect}{ExtDriver}(drv, prefetch = FALSE, bulk_read = 1000L,
          bulk_write = 1000L, stmt_cache = 0L,
          external_credentials = FALSE, sysdba = FALSE, ...)
\S4method{dbDisconnect}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
    An object of class \code{OraDriver} or \code{ExtDriver}.
  }
  \item{conn}{
    An \code{OraConnection} object as produced by \code{dbConnect}.
  }
  \item{username}{
    A character string specifying a user name.
  }
  \item{password}{
    A character string specifying a password.
  }
  \item{dbname}{
    A character string specifying a connect identifier (for more
    information refer to Chapter 8, Configuring Naming Methods, of Oracle
    Database Net Services Administrator's Guide). This is the same as part
    of the SQL*Plus connect string that follows the '@' sign. 
    If you are using Oracle Wallet to store username and password, 
    then this string should be the connect string used to create the 
    wallet mapping (for more information, refer to Configuring Clients to Use
    the External Password Store in Chapter 3 of Oracle Database Security Guide).
    Connect identifiers for an Oracle TimesTen IMDB instance are supported via
    the OCI tnsnames or easy connect naming methods. For additional information
    on TimesTen connections for OCI see chapter 3, TimesTen Support for OCI, of
    TimesTen In-Memory C Developer's Guide.
    Examples below show various ways to specify the connect identifier.
  }
  \item{prefetch}{
    A logical value indicating TRUE or FALSE. When set to TRUE, ROracle will use
    OCI prefetch buffers to retrieve additional data from the server thus saving
    memory required in RODBI/ROOCI by allocating a single row buffer to fetch 
    the data from OCI. Using prefetch results in a fetch call for every row. By
    default, prefetch is FALSE and array fetch is used to retrieve the data from
    the server.
  }
  \item{bulk_read}{
    An integer value indicating the number of rows to fetch at a time. The
    default value is 1000L. When the prefetch option is selected, memory is
    allocated for prefetch buffers and OCI will fetch that many rows at a time.
    When prefetch is not used (the default), memory is allocated in RODBI/ROOCI
    define buffers. Setting this to a large value will result in more memory
    allocated based on the number of columns in the select list and the types
    of columns. For a column of type character, define buffers are allocated
    using the maximum width times the NLS maximum width. Applications should
    adjust this value based on the query result and a larger value will benefit
    queries that return a large result. An application can tune this value as
    needed.
  }
  \item{bulk_write}{
    An integer value indicating the number of rows to insert, update or delete
    at a time. The default value is 1000L. When the bulk_write value is given
    in argument, memory is allocated for buffers and OCI will write that many
    rows at a time. When bulk_write argument is not given, the default value
    1000 is used to allocate memory for the bind buffers. Setting this to a
    large value will result in more memory allocated based on the number of
    columns in the insert list and the types of columns.
  }
  \item{stmt_cache}{
    An integer value indicating the number of statements to cache. It means 
    that cursors are ready to be used without the need to parse the statements 
    again. The default value is 0L. If stmt_cache value is greater than 0L then
    \code{prefetch} value must be set to TRUE. 
  }
  \item{external_credentials}{
    A logical value indicating TRUE or FALSE. When set to TRUE, ROracle will
    begin OCI session authenticated with external credentials on the connection.
    The default value is FALSE.
  }
  \item{sysdba}{
    A logical value indicating TRUE or FALSE. When set to TRUE, ROracle will
    begin OCI session with SYSDBA privileges on the connection. The default
    value is FALSE.
  }
  \item{\dots}{
    Currently unused.
  }
}
\value{
  \item{dbConnect}{
    An object \code{OraConnection} whose class extends \code{DBIConnection}. 
    This object is used to execute SQL queries on the database.
  }
  \item{dbDisconnect}{
    A logical value indicating whether the operation succeeded or not.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbConnect}{
      Establishes a connection between R and an Oracle Database server.
    }
    \item{dbDisconnect}{
      Frees resources used by the connection object.
    }
  }
}
\details{
  \describe{
    \item{dbConnect}{
      This connection object is used to execute operations on the database.
      
      When \code{prefetch} is set to TRUE, it allows the use of the OCI
      prefetch buffer to retrieve additional data from the server.

      The \code{bulk_read} argument is used to set an integer value indicating
      the number of rows to fetch at a time.

      The \code{bulk_write} argument is used to set an integer value
      indicating the number of rows to write at a time.

      The \code{stmt_cache} argument is used to enable or disable the statement
      caching feature. Its value specifies the statement cache size.

      The \code{external_credentials} argument is used to begin OCI session
      authenticated with external credentials on the connection.

      The \code{sysdba} argument is used to begin OCI session with SYSDBA
      privileges on the connection.
           
      When establishing a connection with an \code{ExtDriver} driver, none
      of the arguments specifying credentials are used. A connection in this
      mode is a singleton object, that is, all calls to \code{dbConnect}
      return the same connection object.
    }
    \item{dbDisconnect}{
      This implementation disconnects the connection between R and the database
      server.  It frees all resources used by the connection object. It frees
      all result sets associated with this connection object.
    }
  }
}
\section{References}{
  For the Oracle Database documentation see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    ## Create an Oracle Database instance and create one connection on the
    ## same machine.
    drv <- dbDriver("Oracle")

    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection to a
    ## remote database using the SID in the connect string. 
    drv <- dbDriver("Oracle")

    ## Refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.
    host <- "myhost"
    port <- 1521
    sid <- "mysid"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
        "(CONNECT_DATA=(SID=", sid, ")))", sep = "")

    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection to a
    ## remote database using the service name.
    drv <- dbDriver("Oracle")

    ## Refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.

    host <- "myhost"
    port <- 1521
    svc <- "mydb.example.com"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
      "(CONNECT_DATA=(SERVICE_NAME=", svc, ")))", sep = "")
    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Use Oracle Wallet authentication.
    con <- dbConnect(drv, username ="", password="", 
    dbname = "<wallet_connect_string>")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Connect to a TimesTen IMDB instance using the easy connect 
    ## naming method where SampleDb is a direct driver TimesTen DSN.
    con <- dbConnect(drv, username ="scott", password="tiger", 
                     dbname = "localhost/SampleDb:timesten_direct")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from dual")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Connect to an extproc (this assumes that the driver has already
    ## been initialized in the embedded R code by passing an external
    ## pointer representing the extproc context).
    con <- dbConnect(Extproc())

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from dual")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Create connection with SYSDBA privileges.
    con <- dbConnect(drv, username ="scott", password="tiger",
                     sysdba = TRUE)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")
    
    ## Use OS authentication as an example of external authentication
    ## Make sure that databse user exist to allow an OS authentication

    ## Create connection authenticated with external credentials.
    con <- dbConnect(drv, username ="", password="",
                     external_credentials = TRUE)
    
    ## Above dbConnect() used OS credentials to connect with database.

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
