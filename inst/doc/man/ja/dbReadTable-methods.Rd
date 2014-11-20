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
DBMS表を操作するための便利な関数
}
\description{
これらの関数はそれぞれのRにおける相対要素の
  \code{get}、
  \code{assign}、
  \code{exists}、
  \code{remove}、
  \code{objects}および
  \code{names}
  を模倣しますが、データベース・エンジンでリモートに実行されるコードは
  生成します。
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
\code{OraConnection}データベース接続オブジェクト。
}
  \item{name}{
表名を指定する、大/小文字が区別された文字列。
}
  \item{schema}{
スキーマ名を指定する、大/小文字が区別された文字列(または
    \code{dbListTables}の文字列のベクター)。
}

  \item{row.names}{
\code{dbReadTable}の場合、この引数は、出力data.frameで\code{row.names}として
    使用されるDBMS表の列を指定する
    文字列、インデックスまたは論理ベクターにすることができます(\code{NULL}は、
    出力の\code{row.names}として列を使用しないことを指定します)。
    デフォルトは\code{NULL}です。
    \code{dbWriteTable}の場合、この引数は、出力DBMS表に\code{row.names}を
    出力するかどうかを指定する論理値
    です。\code{TRUE}の場合、\code{"row.names"}という名前の列が
    出力に追加されます。デフォルト値は
    \code{FALSE}です。
}
  \item{value}{
表に書き込むデータを含む\code{data.frame}。(サポート
    されるデータ型については、詳細の項を参照してください。)
}
  \item{overwrite}{
既存の表を上書きするかどうかを指定する論理値。
    デフォルト値は\code{FALSE}です。
}
  \item{append}{
DBMSの既存の表に付加するかどうかを指定する論理値。
    デフォルト値は\code{FALSE}です。
}
  \item{ora.number}{
数値データを書き込むときに、Oracleの
    \code{NUMBER}または\code{BINARY_DOUBLE}列を含む表を作成するかどうかを指定する論理値。
    Oracle \code{TRUE}の値で表を作成するには\code{NUMBER}を指定し、
    Oracle \code{FALSE}の値で表を作成するには\code{BINARY_DOUBLE}を指定します。
    デフォルト値は\code{TRUE}です。
    1つ以上の量的データ値が\code{FALSE}である場合は、
    \code{NaN}を指定します。
}
  \item{purge}{
\code{PURGE}オプションをSQL \code{DROP TABLE}文に追加するかどうかを
    指定する論理値。
}
  \item{all}{
すべてのスキーマを確認するかどうかを指定する論理値。
}
  \item{full}{
スキーマ名を生成するかどうかを指定する論理値。引数
    \code{all}が\code{TRUE}の場合、出力は、表名が後に続くスキーマ名を含むベクター
    になります。出力に対して\code{matrix(..., ncol = 2)}を使用すると、
    各行が表に対応するマトリックスが生成されます。列は、
    スキーマ名と表名をそれぞれ
    表します。
}
  \item{\dots}{
現在使用されていません。
}
}





   


