% $Id: dbCallProc-methods.Rd st_server_demukhin_r/1 2011/07/22 22:11:31 vsashika Exp $
\name{dbCallProc-methods}
\docType{methods}
\alias{dbCallProc-methods}
\alias{dbCallProc,OraConnection-method}
\title{
  Call an SQL stored procedure
}
\description{
  Not yet implemented.
}
\section{Methods}{\describe{
\item{conn}{
  a \code{OraConnection} object.
  }
\item{\dots }{
  additional arguments are passed to the implementing method.
  }
}
}
\references{
  See the Database Interface definition document
  \code{DBI.pdf} in the base directory of this package
  or \url{http://stat.bell-labs.com/RS-DBI}.
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
\keyword{methods}
\keyword{interface}
\keyword{database}
% vim: syntax=tex
