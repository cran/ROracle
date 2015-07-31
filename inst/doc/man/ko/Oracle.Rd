\name{Oracle}
\alias{Oracle}
\alias{Extproc}
\title{
현재 \R 세션에서 Oracle 클라이언트 인스턴스화
}
\description{
이 함수는 현재 \R 세션에서 Oracle 클라이언트를 생성하고
  초기화합니다. 하나 이상의 Oracle 서버에 접속할 수 있는
  객체를 반환합니다.
}
\usage{
  Oracle(interruptible = FALSE, unicode_as_utf8 = TRUE,
         ora.attributes = FALSE)
  Extproc(extproc.ctx = NULL)
}
\arguments{
  \item{interruptible}{
사용자가 장기 실행 질의를 중단할 수 있는지 여부를 나타내는
    논리입니다.
}
  \item{extproc.ctx}{
extproc 컨텍스트를 래핑하는 외부 포인터입니다.
}
  \item{unicode_as_utf8}{
UTF8로 인코딩된 NCHAR, NVARCHAR 및 NCLOB 데이터를 인출할지 여부를 나타내는
    논리입니다.
}
  \item{ora.attributes}{
\code{ora.encoding} 및 \code{ora.type}에서 반환된 데이터 프레임에 \code{ora.maxlength},
    \code{dbGetQuery} 및 \code{fetch} 속성을 포함할지 여부를 나타내는
    논리입니다.
}
}
\value{
해당 클래스가 \code{OraDriver}을(를) 확장하는 \code{Oracle}에 대한 \code{ExtDriver}
  클래스 또는 \code{Extproc}에 대한 \code{DBIDriver} 클래스의 객체입니다.
  이 객체는 \code{dbConnect} 함수를 사용하여 하나 이상의 Oracle 데이터베이스 엔진에
  대한 접속을 생성하는 데 사용됩니다.
}
\section{Side Effects}{
  The \R client part of the database communication is initialized,
  but note that connecting to the database engine needs to be done through
  calls to \code{\link[DBI]{dbConnect}}.
}




\details{
이 객체는 단일 객체입니다. 즉 후속 호출 시 동일한
  초기화된 객체가 반환됩니다.
  이 구현에서는 여러 호스트 서버에 접속하고 각 서버에서
  여러 접속을 동시에 실행할 수 있습니다.
  \code{interruptible}이(가) TRUE로 설정된 경우 서버에서 스레드에 질의를
  실행하여 장기 실행 질의를 중단할 수 있습니다. 기본 스레드는
  Ctrl-C를 검사하고 OCIBreak/OCIReset을 실행하여 서버에서 작업을
  취소합니다. 기본적으로 \code{interruptible}은(는) FALSE입니다.
  \code{unicode_as_utf8}이(가) FALSE로 설정된 경우 NLS_LANG 설정에 의해
  문자 집합을 사용하여 NCHAR, NVARCHAR 및 NCLOB
  데이터가 인출됩니다. 기본적으로 \code{unicode_as_utf8}은(는) TRUE로 설정됩니다.
  \code{ora.attributes}이(가) TRUE로 설정된 경우 \code{ora.encoding},
  \code{ora.type} 및 \code{ora.maxlength} 속성이 dbGetQuery 및 인출에서 반환된 결과 데이터 프레임에
  추가됩니다. dbWriteTable과 함께 사용되어 소스 테이블에서
  인출된 대로 Oracle DBMS에서 동일한 데이터 유형을
  생성해야 합니다.
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
