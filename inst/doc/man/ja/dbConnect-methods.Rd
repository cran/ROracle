\name{dbConnect-methods}
\docType{methods}
\alias{dbConnect}
\alias{dbDisconnect}
\alias{dbConnect,OraDriver-method}
\alias{dbConnect,ExtDriver-method}
\alias{dbDisconnect,OraConnection-method}
\title{
Oracle DBMSへの接続オブジェクトの作成
}
\description{
これらのメソッドは対応する汎用関数の直接的な実装です。
}
\usage{
\S4method{dbConnect}{OraDriver}(drv, username = "", password = "", dbname = "", prefetch = FALSE,
          bulk_read = 1000L, stmt_cache = 0L, external_credentials = FALSE,
          sysdba = FALSE, ...)
\S4method{dbConnect}{ExtDriver}(drv, prefetch = FALSE, bulk_read = 1000L, stmt_cache = 0L,
          external_credentials = FALSE, sysdba = FALSE, ...)
\S4method{dbDisconnect}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
クラス\code{OraDriver}または\code{ExtDriver}のオブジェクト。
}
  \item{conn}{
\code{OraConnection}によって生成される\code{dbConnect}オブジェクト。
}
  \item{username}{
ユーザー名を指定する文字列。
}
  \item{password}{
パスワードを指定する文字列。
}
  \item{dbname}{
接続識別子を指定する文字列(詳細は、
    『Oracle Database Net Services管理者ガイド』の第8章
    「ネーミング方法の構成」を参照してください)。これは、SQL*Plus接続文字列の
    @記号よりも後の部分と同じです。
    Oracle Walletを使用してユーザー名とパスワードを格納する場合、
    この文字列は、ウォレット・マッピングの作成に使用される接続文字列と
    同じである必要があります(詳細は、『Oracle Databaseセキュリティ・ガイド』の第3章の
    外部パスワード・ストアを使用するクライアント構成に関する項を参照してください)。
    Oracle TimesTen IMDBインスタンスの接続識別子は、
    OCI tnsnamesつまり簡易接続ネーミング・メソッドによってサポートされます。OCIの
    TimesTen接続の詳細は、TimesTen In-Memory C開発者ガイドの第3章
    「OCIのTimesTenサポート」を参照してください。
}
  \item{prefetch}{
TRUEまたはFALSEを示す論理値。TRUEに設定すると、ROracleは
    OCIプリフェッチ・バッファを使用して、サーバーから追加データを取得します。このため、
    データをOCIからフェッチするための単一行バッファを割り当てることで、
    RODBI/ROOCIで必要なメモリーが節約されます。プリフェッチを使用するとすべての行で
    フェッチ・コールが生成されます。デフォルトでは、プリフェッチはFALSEで、サーバーからデータを
    取得するための配列フェッチが使用されます。
}
  \item{bulk_read}{
一度にフェッチする行数を示す正数値。デフォルト値は
    1000Lです。プリフェッチ・オプションが選択されているとき、メモリーは
    プリフェッチ・バッファに割り当てられ、OCIは一度にそれら多数の行をフェッチします。
    プリフェッチが使用されないとき(デフォルト)、メモリーはRODBI/ROOCIの定義バッファ
    に割り当てられます。これを大きな値に設定すると、選択リストの列数
    や列の型に基づいて割り当てられるメモリーが増加します。
    文字列型の列では、NLS最大幅の倍数である最大幅を使用して
    定義バッファが割り当てられます。アプリケーションは、問合せ結果に基づいて
    この値を調整する必要があります。大きな値は、大量の結果
    を返す問合せにとって有効です。アプリケーションは必要に応じてこの値を
    調整できます。
}
  \item{stmt_cache}{
キャッシュする文の数を示す正数値。これにより、文を再び解析しなくても、
    カーソルをすぐに使用することができます。
    デフォルト値は0Lです。stmt_cache値が0Lよりも大きい場合、
    \code{prefetch}値をTRUEに設定する必要があります。
}
  \item{external_credentials}{
TRUEまたはFALSEを示す論理値。TRUEに設定すると、ROracleは、
    外部資格証明によって認証されたOCIセッションを接続で開始します。
    デフォルト値はFALSEです。
}
  \item{sysdba}{
TRUEまたはFALSEを示す論理値。TRUEに設定すると、ROracleは、
    SYSDBA権限のOCIセッションを接続で開始します。
    デフォルト値はFALSEです。
}
  \item{\dots}{
現在使用されていません。
}
}
\value{
\item{dbConnect}{
    クラスが\code{OraConnection}を拡張するオブジェクト\code{DBIConnection}。
    このオブジェクトはデータベースでSQL問合せを実行するために使用されます。
  }
  \item{dbDisconnect}{
    処理が成功したかどうかを示す論理値。
  }
}
\section{Side Effects}{
  \describe{
    \item{dbConnect}{
      Establishes a connection between R and an Oracle Database server.
    }
    \item{dbDisconnect}{
      Frees resources used by the connection object.
    }
  }
}
      




           
\details{
\\describe{
    \item{dbConnect}{
      この接続オブジェクトは、データベースで処理を実行するために使用されます。
      \code{prefetch}がTRUEに設定されているときは、サーバーから追加データを取得するために、
      OCIプリフェッチ・バッファの使用が許可されます。
      \code{bulk_read}引数は、一度にフェッチする行数を示す整数値の設定
      に使用されます。
      \code{stmt_cache}引数は、文キャッシュ機能を有効または無効にするために使用
      されます。値によって文キャッシュのサイズが指定されます。
      \code{external_credentials}引数は、外部資格証明によって認証されたOCIセッション
      を接続で開始するために使用されます。
      \code{sysdba}引数は、SYSDBA権限のOCIセッションを接続で
      開始するために使用されます。
      \code{ExtDriver}ドライバで接続を確立するとき、資格証明を指定する引数
      は使用されません。このモードの接続は
      シングルトン・オブジェクトです。つまり、\code{dbConnect}へのすべてのコールが
      同じ接続オブジェクトを返します。
    }
    \item{dbDisconnect}{
      この実装は、Rとデータベース・サーバーの間の接続を切断します。
      接続オブジェクトによって使用されるすべてのリソースを解放します。また、
      この接続オブジェクトに関連付けられているすべての結果セットを解放します。
    }
  }
}
\section{References}{
  For the Oracle Database documentation see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    ## create an Oracle Database instance and create one connection on the
    ## same machine.
    drv <- dbDriver("Oracle")

    ## use username/password authentication
    con <- dbConnect(drv, username = "scott", password = "tiger")

    ## run a SQL statement by creating first a resultSet object
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## we now fetch records from the resultSet into a data.frame
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## create an Oracle Database instance and create one connection to a
    ## remote database using the SID in the connect string. 
    drv <- dbDriver("Oracle")

    ## refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.
    host <- "myhost"
    port <- 1521
    sid <- "mysid"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
        "(CONNECT_DATA=(SID=", sid, ")))", sep = "")

    ## use username/password authentication
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## run a SQL statement by creating first a resultSet object
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## we now fetch records from the resultSet into a data.frame
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## create an Oracle Database instance and create one connection to a
    ## remote database using the service name.
    drv <- dbDriver("Oracle")

    ## refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.

    host <- "myhost"
    port <- 1521
    svc <- "mydb.example.com"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
      "(CONNECT_DATA=(SERVICE_NAME=", svc, ")))", sep = "")
    ## use username/password authentication
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## run a SQL statement by creating first a resultSet object
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## we now fetch records from the resultSet into a data.frame
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## use Oracle Wallet authentication
    con <- dbConnect(drv, username ="", password="", 
    dbname = "<wallet_connect_string>")

    ## run a SQL statement by creating first a resultSet object
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## we now fetch records from the resultSet into a data.frame
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## connect to a TimesTen IMDB instance using the easy connect 
    ## naming method where SampleDb is a direct driver TimesTen DSN
    con <- dbConnect(drv, username ="scott", password="tiger", 
                     dbname = "localhost/SampleDb:timesten_direct")

    ## run a SQL statement by creating first a resultSet object
    rs <- dbSendQuery(con, "select * from dual")

    ## we now fetch records from the resultSet into a data.frame
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## connect to an extproc (this assumes that the driver has already
    ## been initialized in the embedded R code by passing an external
    ## pointer representing the extproc context)
    con <- dbConnect(Extproc())

    ## run a SQL statement by creating first a resultSet object
    rs <- dbSendQuery(con, "select * from dual")

    ## we now fetch records from the resultSet into a data.frame
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## create connection with SYSDBA privileges
    con <- dbConnect(drv, username ="scott", password="tiger",
                     sysdba = TRUE)

    ## run a SQL statement by creating first a resultSet object
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## we now fetch records from the resultSet into a data.frame
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")
    
    ## Use OS authentication as an example of external authentication
    ## Make sure that databse user exist to allow an OS authentication

    ## create connection authenticated with external credentials 
    con <- dbConnect(drv, username ="", password="",
                     external_credentials = TRUE)
    
    ## Above dbConnect() used OS credentials to connect with database.

    ## run a SQL statement by creating first a resultSet object
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## we now fetch records from the resultSet into a data.frame
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
