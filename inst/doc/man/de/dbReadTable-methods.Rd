\name{dbReadTable-methods}
\docType{methods}
\alias{dbReadTable}
\alias{dbWriteTable}
\alias{dbExistsTable}
\alias{dbRemoveTable}
\alias{dbListTables}
\alias{dbListFields}
\alias{dbReadTable,OraConnection,character-method}
\alias{dbWriteTable,OraConnection,character,data.frame-method}
\alias{dbExistsTable,OraConnection,character-method}
\alias{dbRemoveTable,OraConnection,character-method}
\alias{dbListTables,OraConnection-method}
\alias{dbListFields,OraConnection,character-method}
\title{
Praktische Funktionen für das Bearbeiten von DBMS-Tabellen
}
\description{
Diese Funktionen ahmen die entsprechenden R-Funktionen nach 
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} und
  \code{names},
  jedoch mit der Ausnahme, dass sie einen Code generieren, der in einer Datenbank-
  Engine remote ausgeführt wird.
}
\usage{
\S4method{dbReadTable}{OraConnection,character}(conn, name, schema = NULL, row.names = NULL, ...)
\S4method{dbWriteTable}{OraConnection,character,data.frame}(conn, name, value, row.names = FALSE, overwrite = FALSE,
             append = FALSE, ora.number = TRUE, schema = NULL, ...)
\S4method{dbExistsTable}{OraConnection,character}(conn, name, schema = NULL, ...)
\S4method{dbRemoveTable}{OraConnection,character}(conn, name, purge = FALSE, schema = NULL, ...)
\S4method{dbListTables}{OraConnection}(conn, schema = NULL, all = FALSE, full = FALSE, ...)
\S4method{dbListFields}{OraConnection,character}(conn, name, schema = NULL, ...)
}
\arguments{
  \item{conn}{
Ein \code{OraConnection}-Datenbankverbindungsobjekt.
}
  \item{name}{
Eine Zeichenfolge, die einen Tabellennamen angibt. Groß-/Kleinschreibung muss beachtet werden.
}
  \item{schema}{
Eine Zeichenfolge, die einen Schemanamen angibt 
    (oder ein Vektor mit Zeichenfolgen für \code{dbListTables}). Groß-/Kleinschreibung muss beachtet werden.
}

  \item{row.names}{
Bei \code{dbReadTable} kann dieses Argument eine Zeichenfolge, ein 
    Index oder ein logischer Vektor sein, der die Spalte in der DBMS-Tabelle angibt, die als
    \code{row.names} in dem Ausgabe-data.frame verwendet werden muss (\code{NULL}
    gibt an, dass keine Spalte als \code{row.names} in der Ausgabe
    verwendet werden muss). Der Standardwert ist \code{NULL}.
    Bei \code{dbWriteTable} muss dieses Argument ein logischer Wert sein, der angibt,
    ob \code{row.names} an die Ausgabe-DBMS-Tabelle ausgegeben werden
    muss; bei \code{TRUE} wird eine zusätzliche Spalte mit dem Namen \code{"row.names"} 
     zu der Ausgabe hinzugefügt. Der Standardwert ist
    \code{FALSE}.
}
  \item{value}{
\code{data.frame} mit den Daten, die in eine Tabelle geschrieben werden müssen. (Im
    Abschnitt "Details" werden die unterstützten Spaltentypen aufgeführt.)
}
  \item{overwrite}{
Ein logischer Wert, der angibt, ob eine vorhandene Tabelle überschrieben werden
    soll. Der Standardwert ist \code{FALSE}.
}
  \item{append}{
Ein logischer Wert, der angibt, ob der Wert an eine vorhandene Tabelle
    in dem DBMS angehängt werden soll. Der Standardwert ist \code{FALSE}.
}
  \item{ora.number}{
Ein logischer Wert, der angibt, ob eine Tabelle mit Oracle
    \code{NUMBER}- oder \code{BINARY_DOUBLE}-Spalten erstellt werden soll, während numerische 
    Daten geschrieben werden. Geben Sie \code{TRUE} an, um eine Tabelle mit Oracle \code{NUMBER}- 
    Werten zu erstellen, oder geben Sie \code{FALSE} an, um eine Tabelle mit Oracle
    \code{BINARY_DOUBLE}-Werten zu erstellen. Der Standardwert ist \code{TRUE}.
    Geben Sie \code{FALSE} an, wenn mindestens ein numerischer Datenwert 
    \code{NaN} ist.
}
  \item{purge}{
Ein logischer Wert, der angibt, ob die \code{PURGE}-Option zu der
    SQL-\code{DROP TABLE}-Anweisung hinzugefügt werden soll.
}
  \item{all}{
Ein logischer Wert, der angibt, ob alle Schemas geprüft werden sollen.
}
  \item{full}{
Ein logischer Wert, der angibt, ob Schemanamen generiert werden sollen. Wenn Argument
    \code{all} \code{TRUE} ist, ist die Ausgabe ein Vektor mit Schemanamen
    gefolgt von den Tabellennamen. Wenn \code{matrix(..., ncol = 2)} in der
    Ausgabe verwendet wird, wird eine Matrix erzeugt, in der jede Zeile einer
    Tabelle entspricht und in der die Spalten die Schemanamen bzw.
    Tabellennamen darstellen.
}
  \item{\dots}{
Aktuell nicht verwendet.
}
}





   


