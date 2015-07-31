\name{dbGetInfo-methods}
\docType{methods}
\alias{dbGetInfo}
\alias{dbGetStatement}
\alias{dbGetRowCount}
\alias{dbGetRowsAffected}
\alias{dbColumnInfo}
\alias{dbHasCompleted}
\alias{dbGetInfo,OraDriver-method}
\alias{dbGetInfo,ExtDriver-method}
\alias{dbGetInfo,OraConnection-method}
\alias{dbGetInfo,OraResult-method}
\alias{dbGetStatement,OraResult-method}
\alias{dbGetRowCount,OraResult-method}
\alias{dbGetRowsAffected,OraResult-method}
\alias{dbColumnInfo,OraResult-method}
\alias{dbHasCompleted,OraResult-method}
\title{
数据库接口元数据
}
\description{
这些方法是相应泛型函数的
   简单实现。
}
\usage{
\S4method{dbGetInfo}{OraDriver}(dbObj, ...)
\S4method{dbGetInfo}{ExtDriver}(dbObj, ...)
\S4method{dbGetInfo}{OraConnection}(dbObj, what, ...)
\S4method{dbGetInfo}{OraResult}(dbObj, what, ...)
\S4method{dbGetStatement}{OraResult}(res, ...)
\S4method{dbGetRowCount}{OraResult}(res, ...)
\S4method{dbGetRowsAffected}{OraResult}(res, ...)
\S4method{dbColumnInfo}{OraResult}(res, ...)
\S4method{dbHasCompleted}{OraResult}(res)
}
\arguments{
  \item{dbObj}{
在与数据库的 R 接口中实施某种功能的
    任意对象 (驱动程序, 连接或结果集)。
}
  \item{what}{
一个用于指定输出列表的元素的字符串。
}
  \item{res}{
一个 \code{OraResult}。
}
  \item{\dots}{
当前未使用。
}
}


































