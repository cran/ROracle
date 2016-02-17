\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Implémentation Oracle des classes et pilotes d'interface de base de données (DBI)
}
\description{
Initialisation et fermeture de pilote Oracle.
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
Objet qui hérite de \code{OraDriver} ou \code{ExtDriver}
    tel que créé par \code{dbDriver}.
}

  \item{...}{
Tout autre argument à transmettre au pilote \code{drvName}.
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
      Remove the communication link between the \R client and the database.
    }
  }
}





\details{
\\describe{
    \item{dbDriver}{
       Cet objet est un singleton, c'est-à-dire que les appels consécutifs de
       \code{dbDriver} renvoient le même objet initialisé.
      Cette implémentation permet de vous connecter à plusieurs serveurs hôte et
      d'exécuter simultanément plusieurs connexions sur chaque serveur.
      Si \code{interruptible} a la valeur TRUE, il est possible d'interrompre des requêtes
      à longue durée d'exécution sur le serveur en exécutant la requête dans un thread.
      Le thread principal recherche Ctrl-C et émet OCIBreak/OCIReset pour annuler
      l'opération sur le serveur. Par défaut, \code{interruptible} a la valeur FALSE.
      Si \code{unicode_as_utf8} est défini sur FALSE, les données NCHAR, NVARCHAR et NCLOB
      sont extraites à l'aide du jeu de caractères spécifié par le paramètre NLS_LANG.
      Par défaut, \code{unicode_as_utf8} est défini sur TRUE.
      Si \code{ora.attributes} est défini sur TRUE, l'ensemble de résultats de
      \code{dbGetQuery} et \code{fetch} contient des attributs propres au SGBD,
      comme \code{ora.encoding}, \code{ora.type} et \code{ora.maxlength} pour la
      colonne correspondante.
    }
    \item{dbUnloadDriver}{
      Cette implémentation enlève les liens de communication entre le client \R et
      la base de données. Elle libère toutes les connexions et tous les ensembles de résultats associés à
      ces objets de connexion.
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
