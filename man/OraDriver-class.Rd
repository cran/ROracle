\name{OraDriver-class}
\docType{class}
\alias{OraDriver-class}
\title{Class OraDriver}
\description{
   An Oracle driver implementing the R/S-Plus database (DBI) API.
}
\section{Generators}{
   The main generators are \code{\link[DBI]{dbDriver}} and 
   \code{\link{Oracle}}.
}
\section{Extends}{
Class \code{"DBIDriver"}, directly.
Class \code{"OraObject"}, directly.
Class \code{"DBIObject"}, by class "DBIDriver".
Class \code{"dbObjectId"}, by class "OraObject".
}
\section{Methods}{
  \describe{
    \item{coerce}{\code{signature(from = "OraObject", to = "OraDriver")}: ... }
    \item{dbConnect}{\code{signature(drv = "OraDriver")}: ... }
    \item{dbGetInfo}{\code{signature(dbObj = "OraDriver")}: ... }
    \item{dbListConnections}{\code{signature(drv = "OraDriver")}: ... }
    \item{dbUnloadDriver}{\code{signature(drv = "OraDriver")}: ... }
    \item{summary}{\code{signature(object = "OraDriver")}: ... }
  }
}
\references{
  See the Database Interface definition document
  \code{DBI.pdf} in the base directory of this package
  or \url{http://developer.r-project.org/db}.
}

\seealso{
 DBI classes:
 \code{\link{OraObject-class}}
 \code{\link{OraDriver-class}}
 \code{\link{OraConnection-class}}
 \code{\link{OraResult-class}}
}

\examples{\dontrun{
ora <- dbDriver("Oracle")
con <- dbConnect(ora, "user/password@dbname")
}
}
\keyword{database}
\keyword{interface}
\keyword{classes}
% vim: syntax=tex
