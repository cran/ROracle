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
這些方法皆為對應一般函數的
   直接實行, ROracle 特定 DBI 擴充
   \code{execute} 方法除外.
}
\usage{
\S4method{dbSendQuery}{OraConnection,character}(conn, statement, data = NULL, prefetch = FALSE, bulk_read = 1000L, ...)
\S4method{dbGetQuery}{OraConnection,character}(conn, statement, data = NULL, prefetch = FALSE, bulk_read = 1000L, ...)
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
指定連結資料的 data.frame
}
  \item{prefetch}{
一個指示 TRUE 或 FALSE 的邏輯值. 若設為 TRUE, ROracle 將使用
    OCI 預先擷取緩衝區來從伺服器擷取的其他資料, 而透過
    配置單一資料列緩衝區擷取 OCI 中的資料, 可節省 RODBI/ROOCI 中
    所需的記憶體. 使用預先擷取會對每個資料列產生一個擷取呼叫.
    依照預設, 預先擷取為 FALSE, 會使用陣列擷取來從伺服器擷取
    資料.
}
  \item{bulk_read}{
指定一次要擷取之資料列數目的整數值. 預設值
    為 1000L. 如果選取預先擷取選項, 即會配置記憶體給預先擷取緩衝區,
    OCI 將一次擷取這些眾多的資料列. 若未使用預先擷取 (預設值),
    記憶體就會配置在 RODBI/ROOCI 定義緩衝區中. 將這個值
    設成較大的值會讓系統根據選取清單中的資料欄數目與資料欄類型,
    來配置更多的記憶體. 對於字元的資料欄,
    會使用最大寬度乘以 NLS 最大寬度的方式來配置定義緩衝區. 
    應用程式會根據查詢結果調整這個值,
    較大的值將有利查詢傳回更大的結果.
    應用程式可調整此值以符合其需要.
}
  \item{\dots}{
目前未使用.
}
}
\value{
\item{dbSendQuery}{
    其類別擴充 \code{OraResult} 的 \code{DBIResult} 物件. 此 
    物件可使用函數 \code{fetch} 來擷取資料庫中的 
    資料.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      query statement is executed and data has fetched from database.
    }
    \item{dbSendQuery}{
      query statement is executed, but note that data needs to fetch through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{dbClearResult}{
      resources acquired by result set has free.
    }
    \item{dbGetException}{
      error information retrieved and then cleaned from driver.
    }
    \item{execute}{
      query statement is executed.
    }
  }
}
\details{
\\describe{
    \item{dbGetQuery}{
      此實行會執行查詢敘述句, 並 
      從資料庫擷取結果資料. 
    }
    \item{dbSendQuery}{
      此實行會執行查詢敘述句, 並將 
      結果集傳回應用程式. 應用程式此刻即可對結果集 
      執行作業. 
    }
    \item{dbClearResult}{
      此實行會釋出結果集佔用的資源.
    }
    \item{dbGetException}{
      此實行會擷取錯誤資訊.
    }
    \item{execute}{
      此實行會執行查詢敘述句.
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
    res4 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data3 = data.frame(ename = 'SMITH')) 
    data3 <- fetch(res4, n = -1)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
