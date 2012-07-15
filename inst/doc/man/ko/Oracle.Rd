\name{Oracle}
\alias{Oracle}
\title{
현재 \R 세션에서 Oracle 클라이언트 인스턴스화
}
\description{
이 함수는 현재 \R 세션에서 Oracle 클라이언트를 생성하고
  초기화합니다. 하나 이상의 Oracle 서버에 접속할 수 있는
  객체를 반환합니다.
}
\usage{
Oracle(interruptible = FALSE)
}
\arguments{
  \item{interruptible}{
사용자가 장기 실행 질의를 중단할 수 있는지 여부를 나타내는 논리입니다.
}
}
\value{
\code{OraDriver}의 확장 클래스를 가진 \code{DBIDriver} 객체입니다.
  이 객체를 사용하여 \code{dbConnect} 함수를 통해 하나 이상의
  Oracle 데이터베이스 엔진에 대한 접속을 생성합니다.
}
\section{Side Effects}{
The \R client part of the database communication is initialized,
but note that connecting to the database engine needs to be done through
calls to \code{\link[DBI]{dbConnect}}.
}


\details{
이 객체는 단일체입니다. 즉, 이후에 호출 시 똑같이 초기화된 객체를
반환합니다. 이 구현을 통해 여러 호스트 서버에 접속하고 각 서버에서
여러 접속을 동시에 실행할 수 있습니다.
interruptible이 TRUE로 설정된 경우 서버에서 장기 실행 중인 질의를
스레드에서 실행하여 중단할 수 있습니다. 주 스레드는 Ctrl-C를 검사하고
OCIBreak/OCIReset을 발행하여 서버의 작업을 취소합니다.
기본적으로 interruptible은 FALSE입니다.
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
