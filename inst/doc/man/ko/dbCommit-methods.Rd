\name{dbCommit-methods}
\docType{methods}
\alias{dbCommit}
\alias{dbRollback}
\alias{dbCommit,OraConnection-method}
\alias{dbRollback,OraConnection-method}
\title{
DBMS 트랜잭션 관리
}
\description{
Oracle 접속에서 현재 트랜잭션을 커밋하거나
  롤백합니다.
}
\usage{
\S4method{dbCommit}{OraConnection}(conn, ...)
\S4method{dbRollback}{OraConnection}(conn, ...)
}
\arguments{
  \item{conn}{
\code{OraConnection} 함수로 생성된 \code{dbConnect} 객체입니다.
}
  \item{\dots}{
현재 사용되지 않습니다.
}
}
\section{Side Effects}{
  \describe{
    \item{dbCommit}{
      saves changes permanently.
    }
    \item{dbRollback}{
      undo all changes done after last save point.
    }
  }
}
\details{
\\describe{
    \item{dbCommit}{
      구현 시 해당 접속에서 수행된 모든 변경사항을 저장합니다. 
      영구적으로 저장된 다음에는 변경사항을 실행 취소할 수 없습니다.
    }
    \item{dbRollback}{
      구현 시 마지막 저장점 이후에 수행된 모든 변경사항을 실행 취소합니다.
    }
  }
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
   \code{\link[DBI]{fetch}},
   \code{\link[DBI]{dbCommit}},
   \code{\link[DBI]{dbGetInfo}},
   \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")
    dbReadTable(con, "EMP")
    rs <- dbSendQuery(con, "delete from emp where deptno = 10")
    dbReadTable(con, "EMP")
    if(dbGetInfo(rs, what = "rowsAffected") > 1)
    {
      warning("dubious deletion -- rolling back transaction")
      dbRollback(con)
    }
    dbReadTable(con, "EMP")
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
