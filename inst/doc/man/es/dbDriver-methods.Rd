\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Implantación de Oracle de las clases y controladores de la interfaz de la base
  de datos (DBI)
}
\description{
Inicialización y cierre de los controladores de Oracle
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
objeto que se hereda de \code{OraDriver} o \code{ExtDriver}
    como lo ha creado \code{dbDriver}.
}
  \item{...}{
cualquier otro argumento se transfiere al controlador \code{drvName}.
}
}
\value{
\item{dbDriver}{
    Objeto \code{OraDriver} o \code{ExtDriver} cuya clase amplía
    \code{DBIDriver}. Este objeto se utiliza para crear conexiones utilizando la
    función \code{dbConnect}, de uno o varios motores de base de datos Oracle.
  }
  \item{dbUnloadDriver}{
    libera todos los recursos ocupados por el objeto de controlador.
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
      Este objeto es un singleton, es decir, en llamadas posteriores,
      devuelve el mismo objeto inicializado. 
      Esta implantación permite conectarse a varios servidores host y
      ejecutar varias conexiones en cada servidor de manera simultánea.
      Cuando el valor interrumpible se define como TRUE, permite la interrupción de consultas
      de larga duración en el servidor, al ejecutar la consulta en un thread. El thread principal
      comprueba Ctrl-C y emite OCIBreak/OCIReset para cancelar la operación en
      el servidor. Por defecto, el valor de interrumpible es FALSE.
    }
    \item{dbUnloadDriver}{
      la implantación elimina el enlace de comunicación entre el cliente de \R y 
      la base de datos. Libera todas las conexiones y todos los juegos de resultados asociados a
      dichos objetos de conexión
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
