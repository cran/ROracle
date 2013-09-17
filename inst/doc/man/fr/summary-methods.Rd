\name{summary-methods}
\docType{methods}
\alias{show,OraDriver-method}
\alias{show,ExtDriver-method}
\alias{show,OraConnection-method}
\alias{show,OraResult-method}
\alias{summary,OraDriver-method}
\alias{summary,ExtDriver-method}
\alias{summary,OraConnection-method}
\alias{summary,OraResult-method}
\title{
Agréger un objet Oracle
}
\description{
Ces méthodes sont des implémentations directes des
   fonctions génériques correspondantes.
}
\usage{
\S4method{summary}{OraDriver}(object, ...)
\S4method{summary}{ExtDriver}(object, ...)
\S4method{summary}{OraConnection}(object, ...)
\S4method{summary}{OraResult}(object, ...)
}
\arguments{
  \item{object}{
objet d'ensemble de résultats, de connexion ou de pilote.
}
  \item{\dots}{
inutilisé actuellement.
}
}
\value{
description d'objet.
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
  \code{\link[DBI]{dbGetInfo}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp")

    summary(drv)
    summary(con)
    summary(res)
    show(drv)
    show(con)
    show(res)   
  } 
}
\keyword{methods}
\keyword{database}
\keyword{interface}
