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
Exécuter une instruction sur une connexion de base de données spécifique
}
\description{
Ces méthodes sont des implémentations directes des
   fonctions génériques correspondantes, excepté pour la méthode \code{execute} qui est une
   extension DBI ROracle spécifique.
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
Objet \code{OraConnection}.
}
  \item{statement}{
Vecteur de caractère de longueur 1 avec l'instruction SQL.
}
  \item{res}{
Objet \code{OraResult}.
}
  \item{data}{
Elément \code{data.frame} indiquant les données de liaison
}
  \item{prefetch}{
Valeur logique indiquant si ROracle utilise les tampons de préextraction ou une
    extraction par tableau pour extraire des données du serveur. Si \code{TRUE}, ROracle 
    utilise les tampons de préextraction OCI pour extraire des données supplémentaires du serveur, 
    économisant ainsi la mémoire requise dans RODBI/ROOCI en allouant un seul tampon de ligne pour 
    extraire les données à partir d'OCI. L'utilisation de la préextraction génère un appel d'extraction pour 
    chaque ligne. Si \code{FALSE} (valeur par défaut), ROracle utilise l'extraction par tableau pour 
    extraire les données.
}
  \item{bulk_read}{
Valeur entière indiquant le nombre de lignes à extraire à la fois. La 
    valeur par défaut est 1000L. Lorsque l'option de préextraction est sélectionnée, la mémoire 
    est allouée aux tampons de préextraction et OCI extrait le nombre de lignes indiquée de manière 
    simultanée. Lorsque la préextraction n'est pas utilisée, ce qui est le paramètre par défaut, la mémoire est 
    allouée aux tampons définis RODBI/ROOCI. La définition de cette valeur sur un nombre plus important 
    entraîne l'allocation de plus de mémoire en fonction du nombre de colonnes dans la liste et les types
    de colonnes sélectionnés. Pour une colonne de type caractère, les tampons définis sont alloués
    à l'aide de la formule suivante : largeur maximale fois largeur maximale NLS. Une application doit
    ajuster cette valeur en fonction du résultat de requête. Une valeur plus importante est
    bénéfique pour les requêtes qui renvoient un résultat important. L'application peut régler
    cette valeur selon ses besoins.
}
  \item{bulk_write}{
Valeur entière indiquant le nombre de lignes à écrire simultanément.
    La valeur par défaut est 1000L. Lorsque la valeur bulk_write est spécifiée,
    la mémoire est allouée pour les tampons et OCI écrit ce nombre de lignes
    de manière simultanée. Lorsque l'argument bulk_write n'est pas spécifié, la valeur par défaut
    est utilisée pour allouer la mémoire aux tampons de liaison. Si \code{bulk_write} est défini
    sur une valeur élevée, davantage de mémoire est allouée en fonction du nombre de
    colonnes dans la liste d'insertion et des types de colonne.
}
  \item{\dots}{
Inutilisé actuellement.
}
}
\value{
\item{dbSendQuery}{
    Objet \code{OraResult} dont la classe étend \code{DBIResult}. Cet objet est utilisé 
    pour extraire des données d'une base de données, à l'aide de la fonction 
    \code{fetch}.
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
      Cette fonction exécute une instruction de requête et extrait les données de résultat
      de la base de données. Elle ne doit pas être utilisée pour l'appel de requêtes PL/SQL.
    }
    \item{dbSendQuery}{
      Cette fonction exécute une instruction de requête et renvoie un ensemble de résultats
      à l'application. L'application peut ensuite effectuer des opérations sur l'ensemble de résultats.
      Elle ne doit pas être utilisée pour l'appel de requêtes PL/SQL.
    }
     \item{oracleProc}{
      Cette fonction exécute une procédure stockée PL/SQL ou une instruction de requête 
      de fonction et renvoie le résultat.
    }
    \item{dbClearResult}{
      Cette fonction libère les ressources utilisées par l'ensemble de résultats.
    }
    \item{dbGetException}{
      Cette fonction extrait les informations relatives aux erreurs.
    }
    \item{execute}{
      Cette fonction exécute l'instruction de requête indiquée.
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
