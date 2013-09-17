\name{dbListConnections-methods}
\docType{methods}
\alias{dbListConnections}
\alias{dbListResults}
\alias{dbListConnections,OraDriver-method}
\alias{dbListConnections,ExtDriver-method}
\alias{dbListResults,OraConnection-method}
\title{
Listar itens de objetos Oracle
}
\description{
Estes métodos são implementações simples das funções genéricas
   correspondentes.
}
\usage{
\S4method{dbListConnections}{OraDriver}(drv, ...)
\S4method{dbListConnections}{ExtDriver}(drv, ...)
\S4method{dbListResults}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
um(a) \code{OraDriver} ou \code{ExtDriver}.
}
  \item{conn}{
um(a) \code{OraConnection}.
}
  \item{\dots}{
não utilizado no momento.
}
}
\value{
\item{dbListConnections}{
    Uma lista de todas as conexões associadas ao driver.
  }
  \item{dbListResults}{
    Uma lista de todos os conjuntos de resultados associados à conexão.
  }
}
\details{
\\describe{
    \item{dbListConnections}{
      A implementação retorna uma lista de todas as conexões associadas.
      Ela mostra as informações sobre todas as conexões associadas.
    }
    \item{dbListResults}{
      A implementação retorna uma lista de todos os conjuntos de resultados associados.
      Ela mostra as informações sobre todos os conjuntos de resultados associados.
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
