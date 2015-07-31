\name{Oracle}
\alias{Oracle}
\alias{Extproc}
\title{
從目前 \R 階段作業建立 Oracle 從屬端
}
\description{
此函數會從目前的 \R 階段作業建立並初始化
  Oracle 從屬端. 它會傳回一個可讓您連線至一或多部
  Oracle 伺服器的物件.
}
\usage{
  Oracle(interruptible = FALSE, unicode_as_utf8 = TRUE,
         ora.attributes = FALSE)
  Extproc(extproc.ctx = NULL)
}
\arguments{
  \item{interruptible}{
一個指示是否要允許使用者中斷長時間執行之查詢的
    邏輯值.
}
  \item{extproc.ctx}{
包裝 extproc 相關資訊環境的外部指標.
}
  \item{unicode_as_utf8}{
一個指示是否要擷取以 UTF8 編碼之 NCHAR、NVARCHAR 及 NCLOB
    資料的邏輯值.
}
  \item{ora.attributes}{
一個指示是否要在 \code{ora.encoding} 和 \code{ora.type} 所傳回的
    資料框架中包含屬性 \code{ora.maxlength}、\code{dbGetQuery}
    及 \code{fetch} 的邏輯值.
}
}
\value{
一個類別為 \code{OraDriver} 的物件 (如果是 \code{Oracle}), 或是一個
  類別為 \code{ExtDriver} 的物件 (如果是類別擴充 \code{Extproc} 的 \code{DBIDriver}).
  可藉由使用函數 \code{dbConnect}, 使用此物件來建立與一或多個
  Oracle 資料庫引擎的連線.
}
\section{Side Effects}{
  The \R client part of the database communication is initialized,
  but note that connecting to the database engine needs to be done through
  calls to \code{\link[DBI]{dbConnect}}.
}




\details{
此物件為單一個體, 亦即在後續呼叫時,
  它會傳回相同的已初始化物件. 
  此實行可讓您連線至多部主機伺服器,
  並在每部伺服器上同時執行多個連線.
  當 \code{interruptible} 設為 TRUE 時, 可允許藉由執行繫線中
  的查詢來中斷伺服器上長時間執行的查詢. 主要繫線
  會檢查 Ctrl-C 並發出 OCIBreak/OCIReset 來取消伺服器上的
  作業. \code{interruptible} 預設為 FALSE.
  當 \code{unicode_as_utf8} 設為 FALSE 時, 系統會利用使用 NLS_LANG 設定值的
  字元集來擷取 NCHAR、NVARCHAR 及 NCLOB 資料. \code{unicode_as_utf8}
  預設為 TRUE.
  當 \code{ora.attributes} 設為 TRUE 時, 會在從 dbGetQuery
  和 fetch 傳回的結果資料框架中新增屬性
  \code{ora.encoding}、\code{ora.type} 及 \code{ora.maxlength}. 應將它與 dbWriteTable 搭配使用, 以
  建立與 Oracle DBMS 中從來源表格擷取之資料類型相同的
  資料類型.
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
