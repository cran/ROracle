\name{dbSendQuery-methods}
\docType{methods}
\alias{dbSendQuery}
\alias{dbGetQuery}
\alias{dbClearResult}
\alias{dbGetException}
\alias{execute}
\alias{dbSendQuery,OraConnection,character-method}
\alias{dbGetQuery,OraConnection,character-method}
\alias{dbClearResult,OraResult-method}
\alias{dbGetException,OraConnection-method}
\alias{execute,OraResult-method}
\title{
在指定的資料庫連線上執行敘述句
}
\description{
這些方法是對應的一般函數的
   直接實行, 但 \code{execute} 方法除外, 該方法是
   ROracle 特定的 DBI 擴充.
}
\usage{
\S4method{dbSendQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbGetQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbClearResult}{OraResult}(res, ...)
\S4method{dbGetException}{OraConnection}(conn, ...)

execute(res, ...)
\S4method{execute}{OraResult}(res, data = NULL, ...)
}
\arguments{
  \item{conn}{
一個 \code{OraConnection} 物件.
}
  \item{statement}{
SQL 敘述句之長度為 1 的字元向量.
}
  \item{res}{
一個 \code{OraResult} 物件.
}
  \item{data}{
一個指定連結資料的 data.frame
}
  \item{prefetch}{
一個指示 TRUE 或 FALSE 的邏輯值. 設為 TRUE 時, ROracle 會使用
    OCI 預先擷取緩衝區來從伺服器擷取其他資料, 這樣便可透過
    配置單一資料列緩衝區來從 OCI 擷取資料, 節省 RODBI/ROOCI 中
    所需的記憶體. 使用預先擷取會對每個資料列產生一個擷取呼叫.
    依照預設, 預先擷取為 FALSE, 系統會使用陣列擷取來從伺服器擷取
    資料.
}
  \item{bulk_read}{
一個指定一次要擷取之資料列數的整數值. 預設值
    為 1000L. 如果選取預先擷取選項, 就會為預先擷取緩衝區
    配置記憶體, 而 OCI 將一次擷取數量相當的資料列. 若未使用
    預先擷取 (預設值), 記憶體就會配置在 RODBI/ROOCI
    定義緩衝區中. 將這個值設成較大的值時, 會讓系統根據
    選取清單中的資料欄數與資料欄類型, 配置更多的記憶體. 
    對於字元類型的資料欄, 會使用最大寬度乘以 NLS 最大寬度
    的方式來配置定義緩衝區. 應用程式應根據查詢結果調整
    這個值, 而較大的值將對傳回大型結果的查詢較有利.
    應用程式可根據其需求來調整此值.
}
  \item{bulk_write}{
一個指示一次要寫入之資料列數的整數值.
    預設值為 1000L. 以引數提供 bulk_write 值時,
    系統會為緩衝區配置記憶體, 而 OCI 將會一次寫入
    數量相當的資料列. 未提供 bulk_write 引數時, 會使用
    預設值 1000 來為連結緩衝區配置記憶體. 將這個值設成
    較大的值時, 會讓系統根據插入清單中的資料欄數與
    資料欄類型, 配置更多的記憶體.
}
  \item{\dots}{
目前未使用.
}
}
\value{
\item{dbSendQuery}{
    一個類別擴充 \code{OraResult} 的 \code{DBIResult} 物件. 
    可藉由使用函數 \code{fetch}, 使用此物件來從資料庫擷取 
    資料.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      Query statement is executed and data has fetched from database.
    }
    \item{dbSendQuery}{
      Query statement is executed, but note that data needs to fetch through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{dbClearResult}{
      Resources acquired by result set has free.
    }
    \item{dbGetException}{
      Error information retrieved and then cleaned from driver.
    }
    \item{execute}{
      Query statement is executed.
    }
  }
}
\details{
\\describe{
    \item{dbGetQuery}{
      此函數會執行查詢敘述句並從資料庫擷取
      結果資料.
    }
    \item{dbSendQuery}{
      此函數會執行查詢敘述句並將結果集傳回給 
      應用程式. 這時應用程式便可對該結果集執行作業.
    }
    \item{dbClearResult}{
      此函數會釋出結果集所佔用的資源.
    }
    \item{dbGetException}{
      此函數會擷取錯誤資訊.
    }
    \item{execute}{
      此函數會執行指定的查詢敘述句.
    }
  }
}
\section{References}{
  For the Oracle Database documentaion see 
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp where deptno = :1",
                       data = data.frame(deptno = 10))
    data <- fetch(res, n = -1)
    res2 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data1 = data.frame(deptno = 10), prefetch=TRUE,
                        bulk_read=2L)
    data1 <- fetch(res2, n = -1)
    res3 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data2 = data.frame(deptno = 10), bulk_read=10L)
    data2 <- fetch(res3, n = -1)
    res4 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data3 = data.frame(deptno = 10), bulk_write=10L)
    data3 <- fetch(res4, n = -1)
    res5 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data4 = data.frame(ename = 'SMITH')) 
    data4 <- fetch(res5, n = -1)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
