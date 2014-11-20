\name{dbSendQuery-methods}
\docType{methods}
\alias{dbSendQuery}
\alias{dbGetQuery}
\alias{dbClearResult}
\alias{dbGetException}
\alias{execute}
\alias{dbSendQuery,OraConnection,character-method}
\alias{dbGetQuery,OraConnection,character-method}
\alias{dbClearResult,OraResult-method}
\alias{dbGetException,OraConnection-method}
\alias{execute,OraResult-method}
\title{
  Execute a statement on a given database connection
}
\description{
   These methods are straight-forward implementations of the corresponding
   generic functions except for the \code{execute} method which is an
   ROracle specific DBI extension.
}
\usage{
\S4method{dbSendQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbGetQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbClearResult}{OraResult}(res, ...)
\S4method{dbGetException}{OraConnection}(conn, ...)

execute(res, ...)
\S4method{execute}{OraResult}(res, data = NULL, ...)
}
\arguments{
  \item{conn}{An \code{OraConnection} object.}
  \item{statement}{A character vector of length 1 with the SQL statement.}
  \item{res}{An \code{OraResult} object.}
  \item{data}{A data.frame specifying bind data}
  \item{prefetch}{
    A logical value indicating TRUE or FALSE. When set to TRUE, ROracle will use
    OCI prefetch buffers to retrieve additional data from the server thus saving
    memory required in RODBI/ROOCI by allocating a single row buffer to fetch 
    the data from OCI. Using prefetch results in a fetch call for every row. By
    default, prefetch is FALSE and array fetch is used to retrive the data from
    server.
  }
  \item{bulk_read}{
    An integer value indicating the number of rows to fetch at a time. Default
    is 1000L. When the prefetch option is selected, memory is allocated for
    prefetch buffers and OCI will fetch those many rows at a time. When prefetch
    is not used (default) memory is allocated in RODBI/ROOCI define buffers.
    Setting this to a large value will result in more memory being allocated
    based on the number of columns in the select list and the types of columns.
    For a column of type character, define buffers are allocated using the
    maximum width times the NLS maximum width. An Application should adjust this
    value based on the query result and a larger value will benefit queries that
    return a large result. The Application can tune this value to its need.
  }
  \item{bulk_write}{
    An integer value indicating the number of rows to write at a time. The
    default value is 1000L. When the bulk_write value is given in argument,
    memory is allocated for buffers and OCI will write that many rows at a
    time. When bulk_write argument is not given, the default value 1000 is
    used to allocate memory for the bind buffers. Setting this to a large
    value will result in more memory allocated based on the number of columns
    in the insert list and the types of columns.
  }
  \item{\dots}{Currently unused.}
}
\value{
  \item{dbSendQuery}{
    An object \code{OraResult} whose class extends \code{DBIResult}. This 
    object is used to fetch data from database, using the function 
    \code{fetch}.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      Query statement is executed and data has fetched from database.
    }
    \item{dbSendQuery}{
      Query statement is executed, but note that data needs to fetch through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{dbClearResult}{
      Resources acquired by result set has free.
    }
    \item{dbGetException}{
      Error information retrieved and then cleaned from driver.
    }
    \item{execute}{
      Query statement is executed.
    }
  }
}
\details{
  \describe{
    \item{dbGetQuery}{
      Implementation does execute query statement and fetch 
      result data from database. 
    }
    \item{dbSendQuery}{
      Implementation does execute query statement and return 
      result set to the application. Now application can perform operations 
      on result set. 
    }
    \item{dbClearResult}{
      Implementation does free resources occupied by result set.
    }
    \item{dbGetException}{
      Implementation does retrieve error information.
    }
    \item{execute}{
      Implementation does execute query statement.
    }
  }
}
\section{References}{
  For the Oracle Database documentaion see 
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp where deptno = :1",
                       data = data.frame(deptno = 10))
    data <- fetch(res, n = -1)
    res2 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data1 = data.frame(deptno = 10), prefetch=TRUE,
                        bulk_read=2L)
    data1 <- fetch(res2, n = -1)
    res3 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data2 = data.frame(deptno = 10), bulk_read=10L)
    data2 <- fetch(res3, n = -1)
    res4 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data3 = data.frame(deptno = 10), bulk_write=10L)
    data3 <- fetch(res4, n = -1)
    res5 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data4 = data.frame(ename = 'SMITH')) 
    data4 <- fetch(res5, n = -1)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
