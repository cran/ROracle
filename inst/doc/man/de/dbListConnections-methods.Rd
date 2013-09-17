\name{dbListConnections-methods}
\docType{methods}
\alias{dbListConnections}
\alias{dbListResults}
\alias{dbListConnections,OraDriver-method}
\alias{dbListConnections,ExtDriver-method}
\alias{dbListResults,OraConnection-method}
\title{
Elemente von Oracle-Objekten auflisten
}
\description{
Diese Methoden sind einfache Implementierungen der entsprechenden
   generischen Funktionen.
}
\usage{
\S4method{dbListConnections}{OraDriver}(drv, ...)
\S4method{dbListConnections}{ExtDriver}(drv, ...)
\S4method{dbListResults}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
ein \code{OraDriver} oder \code{ExtDriver}.
}
  \item{conn}{
ein \code{OraConnection}.
}
  \item{\dots}{
Aktuell nicht verwendet.
}
}
\value{
\item{dbListConnections}{
    Eine Liste aller Verbindungen, die mit dem Treiber verknüpft sind.
  }
  \item{dbListResults}{
    Eine Liste aller Ergebnismengen, die mit der Verbindung verknüpft sind.
  }
}
\details{
\\describe{
    \item{dbListConnections}{
      Die Implementierung gibt eine Liste aller verknüpften Verbindungen zurück.
      Sie zeigt Informationen zu allen verknüpften Verbindungen an.
    }
    \item{dbListResults}{
      Die Implementierung gibt eine Liste aller verknüpften Ergebnismengen zurück.
      Sie zeigt Informationen zu allen verknüpften Ergebnismengen an.
    }
  }
}
\section{References}{
  For the Oracle Database documentaion see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbColumnInfo}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}}
}

\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con1 <- dbConnect(drv, "scott", "tiger")
    res1 <- dbSendQuery(con1, "select * from emp where deptno = 10")
    res2 <- dbSendQuery(con1, "select * from emp where deptno = 20")
    con2 <- dbConnect(drv, "scott", "tiger")
    res3 <- dbSendQuery(con2, "select * from dept")

    ## get all active statements
    for(con in dbListConnections(drv))
      for (res in dbListResults(con))
        print(dbGetStatement(res))
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
