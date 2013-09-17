\name{dbCommit-methods}
\docType{methods}
\alias{dbCommit}
\alias{dbRollback}
\alias{dbCommit,OraConnection-method}
\alias{dbRollback,OraConnection-method}
\title{
DBMS Transaction Management
}
\description{
Schreibt die aktuelle Transaktion in einer Oracle-Verbindung 
  fest oder rollt sie zurück
}
\usage{
\S4method{dbCommit}{OraConnection}(conn, ...)
\S4method{dbRollback}{OraConnection}(conn, ...)
}
\arguments{
  \item{conn}{
Ein \code{OraConnection}-Objekt, wie von der Funktion \code{dbConnect} erzeugt
}
  \item{\dots}{
Aktuell nicht verwendet.
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
      Implementierung speichert alle Änderungen an dieser Verbindung. 
      Änderungen können nicht rückgängig gemacht werden, nachdem sie endgültig gespeichert wurden.
    }
    \item{dbRollback}{
      Implementierung macht alle Änderungen seit dem letzten Savepoint rückgängig.
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
