\name{dbDriver-methods}
\docType{methods}
\alias{dbDriver-methods}
\alias{dbUnloadDriver-methods}
\alias{dbDriver,character-method}
\alias{dbUnloadDriver,OraDriver-method}
\title{
Oracle에서 DBI(데이터베이스 인터페이스) 클래스 및 드라이버를
  구현한 것입니다.
}
\description{
Oracle 드라이버 초기화 및 마감
}
\section{Methods}{\describe{
\item{drvName}{
  character name of the driver to instantiate.
  }
\item{drv}{
  an object that inherits from \code{OraDriver} as created by
  \code{dbDriver}.
}
\item{...}{
  any other arguments are passed to the driver \code{drvName}.
  }
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
  \code{\link[DBI]{dbListTables}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{\dontrun{
# create an Oracle instance
drv <- dbDriver("Oracle")

con <- dbConnect(drv, "scott", "tiger")
res <- dbSendQuery(con, "select * from emp")
fetch(res, n = 5)
fetch(res)
dbClearResult(res)
}
}
\keyword{methods}
\keyword{interface}
\keyword{database}
