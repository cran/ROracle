\name{Oracle}
\alias{Oracle}
\alias{Extproc}
\title{
現行の\RセッションからのOracleクライアントのインスタンス化
}
\description{
この関数は、現行の\RセッションからOracleクライアントを作成および
  初期化します。また、1つ以上のOracleサーバーへの接続を可能にする
  オブジェクトを返します。
}
\usage{
  Oracle(interruptible = FALSE, unicode_as_utf8 = TRUE,
         ora.attributes = FALSE)
  Extproc(extproc.ctx = NULL)
}
\arguments{
  \item{interruptible}{
長時間実行の問合せでユーザー割込みを許可するかどうかを示す
    論理値。
}
  \item{extproc.ctx}{
extprocコンテキストをラップする外部ポインタ。
}
  \item{unicode_as_utf8}{
UTF8でエンコードされたNCHAR、NVARCHARおよびNCLOBのデータを
    フェッチするかどうかを示す論理値。
}
  \item{ora.attributes}{
属性\code{ora.encoding}、\code{ora.type}および\code{ora.maxlength}を、\code{dbGetQuery}および\code{fetch}によって
    返されるデータ・フレームに含めるかどうかを示す
    論理値。
}
}
\value{
クラス\code{OraDriver}(\code{Oracle}の場合)または\code{ExtDriver}(\code{Extproc}の場合)の
  オブジェクト(そのクラスは\code{DBIDriver}を拡張します)。
  このオブジェクトは、関数\code{dbConnect}を使用して、1つ以上のOracle
  データベース・エンジンとの接続を確立するために使用されます。
}
\section{Side Effects}{
  The \R client part of the database communication is initialized,
  but note that connecting to the database engine needs to be done through
  calls to \code{\link[DBI]{dbConnect}}.
}




