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
Funzioni di convenienza per la manipolazione delle tabelle DBMS
}
\description{
Queste funzioni simulano le funzioni R corrispondenti tranne per il fatto che
  generano codice che viene eseguito in remoto in un motore  di database:
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} e
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
Oggetto di connessione al database \code{OraConnection}.
}
  \item{name}{
Stringa di caratteri con distinzione tra maiuscole e minuscole che specifica un nome di tabella.
}
  \item{schema}{
Stringa di caratteri con distinzione tra maiuscole e minuscole che specifica un nome di schema
    (o un vettore di stringhe di caratteri per \code{dbListTables}).
}
  \item{date}{
Flag booleano per indicare se usare la data o DateTime.
    Per impostazione predefinita, verrà usato DateTime invece dell'indicatore orario.
}

  \item{row.names}{
Nel caso di \code{dbReadTable}, questo argomento può essere una stringa,
    un indice o un vettore logico che specifica la colonna della tabella
    DBMS da utilizzare come \code{row.names} nel data.frame di output (\code{NULL}
    specifica che non devono essere utilizzate colonne come \code{row.names}
    nell'output). L'impostazione predefinita è \code{NULL}.
    Nel caso di \code{dbWriteTable}, questo argomento deve essere un valore
    logico che specifica se \code{row.names} deve essere restituito alla tabella
    DBMS di output; se \code{TRUE}, una colonna extra denominata
    \code{"row.names"} verrà aggiunta all'output. L'impostazione predefinita è
    \code{FALSE}.
}
  \item{value}{
\code{data.frame} che contiene i dati da scrivere in una tabella. (Vedere
    la sezione Dettagli per conoscere i tipi di colonna supportati).
}
  \item{overwrite}{
Valore logico che specifica se sovrascrivere o meno un tabella
    esistente. L'impostazione predefinita è \code{FALSE}.
}
  \item{append}{
Valore logico che specifica se aggiungere i dati a una tabella esistente
    nel sistema DBMS. L'impostazione predefinita è \code{FALSE}.
}
  \item{ora.number}{
Valore logico che specifica se creare una tabella con colonne
    \code{NUMBER} o \code{BINARY_DOUBLE} Oracle durante la scrittura dei dati numerici.
    Specificare \code{TRUE} per creare una tabella con i valori \code{NUMBER} 
    Oracle oppure specificare \code{FALSE} per creare una tabella con
    i valori \code{BINARY_DOUBLE} Oracle. Il valore predefinito è \code{TRUE}.
    Specificare \code{FALSE} se uno o più valori di dati numerici sono
    \code{NaN}.
}
  \item{purge}{
Valore logico che specifica se aggiungere l'opzione \code{PURGE}
    all'istruzione SQL \code{DROP TABLE}.
}
  \item{all}{
Valore logico che specifica se esaminare tutti gli schemi.
}
  \item{full}{
Valore logico che specifica se generare i nomi di schema. Quando
    l'argomento\code{all} è impostato su \code{TRUE}, l'output è un vettore che
    contiene nomi di schema seguiti da nomi di tabella. L'uso di \code{matrix(..., ncol = 2)}
    nell'output genera una matrice in cui ogni riga corrisponde a una
    tabella e le colonne rappresentano i nomi di schema e i nomi di
    tabella.
}
  \item{\dots}{
attualmente inutilizzato.
}
}




















