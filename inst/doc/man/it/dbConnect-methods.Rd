\name{dbConnect-methods}
\docType{methods}
\alias{dbConnect}
\alias{dbDisconnect}
\alias{dbConnect,OraDriver-method}
\alias{dbConnect,ExtDriver-method}
\alias{dbDisconnect,OraConnection-method}
\title{
Creazione di un oggetto di connessione a Oracle DBMS
}
\description{
Questi metodi sono implementazioni semplici delle corrispondenti
   funzioni generiche.
}
\usage{
\S4method{dbConnect}{OraDriver}(drv, username = "", password = "", dbname = "", prefetch = FALSE,
          bulk_read = 1000L, bulk_write = 1000L, stmt_cache = 0L,
          external_credentials = FALSE, sysdba = FALSE, ...)
\S4method{dbConnect}{ExtDriver}(drv, prefetch = FALSE, bulk_read = 1000L,
          bulk_write = 1000L, stmt_cache = 0L,
          external_credentials = FALSE, sysdba = FALSE, ...)
\S4method{dbDisconnect}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
Oggetto della classe \code{OraDriver} o \code{ExtDriver}.
}
  \item{conn}{
Oggetto \code{OraConnection} prodotto da \code{dbConnect}.
}
  \item{username}{
Stringa di caratteri che specifica un nome utente.
}
  \item{password}{
Stringa di caratteri che specifica una password.
}
  \item{dbname}{
Stringa di caratteri che specifica un identificativo di connessione (per ulteriori
    informazioni, fare riferimento al Capitolo 8, Configurazione dei metodi di
    denominazione, nella Guida per l'amministratore di Oracle Database Net Services).
    Questa stringa è uguale alla parte della stringa di connessione SQL*Plus che segue
    la chiocciola '@'. Se si usa Oracle Wallet per memorizzare il nome utente e la password, 
    la stringa deve essere la stringa di connessione utilizzata per creare il mapping di 
    wallet (per ulteriori informazioni, vedere la sezione Configurazione dei client per l'uso
    dell'area di memorizzazione password esterna nel Capitolo 3 della Guida alla sicurezza del
    database Oracle). Gli identificativi di connessione per un'istanza di Oracle TimesTen IMDB
    sono supportati mediante tnsnames OCI o semplici metodi di denominazione di connessione.
    Per ulteriori informazioni sulle connessioni TimesTen per OCI, vedere il Capitolo 3, Supporto
    TimesTen per OCI, della Guida per lo sviluppatore TimesTen In-Memory C.
    Negli esempi riportati di seguito vengono illustrate varie modalità per specificare l'identificativo di connessione.
}
  \item{prefetch}{
Valore logico che indica TRUE o FALSE. Quando è impostato su TRUE, ROracle usa
    i buffer di recupero preliminare OCI per recuperare ulteriori dati dal server, risparmiando
    in questo modo la memoria richiesta in RODBI/ROOCI mediante l'allocazione di un buffer
    con riga singola per recuperare i dati da OCI. L'uso della funzione di recupero preliminare
    genera una chiamata di FETCH per ogni riga. Per impostazione predefinita, la funzione di 
    recupero preliminare è FALSE e per recuperare i dati dal server si utilizza un array fetch.
}
  \item{bulk_read}{
Valore intero che indica il numero di righe da recuperare alla volta. Il valore predefinito è
    1000L. Quando si seleziona l'opzione di recupero preliminare, la memoria viene allocata
    per i buffer di recupero preliminare e OCI recupera ogni volta la quantità di righe specificata.
    Quando l'opzione di recupero preliminare non è usata (impostazione predefinita), la memoria
    viene allocata nei buffer di definizione RODBI/ROOCI. L'impostazione di un valore elevato comporta
    l'allocazione di più memoria in base al numero di colonne nella lista di selezione e ai tipi delle colonne.
    Per una colonna di caratteri, i buffer di definizione vengono allocati utilizzando la larghezza massima
    moltiplicata per la larghezza massima NLS. L'applicazione deve adeguare questo valore in base al risultato
    della query e un valore elevato risulterà più utile alle query che restituiscono risultati di grandi dimensioni.
    L'applicazione può regolare questo valore in base alle esigenze.
}
  \item{bulk_write}{
Un valore intero che indica il numero di righe da inserire, aggiornare o eliminare
    alla volta. Il valore predefinito è 1000L. Quando il valore di bulk_write viene fornito
    in un argomento, la memoria viene allocata per i buffer e OCI scrive ogni volta
    la quantità di righe specificata. Quando l'argomento bulk_write non viene fornito,
    il valore predefinito 1000 viene usato per allocare la memoria per i buffer di
    autenticazione. L'impostazione di un valore elevato comporta l'allocazione di più
    memoria in base al numero di colonne nella lista di inserimento e ai tipi delle colonne.
}
  \item{stmt_cache}{
Valore intero che indica il numero di istruzioni da inserire nella cache. Ciò significa 
    che i cursori sono pronti per l'uso senza che sia necessario analizzare di nuovo 
    le istruzioni. Il valore predefinito è 0L. Se il valore stmt_cache è maggiore di 0L,
    sarà necessario impostare il valore \code{prefetch} su TRUE.
}
  \item{external_credentials}{
Valore logico che indica TRUE o FALSE. Quando l'impostazione è TRUE, ROracle
    avvia una sessione OCI autenticata con credenziali esterne alla connessione.
    Il valore predefinito è FALSE.
}
  \item{sysdba}{
Valore logico che indica TRUE o FALSE. Quando l'impostazione è TRUE, ROracle
    avvia una sessione OCI con privilegi SYSDBA alla connessione.
    Il valore predefinito è FALSE.
}
  \item{\dots}{
Attualmente inutilizzato.
}
}
\value{
\item{dbConnect}{
    Oggetto \code{OraConnection} la cui classe estende \code{DBIConnection}. 
    Questo oggetto viene utilizzato per eseguire le query SQL sul database.
  }
  \item{dbDisconnect}{
    Valore logico che indica se l'operazione è riuscita o meno.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbConnect}{
      Establishes a connection between R and an Oracle Database server.
    }
    \item{dbDisconnect}{
      Frees resources used by the connection object.
    }
  }
}
      





           
\details{
\\describe{
    \item{dbConnect}{
      Questo oggetto di connessione consente di eseguire operazioni nel database.
      Quando è impostato su TRUE, \code{prefetch} consente di usare il buffer di recupero
      preliminare OCI per recuperare dati aggiuntivi dal server.
      L'argomento \code{bulk_read} viene usato per impostare un valore intero
      che indica il numero di righe da recuperare per volta.
      L'argomento \code{bulk_write} viene usato per impostare un valore interero
      che indica il numero di righe da scrivere alla volta.
      L'argomento \code{stmt_cache} viene usato per abilitare o disabilitare la funzione di inserimento
      delle istruzioni nella cache. Il valore specifica la dimensione della cache delle istruzioni.
      L'argomento \code{external_credentials} viene usato per avviare una sessione OCI
      autenticata con credenziali esterne alla connessione.
      L'argomento \code{sysdba} viene usato per avviare una sessione OCI con privilegi SYSDBA
      alla connessione.
      Quando si stabilisce una connessione con un driver \code{ExtDriver}, non viene usato
      alcun argomento di specifica delle credenziali. Una connessione stabilita
      con questa modalità è un oggetto singleton: tutte le chiamate di \code{dbConnect}
      restituiscono lo stesso oggetto di connessione.
    }
    \item{dbDisconnect}{
      Questa implementazione interrompe la connessione tra R e il database
      server. Libera inoltre tutte le risorse utilizzate dall'oggetto di connessione
      e tutti i set di risultati associati all'oggetto di connessione.
    }
  }
}
\section{References}{
  For the Oracle Database documentation see
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
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    ## Create an Oracle Database instance and create one connection on the
    ## same machine.
    drv <- dbDriver("Oracle")

    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection to a
    ## remote database using the SID in the connect string. 
    drv <- dbDriver("Oracle")

    ## Refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.
    host <- "myhost"
    port <- 1521
    sid <- "mysid"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
        "(CONNECT_DATA=(SID=", sid, ")))", sep = "")

    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection to a
    ## remote database using the service name.
    drv <- dbDriver("Oracle")

    ## Refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.

    host <- "myhost"
    port <- 1521
    svc <- "mydb.example.com"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
      "(CONNECT_DATA=(SERVICE_NAME=", svc, ")))", sep = "")
    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Use Oracle Wallet authentication.
    con <- dbConnect(drv, username ="", password="", 
    dbname = "<wallet_connect_string>")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Connect to a TimesTen IMDB instance using the easy connect 
    ## naming method where SampleDb is a direct driver TimesTen DSN.
    con <- dbConnect(drv, username ="scott", password="tiger", 
                     dbname = "localhost/SampleDb:timesten_direct")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from dual")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Connect to an extproc (this assumes that the driver has already
    ## been initialized in the embedded R code by passing an external
    ## pointer representing the extproc context).
    con <- dbConnect(Extproc())

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from dual")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Create connection with SYSDBA privileges.
    con <- dbConnect(drv, username ="scott", password="tiger",
                     sysdba = TRUE)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")
    
    ## Use OS authentication as an example of external authentication
    ## Make sure that databse user exist to allow an OS authentication

    ## Create connection authenticated with external credentials.
    con <- dbConnect(drv, username ="", password="",
                     external_credentials = TRUE)
    
    ## Above dbConnect() used OS credentials to connect with database.

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
