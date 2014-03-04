\name{fetch-methods}
\docType{methods}
\alias{fetch}
\alias{fetch,OraResult-method}
\title{
從先前執行的查詢中擷取記錄
}
\description{
此方法為對應一般函數的
   直接實行.
}
\usage{
\S4method{fetch}{OraResult}(res, n = -1, ...)
}
\arguments{
  \item{res}{
一個 \code{OraResult} 物件.
}
  \item{n}{
每次擷取所要擷取的記錄數目上限.
    使用 \code{n = -1} 可擷取所有擱置中的記錄.
}
  \item{\dots }{
目前未使用.
}
}
\value{
從資料庫擷取的資料列數目.
}
\details{
\code{ROracle} 實行僅擷取 \code{n} 記錄,
  且若遺漏 \code{n} 則傳回所有記錄.
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
