% $Id: DBIPreparedStatement-class.Rd 126 2003-11-03 22:41:41Z dj $
\name{DBIPreparedStatement-class}
\docType{class}
\alias{DBIPreparedStatement-class}
\title{Class DBIPreparedStatement}
\description{
   Base class for all DBMS-specific prepared statement objects.
}
\section{Objects from the Class}{
   A virtual Class: No objects may be created from it.
}
\section{Extends}{
   Class \code{"DBIObject"}, directly.
   Class \code{"DBIResult"}, directly.
}
\section{Generator}{
   The main generator is \code{\link[ROracle]{dbPrepareStatement}}.
}
\section{Methods}{\describe{
  \item{\link[ROracle]{dbExecStatement}}{\code{signature(ps =
    "DBIPreparedStatement", data = "data.frame")}: ... }
  }
}

\references{
  See the Database Interface definition document
  \code{DBI.pdf} in the base directory of this package
  or \url{http://stat.bell-labs.com/RS-DBI}.
}
\author{R-SIG-DB}

\seealso{
 DBI classes:
 \code{\link[DBI]{DBIObject-class}}
 \code{\link[DBI]{DBIDriver-class}}
 \code{\link[DBI]{DBIConnection-class}}
 \code{\link[DBI]{DBIResult-class}}
}

\examples{\dontrun{
 drv <- dbDriver("Oracle")
 con <- dbConnect(drv, "user/password@dbname")
 ## to do...
}
}
\keyword{classes}
\keyword{interface}
\keyword{database}
% vim: syntax=tex
