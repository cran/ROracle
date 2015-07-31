\name{dbGetInfo-methods}
\docType{methods}
\alias{dbGetInfo}
\alias{dbGetStatement}
\alias{dbGetRowCount}
\alias{dbGetRowsAffected}
\alias{dbColumnInfo}
\alias{dbHasCompleted}
\alias{dbGetInfo,OraDriver-method}
\alias{dbGetInfo,ExtDriver-method}
\alias{dbGetInfo,OraConnection-method}
\alias{dbGetInfo,OraResult-method}
\alias{dbGetStatement,OraResult-method}
\alias{dbGetRowCount,OraResult-method}
\alias{dbGetRowsAffected,OraResult-method}
\alias{dbColumnInfo,OraResult-method}
\alias{dbHasCompleted,OraResult-method}
\title{
Metadaten der Datenbankschnittstelle
}
\description{
Diese Methoden sind einfache Implementierungen der entsprechenden
   generischen Funktionen.
}
\usage{
\S4method{dbGetInfo}{OraDriver}(dbObj, ...)
\S4method{dbGetInfo}{ExtDriver}(dbObj, ...)
\S4method{dbGetInfo}{OraConnection}(dbObj, what, ...)
\S4method{dbGetInfo}{OraResult}(dbObj, what, ...)
\S4method{dbGetStatement}{OraResult}(res, ...)
\S4method{dbGetRowCount}{OraResult}(res, ...)
\S4method{dbGetRowsAffected}{OraResult}(res, ...)
\S4method{dbColumnInfo}{OraResult}(res, ...)
\S4method{dbHasCompleted}{OraResult}(res)
}
\arguments{
  \item{dbObj}{
Beliebiges Objekt, das eine Funktionalität in der R-Schnittstelle
    zu Datenbanken implementiert (einen Treiber, eine Verbindung oder eine Ergebnismenge).
}
  \item{what}{
Eine Zeichenfolge, die ein Element der Ausgabeliste angibt.
}
  \item{res}{
Ein \code{OraResult}.
}
  \item{\dots}{
Aktuell nicht verwendet.
}
}


































