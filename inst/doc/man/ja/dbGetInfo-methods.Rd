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
データベース・インタフェース・メタデータ
}
\description{
これらのメソッドは対応する汎用関数の直接的な実装です。
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
Rインタフェースの機能をデータベースに実装する
    オブジェクト(ドライバ、接続または結果セット)。
}
  \item{what}{
出力リストの要素を指定する文字列。
}
  \item{res}{
\code{OraResult}。
}
  \item{\dots}{
現在使用されていません。
}
}


































\details{
表、スキーマおよび列の名前は大/小文字が区別されます。たとえば、
  表名\code{ABC}と\code{abc}は同一ではありません。すべてのデータベース・スキーマ・
  オブジェクト名には二重引用符を含めないでください。これらを二重引用符で囲むと、
  対応するSQL文が生成されるためです。
  \\pkg{ROracle}メソッド\code{dbGetInfo}は、ドライバ・オブジェクトに関する
  次の詳細を提供します。
  \itemize{
    \item {\\$driverName} ドライバの名前、"Oracle (OCI)"
    \item {\\$driverVersion} 使用されたROracleドライバのバージョン
    \item {\\$clientVersion} 使用されたOracle Clientライブラリのバージョン
    \item {\\$conTotal} ドライバによってインスタンス化された接続の数
    \item {\\$conOpen} 現在オープンされている接続の数
    \item {\\$interruptible} 長時間実行の問合せへの割込みが可能な場合はTRUE
    \item {\\$unicode_as_utf8} 文字列データをUTF8でエンコードされた形式で
                              フェッチする場合はTRUE
    \item {\\$ora_attributes}  結果セット・データ・フレーム内の各列に対応する
                             Oracle DBMSの属性がある場合はTRUE
    \item {\\$connections} 現在オープンされている各接続に関する情報(詳細は、
                          接続オブジェクトの\code{dbGetInfo}を参照してください)
  }
  \\pkg{ROracle}メソッド\code{dbGetInfo}は、接続オブジェクトに関する
  次の詳細を提供します。
  \itemize{
    \item {\\$username} この接続でのユーザーの名前
    \item {\\$dbname} 使用された接続別名または接続文字列
    \item {\\$serverVersion} Oracle Databaseサーバーのバージョン
    \item {\\$serverType} 値"Oracle RDBMS"
    \item {\\$resTotal} この接続での結果セットの数
    \item {\\$resOpen} この接続でのオープンされている結果セットの数
    \item {\\$prefetch} プリフェッチ方式を使用してデータをフェッチする場合はTRUE
    \item {\\$bulk_read} DBMSから一度にフェッチされる行数
    \item {\\$bulk_write} DBMSに一度に書き込まれる行数
    \item {\\$stmt_cache} 文キャッシュを使用する場合はTRUE
    \item {\\$results} 現在オープンされている各結果セットに関する情報(詳細は、
                      結果セットの\code{dbGetInfo}を参照してください)
  }
  \\pkg{ROracle}メソッド\code{dbGetInfo}は、結果セット・オブジェクトに関する
  次の詳細を提供します。
  \itemize{
    \item {\\$statement} 結果セット・オブジェクトの生成に使用されたSQL文
    \item {\\$isSelect} select文を指定する場合はTRUE
    \item {\\$rowsAffected} DML文の影響を受ける行数
    \item {\\$rowCount} 現在の結果セットの行数
    \item {\\$completed} 結果セットに行がもうない場合はTRUE
    \item {\\$prefetch} プリフェッチ方式を使用してデータをフェッチする場合はTRUE
    \item {\\$bulk_read} DBMSから一度にフェッチされる行数
    \item {\\$bulk_write} DBMSに一度に書き込まれる行数
    \item {\\$fields} 結果セットの各列に関する情報(詳細は、
                      \code{dbColumnInfo}を参照してください)
  }
  \\pkg{ROracle}メソッド\code{dbColumnInfo}は、結果セットの各列に関する
  次の詳細を提供します。
  \itemize{
    \item {\\$name} 列の名前
    \item {\\$Sclass} Oracle RDBMSによって返されたデータを含む
                     R型のオブジェクト
    \item {\\$type} Oracle RDBMSで作成された列の型
    \item {\\$len} Oracle RDBMSでのVARCHAR、CHARおよびRAWの列型の長さ。
                  その他すべての列はNAとなります。
    \item {\\$precision} 数値列の精度
    \item {\\$scale} 数値列のスケール
    \item {\\$nullOK} 列にNULL値を指定できる場合はTRUE
  }
   次の例では、表について含まれているドライバ、接続、結果セットおよび列の
   情報を示します。
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
ドライバ、接続または結果セット・オブジェクトに関する情報。
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
