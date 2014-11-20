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
Queste funzioni simulano le funzioni R corrispondenti 
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} e 
  \code{names},
  tranne per il fatto che generano codice che viene eseguito in remoto in un motore
  di database.
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
Oggetto di connessione al database \code{OraConnection}.
}
  \item{name}{
Stringa di caratteri con distinzione tra maiuscole e minuscole che specifica un nome di tabella.
}
  \item{schema}{
Stringa di caratteri con distinzione tra maiuscole e minuscole che specifica un nome di schema
    (o un vettore di stringhe di caratteri per \code{dbListTables}).
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
I nomi delle tabelle, degli schemi e delle colonne distinguono tra maiuscole
  e minuscole: i nomi di tabella \code{ABC} e \code{abc}, ad esempio, non sono uguali.
  Tutti i nomi degli oggetti dello schema di database non devono includere
  virgolette poiché vengono racchiusi tra virgolette quando viene generata
   l'istruzione SQL corrispondente. I metodi \\pkg{ROracle} quali \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} e \code{dbWriteTable} utilizzano il mapping seguente 
  tra i tipi di dati \R e Oracle:
  \itemize{
    \item \code{logical} e \code{integer} vengono mappati a Oracle \code{INTEGER}
    \item \code{numeric} viene mappato a Oracle \code{NUMBER} se l'argomento
    \code{ora.number} è \code{TRUE} o a Oracle \code{BINARY_DOUBLE} se
    \code{FALSE}
    \item \code{character} viene mappato a Oracle \code{VARCHAR2(4000)}
    \item \code{Date} e \code{POSIXct} vengono mappati a Oracle \code{DATE}
    \\pkg{ROracle} - il package ROracle
    \R - l'applicazione R
    \code{POSIXct} - la classe POSIXct
    \code{TIMESTAMP}
    \code{TIMESTAMP WITH TIME ZONE}
    \code{TIMESTAMP WITH LOCAL TIME ZONE}
    \item \code{difftime} viene mappato a Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} dei vettori \code{raw} vengono mappati a Oracle \code{RAW(2000)}
    \item Altri tipi \R, quale ad esempio \code{factor}, vengono convertiti in
    \code{character}
  }
   ROracle restituisce i valori delle colonne di database dei tipi di dati seguenti: data,
   indicatore orario, indicatore orario con fuso orario e indicatore orario con fuso
   orario locale nel formato POSIXct di R. POSIXct fa riferimento a un valore di
   tempo memorizzato internamente sotto forma di numero di secondi dall'inizio
   del 1970 nel formato dell'ora UTC. Il numero di secondi viene scambiato da R
   e dal driver ROracle nel formato a virgola mobile doppia. Nella rappresentazione
   POSIXct R usa la variabile di ambiente TZ o mappa la variabile di ambiente del
   fuso orario del sistema operativo alla propria, pertanto la data viene visualizzata
   in questo formato di fuso orario. È possibile inserire nelle colonne i dati dei 4 tipi
   indicati in precedenza usando una stringa con il formato corretto o la rappresentazione
   POSIXct. I dati della stringa vengono passati in modo diretto al database e ROracle fa
   affidamento sul database per la conversione dei dati nella rappresentazione di data e ora.
   I dati POSIXct vengono convertiti nel descrittore DateTime interno Oracle mediante l'aggiunta
   del valore iniziale del 1970 UTC al numero di secondi ottenuto da R. Le eventuali variabili
   POSIXct nell'istruzione di inserimento vengono associate come SQLT_TIMESTAMP_TZ.
   Quando vengono selezionati da Oracle, questi tipi di dati vengono convertiti nel formato
   POSIXct sottraendo l'inizio della data 1970 UTC. Quando il client e il database ROracle
   hanno file della versione del fuso orario diversi e un'applicazione utilizza i tipi di dati
   del fuso orario, è opportuno che i tipi siano uguali, in quanto il fuso orario dell'area
   potrebbe essere stato modificato. ROracle segnala un errore in questa situazione in
   quanto i dati potrebbero risultare danneggiati o potrebbe verificarsi una perdita di
   informazioni durante l'utilizzo di questi tipi di dati.
   Le colonne con i tipi di dati data e indicatore orario vengono recuperate da
   ROracle mediante il tipo di dati SQLT_TIMESTAMP. Le colonne con i tipi di dati
   indicatore orario con fuso orario e indicatore orario con fuso orario locale vengono
   recuperate mediante il tipo di dati SQLT_TIMESTAMP_TZ. Le colonne con il tipo di
   dati indicatore orario con fuso orario locale vengono convertite nel fuso orario della
   sessione in cui viene eseguita l'applicazione R, pertanto l'impostazione della variabile
   di ambiente TZ in R avrà effetto sui valori dei dati in queste colonne. Il driver ROracle
   non mappa la variabile di ambiente TZ al fuso orario della sessione e non esegue un DDL
   di modifica per impostare il fuso orario della sessione. Per recuperare i dati dalle colonne
   con i tipi di dati indicatore orario con fuso orario e indicatore orario con fuso orario locale,
   è necessario che il client e il server abbiano gli stessi dati di fuso orario, altrimenti verrà
   segnalato un errore.
   L'esempio seguente illustra gli effetti della modifica del fuso orario nell'ambiente R:
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
  corrente e dei dati che inserisce, ovvero funge da istruzione DDL
  anche se aggiunge le righe a una tabella già esistente.
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
