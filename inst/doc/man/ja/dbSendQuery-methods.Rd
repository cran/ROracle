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
指定されたデータベース接続での文の実行
}
\description{
これらのメソッドは対応する汎用関数の直接的な
   実装ですが、ROracle固有のDBI拡張機能の
   \code{execute}メソッドは例外です。
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
\code{OraConnection}オブジェクト。
}
  \item{statement}{
SQL文を含む長さ1の文字ベクター。
}
  \item{res}{
\code{OraResult}オブジェクト。
}
  \item{data}{
バインド・データを指定する\code{data.frame}
}
  \item{prefetch}{
ROracleがプリフェッチ・バッファまたは配列フェッチを使用して、サーバーから
    データを取得するかどうかを指定する論理値。\code{TRUE}の場合、ROracleは、
    OCIプリフェッチ・バッファを使用して、サーバーから追加データを取得するため、
    データをOCIからフェッチするための単一行バッファを割り当てることで、
    RODBI/ROOCIで必要なメモリーが節約されます。プリフェッチを使用すると、
    すべての行でフェッチ・コールが生成されます。\code{FALSE} (デフォルト)の場合、
    ROracleは、配列フェッチを使用してデータを取得します。
}
  \item{bulk_read}{
一度にフェッチする行数を示す整数値。デフォルト値は1000Lです。
    プリフェッチ・オプションが選択されているとき、メモリーは
    プリフェッチ・バッファに割り当てられ、OCIは指定した行数を一度に
    フェッチします。プリフェッチが使用されないとき(デフォルト)、
    メモリーはRODBI/ROOCIの定義バッファに割り当てられます。
    これを大きな値に設定すると、選択リストの列数や列の型に
    基づいて割り当てられるメモリーが増加します。文字列型の列では、
    NLS最大幅の倍数である最大幅を使用して定義バッファが割り当てられます。
    アプリケーションは、問合せ結果に基づいてこの値を調整する必要があります。
    大きな値は、大量の結果を返す問合せにとって有効です。
    アプリケーションは必要に応じてこの値を調整できます。
}
  \item{bulk_write}{
一度に書き込む行数を示す整数値。
    デフォルト値は1000Lです。bulk_write値が指定されている場合、
    メモリーはバッファに割り当てられ、OCIは一度にそれら多数の行を
    書き込みます。bulk_write引数が使用されていない場合、
    デフォルト値が使用され、メモリーがバインド・バッファに
    割り当てられます。\code{bulk_write}を大きな値に設定すると、挿入リストの
    列数や列の型に基づいて割り当てられるメモリーが増加します。
}
  \item{\dots}{
現在使用されていません。
}
}
\value{
\item{dbSendQuery}{
    \code{OraResult}オブジェクト(そのクラスは\code{DBIResult}を拡張します)。この
    オブジェクトは、関数\code{fetch}を使用して、データベースからデータを
    フェッチするために使用されます。
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
      この関数は、問合せ文を実行し、データベースから結果データを
      フェッチします。PL/SQL問合せのコールには使用できません。
    }
    \item{dbSendQuery}{
      この関数は、問合せ文を実行し、結果セットをアプリケーションに返します。
      アプリケーションは結果セットに対して処理を実行できます。
      PL/SQL問合せのコールには使用できません。
    }
     \item{oracleProc}{
      この関数は、PL/SQLストアド・プロシージャまたは関数問合せ文を
      実行し、結果を返します。
    }
    \item{dbClearResult}{
      この関数は、結果セットが使用していたリソースを解放します。
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
