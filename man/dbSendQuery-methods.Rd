\name{dbSendQuery-methods}
\docType{methods}
\alias{dbSendQuery}
\alias{dbGetQuery}
\alias{oracleProc}
\alias{dbClearResult}
\alias{dbGetException}
\alias{execute}
\alias{dbSendQuery,OraConnection,character-method}
\alias{dbGetQuery,OraConnection,character-method}
\alias{dbClearResult,OraResult-method}
\alias{oracleProc,OraConnection,character-method}
\alias{dbGetException,OraConnection-method}
\alias{execute,OraResult-method}
\title{
  Execute a Statement on a Given Database Connection
}
\description{
   These methods are straight-forward implementations of the corresponding
   generic functions except for the \code{execute} method, which is an
   ROracle specific DBI extension.
}
\usage{
\S4method{dbSendQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbGetQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{oracleProc}{OraConnection,character}(conn, statement, data = NULL, 
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
  \item{data}{A \code{data.frame} specifying bind data}
  \item{prefetch}{
    A logical value that specifies whether ROracle uses prefetch buffers or an
    array fetch to retrieve data from the server. If \code{TRUE}, then ROracle 
    uses OCI prefetch buffers to retrieve additional data from the server thus 
    saving the memory required in RODBI/ROOCI by allocating a single row buffer 
    to fetch the data from OCI. Using prefetch results in a fetch call for every
    row. If \code{FALSE} (the default), then ROracle uses an array fetch to 
    retrieve the data.
  }
  \item{bulk_read}{
    An integer value indicating the number of rows to fetch at a time. The 
    default value is 1000L. When the prefetch option is selected, memory is 
    allocated for prefetch buffers and OCI fetches the specified number of rows 
    at a time. When prefetch is not used, which is the default, memory is 
    allocated in RODBI/ROOCI define buffers. Setting this to a large value 
    results in more memory being allocated based on the number of columns in 
    the select list and the types of columns. For a column of type character, 
    define buffers are allocated using the maximum width times the NLS maximum 
    width. An application should adjust this value based on the query result.
    A larger value benefits queries that return a large result. The 
    application can tune this value as needed.
  }
  \item{bulk_write}{
    An integer value indicating the number of rows to write at a time. The
    default value is 1000L. When a bulk_write value is specified, memory is 
    allocated for buffers and OCI writes that many rows at a time. If the
    bulk_write argument is not used, then the default value is used to 
    allocate memory for the bind buffers. Setting \code{bulk_write} to a large
    value results in more memory being allocated based on the number of columns
    in the insert list and the types of columns.
  }
  \item{\dots}{Currently unused.}
}
\value{
  \item{dbSendQuery}{
    An \code{OraResult} object whose class extends \code{DBIResult}. This 
    object is used to fetch data from a database, using the function 
    \code{fetch}.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      Query statement is executed and data is fetched from database.
    }
    \item{dbSendQuery}{
      Query statement is executed, but data needs to be fetched through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{oracleProc}{
      PL/SQL stored procedure or function query statement is executed and 
      result is returned.
    }
    \item{dbClearResult}{
      Resources acquired by the result set are freed.
    }
    \item{dbGetException}{
      Error information is retrieved and then cleaned from the driver.
    }
    \item{execute}{
      Query statement is executed.
    }
  }
}
\details{
  \describe{
    \item{dbGetQuery}{
      This function executes a query statement and fetches the result data
      from the database. It should not be used for calling PL/SQL queries.
    }
    \item{dbSendQuery}{
      This function executes a query statement and returns a result set to the 
      application. The application can then perform operations on the result set.
      It should not be used for calling PL/SQL queries.
    }
     \item{oracleProc}{
      This function executes a PL/SQL stored procedure or function query
      statement and returns the result.
    }
    \item{dbClearResult}{
      This function frees resources used by result set.
    }
    \item{dbGetException}{
      This function retrieves error information.
    }
    \item{execute}{
      This function executes the specified query statement.
    }
  }
}
\section{References}{
  For the Oracle Database documentation see 
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
                        data1 <- data.frame(deptno = 10), prefetch=TRUE,
                        bulk_read=2L)
    data1 <- fetch(res2, n = -1)
    data1

    res3 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data2 <- data.frame(deptno = 10), bulk_read=10L)
    data2 <- fetch(res3, n = -1)
    data2

    res4 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data3 <- data.frame(deptno = 10), bulk_write=10L)
    data3 <- fetch(res4, n = -1)
    data3

    res5 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data4 <- data.frame(ename = 'SMITH')) 
    data4 <- fetch(res5, n = -1)
    data4
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
