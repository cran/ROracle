\name{fetch-methods}
\docType{methods}
\alias{fetch}
\alias{fetch,OraResult-method}
\title{
Datensätze von einer zuvor ausgeführten Abfrage abrufen
}
\description{
Diese Methode ist eine einfache Implementierung der entsprechenden
   generischen Funktion.
}
\usage{
\S4method{fetch}{OraResult}(res, n = -1, ...)
}
\arguments{
  \item{res}{
ein \code{OraResult}-Objekt.
}
  \item{n}{
maximale Anzahl von pro Abfrage abzurufenden Datensätzen.
    Verwenden Sie \code{n = -1}, um alle ausstehenden Datensätze abzufragen.
}
  \item{\dots }{
Aktuell nicht verwendet.
}
}
\value{
Anzahl von aus der Datenbank abgefragten Datensätzen.
}
\details{
Die \code{ROracle}-Implementierungen rufen nur \code{n}-Datensätze ab,
  und wenn \code{n} fehlt, werden alle Datensätze zurückgegeben.
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
