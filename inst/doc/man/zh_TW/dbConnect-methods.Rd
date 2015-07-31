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
這些方法是對應之一般函數的
   直接實行.
}
\usage{
\S4method{dbConnect}{OraDriver}(drv, username = "", password = "", dbname = "", prefetch = FALSE,
          bulk_read = 1000L, bulk_write = 1000L, stmt_cache = 0L,
          external_credentials = FALSE, sysdba = FALSE, ...)
\S4method{dbConnect}{ExtDriver}(drv, prefetch = FALSE, bulk_read = 1000L,
          bulk_write = 1000L, stmt_cache = 0L,
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
一個指定連線 ID 的字元字串 (如需詳細資訊, 請參閱
    Oracle Database Net Services Administrator's Guide 的
    第 8 章 Configuring Naming Methods). 這與 SQL*Plus
    連線字串中 '@' 符號後的部分相同.
    如果您使用 Oracle Wallet 來儲存使用者名稱與密碼,
    則此字串應該是用來建立公事包對應的連線字串 (如需
    詳細資訊, 請參閱 Oracle Database Security Guide 之第 3 章中
    的 Configuring Clients to Use the External Password Store).
    對 Oracle TimesTen IMDB 執行處理之連線 ID 的支援是透過 OCI
    tnsnames 或簡易連線命名方法來提供. 如需有關 OCI 之 TimesTen 連線
    的額外資訊, 請參閱 TimesTen In-Memory C Developer's Guide 的
    第 3 章 TimesTen Support for OCI.
    下列範例顯示各種指定連線 ID 的方式.
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
  \item{bulk_write}{
一個指示一次要插入、更新或刪除之資料列數的
    整數值. 預設值為 1000L. 以引數提供 bulk_write
    值時, 系統會為緩衝區配置記憶體, 而 OCI 將會一次寫入
    數量相當的資料列. 未提供 bulk_write 引數時, 會使用
    預設值 1000 來為連結緩衝區配置記憶體. 將這個值設成
    較大的值時, 會讓系統根據插入清單中的資料欄數與
    資料欄類型, 配置更多的記憶體.
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
      此連線物件是用來在資料庫上執行作業.
      當 \code{prefetch} 設為 TRUE 時, 即允許使用 OCI
      預先擷取緩衝區來從伺服器擷取其他資料.
      \code{bulk_read} 引數是用來設定指示一次要擷取之
      資料列數的整數值.
      \code{bulk_write} 引數是用來設定指示一次要寫入之
      資料列數的整數值.
      \code{stmt_cache} 引數是用來啟用或停用敘述句快取功能.
      其值指定敘述句快取大小.
      \code{external_credentials} 引數是用來在連線上啟動使用外部證明資料
      進行認證的 OCI 階段作業.
      \code{sysdba} 引數是用來在連線上以 SYSDBA 權限啟動
      OCI 階段作業.
      建立與 \code{ExtDriver} 驅動程式的連線時, 不會使用
      任何指定證明資料的引數. 這種模式的連線
      是一個單一物件, 也就是說, 所有對 \code{dbConnect} 的
      呼叫都會傳回相同的連線物件.
    }
    \item{dbDisconnect}{
      此實行會中斷 R 與資料庫伺服器之間的連線.
      它會釋出連線物件使用的所有資源, 並釋出
      與此連線物件關聯的所有結果集.
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
    ## Create an Oracle Database instance and create one connection on the
    ## same machine.
    drv <- dbDriver("Oracle")

    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection to a
    ## remote database using the SID in the connect string. 
    drv <- dbDriver("Oracle")

    ## Refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.
    host <- "myhost"
    port <- 1521
    sid <- "mysid"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
        "(CONNECT_DATA=(SID=", sid, ")))", sep = "")

    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection to a
    ## remote database using the service name.
    drv <- dbDriver("Oracle")

    ## Refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.

    host <- "myhost"
    port <- 1521
    svc <- "mydb.example.com"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
      "(CONNECT_DATA=(SERVICE_NAME=", svc, ")))", sep = "")
    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Use Oracle Wallet authentication.
    con <- dbConnect(drv, username ="", password="", 
    dbname = "<wallet_connect_string>")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Connect to a TimesTen IMDB instance using the easy connect 
    ## naming method where SampleDb is a direct driver TimesTen DSN.
    con <- dbConnect(drv, username ="scott", password="tiger", 
                     dbname = "localhost/SampleDb:timesten_direct")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from dual")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Connect to an extproc (this assumes that the driver has already
    ## been initialized in the embedded R code by passing an external
    ## pointer representing the extproc context).
    con <- dbConnect(Extproc())

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from dual")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Create connection with SYSDBA privileges.
    con <- dbConnect(drv, username ="scott", password="tiger",
                     sysdba = TRUE)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")
    
    ## Use OS authentication as an example of external authentication
    ## Make sure that databse user exist to allow an OS authentication

    ## Create connection authenticated with external credentials.
    con <- dbConnect(drv, username ="", password="",
                     external_credentials = TRUE)
    
    ## Above dbConnect() used OS credentials to connect with database.

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
