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
操控 DBMS 表格的便利函數
}
\description{
這些函數會模仿其 R 相對應項, 差別在於這些函數
  會產生在資料庫引擎中遠端執行的程式碼:
  \code{get}、
  \code{assign}、
  \code{exists}、
  \code{remove}、
  \code{objects} 以及
  \code{names}.
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
一個 \code{OraConnection} 資料庫連線物件.
}
  \item{name}{
指定表格名稱的字元字串 (區分大小寫).
}
  \item{schema}{
指定綱要名稱之區分大小寫的字元字串 (或是一個
    \code{dbListTables} 之字元字串的向量).
}
  \item{date}{
指示是要使用日期還是 DateTime 的布林值旗標.
    預設會使用 DateTime, 而不使用時戳.
}

  \item{row.names}{
在 \code{dbReadTable} 的情況下, 此引數可以是一個字串、索引或邏輯向量,
    其指定 DBMS 表格中要作為輸出 data.frame 中之 \code{row.names} 的資料欄
    (\code{NULL} 則指定不使用任何資料欄來作為輸出中的 \code{row.names}).
    預設值為 \code{NULL}.
    如果是 \code{dbWriteTable}, 此引數必須是一個邏輯值,
    指定是否應將 \code{row.names} 輸出至
    輸出 DBMS 表格; 若為 \code{TRUE}, 輸出中將會新增一個名為 
    \code{"row.names"} 的額外資料欄. 預設值為
    \code{FALSE}.
}
  \item{value}{
包含要寫入表格之資料的 \code{data.frame}. (請參閱
    「詳細資訊」區段瞭解支援的資料欄類型.)
}
  \item{overwrite}{
指定是否要覆寫現有表格的邏輯值.
    預設值為 \code{FALSE}.
}
  \item{append}{
指定是否附加至 DBMS 中之現有表格的邏輯值.
    預設值為 \code{FALSE}.
}
  \item{ora.number}{
指定是否要在寫入數值資料時建立一個含有 Oracle
    \code{NUMBER} 或 \code{BINARY_DOUBLE} 資料欄之表格的邏輯值.
    指定 \code{TRUE} 以建立含有 Oracle \code{NUMBER} 
    值的表格, 或指定 \code{FALSE} 以建立含有 Oracle
    \code{BINARY_DOUBLE} 值的表格. 預設值為 \code{TRUE}.
    若一或多個數值資料值為 \code{FALSE},
    請指定 \code{NaN}.
}
  \item{purge}{
指定是否要將 \code{PURGE} 選項新增至 SQL \code{DROP TABLE} 敘述句的
    邏輯值.
}
  \item{all}{
指定是否要查看所有綱要的邏輯值.
}
  \item{full}{
指定是否要產生綱要名稱的邏輯值. 當引數 \code{all} 為 \code{TRUE} 時,
     此輸出會是一個包含綱要名稱後接表格名稱的
    向量. 在輸出上使用 \code{matrix(..., ncol = 2)} 可產生一個矩陣,
    其中每個資料列都對應至一個表格,
    資料欄則分別代表綱要名稱與
    表格名稱.
}
  \item{\dots}{
目前未使用.
}
}




















