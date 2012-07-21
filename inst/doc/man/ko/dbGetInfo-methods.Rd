\name{dbGetInfo-methods}
\docType{methods}
\alias{dbGetInfo-methods}
\alias{dbGetStatement-methods}
\alias{dbGetRowCount-methods}
\alias{dbGetRowsAffected-methods}
\alias{dbColumnInfo-methods}
\alias{dbHasCompleted-methods}
\alias{dbGetInfo,OraDriver-method}
\alias{dbGetInfo,OraConnection-method}
\alias{dbGetInfo,OraResult-method}
\alias{dbGetStatement,OraResult-method}
\alias{dbGetRowCount,OraResult-method}
\alias{dbGetRowsAffected,OraResult-method}
\alias{dbColumnInfo,OraResult-method}
\alias{dbHasCompleted,OraResult-method}
\title{
데이터베이스 인터페이스 메타 데이터
}
\description{
이 메소드는 해당하는 일반 함수를 간단히 구현한
   것입니다.
}
\section{Methods}{\describe{
\item{dbObj}{
  any object that implements some functionality in the R
  interface to databases (a driver, a connection or a result set).
}
\item{res}{ an \code{OraResult}.}
\item{what}{ an element of the output list.}
\item{\dots}{currently not being used.}
}
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbListTables}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{\dontrun{
drv <- dbDriver("Oracle")
con <- dbConnect(drv, "scott", "tiger")

rs <- dbSendQuery(con, "select * from emp")
dbGetStatement(rs)
dbHasCompleted(rs)
dbGetInfo(rs)

# DBIDriver info
names(dbGetInfo(drv))

# DBIConnection info
names(dbGetInfo(con))

# DBIResult info
names(dbGetInfo(rs)) 
}
}
\keyword{methods}
\keyword{interface}
\keyword{database}
