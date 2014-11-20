\name{dbReadTable-methods}
\docType{methods}
\alias{dbReadTable}
\alias{dbWriteTable}
\alias{dbExistsTable}
\alias{dbRemoveTable}
\alias{dbListTables}
\alias{dbListFields}
\alias{dbReadTable,OraConnection,character-method}
\alias{dbWriteTable,OraConnection,character,data.frame-method}
\alias{dbExistsTable,OraConnection,character-method}
\alias{dbRemoveTable,OraConnection,character-method}
\alias{dbListTables,OraConnection-method}
\alias{dbListFields,OraConnection,character-method}
\title{
Funciones Prácticas para Manipular Tablas de DBMS
}
\description{
Estas funciones imitan a los equivalentes de R 
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} y
  \code{names},
  salvo en el hecho de que generan código que se ejecuta de manera remota en un motor
  de base de datos.
}
\usage{
\S4method{dbReadTable}{OraConnection,character}(conn, name, schema = NULL, row.names = NULL, ...)
\S4method{dbWriteTable}{OraConnection,character,data.frame}(conn, name, value, row.names = FALSE, overwrite = FALSE,
             append = FALSE, ora.number = TRUE, schema = NULL, ...)
\S4method{dbExistsTable}{OraConnection,character}(conn, name, schema = NULL, ...)
\S4method{dbRemoveTable}{OraConnection,character}(conn, name, purge = FALSE, schema = NULL, ...)
\S4method{dbListTables}{OraConnection}(conn, schema = NULL, all = FALSE, full = FALSE, ...)
\S4method{dbListFields}{OraConnection,character}(conn, name, schema = NULL, ...)
}
\arguments{
  \item{conn}{
Objeto de conexión de la base de datos \code{OraConnection}.
}
  \item{name}{
Cadena de caracteres sensible a mayúsculas/minúsculas que especifica un nombre de tabla.
}
  \item{schema}{
Cadena de caracteres sensible a mayúsculas/minúsculas que especifica un nombre de esquema (o un
    vector de cadenas de caracteres para \code{dbListTables}).
}

  \item{row.names}{
En el caso de \code{dbReadTable}, este argumento puede ser una cadena, un
    índice o un vector lógico que especifica la columna en la tabla DBMS que
    se utilizará como \code{row.names} en el elemento data.frame de salida, (\code{NULL}
    especifica que no se debe utilizar ninguna columna como \code{row.names} en la
    salida). El valor por defecto es \code{NULL}.
    En el caso de \code{dbWriteTable}, este argumento debe ser un valor
    lógico que especifique si \code{row.names} debe ser una salida a la
    tabla DBMS de salida; si \code{TRUE}, una columna adicional cuyo nombre es 
    \code{"row.names"}, se agregará a la salida. El valor por defecto es
    \code{FALSE}.
}
  \item{value}{
\code{data.frame} que contiene los datos para escribir en una tabla. (Consulte
    la sección Detalles para ver los tipos de columna soportados.)
}
  \item{overwrite}{
Valor lógico que especifica si se debe sobrescribir una tabla existente
    o no. El valor por defecto es \code{FALSE}.
}
  \item{append}{
Valor lógico que especifica si se debe agregar a una tabla existente
    en DBMS. El valor por defecto es \code{FALSE}.
}
  \item{ora.number}{
Valor lógico que especifica si se debe crear una tabla con columnas
    \code{NUMBER} o \code{BINARY_DOUBLE} de Oracle al escribir datos numéricos.
     Especifique \code{TRUE} para crear una tabla con valores de Oracle \code{NUMBER}
    o especifique \code{FALSE} para crear una tabla con valores de Oracle
    \code{BINARY_DOUBLE}. El valor por defecto es \code{TRUE}.
    Especifique \code{FALSE} si uno o varios de los valores de datos numéricos
    son \code{NaN}.
}
  \item{purge}{
Valor lógico que especifica si se debe agregar la opción \code{PURGE} a la
    sentencia \code{DROP TABLE} SQL.
}
  \item{all}{
Valor lógico que especifica si se deben consultar todos los esquemas.
}
  \item{full}{
Valor lógico que especifica si se deben generar nombres de esquema. Cuando el argumento
    \code{all} es \code{TRUE}, la salida es un vector que contiene los nombres de esquema
    seguidos de los nombres de tabla. Al utilizar \code{matrix(..., ncol = 2)}
    en la salida, se produce una matriz en la que cada fila corresponde a una
    tabla y las columnas representan los nombres de esquema y los nombres de tabla
    respectivamente.
}
  \item{\dots}{
no utilizado actualmente.
}
}





   


