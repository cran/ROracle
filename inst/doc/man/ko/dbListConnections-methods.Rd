\name{dbListConnections-methods}
\docType{methods}
\alias{dbListConnections}
\alias{dbListResults}
\alias{dbListConnections,OraDriver-method}
\alias{dbListConnections,ExtDriver-method}
\alias{dbListResults,OraConnection-method}
\title{
Oracle 객체에서 항목 나열
}
\description{
이 메소드는 해당하는 일반 함수를 간단히 구현한
   것입니다.
}
\usage{
\S4method{dbListConnections}{OraDriver}(drv, ...)
\S4method{dbListConnections}{ExtDriver}(drv, ...)
\S4method{dbListResults}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
\code{OraDriver} 또는 \code{ExtDriver}입니다.
}
  \item{conn}{
\code{OraConnection}입니다.
}
  \item{\dots}{
현재 사용되지 않습니다.
}
}
\value{
\item{dbListConnections}{
    드라이버와 연관된 모든 접속의 목록입니다.
  }
  \item{dbListResults}{
    접속과 연관된 모든 결과 집합의 목록입니다.
  }
}
\details{
\\describe{
    \item{dbListConnections}{
      이 구현은 모든 연관된 접속 목록을 반환합니다.
      모든 연관된 접속에 대한 정보가 표시됩니다.
    }
    \item{dbListResults}{
      이 구현은 모든 연관된 결과 집합 목록을 반환합니다.
      모든 연관된 결과 집합에 대한 정보가 표시됩니다.
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
