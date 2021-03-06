\name{ExtDriver-class}
\docType{class}
\alias{ExtDriver-class}
\title{
Classe ExtDriver
}
\description{
Classe di driver extproc Oracle che implementa
  l'interfaccia API del database (DBI) R.
}
\section{Generators}{
   The main generators are \code{\link[DBI]{dbDriver}} and 
   \code{\link{Extproc}}.
}
\section{Extends}{
Class \code{"DBIDriver"}, directly.
Class \code{"DBIObject"}, by class \code{"DBIDriver"}, distance 2.
}
\section{Methods}{
  \describe{
    \item{dbConnect}{\code{signature(drv = "ExtDriver")}: ... }
    \item{dbGetInfo}{\code{signature(dbObj = "ExtDriver")}: ... }
    \item{dbListConnections}{\code{signature(drv = "ExtDriver")}: ... }
    \item{dbUnloadDriver}{\code{signature(drv = "ExtDriver")}: ... }
    \item{summary}{\code{signature(object = "ExtDriver")}: ... }
    \item{show}{\code{signature(object = "ExtDriver")} }
  }
}
\seealso{
 DBI classes:
 \code{\link{OraConnection-class}}
 \code{\link{OraResult-class}}
}
\examples{\dontrun{
con <- dbConnect(Extproc())
}
}
\keyword{database}
\keyword{interface}
\keyword{classes}
