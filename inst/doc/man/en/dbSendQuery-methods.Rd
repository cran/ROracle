\name{dbSendQuery-methods}
\docType{methods}
\alias{dbSendQuery-methods}
\alias{dbGetQuery-methods}
\alias{dbClearResult-methods}
\alias{dbGetException-methods}
\alias{dbSendQuery,OraConnection,character-method}
\alias{dbGetQuery,OraConnection,character-method}
\alias{dbClearResult,OraResult-method}
\alias{dbGetException,OraConnection-method}
\alias{dbGetException,OraResult-method}
\alias{execute}
\alias{execute-methods}
\alias{execute,OraResult-method}
\title{
  Execute a statement on a given database connection
}
\description{
   These methods are straight-forward implementations of the corresponding
   generic functions except for the \code{execute} method which is an
   ROracle specific DBI extension.
}
\arguments{
  \item{conn}{an \code{OraConnection} object.}
  \item{statement}{a character vector of length 1 with the SQL statement.}
  \item{res}{an \code{OraResult} object.}
  \item{data}{a data.frame specifying bind data}
  \item{prefetch}{
    a logical value indicating TRUE or FALSE. When set to TRUE, ROracle will use
    OCI prefetch buffers to retrieve additional data from the server thus saving
    memory required in RODBI/ROOCI by allocating a single row buffer to fetch 
    the data from OCI. Using prefetch results in a fetch call for every row. By
    default, prefetch is FALSE and array fetch is used to retrive the data from
    server.
  }
  \item{bulk_read}{
    an integer value indicating the number of rows to fetch at a time. Default
    is 25L. When prefetch option is select, memory is allocated for prefetch
    buffers and OCI will fetch those many rows at a time. When prefetch is not 
    used(default) memory is allocated in RODBI/ROOCI define buffers. Setting 
    this to a large value will result in more memory allocated based on the 
    number of columns in the select list and the types of columns. For a column
    of character, define buffers are allocated using the maximum width times 
    the NLS maximum width. Application should adjust this value based on the 
    query result and a larger value will benefit queries that return a large 
    result. Application can tune this value to its need.
  }
  \item{lob_prefetch}{
    an integer value indicating the size of lob data that can be prefetched and
    cached while fetching lob data. Default is 1024L.
  }
  \item{\dots }{additional parameters.}
}
\value{
  \item{dbSendQuery}{
    an object \code{OraResult} whose class extends \code{DBIResult}. This 
    object is used to fetch data from database, using the function 
    \code{fetch}.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      query statement is executed and data has fetched from database.
    }
    \item{dbSendQuery}{
      query statement is executed, but note that data needs to fetch through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{dbClearResult}{
      resources acquired by result set has free.
    }
    \item{dbGetException}{
      error information retrieved and then cleaned from driver.
    }
    \item{execute}{
      query statement is executed.
    }
  }
}
\details{
  \describe{
    \item{dbGetQuery}{
      implementation does execute query statement and fetch 
      result data from database. 
    }
    \item{dbSendQuery}{
      implementation does execute query statement and return 
      result set to the application. Now application can perform operations 
      on result set. 
    }
    \item{dbClearResult}{
      implementation does free resources occupied by result set.
    }
    \item{dbGetException}{
      implementation does retrieve error information.
    }
    \item{execute}{
      implementation does execute query statement.
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
    res4 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data3 = data.frame(ename = 'SMITH'), 
                        lob_prefetch=3000L)
    data3 <- fetch(res4, n = -1)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
