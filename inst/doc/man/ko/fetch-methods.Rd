\name{fetch-methods}
\docType{methods}
\alias{fetch}
\alias{fetch,OraResult-method}
\title{
이전에 실행된 질의에서 레코드 인출
}
\description{
이 메소드는 해당하는 일반 함수를 간단히 구현한
   것입니다.
}
\usage{
\S4method{fetch}{OraResult}(res, n = -1, ...)
}
\arguments{
  \item{res}{
\code{OraResult} 객체입니다.
}
  \item{n}{
인출 당 검색할 최대 레코드 수입니다.
    \code{n = -1}을(를) 사용하여 모든 보류 중인 레코드를 검색합니다.
}
  \item{\dots }{
현재 사용되지 않습니다.
}
}
\value{
데이터베이스에서 인출된 레코드 수입니다.
}
\details{
\code{ROracle} 구현은 \code{n} 레코드만 검색합니다.
  \code{n}이(가) 누락된 경우 모든 레코드를 반환합니다.
}
\section{References}{
  For the Oracle Database documentaion see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
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
\examples{
  \dontrun{
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
