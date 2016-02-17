\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
資料庫介面 (DBI) 類別與驅動程式的 Oracle 實行
}
\description{
Oracle 驅動程式初始化與關閉.
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
任何其他要傳送給驅動程式 \code{drvName} 的引數.
}
}
\value{
\item{dbDriver}{
    一個其類別擴充 \code{OraDriver} 的物件 \code{ExtDriver} 或 
    \code{DBIDriver}. 可利用 \code{dbConnect} 函數, 使用此物件來建立
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
      Remove the communication link between the \R client and the database.
    }
  }
}





\details{
\\describe{
    \item{dbDriver}{
       此物件為單一個體, 亦即後續呼叫 \code{dbDriver} 時,
       會傳回相同的已初始化物件.
      此實行可讓您連線至多部主機伺服器,
      並在每部伺服器上同時執行多個連線.
      當 \code{interruptible} 設為 TRUE 時, 可允許藉由執行繫線中
      的查詢來中斷伺服器上長時間執行的查詢. 
      主要繫線會檢查 Ctrl-C 並發出 OCIBreak/OCIReset 來取消
      伺服器上的作業. \code{interruptible} 預設為 FALSE.
      當 \code{unicode_as_utf8} 設為 FALSE 時, 系統會使用 NLS_LANG 設定值
      所指定的字元集來擷取 NCHAR、NVARCHAR 及 NCLOB
      資料. \code{unicode_as_utf8} 預設為 TRUE.
      當 \code{ora.attributes} 設為 TRUE 時, 來自 \code{dbGetQuery} 和 \code{fetch} 
      的結果集會在對應的資料欄中包含 DBMS
      特定的屬性 (例如 \code{ora.encoding}、\code{ora.type} 及
      \code{ora.maxlength}).
    }
    \item{dbUnloadDriver}{
      此實行會移除 \R 從屬端與資料庫之間的
      通訊連結. 它會釋出所有連線及與這些
      連線物件關聯的所有結果集.
    }
  }
}
\section{References}{
  For Oracle Database documentation, see
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
    # first load the library
    library("ROracle")

    # create an Oracle instance
    drv <- dbDriver("Oracle")

    con <- dbConnect(drv, "scott", "tiger")
    dbListTables(con)

    # fetch all results from the emp table
    res <- dbGetQuery(con, "select * from emp")

    # dbSendQuery can be used to fetch data in chunks 
    # as well as all of data at once
    res <- dbSendQuery(con, "select * from emp")

    # fetch all results
    fetch(res)

    # or a chunk at a time
    fetch(res, n = 5)

    # describing the schema for the emp table using dbGetInfo
    dbGetInfo(res, what = 'fields')

    # clear the result
    dbClearResult(res)

    # disconnect from the database
    dbDisconnect(con)

    # free the driver object
    dbUnloadDriver(drv)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
