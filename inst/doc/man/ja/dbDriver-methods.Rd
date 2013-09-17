\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Database Interface (DBI)のクラスおよびドライバのOracle実装
}
\description{
Oracleドライバの初期化およびクローズ
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
\code{OraDriver}によって作成され、\code{ExtDriver}または\code{dbDriver}
    を継承するオブジェクト。
}
  \item{...}{
その他の引数はドライバ\code{drvName}に渡されます。
}
}
\value{
\item{dbDriver}{
    クラスが\code{OraDriver}を拡張する、オブジェクト\code{ExtDriver}または\code{DBIDriver}。
    このオブジェクトは、関数\code{dbConnect}を使用して、1つまたは複数の
    Oracleデータベース・エンジンとの接続を確立するために使用されます。
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
      Remove communication link between \R client and database.
    }
  }
}


\details{
\\describe{
    \item{dbDriver}{
      オブジェクトはシングルトンで、以降の起動では同じ
      初期化済オブジェクトを返します。
      この実装によって、複数のホスト・サーバーに接続し、複数の
      接続を各サーバーで同時に実行できます。interruptibleが
      TRUEに設定されていると、スレッドの問合せを実行することで、
      サーバー上の長時間実行の問合せへの割込みが可能です。
      メイン・スレッドは[Ctrl]-[C]をチェックし、OCIBreak/OCIResetを発行して
      サーバー上の操作を取り消します。デフォルトでinterruptibleはFALSEです。
    }
    \item{dbUnloadDriver}{
      実装によって、\Rクライアントとデータベースの間の接続リンク
      が削除されます。すべての接続と、それらの接続オブジェクトに関連付けられている
      すべての結果セットが解放されます。
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
