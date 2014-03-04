\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Oracle-Implementierung der Database Interface-(DBI-)Klassen 
  und -Treiber
}
\description{
Oracle-Treiberinitialisierung und -schließung
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
ein Objekt, das aus \code{OraDriver} oder \code{ExtDriver} erbt,
    wie mit \code{dbDriver}.
}
  \item{...}{
andere Argumente werden an den Treiber übergeben \code{drvName}.
}
}
\value{
\item{dbDriver}{
    Ein Objekt \code{OraDriver} oder \code{ExtDriver}, dessen Klasse \code{DBIDriver} erweitert.
    Dieses Objekt wird verwendet, um mit der Funktion \code{dbConnect}
    Verbindung zu mindestens einer Oracle-Datenbank-Engine herzustellen.
  }
  \item{dbUnloadDriver}{
    gibt alle Ressourcen frei, die von dem Treiberobjekt belegt werden.
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
      Objekt ist ein Einzelobjekt, d.h. bei nachfolgenden Aufrufen wird dasselbe
      initialisierte Objekt zurückgegeben.
      Mit dieser Implementierung können Sie mehrere Hostserver verbinden und 
      mehrere Verbindungen auf jedem Server gleichzeitig ausführen.
      Wenn "Interruptible" auf TRUE gesetzt ist, können Abfragen mit langer Ausführungsdauer
      auf dem Server unterbrochen werden, indem die Abfrage in einem Thread ausgeführt wird. 
      Der Hauptthread prüft auf Strg-C und gibt OCIBreak/OCIReset aus, um den Vorgang auf
      dem Server abzubrechen. Standardmäßig ist "Interruptible" FALSE.
    }
    \item{dbUnloadDriver}{
      Die Implementierung entfernt den Kommunikationslink zwischen \R-Client und 
      Datenbank. Sie gibt alle Verbindungen und Ergebnismengen frei, die mit diesen
      Verbindungsobjekten verknüpft sind.
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
