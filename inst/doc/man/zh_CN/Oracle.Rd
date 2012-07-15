\name{Oracle}
\alias{Oracle}
\title{
从当前 \R 会话实例化 Oracle 客户机
}
\description{
此函数从当前 \R 会话创建并初始化
  Oracle 客户机。它返回一个可用于连接到一个或多个
  Oracle 服务器的对象。
}
\usage{
Oracle(interruptible = FALSE)
}
\arguments{
  \item{interruptible}{
一个逻辑值, 该值指示是否允许用户中断长时间运行的查询。
}
}
\value{
一个 \code{OraDriver} 对象, 其类扩展 \code{DBIDriver}。此
  对象用于使用函数 \code{dbConnect} 创建与
  一个或多个 Oracle 数据库引擎的连接。
}
\section{Side Effects}{
The \R client part of the database communication is initialized,
but note that connecting to the database engine needs to be done through
calls to \code{\link[DBI]{dbConnect}}.
}


\details{
此对象是单例, 即在后续调用中
它将返回同一已初始化对象。
此实现允许您同时连接到多个主机服务器
并同时在每个服务器上运行多个连接。
当“可中断”设置为 TRUE 时, 可以通过在一个线程中执行查询
来中断服务器上长时间运行的查询。主线程
检查是否有 Ctrl-C, 并且发出 OCIBreak/OCIReset 来取消
服务器上的操作。默认情况下,“可中断”为 FALSE。
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
