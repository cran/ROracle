\name{dbSendQuery-methods}
\docType{methods}
\alias{dbSendQuery}
\alias{dbGetQuery}
\alias{oracleProc}
\alias{dbClearResult}
\alias{dbGetException}
\alias{execute}
\alias{dbSendQuery,OraConnection,character-method}
\alias{dbGetQuery,OraConnection,character-method}
\alias{dbClearResult,OraResult-method}
\alias{oracleProc,OraConnection,character-method}
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
\S4method{dbSendQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbGetQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{oracleProc}{OraConnection,character}(conn, statement, data = NULL, 
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbClearResult}{OraResult}(res, ...)
\S4method{dbGetException}{OraConnection}(conn, ...)

execute(res, ...)
\S4method{execute}{OraResult}(res, data = NULL, ...)
}
\arguments{
  \item{conn}{
Ein \code{OraConnection}-Objekt.
}
  \item{statement}{
Ein Zeichenvektor mit der Länge 1 mit der SQL-Anweisung.
}
  \item{res}{
Ein \code{OraResult}-Objekt.
}
  \item{data}{
Ein \code{data.frame}, der Bind-Daten angibt
}
  \item{prefetch}{
Ein logischer Wert, der angibt, ob ROracle Prefetch-Puffer oder einen
    Array-Fetch verwendet, um Daten aus dem Server abzurufen. Bei \code{TRUE} ruft ROracle 
    zusätzliche Daten mit OCI-Prefetch-Puffern aus dem Server ab und spart dabei den 
    in RODBI/ROOCI benötigten Speicher, indem ein einzelner Zeilenpuffer für den Abruf 
    der Daten aus OCI verwendet wird. Die Verwendung von Prefetch führt zu einem Fetch-Aufruf für jede
    Zeile. Bei \code{FALSE} (Standardwert) verwendet ROracle einen Array-Fetch, um die Daten
    abzurufen.
}
  \item{bulk_read}{
Ein ganzzahliger Wert, der die Anzahl von Zeilen angibt, die jeweils abgerufen werden soll.
    Der Standardwert beträgt 1000L. Wenn die Prefetch-Option aktiviert ist, wird Speicher für
    Prefetch-Puffer zugewiesen, und OCI ruft jeweils die angegebene Anzahl von Zeilen ab.
    Wenn Prefetch nicht verwendet wird (Standard), wird Speicher in RODBI/ROOCI-
    Define-Puffern zugewiesen. Wenn Sie hier einen hohen Wert festlegen, wird mehr Speicher
    basierend auf der Anzahl von Spalten in der Select-Liste und den Spaltentypen zugewiesen.
    Bei einer Zeichenspalte werden Define-Puffer mit der maximalen Breite
    mal der maximalen NLS-Breite zugewiesen. Anwendungen müssen diesen 
    Wert entsprechend dem Abfrageergebnis anpassen. Ein hoher Wert kommt
    Abfragen zu Gute, die ein großes Ergebnis zurückgeben. Die Anwendung kann diesen
    Wert nach Bedarf optimieren.
}
  \item{bulk_write}{
Ein ganzzahliger Wert, der die Anzahl an Zeilen angibt, die jeweils geschrieben
    werden sollen. Der Standardwert ist 1000L. Wenn Sie einen bulk_write-Wert
    angeben, wird Speicher für Puffer zugewiesen, und OCI schreibt jeweils die entsprechende
    Anzahl an Zeilen. Wenn Sie das Argument bulk_write nicht verwenden, wird über den
    Standardwert Speicher für die Bind-Puffer zugewiesen. Wenn Sie \code{bulk_write} auf einen
    hohen Wert setzen, wird basierend auf der Anzahl von Spalten in der Einfügeliste
    und auf den Spaltentypen entsprechend mehr Speicher zugewiesen.
}
  \item{\dots}{
Aktuell nicht verwendet.
}
}
\value{
\item{dbSendQuery}{
    Ein \code{OraResult}-Objekt, dessen Klasse \code{DBIResult} erweitert. Dieses 
    Objekt wird für den Abruf von Daten aus einer Datenbank mit der Funktion 
    \code{fetch} verwendet.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      Query statement is executed and data is fetched from database.
    }
    \item{dbSendQuery}{
      Query statement is executed, but data needs to be fetched through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{oracleProc}{
      PL/SQL stored procedure or function query statement is executed and 
      result is returned.
    }
    \item{dbClearResult}{
      Resources acquired by the result set are freed.
    }
    \item{dbGetException}{
      Error information is retrieved and then cleaned from the driver.
    }
    \item{execute}{
      Query statement is executed.
    }
  }
}
\details{
\\describe{
    \item{dbGetQuery}{
      Diese Funktion führt eine Abfrageanweisung aus und ruft die Ergebnisdaten
      aus der Datenbank ab. Sie sollte nicht für den Aufruf von PL/SQL-Abfragen verwendet werden.
    }
    \item{dbSendQuery}{
      Diese Funktion führt eine Abfrageanweisung aus und gibt eine Ergebnismenge
      an die Anwendung zurück. Die Anweisung kann dann Vorgänge mit der Ergebnismenge ausführen.
      Dies sollte nicht für den Aufruf von PL/SQL-Abfragen verwendet werden.
    }
     \item{oracleProc}{
      Diese Funktion führt eine gespeicherte PL/SQL-Prozedur oder Funktionsabfrageanweisung
      aus und gibt das Ergebnis zurück.
    }
    \item{dbClearResult}{
      Diese Funktion gibt Ressourcen frei, die von der Ergebnismenge belegt werden.
    }
    \item{dbGetException}{
      Diese Funktion ruft Fehlerinformationen ab.
    }
    \item{execute}{
      Diese Funktion führt die angegebene Abfrageanweisung aus.
    }
  }
}
\section{References}{
  For the Oracle Database documentation see 
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
                        data1 <- data.frame(deptno = 10), prefetch=TRUE,
                        bulk_read=2L)
    data1 <- fetch(res2, n = -1)
    data1

    res3 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data2 <- data.frame(deptno = 10), bulk_read=10L)
    data2 <- fetch(res3, n = -1)
    data2

    res4 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data3 <- data.frame(deptno = 10), bulk_write=10L)
    data3 <- fetch(res4, n = -1)
    data3

    res5 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data4 <- data.frame(ename = 'SMITH')) 
    data4 <- fetch(res5, n = -1)
    data4
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
