\name{fetch-methods}
\docType{methods}
\alias{fetch-methods}
\alias{fetch,OraResult,numeric-method}
\alias{fetch,OraResult,missing-method}
\title{
이전에 실행된 질의에서 레코드 인출
}
\description{
이 메소드는 해당하는 일반 함수를 간단히 구현한
   것입니다.
}
\section{Methods}{\describe{

\item{res}{
  an \code{OraResult} object.
  }
\item{n}{
  maximum number of records to retrieve per fetch.
  Use \code{n = -1} to retrieve all pending records.
  }
\item{\dots }{currently not used.}
}
}
\details{
\code{ROracle} 구현은 \code{n} 레코드만 검색합니다.
  \code{n}이(가) 누락된 경우 모든 레코드를 반환합니다.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{dbClearResult}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{\dontrun{
drv <- dbDriver("Oracle")
con <- dbConnect(drv, "scott", "tiger")
res <- dbSendQuery(con, "select * from emp")

# we now fetch the first 10 records from the resultSet into a data.frame
data1 <- fetch(res, n = 10)   
dim(data1)

dbHasCompleted(res)

# let's get all remaining records
data2 <- fetch(res, n = -1)
}
}
\keyword{methods}
\keyword{interface}
\keyword{database}
