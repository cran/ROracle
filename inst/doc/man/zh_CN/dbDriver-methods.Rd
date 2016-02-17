\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
数据库接口 (DBI) 类和驱动程序的 Oracle 实施
}
\description{
Oracle 驱动程序初始化和关闭。
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
一个对象, 继承自 \code{OraDriver} 或 \code{ExtDriver},
    由 \code{dbDriver} 创建。
}

  \item{...}{
要传递给驱动程序 \code{drvName} 的任何其他参数。
}
}
\value{
\item{dbDriver}{
    一个对象 \code{OraDriver} 或 \code{ExtDriver}, 其类扩展
    \code{DBIDriver}。此对象用于使用函数 \code{dbConnect} 创建与
    一个或多个 Oracle 数据库引擎的连接。
  }
  \item{dbUnloadDriver}{
    释放驱动程序对象占用的所有资源。
  }
}
\section{Side Effects}{
  \describe{
    \item{dbDriver}{
      The \R client part of the database communication is initialized,
      but note that connecting to the database engine needs to be done through
      calls to \code{\link[DBI]{dbConnect}}.
    }
    \item{dbUnloadDriver}{
      Remove the communication link between the \R client and the database.
    }
  }
}





\details{
\\describe{
    \item{dbDriver}{
       此对象是单例对象, 即在后续调用中,
       \code{dbDriver} 将返回同一已初始化对象。
      此实施允许您同时连接到多个主机服务器
      并同时在每个服务器上运行多个连接。
      当 \code{interruptible} 设置为 TRUE 时, 可以通过在一个线程中
      执行查询来中断服务器上长时间运行的查询。
      主线程检查是否有 Ctrl-C, 并发出 OCIBreak/OCIReset 来取消
      服务器上的操作。默认情况下, \code{interruptible} 为 FALSE。
      当 \code{unicode_as_utf8} 设置为 FALSE 时, 使用 NLS_LANG 设置
      指定的字符集来提取 NCHAR, NVARCHAR 和 NCLOB
      数据。默认情况下, \code{unicode_as_utf8} 设置为 TRUE。
      当 \code{ora.attributes} 设置为 TRUE 时, \code{dbGetQuery} 和 \code{fetch}
      中的结果集包含特定于 DBMS 的属性, 例如
      对应列的 \code{ora.encoding}, \code{ora.type} 和
      \code{ora.maxlength}。
    }
    \item{dbUnloadDriver}{
      此实施将删除 \R 客户机与数据库之间的通信
      链路。它释放与这些连接对象关联的所有连接和
      所有结果集。
    }
  }
}
\section{References}{
  For Oracle Database documentation, see
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
  \code{\link[DBI]{dbListTables}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    # first load the library
    library("ROracle")

    # create an Oracle instance
    drv <- dbDriver("Oracle")

    con <- dbConnect(drv, "scott", "tiger")
    dbListTables(con)

    # fetch all results from the emp table
    res <- dbGetQuery(con, "select * from emp")

    # dbSendQuery can be used to fetch data in chunks 
    # as well as all of data at once
    res <- dbSendQuery(con, "select * from emp")

    # fetch all results
    fetch(res)

    # or a chunk at a time
    fetch(res, n = 5)

    # describing the schema for the emp table using dbGetInfo
    dbGetInfo(res, what = 'fields')

    # clear the result
    dbClearResult(res)

    # disconnect from the database
    dbDisconnect(con)

    # free the driver object
    dbUnloadDriver(drv)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
