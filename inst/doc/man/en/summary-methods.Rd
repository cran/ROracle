\name{summary-methods}
\docType{methods}
\alias{summary-methods}
\alias{show-methods}
\alias{show,OraDriver-method}
\alias{show,OraConnection-method}
\alias{show,OraResult-method}
\alias{summary,OraDriver-method}
\alias{summary,OraConnection-method}
\alias{summary,OraResult-method}
\title{
  Summarize an Oracle object
}
\description{
   These methods are straight-forward implementations of the corresponding
   generic functions.
}
\arguments{
  \item{obj}{
    a driver or connection or result set object.
  }
}
\value{
  description of object.
}
\details{
  This describes the object.
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
  \code{\link[DBI]{dbGetInfo}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp")

    summary(drv)
    summary(con)
    summary(res)
    show(drv)
    show(con)
    show(res)   
  } 
}
\keyword{methods}
\keyword{database}
\keyword{interface}
