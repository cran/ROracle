\name{dbListConnections-methods}
\docType{methods}
\alias{dbListConnections}
\alias{dbListResults}
\alias{dbListConnections,OraDriver-method}
\alias{dbListConnections,ExtDriver-method}
\alias{dbListResults,OraConnection-method}
\title{
Elementos de la Lista de los Objetos de Oracle
}
\description{
Estos métodos son implantaciones sencillas de las funciones
   genéricas correspondientes.
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
no utilizado actualmente.
}
}
\value{
\item{dbListConnections}{
    Lista de todas las conexiones asociadas al controlador.
  }
  \item{dbListResults}{
    Lista de juegos de resultados asociados a la conexión.
  }
}
\details{
\\describe{
    \item{dbListConnections}{
      la implantación devuelve una lista de todas las conexiones asociadas.
      Muestra la información sobre todas las conexiones asociadas.
    }
    \item{dbListResults}{
      La implantación devuelve una lista de todos los juegos de resultados asociados.
      Muestra la información sobre todos los juegos de resultados asociados.
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
