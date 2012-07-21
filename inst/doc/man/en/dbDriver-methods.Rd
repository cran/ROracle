\name{dbDriver-methods}
\docType{methods}
\alias{dbDriver-methods}
\alias{dbUnloadDriver-methods}
\alias{dbDriver,character-method}
\alias{dbUnloadDriver,OraDriver-method}
\title{
  Oracle implementation of the Database Interface (DBI) classes 
  and drivers 
}
\description{
  Oracle driver initialization and closing
}
\arguments{
  \item{drvName}{
    character name of the driver to instantiate.
  }
  \item{drv}{
    an object that inherits from \code{OraDriver} as created by 
    \code{dbDriver}.
  }
  \item{...}{
    any other arguments are passed to the driver \code{drvName}.
  }
}
\value{
  \item{dbDriver}{
    An object \code{OraDriver} whose class extends \code{DBIDriver}. This
    object is used to create connections, using the function
    \code{dbConnect}, to one or several Oracle database engines.
  }
  \item{dbUnloadDriver}{
    free all resources occupied by driver object.
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
      Remove communication link between \R client and database.
    }
  }
}
\details{
  \describe{
    \item{dbDriver}{
      object is a singleton, that is, on subsequent invocations
      it returns the same initialized object.

      This implementation allows you to connect to multiple host servers and
      run multiple connections on each server simultaneously.

      When interruptible is set to TRUE, it allows for interrupting long-running
      queries on the server by executing the query in a thread. Main thread
      checks for Ctrl-C and issues OCIBreak/OCIReset to cancel the operation on
      the server. By default interruptible is FALSE.
    }
    \item{dbUnloadDriver}{
      implementation remove communication link between \R client and 
      database. It frees all connection and all result sets associated with
      those connection objects
    }
  }
}
\section{References}{
  For the Oracle Database documentaion see
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
    # create an Oracle instance
    drv <- dbDriver("Oracle")

    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp")
    fetch(res, n = 5)
    fetch(res)
    dbClearResult(res)
    dbUnloadDriver(drv)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