\details{
Los nombres de tabla, esquema y columna son sensibles a mayúsculas/minúsculas, por ejemplo, los nombres
  de tabla \code{ABC} y \code{abc} no son los mismos. Todos los nombres de objeto
  de esquema de base de datos no se deben escribir entre comillas, ya que cuando están entre comillas, se generará
  la sentencia SQL correspondiente.
  Los métodos \\pkg{ROracle} como \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} y \code{dbWriteTable} utilizan la siguiente asignación
  entre los tipos de dato de \R y de Oracle:
  \itemize{
    \item \code{logical} y \code{integer} se asignan a Oracle \code{INTEGER}
    \item \code{numeric} se asigna a Oracle \code{NUMBER} si el argumento
    \code{ora.number} es \code{TRUE} u Oracle  \code{BINARY_DOUBLE} si
    \code{FALSE}
    \item \code{character} se asigna a Oracle \code{VARCHAR2(4000)}
    \item \code{Date} y \code{POSIXct} se asigna a Oracle \code{DATE}
    \\pkg{ROracle}: paquete ROracle
    \R: aplicación de R
    \code{POSIXct}: clase POSIXct
    \code{TIMESTAMP}
    \code{TIMESTAMP WITH TIME ZONE}
    \code{TIMESTAMP WITH LOCAL TIME ZONE}
    \item \code{difftime} se asigna a Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} de los vectores \code{raw} se asigna a Oracle \code{RAW(2000)}
    \item otros tipos de \R como \code{factor} se convierten a
    \code{character}
  }
   ROracle devuelve valores desde las columnas de la base de datos que forman parte del tipo de dato: fecha,
   registro de hora, registro de hora con zona horaria y registro de hora con zona horaria local
   en el formato POSIXct de R. POSIXct hace referencia a una hora
   que se almacena internamente como el número de segundos desde el principio de
   1970 en UTC. El número de segundos se intercambia entre el controlador de R y ROracle en
   formato doble de punto flotante. En la representación POSIXct, R utiliza la variable de entorno TZ
   o se asigna a sí mismo la variable de entorno de zona horaria del sistema operativo,
   por lo tanto, la fecha aparecerá en este formato de zona horaria.
   Un usuario puede insertar datos en columnas de los 4 tipos de dato mostrados anteriormente que utilizan 
   una cadena con el formato correcto o la representación POSIXct. Los datos de cadena se
   transfieren a la base de datos directamente y ROracle se basa en una base de datos para convertirla
   a una representación de fecha y hora. Los datos POSIXct se pueden convertir a un descriptor
   interno DateTime de Oracle agregando el principio de 1970 UTC al número
   de segundos que se obtiene de R. Cualquier variable de POSIXct en la sentencia
   de inserción se enlazan como SQLT_TIMESTAMP_TZ.
   Cuando estos tipos de dato se seleccionan desde Oracle, éstos se convierten a formato POSIXct
   restando el principio de 1970 UTC. Cuando el cliente de ROracle y la
   base de datos tienen archivos de versión de zona horaria diferentes y una aplicación utiliza los
   tipos de dato de zona horaria, se recomienda que sean los mismos, ya que la región
   puede haber cambiado su zona. ROracle informará de un error en este caso, ya que
   puede provocar la pérdida y corrupción de información al trabajar con estos
   tipos de dato.
   ROracle recupera las columnas con el tipo de dato de registro de fecha y hora mediante el tipo de dato
   SQLT_TIMESTAMP. Las columnas de los tipos de dato de registro de hora con zona horaria y
   de registro de hora con zona horaria local se recuperarán mediante el tipo de dato
   SQLT_TIMESTAMP_TZ. Las columnas de zona horaria de tipo de dato con zona horaria local
   experimentan una conversión a la zona horaria de la sesión que ejecuta la aplicación R
   configurando así TZ de entorno de zona horaria en R y afectando a los valores de datos
   de esta columna. El controlador de ROracle no asigna la variable de entorno TZ
   a la zona horaria de la sesión y
   no emite una DDL de modificación para definir la zona horaria de la sesión. Para
   recuperar datos de columnas con registro de hora de zona horaria y registro de hora de
   zona horaria local, el cliente y el servidor deben tener el mismo archivo de datos de zona horaria,
   de lo contrario, se informará de un error.
   El siguiente ejemplo muestra el efecto de cambiar la zona horaria en el entorno de R:
   \\preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # Seleccionar datos y mostrarlos
   res <- dbGetQuery(con, selStr)
   R>     res[,1]
   [1] 1 2 3 4 5 6
   R>     res[,2]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:02 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R>     res[,3]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:03 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R>     res[,4]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:03 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R>     res[,5]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:03 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R> Sys.setenv(TZ='EST5EDT')
   R>     res[,1]
   [1] 1 2 3 4 5 6
   R>     res[,2]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:02 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"
   R>     res[,3]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:03 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"
   R>     res[,4]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:03 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"
   R>     res[,5]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:03 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"}
  De la misma forma, \code{dbWriteTable} siempre confirma automáticamente una transacción actual, de la misma forma
  que inserta los datos, es decir, actúa como una sentencia DDL, incluso si
  agrega filas a una tabla ya existente.
}
\value{
\code{data.frame} en caso de \code{dbReadTable};
  \code{vector} en caso de \code{dbListTables} y
  \code{dbListFields};
  \code{logical} en caso de \code{dbExistsTable} que indica
  si la tabla existe;
  de lo contrario \code{TRUE} cuando la operación ha sido correcta o
  una excepción.
}
\section{References}{
  For the Oracle Database documentation see 
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
  For Datetime Data Types and Time Zone Support in Oracle see
  \url{http://docs.oracle.com/cd/E14072_01/server.112/e10729/ch4datetime.htm}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}}.
}
\examples{
  \dontrun{
    con <- dbConnect(Oracle(), "scott", "tiger")
    if (dbExistsTable(con, "FOO", "SCOTT"))
      dbRemoveTable(con, "FOO")

    foo <- dbReadTable(con, "EMP")
    row.names(foo) <- foo$EMPNO
    foo <- foo[,-1]

    dbWriteTable(con, "FOO", foo, row.names = TRUE)
    dbWriteTable(con, "FOO", foo, row.names = TRUE, overwrite = TRUE)
    dbReadTable(con, "FOO", row.names = 1)

    dbGetQuery(con, "delete from foo")
    dbWriteTable(con, "FOO", foo, row.names = TRUE, append = TRUE)
    dbReadTable(con, "FOO", row.names = 1)
    dbRemoveTable(con, "FOO")

    dbListTables(con)
    dbListFields(con, "EMP")

    if (dbExistsTable(con, "RORACLE_TEST", "SCOTT"))
      dbRemoveTable(con, "RORACLE_TEST")

    # example of POSIXct usage
    # A table is created using:
    createTab <- "create table RORACLE_TEST(row_num number, id1 date,
                 id2 timestamp, id3 timestamp with time zone, 
                 id4 timestamp with local time zone )"

    dbGetQuery(con, createTab)
    # Insert statement
    insStr <- "insert into RORACLE_TEST values(:1, :2, :3, :4, :5)";

    # Select statement
    selStr <- "select * from RORACLE_TEST";

    # Insert time stamp without time values in POSIXct form
    x <- 1; 
    y <- "2012-06-05";
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    # Insert date & times stamp with time values in POSIXct form
    x <- 2;
    y <- "2012-01-05 07:15:02";
    y <- as.POSIXct(y);
    z <- "2012-01-05 07:15:03.123";
    z <- as.POSIXct(z);
    dbGetQuery(con, insStr, data.frame(x, y, z,  z, z));

    # Insert list of date objects in POSIXct form
    x <- c(3, 4, 5, 6);
    y <- c('2012-01-05', '2011-01-05', '2013-01-05', '2020-01-05');
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    dbCommit (con)

    # Selecting data and displaying it
    res <- dbGetQuery(con, selStr)
    res[,1]
    res[,2]
    res[,3]
    res[,4]
    res[,5]
  }
  \dontrun{
    df <- data.frame(A=c(0,1,NaN,4), B=c(NA, 2,3,NaN))
    con <- dbConnect(Oracle(), "scott", "tiger")
    dbWriteTable(con,"TEST", df, row.names = FALSE, ora.number=FALSE)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
