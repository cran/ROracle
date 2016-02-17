\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
  Oracle Implementation of the Database Interface (DBI) Classes and Drivers
}
\description{
  Oracle driver initialization and closing.
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
    An object that inherits from \code{OraDriver} or \code{ExtDriver}
    as created by \code{dbDriver}.
  }
  \item{...}{
    Any other arguments to pass to the driver \code{drvName}.

  }
}
\value{
  \item{dbDriver}{
    An object \code{OraDriver} or \code{ExtDriver} whose class extends
    \code{DBIDriver}. This object is used to create connections, using the
    function \code{dbConnect}, to one or more Oracle Database engines.
  }
  \item{dbUnloadDriver}{
    Free all resources occupied by the driver object.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbDriver}{
      The \R client part of the database communication is initialized,
      but note that connecting to the database engine needs to be done through
      calls to \code{\link[DBI]{dbConnect}}.
    }
    \item{dbUnloadDriver}{
      Remove the communication link between the \R client and the database.
    }
  }
}
\details{
  \describe{
    \item{dbDriver}{
       This object is a singleton, that is, subsequent invocations of
       \code{dbDriver} return the same initialized object.

      This implementation allows you to connect to multiple host servers and
      run multiple connections on each server simultaneously.

      When \code{interruptible} is set to TRUE, it allows for interrupting
      long-running queries on the server by executing the query in a thread.
      Main thread checks for Ctrl-C and issues OCIBreak/OCIReset to cancel the
      operation on the server. By default, \code{interruptible} is FALSE.

      When \code{unicode_as_utf8} is set to FALSE, NCHAR, NVARCHAR and NCLOB
      data is fetched using the character set specified by the NLS_LANG
      setting. By default, \code{unicode_as_utf8} is set to TRUE.

      When \code{ora.attributes} is set to TRUE, the result set from
      \code{dbGetQuery} and \code{fetch} contains DBMS-specific attributes like
      \code{ora.encoding}, \code{ora.type}, and \code{ora.maxlength} for the
      corresponding column.

    }
    \item{dbUnloadDriver}{
      This implementation removes communication links between the \R client and
      the database. It frees all connections and all result sets associated
      with those connection objects.
    }
  }
}
\section{References}{
  For Oracle Database documentation, see
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
  \code{\link[DBI]{dbListTables}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    # first load the library
    library("ROracle")

    # create an Oracle instance
    drv <- dbDriver("Oracle")

    con <- dbConnect(drv, "scott", "tiger")
    dbListTables(con)

    # fetch all results from the emp table
    res <- dbGetQuery(con, "select * from emp")

    # dbSendQuery can be used to fetch data in chunks 
    # as well as all of data at once
    res <- dbSendQuery(con, "select * from emp")

    # fetch all results
    fetch(res)

    # or a chunk at a time
    fetch(res, n = 5)

    # describing the schema for the emp table using dbGetInfo
    dbGetInfo(res, what = 'fields')

    # clear the result
    dbClearResult(res)

    # disconnect from the database
    dbDisconnect(con)

    # free the driver object
    dbUnloadDriver(drv)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
