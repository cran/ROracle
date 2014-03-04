\name{dbCommit-methods}
\docType{methods}
\alias{dbCommit}
\alias{dbRollback}
\alias{dbCommit,OraConnection-method}
\alias{dbRollback,OraConnection-method}
\title{
DBMSトランザクション管理
}
\description{
Oracle接続の現在のトランザクションをコミットまたはロールバックします。
}
\usage{
\S4method{dbCommit}{OraConnection}(conn, ...)
\S4method{dbRollback}{OraConnection}(conn, ...)
}
\arguments{
  \item{conn}{
関数\code{OraConnection}によって生成される\code{dbConnect}オブジェクト。
}
  \item{\dots}{
現在使用されていません。
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
      実装によって、その接続で行われたすべての変更が保存されます。
      永続的に保存された後では、変更を元に戻すことはできません。
    }
    \item{dbRollback}{
      実装によって、最終セーブポイント以降に行われたすべての変更が元に戻されます。
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