\details{
表格、綱要以及資料欄名稱都有大小寫之分, 例如表格
  名稱 \code{ABC} 和 \code{abc} 就不相同. 所有的資料庫綱要
  物件名稱都不應包括雙引號, 因為產生相對應的
  SQL 敘述句之後, 這些物件名稱都會外加雙引號.
   下列屬性用於在 \code{dbWriteTable} 中正確對應 BLOB、CLOB、NCLOB、NCHAR、VARCHAR2、
   NVARCHAR2、CHAR、TIMESTAMP WITH TIME ZONE 以及 TIMESTAMP WITH LOCAL TIME ZONE
   資料欄:
   1) 屬性名稱: \code{ora.type}
   此屬性代表現有資料欄的類型, 可以是
   "CLOB"、"BLOB"、"CHAR"、"VARCHAR2" 或 "RAW". 使用者可以指定
   TIMESTAMP、DATE、TIMESTAMP WITH TIME ZONE 或 Oracle 資料庫支援的
   任何其他資料欄類型. ROacle 不會剖析值; 而是由
   資料庫來進行驗證. 使用者可針對 \code{ora.type} 提供下列
   其中一個值: CLOB、BLOB、CHAR、TIMESTAMP WITH TIME
   ZONE、TIMESTAMP WITH LOCAL TIME ZONE 以及 fractional_seconds_precision.
   2) 屬性名稱: \code{ora.encoding}
   若指定 UTF-8, 資料庫會根據 \code{ora.type} 使用 NCLOB、NCHAR 或
   NVARCHAR.
   3) 屬性名稱: \code{ora.maxlength}
   使用者可以指定 CHAR、VARCHAR、NCHAR、NVARCHAR2 或
   RAW 資料欄的最大長度. 對於其他資料類型, \code{ora.maxlength} 不適用,
   會予以忽略. 未指定 \code{ora.maxlength} 時, 某些
   資料類型會使用下列預設值.
   CHAR                                       2000
   NCHAR                                      1000
   VARCHAR2                                   4000
   NVARCHAR2                                  2000
   RAW                                        2000
   4) 屬性名稱: \code{ora.fractional_seconds_precision}
   使用者可以指定 TIMESTAMP、TIMESTAMP WITH TIME ZONE
   以及 TIMESTAMP WITH LOCAL TIME ZONE 資料欄之 SECOND 日期時間欄位的
   小數部分. 它可以 0 到 9 範圍內的數字. 預設值為 6.
  \\pkg{ROracle} 方法 (例如 \code{dbReadTable}、\code{dbGetQuery}、
  \code{fetch} 以及 \code{dbWriteTable}) 在 \R 與 Oracle 資料類型之間
  使用下列對應:
  \itemize{
    \item \code{logical} 和 \code{integer} 對應至 Oracle \code{INTEGER}
    \item 如果引數 \code{numeric} 為 \code{NUMBER}, 則 \code{ora.number} 對應至 \code{TRUE},
    或如果為 \code{BINARY_DOUBLE} 則對應至 Oracle 
    \code{FALSE}
    \item如果屬性 \code{character} 為 \code{CLOB}, 則 \code{ora.type} 對應至 Oracle \code{"CLOB"}, 
    或如果屬性 \code{NCLOB} 為 \code{ora.type} 且 \code{"CLOB"} 為 \code{ora.encoding}, 則對應至  Oracle \code{"UTF-8"}, 
    或如果屬性 \code{CHAR(ora.maxlength)} 為 \code{ora.type}, 則對應至 Oracle \code{"CHAR"}, 
    或如果屬性 \code{NCHAR(ora.maxlength)} 為 \code{ora.type} 且 \code{"CHAR"} 為 \code{ora.encoding}, 則對應至 Oracle \code{"UTF-8"}, 
    或如果屬性 \code{NVARCHAR2(ora.maxlength)} 為 \code{ora.encoding} 或 Oracle \code{"UTF-8"}, 則對應至 Oracle \code{VARCHAR2(ora.maxlength)}
    \item \code{Date} 與 \code{POSIXct} 會對應至 Oracle \code{DATE}
    \\pkg{ROracle} -  ROracle 封裝程式
    \R - R 應用程式
    \item 如果屬性 \code{POSIXct} 為 \code{TIMESTAMP WITH TIME ZONE(ora.fractional_seconds_precision)}  
    則 \code{ora.type} 會對應至 Oracle \code{"TIMESTAMP WITH TIME ZONE"} 
    或如果屬性 \code{TIMESTAMP WITH LOCAL TIME ZONE(ora.fractional_seconds_precision)} 為 \code{ora.type}
    則對應至Oracle \code{"TIMESTAMP WITH LOCAL TIME ZONE"} 
    或如果 \code{TIMESTAMP(ora.fractional_seconds_precision)} 為 \code{Date}
    則對應至 Oracle \code{FALSE} 
    \item \code{difftime} 會對應至 Oracle \code{INTERVAL DAY TO SECOND}
    \item 如果屬性 \code{list} 為 \code{raw} 或 Oracle \code{BLOB}
    則 \code{ora.type} 向量的 \code{"BLOB"} 會對應至 Oracle \code{RAW(ora.maxlength)}
    \item 其他 \R 類型 (例如 \code{factor}) 會轉換成
    \code{character}
  }
   ROracle 會以 R 的 POSIXct 格式, 從下列資料類型的資料庫資料欄傳回值: 日期、
   時戳、含時區的時戳、及含當地時區的時戳資料類型.  POSIXct 是一個以自 1970 年
   開始算起的秒數形式儲存在內部的 UTC  時間. 秒數是從 R 和 ROracle 驅動程式
   以浮點雙精準數格式換算. 在 POSIXct 表示法中, R 會使用 TZ 環境變數, 
   或將作業系統時區環境變數對應至它自己的環境變數, 因此, 日期將會以此時區格式顯示.
   使用者可以使用格式正確的字串或 POSIXct 表示法, 將資料插入上列四種資料類型的資料欄.
   字串資料會被直接傳送給資料庫, 而 ROracle 會倚賴資料庫將其轉換成日期時間表示法.
   ROracle 驅動程式會在用於 DML 作業的資料框架中使用 "\%Y-\%m-\%d \%H:\%M:\%OS6" 格式,
   將 POSIXct 表示法轉換成字串表示法. 此格式的資料會對應至 NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF", 並會轉換成要連結至 Oracle 資料庫的 SQLT_TIMESTAMP_LTZ.
   系統會建立在內部代表 ROracle 驅動程式之字元資料的中繼類別 "datetime".
   ROracle 會使用 SQLT_TIMESTAMP 資料類型來擷取日期和時戳資料類型的資料欄.
   擷取含時區的時戳或含當地時區的時戳資料類型的資料欄時, 則是使用 SQLT_TIMESTAMP_LTZ 資料類型.
   含當地時區的時區資料類型的資料欄會經歷轉換成 R 應用程式執行環境之階段作業時區的過程, 
   因此在 R 中設定時區環境變數 TZ 將會影響此資料欄中的資料值. 當連線至資料庫時,
   ROracle 驅動程式會將 TZ 環境變數對應至階段作業時區, 並發出更改 DDL 以設定階段作業時區.
   若要從含時區的時戳或含當地時區的時戳資料類型的資料欄擷取資料, 從屬端和伺服器必須具有
   相同的時區資料檔, 否則將會回報錯誤.
   從資料庫選取這些資料類型時, 會使用與 R 中的 "Y-\%m-\%d \%H:\%M:\%OS6" 對應
   的 NLS_TIMESTAMP_TZ_FORMAT "YYYY-MM-DD HH24:MI:SSXFF" 將它們轉換成字串表示式. 
   系統會建立中繼類別 "datetime" 以在 ROracle 驅動程式中代表此字元資料. 
   ROracle 驅動程式會接著使用 as.POSIXct() 函數將其轉換成 POSIXct.
   R 應用程式會在資料框架中看見 POSIXct 形式的資料.
   \\preformatted{
R 階段作業時區:
 R 具有 R 引擎運作環境時區的概念. 時區可以設定為 'PST8PDT'、'America/Los_Angeles' 等等之類的字串.
 這些字串皆一目了然並且指定了階段作業運作環境的時區.
 可以使用下列兩種方式之一來設定 R 階段作業時區:
 1. 在 Linux/UNIX 上啟動 R 之前, 於 Linux 或 Unix 命令行中輸入下列程式碼:
    setenv TZ = America/Los_Angeles on Linux/UNIX
    注意: 請勿在 Windows 上使用此選項, 因為它不允許使用者設定
             環境變數 TZ 的 Oracle 相容時區名稱.
 2. 在出現 R 提示時輸入下列程式碼:
    Sys.setenv(TZ = "PST8PDT")
 建議使用選項 2, 因為 R 命令檔在 Linux/Unix 與 Windows 上運作時都一樣沒有移植問題. 
 選項 2 甚至同樣可讓您 在 Windows 上指定 Oracle 相容時區名稱. R 階段作業時區會決定
 所有 POSIXct 未限定時區之日期時間類型的時區. 這也是所有限定之日期時間類型
 被 R 顯示時所轉換成的時區.
 下列範例提供此案例的示範.
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
請注意, 未限定的時戳在被 R 顯示時, 也會被假設為採用 R 的階段作業時區. 
當然, R 也夠聰明, 能夠根據美國日光節約的開始時間判斷該時間是 PST 或 PDT,
然後相應地顯示 PST或 PDT.
下列範例提供更明確的示範.
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
請注意, 所有未限定時區的時戳都會被假設為採用階段作業時區.
不過, 甚至是限定時區的時戳也會被轉換成階段作業時區並顯示. 
請注意, R 會以 R 階段作業的時區來顯示所有值 (時區名稱也會一併
修改成 EST 或 EDT 來表示適用的日光節約時間). 請參考日期時間類別 (網址為:
http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html) 和時區
(網址為:
http://stat.ethz.ch/R-manual/R-devel/library/base/html/timezones.html
以瞭解 R 如何處理日期與時間及時區)
以下是使用較長時區名稱 (通常稱為「Olson 名稱」)
而不使用縮寫的範例.
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
請注意, 在這樣的案例中, R 在顯示值時不會使用長名稱, 
而是仍使用縮寫 "PST" 和 "PDT" 來顯示值. 這相當重要, 
因為 Oracle 不一定喜歡這些縮寫. 例如, Oracle\\n資料庫
無法將 "PDT" 辨識為有效的時區. 請參閱
「R 時區與 Oracle 階段作業時區」以瞭解有關有效時區的詳細資訊.
}
   下列範例顯示變更 R 環境中時區的結果:
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
  此外, 即使是將資料列附加至已經存在的表格,
  \code{dbWriteTable} 也一律會自動確認目前的交易及其插入
  的資料 (亦即會扮演 DDL 敘述句的角色).
}
\value{
在 \code{data.frame} 情況下為 \code{dbReadTable};
  在 \code{vector} 與 \code{dbListTables} 的情況下為
  \code{dbListFields};
  在 \code{logical} 指示表格是否存在的
  情況下為 \code{dbExistsTable};
  否則, 在作業成功或發生異常狀況時
  為 \code{TRUE}.
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
