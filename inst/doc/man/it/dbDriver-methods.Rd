\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Implementazione Oracle di classi e driver DBI (Database Interface)
}
\description{
Inizializzazione e chiusura di driver Oracle.
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
Qualsiasi altro argomento da passare al driver \code{drvName}.
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
      Remove the communication link between the \R client and the database.
    }
  }
}





\details{
\\describe{
    \item{dbDriver}{
      Questo oggetto è un singleton: ciò significa che i richiami successivi
      dell'oggetto \code{dbDriver} restituiscono lo stesso oggetto inizializzato.
      Questa implementazione consente di connettersi a più server host
      e di stabilire contemporaneamente più connessioni a ogni server.
      Quando \code{interruptible} è impostato su TRUE, consente l'interruzione delle query con
      tempi di esecuzione lunghi sul server mediante l'esecuzione della query in un
      thread. Il thread principale controlla Ctrl-C ed esegue OCIBreak/OCIReset per
      annullare l'operazione sul server. Per impostazione predefinita, \code{interruptible} è FALSE.
      Quando \code{unicode_as_utf8} è impostato su FALSE, i dati NCHAR, NVARCHAR e NCLOB
      vengono recuperati utilizzando il set di caratteri specificato
      dall'impostazione NLS_LANG. Per impostazione predefinita, \code{unicode_as_utf8} è impostato su TRUE.
      Quando \code{ora.attributes} è impostato su TRUE, il set di risultati ottenuto da
      \code{dbGetQuery} e \code{fetch} contiene attributi specifici di DBMS come
      \code{ora.encoding}, \code{ora.type} e \code{ora.maxlength} per la
      colonna corrispondente.
    }
    \item{dbUnloadDriver}{
      L'implementazione rimuove il collegamento di comunicazione tra il client \R 
      e il database. Libera inoltre tutte le connessioni e i set di risultati associati a
      gli oggetti di connessione interessati.
    }
  }
}
\section{References}{
  For Oracle Database documentation, see
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
    # first load the library
    library("ROracle")

    # create an Oracle instance
    drv <- dbDriver("Oracle")

    con <- dbConnect(drv, "scott", "tiger")
    dbListTables(con)

    # fetch all results from the emp table
    res <- dbGetQuery(con, "select * from emp")

    # dbSendQuery can be used to fetch data in chunks 
    # as well as all of data at once
    res <- dbSendQuery(con, "select * from emp")

    # fetch all results
    fetch(res)

    # or a chunk at a time
    fetch(res, n = 5)

    # describing the schema for the emp table using dbGetInfo
    dbGetInfo(res, what = 'fields')

    # clear the result
    dbClearResult(res)

    # disconnect from the database
    dbDisconnect(con)

    # free the driver object
    dbUnloadDriver(drv)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
