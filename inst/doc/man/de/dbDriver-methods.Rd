\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Oracle-Implementierung der Database Interface-(DBI-)Klassen und -Treiber
}
\description{
Oracle-Treiberinitialisierung und -schließung.
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
Ein Objekt, das aus \code{OraDriver} oder \code{ExtDriver} erbt,
    wie mit \code{dbDriver}.
}

  \item{...}{
Weitere Argumente, die an den Treiber \code{drvName} übergeben werden sollen.
}
}
\value{
\item{dbDriver}{
    Ein Objekt \code{OraDriver} oder \code{ExtDriver}, dessen Klasse \code{DBIDriver} erweitert.
    Dieses Objekt wird verwendet, um mit der Funktion \code{dbConnect}
    Verbindung zu mindestens einer Oracle Database Engine herzustellen.
  }
  \item{dbUnloadDriver}{
    Gibt alle Ressourcen frei, die vom Treiberobjekt belegt werden.
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
       Dies ist ein Einzelobjekt. Das bedeutet, dass nachfolgende Aufrufe von
       \code{dbDriver} dasselbe initialisierte Objekt zurückgeben.
      Mit dieser Implementierung können Sie Verbindungen zu mehreren Hostservern herstellen
      und auf jedem Server mehrere Verbindungen gleichzeitig ausführen.
      Wenn \code{interruptible} auf TRUE gesetzt ist, können Abfragen mit langer Ausführungszeit
      auf dem Server durch Ausführen der Abfrage in einem Thread unterbrochen werden.
      Der Haupthread prüft auf STRG-C und gibt OCIBreak/OCIReset aus, um den Vorgang
      auf dem Server abzubrechen. Standardmäßig ist \code{interruptible} FALSE.
      Wenn \code{unicode_as_utf8} auf FALSE gesetzt ist, werden NCHAR-, NVARCHAR- und NCLOB-
      Daten über die in der NLS_LANG-Einstellung angegebene Zeichenfolge
      abgerufen. Standardmäßig ist \code{unicode_as_utf8} auf TRUE gesetzt.
      Wenn \code{ora.attributes} auf TRUE gesetzt ist, enthält die Ergebnismenge von
      \code{dbGetQuery} und \code{fetch} DBMS-spezifische Attribute wie
      \code{ora.encoding}, \code{ora.type} und \code{ora.maxlength} für die
      entsprechende Spalte.
    }
    \item{dbUnloadDriver}{
      Diese Implementierung entfernt Kommunikationslinks zwischen dem \R-Client und
      der Datenbank. Sie gibt alle Verbindungen und alle mit den dazugehörigen
      Verbindungsobjekten verknüpften Ergebnismengen frei.
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
