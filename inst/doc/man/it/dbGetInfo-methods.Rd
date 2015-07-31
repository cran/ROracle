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
Metadati DBI
}
\description{
Questi metodi sono implementazioni semplici delle corrispondenti
   funzioni generiche.
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
Qualsiasi oggetto che implementi alcune funzionalità dell'interfaccia
    R nei database (un driver, una connessione o un set di risultati).
}
  \item{what}{
Stringa di caratteri che specifica un elemento della lista di output.
}
  \item{res}{
\code{OraResult}.
}
  \item{\dots}{
Attualmente inutilizzato.
}
}


































\details{
I nomi di tabella, schema e colonna distinguono tra maiuscole e minuscole; ad esempio
  i nomi di tabella \code{ABC} e \code{abc} non sono uguali. Tutti i nomi degli oggetti dello schema
  del database non devono includere le virgolette poiché vengono racchiusi tra
  virgolette quando viene generata l'istruzione SQL corrispondente.
  Il metodo \\pkg{ROracle} \code{dbGetInfo} fornisce i dettagli riportati di seguito
  sull'oggetto driver.
  \itemize{
    \item {\\$driverName} Il nome del driver, "Oracle (OCI)"
    \item {\\$driverVersion} La versione del driver ROracle usata
    \item {\\$clientVersion} La versione della libreria Oracle Client usata
    \item {\\$conTotal} Il numero di connessioni per le quali è stata creata un'istanza dal driver
    \item {\\$conOpen} Il numero di connessioni attualmente aperte
    \item {\\$interruptible} TRUE quando una query con tempi di esecuzione lunghi può essere interrotta
    \item {\\$unicode_as_utf8} TRUE quando i dati dei caratteri devono essere recuperati nel
                             formato codificato UTF8
    \item {\\$ora_attributes} TRUE quando ogni colonna in un data frame del set di risultati
                             dispone di attributi Oracle DBMS corrispondenti
    \item {\\$connections} Informazioni su ogni connessione attualmente aperta, vedere
                          \code{dbGetInfo} dell'oggetto di connessione per i dettagli
  }
  Il metodo \\pkg{ROracle} \code{dbGetInfo} fornisce i dettagli riportati di seguito
  sull'oggetto connessione.
  \itemize{
    \item {\\$username} Il nome dell'utente in questa connessione
    \item {\\$dbname} L'alias di connessione o la stringa di connessione usata
    \item {\\$serverVersion} La versione del server del database Oracle
    \item {\\$serverType} Il valore "Oracle RDBMS"
    \item {\\$resTotal} Il numero di set di risultati in questa connessione
    \item {\\$resOpen} Il numero di set di risultati aperti in questa connessione
    \item {\\$prefetch} TRUE quando per recuperare i dati viene usato il meccanismo di recupero preliminare
    \item {\\$bulk_read} Il numero di righe da recuperare alla volta da DBMS
    \item {\\$bulk_write} Il numero di righe da scrivere alla volta in DBMS
    \item {\\$stmt_cache} TRUE quando viene usata la cache delle istruzioni
    \item {\\$results} Informazioni su ogni set di risultati attualmente aperto, vedere
                      \code{dbGetInfo} del set di risultati per i dettagli
  }
  Il metodo \\pkg{ROracle} \code{dbGetInfo} fornice i dettagli riportati di seguito
  sull'oggetto set di risultati.
  \itemize{
    \item {\\$statement} Istruzione SQL usata per produrre l'oggetto set di risultati
    \item {\\$isSelect} TRUE quando viene specificata un'istruzione SELECT
    \item {\\$rowsAffected} Il numero di righe interessate dall'istruzione DML
    \item {\\$rowCount} Il numero di righe attualmente nel set di risultati
    \item {\\$completed} TRUE se non vi sono altre righe nel set di risultati
    \item {\\$prefetch} TRUE quando per recuperare i dati viene usato il meccanismo di recupero preliminare
    \item {\\$bulk_read} Il numero di righe da recuperare alla volta da DBMS
    \item {\\$bulk_write} Il numero di righe da scrivere alla volta in DBMS
    \item {\\$fields} Informazioni su ogni colonna del set di risultati, vedere
                     \code{dbColumnInfo} per i dettagli
  }
  Il metodo \\pkg{ROracle} \code{dbColumnInfo} fornisce i dettagli riportati di seguito
  su ogni colonna del set di risultati.
  \itemize{
    \item {\\$name} Il nome della colonna
    \item {\\$Sclass} Il tipo R dell'oggetto che contiene i dati restituiti da
                     Oracle RDBMS
    \item {\\$type} Il tipo di colonna creato in Oracle RDBMS
    \item {\\$len} La lunghezza del tipo di colonna VARCHAR, CHAR e RAW in Oracle RDBMS.
                  Tutte le altre colonne avranno NA.
    \item {\\$precision} La precisione della colonna numerica
    \item {\\$scale} La scala della colonna numerica
    \item {\\$nullOK} TRUE quando un valore NULL può essere presente nella colonna
  }
   Nell'esempio riportato di seguito vengono illustrate le informazioni relative al driver,
   alla connessione, al set di risultati e alla colonna per una tabella con il seguente contenuto.
 \\preformatted{
   create table foo(
     a number(21),
     b numero,
     c char(20),
     d varchar(300),
     e binary_double,
     f binary_float,
     g clob,
     h blob,
     i bfile,
     j data,
     m indicatore orario,
     n indicatore orario con fuso orario,
     o indicatore orario con fuso orario locale,
     r intervallo in giorni e secondi,
     s raw(234)
   );
 }
\\preformatted{   library(ROracle)
Package di caricamento richiesto: DBI
> # creazione istanza oggetto driver ROracle
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
Nome utente:             scott 
Stringa di connessione:         
Versione del server:        11.2.0.4.0 
Tipo di server:           Oracle RDBMS 
Risultati elaborati:     1 
Recupero preliminare OCI:          FALSE 
Lettura in blocco:             1000 
Scrittura in blocco:            1000 
Dimensione cache delle istruzioni:  0 
Risultati aperti:          1 
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
Istruzione:            select * from foo 
Righe interessate:        0 
Conteggio righe:            0 
Istruzione SELECT:     TRUE 
Istruzione completata:  FALSE 
Recupero preliminare OCI:         FALSE 
Lettura in blocco:            1000 
Scrittura in blocco:           1000 
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
Informazioni su un oggetto driver, connessione o set di risultati.
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
