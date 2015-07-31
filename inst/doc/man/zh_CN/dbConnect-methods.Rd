\name{dbConnect-methods}
\docType{methods}
\alias{dbConnect}
\alias{dbDisconnect}
\alias{dbConnect,OraDriver-method}
\alias{dbConnect,ExtDriver-method}
\alias{dbDisconnect,OraConnection-method}
\title{
创建与 Oracle DBMS 的连接对象
}
\description{
这些方法是相应泛型函数的
   简单实施。
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
类 \code{OraDriver} 或 \code{ExtDriver} 的对象。
}
  \item{conn}{
由 \code{OraConnection} 生成的 \code{dbConnect} 对象。
}
  \item{username}{
一个用于指定用户名的字符串。
}
  \item{password}{
一个用于指定口令的字符串。
}
  \item{dbname}{
一个用于指定连接标识符的字符串 (有关
    详细信息, 请参阅 Oracle Database Net Services Administrator's Guide 中的
    第 8 章“Configuring Naming Methods”)。这与 
    跟在 '@' 符号后的 SQL*Plus 连接字符串部分相同。
    如果使用 Oracle Wallet 来存储用户名和口令,
    则此字符串应为用于创建 wallet 映射的
    连接字符串 (有关详细信息, 请参阅 Oracle Database Security Guide
    中第 3 章的“Configuring Clients to Use the External Password Store”)。
    通过 OCI tnsnames 或轻松连接指定方法来支持
    Oracle TimesTen IMDB 实例的连接标识符。有关 OCI 的 TimesTen 的连接
    详细信息, 请参阅 TimesTen In-Memory C Developer's Guide 中的
    第 3 章“TimesTen Support for OCI”。
    以下示例显示用于指定连接标识符的各种方式。
}
  \item{prefetch}{
一个指示 TRUE 或 FALSE 的逻辑值。设置为 TRUE 时, ROracle 将
    使用 OCI 预取缓冲区来从服务器检索附加数据, 通过分配一个
    单行缓冲区来从 OCI 提取数据, 从而节省 RODBI/ROOCI 中
    所需的内存。使用预取将对每一行产生一个提取调用。
    默认情况下, 预取为 FALSE, 使用阵列提取从服务器检索
    数据。
}
  \item{bulk_read}{
一个指示一次提取的行数的整数值。默认值为
    1000L。选择了预取选项时, 将为预取缓冲区分配
    内存, OCI 将提取一次提取这么多行。未使用预取 
    (默认) 时, 在 RODBI/ROOCI 定义缓冲区中分配内存。
    根据选择列表中的列数以及列的数据类型,
    将此项设置为较大的值可以分配更多内存。
    对于字符类型的列, 定义缓冲区将使用最大宽度乘以 
    NLS 最大宽度来分配。应用程序应根据查询结果调整
    此值, 较大的值对于返回较大结果的查询
    会有好处。应用程序可以根据其需求调整
    此值。
}
  \item{bulk_write}{
一个整数值, 指示一次插入, 更新或删除的行数。
    默认值为 1000L。如果参数中提供了 bulk_write 值,
    将为缓冲区分配内存, OCI 将一次写入这么多行。
    如果未提供 bulk_write 参数, 则将使用默认值
    1000 来为绑定缓冲区分配内存。根据
    插入列表中的列数以及列的数据类型,
    将此项设置为较大的值将会分配更多内存。
}
  \item{stmt_cache}{
一个指示要高速缓存的语句数的整数值。它表示
    游标已就绪可以使用, 无需重新对语句进行
    语法分析。默认值为 0L。如果 stmt_cache 值大于 0L,
    则 \code{prefetch} 值必须设置为 TRUE。
}
  \item{external_credentials}{
一个指示 TRUE 或 FALSE 的逻辑值。设置为 TRUE 时, ROracle 将
    启动在连接上通过外部身份证明验证的 OCI 会话。
    默认值为 FALSE。
}
  \item{sysdba}{
一个指示 TRUE 或 FALSE 的逻辑值。设置为 TRUE 时, ROracle 将
    启动在连接上具有 SYSDBA 权限的 OCI 会话。
    默认值为 FALSE。
}
  \item{\dots}{
当前未使用。
}
}
\value{
\item{dbConnect}{
    其类扩展 \code{OraConnection} 的对象 \code{DBIConnection}。
    此对象用于在数据库上执行 SQL 查询。
  }
  \item{dbDisconnect}{
    指示操作是否成功的逻辑值。
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
      此连接对象用于在数据库上执行操作。
      将 \code{prefetch} 设置为 TRUE 时, 它允许使用 OCI
      预取缓冲区来从服务器检索附加数据。
      \code{bulk_read} 参数用于设置整数值, 指示
      一次提取的行数。
      \code{bulk_write} 参数用于设置整数值,
      指示一次写入的行数。
      \code{stmt_cache} 参数用于启用或禁用语句
      高速缓存功能。其值指定语句高速缓存大小。
      \code{external_credentials} 参数用于启动通过连接上的外部
      身份证明验证的 OCI 会话。
      \code{sysdba} 参数用于启动在连接上具有 SYSDBA
      权限的 OCI 会话。
      建立与 \code{ExtDriver} 驱动程序的连接时,
      不使用任何指定身份证明的参数。采用此模式的
      连接是单例对象, 即, 所有对 \code{dbConnect} 的
      调用返回相同连接对象。
    }
    \item{dbDisconnect}{
      此实施将断开 R 与数据库服务器之间的连接。
      它释放连接对象使用的所有资源,
      并释放与此连接对象关联的所有结果集。
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