\details{
Bei Tabellen-, Schema- und Spaltennamen muss die Groß-/Kleinschreibung beachtet werden, Beispiel:
  die Tabellennamen \code{ABC} und \code{abc} sind nicht identisch. Alle Datenbankschemaobjektnamen
  dürfen keine doppelten Anführungszeichen enthalten, weil sie in doppelte Anführungszeichen
  gesetzt werden, wenn die entsprechende SQL-Anweisung generiert wird.
  \\pkg{ROracle}-Methoden wie \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} und \code{dbWriteTable} verwenden dieselbe Zuordnung
  zwischen \R- und Oracle-Datentypen:
  \itemize{
    \item \code{logical} und \code{integer} werden Oracle \code{INTEGER} zugeordnet
    \item \code{numeric} wird Oracle \code{NUMBER} zugeordnet, wenn Argument
    \code{ora.number} \code{TRUE} ist oder Oracle \code{BINARY_DOUBLE}, wenn
    \code{FALSE} ist
    \item \code{character} wird Oracle \code{VARCHAR2(4000)} zugeordnet
    \item \code{Date} und \code{POSIXct} werden Oracle \code{DATE} zugeordnet
    \\pkg{ROracle} - das ROracle-Package
    \R - die R-Anwendung
    \code{POSIXct} - die POSIXct-Klasse
    \code{TIMESTAMP}
    \code{TIMESTAMP WITH TIME ZONE}
    \code{TIMESTAMP WITH LOCAL TIME ZONE}
    \item \code{difftime} wird Oracle \code{INTERVAL DAY TO SECOND} zugeordnet
    \item \code{list} von \code{raw} Vektoren werden Oracle \code{RAW(2000)} zugeordnet
    \item andere \R-Typen wie \code{factor} werden in
    \code{character} konvertiert
  }
   ROracle gibt Werte aus Datenspalten mit folgenden Datentypen zurück: Datum,
   Zeitstempel, Zeitstempel mit Zeitzone und Zeitstempel mit lokaler Zeitzone,
   Datentypen im POSIXct-Format von R. POSIXct bezieht sich auf eine Zeit, 
   die intern als eine Anzahl von Sekunden seit dem Anfang von1970 
   in UTC gespeichert wird. Die Anzahl von Sekunden wird von R und ROracle-Treiber
   im Gleitkommadoppelformat ausgetauscht. In POSIXct verwendet die Darstellung von R 
   die TZ-Umgebungsvariable oder ordnet die BS-Zeitzonenumgebungsvariable sich selbst
   zu, deshalb wird das Datum in diesem Zeitzonenformat angezeigt.
   Daten können in Spalten der 4 oben aufgeführten Datentypen mit einer
   Zeichenfolge im korrekten Format oder der POSIXct-Darstellung eingefügt werden.
   Zeichenfolgendaten werden direkt an die Datenbank übergeben und ROracle verwendet die
   Datenbank zu deren Konvertierung in die Datumzeitdarstellung. POSIXct-Daten werden in den
   internen DateTime-Deskriptor von Oracle konvertiert, indem der Anfang von1970 UTC zu der
   Anzahl von Sekunden hinzugefügt wird, die aus R abgerufen werden. POSIXct-Variablen in Insert-
   Anweisungen werden als SQLT_TIMESTAMP_TZ gebunden.
   Wenn diese Datentypen aus Oracle gewählt werden, werden sie in das POSIXct-Format
   konvertiert, indem der Anfang von 1970 UTC subtrahiert wird. Wenn der ROracle-Client und die
   Datenbank Dateien mit unterschiedlichen Zeitzonenversionen haben und eine Anwendung die
   Zeitzonendatentypen verwendet, wird empfohlen, dass sie identisch sind, weil die Zeitzone
   der Region möglicherweise geändert wurde. ROracle meldet einen Fehler in dieser Situation, weil
   dies zu einer Beschädigung und einem Verlust der Daten führen kann, wenn diese Datentypen
   bearbeitet werden.
   Spalten mit dem Datentyp Datum und Zeitstempel werden von ROracle mit dem 
   SQLT_TIMESTAMP-Datentyp abgerufen. Spalten mit dem Datentyp Zeitstempel mit Zeitzone
   und Zeitstempel mit lokaler Zeitzone werden mit dem Datentyp 
   SQLT_TIMESTAMP_TZ abgerufen. Spalten mit dem Datentyp Zeitzone mit lokaler
   Zeitzone werden in die Sessionzeitzone konvertiert, in der die R-Anwendung ausgeführt wird.
   Die Festlegung der Zeitzonenumgebungsvariablen TZ in R wirkt sich also auf die Datenwerte
   in dieser Spalte aus. ROracle-Treiber ordnet die TZ-Umgebungsvariable der
   Sessionzeitzone nicht zu und gibt keine
   "alter DDL"-Anweisung aus, um die Sessionzeitzone festzulegen. Um Daten aus Spalten
   mit dem Datentyp Zeitstempel mit Zeitzone und Zeitstempel lokaler Zeitzone
   abzurufen, müssen Client und Server dieselbe Zeitzonendatendatei verwenden,
   sonst kommt es zu einem Fehler.
   Das folgende Beispiel zeigt, wie sich die Änderung der Zeitzone in der R-Umgebung auswirkt:
   \\preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # Auswahl von Daten und deren Anzeige
   res <- dbGetQuery(con, selStr)
   R>     res[,1]
   [1] 1 2 3 4 5 6
   R>     res[,2]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:02 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R>     res[,3]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:03 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R>     res[,4]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:03 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R>     res[,5]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:03 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R> Sys.setenv(TZ='EST5EDT')
   R>     res[,1]
   [1] 1 2 3 4 5 6
   R>     res[,2]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:02 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"
   R>     res[,3]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:03 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"
   R>     res[,4]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:03 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"
   R>     res[,5]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:03 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"}
  Außerdem speichert \code{dbWriteTable} eine aktuelle Transaktion immer automatisch genau so wie
  die Daten, die eingefügt werden, d.h. sie fungiert als DDL-Anweisung, selbst wenn 
  Zeilen an eine bereits vorhandene Tabelle angehängt werden.
}
\value{
Ein \code{data.frame} im Fall von \code{dbReadTable}; 
  ein \code{vector} im Fall von
  \code{dbListTables} und \code{dbListFields};
  ein \code{logical} im Fall von \code{dbExistsTable}, was angibt, 
  ob die Tabelle vorhanden ist;
  anderenfalls \code{TRUE}, wenn der Vorgang erfolgreich war, 
  bzw. eine Exception.
}
\section{References}{
  For the Oracle Database documentation see 
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
  For Datetime Data Types and Time Zone Support in Oracle see
  \url{http://docs.oracle.com/cd/E14072_01/server.112/e10729/ch4datetime.htm}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}}.
}
\examples{
  \dontrun{
    con <- dbConnect(Oracle(), "scott", "tiger")
    if (dbExistsTable(con, "FOO", "SCOTT"))
      dbRemoveTable(con, "FOO")

    foo <- dbReadTable(con, "EMP")
    row.names(foo) <- foo$EMPNO
    foo <- foo[,-1]

    dbWriteTable(con, "FOO", foo, row.names = TRUE)
    dbWriteTable(con, "FOO", foo, row.names = TRUE, overwrite = TRUE)
    dbReadTable(con, "FOO", row.names = 1)

    dbGetQuery(con, "delete from foo")
    dbWriteTable(con, "FOO", foo, row.names = TRUE, append = TRUE)
    dbReadTable(con, "FOO", row.names = 1)
    dbRemoveTable(con, "FOO")

    dbListTables(con)
    dbListFields(con, "EMP")

    if (dbExistsTable(con, "RORACLE_TEST", "SCOTT"))
      dbRemoveTable(con, "RORACLE_TEST")

    # example of POSIXct usage
    # A table is created using:
    createTab <- "create table RORACLE_TEST(row_num number, id1 date,
                 id2 timestamp, id3 timestamp with time zone, 
                 id4 timestamp with local time zone )"

    dbGetQuery(con, createTab)
    # Insert statement
    insStr <- "insert into RORACLE_TEST values(:1, :2, :3, :4, :5)";

    # Select statement
    selStr <- "select * from RORACLE_TEST";

    # Insert time stamp without time values in POSIXct form
    x <- 1; 
    y <- "2012-06-05";
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    # Insert date & times stamp with time values in POSIXct form
    x <- 2;
    y <- "2012-01-05 07:15:02";
    y <- as.POSIXct(y);
    z <- "2012-01-05 07:15:03.123";
    z <- as.POSIXct(z);
    dbGetQuery(con, insStr, data.frame(x, y, z,  z, z));

    # Insert list of date objects in POSIXct form
    x <- c(3, 4, 5, 6);
    y <- c('2012-01-05', '2011-01-05', '2013-01-05', '2020-01-05');
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    dbCommit (con)

    # Selecting data and displaying it
    res <- dbGetQuery(con, selStr)
    res[,1]
    res[,2]
    res[,3]
    res[,4]
    res[,5]
  }
  \dontrun{
    df <- data.frame(A=c(0,1,NaN,4), B=c(NA, 2,3,NaN))
    con <- dbConnect(Oracle(), "scott", "tiger")
    dbWriteTable(con,"TEST", df, row.names = FALSE, ora.number=FALSE)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
