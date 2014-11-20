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
這些函數模仿其 R 中對應的 
  \code{get}、
  \code{assign}、
  \code{exists}、
  \code{remove}、
  \code{objects} 與
  \code{names},
  差別在於這些函數會產生在資料庫引擎中遠端執行的
  程式碼.
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
一個 \code{OraConnection} 資料庫連線物件.
}
  \item{name}{
指定表格名稱的字元字串 (區分大小寫).
}
  \item{schema}{
指定綱要名稱之區分大小寫的字元字串 (或是一個
    \code{dbListTables} 之字元字串的向量).
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
表格、綱要和資料欄名稱均區分大小寫, 例如
  表格名稱 \code{ABC} 與 \code{abc} 會視為不同.
  所有的資料庫綱要物件名稱皆不可包含雙引號,
  因為在產生對應的 SQL 敘述句時, 會將他們以雙引號括住.
  \\pkg{ROracle} 方法, 例如 \code{dbReadTable}、\code{dbGetQuery}、 
  \code{fetch} 以及 \code{dbWriteTable}, 會使用下列
  \R 與 Oracle 資料類型之間的對應:
  \itemize{
    \item \code{logical} 與 \code{integer} 對應至 Oracle \code{INTEGER}
    \item 若引數 \code{numeric} 為 \code{NUMBER} 
    則 \code{ora.number} 對應至 Oracle \code{TRUE} 
    或若 \code{BINARY_DOUBLE} 則對應至 Oracle \code{FALSE}
    \item \code{character} 對應至 Oracle \code{VARCHAR2(4000)}
    \item \code{Date} 與 \code{POSIXct} 對應至 Oracle \code{DATE}
    \\pkg{ROracle} - ROracle 套裝程式
    \R - R 應用程式
    \code{POSIXct} - POSIXct 類別
    \code{TIMESTAMP}
    \code{TIMESTAMP WITH TIME ZONE}
    \code{TIMESTAMP WITH LOCAL TIME ZONE}
    \item \code{difftime} 對應至 Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} 向量的 \code{raw} 對應至 Oracle \code{RAW(2000)}
    \item 其他 \R 類型, 例如 \code{factor}, 則會轉換成
    \code{character}
  }
   ROracle 會從資料庫資料欄傳回這些資料類型的值: 日期、時戳、
   含有時區的時戳, 以及含有使用 R 的 POSIXct 格式之
   本地時區資料類型的時戳.
   POSIXct 參照的時間是從 1970 UTC 開始起以內部方式儲存的秒數.
   秒數是以浮點雙精準數格式從 R 與 ROracle 驅動程式之間交換.
   在 POSIXct 表示法中, R 使用 TZ 環境變數
   或將本身與作業系統時區變數對應,
   因此資料會以這種時區格式顯示.
   使用者可使用正確格式或 POSIXct  表示法的字串, 
   在資料欄中插入上述 4 種資料類型的資料.
   字串資料會直接傳遞給資料庫, 
   而 ROracle 則仰賴資料庫將其轉換成日期時間的表示法.
   POSIXct 資料將會轉換成 Oracle 的內部 DateTime 描述區, 
   其方法是將從 R 取得秒數加上 1970 UTC 的開頭. 在插入敘述句
   中的任何 POSIXct 變數會限制為 SQLT_TIMESTAMP_TZ.
   從 Oracle 選取這些資料類型之後, 系統即會將其減去 1970 UTC 的開頭,
   以轉換成 POSIXct 格式. 如果 ROracle 從屬端與資料庫
   有不同的時區版本檔案, 而有某應用程式使用時區資料類型,
   建議您讓它們使用相同的時區版本檔案,
   因為時區可能會隨地區而改變. 這種情形 ROracl 會報告錯誤,
   因為在運算這些資料類型時, 它可能會導致資料損毀或
   遺失資訊.
   具有日期與時戳資料類型的資料欄, 是由 ROracle 使用
   SQLT_TIMESTAMP 資料類型擷取. 具有包含時區之時戳
   以及包含本地時區資料類型之時戳的資料欄, 是使用
   SQLT_TIMESTAMP_TZ 資料類型擷取. 資料類型時區的資料欄,
   內含會轉換成執行 R 應用程式的階段作業時區的本地時區,
   因此在 R 中設定時區環境 TZ 將會影響此資料欄中的資料值.
   ROracle 驅動程式不會將 TZ 環境變數對應至階段作業時區, 
   並且不會發出更改 DDL
   來設定階段作業時區. 為了從
   具有內含時區之時戳以及內含本地時區之時戳的資料欄擷取資料,
   從屬端與伺服器的時區資料檔案必須相同,
   否則系統將會報告錯誤.
   以下範例顯示變更 R 環境中之時區的影響:
   \\preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # 選取並顯示資料
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
  此外, \code{dbWriteTable} 一律自動確認目前的交易以及它插入的資料,
  例如, 它會作為 DDL 敘述句,
  即使附加資料列至已存在的表格亦然.
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
