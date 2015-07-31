\name{dbGetInfo-methods}
\docType{methods}
\alias{dbGetInfo}
\alias{dbGetStatement}
\alias{dbGetRowCount}
\alias{dbGetRowsAffected}
\alias{dbColumnInfo}
\alias{dbHasCompleted}
\alias{dbGetInfo,OraDriver-method}
\alias{dbGetInfo,ExtDriver-method}
\alias{dbGetInfo,OraConnection-method}
\alias{dbGetInfo,OraResult-method}
\alias{dbGetStatement,OraResult-method}
\alias{dbGetRowCount,OraResult-method}
\alias{dbGetRowsAffected,OraResult-method}
\alias{dbColumnInfo,OraResult-method}
\alias{dbHasCompleted,OraResult-method}
\title{
Metadatos de la Interfaz de la Base de Datos
}
\description{
Estos métodos son implantaciones sencillas de las funciones
   genéricas correspondientes.
}
\usage{
\S4method{dbGetInfo}{OraDriver}(dbObj, ...)
\S4method{dbGetInfo}{ExtDriver}(dbObj, ...)
\S4method{dbGetInfo}{OraConnection}(dbObj, what, ...)
\S4method{dbGetInfo}{OraResult}(dbObj, what, ...)
\S4method{dbGetStatement}{OraResult}(res, ...)
\S4method{dbGetRowCount}{OraResult}(res, ...)
\S4method{dbGetRowsAffected}{OraResult}(res, ...)
\S4method{dbColumnInfo}{OraResult}(res, ...)
\S4method{dbHasCompleted}{OraResult}(res)
}
\arguments{
  \item{dbObj}{
Cualquier objeto que implanta alguna funcionalidad en la interfaz de R
    a las bases de datos (un controlador, una conexión o un juego de resultados).
}
  \item{what}{
Cadena de caracteres que especifica un elemento de la lista de salida.
}
  \item{res}{
\code{OraResult}.
}
  \item{\dots}{
No utilizado actualmente.
}
}


