\details{
I nomi tabella, schema e colonne distinguono tra maiuscole e minuscole. 
  Ad esempio, i nomi tabella \code{ABC} e \code{abc} non sono uguali. Tutti i nomi degli
  oggetti di schema del database non devono contenere le virgolette poiché
  vengono racchiusi tra virgolette quando viene generata l'istruzione SQL corrispondente.
   Per mappare in modo corretto le colonne BLOB, CLOB, NCLOB, NCHAR, VARCHAR2,
   NVARCHAR2, CHAR, TIMESTAMP WITH TIME ZONE e TIMESTAMP WITH LOCAL TIME ZONE
    in \code{dbWriteTable} vengono usati gli attributi riportati di seguito.
   1) Nome attributo: \code{ora.type}
   Questo attributo indica il tipo di colonna di base e può essere
   "CLOB", "BLOB", "CHAR", "VARCHAR2" o "RAW". L'utente può specificare
   TIMESTAMP, DATE, TIMESTAMP WITH TIME ZONE o qualsiasi altro tipi di
   colonna supportato dal database Oracle. Oracle non analizza il valore, che 
   viene convalidato dal database. L'utente può fornire uno dei valori seguenti
   per \code{ora.type}: CLOB, BLOB, CHAR, TIMESTAMP WITH TIME ZONE,
   TIMESTAMP WITH LOCAL TIME ZONE e fractional_seconds_precision.
   2) Nome attributo: \code{ora.encoding}
   Quando si specifica UTF-8, il database usa NCLOB, NCHAR o NVARCHAR
   in base a \code{ora.type}.
   3) Nome attributo: \code{ora.maxlength}
   È possibile specificare la lunghezza massima delle colonne CHAR, VARCHAR, NCHAR,
   NVARCHAR2 o RAW. \code{ora.maxlength} non si applica agli altri tipi di dati
   e viene ignorato. Quando non si specifica \code{ora.maxlength}, per certi tipi di dati
   vengono usati i valori predefiniti seguenti:
   CHAR                                       2000
   NCHAR                                      1000
   VARCHAR2                                   4000
   NVARCHAR2                                  2000
   RAW                                        2000
   4) Nome attributo: \code{ora.fractional_seconds_precision}
   È possibile specificare la parte frazionaria del campo data e ora SECOND delle colonne
   TIMESTAMP, TIMESTAMP WITH TIME ZONE e TIMESTAMP WITH LOCAL TIME ZONE.
   Può essere un numero compreso nell'intervallo da 0 a 9. Il valore predefinito è 6.
  I metodi \\pkg{ROracle} quali \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} e \code{dbWriteTable} utilizzano il mapping riportato
  di seguito tra i tipi di dati \R e Oracle:
  \itemize{
    \item \code{logical} e \code{integer} vengono mappati a Oracle \code{INTEGER}
    \item \code{numeric} viene mappato a Oracle \code{NUMBER} se l'argomento
    \code{ora.number} è \code{TRUE} oppure a Oracle \code{BINARY_DOUBLE} se è
    \code{FALSE}
    \item \code{character} viene mappato a Oracle \code{CLOB} se l'attributo 
    \code{ora.type} è \code{"CLOB"} oppure a Oracle \code{NCLOB} se l'attributo
    \code{ora.type} è \code{"CLOB"} e \code{ora.encoding} è \code{"UTF-8"}
    oppure a Oracle \code{CHAR(ora.maxlength)} se l'attributo \code{ora.type} è 
    \code{"CHAR"} oppure a Oracle \code{NCHAR(ora.maxlength)} se l'attributo 
    \code{ora.type} è \code{"CHAR"} e \code{ora.encoding} è \code{"UTF-8"}
    oppure a Oracle \code{NVARCHAR2(ora.maxlength)} se l'attributo \code{ora.encoding}
    è \code{"UTF-8"} oppure a Oracle \code{VARCHAR2(ora.maxlength)}
    \item \code{Date} e \code{POSIXct} vengono mappati a Oracle \code{DATE}
    \\pkg{ROracle} - il package ROracle
    \R - l'applicazione R
    \item \code{POSIXct} viene mappato a Oracle 
    \code{TIMESTAMP WITH TIME ZONE(ora.fractional_seconds_precision)} se 
    l'attributo \code{ora.type} è \code{"TIMESTAMP WITH TIME ZONE"} oppure a Oracle 
    \code{TIMESTAMP WITH LOCAL TIME ZONE(ora.fractional_seconds_precision)} se
    l'attributo \code{ora.type} è \code{"TIMESTAMP WITH LOCAL TIME ZONE"} oppure
    a Oracle \code{TIMESTAMP(ora.fractional_seconds_precision)} se 
    \code{Date} è \code{FALSE} 
    \item \code{difftime} viene mappato a Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} vettori su \code{raw} vengono mappati a Oracle \code{BLOB} se 
    l'attributo \code{ora.type} è \code{"BLOB"} oppure a Oracle 
    \code{RAW(ora.maxlength)}
    \item Gli altri tipi \R, quale ad esempio \code{factor}, vengono convertiti in
    \code{character}
  }
   ROracle restituisce i valori delle colonne del database dei tipi di dati seguenti:
   data, indicatore orario, indicatore orario con fuso orario e indicatore orario con
   fuso orario locale nel formato POSIXct di R. POSIXct fa riferimento a un valore
   di tempo memorizzato internamente sotto forma di numero di secondi dall'inizio
   del 1970 nel formato dell'ora UTC. Il numero di secondi viene scambiato da R e
   dal driver ROracle nel formato a virgola mobile doppia. Nella rappresentazione
   POSIXct R usa la variabile di ambiente TZ oppure mappa la variabile di ambiente
   del fuso orario del sistema operativo alla propria, pertanto la data viene visualizzata
   in questo formato di fuso orario. È possibile inserire nelle colonne i dati dei quattro tipi
   indicati in precedenza usando una stringa con il formato corretto o la rappresentazione
   POSIXct. I dati della stringa vengono passati direttamente al database e ROracle fa
   affidamento sul database per la conversione dei dati nella rappresentazione di data e ora.
   Il driver ROracle converte la rappresentazione POSIXct in una rappresentazione di stringa
   mediante il formato "\%Y-\%m-\%d \%H:\%M:\%OS6" di un data frame usato per le operazioni DML.
   I dati in questo formato corrispondono a NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF" e vengono convertiti in SQLT_TIMESTAMP_LTZ per essere
   associati al database Oracle. Viene creata una classe intermedia "datetime" che
   rappresenta internamente i dati dei caratteri nel driver ROracle.
   Le colonne con il tipo di dati data e indicatore orario vengono recuperate da ROracle mediante
   il tipo di dati SQLT_TIMESTAMP. Le colonne con il tipo di dati indicatore orario con fuso orario
   o indicatore orario con fuso orario locale vengono recuperate mediante il tipo di dati
   SQLT_TIMESTAMP_LTZ. Le colonne con il tipo di dati indicatore orario con fuso orario locale
   vengono convertite nel fuso orario della sessione in cui viene eseguita l'applicazione R,
   pertanto l'impostazione della variabile TZ del fuso orario in R avrà effetto sui valori dei
   dati in questa colonna. Il driver ROracle mappa la variabile di ambiente TZ al fuso orario
   della sessione ed esegue una DDL di modifica per impostare il fuso orario della sessione
   quando viene stabilita la connessione al database.
   Per recuperare i dati dalle colonne con tipo di dati indicatore orario con fuso orario o
   indicatore orario con fuso orario locale, è necessario che il client e il server abbiano
   lo stesso file di dati di fuso orario, altrimenti verrà segnalato un errore.
   Quando vengono selezionati dal database, questi tipi di dati vengono convertiti in
   rappresentazione di stringa mediate NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF" che corrisponde a "\%Y-\%m-\%d \%H:\%M:\%OS6"
   in R. Viene creata una classe intermedia "datetime" per rappresentare questi dati
   dei caratteri nel driver ROracle, che successivamente provvede a convertirli nel
   formato POSIXct mediante la funzione as.POSIXct(). Un'applicazione R visualizza
   i dati nel formato POSIXct nel data frame.
   \\preformatted{
Fuso orario della sessione R:
 il fuso orario in R corrisponde a quello in cui è in funzione il motore R. Il fuso orario
 può essere impostato su una stringa, ad esempio 'PST8PDT', 'America/Los_Angeles' e così via.
 Queste stringhe sono auto-esplicative e specificano il fuso orario in cui è
 operativa la sessione.
 Il fuso orario della sessione R può essere impostato in uno dei due modi seguenti:
 1. Immettendo quanto riportato di seguito nella riga di comando Linux o Unix
    prima di avviare R:
    setenv TZ = America/Los_Angeles on Linux/UNIX
    NOTA: non usare questa opzione in Windows poiché non consente di impostare
          i nomi di fuso orario compatibili con Oracle per la variabile di ambiente TZ.
 2. Immettendo quanto riportato di seguito al prompt di R:
    Sys.setenv(TZ = "PST8PDT")
 Si consiglia di usare l'opzione 2 poiché lo script R funziona senza problemi di
 trasferimento in Linux/Unix come anche in Windows. L'opzione 2 consente inoltre
 di specificare i nomi di fuso orario compatibili con Oracle anche in Windows.
 Il fuso orario della sessione R determina il fuso orario per tutti i tipi di dati 
 data-ora non qualificati del fuso orario POSIXct. È inoltre il fuso orario in cui
 vengono convertiti i tipi di dati data-ora qualificati quando vengono visualizzati.
 da R. Ciò viene dimostrato nell'esempio riportato di seguito.
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
Si suppone che anche gli indicatori orari non qualificati siano nel fuso
orario della sessione quando vengono visualizzati da R. Naturalmente
R è anche in grado di determinare se l'orario rientra in PST o PDT in
base all'inizio dell'ora legale e visualizza PST o PDT
di conseguenza.
Nell'esempio riportato di seguito questo aspetto risulta più chiaro.
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
Si suppone che tutti gli indicatori orari non qualificati di fuso orario siano nel
fuso orario della sessione. Anche gli indicatori orari qualificati di fuso orario
vengono tuttavia convertiti nel fuso orario della sessione e visualizzati.
Tenere presente che tutti i valori vengono visualizzati da R nel fuso orario
della sessione R (dove anche il nome del fuso orario viene modificato in EST
o EDT per tenere conto dell'ora legale, se applicabile). Vedere le classi Date-Time
in http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html
e ai fusi orari in
http://stat.ethz.ch/R-manual/R-devel/library/base/html/timezones.html
per i dettagli sulle modalità di gestione di data, ora e fuso orario da parte di R.
Nell'esempio riportato di seguito viene utilizzato un nome di fuso orario più lungo
(spesso definito 'Olson') invece di un'abbreviazione.
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
In casi del genere R non utilizza il nome lungo per la visualizzazione
dei valori, ma continua a visualizzare i valori utilizzando le abbreviazioni
"PST" e "PDT". Ciò è significativo perché queste abbreviazioni si rivelano
inadeguate in Oracle. Un database Oracle, ad esempio, non riconosce
"PDT" come fuso orario valido. Per informazioni dettagliate sui fusi orari
validi, vedere "Fuso orario R e fuso orario della sessione Oracle".
}
   Nell'esempio riportato di seguito viene mostrato l'effetto della modifica
   del fuso orario nell'ambiente R.
   \\preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # Selezione e visualizzazione dei dati
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
  Inoltre \code{dbWriteTable} esegue sempre il commit automatico della transazione
  corrente e dei dati che inserisce, ovvero funge da istruzione DDL anche
  se aggiunge righe a una tabella esistente.
}
\value{
\code{data.frame} nel caso di \code{dbReadTable};
  \code{vector} nel caso di \code{dbListTables} e
  \code{dbListFields};
  \code{logical} nel caso di \code{dbExistsTable} per indicare
  se la tabella esiste,
  altrimenti \code{TRUE} quando l'operazione riesce o
  viene restituita un'eccezione.
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