\details{
表, 方案和列名区分大小写, 例如, 表名
  \code{ABC} 和 \code{abc} 不相同。所有数据库方案
  对象名称不应包括双引号, 因为在生成
  对应 SQL 语句时会将其括在双引号内。
  \\pkg{ROracle} 方法 \code{dbGetInfo} 提供有关驱动程序对象的
  以下详细信息:
  \itemize{
    \item {\\$driverName} 驱动程序的名称, "Oracle (OCI)" 
    \item {\\$driverVersion} 所用 ROracle 驱动程序的版本
    \item {\\$clientVersion} 所用 Oracle 客户机库的版本
    \item {\\$conTotal} 驱动程序实例化的连接数
    \item {\\$conOpen} 当前打开的连接数 
    \item {\\$interruptible} 如果可以中断长时间运行的查询, 则为 TRUE
    \item {\\$unicode_as_utf8} 如果要提取的字符数据采用 UTF8 编码格式,
                              则为 TRUE
    \item {\\$ora_attributes} 如果结果集数据框架中的每个列都有对应的 Oracle DBMS 属性,
                             则为 TRUE
    \item {\\$connections} 有关当前打开的每个连接的信息, 请参阅
                          连接对象的 \code{dbGetInfo} 以获取详细信息
  }
  \\pkg{ROracle} 方法 \code{dbGetInfo} 提供有关连接对象的
  以下详细信息:
  \itemize{
    \item {\\$username} 此连接上的用户的名称
    \item {\\$dbname} 所用的连接别名或连接字符串
    \item {\\$serverVersion} Oracle 数据库服务器的版本
    \item {\\$serverType} 值 "Oracle RDBMS"
    \item {\\$resTotal} 此连接上的结果集数
    \item {\\$resOpen} 此连接上打开的结果集数
    \item {\\$prefetch} 如果使用预取机制来提取数据, 则为 TRUE
    \item {\\$bulk_read} 一次从 DBMS 中提取的行数
    \item {\\$bulk_write} 一次写入 DBMS 的行数
    \item {\\$stmt_cache} 如果使用语句高速缓存, 则为 TRUE
    \item {\\$results} 有关当前打开的每个结果集的信息, 请参阅
                      结果集的 \code{dbGetInfo} 以获取详细信息
  }
  \\pkg{ROracle} 方法 \code{dbGetInfo} 提供有关结果集对象的
  以下详细信息:
  \itemize{
    \item {\\$statement} 用于生成结果集对象的 SQL 语句
    \item {\\$isSelect} 如果指定了 select 语句, 则为 TRUE
    \item {\\$rowsAffected} DML 语句影响的行数
    \item {\\$rowCount} 结果集中的当前行数
    \item {\\$completed} 如果结果集中没有更多行, 则为 TRUE
    \item {\\$prefetch} 如果使用预取机制来提取数据, 则为 TRUE
    \item {\\$bulk_read} 一次从 DBMS 中提取的行数
    \item {\\$bulk_write} 一次写入 DBMS 的行数
    \item {\\$fields} 有关结果集中的每个列的信息, 请参阅
                     \code{dbColumnInfo} 以获取详细信息
  }
  \\pkg{ROracle} 方法 \code{dbColumnInfo} 提供有关结果集中的
  每个列的以下详细信息:
  \itemize{
    \item {\\$name} 列的名称
    \item {\\$Sclass} 包含 Oracle RDBMS 所返回数据的对象
                     的 R 类型
    \item {\\$type} 在 Oracle RDBMS 中创建的列的类型
    \item {\\$len} Oracle RDBMS 中的 VARCHAR, CHAR 和 RAW 类型列的长度。
                  所有其他列均为 NA。
    \item {\\$precision} 数字列的精度
    \item {\\$scale} 数字列的小数位数
    \item {\\$nullOK} 如果列中可以存在 NULL 值, 则为 TRUE
  }
   以下示例显示表包含的驱动程序, 连接, 结果集和
   列信息:
 \\preformatted{
   create table foo(
     a number(21),
     b number,
     c char(20),
     d varchar(300),
     e binary_double,
     f binary_float,
     g clob,
     h blob,
     i bfile,
     j date,
     m timestamp,
     n timestamp with time zone,
     o timestamp with local time zone,
     r interval day to second,
     s raw(234)
   );
 }
\\preformatted{   library(ROracle)
Loading required package: DBI
> # instantiate ROracle driver object
> drv <- Oracle()
> con <- dbConnect(drv, "scott", "tiger")
> rs <- dbSendQuery(con, "select * from foo")
> dbGetInfo(drv)
$driverName
[1] "Oracle (OCI)"
$driverVersion
[1] "1.1-12"
$clientVersion
[1] "11.2.0.4.0"
$conTotal
[1] 1
$conOpen
[1] 1
$interruptible
[1] FALSE
$unicode_as_utf8
[1] TRUE
$ora_attributes
[1] TRUE
$connections
$connections[[1]]
User name:             scott 
Connect string:         
Server version:        11.2.0.4.0 
Server type:           Oracle RDBMS 
Results processed:     1 
OCI prefetch:          FALSE 
Bulk read:             1000 
Bulk write:            1000 
Statement cache size:  0 
Open results:          1 
> dbGetInfo(con)
$username
[1] "scott"
$dbname
[1] ""
$serverVersion
[1] "11.2.0.4.0"
$serverType
[1] "Oracle RDBMS"
$resTotal
[1] 1
$resOpen
[1] 1
$prefetch
[1] FALSE
$bulk_read
[1] 1000
$bulk_write
[1] 1000
$stmt_cache
[1] 0
$results
$results[[1]]
Statement:            select * from foo 
Rows affected:        0 
Row count:            0 
Select statement:     TRUE 
Statement completed:  FALSE 
OCI prefetch:         FALSE 
Bulk read:            1000 
Bulk write:           1000 
> dbGetInfo(rs)
$statement
[1] "select * from foo"
$isSelect
[1] TRUE
$rowsAffected
[1] 0
$rowCount
[1] 0
$completed
[1] FALSE
$prefetch
[1] FALSE
$bulk_read
[1] 1000
$bulk_write
[1] 1000
$fields
   name    Sclass                           type len precision scale nullOK
1     A   numeric                         NUMBER  NA        21     0   TRUE
2     B   numeric                         NUMBER  NA         0  -127   TRUE
3     C character                           CHAR  20         0     0   TRUE
4     D character                       VARCHAR2 300         0     0   TRUE
5     E   numeric                  BINARY_DOUBLE  NA         0     0   TRUE
6     F   numeric                   BINARY_FLOAT  NA         0     0   TRUE
7     G character                           CLOB  NA         0     0   TRUE
8     H       raw                           BLOB  NA         0     0   TRUE
9     I       raw                          BFILE  NA         0     0   TRUE
10    J   POSIXct                           DATE  NA         0     0   TRUE
11    M   POSIXct                      TIMESTAMP  NA         0     6   TRUE
12    N   POSIXct       TIMESTAMP WITH TIME ZONE  NA         0     6   TRUE
13    O   POSIXct TIMESTAMP WITH LOCAL TIME ZONE  NA         0     6   TRUE
14    R  difftime         INTERVAL DAY TO SECOND  NA         2     6   TRUE
15    S       raw                            RAW 234         0     0   TRUE
   }
}
\value{
有关驱动程序, 连接或结果集对象的信息。
}
\section{References}{
  For the Oracle Database documentaion see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
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
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")

    rs <- dbSendQuery(con, "select * from emp")

    # Get the SQL statement for the result set object rs
    dbGetStatement(rs)

    # Are there any more rows in result set?
    dbHasCompleted(rs)

    # Information about columns in result set rs object
    dbColumnInfo(rs)

    # DBIDriver info
    names(dbGetInfo(drv))

    # DBIConnection info
    names(dbGetInfo(con))

    # DBIResult info
    names(dbGetInfo(rs)) 
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
