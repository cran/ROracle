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
    取得するために配列フェッチが使用されます。
}
  \item{bulk_read}{
一度にフェッチする行数を示す整数値。デフォルト値は
    1000Lです。プリフェッチ・オプションが選択されているとき、メモリーは
    プリフェッチ・バッファに割り当てられ、OCIは一度にそれら多数の行をフェッチします。
    プリフェッチが使用されないとき(デフォルト)、メモリーはRODBI/ROOCIの定義バッファ
    に割り当てられます。これを大きな値に設定すると、選択リストの列数
    や列の型に基づいて割り当てられるメモリーが増加します。
    文字列型の列では、NLS最大幅の倍数である最大幅を使用して
    定義バッファが割り当てられます。アプリケーションは、問合せ結果に基づいて
    この値を調整する必要があります。大きな値は、大量の結果を
    返す問合せにとって有効です。アプリケーションは必要に応じてこの値を
    調整できます。
}
  \item{bulk_write}{
一度に書き込む行数を示す整数値。
    デフォルト値は1000Lです。bulk_write値が引数に指定されている場合、
    メモリーはバッファに割り当てられ、OCIは一度にそれら多数の行を
    書き込みます。bulk_write引数が指定されていない場合、デフォルト値
    1000が使用され、メモリーがバインド・バッファに割り当てられます。
    これを大きな値に設定すると、挿入リストの列数や列の型に基づいて
    割り当てられるメモリーが増加します。
}
  \item{\dots}{
現在使用されていません。
}
}
\value{
\item{dbSendQuery}{
    オブジェクト\code{OraResult}(そのクラスは\code{DBIResult}を拡張します)。この
    オブジェクトは、関数\code{fetch}を使用して、データベースからデータを
    フェッチするために使用されます。
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
      この関数は、問合せ文を実行し、データベースから結果データを
      フェッチします。
    }
    \item{dbSendQuery}{
      この関数は、問合せ文を実行し、結果セットをアプリケーションに返します。
      アプリケーションは結果セットに対して処理を実行できるようになります。
    }
    \item{dbClearResult}{
      この関数は、結果セットが占有していたリソースを解放します。
    }
    \item{dbGetException}{
      この関数は、エラー情報を取得します。
    }
    \item{execute}{
      この関数は、指定の問合せ文を実行します。
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
