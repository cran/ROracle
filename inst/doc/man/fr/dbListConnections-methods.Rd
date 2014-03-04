\name{dbListConnections-methods}
\docType{methods}
\alias{dbListConnections}
\alias{dbListResults}
\alias{dbListConnections,OraDriver-method}
\alias{dbListConnections,ExtDriver-method}
\alias{dbListResults,OraConnection-method}
\title{
Lister les éléments des objets Oracle
}
\description{
Ces méthodes sont des implémentations directes des
   fonctions génériques correspondantes.
}
\usage{
\S4method{dbListConnections}{OraDriver}(drv, ...)
\S4method{dbListConnections}{ExtDriver}(drv, ...)
\S4method{dbListResults}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
\code{OraDriver} ou \code{ExtDriver}.
}
  \item{conn}{
\code{OraConnection}.
}
  \item{\dots}{
inutilisé actuellement.
}
}
\value{
\item{dbListConnections}{
    Liste de toutes les connexions associées au pilote.
  }
  \item{dbListResults}{
    Liste de tous les ensembles de résultats associés à la connexion.
  }
}
\details{
\\describe{
    \item{dbListConnections}{
      L'implémentation renvoie la liste de toutes les connexions associées.
      Elle affiche des informations sur toutes les connexions associées.
    }
    \item{dbListResults}{
      L'implémentation renvoie la liste de tous les ensembles de résultats associés.
      Elle affiche des informations sur tous les ensembles de résultats associés.
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
