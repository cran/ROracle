\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
A implementação da Oracle dos drivers e classes DBI (Database
  Interface)
}
\description{
Inicialização e fechamento de driver Oracle
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
um objeto que herda de \code{OraDriver} ou \code{ExtDriver}
    conforme criado por \code{dbDriver}.
}
  \item{...}{
todos os outros argumentos são especificados para o driver \code{drvName}.
}
}
\value{
\item{dbDriver}{
    Um objeto \code{OraDriver} ou \code{ExtDriver} cuja classe estende
    \code{DBIDriver}. Esse objeto é usado para criar conexões, usando a função
    \code{dbConnect} para um ou vários mecanismos do banco de dados Oracle.
  }
  \item{dbUnloadDriver}{
    libera todos os recursos ocupados pelo objeto do driver.
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
      o objeto é um singleton, ou seja, em chamadas subsequentes
      ele retorna o mesmo objeto inicializado.
      Esta implementação permite que você estabeleça conexão com vários servidores e
      execute várias conexões em cada servidor simultaneamente.
      Quando definida como TRUE, a opção interrompível permite interromper
      consultas de longa execução no servidor ao processar a consulta em um thread. O thread principal
      verifica se a sequência Ctrl-C foi utilizada e emite OCIBreak/OCIReset para cancelar a operação no
      servidor. Por padrão , a opção interrompível é FALSE.
    }
    \item{dbUnloadDriver}{
      A implementação remove o link de comunicação entre o cliente \R e 
      o banco de dados. Ela libera todas as conexões e todos os conjuntos de resultados associados a
      esses objetos de conexão
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
