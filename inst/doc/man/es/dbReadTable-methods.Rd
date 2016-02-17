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
Estas funciones imitan a los equivalentes de R salvo en el hecho de que generan 
  código que se ejecuta de manera remota en un motor de base de datos:
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} y
  \code{names}.
}
\usage{
\S4method{dbReadTable}{OraConnection,character}(conn, name, schema = NULL, row.names = NULL, ...)
\S4method{dbWriteTable}{OraConnection,character,data.frame}(conn, name, value, row.names = FALSE, overwrite = FALSE,
             append = FALSE, ora.number = TRUE, schema = NULL, date = FALSE, ...)
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
  \item{date}{
Indicador booleano para determinar si se va a utilizar date o DateTime.
    Por defecto, se utilizará DateTime en lugar de timestamp.
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
Los nombres de tabla, esquema y columna son sensibles a mayúsculas/minúsculas, por ejemplo,
  los nombres \code{ABC} y \code{abc} no son iguales. Los nombres de objeto
  de esquema de base de datos no deben incluir comillas dobles, ya que se escriben
   entre comillas cuando se genera la sentencia SQL correspondiente.
   Se utilizan los siguientes atributos para asignar las columnas BLOB, CLOB, NCLOB, NCHAR, VARCHAR2,
   NVARCHAR2, CHAR, TIMESTAMP WITH TIME ZONE y TIMESTAMP WITH LOCAL TIME ZONE
   de forma correcta en \code{dbWriteTable}:
   1) Nombre de Atributo: \code{ora.type}
   Este atributo indicará el tipo de columna subyacente y puede ser
   "CLOB", "BLOB", "CHAR", "VARCHAR2" o "RAW". El usuario puede especificar
   TIMESTAMP, DATE, TIMESTAMP WITH TIME ZONE o cualquier otro tipo de columna
   soportado por Oracle Database. ROracle no lo analizará y dejará que
   lo valide la base de datos. El usuario puede proporcionar los siguientes
   valores de \code{ora.type}: CLOB, BLOB, CHAR, TIMESTAMP WITH TIME
   ZONE, TIMESTAMP WITH LOCAL TIME ZONE y fractional_seconds_precision.
   2) Nombre de Atributo: \code{ora.encoding}
   Cuando se especifique UTF-8, la base de datos utilizará NCLOB, NCHAR o NVARCHAR basándose en
   \code{ora.type}.
   3) Nombre de Atributo: \code{ora.maxlength}
   Se puede especificar una longitud máxima de columnas CHAR, VARCHAR, NCHAR, NVARCHAR2 o
   RAW. Para otros tipos de dato, \code{ora.maxlength} no se aplica
   y se ignorará. Se utilizan los siguientes valores por defecto para
   determinados tipos de dato cuando no se especifica \code{ora.maxlength}.
   CHAR                                       2000
   NCHAR                                      1000
   VARCHAR2                                   4000
   NVARCHAR2                                  2000
   RAW                                        2000
   4) Nombre de Atributo: \code{ora.fractional_seconds_precision}
   Se puede especificar la parte fraccional del campo de fecha y hora SECOND de
   las columnas TIMESTAMP, TIMESTAMP WITH TIME ZONE y TIMESTAMP WITH
    LOCAL TIME ZONE. Puede ser un número en el rango de 0 a 9. El valor por defecto es 6.
  Los métodos \\pkg{ROracle} como \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} y \code{dbWriteTable} utilizan la siguiente asignación
  entre los tipos de dato \R y Oracle:
  \itemize{
    \item \code{logical} y \code{integer} se asignan a Oracle \code{INTEGER}
    \item \code{numeric} se asigna a Oracle \code{NUMBER} si el argumento
    \code{ora.number} es \code{TRUE} u Oracle \code{BINARY_DOUBLE} si
    \code{FALSE}
    \item \code{character} se asigna a Oracle \code{CLOB} si el atributo 
    \code{ora.type} es \code{"CLOB"} u Oracle \code{NCLOB} si el atributo
    \code{ora.type} es \code{"CLOB"} y \code{ora.encoding} es \code{"UTF-8"}
    u Oracle \code{CHAR(ora.maxlength)} si el atributo \code{ora.type} es 
    \code{"CHAR"} u Oracle \code{NCHAR(ora.maxlength)} si el atributo 
    \code{ora.type} es \code{"CHAR"} y \code{ora.encoding} es \code{"UTF-8"}
    u Oracle \code{NVARCHAR2(ora.maxlength)} si el atributo \code{ora.encoding}
    es \code{"UTF-8"} u Oracle \code{VARCHAR2(ora.maxlength)}
    \item \code{Date} y \code{POSIXct} se asignan a Oracle \code{DATE}
    \\pkg{ROracle}: Paquete ROracle
    \R: aplicación R
    \item \code{POSIXct} se asigna a Oracle 
    \code{TIMESTAMP WITH TIME ZONE(ora.fractional_seconds_precision)} si 
    el atributo \code{ora.type} es \code{"TIMESTAMP WITH TIME ZONE"} u Oracle 
    \code{TIMESTAMP WITH LOCAL TIME ZONE(ora.fractional_seconds_precision)} si
    el atributo \code{ora.type} es \code{"TIMESTAMP WITH LOCAL TIME ZONE"} u
    Oracle \code{TIMESTAMP(ora.fractional_seconds_precision)} y si 
    \code{Date} es \code{FALSE} 
    \item \code{difftime} se asigna a Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} de \code{raw} vectores se asignan a Oracle \code{BLOB} si 
    el atributo \code{ora.type} es \code{"BLOB"} u Oracle 
    \code{RAW(ora.maxlength)}
    \item otros tipos de \R como \code{factor} se convierten a
    \code{character}
  }
   ROracle devuelve valores de las columnas de base de datos que son del tipo de dato: fecha,
   registro de hora, registro de hora con zona horaria y registro de hora con zona horaria local
   en el formato POSIXct de R. POSIXct hace referencia a una hora
   que se almacena internamente como el número de segundos desde el principio de
   1970 en UTC. El número de segundos se intercambia entre el controlador de R y ROracle en
   formato doble de punto flotante. En la representación POSIXct, R utiliza la variable de entorno TZ
   o se asigna a sí mismo la variable de entorno de zona horaria del sistema operativo,
   por lo que la fecha aparecerá en este formato de zona horaria.
   Un usuario puede insertar datos en columnas de los 4 tipos de dato mostrados anteriormente
   con una cadena con el formato correcto o la representación POSIXct. Los datos de cadena se
   transfieren a la base de datos directamente y ROracle se basa en una base de datos para convertirlos
   en una representación de fecha y hora. El controlador de ROracle convierte la representación de POSIXct
  en una representación de cadena con el formato
   "\%Y-\%m-\%d \%H:\%M:\%OS6" en un marco de datos que se utiliza para operaciones DML.
   Los datos de este formato se corresponden con NLS_TIMESTAMP_TZ_FORMAT
   "AAAA-MM-DD HH24:MI:SSXFF" y se convierten en SQLT_TIMESTAMP_LTZ para
   enlazarse a la base de datos Oracle. Se crea una clase "datetime" intermedia.
   que representa los datos de caracteres para el controlador de ROracle de forma interna.
   ROracle recupera las columnas con el tipo de dato de registro de fecha y hora mediante el tipo de dato
   SQLT_TIMESTAMP. Las columnas de los tipos de dato de registro de hora con zona horaria o
   de registro de hora con zona horaria local se recuperarán mediante el tipo de dato
   SQLT_TIMESTAMP_LTZ. Las columnas de zona horaria de tipo de dato con zona horaria local
   experimentan una conversión a la zona horaria de la sesión en la que se ejecuta la aplicación R
   por lo que la configuración del entorno de zona horaria TZ en R afectará a los valores de datos
   de esta columna. El controlador de ROracle asigna la variable de entorno TZ
   a la zona horaria de la sesión y emite una DDL de modificación para definir la zona horaria de la sesión
   cuando se establece la conexión con la base de datos.
   Para recuperar datos de columnas con registro de hora de zona horaria o registro de hora de
   zona horaria local, el cliente y el servidor deben tener el mismo archivo de datos de zona horaria,
   ya que, de lo contrario, se notificará que hay un error.
   Cuando se seleccionan estos tipos de dato de la base de datos, se convierten en
   una representación de cadena con el valor NLS_TIMESTAMP_TZ_FORMAT
   "AAAA-MM-DD HH24:MI:SSXFF" que se corresponde con "\%Y-\%m-\%d \%H:\%M:\%OS6"
   en R. Se crea una clase intermedia "datetime"
   para representar estos datos de caracteres en el controlador de ROracle. Este controlador
   los convierte a continuación en POSIXct con la función as.POSIXct(). Una aplicación R
   observa los datos en formato POSIXct en el marco de datos.
   \\preformatted{
Zona horaria de la sesión de R:
 R tiene el concepto de una zona horaria en la que se utiliza el motor de R. La zona
 horaria se puede definir en una cadena, como 'PST8PDT', 'America/Los_Angeles', etc.
 Estas cadenas se explican por sí mismas y especifican la zona horaria en la que
 se está ejecutando la sesión.
 La zona horaria de la sesión de R se puede definir de una de estas dos formas:
 1. Introduciendo lo siguiente en la línea de comandos de Linux o Unix antes de iniciar
    R:
    setenv TZ = America/Los_Angeles en Linux/UNIX
    NOTA: No utilice esta opción en Windows, ya que no permite
          definir nombres de zonas horarias compatibles con Oracle para la variable de entorno TZ.
 2. Introduciendo lo siguiente en la petición de datos de R:
    Sys.setenv(TZ = "PST8PDT")
 Recomendamos utilizar la opción 2, ya que el script de R funciona sin ningún
 problema de migración en Linux/Unix, así como en Windows. La opción 2 también permite
 especificar nombres de zonas horarias compatibles con Oracle, incluso en Windows.
 La zona horaria de la sesión de R determina la zona horaria para todos los tipos de fecha-hora no cualificados
 de zona horaria POSIXct. También es la zona horaria en la que se convierten todos los
 tipos de fecha-hora cualificados cuando se muestran en R.
 El siguiente ejemplo muestra esto.
 Sys.setenv(TZ = "PST8PDT")
 dt <- c(as.POSIXct("2010/3/13", tz = "PST8PDT"),
         as.POSIXct("2010/3/13 3:47:30.123456", tz = "PST8PDT"),
         as.POSIXct("2010/3/22", tz = "PST8PDT"),
         as.POSIXct("2010/3/22 7:02:30", tz = "PST8PDT"),
         as.POSIXct("2010/3/13"),
         as.POSIXct("2010/3/13 3:47:30.123456"),
         as.POSIXct("2010/3/22"),
         as.POSIXct("2010/3/22 7:02:30"))
 dt
 [1] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
 [3] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
 [5] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
 [7] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
Tenga en cuenta que también se asume que los registros de hora no cualificados están en la
zona horaria de la sesión de R cuando los muestra R. Por supuesto, R también es lo
suficientemente inteligente como para determinar si la hora está en PST o en PDT
según cuándo comience el cambio de horario de verano de EE.UU. y muestra PST o PDT
según corresponda.
En el siguiente ejemplo se muestra esto más claramente.
> Sys.setenv(TZ = "EST5EDT")
> dt <- c(as.POSIXct("2010/3/13", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13 3:47:30.123456", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22 7:02:30", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13"),
+         as.POSIXct("2010/3/13 3:47:30.123456"),
+         as.POSIXct("2010/3/22"),
+         as.POSIXct("2010/3/22 7:02:30"))
> dt
[1] "2010-03-13 03:00:00.000000 EST" "2010-03-13 06:47:30.123456 EST"
[3] "2010-03-22 03:00:00.000000 EDT" "2010-03-22 10:02:30.000000 EDT"
[5] "2010-03-13 00:00:00.000000 EST" "2010-03-13 03:47:30.123456 EST"
[7] "2010-03-22 00:00:00.000000 EDT" "2010-03-22 07:02:30.000000 EDT"
Tenga en cuenta que también se asume que los registros de hora no cualificados están en la
zona horaria de la sesión. Sin embargo, incluso los registros de hora
cualificados de la zona horaria se convierten en la zona horaria de la sesión y se muestran. Tenga en cuenta que
todos los valores los muestra R en la zona horaria de la sesión de R (con el nombre de zona horaria
también modificado a EST o EDT para representar
el cambio de horario de verano según corresponda). Consulte la sección sobre clases Date-Time en
http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html
y sobre las zonas horarias en:
http://stat.ethz.ch/R-manual/R-devel/library/base/html/timezones.html
para obtener información sobre cómo R gestiona las fechas y horas y las zonas horarias)
En el siguiente ejemplo se utiliza un nombre de zona horaria más largo
(al que se suele conocer como 'Nombre Olson'), en lugar de una abreviatura.
> Sys.setenv(TZ = "America/Los_Angeles")
> dt <- c(as.POSIXct("2010/3/13", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13 3:47:30.123456", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22 7:02:30", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13"),
+         as.POSIXct("2010/3/13 3:47:30.123456"),
+         as.POSIXct("2010/3/22"),
+         as.POSIXct("2010/3/22 7:02:30"))
> dt
[1] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
[3] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
[5] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
[7] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
Tenga en cuenta que, en ese caso, R no utiliza el nombre largo cuando se
muestran los valores, sino que sigue mostrando los valores con
las abreviaturas "PST" y "PDT". Esto es significativo porque Oracle
no siempre acepta estas abreviaturas. Por ejemplo, una base
de datos Oracle no reconoce "PDT" como zona horaria válida. Consulte la sección sobre
la zona horaria de R y la zona horaria de la sesión de Oracle para obtener información sobre las zonas horarias válidas.
}
   El siguiente ejemplo muestra el efecto de cambiar la zona horaria en el entorno
   de R:
   \\preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # Selecting data and displaying it
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
  De la misma forma, \code{dbWriteTable} siempre confirma automáticamente
   una transacción actual, así como los datos que esta inserta,
   es decir, actúa como una sentencia DDL, incluso aunque agregue filas a una tabla ya existente.
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
  \url{http://docs.oracle.com/cd/E11882_01/server.112/e10729/ch4datetime.htm}.
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

    # Example of POSIXct usage.
    # A table is created using:
    createTab <- "create table RORACLE_TEST(row_num number, id1 date,
                 id2 timestamp, id3 timestamp with time zone, 
                 id4 timestamp with local time zone )"

    dbGetQuery(con, createTab)
    # Insert statement.
    insStr <- "insert into RORACLE_TEST values(:1, :2, :3, :4, :5)";

    # Select statement.
    selStr <- "select * from RORACLE_TEST";

    # Insert time stamp without time values in POSIXct form.
    x <- 1; 
    y <- "2012-06-05";
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    # Insert date & times stamp with time values in POSIXct form.
    x <- 2;
    y <- "2012-01-05 07:15:02";
    y <- as.POSIXct(y);
    z <- "2012-01-05 07:15:03.123";
    z <- as.POSIXct(z);
    dbGetQuery(con, insStr, data.frame(x, y, z,  z, z));

    # Insert list of date objects in POSIXct form.
    x <- c(3, 4, 5, 6);
    y <- c('2012-01-05', '2011-01-05', '2013-01-05', '2020-01-05');
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    dbCommit (con)

    # Selecting data and displaying it.
    res <- dbGetQuery(con, selStr)
    res[,1]
    res[,2]
    res[,3]
    res[,4]
    res[,5]

    # insert data in Date format
    a<-as.Date("2014-01-01")
    dbWriteTable(con, 'TEMP', data.frame(a), date = TRUE)

    # using attribute to map NCHAR, CLOB, BLOB, NCLOB columns correctly in 
    # dbWriteTable
    str1 <- paste(letters, collapse="")
    lstr1 <- paste(rep(str1, 200), collapse="")
    raw.lst <- vector("list",1)
    lraw.lst <- vector("list",1)
    raw.lst[[1L]] <- charToRaw(str1)
    lraw.lst[[1L]] <- rep(charToRaw(str1), 200)
    a <- as.POSIXct("2014-01-01 14:12:09.0194733")
    b <- as.POSIXct("2014-01-01 14:12:09.01947")
    test.df <- data.frame(char=str1, nchar=str1, varchar=str1, clob=lstr1,
                      nclob=lstr1, stringsAsFactors=FALSE)
    test.df$raw.typ <- raw.lst
    test.df$blob <- lraw.lst
    test.df$char_max <- str1 
    test.df$raw_max.typ <- raw.lst
    test.df$nvchar <- str1
    test.df$nvchar_max <- str1
    test.df$date_tz <- a
    test.df$date_ltz <- b

    # adding attributes
    attr(test.df$clob, "ora.type") <- "CLOB"
    attr(test.df$blob, "ora.type") <- "BLOB"
    attr(test.df$nclob, "ora.type") <- "CLOB"
    attr(test.df$nclob, "ora.encoding") <- "UTF-8"
    attr(test.df$char_max, "ora.maxlength") <- 3000
    attr(test.df$raw_max.typ, "ora.maxlength") <- 1000
    attr(test.df$nvchar, "ora.encoding") <- "UTF-8"
    attr(test.df$nvchar_max, "ora.encoding") <- "UTF-8"
    attr(test.df$nvchar_max, "ora.maxlength") <- 1500
    attr(test.df$char, "ora.type") <- "CHAR"
    attr(test.df$date_tz, "ora.type") <- "timestamp with time zone"
    attr(test.df$date_ltz, "ora.type") <- "timestamp with local time zone"
    attr(test.df$nchar, "ora.type") <- "CHAR"
    attr(test.df$nchar, "ora.encoding") <- "UTF-8"
    attr(test.df$date_tz, "ora.fractional_seconds_precision") <- 9
R> # displaying the data frame
R> test.df
char                         nchar
1 abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz
varchar
1 abcdefghijklmnopqrstuvwxyz
clob
1 abcdefghijklmnopqrstuvwxyz...
nclob
1 abcdefghijklmnopqrstuvwxyz...
raw.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
blob
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a,...
char_max
1 abcdefghijklmnopqrstuvwxyz
raw_max.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
nvchar                       nvchar_max
1 abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz
date_tz                      date_ltz
1 2014-01-01 14:12:09.019473 2014-01-01 14:12:09.01946

    dbWriteTable(con, name="TEST_TAB", value=test.df)
    res <- dbReadTable(con, name="TEST_TAB")
R> res
char
1 abcdefghijklmnopqrstuvwxyz
nchar
1 abcdefghijklmnopqrstuvwxyz
varchar
1 abcdefghijklmnopqrstuvwxyz
clob
1 abcdefghijklmnopqrstuvwxyz...
nclob
1 abcdefghijklmnopqrstuvwxyz...
raw.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
blob
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a,...
char_max                                                                                           
1 abcdefghijklmnopqrstuvwxyz
raw_max.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
nvchar                       nvchar_max
1 abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz
date_tz                      date_ltz
1 2014-01-01 14:12:09.019473 2014-01-01 14:12:09.01946
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
