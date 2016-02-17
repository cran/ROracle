\name{OraDriver-class}
\docType{class}
\alias{OraDriver-class}
\title{
類別 OraDriver
}
\description{
實行 R 資料庫介面 (DBI) API 的 Oracle 驅動程式類別.
}
\section{Generators}{
   The main generators are \code{\link[DBI]{dbDriver}} and 
   \code{\link{Oracle}}.
}
\section{Extends}{
Class \code{"DBIDriver"}, directly.
Class \code{"DBIObject"}, by class \code{"DBIDriver"}, distance 2.
}
\section{Methods}{
  \describe{
    \item{dbConnect}{\code{signature(drv = "OraDriver")}: ... }
    \item{dbGetInfo}{\code{signature(dbObj = "OraDriver")}: ... }
    \item{dbListConnections}{\code{signature(drv = "OraDriver")}: ... }
    \item{dbUnloadDriver}{\code{signature(drv = "OraDriver")}: ... }
    \item{summary}{\code{signature(object = "OraDriver")}: ... }
    \item{show}{\code{signature(object = "OraDriver")} }
  }
}
\seealso{
 DBI classes:
 \code{\link{OraConnection-class}}
 \code{\link{OraResult-class}}
}
\examples{\dontrun{
# first load the library
library("ROracle")
ora <- dbDriver("Oracle")
con <- dbConnect(ora, "scott", "tiger")
}
}
\keyword{database}
\keyword{interface}
\keyword{classes}
