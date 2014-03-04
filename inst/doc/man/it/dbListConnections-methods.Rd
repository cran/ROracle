\name{dbListConnections-methods}
\docType{methods}
\alias{dbListConnections}
\alias{dbListResults}
\alias{dbListConnections,OraDriver-method}
\alias{dbListConnections,ExtDriver-method}
\alias{dbListResults,OraConnection-method}
\title{
Elenco di elementi dagli oggetti Oracle
}
\description{
Questi metodi sono implementazioni semplici delle corrispondenti
   funzioni generiche.
}
\usage{
\S4method{dbListConnections}{OraDriver}(drv, ...)
\S4method{dbListConnections}{ExtDriver}(drv, ...)
\S4method{dbListResults}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
\code{OraDriver} o \code{ExtDriver}.
}
  \item{conn}{
\code{OraConnection}.
}
  \item{\dots}{
attualmente inutilizzato.
}
}
\value{
\item{dbListConnections}{
    Lista di tutte le connessioni associate al driver.
  }
  \item{dbListResults}{
    Lista di tutti i set di risultati associati alla connessione.
  }
}
\details{
\\describe{
    \item{dbListConnections}{
      restituisce la lista di tutte le connessioni associate.
      Mostra le informazioni relative a tutte le connessioni associate.
    }
    \item{dbListResults}{
      restituisce la lista di tutti i set di risultati associati.
      Mostra le informazioni relative a tutti set di risultati associati.
    }
  }
}
\section{References}{
  For the Oracle Database documentaion see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbColumnInfo}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}}
}

\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con1 <- dbConnect(drv, "scott", "tiger")
    res1 <- dbSendQuery(con1, "select * from emp where deptno = 10")
    res2 <- dbSendQuery(con1, "select * from emp where deptno = 20")
    con2 <- dbConnect(drv, "scott", "tiger")
    res3 <- dbSendQuery(con2, "select * from dept")

    ## get all active statements
    for(con in dbListConnections(drv))
      for (res in dbListResults(con))
        print(dbGetStatement(res))
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
