\name{dbConnect-methods}
\docType{methods}
\alias{dbConnect}
\alias{dbDisconnect}
\alias{dbConnect,OraDriver-method}
\alias{dbConnect,ExtDriver-method}
\alias{dbDisconnect,OraConnection-method}
\title{
建立 Oracle DBMS 的連線物件
}
\description{
這些方法皆為對應一般函數的
   直接實行.
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
類別 \code{OraDriver} 或 \code{ExtDriver} 的物件.
}
  \item{conn}{
一個由 \code{OraConnection} 產生的 \code{dbConnect} 物件.
}
  \item{username}{
指定使用者名稱的字元字串.
}
  \item{password}{
指定密碼的字元字串.
}
  \item{dbname}{
指定連線 ID 的字元字串 (如需詳細資訊, 請參閱
    Oracle Database Net Services Administrator's Guide 的
    第 8 章 Configuring Naming Methods). 此部分與
    SQL*Plus 連線字串後接 '@' 符號相同.
    如果您是使用 Oracle Wallet 儲存使用者名稱與密碼,
    則應使用此字串來建立公事包對應 (如需詳細資訊,
    請參閱 Oracle Database Security Guide 第 3 章中的
    Configuring Clients to Use the External Password Store).
    Oracle TimesTen IMDB 執行處理的連線 ID 是透過 OCI tnsnames 或
    簡易連線命名方法支援. 如需 OCI 的 TimesTen 連線額外資訊,
     請參閱 TimesTen In-Memory C Developer's Guide 的第 3 章
    TimesTen Support for OCI.
}
  \item{prefetch}{
一個指示 TRUE 或 FALSE 的邏輯值. 若設為 TRUE, ROracle 將使用
    OCI 預先擷取緩衝區來擷取伺服器中的其他資料, 而透過
    配置單一資料列緩衝區擷取 OCI 中的資料, 可節省 RODBI/ROOCI 中
    所需的記憶體. 使用預先擷取會對每個資料列產生一個擷取呼叫.
    依照預設, 預先擷取為 FALSE, 會使用陣列擷取來擷取伺服器中的
    資料.
}
  \item{bulk_read}{
指定一次要擷取之資料列數目的整數值. 預設值
    為 1000L. 如果選取預先擷取選項, 即會配置記憶體給
    預先擷取緩衝區, OCI 將一次擷取大量的資料列.
    若未使用預先擷取 (預設值), 記憶體就會配置在 RODBI/ROOCI
    定義緩衝區中. 這個值設得越大, 系統就會根據選取清單中的
    資料欄數目與資料欄類型來配置更多的記憶體.
    對於字元類型的資料欄, 會使用最大寬度乘以 NLS 最大寬度
    來配置定義緩衝區. 應用程式會根據查詢結果調整這個值,
    較大的值將有利查詢傳回更大的結果.
    應用程式可調整此值以符合其需要.
    
}
  \item{stmt_cache}{
指示要快取之敘述句數目的整數值. 它代表 
    游標已就緒可供使用, 無須再次剖析敘述句. 
    預設值為 0L. 如果 stmt_cache 值大於 0L, 則
    必須將 \code{prefetch} 值設為 TRUE.
}
  \item{external_credentials}{
指示 TRUE 或 FALSE 的邏輯值. 若設為 TRUE, ROracle 將
    在連線上啟動以外部證明資料認證的 OCI 階段作業.
    預設值為 FALSE.
}
  \item{sysdba}{
指示 TRUE 或 FALSE 的邏輯值. 若設為 TRUE, ROracle 將
    在連線上以 SYSDBA 權限啟動 OCI 階段作業.
    預設值為 FALSE.
}
  \item{\dots}{
目前未使用.
}
}
\value{
\item{dbConnect}{
    其類別擴充 \code{OraConnection} 的物件 \code{DBIConnection}. 
    此物件用來在資料庫上執行 SQL 查詢.
  }
  \item{dbDisconnect}{
    指示作業是否成功的邏輯值.
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
      此連線物件用來在資料庫上執行作業.
      當 \code{prefetch} 設為 TRUE 時, 即允許使用 OCI
      預先擷取緩衝區從伺服器擷取額外的資料.
      \code{bulk_read} 引數是用來設定指示
      一次要擷取之資料列數目的整數值.
      \code{stmt_cache} 引數是用來啟用或停用敘述句的快取功能.
      其值指定敘述句快取大小.
      \code{external_credentials} 是用來在連線上啟動使用外部證明資料認證的
       OCI 階段作業.
      \code{sysdba} 是用來在連線上以 SYSDBA 權限啟動
      OCI 階段作業.
      在建立與 \code{ExtDriver} 驅動程式的連線時,
      不會使用任何指定證明資料的引數. 這種模式的連線
      是一個單一物件, 也就是說, 所有對 \code{dbConnect} 的呼叫
      都會傳回相同的連線物件.
    }
    \item{dbDisconnect}{
      此實行會中斷 R 與資料庫伺服器之間的連線.
      它會釋出連線物件使用的所有資源, 並釋出
      與此連線物件相關聯的所有結果集.
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
