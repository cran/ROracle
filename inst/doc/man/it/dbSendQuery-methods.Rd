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
Esecuzione di un'istruzione su una connessione al database specificata
}
\description{
Questi metodi sono implementazioni semplici delle corrispondenti
   funzioni generiche, tranne per il metodo \code{execute} che è un'estensione DBI
   specifica di Oracle R.
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
oggetto \code{OraConnection}.
}
  \item{statement}{
vettore di caratteri di lunghezza 1 con l'istruzione SQL.
}
  \item{res}{
oggetto \code{OraResult}.
}
  \item{data}{
data.frame che specifica dati di bind
}
  \item{prefetch}{
valore logico che indica TRUE o FALSE. Quando è impostato su TRUE, ROracle usa
    i buffer di recupero preliminare OCI per recuperare ulteriori dati dal server, risparmiando
    in questo modo la memoria richiesta in RODBI/ROOCI mediante l'allocazione di un buffer
    con riga singola per recuperare i dati da OCI. L'uso della funzione di recupero preliminare
    genera una chiamata di FETCH per ogni riga. Per impostazione predefinita, la funzione di 
    recupero preliminare è FALSE e per recuperare i dati dal server si utilizza un array fetch.
}
  \item{bulk_read}{
valore intero che indica il numero di righe da recuperare alla volta. L'impostazione predefinita è
    1000L. Quando si seleziona l'opzione di recupero preliminare, la memoria viene allocata per i
    buffer di recupero preliminare e OCI recupera ogni volta la quantità di righe specificata. Quando 
    l'opzione di recupero preliminare non è usata (impostazione predefinita), la memoria viene 
    allocata nei buffer di definizione RODBI/ROOCI. L'impostazione di un valore elevato comporta 
    l'allocazione di più memoria in base al numero di colonne nella lista di selezione e ai tipi delle colonne.
    Per una colonna di caratteri, i buffer di definizione vengono allocati utilizzando la larghezza massima 
    moltiplicata per la larghezza massima NLS. L'applicazione deve adeguare questo valore in base al risultato 
    della query e un valore elevato risulterà più utile alle query che restituiscono risultati di grandi dimensioni. 
    L'applicazione può regolare questo valore in base alle esigenze.
}
  \item{\dots}{
attualmente inutilizzato.
}
}
\value{
\item{dbSendQuery}{
    oggetto \code{OraResult} la cui classe estende \code{DBIResult}. Questo 
    oggetto viene usato per il recupero dei dati dal database mediante 
    la funzione \code{fetch}.
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
      l'implementazione esegue l'istruzione di query e recupera 
      i dati dei risultati dal database. 
    }
    \item{dbSendQuery}{
      l'implementazione esegue l'istruzione di query e restituisce 
      il set di risultati all'applicazione. L'applicazione potrà quindi 
      eseguire le operazioni necessarie sul set di risultati. 
    }
    \item{dbClearResult}{
      l'implementazione libera le risorse occupate dal set di risultati.
    }
    \item{dbGetException}{
      l'implementazione recupera le informazioni relative agli errori.
    }
    \item{execute}{
      l'implementazione esegue l'istruzione di query.
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
