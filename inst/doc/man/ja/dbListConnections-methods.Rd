\name{dbListConnections-methods}
\docType{methods}
\alias{dbListConnections}
\alias{dbListResults}
\alias{dbListConnections,OraDriver-method}
\alias{dbListConnections,ExtDriver-method}
\alias{dbListResults,OraConnection-method}
\title{
Oracleオブジェクトからのアイテムのリスト
}
\description{
これらのメソッドは対応する汎用関数の直接的な実装です。
}
\usage{
\S4method{dbListConnections}{OraDriver}(drv, ...)
\S4method{dbListConnections}{ExtDriver}(drv, ...)
\S4method{dbListResults}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
\code{OraDriver}または\code{ExtDriver}。
}
  \item{conn}{
\code{OraConnection}。
}
  \item{\dots}{
現在使用されていません。
}
}
\value{
\item{dbListConnections}{
    ドライバに関連付けられているすべての接続のリスト。
  }
  \item{dbListResults}{
    接続に関連付けられているすべての結果セットのリスト。
  }
}
\details{
\\describe{
    \item{dbListConnections}{
      実装によって関連付けられたオブジェクトすべての接続のリストが返されます。
      これは、関連付けられたすべての接続の情報を示します。
    }
    \item{dbListResults}{
      実装によって関連付けられたすべての結果セットのリストが返されます。
      これは、関連付けられたすべての結果セットの情報を示します。
    }
  }
}
\section{References}{
  For the Oracle Database documentaion see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbColumnInfo}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}}
}

\examples{
  \dontrun{
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
