\name{fetch-methods}
\docType{methods}
\alias{fetch}
\alias{fetch,OraResult-method}
\title{
Recuperar Registros de una Consulta Ejecutada Previamente
}
\description{
Este método es una implantación sencilla de la función
   genérica correspondiente.
}
\usage{
\S4method{fetch}{OraResult}(res, n = -1, ...)
}
\arguments{
  \item{res}{
objeto \code{OraResult}.
}
  \item{n}{
número máximo de registros que recuperar por rastreo.
    Utilice \code{n = -1} para recuperar todos los registros pendientes.
}
  \item{\dots }{
no utilizado actualmente.
}
}
\value{
número de registros recuperados de la base de datos.
}
\details{
Las implantaciones \code{ROracle} sólo recuperan los registros \code{n}
  y si falta \code{n}, devuelven todos los registros.
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
