\name{dbListConnections-methods}
\docType{methods}
\alias{dbListConnections}
\alias{dbListResults}
\alias{dbListConnections,OraDriver-method}
\alias{dbListConnections,ExtDriver-method}
\alias{dbListResults,OraConnection-method}
\title{
Oracle 物件的清單項目
}
\description{
這些方法是對應的一般函數的
   直接實行.
}
\usage{
\S4method{dbListConnections}{OraDriver}(drv, ...)
\S4method{dbListConnections}{ExtDriver}(drv, ...)
\S4method{dbListResults}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
一個 \code{OraDriver} 或 \code{ExtDriver}.
}
  \item{conn}{
一個 \code{OraConnection}.
}
  \item{\dots}{
目前未使用.
}
}
\value{
\item{dbListConnections}{
    一個與驅動程式相關聯之所有連線的清單.
  }
  \item{dbListResults}{
    一個與連線相關聯之所有結果集的清單.
  }
}
\details{
\\describe{
    \item{dbListConnections}{
      此實行會傳回一個所有關聯之連線的清單.
      它會顯示所有關聯之連線的相關資訊.
    }
    \item{dbListResults}{
      此實行會傳回一個所有關聯之結果集的清單.
      它會顯示所有關聯之結果集的相關資訊.
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
