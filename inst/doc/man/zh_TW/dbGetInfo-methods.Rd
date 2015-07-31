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
資料庫介面描述資料
}
\description{
這些方法是對應的一般函數的
   直接實行.
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
任何在資料庫之 R 介面中實行某項功能
    的物件 (驅動程式、連線或結果集).
}
  \item{what}{
一個指定某個輸出清單元素的字元字串.
}
  \item{res}{
一個 \code{OraResult}.
}
  \item{\dots}{
目前未使用.
}
}


































\details{
表格、綱要及資料欄名稱皆區分大小寫, 例如表格
  名稱 \code{ABC} 與 \code{abc} 並不相同. 所有資料庫綱要
  物件名稱都不應該包含雙引號, 因為產生對應的 SQL
  敘述句時會將這些物件名稱包含在雙引號中.
  \\pkg{ROracle} 方法 \code{dbGetInfo} 提供下列有關驅動程式物件
  的詳細資訊:
  \itemize{
    \item {\\$driverName} 驅動程式的名稱, "Oracle (OCI)" 
    \item {\\$driverVersion} 所使用之 ROracle 驅動程式的版本
    \item {\\$clientVersion} 所使用之「Oracle 從屬端」程式庫的版本
    \item {\\$conTotal} 驅動程式所建立的連線數
    \item {\\$conOpen} 目前已開啟的連線數
    \item {\\$interruptible} 可中斷長時間執行的查詢時, 為 TRUE
    \item {\\$unicode_as_utf8} 要以 UTF8 編碼格式擷取字元資料時,
                              為 TRUE
    \item {\\$ora_attributes} 結果集資料框架中每個資料欄具有
                             對應的 Oracle DBMS 屬性時, 為 TRUE
    \item {\\$connections} 目前已開啟之每個連線的相關資訊, 請參閱
                          連線物件的 \code{dbGetInfo} 以瞭解詳細資訊
  }
  \\pkg{ROracle} 方法 \code{dbGetInfo} 提供下列有關連線物件
  的詳細資訊:
  \itemize{
    \item {\\$username} 此連線上使用者的名稱
    \item {\\$dbname} 所使用的連線別名或連線字串
    \item {\\$serverVersion} Oracle 資料庫伺服器的版本
    \item {\\$serverType} 值 "Oracle RDBMS"
    \item {\\$resTotal} 此連線上的結果集數
    \item {\\$resOpen} 此連線上已開啟的結果集數
    \item {\\$prefetch} 使用預先擷取機制來擷取資料時, 為 TRUE
    \item {\\$bulk_read} 要從 DBMS 一次擷取的資料列數
    \item {\\$bulk_write} 要一次寫入 DBMS 的資料列數
    \item {\\$stmt_cache} 使用敘述句快取時, 為 TRUE
    \item {\\$results} 目前已開啟之每個結果集的相關資訊, 請參閱
                      結果集的 \code{dbGetInfo} 以瞭解詳細資訊
  }
  \\pkg{ROracle} 方法 \code{dbGetInfo} 提供下列有關結果集物件
  的詳細資訊:
  \itemize{
    \item {\\$statement} 用來產生結果集物件的 SQL 敘述句
    \item {\\$isSelect} 已指定 select 敘述句時, 為 TRUE
    \item {\\$rowsAffected} DML 敘述句所影響的資料列數
    \item {\\$rowCount} 結果集中目前的資料列數
    \item {\\$completed} 如果結果集中已沒有其他資料列, 則為 TRUE
    \item {\\$prefetch} 使用預先擷取機制來擷取資料時, 為 TRUE
    \item {\\$bulk_read} 要從 DBMS 一次擷取的資料列數
    \item {\\$bulk_write} 要一次寫入 DBMS 的資料列數
    \item {\\$fields} 結果集中每個資料欄的相關資訊, 請參閱
                     \code{dbColumnInfo} 以瞭解詳細資訊
  }
  \\pkg{ROracle} 方法 \code{dbColumnInfo} 提供下列有關結果集中
  每個資料欄的詳細資訊:
  \itemize{
    \item {\\$name} 資料欄的名稱
    \item {\\$Sclass} 包含 Oracle RDBMS 所傳回資料之
                     物件的 R 類型
    \item {\\$type} Oracle RDBMS 中建立的資料欄類型
    \item {\\$len} Oracle RDBMS 中 VARCHAR、CHAR 及 RAW 資料欄類型的長度.
                  所有其他資料欄的長度皆為 NA.
    \item {\\$precision} 數字資料欄的數字位數
    \item {\\$scale} 數字資料欄的小數位數
    \item {\\$nullOK} 資料欄中可以有 NULL 值時, 為 TRUE
  }
   下列範例顯示包含下列資訊之表格的驅動程式、連線、
   結果集及資料欄資訊:
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
驅動程式、連線或結果集物件的相關資訊.
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
