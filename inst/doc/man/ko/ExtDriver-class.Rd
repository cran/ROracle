\name{ExtDriver-class}
\docType{class}
\alias{ExtDriver-class}
\title{
ExtDriver 클래스
}
\description{
R DBI(데이터베이스 인터페이스) API를 구현하는 Oracle extproc
  드라이버 클래스입니다.
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
