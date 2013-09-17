\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Implementazione Oracle di classi e driver DBI 
  (Database Interface)
}
\description{
Inizializzazione e chiusura di driver Oracle
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
Oggetto che eredita da \code{OraDriver} o \code{ExtDriver}
    creato da \code{dbDriver}.
}
  \item{...}{
qualsiasi altro argomento passato al driver \code{drvName}.
}
}
\value{
\item{dbDriver}{
    Oggetto \code{OraDriver} o \code{ExtDriver} la cui classe estende \code{DBIDriver}.
    Questo oggetto consente di creare le connessioni a uno
    o più motori del database Oracle tramite la funzione \code{dbConnect}.
  }
  \item{dbUnloadDriver}{
    Libera tutte le risorse occupate dall'oggetto driver.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbDriver}{
      The \R client part of the database communication is initialized,
      but note that connecting to the database engine needs to be done through
      calls to \code{\link[DBI]{dbConnect}}.
    }
    \item{dbUnloadDriver}{
      Remove communication link between \R client and database.
    }
  }
}


\details{
\\describe{
    \item{dbDriver}{
      Questo oggetto è un singleton: ciò significa che restituisce lo stesso
      oggetto inizializzato nei richiami successivi.
      Questa implementazione consente di connettersi a più server host
      e di stabilire contemporaneamente più connessioni a ogni server.
      Quando è impostato su TRUE, interruptible consente l'interruzione delle query con
      tempi di esecuzione lunghi sul server mediante l'esecuzione della query in un
      thread. Il thread principale controlla Ctrl-C ed esegue OCIBreak/OCIReset per
      annullare l'operazione sul server. interruptible è FALSE per impostazione predefinita.
    }
    \item{dbUnloadDriver}{
      L'implementazione rimuove il collegamento di comunicazione tra il client \R 
      e il database. Libera inoltre tutte le connessioni e i set di risultati associati a
      gli oggetti di connessione interessati.
    }
  }
}
\section{References}{
  For the Oracle Database documentaion see
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
  \code{\link[DBI]{dbListTables}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    # create an Oracle instance
    drv <- dbDriver("Oracle")

    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp")
    fetch(res, n = 5)
    fetch(res)
    dbClearResult(res)
    dbUnloadDriver(drv)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
