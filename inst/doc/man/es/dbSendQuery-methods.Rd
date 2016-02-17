\name{dbSendQuery-methods}
\docType{methods}
\alias{dbSendQuery}
\alias{dbGetQuery}
\alias{oracleProc}
\alias{dbClearResult}
\alias{dbGetException}
\alias{execute}
\alias{dbSendQuery,OraConnection,character-method}
\alias{dbGetQuery,OraConnection,character-method}
\alias{dbClearResult,OraResult-method}
\alias{oracleProc,OraConnection,character-method}
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
\S4method{dbSendQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbGetQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{oracleProc}{OraConnection,character}(conn, statement, data = NULL, 
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbClearResult}{OraResult}(res, ...)
\S4method{dbGetException}{OraConnection}(conn, ...)

execute(res, ...)
\S4method{execute}{OraResult}(res, data = NULL, ...)
}
\arguments{
  \item{conn}{
Objeto \code{OraConnection}.
}
  \item{statement}{
Vector de caracteres de longitud 1 con la sentencia SQL.
}
  \item{res}{
Objeto \code{OraResult}.
}
  \item{data}{
Elemento \code{data.frame} que especifica los datos de enlace
}
  \item{prefetch}{
Valor lógico que especifica si ROracle utiliza buffers de recuperación previa o
    una recuperación de matriz para recuperar los datos del servidor. Si \code{TRUE}, ROracle 
    utiliza buffers de recuperación previa de OCI para recuperar los datos adicionales del servidor 
    y, por lo tanto, guardar la memoria necesaria en RODBI/ROOCI asignando un único buffer de fila 
    para recuperar los datos desde OCI. Se utilizan los resultados de recuperación previa en una llamada de recuperación
    para cada fila. Si \code{FALSE} (valor por defecto), ROracle utiliza una recuperación previa de matriz para 
    recuperar los datos.
}
  \item{bulk_read}{
Valor entero que indica el número de filas que recuperar al mismo tiempo. El 
    valor por defecto es 1000L. Cuando la opción de recuperación previa está seleccionada, la memoria
    se asigna para los buffers de recuperación previa y OCI recupera el número especificado de filas al mismo tiempo.
    Cuando no se utiliza la recuperación previa, opción por defecto, la memoria se asigna en los buffers de definición
    RODBI/ROOCI. Al configurar este valor en un valor grande, hará que exista más memoria asignada
    que se basa en el número de columnas en la lista de selección y los tipos de columnas.
    Para una columna de carácter de tipo, los buffers de definición se asignan
    utilizando el número máximo de ancho con el ancho máximo de NLS. Las aplicaciones deben
    ajustar este valor según el resultado de la consulta. Un valor más grande beneficia
    las consultas que devuelven un resultado mayor. La aplicación puede ajustar este valor según sea necesario.
}
  \item{bulk_write}{
Valor entero que indica el número de filas que escribir al mismo tiempo. El
    valor por defecto es 1000L. Cuando se especifica el valor bulk_write, la memoria
    se asigna para los buffers y OCI escribe esa cantidad de filas al mismo tiempo.
    Si no se utiliza el argumento bulk_write, se utiliza el valor por defecto
    para asignar memoria para los buffers de enlace. Al definir \code{bulk_write} en un valor grande,
    hará que exista más memoria asignada que se basa en el número de columnas
    en la lista de inserción y los tipos de columnas.
}
  \item{\dots}{
No utilizado actualmente.
}
}
\value{
\item{dbSendQuery}{
    Objeto \code{OraResult} cuya clase amplía \code{DBIResult}. Este 
    objeto se utiliza para recuperar datos de una base de datos con la función 
    \code{fetch}.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      Query statement is executed and data is fetched from database.
    }
    \item{dbSendQuery}{
      Query statement is executed, but data needs to be fetched through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{oracleProc}{
      PL/SQL stored procedure or function query statement is executed and 
      result is returned.
    }
    \item{dbClearResult}{
      Resources acquired by the result set are freed.
    }
    \item{dbGetException}{
      Error information is retrieved and then cleaned from the driver.
    }
    \item{execute}{
      Query statement is executed.
    }
  }
}
\details{
\\describe{
    \item{dbGetQuery}{
      Esta función ejecuta una sentencia de consulta y recupera los datos de
      resultados de la base de datos. No se debe utilizar para llamar a consultas PL/SQL.
    }
    \item{dbSendQuery}{
      Esta función ejecuta una sentencia de consulta y devuelve el juego de resultados
      a la aplicación. La aplicación puede entonces realizar operaciones en el juego de resultados.
      No se debe utilizar para llamar a consultas PL/SQL.
    }
     \item{oracleProc}{
      Esta función ejecuta un procedimiento almacenado PL/SQL o una sentencia de consulta
      de función y devuelve el resultado.
    }
    \item{dbClearResult}{
      Esta función libera recursos ocupados por el juego de resultados.
    }
    \item{dbGetException}{
      Esta función recupera la información sobre los errores.
    }
    \item{execute}{
      Esta función ejecuta la sentencia de consulta especificada.
    }
  }
}
\section{References}{
  For the Oracle Database documentation see 
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
                        data1 <- data.frame(deptno = 10), prefetch=TRUE,
                        bulk_read=2L)
    data1 <- fetch(res2, n = -1)
    data1

    res3 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data2 <- data.frame(deptno = 10), bulk_read=10L)
    data2 <- fetch(res3, n = -1)
    data2

    res4 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data3 <- data.frame(deptno = 10), bulk_write=10L)
    data3 <- fetch(res4, n = -1)
    data3

    res5 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data4 <- data.frame(ename = 'SMITH')) 
    data4 <- fetch(res5, n = -1)
    data4
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
