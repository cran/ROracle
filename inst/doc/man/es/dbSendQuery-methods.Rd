\name{dbSendQuery-methods}
\docType{methods}
\alias{dbSendQuery}
\alias{dbGetQuery}
\alias{dbClearResult}
\alias{dbGetException}
\alias{execute}
\alias{dbSendQuery,OraConnection,character-method}
\alias{dbGetQuery,OraConnection,character-method}
\alias{dbClearResult,OraResult-method}
\alias{dbGetException,OraConnection-method}
\alias{execute,OraResult-method}
\title{
Ejecutar una Sentencia en una Conexión de Base de Datos Especificada
}
\description{
Estos métodos son implantaciones sencillas de las funciones
   genéricas correspondientes, a excepción del método \code{execute}, que es una
   extensión de DBI específica de ROracle.
}
\usage{
\S4method{dbSendQuery}{OraConnection,character}(conn, statement, data = NULL, prefetch = FALSE, bulk_read = 1000L, ...)
\S4method{dbGetQuery}{OraConnection,character}(conn, statement, data = NULL, prefetch = FALSE, bulk_read = 1000L, ...)
\S4method{dbClearResult}{OraResult}(res, ...)
\S4method{dbGetException}{OraConnection}(conn, ...)

execute(res, ...)
\S4method{execute}{OraResult}(res, data = NULL, ...)
}
\arguments{
  \item{conn}{
objeto \code{OraConnection}.
}
  \item{statement}{
vector de caracteres de longitud 1 con la sentencia SQL.
}
  \item{res}{
objeto \code{OraResult}.
}
  \item{data}{
elemento data.frame que especifica los datos de enlace
}
  \item{prefetch}{
valor lógico que indica TRUE o FALSE. Si se define en TRUE, ROracle utilizará
    los buffers de recuperación previa de OCI para recuperar datos adicionales del servidor guardando
    la memoria necesaria en RODBI/ROOCI asignando un buffer de fila único para recuperar 
    los datos de OCI. Utilice los resultados de recuperación previa en una llamada de recuperación para cada fila. Por
    defecto, la recuperación previa es FALSE y se utiliza una recuperación de matriz para recuperar los datos del
    servidor.
}
  \item{bulk_read}{
valor entero que indica el número de filas que recuperar al mismo tiempo. El
    valor por defecto es 1000L. Cuando la opción de recuperación previa está seleccionada, la memoria
    se asigna para los buffers de recuperación previa y OCI recuperará esa cantidad de filas al mismo tiempo.
    Cuando no se utiliza la recuperación previa (opción por defecto), la memoria se asigna en los buffers de definición
    RODBI/ROOCI. Al configurar este valor en un valor grande, hará que exista más memoria asignada
    basada en el número de columnas en la lista de selección y los tipos de columnas.
    Para una columna de tipo de caracteres, los buffers de definición se asignan
    utilizando el número máximo de ancho con el ancho máximo de NLS. Las aplicaciones deben
    ajustar este valor según el resultado de la consulta y un valor más grande beneficiará
    las consultas que devuelven un resultado mayor. Una aplicación puede ajustar este valor según
    sea necesario.
}
  \item{\dots}{
no utilizado actualmente.
}
}
\value{
\item{dbSendQuery}{
    objeto \code{OraResult} cuya clase amplía \code{DBIResult}. Este 
    objeto se utiliza para recuperar datos de la base de datos con la función 
    \code{fetch}.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      query statement is executed and data has fetched from database.
    }
    \item{dbSendQuery}{
      query statement is executed, but note that data needs to fetch through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{dbClearResult}{
      resources acquired by result set has free.
    }
    \item{dbGetException}{
      error information retrieved and then cleaned from driver.
    }
    \item{execute}{
      query statement is executed.
    }
  }
}
\details{
\\describe{
    \item{dbGetQuery}{
      la implantación ejecuta la sentencia de consulta y recupera 
      los datos de resultados de la base de datos. 
    }
    \item{dbSendQuery}{
      la implantación ejecuta la sentencia de consulta y devuelve 
      el juego de resultados a la aplicación. Ahora la aplicación puede realizar operaciones 
      en el juego de resultados. 
    }
    \item{dbClearResult}{
      la implantación libera recursos ocupados por el juego de resultados.
    }
    \item{dbGetException}{
      la implantación recupera la información sobre errores.
    }
    \item{execute}{
      la implantación ejecuta la sentencia de consulta.
    }
  }
}
\section{References}{
  For the Oracle Database documentaion see 
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp where deptno = :1",
                       data = data.frame(deptno = 10))
    data <- fetch(res, n = -1)
    res2 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data1 = data.frame(deptno = 10), prefetch=TRUE,
                        bulk_read=2L)
    data1 <- fetch(res2, n = -1)
    res3 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data2 = data.frame(deptno = 10), bulk_read=10L)
    data2 <- fetch(res3, n = -1)
    res4 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data3 = data.frame(ename = 'SMITH')) 
    data3 <- fetch(res4, n = -1)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
