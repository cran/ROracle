\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Implémentation Oracle des classes et pilotes d'interface de base de
   données (DBI)
}
\description{
Initialisation et fermeture de pilote Oracle
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
objet qui hérite de \code{OraDriver} ou \code{ExtDriver}
    tel que créé par \code{dbDriver}.
}
  \item{...}{
les autres arguments sont transmis au pilote \code{drvName}.
}
}
\value{
\item{dbDriver}{
    Objet \code{OraDriver} ou \code{ExtDriver} dont la classe étend
    \code{DBIDriver}. Cet objet est utilisé pour créer des connexions, à l'aide de la
    fonction \code{dbConnect}, vers des moteurs de base de données Oracle.
  }
  \item{dbUnloadDriver}{
    Libère toutes les ressources occupées par l'objet de pilote.
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
      L'objet est un singleton, c'est-à-dire que lors des appels suivants,
il renvoie le même objet initialisé. 
Cette implémentation vous permet de vous connecter à plusieurs serveurs hôte et
d'exécuter simultanément plusieurs connexions sur chaque serveur.
Si l'élément interruptible a la valeur TRUE, il permet l'interruption de requêtes
à longue durée d'exécution sur le serveur en exécutant la requête dans un thread. Le thread principal
recherche Ctrl-C et émet OCIBreak/OCIReset pour annuler l'opération sur
le serveur. Par défaut, l'élément interruptible a la valeur FALSE.
    }
    \item{dbUnloadDriver}{
      L'implémentation enlève le lien de communication entre le client \R et la 
      base de données. Elle libère toutes les connexions et tous les ensembles de résultats associés à
      ces objets de connexion
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
