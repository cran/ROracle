\name{dbListConnections-methods}
\docType{methods}
\alias{dbListConnections-methods}
\alias{dbListResults-methods}
\alias{dbListConnections,OraDriver-method}
\alias{dbListResults,OraConnection-method}
\title{
Oracleオブジェクトからのアイテムのリスト
}
\description{
これらのメソッドは対応する汎用関数の直接的な実装です。
}
\section{Methods}{\describe{
  \item{drv}{an \code{OraDriver}.}
  \item{conn}{an \code{OraConnection}.}
  \item{\dots}{currently not used.}
}
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbColumnInfo}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}}
}

\examples{\dontrun{
drv <- dbDriver("Oracle")
con1 <- dbConnect(drv, "scott", "tiger")
res1 <- dbSendQuery(con1, "select * from emp where deptno = 10")
res2 <- dbSendQuery(con1, "select * from emp where deptno = 20")
con2 <- dbConnect(drv, "scott", "tiger")
res3 <- dbSendQuery(con2, "select * from dept")

## get all active statements
for(con in dbListConnections(drv))
  for (res in dbListResults(con))
    print(dbGetStatement(res))
}
}
\keyword{methods}
\keyword{interface}
\keyword{database}
