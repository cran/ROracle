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
Eine Anweisung bei einer vorgegebenen Datenbankverbindung ausführen
}
\description{
Diese Methoden sind einfache Implementierungen der entsprechenden
   generischen Funktionen mit Ausnahme der \code{execute}-Methode, die eine 
   ROracle-spezifische DBI-Erweiterung ist.
}
\usage{
\S4method{dbSendQuery}{OraConnection,character}(conn, statement, data = NULL, prefetch = FALSE, bulk_read = 1000L, ...)
\S4method{dbGetQuery}{OraConnection,character}(conn, statement, data = NULL, prefetch = FALSE, bulk_read = 1000L, ...)
\S4method{dbClearResult}{OraResult}(res, ...)
\S4method{dbGetException}{OraConnection}(conn, ...)

execute(res, ...)
\S4method{execute}{OraResult}(res, data = NULL, ...)
}
\arguments{
  \item{conn}{
ein \code{OraConnection}-Objekt.
}
  \item{statement}{
ein Zeichenvektor mit der Länge 1 mit der SQL-Anweisung.
}
  \item{res}{
ein \code{OraResult}-Objekt.
}
  \item{data}{
ein data.frame, der Bind-Daten angibt
}
  \item{prefetch}{
Ein logischer Wert, der TRUE oder FALSE angibt. Wenn der Wert auf TRUE gesetzt ist, verwendet ROracle
    OCI-Prefetch-Puffer, um zusätzliche Daten aus dem Server abzurufen und so Speicher zu
    sparen, der in RODBI/ROOCI benötigt wird, indem ein einzelner Zeilenpuffer für den Abruf 
    der Daten aus OCI verwendet wird. Die Verwendung von Prefetch führt zu einem Fetch-Aufruf für jede
    Zeile. Standardmäßig ist Prefetch FALSE und Array-Fetch wird verwendet, um die Daten aus
    dem Server abzurufen.
}
  \item{bulk_read}{
Ein ganzzahliger Wert, der die Anzahl von Zeilen angibt, die gleichzeitig abgerufen werden sollen.
    Der Standardwert beträgt 1000L. Wenn die Prefetch-Option gewählt ist, wird der Speicher für
    Prefetch-Puffer verwendet und OCI ruft diese Anzahl von Zeilen gleichzeitig ab.
    Wenn Prefetch nicht verwendet wird (Standard), wird der Speicher in RODBI/ROOCI-
    Define-Puffern zugewiesen. Wenn hier ein hoher Wert festgelegt wird, wird mehr Speicher
    basierend auf der Anzahl von Spalten in der Select-Liste und den Spaltentypen zugewiesen.
    Bei einer Zeichenspalte werden Define-Puffer mit der maximalen Breite
    mal der maximalen NLS-Breite zugewiesen. Die Anwendung muss diesen 
    Wert entsprechend dem Abfrageergebnis anpassen und ein hoher Wert kommt
    Abfragen zu Gute, die ein großes Ergebnis zurückgeben. Die Anwendung kann diesen
    Wert nach Bedarf optimieren.
}
  \item{\dots}{
Aktuell nicht verwendet.
}
}
\value{
\item{dbSendQuery}{
    ein Objekt \code{OraResult}, dessen Klasse \code{DBIResult} erweitert. Dieses 
    Objekt wird für den Abruf von Daten aus der Datenbank mit der Funktion 
    \code{fetch} verwendet.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      query statement is executed and data has fetched from database.
    }
    \item{dbSendQuery}{
      query statement is executed, but note that data needs to fetch through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{dbClearResult}{
      resources acquired by result set has free.
    }
    \item{dbGetException}{
      error information retrieved and then cleaned from driver.
    }
    \item{execute}{
      query statement is executed.
    }
  }
}
\details{
\\describe{
    \item{dbGetQuery}{
      Die Implementierung führt die Abfrageanweisung aus und ruft 
      Ergebnisdaten aus der Datenbank ab. 
    }
    \item{dbSendQuery}{
      Die Implementierung führt die Abfrageanweisung aus und gibt die 
      Ergebnismenge an die Anwendung zurück. Die Anweisung kann nun Vorgänge 
      mit der Ergebnismenge ausführen. 
    }
    \item{dbClearResult}{
      Die Implementierung gibt Ressourcen frei, die von der Ergebnismenge belegt werden.
    }
    \item{dbGetException}{
      Die Implementierung ruft Fehlerinformationen ab.
    }
    \item{execute}{
      Die Implementierung führt die Abfrageanweisung aus.
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
    res4 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data3 = data.frame(ename = 'SMITH')) 
    data3 <- fetch(res4, n = -1)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
