\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Implantación de Oracle de las Clases y Controladores de la Interfaz de la Base de Datos (DBI)
}
\description{
Inicialización y cierre de los controladores de Oracle.
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
Objeto que se hereda de \code{OraDriver} o \code{ExtDriver}
    como lo ha creado \code{dbDriver}.
}

  \item{...}{
Cualquier otro argumento que transferir al controlador \code{drvName}.
}
}
\value{
\item{dbDriver}{
    Objeto \code{OraDriver} o \code{ExtDriver} cuya clase amplía
    \code{DBIDriver}. Este objeto se utiliza para crear conexiones utilizando la
    función \code{dbConnect}, de uno o más motores de Oracle Database.
  }
  \item{dbUnloadDriver}{
    Libera todos los recursos ocupados por el objeto de controlador.
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
       Este objeto es un singleton, es decir, en llamadas posteriores,
       \code{dbDriver} devuelve el mismo objeto inicializado.
       Esta implantación permite conectarse a varios servidores host y
      ejecutar varias conexiones en cada servidor de manera simultánea.
      Cuando \code{interruptible} se define en TRUE, permite la interrupción de
      consultas de larga duración en el servidor, al ejecutar la consulta en un thread.
      El thread principal comprueba Ctrl-C y emite OCIBreak/OCIReset para cancelar
      la operación en el servidor. Por defecto, el valor de \code{interruptible} es FALSE.
      Cuando \code{unicode_as_utf8} se define en FALSE, los datos de NCHAR, NVARCHAR y NCLOB
      se recuperan con el juego de caracteres que especifica el valor NLS_LANG.
      Por defecto, \code{unicode_as_utf8} se define en TRUE.
      Cuando \code{ora.attributes} se define en TRUE, el juego de resultados de
      \code{dbGetQuery} y \code{fetch} contiene atributos específicos de DBMS como
      \code{ora.encoding}, \code{ora.type} y \code{ora.maxlength} para la
      columna correspondiente.
    }
    \item{dbUnloadDriver}{
      Esta implantación elimina los enlaces de comunicación entre el cliente de \R y
      la base de datos. Libera todas las conexiones y todos los juegos de resultados asociados a
      dichos objetos de conexión.
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