\details{
Los nombres de tablas, esquemas y columnas son sensibles a mayúsculas/minúsculas, por ejemplo,
  los nombres de las tablas \code{ABC} y \code{abc} no son iguales. Todos los nombres de objetos de esquemas
  de bases de datos no debe incluir comillas dobles, ya que están incluidas en comillas
  dobles cuando se generan las sentencias SQL correspondientes.
  El método \\pkg{ROracle} \code{dbGetInfo} proporciona los siguientes detalles sobre
  el objeto del controlador:
  \itemize{
    \item {\\$driverName} Nombre del controlador, "Oracle (OCI)"
    \item {\\$driverVersion} Versión del controlador ROracle utilizado
    \item {\\$clientVersion} Versión de la biblioteca de Oracle Client utilizada
    \item {\\$conTotal} Número de conexiones que ha instanciado el controlador
    \item {\\$conOpen} Número de conexiones abiertas actualmente
    \item {\\$interruptible} TRUE cuando se puede interrumpir una consulta de ejecución larga
    \item {\\$unicode_as_utf8} TRUE cuando los datos de caracteres se van a recuperar en formato
                              UTF8 codificado
    \item {\\$ora_attributes} TRUE cuando cada columna de un marco de datos del juego de resultados
                             tiene atributos de Oracle DBMS correspondientes
    \item {\\$connections} Información sobre cada conexión abierta actualmente. Consulte
                          \code{dbGetInfo} del objeto de conexión para obtener más información
  }
  El método \\pkg{ROracle} \code{dbGetInfo} proporciona los siguientes detalles
  sobre el objeto de conexión:
  \itemize{
    \item {\\$username} Nombre del usuario en esta conexión
    \item {\\$dbname} Alias de conexión o cadena de conexión utilizada
    \item {\\$serverVersion} Versión del servidor de Oracle Database
    \item {\\$serverType} Valor "Oracle RDBMS"
    \item {\\$resTotal} Número de juegos de resultados en esta conexión
    \item {\\$resOpen} Número de juegos de resultados abiertos en esta conexión
    \item {\\$prefetch} TRUE cuando se utiliza el mecanismo de recuperación previa para recuperar datos
    \item {\\$bulk_read} Número de filas que recuperar a la vez de DBMS
    \item {\\$bulk_write} Número de filas que escribir a la vez en DBMS
    \item {\\$stmt_cache} TRUE cuando se utiliza la caché de sentencias
    \item {\\$results} Información sobre cada juego de resultados actualmente abierto. Consulte
                      \code{dbGetInfo} del juego de resultados para obtener información
  }
  El método \\pkg{ROracle} \code{dbGetInfo} proporciona los siguientes detalles
  sobre el objeto de juego de resultados:
  \itemize{
    \item {\\$statement} Sentencia SQL utilizada para producir el objeto de juego de resultados
    \item {\\$isSelect} TRUE cuando se especifica una sentencia select
    \item {\\$rowsAffected} Número de filas afectadas por la sentencia DML
    \item {\\$rowCount} Número de filas actual en el juego de resultados
    \item {\\$completed} TRUE si no hay más filas en el juego de resultados
    \item {\\$prefetch} TRUE cuando se utiliza el mecanismo de recuperación previa para recuperar los datos
    \item {\\$bulk_read} Número de filas que recuperar a la vez de DBMS
    \item {\\$bulk_write} Número de filas que escribir a la vez en DBMS
    \item {\\$fields} Información sobre cada columna en el juego de resultados. Consulte
                     \code{dbColumnInfo} para obtener información
  }
  El método \\pkg{ROracle} \code{dbColumnInfo} proporciona los siguientes detalles
  sobre cada columna en el juego de resultados:
  \itemize{
    \item {\\$name} Nombre de la columna
    \item {\\$Sclass} Tipo R de objeto que contiene los datos que devuelve
                     Oracle RDBMS
    \item {\\$type} Tipo de columna según se creó en Oracle RDBMS
    \item {\\$len} Longitud del tipo de columna VARCHAR, CHAR y RAW en Oracle RDBMS.
                  El resto de columnas tendrán NA.
    \item {\\$precision} Precisión de la columna NUMBER
    \item {\\$scale} Escala de la columna NUMBER
    \item {\\$nullOK} TRUE cuando se puede presentar un valor NULL en la columna
  }
   En el ejemplo siguiente se muestra la información del controlador, la conexión, el juego de
   resultados e información de la columna de una tabla con:
 \\preformatted{
   create table foo(
     a number(21),
     b number,
     c char(20),
     d varchar(300),
     e binary_double,
     f binary_float,
     g clob,
     h blob,
     i bfile,
     j date,
     m registro de hora,
     n registro de hora con zona horaria,
     o registro de hora con zona horaria local,
     r intervalo de día a segundo,
     s raw(234)
   );
 }
\\preformatted{   library(ROracle)
Cargando paquete necesario: DBI
> # instantiate ROracle driver object
> drv <- Oracle()
> con <- dbConnect(drv, "scott", "tiger")
> rs <- dbSendQuery(con, "select * from foo")
> dbGetInfo(drv)
$driverName
[1] "Oracle (OCI)"
$driverVersion
[1] "1.1-12"
$clientVersion
[1] "11.2.0.4.0"
$conTotal
[1] 1
$conOpen
[1] 1
$interruptible
[1] FALSE
$unicode_as_utf8
[1] TRUE
$ora_attributes
[1] TRUE
$connections
$connections[[1]]
Nombre de usuario:             scott 
Cadena de conexión:         
Versión del servidor:        11.2.0.4.0 
Tipo de servidor:           Oracle RDBMS 
Resultados procesados:     1 
Recuperación previa de OCI:          FALSE 
Lecturas en bloque:             1000 
Escrituras en bloque:            1000 
Tamaño de caché de sentencias:  0 
Resultados abiertos:          1 
> dbGetInfo(con)
$username
[1] "scott"
$dbname
[1] ""
$serverVersion
[1] "11.2.0.4.0"
$serverType
[1] "Oracle RDBMS"
$resTotal
[1] 1
$resOpen
[1] 1
$prefetch
[1] FALSE
$bulk_read
[1] 1000
$bulk_write
[1] 1000
$stmt_cache
[1] 0
$results
$results[[1]]
Sentencia:            select * from foo 
Filas afectadas:        0 
Recuento de filas:            0 
Sentencia Select:     TRUE 
Sentencia terminada:  FALSE 
Recuperación previa de OCI:         FALSE 
Lecturas en bloque:            1000 
Escrituras en bloque:           1000 
> dbGetInfo(rs)
$statement
[1] "select * from foo"
$isSelect
[1] TRUE
$rowsAffected
[1] 0
$rowCount
[1] 0
$completed
[1] FALSE
$prefetch
[1] FALSE
$bulk_read
[1] 1000
$bulk_write
[1] 1000
$fields
   name    Sclass                           type len precision scale nullOK
1     A   numeric                         NUMBER  NA        21     0   TRUE
2     B   numeric                         NUMBER  NA         0  -127   TRUE
3     C character                           CHAR  20         0     0   TRUE
4     D character                       VARCHAR2 300         0     0   TRUE
5     E   numeric                  BINARY_DOUBLE  NA         0     0   TRUE
6     F   numeric                   BINARY_FLOAT  NA         0     0   TRUE
7     G character                           CLOB  NA         0     0   TRUE
8     H       raw                           BLOB  NA         0     0   TRUE
9     I       raw                          BFILE  NA         0     0   TRUE
10    J   POSIXct                           DATE  NA         0     0   TRUE
11    M   POSIXct                      TIMESTAMP  NA         0     6   TRUE
12    N   POSIXct       TIMESTAMP WITH TIME ZONE  NA         0     6   TRUE
13    O   POSIXct TIMESTAMP WITH LOCAL TIME ZONE  NA         0     6   TRUE
14    R  difftime         INTERVAL DAY TO SECOND  NA         2     6   TRUE
15    S       raw                            RAW 234         0     0   TRUE
   }
}
\value{
Información sobre el controlador, la conexión o un objeto de juego de resultados.
}
\section{References}{
  For the Oracle Database documentaion see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
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
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")

    rs <- dbSendQuery(con, "select * from emp")

    # Get the SQL statement for the result set object rs
    dbGetStatement(rs)

    # Are there any more rows in result set?
    dbHasCompleted(rs)

    # Information about columns in result set rs object
    dbColumnInfo(rs)

    # DBIDriver info
    names(dbGetInfo(drv))

    # DBIConnection info
    names(dbGetInfo(con))

    # DBIResult info
    names(dbGetInfo(rs)) 
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