\details{
このオブジェクトはシングルトンです。つまり、以降の起動では
  同じ初期化済オブジェクトを返します。
  この実装によって、複数のホスト・サーバーに接続し、
  複数の接続を各サーバーで同時に実行できます。
  \code{interruptible}がTRUEに設定されていると、スレッドで問合せを実行することで、
  サーバー上の長時間実行の問合せへの割込みが可能になります。
  メイン・スレッドは[Ctrl]-[C]をチェックし、OCIBreak/OCIResetを発行して
  サーバー上の操作を取り消します。デフォルトでは、\code{interruptible}はFALSEです。
  \code{unicode_as_utf8}がFALSEに設定されていると、NCHAR、NVARCHARおよびNCLOBのデータが
  NLS_LANG設定を使用している文字セットを使用してフェッチされます。
  デフォルトでは、\code{unicode_as_utf8}はTRUEに設定されています。
  \code{ora.attributes}がTRUEに設定されていると、属性\code{ora.encoding}、
  \code{ora.type}および\code{ora.maxlength}がdbGetQueryおよびフェッチから
  返される結果データ・フレームに追加されます。ソース表からフェッチされるときに、
  Oracle DBMSと同じデータ型を作成するには、dbWriteTableとともに使用する必要が
  あります。
}
\section{Oracle user authentication}{
  In order to establish a connection to an Oracle server users need to provide
  a user name, a password, and possibly a connect identifier (for more
  information refer to chapter 8 (Configuring Naming Methods) of Oracle
  Database Net Services Administrator's Guide). This is the same as the part
  of the SQL*Plus connect string that follows the '@' sign.

  Connections to an Oracle TimesTen IMDB instance are established using the OCI
  tnsnames or easy connect naming methods. For additional information on 
  TimesTen connections for OCI see chapter 3 
  (TimesTen Support for Oracle Call Interface) of the Oracle TimesTen In-Memory
  C Developer's Guide.
}

\section{Transactions}{ 
  The current implementation directly supports transaction
  commits and rollbacks on a connection-wide basis through calls
  to \code{\link[DBI]{dbCommit}} and \code{\link[DBI]{dbRollback}}.
  Save points are not yet directly implemented, but you may be able
  to define them and rollback to them through calls to dynamic SQL
  with \code{\link[DBI]{dbGetQuery}}.

  Notice that Oracle (and ANSI/ISO compliant DBMS) transactions are 
  implicitly started when data definition SQL statements are executed (create
  table, etc.), which helper functions like \code{\link[DBI]{dbWriteTable}}
  may execute behind the scenes. You may want or need to commit
  or roll back your work before issuing any of these helper functions.
}

\section{References}{
  For Oracle Database documentation, see
  \url{ http://docs.oracle.com/en/database/}.
}
\author{David A. James and Denis Mukhin}
\seealso{
  On database managers:

  \code{\link[DBI]{dbDriver}}
  \code{\link[DBI]{dbUnloadDriver}}
  \code{\link[DBI]{dbListConnections}}

  On connections:

  \code{\link[DBI]{dbConnect}}
  \code{\link[DBI]{dbDisconnect}}
  \code{\link[DBI]{dbSendQuery}}
  \code{\link[DBI]{dbGetQuery}}
  \code{\link[DBI]{dbGetException}}
  \code{\link[DBI]{dbListResults}}

  Convenience methods:
  \code{\link[DBI]{dbListTables}}
  \code{\link[DBI]{dbReadTable}}
  \code{\link[DBI]{dbWriteTable}}
  \code{\link[DBI]{dbExistsTable}}
  \code{\link[DBI]{dbRemoveTable}}
  \code{\link[DBI]{dbListFields}}

  On transaction management:

  \code{\link[DBI]{dbCommit}}
  \code{\link[DBI]{dbRollback}}

  On queries and result objects:

  \code{\link[DBI]{fetch}}
  \code{\link[DBI]{dbClearResult}}
  \code{\link[DBI]{dbColumnInfo}}
  \code{\link[DBI]{dbGetStatement}}
  \code{\link[DBI]{dbHasCompleted}}
  \code{\link[DBI]{dbGetRowsAffected}}
  \code{\link[DBI]{dbGetRowCount}}

  On meta-data:

  \code{\link[methods]{show}}
  \code{\link[base]{summary}}
  \code{\link[DBI]{dbGetInfo}}
}
\examples{
  \dontrun{
    ## create a Oracle instance and create one connection.
    ora <- Oracle()         ## or dbDriver("Oracle")
    con <- dbConnect(ora, username = "scott", password = "tiger", 
                     dbname = "inst1")

    ## if you are connecting to a local database
    con <- dbConnect(ora, username = "scott", password = "tiger")

    ## execute a statement and fetch its output in chunks of no more
    ## than 5000 rows at a time
    rs   <- dbSendQuery(con, "select * from emp where deptno = 10")
    while (!dbHasCompleted(rs)) {
      df <- fetch(rs, n = 5000)
      ## process df
    }
    dbClearResult(rs)       ## done with this query

    ## execute and fetch a statement with bind data
    df <- dbGetQuery(con, "select * from emp where deptno = :1",
                     data = data.frame(depno = 10))

    ## create a copy of emp table
    dbGetQuery(con, "create table foo as select * from emp")

    ## execute and bind an INSERT statement
    my.data = data.frame(empno = c(8001, 8002), ename = c('MUKHIN', 'ABOYOUN'))
    more.data = data.frame(empno = c(8003), ename = c('JAMES'))
    rs <- dbSendQuery(con, "insert into foo (empno, ename) values (:1, :2)",
                      data = my.data)

    ## execute with more data
    execute(rs, data = more.data)
    dbClearResult(rs)       ## done with this query

    ## ok, everything looks fine
    dbCommit(con)           

    ## a concise description of the driver 
    summary(ora)

    ## done with this connection
    dbDisconnect(con)
  }
}
\keyword{interface}
\keyword{database}
