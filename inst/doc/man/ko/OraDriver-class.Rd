\name{OraDriver-class}
\docType{class}
\alias{OraDriver-class}
\title{
OraDriver 클래스
}
\description{
R DBI(데이터베이스 인터페이스) API를 구현하는 Oracle 드라이버 클래스입니다.
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
