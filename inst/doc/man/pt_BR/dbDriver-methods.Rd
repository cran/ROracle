\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Implementação da Oracle das Classes e dos Drivers DBI (Database Interface)
}
\description{
Inicialização e fechamento de driver Oracle.
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
Um objeto que herda de \code{OraDriver} ou \code{ExtDriver}
    conforme criado por \code{dbDriver}.
}

  \item{...}{
Qualquer outro argumento a ser especificado para o driver \code{drvName}.
}
}
\value{
\item{dbDriver}{
    Um objeto \code{OraDriver} ou \code{ExtDriver} cuja classe estende
    \code{DBIDriver}. Esse objeto é usado para criar conexões, utilizando a
    função \code{dbConnect}, com um ou mais motores do Oracle Database.
  }
  \item{dbUnloadDriver}{
    Libera todos os recursos ocupados pelo objeto de driver.
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
       Este objeto é um singleton, ou seja, as chamadas subsequentes de
       \code{dbDriver} retornam o mesmo objeto inicializado.
      Essa implementação permite que você tenha conexão com diversos servidores host e
      execute várias conexões em cada servidor simultaneamente.
      Quando \code{interruptible} é definido como TRUE, ele permite interromper
      consultas de execução longa no servidor executando a consulta em um thread.
      O thread principal verifica Ctrl-C e emite OCIBreak/OCIReset para cancelar a
      operação no servidor. Por padrão, \code{interruptible} é FALSE.
      Quando \code{unicode_as_utf8} é definido como FALSE, os dados NCHAR, NVARCHAR e NCLOB
      são extraídos usando o conjunto de caracteres especificado pela
      definição NLS_LANG. Por padrão, \code{unicode_as_utf8} é definido como TRUE.
      Quando \code{ora.attributes} é definido como TRUE, o conjunto de resultados de
      \code{dbGetQuery} e \code{fetch} contém atributos específicos do DBMS, como
      \code{ora.encoding}, \code{ora.type} e \code{ora.maxlength}, para a
      coluna correspondente.
    }
    \item{dbUnloadDriver}{
      Essa implementação remove links de comunicação entre o cliente \R e o
      banco de dados. Ela libera todas as conexões e todos os conjuntos de resultados associados
      a esses objetos de conexão.
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
