\name{dbSendQuery-methods}
\docType{methods}
\alias{dbSendQuery}
\alias{dbGetQuery}
\alias{oracleProc}
\alias{dbClearResult}
\alias{dbGetException}
\alias{execute}
\alias{dbSendQuery,OraConnection,character-method}
\alias{dbGetQuery,OraConnection,character-method}
\alias{dbClearResult,OraResult-method}
\alias{oracleProc,OraConnection,character-method}
\alias{dbGetException,OraConnection-method}
\alias{execute,OraResult-method}
\title{
在指定的資料庫連線執行敘述句
}
\description{
這些方法是相對應一般函數的直接
   實行, 但 \code{execute} 方法除外, 它是
   ROracle 特定 DBI 擴充.
}
\usage{
\S4method{dbSendQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbGetQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{oracleProc}{OraConnection,character}(conn, statement, data = NULL, 
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
一個指定連結資料的 \code{data.frame}
}
  \item{prefetch}{
一個邏輯值, 用於指定 ROracle 是使用預先擷取緩衝區還是
    陣列擷取, 從伺服器擷取資料. 若為 \code{TRUE}, ROracle 會
    使用 OCI 預先擷取緩衝區從伺服器擷取其他資料, 而透過 
    配置單一資料列緩衝區來擷取 OCI 中的資料, 可節省 RODBI/ROOCI 中 
    所需的記憶體. 若使用預先擷取, 會對每個資料列產生一個擷取
    呼叫. 若為 \code{FALSE} (預設值), ROracle 會使用陣列擷取來 
    擷取資料.
}
  \item{bulk_read}{
一個整數值, 用於指示一次要擷取的資料列數目. 
    預設值為 1000L. 如果選取預先擷取選項, 會配置 
    記憶體給預先擷取緩衝區, OCI 將一次擷取指定數目的 
    資料列. 若未使用預先擷取 (預設值), 會在 RODBI/ROOCI 
    定義緩衝區中配置記憶體. 這個值若設得越大, 
    系統就會根據選取清單中的資料欄數目和資料欄類型, 
    配置更多的記憶體. 若為字元類型的資料欄, 
    會使用最大寬度乘以 NLS 最大寬度, 配置定義 
    緩衝區. 應用程式應該根據查詢結果調整這個值.
    值若比較大, 將有利於傳回大量結果的查詢. 
    應用程式可視需要調校這個值.
}
  \item{bulk_write}{
一個整數值, 用於指示一次要寫入的資料列數目. 
    預設值為 1000L. 如果指定 bulk_write 值, 會配置 
    記憶體給緩衝區, 而 OCI 將一次寫入那麼多的資料列. 
    若未使用 bulk_write 引數, 將會使用預設值來配置 
    記憶體給連結緩衝區. \code{bulk_write} 值若設得越大, 
    系統就會根據插入清單中的資料欄數目和資料欄類型, 
    配置更多的記憶體.
}
  \item{\dots}{
目前未使用.
}
}
\value{
\item{dbSendQuery}{
    一個其類別擴充 \code{OraResult} 的 \code{DBIResult} 物件. 
    可利用 \code{fetch} 函數, 使用此物件來擷取資料庫的 
    資料.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      Query statement is executed and data is fetched from database.
    }
    \item{dbSendQuery}{
      Query statement is executed, but data needs to be fetched through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{oracleProc}{
      PL/SQL stored procedure or function query statement is executed and 
      result is returned.
    }
    \item{dbClearResult}{
      Resources acquired by the result set are freed.
    }
    \item{dbGetException}{
      Error information is retrieved and then cleaned from the driver.
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
      結果資料. 不可使用它呼叫 PL/SQL 查詢.
    }
    \item{dbSendQuery}{
      此函數會執行查詢敘述句並將結果集傳回給 
      應用程式. 應用程式可以接著對結果集執行作業.
      不可使用它呼叫 PL/SQL 查詢.
    }
     \item{oracleProc}{
      此函數會執行 PL/SQL 預存程序或函數查詢
      敘述句並傳回結果.
    }
    \item{dbClearResult}{
      此函數會釋出結果集所使用的資源.
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
  For the Oracle Database documentation see 
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
                        data1 <- data.frame(deptno = 10), prefetch=TRUE,
                        bulk_read=2L)
    data1 <- fetch(res2, n = -1)
    data1

    res3 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data2 <- data.frame(deptno = 10), bulk_read=10L)
    data2 <- fetch(res3, n = -1)
    data2

    res4 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data3 <- data.frame(deptno = 10), bulk_write=10L)
    data3 <- fetch(res4, n = -1)
    data3

    res5 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data4 <- data.frame(ename = 'SMITH')) 
    data4 <- fetch(res5, n = -1)
    data4
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
