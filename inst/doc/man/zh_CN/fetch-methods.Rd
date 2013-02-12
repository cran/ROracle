\name{fetch-methods}
\docType{methods}
\alias{fetch-methods}
\alias{fetch,OraResult,numeric-method}
\alias{fetch,OraResult,missing-method}
\title{
从以前执行的查询提取记录
}
\description{
此方法是相应泛型函数的
   简单实现。
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
\code{ROracle} 实现将仅检索 \code{n} 条记录,
  但如果缺少 \code{n}, 则返回所有记录。
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
