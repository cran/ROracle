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
以下函数模仿其 R 副本, 不同的是, 它们将生成
  在数据库引擎中远程执行的代码。
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} 和
  \code{names}。
}
\usage{
\S4method{dbReadTable}{OraConnection,character}(conn, name, schema = NULL, row.names = NULL, ...)
\S4method{dbWriteTable}{OraConnection,character,data.frame}(conn, name, value, row.names = FALSE, overwrite = FALSE,
             append = FALSE, ora.number = TRUE, schema = NULL, date = FALSE, ...)
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
  \item{date}{
一个用于指示使用日期还是日期时间的布尔标记。
    默认情况下, 将使用日期时间而不是时间戳。
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
表, 方案和列名区分大小写。例如, 表名
  \code{ABC} 和 \code{abc} 不相同。所有数据库方案
  对象名称不应包括双引号, 因为在生成对应
  SQL 语句时会将其括在双引号中。
   以下属性用于在 \code{dbWriteTable} 中正确映射 BLOB, CLOB, NCLOB, NCHAR, VARCHAR2,
   NVARCHAR2, CHAR, TIMESTAMP WITH TIME ZONE 和 TIMESTAMP WITH LOCAL TIME ZONE
   列:
   1) 属性名: \code{ora.type}
   此属性将指示基础列的类型, 可以为
   "CLOB", "BLOB", "CHAR", "VARCHAR2" 或 "RAW"。用户可以指定
   TIMESTAMP, DATE, TIMESTAMP WITH TIME ZONE 或 Oracle 数据库支持的
   任何其他列类型。ROacle 不会对值进行语法分析; 由
   数据库进行验证。用户可以为 \code{ora.type} 提供以下值
   之一: CLOB, BLOB, CHAR, TIMESTAMP WITH TIME
   ZONE, TIMESTAMP WITH LOCAL TIME ZONE 和 fractional_seconds_precision。
   2) 属性名: \code{ora.encoding}
   指定了 UTF-8 时, 数据库根据 \code{ora.type} 使用 NCLOB, NCHAR 或
   NVARCHAR。
   3) 属性名: \code{ora.maxlength}
   用户可以指定 CHAR, VARCHAR, NCHAR, NVARCHAR2 或 
   RAW 列的最大长度。对于其他数据类型, \code{ora.maxlength} 不适用,
   将忽略。未指定 \code{ora.maxlength} 时, 以下默认值用于
   特定数据类型。
   CHAR                                       2000
   NCHAR                                      1000
   VARCHAR2                                   4000
   NVARCHAR2                                  2000
   RAW                                        2000
   4) 属性名: \code{ora.fractional_seconds_precision}
   用户可以指定 TIMESTAMP, TIMESTAMP WITH TIME ZONE
   和 TIMESTAMP WITH LOCAL TIME ZONE 列的 
   SECOND 日期时间字段的小数部分。可以是 0 到 9 的范围内的数字。默认值为 6。
  \\pkg{ROracle} 方法, 例如 \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} 和 \code{dbWriteTable}, 在 \R 和 Oracle 数据类型
  之间使用以下映射:
  \itemize{
    \item \code{logical} 和 \code{integer} 映射到 Oracle \code{INTEGER}
    \item \code{numeric} 映射到 Oracle \code{NUMBER} (如果参数
    \code{ora.number} 为 \code{TRUE}) 或 Oracle \code{BINARY_DOUBLE} (如果为
    \code{FALSE})
    \item \code{character} 映射到 Oracle \code{CLOB} (如果属性
    \code{ora.type} 为 \code{"CLOB"}) 或 Oracle \code{NCLOB} (如果属性
    \code{ora.type} 为 \code{"CLOB"} 并且 \code{ora.encoding} 为 \code{"UTF-8"}),
    Oracle \code{CHAR(ora.maxlength)} (属性 \code{ora.type} 为
    \code{"CHAR"}), Oracle \code{NCHAR(ora.maxlength)} (如果属性 
    \code{ora.type} 为 \code{"CHAR"} 并且 \code{ora.encoding} 为 \code{"UTF-8"}),
    Oracle \code{NVARCHAR2(ora.maxlength)} (如果属性 \code{ora.encoding}
    为 \code{"UTF-8"}) 或者 Oracle \code{VARCHAR2(ora.maxlength)}
    \item \code{Date} 和 \code{POSIXct} 映射到 Oracle \code{DATE}
    \\pkg{ROracle} - ROracle 程序包
    \R - R 应用程序
    \item \code{POSIXct} 映射到 Oracle 
    \code{TIMESTAMP WITH TIME ZONE(ora.fractional_seconds_precision)} (如果 
    属性 \code{ora.type} 为 \code{"TIMESTAMP WITH TIME ZONE"}), Oracle 
    \code{TIMESTAMP WITH LOCAL TIME ZONE(ora.fractional_seconds_precision)} (如果
    属性 \code{ora.type} 为 \code{"TIMESTAMP WITH LOCAL TIME ZONE"}), 或者
    Oracle \code{TIMESTAMP(ora.fractional_seconds_precision)} (如果
    \code{Date} 为 \code{FALSE})
    \item \code{difftime} 映射到 Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} 向量的 \code{raw} 映射到 Oracle \code{BLOB} (如果
    属性 \code{ora.type} 为 \code{"BLOB"}) 或者 Oracle 
    \code{RAW(ora.maxlength)}
    \item 其他 \R 类型, 例如 \code{factor} 转换为
    \code{character}
  }
   ROracle 从以下数据类型的数据库列返回值: 日期,
   时间戳, 带有时区的时间戳以及带有本地时区的时间戳
   数据类型 (采用 R 的 POSIXct 格式)。POSIXct 引用
   的时间采用自 1970 年 (UTC) 以来的秒数的形式
   在内部存储。秒数从 R 和 ROracle 驱动程序以浮点双精度
   格式进行交换。在 POSIXct 表示形式中, R 使用 TZ
   环境变量或者将操作系统时区环境变量映射到
   自身, 这样日期就将以此时区格式显示。
   用户可以使用正确格式的字符串或者 POSIXct 表示形式
   将数据插入到上面列出的四种数据类型的列中。字符串数据
   直接传递到数据库, ROracle 依赖于数据库将其转换为
   日期时间表示形式。ROracle 驱动程序在用于 DML 操作的
   数据框架中使用格式 "\%Y-\%m-\%d \%H:\%M:\%OS6"
   将 POSIXct 表示形式转换为字符串表示形式。
   采用此格式的数据对应于 NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF", 并且转换为要绑定到
   Oracle 数据库的 SQLT_TIMESTAMP_LTZ。将创建中间类 "datetime"
   以表示 ROracle 驱动程序内部的字符数据。
   具有日期和时间戳数据类型的列由 ROracle 使用
   SQLT_TIMESTAMP 数据类型提取。具有带有时区的时间戳或
   带有本地时区的时间戳数据类型的列使用
   SQLT_TIMESTAMP_LTZ 数据类型提取。时区数据类型的列
   在带有本地时区时, 将转换为运行 R 应用程序所用的会话时区,
   因此, R 中时区环境 TZ 的设置将影响此列中的
   数据值。ROracle 驱动程序会将 TZ 环境变量映射到
   会话时区, 并且发布变更 DDL 以在建立数据库连接时
   设置会话时区。
   对于带有时区的时间戳或带有本地时区的时间戳的
   列, 要从列中提取数据, 客户机和服务器必须
   具有相同的时区数据文件, 否则将报告错误。
   从数据库中选择这些数据类型时, 会使用与 R 中的
   "\%Y-\%m-\%d \%H:\%M:\%OS6" 对应的 NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF" 将这些数据类型转换为
   字符串表示形式。将创建中间类 "datetime"
   以在 ROracle 驱动程序中表示此字符数据。ROracle 驱动程序
   然后使用 as.POSIXct() 函数将其转换为 POSIXct。R 应用程序
   在数据框架中会看到 POSIXct 形式的数据。
   \\preformatted{
R 会话时区:
 R  采用运行 R 引擎所用时区的概念。时区
 可以设置为 'PST8PDT', 'America/Los_Angeles' 等字符串。
 这些字符串不解自明, 指定运行会话所用的
 时区。
 可以通过以下两种方式之一设置 R 会话时区:
 1. 先在 Linux 或 Unix 命令行上输入以下内容, 然后再启动
    R:
    setenv TZ = America/Los_Angeles on Linux/UNIX
    注: 请勿在 Windows 上使用此选项, 因为不允许用户
          为环境变量 TZ 设置 Oracle 兼容时区名称。
 2. 在 R 提示符下输入以下内容:
    Sys.setenv(TZ = "PST8PDT")
 建议使用选项 2, 因为 R 脚本工作时, Linux/Unix 以及
 Windows 上不能出现任何移植问题。使用选项 2
 甚至还可以在 Windows 上指定 Oracle 兼容时区名称。
 R 会话时区确定所有 POSIXct 时区非限定
 日期时间类型的时区。如果 R 显示了所有限定日期时间类型,
 它们还都将转换为此时区。
 以下示例演示了这一点。
 Sys.setenv(TZ = "PST8PDT")
 dt <- c(as.POSIXct("2010/3/13", tz = "PST8PDT"),
         as.POSIXct("2010/3/13 3:47:30.123456", tz = "PST8PDT"),
         as.POSIXct("2010/3/22", tz = "PST8PDT"),
         as.POSIXct("2010/3/22 7:02:30", tz = "PST8PDT"),
         as.POSIXct("2010/3/13"),
         as.POSIXct("2010/3/13 3:47:30.123456"),
         as.POSIXct("2010/3/22"),
         as.POSIXct("2010/3/22 7:02:30"))
 dt
 [1] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
 [3] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
 [5] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
 [7] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
请注意, 如果 R 显示了非限定时间戳, 则还假定这些
时间戳位于 R 的会话时区中。当然, R 还足够智能,
可以根据美国夏令时开始的时间确定时间
是采用 PST 还是 PDT, 并相应地显示 PST 或
PDT。
以下示例更明显地证明了这一点。
> Sys.setenv(TZ = "EST5EDT")
> dt <- c(as.POSIXct("2010/3/13", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13 3:47:30.123456", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22 7:02:30", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13"),
+         as.POSIXct("2010/3/13 3:47:30.123456"),
+         as.POSIXct("2010/3/22"),
+         as.POSIXct("2010/3/22 7:02:30"))
> dt
[1] "2010-03-13 03:00:00.000000 EST" "2010-03-13 06:47:30.123456 EST"
[3] "2010-03-22 03:00:00.000000 EDT" "2010-03-22 10:02:30.000000 EDT"
[5] "2010-03-13 00:00:00.000000 EST" "2010-03-13 03:47:30.123456 EST"
[7] "2010-03-22 00:00:00.000000 EDT" "2010-03-22 07:02:30.000000 EDT"
请注意, 假定所有时区非限定时间戳
位于会话时区中。但是, 甚至时区限定
时间戳也将转换为会话时区并以此显示。
请注意, 所有值都由 R 按照 R 会话的时区显示
 (时区名称还将修改为 EST 或 EDT
以说明适用的夏令时)。有关 R 如何处理
日期和时间及时区的详细信息, 请参阅 
http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html
中的日期时间类以及
http://stat.ethz.ch/R-manual/R-devel/library/base/html/timezones.html 中的时区
让我们举例说明使用较长时区名称
(通常称为 'Olson 名称') 和缩写的情况。
> Sys.setenv(TZ = "America/Los_Angeles")
> dt <- c(as.POSIXct("2010/3/13", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13 3:47:30.123456", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22 7:02:30", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13"),
+         as.POSIXct("2010/3/13 3:47:30.123456"),
+         as.POSIXct("2010/3/22"),
+         as.POSIXct("2010/3/22 7:02:30"))
> dt
[1] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
[3] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
[5] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
[7] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
请注意, 在这种情况下, R 在显示值时
不使用长名称, 而仍使用缩写
"PST" 和 "PDT" 显示值。这一点很重要,
因为 Oracle 不一定喜欢这些缩写。例如, Oracle
数据库不会将 "PDT" 识别为有效时区。有关有效时区的
详细信息, 请参阅 "R 时区和 Oracle 会话时区"。
}
   以下示例显示了在 R 环境中更改时区的
   效果:
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
  此外 \code{dbWriteTable} 始终自动提交当前事务处理
  及其插入的数据, 即它用作 DDL 语句, 即使
  会将行附加到已存在的表中也是如此。
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
  \url{http://docs.oracle.com/cd/E11882_01/server.112/e10729/ch4datetime.htm}.
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

    # Example of POSIXct usage.
    # A table is created using:
    createTab <- "create table RORACLE_TEST(row_num number, id1 date,
                 id2 timestamp, id3 timestamp with time zone, 
                 id4 timestamp with local time zone )"

    dbGetQuery(con, createTab)
    # Insert statement.
    insStr <- "insert into RORACLE_TEST values(:1, :2, :3, :4, :5)";

    # Select statement.
    selStr <- "select * from RORACLE_TEST";

    # Insert time stamp without time values in POSIXct form.
    x <- 1; 
    y <- "2012-06-05";
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    # Insert date & times stamp with time values in POSIXct form.
    x <- 2;
    y <- "2012-01-05 07:15:02";
    y <- as.POSIXct(y);
    z <- "2012-01-05 07:15:03.123";
    z <- as.POSIXct(z);
    dbGetQuery(con, insStr, data.frame(x, y, z,  z, z));

    # Insert list of date objects in POSIXct form.
    x <- c(3, 4, 5, 6);
    y <- c('2012-01-05', '2011-01-05', '2013-01-05', '2020-01-05');
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    dbCommit (con)

    # Selecting data and displaying it.
    res <- dbGetQuery(con, selStr)
    res[,1]
    res[,2]
    res[,3]
    res[,4]
    res[,5]

    # insert data in Date format
    a<-as.Date("2014-01-01")
    dbWriteTable(con, 'TEMP', data.frame(a), date = TRUE)

    # using attribute to map NCHAR, CLOB, BLOB, NCLOB columns correctly in 
    # dbWriteTable
    str1 <- paste(letters, collapse="")
    lstr1 <- paste(rep(str1, 200), collapse="")
    raw.lst <- vector("list",1)
    lraw.lst <- vector("list",1)
    raw.lst[[1L]] <- charToRaw(str1)
    lraw.lst[[1L]] <- rep(charToRaw(str1), 200)
    a <- as.POSIXct("2014-01-01 14:12:09.0194733")
    b <- as.POSIXct("2014-01-01 14:12:09.01947")
    test.df <- data.frame(char=str1, nchar=str1, varchar=str1, clob=lstr1,
                      nclob=lstr1, stringsAsFactors=FALSE)
    test.df$raw.typ <- raw.lst
    test.df$blob <- lraw.lst
    test.df$char_max <- str1 
    test.df$raw_max.typ <- raw.lst
    test.df$nvchar <- str1
    test.df$nvchar_max <- str1
    test.df$date_tz <- a
    test.df$date_ltz <- b

    # adding attributes
    attr(test.df$clob, "ora.type") <- "CLOB"
    attr(test.df$blob, "ora.type") <- "BLOB"
    attr(test.df$nclob, "ora.type") <- "CLOB"
    attr(test.df$nclob, "ora.encoding") <- "UTF-8"
    attr(test.df$char_max, "ora.maxlength") <- 3000
    attr(test.df$raw_max.typ, "ora.maxlength") <- 1000
    attr(test.df$nvchar, "ora.encoding") <- "UTF-8"
    attr(test.df$nvchar_max, "ora.encoding") <- "UTF-8"
    attr(test.df$nvchar_max, "ora.maxlength") <- 1500
    attr(test.df$char, "ora.type") <- "CHAR"
    attr(test.df$date_tz, "ora.type") <- "timestamp with time zone"
    attr(test.df$date_ltz, "ora.type") <- "timestamp with local time zone"
    attr(test.df$nchar, "ora.type") <- "CHAR"
    attr(test.df$nchar, "ora.encoding") <- "UTF-8"
    attr(test.df$date_tz, "ora.fractional_seconds_precision") <- 9
R> # displaying the data frame
R> test.df
char                         nchar
1 abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz
varchar
1 abcdefghijklmnopqrstuvwxyz
clob
1 abcdefghijklmnopqrstuvwxyz...
nclob
1 abcdefghijklmnopqrstuvwxyz...
raw.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
blob
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a,...
char_max
1 abcdefghijklmnopqrstuvwxyz
raw_max.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
nvchar                       nvchar_max
1 abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz
date_tz                      date_ltz
1 2014-01-01 14:12:09.019473 2014-01-01 14:12:09.01946

    dbWriteTable(con, name="TEST_TAB", value=test.df)
    res <- dbReadTable(con, name="TEST_TAB")
R> res
char
1 abcdefghijklmnopqrstuvwxyz
nchar
1 abcdefghijklmnopqrstuvwxyz
varchar
1 abcdefghijklmnopqrstuvwxyz
clob
1 abcdefghijklmnopqrstuvwxyz...
nclob
1 abcdefghijklmnopqrstuvwxyz...
raw.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
blob
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a,...
char_max                                                                                           
1 abcdefghijklmnopqrstuvwxyz
raw_max.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
nvchar                       nvchar_max
1 abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz
date_tz                      date_ltz
1 2014-01-01 14:12:09.019473 2014-01-01 14:12:09.01946
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