\details{
Bei Tabellen-, Schema- und Spaltennamen muss Groß- und Kleinschreibung beachtet werden.
  Beispiel: Die Tabellennamen \code{ABC} und \code{abc} sind nicht identisch. Namen von
  Datenbankschemaobjekten dürfen keine doppelten Anführungszeichen enthalten,
  da sie bei der Generierung der entsprechenden SQL-Anweisung in doppelte Anführungszeichen
  eingeschlossen werden. Die \\pkg{ROracle}-Methode \code{dbGetInfo} stellt folgende Details zu
  dem Treiberobjekt bereit:
  \itemize{
    \item {\\$driverName} Der Name des Treibers: "Oracle (OCI)"
    \item {\\$driverVersion} Die Version des verwendeten ROracle-Treibers
    \item {\\$clientVersion} Die Version der verwendeten Oracle-Client-Library
    \item {\\$conTotal} Die Anzahl der vom Treiber instanziierten Verbindungen
    \item {\\$conOpen} Die Anzahl der derzeit offenen Verbindungen
    \item {\\$interruptible} TRUE, wenn eine Abfrage mit langer Ausführungszeit unterbrochen werden kann
    \item {\\$unicode_as_utf8} TRUE, wenn Zeichendaten im verschlüsselten UTF8-
                              Format abgerufen werden müssen
    \item {\\$ora_attributes} TRUE, wenn jede Spalte in einem Ergebnismengen-Datenframe
                             entsprechende Oracle DBMS-Attribute besitzt
    \item {\\$connections} Informationen zu den einzelnen derzeit offenen Verbindungen. Weitere
                          Einzelheiten finden Sie unter: \code{dbGetInfo} des Verbindungsobjekts
  }
  Die \\pkg{ROracle}-Methode \code{dbGetInfo} stellt folgende Details zu dem
  Verbindungsobjekt bereit:
  \itemize{
    \item {\\$username} Der Name des Benutzers in dieser Verbindung
    \item {\\$dbname} Der verwendete Verbindungsalias bzw. die verwendete Verbindungszeichenfolge
    \item {\\$serverVersion} Die Version des Oracle Database-Servers
    \item {\\$serverType} Der Wert "Oracle RDBMS"
    \item {\\$resTotal} Die Anzahl der Ergebnismengen in dieser Verbindung
    \item {\\$resOpen} Die Anzahl der offenen Ergebnismengen in dieser Verbindung
    \item {\\$prefetch} TRUE, wenn Daten über Prefetch-Mechanismus abgerufen werden
    \item {\\$bulk_read} Die Anzahl der gleichzeitig aus dem DBMS abzurufenden Zeilen
    \item {\\$bulk_write} Die Anzahl der gleichzeitig in das DBMS zu schreibenden Zeilen
    \item {\\$stmt_cache} TRUE, wenn der Anweisungscache verwendet wird
    \item {\\$results} Informationen zu den einzelnen derzeit offenen Ergebnismengen finden Sie
                      unter: \code{dbGetInfo} der Ergebnismenge
  }
  Die \\pkg{ROracle}-Methode \code{dbGetInfo} stellt folgende Details
  zu dem Ergebnismengenobjekt bereit:
  \itemize{
    \item {\\$statement} Zum Erzeugen des Ergebnismengenobjekts verwendete SQL-Anweisung
    \item {\\$isSelect} TRUE, wenn eine SELECT-Anweisung angegeben wird
    \item {\\$rowsAffected} Die Anzahl der von der DML-Anweisung betroffenen Zeilen
    \item {\\$rowCount} Die Anzahl der aktuell in der Ergebnismenge befindlichen Zeilen
    \item {\\$completed} TRUE, wenn keine weiteren Zeilen in der Ergebnismenge vorhanden sind
    \item {\\$prefetch} TRUE, wenn Daten über den Prefetch-Mechanismus abgerufen werden
    \item {\\$bulk_read} Die Anzahl der gleichzeitig vom DBMS abzurufenden Zeilen
    \item {\\$bulk_write} Die Anzahl der gleichzeitig in das DBMS zu schreibenden Zeilen
    \item {\\$fields} Informationen zu den einzelnen Spalten in der Ergebnismenge finden Sie
                     unter: \code{dbColumnInfo}
  }
  Die \\pkg{ROracle}-Methode \code{dbColumnInfo} stellt folgende Details
  zu den einzelnen Spalten in der Ergebnismenge bereit:
  \itemize{
    \item {\\$name} Der Name der Spalte
    \item {\\$Sclass} Der R-Typ des Objekts mit den von
                     Oracle RDBMS zurückgegebenen Daten
    \item {\\$type} Der Typ der in Oracle RDBMS erstellten Spalte
    \item {\\$len} Länge der Spalten vom Typ VARCHAR, CHAR und RAW in Oracle RDBMS.
                  Alle anderen Spalten haben die Länge "NA".
    \item {\\$precision} Die Gesamtstellenzahl der Spalte
    \item {\\$scale} Die Anzahl der Nachkommastellen für die Spalte
    \item {\\$nullOK} TRUE, wenn ein NULL-Wert in der Spalte vorhanden sein darf
  }
   Im nachstehenden Beispiel werden Informationen zu Treiber, Verbindung, Ergebnismenge und
   Spalte in einer Tabelle angezeigt, die Folgendes enthält:
 \\preformatted{
   create table foo(
     a number(21),
     b number,
     c char(20),
     d varchar(300),
     e binary_double,
     f binary_float,
     g clob,
     h blob,
     i bfile,
     j date,
     m timestamp,
     n timestamp with time zone,
     o timestamp with local time zone,
     r interval day to second,
     s raw(234)
   );
 }
\\preformatted{   library(ROracle)
Erforderliches Package wird geladen: DBI
> # ROracle-Treiberobjekt instanziierendriver object
> drv <- Oracle()
> con <- dbConnect(drv, "scott", "tiger")
> rs <- dbSendQuery(con, "select * from foo")
> dbGetInfo(drv)
$driverName
[1] "Oracle (OCI)"
$driverVersion
[1] "1.1-12"
$clientVersion
[1] "11.2.0.4.0"
$conTotal
[1] 1
$conOpen
[1] 1
$interruptible
[1] FALSE
$unicode_as_utf8
[1] TRUE
$ora_attributes
[1] TRUE
$connections
$connections[[1]]
Benutzername:             scott 
Verbindungszeichenfolge:         
Serverversion:        11.2.0.4.0 
Servertyp:           Oracle RDBMS 
Verarbeitete Ergebnisse:     1 
OCI-Prefetch:          FALSE 
Bulklesevorgänge:             1000 
Bulkschreibvorgänge:            1000 
Anweisungscachegröße:  0 
Offene Ergebnisse:          1 
> dbGetInfo(con)
$username
[1] "scott"
$dbname
[1] ""
$serverVersion
[1] "11.2.0.4.0"
$serverType
[1] "Oracle RDBMS"
$resTotal
[1] 1
$resOpen
[1] 1
$prefetch
[1] FALSE
$bulk_read
[1] 1000
$bulk_write
[1] 1000
$stmt_cache
[1] 0
$results
$results[[1]]
Anweisung:            select * from foo 
Betroffene Zeilen:        0 
Anzahl Zeilen:            0 
SELECT-Anweisung:     TRUE 
Anweisung abgeschlossen:  FALSE 
OCI-Prefetch:         FALSE 
Bulklesevorgänge:            1000 
Bulkschreibvorgänge:           1000 
> dbGetInfo(rs)
$statement
[1] "select * from foo"
$isSelect
[1] TRUE
$rowsAffected
[1] 0
$rowCount
[1] 0
$completed
[1] FALSE
$prefetch
[1] FALSE
$bulk_read
[1] 1000
$bulk_write
[1] 1000
$fields
   name    Sclass                           type len precision scale nullOK
1     A   numeric                         NUMBER  NA        21     0   TRUE
2     B   numeric                         NUMBER  NA         0  -127   TRUE
3     C character                           CHAR  20         0     0   TRUE
4     D character                       VARCHAR2 300         0     0   TRUE
5     E   numeric                  BINARY_DOUBLE  NA         0     0   TRUE
6     F   numeric                   BINARY_FLOAT  NA         0     0   TRUE
7     G character                           CLOB  NA         0     0   TRUE
8     H       raw                           BLOB  NA         0     0   TRUE
9     I       raw                          BFILE  NA         0     0   TRUE
10    J   POSIXct                           DATE  NA         0     0   TRUE
11    M   POSIXct                      TIMESTAMP  NA         0     6   TRUE
12    N   POSIXct       TIMESTAMP WITH TIME ZONE  NA         0     6   TRUE
13    O   POSIXct TIMESTAMP WITH LOCAL TIME ZONE  NA         0     6   TRUE
14    R  difftime         INTERVAL DAY TO SECOND  NA         2     6   TRUE
15    S       raw                            RAW 234         0     0   TRUE
   }
}
\value{
Informationen zum Treiber-, Verbindungs- oder Ergebnismengenobjekt.
}
\section{References}{
  For the Oracle Database documentaion see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
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
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")

    rs <- dbSendQuery(con, "select * from emp")

    # Get the SQL statement for the result set object rs
    dbGetStatement(rs)

    # Are there any more rows in result set?
    dbHasCompleted(rs)

    # Information about columns in result set rs object
    dbColumnInfo(rs)

    # DBIDriver info
    names(dbGetInfo(drv))

    # DBIConnection info
    names(dbGetInfo(con))

    # DBIResult info
    names(dbGetInfo(rs)) 
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
