\name{dbReadTable-methods}
\docType{methods}
\alias{dbReadTable}
\alias{dbWriteTable}
\alias{dbExistsTable}
\alias{dbRemoveTable}
\alias{dbListTables}
\alias{dbListFields}
\alias{dbReadTable,OraConnection,character-method}
\alias{dbWriteTable,OraConnection,character,data.frame-method}
\alias{dbExistsTable,OraConnection,character-method}
\alias{dbRemoveTable,OraConnection,character-method}
\alias{dbListTables,OraConnection-method}
\alias{dbListFields,OraConnection,character-method}
\title{
用于操纵 DBMS 表的便利函数
}
\description{
以下函数模仿其 R 副本 
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} 和
  \code{names}。
  不同的是, 它们将生成在数据库引擎中远程执行的
  代码。
}
\usage{
\S4method{dbReadTable}{OraConnection,character}(conn, name, schema = NULL, row.names = NULL, ...)
\S4method{dbWriteTable}{OraConnection,character,data.frame}(conn, name, value, row.names = FALSE, overwrite = FALSE,
             append = FALSE, ora.number = TRUE, schema = NULL, ...)
\S4method{dbExistsTable}{OraConnection,character}(conn, name, schema = NULL, ...)
\S4method{dbRemoveTable}{OraConnection,character}(conn, name, purge = FALSE, schema = NULL, ...)
\S4method{dbListTables}{OraConnection}(conn, schema = NULL, all = FALSE, full = FALSE, ...)
\S4method{dbListFields}{OraConnection,character}(conn, name, schema = NULL, ...)
}
\arguments{
  \item{conn}{
一个 \code{OraConnection} 数据库连接对象。
}
  \item{name}{
一个用于指定表名的字符串, 区分大小写。
}
  \item{schema}{
一个用于指定方案名称的字符串, 区分大小写 (或
    \code{dbListTables} 的字符串的一个向量)。
}

  \item{row.names}{
在 \code{dbReadTable} 的情况下, 此参数可以为一个字符串,
    索引或逻辑向量, 指定将 DBMS 表中的列
    在输出 data.frame 中用作 \code{row.names} (\code{NULL}
    指定在输出中不将任何列用作 \code{row.names})。
    默认值为 \code{NULL}。
    在 \code{dbWriteTable} 的情况下, 此参数应为指定 \code{row.names}
    是否输出到输出 DBMS 表的值;
    如果为 \code{TRUE}, 则在输出中添加名为
    \code{"row.names"} 的附加列。默认值为
    \code{FALSE}。
}
  \item{value}{
\code{data.frame} 包含要写入表中的数据。(有关
    支持的列类型, 请参阅“详细信息”部分。)
}
  \item{overwrite}{
一个指定是否覆盖现有表的逻辑值。
    默认值为 \code{FALSE}。
}
  \item{append}{
一个指定是否附加到 DBMS 中现有表的逻辑值。
    默认值为 \code{FALSE}。
}
  \item{ora.number}{
一个指定在写入数值数据时使用 Oracle
    \code{NUMBER} 还是 \code{BINARY_DOUBLE} 列创建表的
    逻辑值。指定 \code{TRUE} 以使用 Oracle \code{NUMBER} 
    值创建表, 或者指定 \code{FALSE} 以使用 Oracle
    \code{BINARY_DOUBLE} 值创建表。默认值为 \code{TRUE}。
    如果一个或多个数值数据值为 \code{FALSE}, 则指定
    \code{NaN}。
}
  \item{purge}{
一个指定是否将 \code{PURGE} 选项添加到
    SQL \code{DROP TABLE} 语句的逻辑值。
}
  \item{all}{
指定是否查看所有方案的逻辑值。
}
  \item{full}{
一个指定是否生成方案名称的逻辑值。参数
    \code{all} 为 \code{TRUE} 时, 输出是包含方案名后跟
    表名的向量。在输出上使用 \code{matrix(..., ncol = 2)}
     将生成矩阵, 其中每一行对应一个
    表, 列分别表示方案名称和
    表名。
}
  \item{\dots}{
当前未使用。
}
}





   


