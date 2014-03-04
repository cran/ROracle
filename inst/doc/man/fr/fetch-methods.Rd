\name{fetch-methods}
\docType{methods}
\alias{fetch}
\alias{fetch,OraResult-method}
\title{
Extraire les enregistrements d'une requête exécutée précédemment
}
\description{
Cette méthode est une implémentation directe de
   la fonction générique correspondante.
}
\usage{
\S4method{fetch}{OraResult}(res, n = -1, ...)
}
\arguments{
  \item{res}{
objet \code{OraResult}.
}
  \item{n}{
nombre maximal d'enregistrements à extraire par extraction.
    Utilisez \code{n = -1} pour extraire tous les enregistrements en suspens.
}
  \item{\dots }{
inutilisé actuellement.
}
}
\value{
nombre d'enregistrements extrait de la base de données.
}
\details{
L'implémentation \code{ROracle} extrait uniquement les enregistrements \code{n},
  et si l'élément \code{n} est manquant, elle renvoie tous les enregistrements.
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
  \code{\link[DBI]{dbClearResult}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp")

    # we now fetch the first 10 records from the resultSet into a data.frame
    data1 <- fetch(res, n = 10)   
    dim(data1)

    dbHasCompleted(res)

    # let's get all remaining records
    data2 <- fetch(res, n = -1)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
