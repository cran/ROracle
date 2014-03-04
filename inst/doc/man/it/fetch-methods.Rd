\name{fetch-methods}
\docType{methods}
\alias{fetch}
\alias{fetch,OraResult-method}
\title{
Recupero tramite fetch di record da una query precedentemente eseguita
}
\description{
Questo metodo è un'implementazione semplice della corrispondente
   funzione generica.
}
\usage{
\S4method{fetch}{OraResult}(res, n = -1, ...)
}
\arguments{
  \item{res}{
oggetto \code{OraResult}.
}
  \item{n}{
numero massimo di record da recuperare per singola operazione fetch.
    Usare \code{n = -1} per recuperare tutti i record in sospeso.
}
  \item{\dots }{
attualmente inutilizzato.
}
}
\value{
numero di record recuperati dal database.
}
\details{
Le implementazioni \code{ROracle} recuperano solo i record \code{n},
  e se \code{n} risulta mancante, restituisce tutti i record.
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
