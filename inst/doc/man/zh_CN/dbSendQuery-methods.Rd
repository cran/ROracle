\name{dbSendQuery-methods}
\docType{methods}
\alias{dbSendQuery}
\alias{dbGetQuery}
\alias{dbClearResult}
\alias{dbGetException}
\alias{execute}
\alias{dbSendQuery,OraConnection,character-method}
\alias{dbGetQuery,OraConnection,character-method}
\alias{dbClearResult,OraResult-method}
\alias{dbGetException,OraConnection-method}
\alias{execute,OraResult-method}
\title{
在给定数据库连接上执行语句
}
\description{
这些方法是相应泛型函数的
   简单实现, 但 \code{execute} 方法除外, 该方法是一个
   ROracle 特定的 DBI 扩展。
}
\usage{
\S4method{dbSendQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbGetQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbClearResult}{OraResult}(res, ...)
\S4method{dbGetException}{OraConnection}(conn, ...)

execute(res, ...)
\S4method{execute}{OraResult}(res, data = NULL, ...)
}
\arguments{
  \item{conn}{
一个 \code{OraConnection} 对象。
}
  \item{statement}{
长度为 1 的字符向量及 SQL 语句。
}
  \item{res}{
一个 \code{OraResult} 对象。
}
  \item{data}{
一个用于指定绑定数据的 data.frame
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
    内存, OCI 将一次提取这么多行。未使用预取
    (默认) 时, 在 RODBI/ROOCI 定义缓冲区中分配内存。
    根据选择列表中的列数以及列的类型,
    将此项设置为较大的值可以分配更多内存。
    对于字符类型的列, 定义缓冲区将使用最大宽度乘以
    NLS 最大宽度来分配。应用程序应根据查询结果调整
    此值, 较大的值对于返回较大结果的查询
    会有好处。应用程序可以根据其需求调整此值。
}
  \item{bulk_write}{
一个指示一次写入的行数的整数值。
    默认值为 1000L。参数中提供了 bulk_write 值时,
    将为缓冲区分配内存, OCI 将一次写入这么多行。
    未提供 bulk_write 参数时, 将使用默认值 1000 为
    绑定缓冲区分配内存。根据插入列表中的列数
    以及列的类型, 将此项设置为较大的值
    可以分配更多内存。
}
  \item{\dots}{
当前未使用。
}
}
\value{
\item{dbSendQuery}{
    一个对象 \code{OraResult}, 其类扩展 \code{DBIResult}。此
    对象用于使用函数 \code{fetch} 从数据库
    提取数据。
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      Query statement is executed and data has fetched from database.
    }
    \item{dbSendQuery}{
      Query statement is executed, but note that data needs to fetch through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{dbClearResult}{
      Resources acquired by result set has free.
    }
    \item{dbGetException}{
      Error information retrieved and then cleaned from driver.
    }
    \item{execute}{
      Query statement is executed.
    }
  }
}
\details{
\\describe{
    \item{dbGetQuery}{
      此函数执行查询语句并从数据库中
      提取结果数据。
    }
    \item{dbSendQuery}{
      此函数执行查询语句并将结果集返回
      应用程序。应用程序现在可以在结果集上执行操作。
    }
    \item{dbClearResult}{
      此函数释放结果集占用的资源。
    }
    \item{dbGetException}{
      此函数检索错误信息。
    }
    \item{execute}{
      此函数执行指定的查询语句。
    }
  }
}
\section{References}{
  For the Oracle Database documentaion see 
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp where deptno = :1",
                       data = data.frame(deptno = 10))
    data <- fetch(res, n = -1)
    res2 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data1 = data.frame(deptno = 10), prefetch=TRUE,
                        bulk_read=2L)
    data1 <- fetch(res2, n = -1)
    res3 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data2 = data.frame(deptno = 10), bulk_read=10L)
    data2 <- fetch(res3, n = -1)
    res4 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data3 = data.frame(deptno = 10), bulk_write=10L)
    data3 <- fetch(res4, n = -1)
    res5 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data4 = data.frame(ename = 'SMITH')) 
    data4 <- fetch(res5, n = -1)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
