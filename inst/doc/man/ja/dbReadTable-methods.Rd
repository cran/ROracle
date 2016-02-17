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
これらの関数はそれぞれのRにおける次の相対要素を模倣しますが、
  データベース・エンジンでリモートに実行されるコードは生成します。
  \code{get}、
  \code{assign}、
  \code{exists}、
  \code{remove}、
  \code{objects}および
  \code{names}
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
\code{OraConnection}データベース接続オブジェクト。
}
  \item{name}{
表名を指定する、大/小文字が区別された文字列。
}
  \item{schema}{
スキーマ名を指定する、大/小文字が区別された文字列(または
    \code{dbListTables}の文字列のベクター)。
}
  \item{date}{
日付とDateTimepのどちらを使用するかを示すブール・フラグ。
    デフォルトでは、タイムスタンプではなく、DateTimeが使用されます。
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
表、スキーマおよび列の名前は大/小文字が区別されます。たとえば、
  表名\code{ABC}と\code{abc}は同一ではありません。すべてのデータベース・スキーマ・
  オブジェクト名には二重引用符を含めないでください。これらを二重引用符で囲むと、
  対応するSQL文が生成されるためです。
   \code{dbWriteTable}でBLOB、CLOB、NCLOB、NCHAR、VARCHAR2、NVARCHAR2、CHAR、
   TIMESTAMP WITH TIME ZONEおよびTIMESTAMP WITH LOCAL TIME ZONEの各列を
   正しくマッピングするために、次の属性を使用します。
   1) 属性名: \code{ora.type}
   この属性は基本の列の型を示し、有効値には"CLOB"、"BLOB"、"CHAR"、
   "VARCHAR2"または"RAW"があります。ユーザーは、タイムスタンプ、
   日付、タイムゾーン付きタイムスタンプの他、Oracle Databaseでサポートされる
   列型を指定できます。データはROracleでは解析されず、
   データベースで検証されます。ユーザーは、次の\code{ora.type}の値の1つを指定できます。
   CLOB、BLOB、CHAR、TIMESTAMP WITH TIME ZONE、
   TIMESTAMP WITH LOCAL TIME ZONEおよびfractional_seconds_precision
   2) 属性名: \code{ora.encoding}
   UTF-8を指定すると、データベースでは、\code{ora.type}に基づいてNCLOB、NCHARまたはNVARCHARが
   使用されます。
   3) 属性名: \code{ora.maxlength}
   CHAR、VARCHAR、NCHAR、NVARCHAR2またはRAWの列の
   最大長を指定できます。他のデータ型については、\code{ora.maxlength}では
   適用されず無視されます。\code{ora.maxlength}が指定されていない場合、
   特定のデータ型には次のデフォルト値が使用されます。
   CHAR                                       2000
   NCHAR                                      1000
   VARCHAR2                                   4000
   NVARCHAR2                                  2000
   RAW                                        2000
   4) 属性名: \code{ora.fractional_seconds_precision}
   TIMESTAMP、TIMESTAMP WITH TIME ZONEおよびTIMESTAMP WITH LOCAL TIME ZONEの
   列のSECOND datetimeフィールドの小数部分を指定できます。
   0から9の範囲の数値を指定できます。デフォルト値は6です。
  pkg{ROracle}メソッド(\code{dbReadTable}、\code{dbGetQuery}、\code{fetch}、\code{dbWriteTable}など)は、
  \RとOracleデータ型の間で次のマッピングを
  使用します。
  \itemize{
    \item \code{logical}および\code{integer}はOracle \code{INTEGER}にマップ
    \item \code{numeric}はOracle \code{NUMBER}にマップ(引数
    \code{ora.number}が\code{TRUE}の場合)、Oracle  \code{BINARY_DOUBLE}にマップ
    (\code{FALSE}の場合)
    \item \code{character}はOracle \code{CLOB}にマップ(属性
    \code{ora.type}が\code{"CLOB"}の場合)、Oracle \code{NCLOB}にマップ(属性
    \code{ora.type}が\code{"CLOB"}かつ\code{ora.encoding}が\code{"UTF-8"}の場合)、
    Oracle \code{CHAR(ora.maxlength)}にマップ(属性\code{ora.type}が
    \code{"CHAR"}の場合)、Oracle \code{NCHAR(ora.maxlength)}にマップ(属性
    \code{ora.type}が\code{"CHAR"}かつ\code{ora.encoding}が\code{"UTF-8"}の場合)、
    Oracle \code{NVARCHAR2(ora.maxlength)}にマップ(属性\code{ora.encoding}が
    \code{"UTF-8"}の場合)またはOracle \code{VARCHAR2(ora.maxlength)}にマップ
    \item \code{Date}および\code{POSIXct}はOracle \code{DATE}にマップ
    \\pkg{ROracle} - ROracleパッケージ
    \R - Rアプリケーション
    \item \code{POSIXct}はOracle 
    \code{TIMESTAMP WITH TIME ZONE(ora.fractional_seconds_precision)}にマップ
    (属性\code{ora.type}が\code{"TIMESTAMP WITH TIME ZONE"}の場合)、Oracle 
    \code{TIMESTAMP WITH LOCAL TIME ZONE(ora.fractional_seconds_precision)}にマップ
    (属性\code{ora.type}が\code{"TIMESTAMP WITH LOCAL TIME ZONE"}の場合)または
    Oracle \code{TIMESTAMP(ora.fractional_seconds_precision)}にマップ
    (\code{Date}が\code{FALSE}の場合)
    \item \code{difftime}はOracle \code{INTERVAL DAY TO SECOND}にマップ
    \item \code{list} (\code{raw}ベクター)はOracle \code{BLOB}にマップ
    (属性\code{ora.type}が\code{"BLOB"}の場合)またはOracle 
    \code{RAW(ora.maxlength)}にマップ
    \item 他の\R型(\code{factor}など)は
    \code{character}に変換されます。
  }
   ROracleは、データ型がdate、time stamp、time stamp with time zoneおよび
   time stamp with local time zoneのデータベース列の値を
   RのPOSIXct形式で返します。POSIXctとは、UTCでの1970年以降の
   秒数として内部的に格納されている時刻のことです。秒数は、
   倍精度浮動小数点形式で、RおよびROracleドライバと交換されます。
   POSIXctの表現では、RはTZ環境変数を使用するか、
   OSのタイム・ゾーン環境変数をR独自の変数にマップするため、
   日付はこのタイム・ゾーン形式で表示されます。
   前述の4つのデータ型の列にデータを挿入するには、正しい形式
   すなわちPOSIXct表現の文字列を使用します。文字列データは
   直接データベースに渡され、ROracleは日付時刻表現への変換を
   データベースに依存します。ROracleドライバは、DML操作に使用される
   データ・フレームで書式"\%Y-\%m-\%d \%H:\%M:\%OS6"を使用して、
   POSIXct表現を文字列表現に変換します。
   この書式のデータはNLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF"に対応し、Oracleデータベースに
   バインドされるSQLT_TIMESTAMP_LTZに変換されます。ROracleドライバへの
   文字データを内部的に表す中間クラス"datetime"が作成されます。
   データ型がdateおよびtime stampの列は、SQLT_TIMESTAMPデータ型を使用して
   ROracleによってフェッチされます。データ型がtime stamp with time zone
   またはtime stamp with local time zoneの列は、SQLT_TIMESTAMP_LTZデータ型を
   使用してフェッチされます。データ型がtime zone with local time zoneの列は、
   Rアプリケーションが実行されているセッション・タイム・ゾーンに変換されます。
   したがって、Rでのタイム・ゾーン環境TZの設定が、この列のデータ値に影響します。
   ROracleドライバは、データベースへの接続が確立されている場合、
   TZ環境変数をセッション・タイム・ゾーンにマッピングし、
   セッション・タイム・ゾーンを設定するためのalter DDLを発行します。
   タイム・ゾーン付きタイムスタンプまたはローカル・タイム・ゾーン付きタイムスタンプを含む
   列からデータをフェッチするには、クライアントとサーバーのタイム・ゾーン・データ・ファイルが
   同一であることが必要です。そうでない場合は、エラーが報告されます。
   これらのデータ型がデータベースから選択されると、Rの
   "\%Y-\%m-\%d \%H:\%M:\%OS6"に対応するNLS_TIMESTAMP_TZ_FORMAT 
   "YYYY-MM-DD HH24:MI:SSXFF"を使用して文字列表現に変換されます。
   この文字データをROracleドライバで表す中間クラス"datetime"が
   作成されます。次に、データはas.POSIXct()関数を使用して
   ROracleドライバによってPOSIXctに変換されます。Rアプリケーションは
   データ・フレームのデータをPOSIXct形式で参照します。
   \\preformatted{
Rセッション・タイム・ゾーン:
 Rには、Rエンジンが動作するタイム・ゾーンの概念があります。
 タイム・ゾーンは、'PST8PDT'、'America/Los_Angeles'などの
 文字列に設定できます。これらの文字列は一目瞭然で、
 セッションが動作するタイム・ゾーンを指定します。
 Rセッション・タイム・ゾーンは次の2つの方法のいずれかで設定できます。
 1. Rの起動前に、LinuxまたはUnixのコマンドラインで次のように入力し
    ます。
    setenv TZ = America/Los_Angeles on Linux/UNIX
    注意: このオプションはWindowsで使用しないでください。環境変数TZに
          Oracle互換のタイムゾーン名を設定できないためです。
 2. Rプロンプトで次のように入力します。
    Sys.setenv(TZ = "PST8PDT")
 RスクリプトはLinux/UnixおよびWindowsで移植の問題なしに機能するため、
 オプション2の使用をお薦めします。また、オプション2を使用すると、
 WindowsでもOracle互換のタイムゾーン名を指定できます。
 Rセッション・タイム・ゾーンにより、すべてのPOSIXctタイム・ゾーン修飾されていない
 date-time型に対するタイムゾーンが決まります。これは、Rで表示する際に、
 すべての修飾されたdate-time型が変換されるタイム・ゾーンでもあります。
 次の例では、これを説明します。
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
Rで表示する際に、修飾されていないタイムスタンプも
Rのセッション・タイム・ゾーンにあると想定されます。
もちろん、Rは高性能でもあるため、US夏時間が始まる時期に
基づいて、時刻がPSTに入るかPDTに入るかを判断し、
適切にPSTまたはPDTを表示できます。
次の例では、これをさらに明確に示します。
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
すべてのタイム・ゾーン修飾されていないタイムスタンプはセッション・タイム・ゾーンにあると
想定されます。しかし、タイム・ゾーン修飾されたタイムスタンプでもセッション・タイム・ゾーンに
変換されて、表示されます。Rでは、すべての値がRセッションのタイム・ゾーンで
表示されます(タイムゾーン名付きで、該当するかぎり、夏時間を考慮するために
ESTまたはEDTにも変更)。
Rでの日付、時刻およびタイム・ゾーンの
処理方法の詳細は、次のURLでDate-Timeを参照してください。
http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html
また、次のURLでtimezonesを参照してください。
http://stat.ethz.ch/R-manual/R-devel/library/base/html/timezones.html
略称ではなく長いタイム・ゾーン名('Olson名'とも呼ばれる)を使用する例を
あげてみましょう。
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
このような場合、Rでは、値を表示する際に長い名前を使用せず、
かわりに略称の"PST"および"PDT"を使用して値を表示します。
これは、Oracleでは必ずしもこのような略称が適するわけではないため、
重要です。たとえば、Oracleデータベースは"PDT"を
有効なタイム・ゾーンと認識しません。有効なタイム・ゾーンの詳細は、
「Rタイム・ゾーンとOracleセッション・タイム・ゾーン」を参照してください。
}
   次の例では、R環境でのタイム・ゾーン変更の影響を
   示します。
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
  また、\code{dbWriteTable}は、現在のトランザクションおよび挿入するデータを
  常に自動的にコミットします。つまり、既存の表に行を追加する場合でも
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
