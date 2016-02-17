\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Database Interface (DBI)のクラスおよびドライバのOracle実装
}
\description{
Oracleドライバの初期化およびクローズ。
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
\code{OraDriver}または\code{ExtDriver}を継承するオブジェクト
    (\code{dbDriver}によって作成)。
}

  \item{...}{
ドライバ\code{drvName}に渡されるその他の引数。
}
}
\value{
\item{dbDriver}{
    オブジェクト\code{OraDriver}または\code{ExtDriver} (そのクラスは\code{DBIDriver}を拡張します)。
    このオブジェクトは、関数\code{dbConnect}を使用して、1つ以上のOracle 
    Databaseエンジンとの接続を確立するために使用されます。
  }
  \item{dbUnloadDriver}{
    ドライバ・オブジェクトによって占有されたすべてのリソースを解放します。
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
       このオブジェクトはシングルトンです。つまり、以降の\code{dbDriver}の起動では
       同じ初期化済オブジェクトを返します。
      この実装によって、複数のホスト・サーバーに接続し、
      複数の接続を各サーバーで同時に実行できます。
      \code{interruptible}がTRUEに設定されていると、スレッドで問合せを実行することで、
      サーバー上の長時間実行の問合せへの割込みが可能になります。
      メイン・スレッドは[Ctrl]-[C]をチェックし、OCIBreak/OCIResetを発行して
      サーバー上の操作を取り消します。デフォルトでは、\code{interruptible}はFALSEです。
      \code{unicode_as_utf8}がFALSEに設定されていると、NCHAR、NVARCHARおよびNCLOBの
      データがNLS_LANG設定によって指定された文字セットを使用して
      フェッチされます。デフォルトでは、\code{unicode_as_utf8}はTRUEに設定されています。
      \code{ora.attributes}がTRUEに設定されていると、
      \code{dbGetQuery}および\code{fetch}からの結果セットには、
      対応する列に対するDBMS固有の属性
      (\code{ora.encoding}、\code{ora.type}、\code{ora.maxlength}など)が含まれます。
    }
    \item{dbUnloadDriver}{
      この実装によって、\Rクライアントとデータベースの間の通信リンクが
      削除されます。また、すべての接続と、それらの接続オブジェクトに関連付けられている
      すべての結果セットが解放されます。
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
