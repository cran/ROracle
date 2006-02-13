% $Id: dbCallProc-methods.Rd,v 1.2 2006/02/08 19:17:00 dj Exp dj $
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
