\name{fetch-methods}
\docType{methods}
\alias{fetch}
\alias{fetch,OraResult-method}
\title{
  Fetch records from a previously executed query
}
\description{
   This method is a straight-forward implementation of the corresponding
   generic function.
}
\usage{
\S4method{fetch}{OraResult}(res, n = -1, ...)
}
\arguments{
  \item{res}{
    an \code{OraResult} object.
  }
  \item{n}{
    maximum number of records to retrieve per fetch.
    Use \code{n = -1} to retrieve all pending records.
  }
  \item{\dots }{currently unused.}
}
\value{
  number of records fetched from database.
}
\details{
  The \code{ROracle} implementations retrieves only \code{n} records,
  and if \code{n} is missing it returns all records.
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
  \code{\link[DBI]{dbClearResult}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp")

    # we now fetch the first 10 records from the resultSet into a data.frame
    data1 <- fetch(res, n = 10)   
    dim(data1)

    dbHasCompleted(res)

    # let's get all remaining records
    data2 <- fetch(res, n = -1)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
