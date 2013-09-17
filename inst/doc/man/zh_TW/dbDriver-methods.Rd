\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Database Interface (DBI) 類別與驅動程式的 Oracle
  實行
}
\description{
Oracle 驅動程式初始化與關閉
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
一個由 \code{OraDriver} 建立時從 \code{ExtDriver} 或 \code{dbDriver}
    繼承的物件.
}
  \item{...}{
所有其他引數都會傳遞給驅動程式 \code{drvName}.
}
}
\value{
\item{dbDriver}{
    一個物件 \code{OraDriver} 或 \code{ExtDriver}, 其類別擴充
    \code{DBIDriver}. 透過使用函數 \code{dbConnect}, 可使用此物件來建立
    與一或多個 Oracle 資料庫引擎的連線.
  }
  \item{dbUnloadDriver}{
    釋出驅動程式物件佔用的所有資源.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbDriver}{
      The \R client part of the database communication is initialized,
      but note that connecting to the database engine needs to be done through
      calls to \code{\link[DBI]{dbConnect}}.
    }
    \item{dbUnloadDriver}{
      Remove communication link between \R client and database.
    }
  }
}


\details{
\\describe{
    \item{dbDriver}{
      此物件為單一個體, 亦即後續呼叫時,
      它會傳回相同已初始化的物件. 
      此實行可讓您連線多部主機伺服器,
      並在每部伺服器上同時執行多個連線.
      當可否中斷設為 TRUE 時, 它可以執行繫線中的查詢,
      以中斷長時間執行的查詢. 主要繫線
      會檢查 Ctrl-C 並發出 OCIBreak/OCIReset 以取消伺服器上的
      作業. 根據預設, 可否中斷設為 FALSE.
    }
    \item{dbUnloadDriver}{
      此實行會將 \R 從屬端與資料庫之間的通訊連結移除.
      它會釋出與這些連線物件相關的所有連線與
      所有結果集.
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
  \code{\link[DBI]{dbListTables}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    # create an Oracle instance
    drv <- dbDriver("Oracle")

    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp")
    fetch(res, n = 5)
    fetch(res)
    dbClearResult(res)
    dbUnloadDriver(drv)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
