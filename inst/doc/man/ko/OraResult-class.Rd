\name{OraResult-class}
\docType{class}
\alias{OraResult-class}
\title{
OraResult 클래스
}
\description{
Oracle 질의 결과 클래스입니다. 이 클래스는 SQL 문 결과를
  캡슐화합니다.
}
\section{Generators}{
   The main generator is \code{\link[DBI]{dbSendQuery}}.
}
\section{Extends}{
Class \code{"DBIResult"}, directly.
Class \code{"DBIObject"}, by class \code{"DBIResult"}, distance 2.
}
\section{Methods}{
  \describe{
    \item{dbClearResult}{\code{signature(res = "OraResult")}: ... }
    \item{dbColumnInfo}{\code{signature(res = "OraResult")}: ... }
    \item{dbGetInfo}{\code{signature(dbObj = "OraResult")}: ... }
    \item{dbGetStatement}{\code{signature(res = "OraResult")}: ... }
    \item{dbGetRowCount}{\code{signature(res = "OraResult")}: ... }
    \item{dbGetRowsAffected}{\code{signature(res = "OraResult")}: ... }
    \item{dbHasCompleted}{\code{signature(res = "OraResult")}: ... }
    \item{fetch}{\code{signature(res = "OraResult", n = "numeric")}: ... }
    \item{fetch}{\code{signature(res = "OraResult", n = "missing")}: ... }
    \item{execute}{\code{signature(res = "OraResult")}: ...}
    \item{summary}{\code{signature(object = "OraResult")}: ... }
    \item{show}{\code{signature(object = "OraResult")} }
  }
}
\seealso{
 DBI classes:
 \code{\link{OraDriver-class}}
 \code{\link{OraConnection-class}}
 \code{\link{OraResult-class}}
}
\examples{\dontrun{
ora <- dbDriver("Oracle")
con <- dbConnect(ora, "scott", "tiger")
res <- dbSendQuery(con, "select * from emp")
fetch(res, n = 2)
fetch(res)
dbColumnInfo(res)
dbClearResult(res)
}
}
\keyword{database}
\keyword{interface}
\keyword{classes}
