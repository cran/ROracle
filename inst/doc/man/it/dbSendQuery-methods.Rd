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
Esecuzione di un'istruzione su una connessione al database specificata
}
\description{
Questi metodi sono implementazioni semplici delle corrispondenti
   funzioni generiche, tranne per il metodo \code{execute}, che è un'estensione DBI
   specifica di Oracle R.
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
Oggetto \code{OraConnection}.
}
  \item{statement}{
Vettore di caratteri di lunghezza 1 con l'istruzione SQL.
}
  \item{res}{
Oggetto \code{OraResult}.
}
  \item{data}{
\code{data.frame} che specifica i dati di bind.
}
  \item{prefetch}{
Valore logico che specifica se ROracle usa i buffer di recupero preliminare o un array 
    fetch per recuperare i dati dal server. Quando l'impostazione è \code{TRUE}, ROracle usa i 
    buffer di recupero preliminare OCI per recuperare ulteriori dati dal server, risparmiando 
    la memoria richiesta in RODBI/ROOCI mediante l'allocazione di un buffer con riga 
    singola per recuperare i dati da OCI. L'uso della funzione di recupero preliminare 
    genera una chiamata di FETCH per ogni riga. Con l'impostazione predefinita \code{FALSE}, 
    ROracle usa un array fetch per recuperare i dati.
}
  \item{bulk_read}{
Valore intero che indica il numero di righe da recuperare alla volta. Il valore 
    predefinito è 1000L. Quando si seleziona l'opzione di recupero preliminare, la 
    memoria viene allocata per i buffer di recupero preliminare e OCI recupera ogni 
    volta il numero di righe specificato. Quando l'opzione di recupero preliminare non 
    è usata (impostazione predefinita), la memoria viene allocata nei buffer di definizione 
    RODBI/ROOCI. L'impostazione di un valore elevato comporta l'allocazione di più memoria 
    in base al numero di colonne nella lista di selezione e ai tipi delle colonne. Per una colonna 
    di caratteri, i buffer di definizione vengono allocati utilizzando la larghezza massima moltiplicata 
    per la larghezza massima NLS. L'applicazione deve adeguare questo valore in base al risultato 
    della query. Un valore elevato risulterà più utile alle query che restituiscono grandi quantità di 
    risultati. L'applicazione può regolare questo valore in base alle esigenze.
}
  \item{bulk_write}{
Valore intero che indica il numero di righe da scrivere alla volta. Il valore
    predefinito è 1000L. Quando si specifica un valore bulk_write, la memoria 
    viene allocata per i buffer e OCI scrive ogni volta la quantità di righe 
    specificata. Se l'argomento bulk_write non viene usato, per allocare la 
    memoria per i buffer di autenticazione viene usato il valore predefinito 1000. 
    L'impostazione di \code{bulk_write} su un valore elevato comporta l'allocazione di più
    memoria in base al numero di colonne nella lista di inserimento e ai tipi delle colonne.
}
  \item{\dots}{
Attualmente inutilizzato.
}
}
\value{
\item{dbSendQuery}{
    Oggetto \code{OraResult} la cui classe estende \code{DBIResult}. Questo 
    oggetto viene usato per il recupero dei dati dal database mediante 
    la funzione \code{fetch}.
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
      Questa funzione esegue un'istruzione di query e recupera i dati dei
      risultati dal database. Non deve essere usata per richiamare le query PL/SQL.
    }
    \item{dbSendQuery}{
      Questa funzione esegue un'istruzione di query e restituisce un set di risultati 
      all'applicazione, che potrà eseguire le operazioni necessarie sul set di risultati.
      Non deve essere usata per richiamare le query PL/SQL.
    }
     \item{oracleProc}{
      Questa funzione esegue una stored procedure PL/SQL o un'istruzione di query
      di funzione e restituisce il risultato.
    }
    \item{dbClearResult}{
      Questa funzione libera le risorse utilizzate dal set di risultati.
    }
    \item{dbGetException}{
      Questa funzione recupera le informazioni relative agli errori.
    }
    \item{execute}{
      Questa funzione esegue l'istruzione di query specificata.
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