\details{
表, 方案和列名区分大小写, 即表名
  \code{ABC} 和 \code{abc} 不同。所有数据库方案
  对象名称不应包括双引号, 因为在生成
  对应 SQL 语句时会将其括在双引号内。
  \\pkg{ROracle} 方法, 例如 \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} 和 \code{dbWriteTable} 在 \R 和 Oracle 数据类型
  之间使用以下映射:
  \itemize{
    \item \code{logical} 和 \code{integer} 映射到 Oracle \code{INTEGER}
    \item \code{numeric} 在参数 \code{NUMBER} 为 \code{ora.number} 时
    映射到 Oracle \code{TRUE}, 如果为 \code{BINARY_DOUBLE} 则映射到
    Oracle \code{FALSE}
    \item \code{character} 映射到 Oracle \code{VARCHAR2(4000)}
    \item \code{Date} 和 \code{POSIXct} 映射到 Oracle \code{DATE}
    \\pkg{ROracle} - ROracle 程序包
    \R - R 应用程序
    \code{POSIXct} - POSIXct 类
    \code{TIMESTAMP}
    \code{TIMESTAMP WITH TIME ZONE}
    \code{TIMESTAMP WITH LOCAL TIME ZONE}
    \item \code{difftime} 映射到 Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} 向量的 \code{raw} 映射到 Oracle \code{RAW(2000)}
    \item 其他 \R 类型 (例如 \code{factor}) 转换为
    \code{character}
  }
   ROracle 从以下数据类型的数据库列返回值: 日期,
   时间戳, 带有时区的时间戳以及带有本地时区的时间戳
   数据类型 (采用 R 的 POSIXct 格式)。POSIXct 引用
   内部存储的时间作为按 1970 年 UTC 开始的
   秒数。秒数从 R 和 ROracle 驱动程序以浮点双精度格式
   进行交换。在 POSIXct 表示形式中, R 使用 TZ
   环境变量或者将操作系统时区环境变量映射到
   自身, 这样日期就将以此时区格式显示。
   用户可以使用正确格式的字符串或者 POSIXct 表示形式
   将数据插入以上列出的 4 中数据类型的列中。字符串数据
   直接传递到数据库, ROracle 依赖于数据库将其转换为
   日期时间表示形式。POSIXct 数据通过将 1970 UTC 的
   开始添加到从 R 获取的秒数, 将其转换为 Oracle 的
   内部日期时间描述符。插入语句中的任何 POSIXct 变量
   将绑定为 SQLT_TIMESTAMP_TZ,
   从 Oracle 中选择这些数据类型时, 它们将通过减去
    1970 UTC 的开始转换为 POSIXct。ROracle
   客户机和数据库具有不同时区版本文件并且
   应用程序使用时区数据时, 建议让它们相同, 因为区域
   可能改变了其时区。ROracle 在这种情况下将报告错误,
   因为这会在操作这些数据类型时导致数据损坏或
   信息丢失。
   具有日期和时间戳数据类型的列由 ROracle 使用
   SQLT_TIMESTAMP 数据类型提取。具有带有时区的时间戳
   和带有本地时区时间戳数据类型由 ROracle 使用 
   SQLT_TIMESTAMP_TZ 数据类型提取。时区数据类型的
   列在带有本地时区时, 将转换为 R 应用程序运行所在的会话时区,
   因此, R 中时区环境 TZ 的设置将影响此列中的
   数据值。ROracle 驱动程序不将 TZ 环境变量
   映射到会话时区, 并且不发布
   变更 alter DDL 以设置会话时区。对于带有时区的时间戳
   和带有本地时区的时间戳的列, 要从列中提取数据,
   客户机和服务器必须具有相同的时区数据文件,
   否则将报告错误。
   以下示例显示了在 R 环境中更改时区的效果:
   \\preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # Selecting data and displaying it
   res <- dbGetQuery(con, selStr)
   R>     res[,1]
   [1] 1 2 3 4 5 6
   R>     res[,2]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:02 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R>     res[,3]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:03 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R>     res[,4]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:03 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R>     res[,5]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:03 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R> Sys.setenv(TZ='EST5EDT')
   R>     res[,1]
   [1] 1 2 3 4 5 6
   R>     res[,2]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:02 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"
   R>     res[,3]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:03 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"
   R>     res[,4]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:03 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"
   R>     res[,5]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:03 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"}
  此外, \code{dbWriteTable} 始终自动提交当前事务处理及其
  插入的数据, 即它用作 DDL 语句, 虽然
  会将行附加到已经存在的表中。
}
\value{
对于 \code{data.frame} 为 \code{dbReadTable} ;
  对于 \code{vector} 和 \code{dbListTables} 为
  \code{dbListFields};
  对于 \code{logical} 为 \code{dbExistsTable}, 指示
  表是否存在;
  若不属于上述任何一种情况, 在操作成功时为
   \code{TRUE}, 否则为异常错误。
}
\section{References}{
  For the Oracle Database documentation see 
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
  For Datetime Data Types and Time Zone Support in Oracle see
  \url{http://docs.oracle.com/cd/E14072_01/server.112/e10729/ch4datetime.htm}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}}.
}
\examples{
  \dontrun{
    con <- dbConnect(Oracle(), "scott", "tiger")
    if (dbExistsTable(con, "FOO", "SCOTT"))
      dbRemoveTable(con, "FOO")

    foo <- dbReadTable(con, "EMP")
    row.names(foo) <- foo$EMPNO
    foo <- foo[,-1]

    dbWriteTable(con, "FOO", foo, row.names = TRUE)
    dbWriteTable(con, "FOO", foo, row.names = TRUE, overwrite = TRUE)
    dbReadTable(con, "FOO", row.names = 1)

    dbGetQuery(con, "delete from foo")
    dbWriteTable(con, "FOO", foo, row.names = TRUE, append = TRUE)
    dbReadTable(con, "FOO", row.names = 1)
    dbRemoveTable(con, "FOO")

    dbListTables(con)
    dbListFields(con, "EMP")

    if (dbExistsTable(con, "RORACLE_TEST", "SCOTT"))
      dbRemoveTable(con, "RORACLE_TEST")

    # example of POSIXct usage
    # A table is created using:
    createTab <- "create table RORACLE_TEST(row_num number, id1 date,
                 id2 timestamp, id3 timestamp with time zone, 
                 id4 timestamp with local time zone )"

    dbGetQuery(con, createTab)
    # Insert statement
    insStr <- "insert into RORACLE_TEST values(:1, :2, :3, :4, :5)";

    # Select statement
    selStr <- "select * from RORACLE_TEST";

    # Insert time stamp without time values in POSIXct form
    x <- 1; 
    y <- "2012-06-05";
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    # Insert date & times stamp with time values in POSIXct form
    x <- 2;
    y <- "2012-01-05 07:15:02";
    y <- as.POSIXct(y);
    z <- "2012-01-05 07:15:03.123";
    z <- as.POSIXct(z);
    dbGetQuery(con, insStr, data.frame(x, y, z,  z, z));

    # Insert list of date objects in POSIXct form
    x <- c(3, 4, 5, 6);
    y <- c('2012-01-05', '2011-01-05', '2013-01-05', '2020-01-05');
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    dbCommit (con)

    # Selecting data and displaying it
    res <- dbGetQuery(con, selStr)
    res[,1]
    res[,2]
    res[,3]
    res[,4]
    res[,5]
  }
  \dontrun{
    df <- data.frame(A=c(0,1,NaN,4), B=c(NA, 2,3,NaN))
    con <- dbConnect(Oracle(), "scott", "tiger")
    dbWriteTable(con,"TEST", df, row.names = FALSE, ora.number=FALSE)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
