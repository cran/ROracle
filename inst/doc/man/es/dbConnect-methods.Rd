\name{dbConnect-methods}
\docType{methods}
\alias{dbConnect}
\alias{dbDisconnect}
\alias{dbConnect,OraDriver-method}
\alias{dbConnect,ExtDriver-method}
\alias{dbDisconnect,OraConnection-method}
\title{
Crear un Objeto de Conexión a una Instancia de Oracle DBMS
}
\description{
Estos métodos son implantaciones sencillas de las funciones
   genéricas correspondientes.
}
\usage{
\S4method{dbConnect}{OraDriver}(drv, username = "", password = "", dbname = "", prefetch = FALSE,
          bulk_read = 1000L, bulk_write = 1000L, stmt_cache = 0L,
          external_credentials = FALSE, sysdba = FALSE, ...)
\S4method{dbConnect}{ExtDriver}(drv, prefetch = FALSE, bulk_read = 1000L,
          bulk_write = 1000L, stmt_cache = 0L,
          external_credentials = FALSE, sysdba = FALSE, ...)
\S4method{dbDisconnect}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
Objeto de clase \code{OraDriver} o \code{ExtDriver}.
}
  \item{conn}{
Objeto \code{OraConnection} como lo ha producido \code{dbConnect}.
}
  \item{username}{
Cadena de caracteres que especifica un nombre de usuario.
}
  \item{password}{
Cadena de caracteres que especifica una contraseña.
}
  \item{dbname}{
Cadena de caracteres que especifica un identificador de conexión (para obtener más
    información, consulte el capítulo 8 sobre configuración de los métodos de nomenclatura, en Oracle
    Database Net Services Administrator's Guide). Es la misma cadena que la parte
    de la cadena de conexión de SQL*Plus que sigue al signo '@'. 
    Si está utilizando Oracle Wallet para almacenar el nombre de usuario y la contraseña, 
    esta cadena debe ser la cadena de conexión utilizada para crear la 
    asignación de carteras (para obtener más información, consulte la sección sobre configuración de
    clientes para utilizar el almacén de contraseñas externo en el capítulo 3 de Oracle Database Security Guide).
    Los identificadores de conexión para una instancia IMDB de Oracle TimesTen están soportados mediante
    tnsnames de OCI o métodos de nomenclatura de conexión sencilla. Para obtener más información
    sobre conexiones TimesTen para OCI, consulte el capítulo 3 sobre soporte TimesTen para OCI de
    TimesTen In-Memory C Developer's Guide.
    Los ejemplos siguientes muestra distintas formas de especificar el identificador de conexión.
}
  \item{prefetch}{
Valor lógico que indica TRUE o FALSE. Si se define en TRUE, ROracle utilizará
    los buffers de recuperación previa de OCI para recuperar los datos adicionales del servidor y, por lo tanto, guardar
    la memoria necesaria en RODBI/ROOCI asignando un único buffer de fila para recuperar
    los datos desde OCI. Se utilizan los resultados de recuperación previa en una llamada de recuperación para cada fila. Por
    defecto, la recuperación previa es FALSE y la recuperación de matriz se utiliza para recuperar los datos desde
    el servidor.
}
  \item{bulk_read}{
Valor entero que indica el número de filas que recuperar al mismo tiempo. El
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
  \item{bulk_write}{
Valor entero que indica el número de filas que insertar, actualizar o suprimir al mismo tiempo. El
    valor por defecto es 1000L. Cuando el valor bulk_write se especifica en el argumento, la memoria
    se asigna para los buffers y OCI escribirá esa cantidad de filas al mismo tiempo.
    Cuando no se especifica el argumento bulk_write, se utiliza el valor por defecto, 1000,
    para asignar memoria para los buffers de enlace. Al configurar este valor en un valor grande,
    hará que exista más memoria asignada basada en el número de columnas en la lista de inserción y los tipos de columnas.
}
  \item{stmt_cache}{
Valor entero que indica el número de sentencias que almacenar en caché. Significa que 
    los cursores están listos para utilizarse sin tener que volver a analizar las 
    sentencias. El valor por defecto es 0L. Si el valor stmt_cache es mayor que 0L, el valor
    \code{prefetch} se debe definir en TRUE.
}
  \item{external_credentials}{
Valor lógico que indica TRUE o FALSE. Si se define en TRUE, ROracle
    iniciará la sesión de OCI autenticada con las credenciales externas en la conexión.
    El valor por defecto es FALSE.
}
  \item{sysdba}{
Valor lógico que indica TRUE o FALSE. Si se define en TRUE, ROracle
    iniciará la sesión de OCI con privilegios SYSDBA en la conexión. El valor por defecto
    es FALSE.
}
  \item{\dots}{
No utilizado actualmente.
}
}
\value{
\item{dbConnect}{
    Objeto \code{OraConnection} cuya clase amplía \code{DBIConnection}. 
    Este objeto se utiliza para ejecutar consultas SQL en la base de datos.
  }
  \item{dbDisconnect}{
    Valor lógico que indica si la operación se ha realizado correctamente o no.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbConnect}{
      Establishes a connection between R and an Oracle Database server.
    }
    \item{dbDisconnect}{
      Frees resources used by the connection object.
    }
  }
}
      





           
\details{
\\describe{
    \item{dbConnect}{
      Este objeto de conexión se utiliza para ejecutar las operaciones en la base de datos.
      Cuando \code{prefetch} se define en TRUE, permite utilizar el buffer de recuperación previa de OCI
      para recuperar los datos adicionales del servidor.
      El argumento \code{bulk_read} se utiliza para definir un valor entero indicando
      el número de filas que recuperar al mismo tiempo.
      El argumento \code{bulk_write} se utiliza para definir un valor entero que indica
      el número de filas que escribir a la vez.
      El argumento \code{stmt_cache} se utiliza para activar o desactivar la función
      de almacenamiento en caché. Su valor especifica el tamaño de la caché de sentencia.
      El argumento \code{external_credentials} se utiliza para iniciar una sesión de OCI
      autenticada con credenciales externas en la conexión.
      El argumento \code{sysdba} se utiliza para iniciar una sesión de OCI con privilegios SYSDBA
      en la conexión.
      Al establecer una conexión con un controlador \code{ExtDriver}, no se utilizará ninguno
      de los argumentos que especifican las credenciales. Una conexión en este modo
      es un objeto singleton, es decir, todas las llamadas a \code{dbConnect}
      devuelven el mismo objeto de conexión.
    }
    \item{dbDisconnect}{
      Esta implantación desconecta la conexión entre R y el servidor de la base de datos.
      Libera todos los recursos utilizados por el objeto de conexión. Libera
      todos los juegos de resultados asociados a este objeto de conexión.
    }
  }
}
\section{References}{
  For the Oracle Database documentation see
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
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    ## Create an Oracle Database instance and create one connection on the
    ## same machine.
    drv <- dbDriver("Oracle")

    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection to a
    ## remote database using the SID in the connect string. 
    drv <- dbDriver("Oracle")

    ## Refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.
    host <- "myhost"
    port <- 1521
    sid <- "mysid"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
        "(CONNECT_DATA=(SID=", sid, ")))", sep = "")

    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection to a
    ## remote database using the service name.
    drv <- dbDriver("Oracle")

    ## Refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.

    host <- "myhost"
    port <- 1521
    svc <- "mydb.example.com"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
      "(CONNECT_DATA=(SERVICE_NAME=", svc, ")))", sep = "")
    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Use Oracle Wallet authentication.
    con <- dbConnect(drv, username ="", password="", 
    dbname = "<wallet_connect_string>")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Connect to a TimesTen IMDB instance using the easy connect 
    ## naming method where SampleDb is a direct driver TimesTen DSN.
    con <- dbConnect(drv, username ="scott", password="tiger", 
                     dbname = "localhost/SampleDb:timesten_direct")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from dual")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Connect to an extproc (this assumes that the driver has already
    ## been initialized in the embedded R code by passing an external
    ## pointer representing the extproc context).
    con <- dbConnect(Extproc())

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from dual")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Create connection with SYSDBA privileges.
    con <- dbConnect(drv, username ="scott", password="tiger",
                     sysdba = TRUE)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")
    
    ## Use OS authentication as an example of external authentication
    ## Make sure that databse user exist to allow an OS authentication

    ## Create connection authenticated with external credentials.
    con <- dbConnect(drv, username ="", password="",
                     external_credentials = TRUE)
    
    ## Above dbConnect() used OS credentials to connect with database.

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