\details{
表、スキーマおよび列の名前は大/小文字が区別されます。つまり、表名
  \code{ABC}と\code{abc}は同一ではありません。すべてのデータベース・スキーマ・オブジェクト名
  には二重引用符を含めないでください。これらを二重引用符で囲むと、
  対応するSQL文が生成されるためです。
  \\pkg{ROracle}メソッド(\code{dbReadTable}、\code{dbGetQuery}、\code{fetch}、\code{dbWriteTable}など)は、
  \RとOracleデータ型の間で次のマッピング
  を使用します。
  \itemize{
    \item \code{logical}および\code{integer}はOracle \code{INTEGER}にマップ
    \item \code{numeric}はOracle \code{NUMBER}にマップ(引数
    \code{ora.number}が\code{TRUE}の場合)、Oracle \code{BINARY_DOUBLE}にマップ
    (\code{FALSE}の場合)
    \item \code{character}はOracle \code{VARCHAR2(4000)}にマップ
    \item \code{Date}および\code{POSIXct}はOracle \code{DATE}にマップ
    \\pkg{ROracle} - ROracleパッケージ
    \R - Rアプリケーション
    \code{POSIXct} - POSIXctクラス
    \code{TIMESTAMP}
    \code{TIMESTAMP WITH TIME ZONE}
    \code{TIMESTAMP WITH LOCAL TIME ZONE}
    \item \code{difftime}はOracle \code{INTERVAL DAY TO SECOND}にマップ
    \item \code{list}ベクターの\code{raw}はOracle \code{RAW(2000)}にマップ
    \item 他の\R型(\code{factor}など)は
    \code{character}に変換されます。
  }
   ROracleは、データ型が日付、タイム・スタンプ、タイム・ゾーン付きタイム・スタンプ、
   ローカル・タイム・ゾーン付きタイム・スタンプのデータベース列の値を
   RのPOSIXct形式で返します。POSIXctは、1970年(UTC)以降の
   秒数として内部的に格納されている時刻を参照します。
   秒数は、倍精度浮動小数点形式で、
   RおよびROracleドライバと交換されます。POSIXctの表現では、RはTZ環境変数
   を使用するか、OSのタイム・ゾーン変数を自らの変数にマップするため、
   日付がこのタイム・ゾーン形式で表示されます。
   前述の4つのデータ型の列にデータを挿入するには、正しい形式すなわち
   POSIXct表現の文字列を使用します。文字列データは、直接
   データベースに渡され、ROracleは日付時刻表現への変換をデータベースに
   依存します。POSIXctデータが、Oracleの内部のDateTime記述子
   に変換される際には、開始値の1970 (UTC)がRから取得された秒数に
   加算されます。挿入文のすべてのPOSIXct変数
   はSQLT_TIMESTAMP_TZとしてバインドされます。
   これらのデータ型がOracleで選択されるときには、POSIXct形式に
   変換される際に、開始値の1970 (UTC)が引かれます。ROracleクライアントと
   データベースのタイム・ゾーン・バージョン・ファイルが異なり、アプリケーションが
   タイム・ゾーン・データ型を使用する場合は、それらを同じにすることをお薦めします。
   リージョンによってゾーンが変更されている可能性があるためです。この状況でROracleはエラーをレポートします。
   このようなデータ型を処理するときに、データの破損や情報の損失が生じる
   可能性があるためです。
   日付やタイム・スタンプ・データ型を含む列は、SQLT_TIMESTAMPを使用して
   ROracleによってフェッチされます。データ型がタイム・ゾーン付きタイム・スタンプや
   ローカル・タイム・ゾーン付きタイム・スタンプの列は、SQLT_TIMESTAMP_TZデータ型
   を使用してフェッチされます。データ型がローカル・タイム・ゾーン付きタイム・スタンプ
   の列は、Rアプリケーションが実行しているセッション・タイム・ゾーンに変換されます。
   したがって、Rでのタイム・ゾーン環境TZの設定が、この列のデータ値に
   影響します。ROracleドライバは、TZ環境変数をセッション・タイム・ゾーンに
   マッピングせず、セッション・タイム・ゾーンを設定するための
   alter DDLを発行しません。タイム・ゾーン付きタイム・スタンプや
   ローカル・タイム・ゾーン付きタイム・スタンプの列からデータをフェッチするには、
   クライアントとサーバーのタイム・ゾーン・データ・ファイルが同一であることが必要です。
   そうでない場合は、エラーが報告されます。
   次の例は、R環境でのタイム・ゾーン変更の影響を示します。
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
  また、\code{dbWriteTable}は、トランザクションおよび挿入するデータを常に
  自動的にコミットします。つまり、既存の表に行を追加する場合でも
  DDL文のように動作します。
}
\value{
\code{data.frame}の場合は\code{dbReadTable}、
  \code{vector}および\code{dbListTables}の場合は
  \code{dbListFields}、
  \code{logical}の場合は表が存在するか
  どうかを示す\code{dbExistsTable}、
  それ以外の場合は操作の成功時は\code{TRUE}で、その他は
  例外です。
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
