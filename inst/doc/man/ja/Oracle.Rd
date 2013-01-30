\name{Oracle}
\alias{Oracle}
\title{
現行の\RセッションからのOracleクライアントのインスタンス化
}
\description{
この関数は、現行の\RセッションからOracleクライアントを作成およびインスタンス化します。これによって、1つ以上のOracleサーバーへの接続を可能にするオブジェクトが返されます。
}
\usage{
Oracle(interruptible = FALSE)
}
\arguments{
  \item{interruptible}{
長時間実行の問合せでユーザー割込みを許可するかどうかを示す論理値。
}
}
\value{
オブジェクト\code{OraDriver} (このクラスは\code{DBIDriver}を拡張します)。このオブジェクトは、関数\code{dbConnect}を使用した、1つ以上のOracleデータベース・エンジンに対する接続の作成に使用されます。
}
\section{Side Effects}{
The \R client part of the database communication is initialized,
but note that connecting to the database engine needs to be done through
calls to \code{\link[DBI]{dbConnect}}.
}


\details{
このオブジェクトはシングルトンで、以降の起動では同じ初期化済オブジェクトを返します。
この実装によって、複数のホスト・サーバーに接続し、複数の接続を各サーバーで同時に実行できます。
interruptibleがTRUEに設定されていると、スレッドの問合せを実行することで、サーバー上の長時間実行の問合せへの割込みが可能です。メイン・スレッドは[Ctrl]-[C]をチェックし、OCIBreak/OCIResetを発行してサーバー上の操作を取り消します。デフォルトでinterruptibleはFALSEです。
}
\section{Oracle user authentication}{
In order to establish a connection to an Oracle server users need to provide
a user name, a password, and possibly a connect identifier (for more
informations refer to chapter 8 (Configuring Naming Methods) of Oracle
Database Net Services Administrator's Guide). This is the same as part
of the SQL*Plus connect string that follows the '@' sign.
}

\section{Transactions}{ 
The current implementation directly supports transaction
commits and rollbacks on a connection-wide basis through calls
to \code{\link[DBI]{dbCommit}} and \code{\link[DBI]{dbRollback}}.
Save points are not yet directly implemented, but you may be able
to define them and rollback to them through calls to dynamic SQL
with \code{\link[DBI]{dbGetQuery}}.

Notice that Oracle (and ANSI/ISO compliant DBMS) transactions are 
implicitly started when data definition SQL are executed (create
table, etc.), which helper functions like \code{\link[DBI]{dbWriteTable}}
may execute behind the scenes. You may want or need to commit
or roll back your work before issuing any of these helper functions.
}

\section{References}{
For the Oracle Database documentaion see
\url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
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
\examples{\dontrun{
## create a Oracle instance and create one connection.
ora <- Oracle()         ## or dbDriver("Oracle")
con <- dbConnect(ora, username = "scott", password = "tiger", dbname = "inst1")

## if you are connecting to a local database
con <- dbConnect(ora, username = "scott", password = "tiger")

## execute a statement and fetch its output in chunks of no more
## than 5000 rows at a time
rs <- dbSendQuery(con, "select * from emp where deptno = 10")
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
