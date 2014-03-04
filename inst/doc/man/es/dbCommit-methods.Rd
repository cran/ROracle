\name{dbCommit-methods}
\docType{methods}
\alias{dbCommit}
\alias{dbRollback}
\alias{dbCommit,OraConnection-method}
\alias{dbRollback,OraConnection-method}
\title{
Gestión de Transacciones de DBMS
}
\description{
Confirma o realiza rollback de la transacción actual 
  en una conexión Oracle
}
\usage{
\S4method{dbCommit}{OraConnection}(conn, ...)
\S4method{dbRollback}{OraConnection}(conn, ...)
}
\arguments{
  \item{conn}{
objeto \code{OraConnection}, como lo produce la función \code{dbConnect}
}
  \item{\dots}{
no utilizado actualmente.
}
}
\section{Side Effects}{
  \describe{
    \item{dbCommit}{
      saves changes permanently.
    }
    \item{dbRollback}{
      undo all changes done after last save point.
    }
  }
}
\details{
\\describe{
    \item{dbCommit}{
      la implantación guarda todos los cambios realizados en esa conexión. 
      Los cambios no se pueden deshacer una vez guardados permanentemente.
    }
    \item{dbRollback}{
      la implantación deshace todos los cambios realizados después del último punto de grabación.
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
   \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")
    dbReadTable(con, "EMP")
    rs <- dbSendQuery(con, "delete from emp where deptno = 10")
    dbReadTable(con, "EMP")
    if(dbGetInfo(rs, what = "rowsAffected") > 1)
    {
      warning("dubious deletion -- rolling back transaction")
      dbRollback(con)
    }
    dbReadTable(con, "EMP")
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
