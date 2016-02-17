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
Diese Funktionen imitieren die entsprechenden R-Funktionen, jedoch mit der Ausnahme,
dass sie einen Code generieren, der in einer Datenbank-Engine remote ausgeführt wird:
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} und
  \code{names}.
}
\usage{
\S4method{dbReadTable}{OraConnection,character}(conn, name, schema = NULL, row.names = NULL, ...)
\S4method{dbWriteTable}{OraConnection,character,data.frame}(conn, name, value, row.names = FALSE, overwrite = FALSE,
             append = FALSE, ora.number = TRUE, schema = NULL, date = FALSE, ...)
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
  \item{date}{
Ein boolesches Kennzeichen, das angibt, ob "date" oder "DateTimep" verwendet werden soll.
    Standardmäßig wird "DateTime" anstelle von "timestamp" verwendet.
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
Bei Tabellen-, Schema- und Spaltennamen ist die Groß-/Kleinschreibung zu beachten.
  Beispiel: Die Tabellennamen \code{ABC} und \code{abc} sind nicht identisch. Alle Objektnamen von
  Datenbankschemas dürfen keine doppelten Anführungszeichen enthalten, da sie bei
  Erstellung der entsprechenden SQL-Anweisung in doppelte Anführungszeichen gesetzt werden.
   Die folgenden Attribute dienen der korrekten Zuordnung der Spalten BLOB, CLOB, NCLOB, NCHAR, VARCHAR2,
   NVARCHAR2, CHAR, TIMESTAMP WITH TIME ZONE und TIMESTAMP WITH LOCAL TIME ZONE
   in \code{dbWriteTable}:
   1) Attributname: \code{ora.type}
   Dieses Attribut gibt den Typ der zugrunde liegenden Spalte an und kann
   "CLOB", "BLOB", "CHAR", "VARCHAR2" oder "RAW" sein. Der Benutzer kann
   TIMESTAMP, DATE, TIMESTAMP WITH TIME ZONE oder einen beliebigen anderen Spaltentyp angeben,
   der von Oracle Database unterstützt wird. ROracle parst den Wert nicht, sondern er wird
   von der Datenbank validiert. Der Benutzer kann einen der folgenden Werte
   für \code{ora.type} angeben: CLOB, BLOB, CHAR, TIMESTAMP WITH TIME
   ZONE, TIMESTAMP WITH LOCAL TIME ZONE und fractional_seconds_precision.
   2) Attributname: \code{ora.encoding}
   Wird UTF-8 angegeben, verwendet die Datenbank NCLOB, NCHAR oder NVARCHAR,
   basierend auf \code{ora.type}.
   3) Attributname: \code{ora.maxlength}
   Sie können die maximale Länge der Spalten CHAR, VARCHAR, NCHAR, NVARCHAR2 oder
   RAW angeben. Bei anderen Datentypen gilt \code{ora.maxlength} nicht
   und wird ignoriert. Die folgenden Standardwerte werden für
   bestimmte Datentypen verwendet, wenn \code{ora.maxlength} nicht angegeben wird.
   CHAR                                       2000
   NCHAR                                      1000
   VARCHAR2                                   4000
   NVARCHAR2                                  2000
   RAW                                        2000
   4) Attributname: \code{ora.fractional_seconds_precision}
   Sie können die Bruchzahlen des ZWEITEN Datum/Uhrzeit-Felds der
   Spalten TIMESTAMP, TIMESTAMP WITH TIME ZONE und TIMESTAMP WITH LOCAL TIME ZONE
   angeben. Dies kann eine Zahl zwischen 0 und 9 sein. Standardwert ist 6.
  \\pkg{ROracle}-Methoden wie \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} und \code{dbWriteTable} verwenden folgende Zuordnungen
  zwischen \R- und Oracle-Datentypen:
  \itemize{
    \item \code{logical} und \code{integer} werden Oracle \code{INTEGER} zugeordnet
    \item \code{numeric} wird Oracle \code{NUMBER} zugeordnet, wenn das Argument
    \code{ora.number} gleich \code{TRUE} oder Oracle \code{BINARY_DOUBLE} ist, wenn
    \code{FALSE}
    \item \code{character} wird Oracle \code{CLOB} zugeordnet, wenn das Attribut 
    \code{ora.type} gleich \code{"CLOB"} ist, oder Oracle \code{NCLOB}, wenn das Attribut
    \code{ora.type} gleich \code{"CLOB"} und wenn \code{ora.encoding} gleich \code{"UTF-8"} ist,
    oder Oracle \code{CHAR(ora.maxlength)}, wenn das Attribut
    \code{ora.type} gleich \code{"CHAR"} ist, oder Oracle \code{NCHAR(ora.maxlength)}, wenn das 
    Attribut \code{ora.type} gleich \code{"CHAR"} und wenn \code{ora.encoding} gleich \code{"UTF-8"} ist,
    oder Oracle \code{NVARCHAR2(ora.maxlength)}, wenn das Attribut
    \code{ora.encoding} gleich \code{"UTF-8"} ist, oder Oracle \code{VARCHAR2(ora.maxlength)}
    \item \code{Date} und \code{POSIXct} werden Oracle \code{DATE} zugeordnet
    \\pkg{ROracle} - das ROracle-Package
    \R - die R-Anwendung
    \item \code{POSIXct} wird Oracle 
    \code{TIMESTAMP WITH TIME ZONE(ora.fractional_seconds_precision)} zugeordnet, wenn das 
    Attribut \code{ora.type} gleich \code{"TIMESTAMP WITH TIME ZONE"} ist, oder Oracle 
    \code{TIMESTAMP WITH LOCAL TIME ZONE(ora.fractional_seconds_precision)}, wenn das
    Attribut \code{ora.type} gleich \code{"TIMESTAMP WITH LOCAL TIME ZONE"} oder
    Oracle \code{TIMESTAMP(ora.fractional_seconds_precision)} und wenn 
    \code{Date} gleich \code{FALSE} ist
    \item \code{difftime} wird Oracle \code{INTERVAL DAY TO SECOND} zugeordnet
    \item \code{list} von \code{raw} Vektoren werden Oracle \code{BLOB} zugeordnet, wenn das 
    Attribut \code{ora.type} gleich \code{"BLOB"} ist, oder Oracle 
    \code{RAW(ora.maxlength)}
    \item andere \R-Typen wie \code{factor} werden in
    \code{character} umgewandelt
  }
   ROracle gibt Werte aus Datenbankspalten vom Datentyp Datum,
   Zeitstempel, Zeitstempel mit Zeitzone und Zeitstempel mit lokaler Zeitzone
   im POSIXct-Format von R zurück. POSIXct bezieht sich auf eine
   Uhrzeit, die intern als Anzahl Sekunden seit Beginn des Jahres 1970 als UTC gespeichert ist.
   Die Anzahl Sekunden wird vom R- und ROracle-Treiber in eine Gleitkommazahl
   mit doppelter Genauigkeit umgewandelt. In der POSIXct-Darstellung verwendet R die
   TZ-Umgebungsvariable oder ordnet die BS-Zeitzonenumgebungsvariable der eigenen
   Variablen zu. Das Datum wird daher in diesem Zeitzonenformat angezeigt.
   Sie können Daten der vier oben genannten Datentypen
   unter Verwendung einer Zeichenfolge des richtigen Formats oder der POSIXct-Darstellung in Spalten einfügen.
   Zeichenfolgedaten werden direkt an die Datenbank übergeben, und ROracle ist auf die Datenbank angewiesen, dass diese
   die Daten in eine Datum/Uhrzeit-Darstellung konvertiert. Der ROracle-Treiber konvertiert die POSIXct-
   Darstellung in eine Zeichenfolge des Formats
   "\%Y-\%m-\%d \%H:\%M:\%OS6" in einem Datenframe, der für DML-Vorgänge verwendet wird.
   Daten in diesem Format entsprechen dem NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF" und werden in SQLT_TIMESTAMP_LTZ konvertiert, um
   an die Oracle-Datenbank gebunden zu werden. Es wird eine Zwischenklasse "datetime" erstellt,
   die dem ROracle-Treiber intern als Zeichendaten dargestellt wird.
   Spalten mit Daten des Typs Datum und Zeitstempel werden von ROracle mit dem
   Datentyp SQLT_TIMESTAMP abgerufen. Spalten mit Daten des Typs Zeitstempel mit Zeitzone
   oder Zeitstempel mit lokaler Zeitzone werden mit dem
   Datentyp SQLT_TIMESTAMP_LTZ abgerufen. Spalten mit Daten des Typs Zeitstempel mit lokaler
   Zeitzone werden in die Zeitzone der Session konvertiert, in der die R-Anwendung ausgeführt wird,
   daher hat die Einstellung der Zeitzonenumgebung TZ in R Auswirkungen auf die Datenwerte
   in dieser Spalte. Der ROracle-Treiber ordnet die TZ-Umgebungsvariable der
   Sessionzeitzone zu und gibt eine alternative DDL zur Einstellung der Sessionzeitzone aus,
   wenn die Verbindung zur Datenbank hergestellt wird.
   Um Daten aus Spalten mit Zeitstempel mit Zeitzone oder Zeitstempel
   mit lokaler Zeitzone abzurufen, müssen Client und Server dieselbe Zeitzonendatendatei haben,
   andernfalls wird ein Fehler gemeldet.
   Werden diese Datentypen aus der Datenbank gewählt, werden sie
   in R in eine Zeichenfolgedarstellung des Formats NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF" konvertiert, das "\%Y-\%m-\%d \%H:\%M:\%OS6" entspricht.
   Eine Zwischenklasse "datetime" wird erstellt,
   um diese Zeichendaten im ROracle-Treiber darzustellen. Der ROracle-Treiber konvertiert diese Daten dann
   mittels der as.POSIXct()-Funktion in POSIXct. In einer R-Anwendung
   werden diese Daten im POSIXct-Format im Datenframe dargestellt.
   \\preformatted{
R-Sessionzeitzone:
 R hat das Konzept einer Zeitzone, in der die R-Engine ausgeführt wird. Die
 Zeitzone kann auf eine Zeichenfolge wie "PST8PDT", "America/Los_Angeles" usw. gesetzt werden.
 Diese Zeichenfolgen sind selbsterklärend und geben die Zeitzone an, in der die
 Session ausgeführt wird.
 Die Zeitzone der R-Session kann auf zwei Arten eingestellt werden:
 1. Durch Eingabe folgender Daten in der Linux- oder Unix-Befehlszeile vor dem Start von
    R:
    setenv TZ = America/Los_Angeles unter Linux/UNIX
    HINWEIS: Verwenden Sie diese Option nicht unter Windows, da dieses BS 
          keine mit Oracle kompatiblen Zeitzonennamen für die Umgebungsvariable TZ zulässt.
 2. Durch Eingabe der folgenden Daten an der R-Eingabeaufforderung:
    Sys.setenv(TZ = "PST8PDT")
 Es wird empfohlen, die Option 2 zu verwenden, da das R-Skript ohne
 Portierungsprobleme unter Linux/Unix und unter Windows arbeitet. Option 2 erlaubt zudem,
 Oracle-kompatible Zeitzonennamen auch unter Windows anzugeben.
 Die Zeitzone der R-Session bestimmt die Zeitzone für alle nicht qualifizierten Datum/Uhrzeittypen
 für POSIXct-Zeitzonen. Sie ist auch die Zeitzone, in die alle
 qualifizierten Datum/Uhrzeittypen konvertiert werden, wenn sie von R angezeigt werden.
 Dies zeigt das folgende Beispiel.
 Sys.setenv(TZ = "PST8PDT")
 dt <- c(as.POSIXct("2010/3/13", tz = "PST8PDT"),
         as.POSIXct("2010/3/13 3:47:30.123456", tz = "PST8PDT"),
         as.POSIXct("2010/3/22", tz = "PST8PDT"),
         as.POSIXct("2010/3/22 7:02:30", tz = "PST8PDT"),
         as.POSIXct("2010/3/13"),
         as.POSIXct("2010/3/13 3:47:30.123456"),
         as.POSIXct("2010/3/22"),
         as.POSIXct("2010/3/22 7:02:30"))
 dt
 [1] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
 [3] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
 [5] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
 [7] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
Beachten Sie, dass für die nicht qualifizierten Zeitstempel angenommen wird, dass
sie in der Zeitzone der R-Session liegen, wenn sie von R angezeigt werden.
Anhand des US-Sommerzeitbeginns kann R erkennen, ob die Zeit in PST oder PDT liegt,
und zeigt entsprechend PST oder PDT
an.
Das folgende Beispiel macht dies noch deutlicher.
> Sys.setenv(TZ = "EST5EDT")
> dt <- c(as.POSIXct("2010/3/13", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13 3:47:30.123456", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22 7:02:30", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13"),
+         as.POSIXct("2010/3/13 3:47:30.123456"),
+         as.POSIXct("2010/3/22"),
+         as.POSIXct("2010/3/22 7:02:30"))
> dt
[1] "2010-03-13 03:00:00.000000 EST" "2010-03-13 06:47:30.123456 EST"
[3] "2010-03-22 03:00:00.000000 EDT" "2010-03-22 10:02:30.000000 EDT"
[5] "2010-03-13 00:00:00.000000 EST" "2010-03-13 03:47:30.123456 EST"
[7] "2010-03-22 00:00:00.000000 EDT" "2010-03-22 07:02:30.000000 EDT"
Beachten Sie, dass von allen nicht qualifizierten Zeitstempeln der Zeitzone angenommen wird,
dass sie in der Zeitzone der Session liegen. Auch die qualifizierten Zeitstempel der Zeitzone
werden jedoch in die Sessionzeitzone konvertiert und in dieser angezeigt. Beachten Sie, dass alle
Werte von R in der Zeitzone der R-Session angezeigt werden (der
Zeitzonenname wird auch in EST oder EDT geändert, um ggf. die
Sommerzeit zu berücksichtigen). Informationen zu Datum/Uhrzeitklassen finden Sie unter
http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html
und zu Zeitzonen unter
http://stat.ethz.ch/R-manual/R-devel/library/base/html/timezones.html
(Details dazu, wie Datum, Uhrzeit und Zeitzonen in R behandelt werden)
Im Folgenden finden Sie ein Beispiel mit längerem Zeitzonennamen
(oft auch "Olson-Name" genannt) als Gegenstück zu einer Abkürzung.
> Sys.setenv(TZ = "America/Los_Angeles")
> dt <- c(as.POSIXct("2010/3/13", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13 3:47:30.123456", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22 7:02:30", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13"),
+         as.POSIXct("2010/3/13 3:47:30.123456"),
+         as.POSIXct("2010/3/22"),
+         as.POSIXct("2010/3/22 7:02:30"))
> dt
[1] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
[3] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
[5] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
[7] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
Beachten Sie, dass R in diesem Fall nicht den langen Namen verwendet, wenn die
Werte angezeigt werden, sondern die Werte immer noch
mit den Abkürzungen "PST" und "PDT" anzeigt. Dies ist bedeutsam, da Oracle
diese Abkürzungen nicht uneingeschränkt unterstützt. Beispiel: Eine Oracle-
Datenbank erkennt "PDT" nicht als gültige Zeitzone. Weitere Details zu gültigen Zeitzonen finden Sie unter
"R Time zone and Oracle session time zone".
}
   Das Beispiel unten zeigt die Auswirkungen einer Änderung der Zeitzone in der
   R-Umgebung:
   \\preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # Daten auswählen und anzeigen
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
  Auch \code{dbWriteTable} schreibt immer eine aktuelle Transaktion sowie
  die eingefügten Daten fest und fungiert somit als DDL-Anweisung,
  selbst wenn Zeilen an eine bereits bestehende Tabelle angehängt werden.
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
  \url{http://docs.oracle.com/cd/E11882_01/server.112/e10729/ch4datetime.htm}.
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

    # Example of POSIXct usage.
    # A table is created using:
    createTab <- "create table RORACLE_TEST(row_num number, id1 date,
                 id2 timestamp, id3 timestamp with time zone, 
                 id4 timestamp with local time zone )"

    dbGetQuery(con, createTab)
    # Insert statement.
    insStr <- "insert into RORACLE_TEST values(:1, :2, :3, :4, :5)";

    # Select statement.
    selStr <- "select * from RORACLE_TEST";

    # Insert time stamp without time values in POSIXct form.
    x <- 1; 
    y <- "2012-06-05";
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    # Insert date & times stamp with time values in POSIXct form.
    x <- 2;
    y <- "2012-01-05 07:15:02";
    y <- as.POSIXct(y);
    z <- "2012-01-05 07:15:03.123";
    z <- as.POSIXct(z);
    dbGetQuery(con, insStr, data.frame(x, y, z,  z, z));

    # Insert list of date objects in POSIXct form.
    x <- c(3, 4, 5, 6);
    y <- c('2012-01-05', '2011-01-05', '2013-01-05', '2020-01-05');
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    dbCommit (con)

    # Selecting data and displaying it.
    res <- dbGetQuery(con, selStr)
    res[,1]
    res[,2]
    res[,3]
    res[,4]
    res[,5]

    # insert data in Date format
    a<-as.Date("2014-01-01")
    dbWriteTable(con, 'TEMP', data.frame(a), date = TRUE)

    # using attribute to map NCHAR, CLOB, BLOB, NCLOB columns correctly in 
    # dbWriteTable
    str1 <- paste(letters, collapse="")
    lstr1 <- paste(rep(str1, 200), collapse="")
    raw.lst <- vector("list",1)
    lraw.lst <- vector("list",1)
    raw.lst[[1L]] <- charToRaw(str1)
    lraw.lst[[1L]] <- rep(charToRaw(str1), 200)
    a <- as.POSIXct("2014-01-01 14:12:09.0194733")
    b <- as.POSIXct("2014-01-01 14:12:09.01947")
    test.df <- data.frame(char=str1, nchar=str1, varchar=str1, clob=lstr1,
                      nclob=lstr1, stringsAsFactors=FALSE)
    test.df$raw.typ <- raw.lst
    test.df$blob <- lraw.lst
    test.df$char_max <- str1 
    test.df$raw_max.typ <- raw.lst
    test.df$nvchar <- str1
    test.df$nvchar_max <- str1
    test.df$date_tz <- a
    test.df$date_ltz <- b

    # adding attributes
    attr(test.df$clob, "ora.type") <- "CLOB"
    attr(test.df$blob, "ora.type") <- "BLOB"
    attr(test.df$nclob, "ora.type") <- "CLOB"
    attr(test.df$nclob, "ora.encoding") <- "UTF-8"
    attr(test.df$char_max, "ora.maxlength") <- 3000
    attr(test.df$raw_max.typ, "ora.maxlength") <- 1000
    attr(test.df$nvchar, "ora.encoding") <- "UTF-8"
    attr(test.df$nvchar_max, "ora.encoding") <- "UTF-8"
    attr(test.df$nvchar_max, "ora.maxlength") <- 1500
    attr(test.df$char, "ora.type") <- "CHAR"
    attr(test.df$date_tz, "ora.type") <- "timestamp with time zone"
    attr(test.df$date_ltz, "ora.type") <- "timestamp with local time zone"
    attr(test.df$nchar, "ora.type") <- "CHAR"
    attr(test.df$nchar, "ora.encoding") <- "UTF-8"
    attr(test.df$date_tz, "ora.fractional_seconds_precision") <- 9
R> # displaying the data frame
R> test.df
char                         nchar
1 abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz
varchar
1 abcdefghijklmnopqrstuvwxyz
clob
1 abcdefghijklmnopqrstuvwxyz...
nclob
1 abcdefghijklmnopqrstuvwxyz...
raw.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
blob
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a,...
char_max
1 abcdefghijklmnopqrstuvwxyz
raw_max.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
nvchar                       nvchar_max
1 abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz
date_tz                      date_ltz
1 2014-01-01 14:12:09.019473 2014-01-01 14:12:09.01946

    dbWriteTable(con, name="TEST_TAB", value=test.df)
    res <- dbReadTable(con, name="TEST_TAB")
R> res
char
1 abcdefghijklmnopqrstuvwxyz
nchar
1 abcdefghijklmnopqrstuvwxyz
varchar
1 abcdefghijklmnopqrstuvwxyz
clob
1 abcdefghijklmnopqrstuvwxyz...
nclob
1 abcdefghijklmnopqrstuvwxyz...
raw.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
blob
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a,...
char_max                                                                                           
1 abcdefghijklmnopqrstuvwxyz
raw_max.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
nvchar                       nvchar_max
1 abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz
date_tz                      date_ltz
1 2014-01-01 14:12:09.019473 2014-01-01 14:12:09.01946
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
