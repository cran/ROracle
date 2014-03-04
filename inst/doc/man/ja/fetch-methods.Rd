\name{fetch-methods}
\docType{methods}
\alias{fetch}
\alias{fetch,OraResult-method}
\title{
以前実行された問合せからのレコードのフェッチ
}
\description{
このメソッドは対応する汎用関数の直接的な実装です。
}
\usage{
\S4method{fetch}{OraResult}(res, n = -1, ...)
}
\arguments{
  \item{res}{
\code{OraResult}オブジェクト。
}
  \item{n}{
フェッチごとに取得される最大レコード数。
    \code{n = -1}を使用して、すべての保留レコードを取得します。
}
  \item{\dots }{
現在使用されていません。
}
}
\value{
データベースからフェッチされるレコード数。
}
\details{
\code{ROracle}の実装は\code{n}レコードのみを取得し、\code{n}が欠落している場合はすべてのレコードを返します。
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
