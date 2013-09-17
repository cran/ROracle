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
指定されたデータベース接続での文の実行
}
\description{
これらのメソッドは対応する汎用関数の直接的な実装ですが、ROracle固有のDBI拡張機能の\code{execute}メソッドは例外です。
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
\code{OraConnection}オブジェクト。
}
  \item{statement}{
SQL文を含む長さ1の文字ベクター。
}
  \item{res}{
\code{OraResult}オブジェクト。
}
  \item{data}{
バインド・データを指定するdata.frame
}
  \item{prefetch}{
TRUEまたはFALSEを示す論理値。TRUEに設定すると、ROracleは
    OCIプリフェッチ・バッファを使用して、サーバーから追加データを取得します。このため、
    データをOCIからフェッチするための単一行バッファを割り当てることで、
    RODBI/ROOCIで必要なメモリーが節約されます。プリフェッチを使用するとすべての行で
    フェッチ・コールが生成されます。デフォルトでは、プリフェッチはFALSEで、サーバーからデータを
    取得するための配列フェッチが使用されます。
}
  \item{bulk_read}{
一度にフェッチする行数を示す正数値。デフォルト値は
    1000Lです。プリフェッチ・オプションが選択されているとき、メモリーは
    プリフェッチ・バッファに割り当てられ、OCIは一度にそれら多数の行をフェッチします。
    プリフェッチが使用されないとき(デフォルト)、メモリーはRODBI/ROOCIの定義バッファ
    に割り当てられます。これを大きな値に設定すると、選択リストの列数
    や列の型に基づいて割り当てられるメモリーが増加します。
    文字の列では、NLS最大幅の倍数である最大幅を使用して
    定義バッファが割り当てられます。アプリケーションは、問合せ結果に基づいて
    この値を調整する必要があります。大きな値は、大量の結果
    を返す問合せにとって有効です。アプリケーションは必要に応じてこの値を
    調整できます。
}
  \item{\dots}{
現在使用されていません。
}
}
\value{
\item{dbSendQuery}{
    クラスが\code{OraResult}を拡張するオブジェクト\code{DBIResult}。この
    オブジェクトは、関数\code{fetch}を使用して、データベースからデータをフェッチするために
    使用されます。
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
      実装が、問合せ文を実行し、データベースから結果データを
      フェッチします。
    }
    \item{dbSendQuery}{
      実装が、問合せ文を実行し、結果セットをアプリケーションに
      返します。アプリケーションが、結果セットに対して処理を実行
      できます。
    }
    \item{dbClearResult}{
      実装が、結果セットが占有していたリソースを解放します。
    }
    \item{dbGetException}{
      実装が、エラー情報を取得します。
    }
    \item{execute}{
      実装が、問合せ文を実行します。
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
