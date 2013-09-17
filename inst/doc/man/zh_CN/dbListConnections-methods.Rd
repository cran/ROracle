\name{dbListConnections-methods}
\docType{methods}
\alias{dbListConnections}
\alias{dbListResults}
\alias{dbListConnections,OraDriver-method}
\alias{dbListConnections,ExtDriver-method}
\alias{dbListResults,OraConnection-method}
\title{
Oracle 对象的列表项
}
\description{
这些方法是相应泛型函数的
   简单实现。
}
\usage{
\S4method{dbListConnections}{OraDriver}(drv, ...)
\S4method{dbListConnections}{ExtDriver}(drv, ...)
\S4method{dbListResults}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
一个 \code{OraDriver} 或 \code{ExtDriver}。
}
  \item{conn}{
一个 \code{OraConnection}。
}
  \item{\dots}{
当前未使用。
}
}
\value{
\item{dbListConnections}{
    与驱动程序关联的所有连接的列表。
  }
  \item{dbListResults}{
    与连接关联的所有结果集的列表。
  }
}
\details{
\\describe{
    \item{dbListConnections}{
      实施返回所有关联连接的列表。
      它显示有关所有关联连接的信息。
    }
    \item{dbListResults}{
      实施返回所有关联结果集的列表。
      它显示有关所有关联结果集的信息。
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
