\name{dbCommit-methods}
\docType{methods}
\alias{dbCommit-methods}
\alias{dbRollback-methods}
\alias{dbCommit,OraConnection-method}
\alias{dbRollback,OraConnection-method}
\title{
DBMS 交易管理
}
\description{
確認或倒回 Oracle 連線中的 
  目前交易
}
\section{Methods}{\describe{
\item{conn}{a \code{OraConnection} object, as produced by the function 
  \code{dbConnect}.}
\item{\dots }{currently unused.}
}
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
\examples{\dontrun{
drv <- dbDriver("Oracle")
con <- dbConnect(drv, "scott", "tiger")
dbReadTable(con, "EMP")
rs <- dbSendQuery(con, "delete from emp where deptno = 10")
dbReadTable(con, "EMP")
if(dbGetInfo(rs, what = "rowsAffected") > 1)
{
  warning("dubious deletion -- rolling back transaction")
  dbRollback(con)
}
dbReadTable(con, "EMP")
}
}
\keyword{methods}
\keyword{interface}
\keyword{database}