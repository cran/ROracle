\name{Oracle}
\alias{Oracle}
\title{
從目前 \R 階段作業建立 Oracle 從屬端
}
\description{
此函數從目前 \R 階段作業建立與初始化 Oracle
  從屬端. 它傳回一個物件, 讓您連線
  一或數部 Oracle 伺服器.
}
\usage{
Oracle(interruptible = FALSE)
}
\arguments{
  \item{interruptible}{
邏輯指示是否允許使用者中斷長時間執行的查詢.
}
}
\value{
其類別擴充 \code{OraDriver} 的物件 \code{DBIDriver}. 此物件
  可使用函數 \code{dbConnect}, 建立連線至
  一或多個 Oracle 資料庫引擎.
}
\section{Side Effects}{
The \R client part of the database communication is initialized,
but note that connecting to the database engine needs to be done through
calls to \code{\link[DBI]{dbConnect}}.
}


\details{
此物件為單一個體, 亦即後續呼叫時,
它會傳回相同已初始化的物件. 
此實行可讓您連線多部主機伺服器,
並在每部伺服器上同時執行多個連線.
當可否中斷設為 TRUE 時, 它可以執行繫線中的查詢,
以中斷長時間執行的查詢. 主要繫線
會檢查 Ctrl-C 並發出 OCIBreak/OCIReset 以取消伺服器上的
作業. 根據預設, 可否中斷設為 FALSE.
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
