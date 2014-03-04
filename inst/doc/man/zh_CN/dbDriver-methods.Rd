\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
数据库接口 (DBI) 类和驱动程序的
  Oracle 实现
}
\description{
Oracle 驱动程序初始化和关闭
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
任何其他参数传递给驱动程序 \code{drvName}。
}
}
\value{
\item{dbDriver}{
    一个对象 \code{OraDriver} 或 \code{ExtDriver}, 其类扩展
    \code{DBIDriver}。对象用于使用函数 \code{dbConnect} 创建与
    一个或多个 Oracle 数据库引擎的连接。
  }
  \item{dbUnloadDriver}{
    free all resources occupied by driver object.
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
      Remove communication link between \R client and database.
    }
  }
}


\details{
\\describe{
    \item{dbDriver}{
      此对象是单例, 即在后续调用中
      它将返回同一已初始化对象。
      此实施允许您同时连接到多个主机服务器
      并同时在每个服务器上运行多个连接。
      当“可中断”设置为 TRUE 时, 可以通过在一个线程中执行查询
      来中断服务器上长时间运行的查询。主线程
      检查是否有 Ctrl-C, 并且发出 OCIBreak/OCIReset 来取消
      服务器上的操作。默认情况下,“可中断”为 FALSE。
    }
    \item{dbUnloadDriver}{
      实施将删除 \R 客户机与数据库之间的通信
      连接。它释放与这些连接对象关联的所有连接和
      所有结果集
    }
  }
}
\section{References}{
  For the Oracle Database documentaion see
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
    # create an Oracle instance
    drv <- dbDriver("Oracle")

    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp")
    fetch(res, n = 5)
    fetch(res)
    dbClearResult(res)
    dbUnloadDriver(drv)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
