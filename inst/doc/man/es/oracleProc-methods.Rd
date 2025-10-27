\name{oracleProc-methods}
\docType{methods}
\alias{oracleProc}
\alias{oracleProc,OraConnection,character-method}
\title{
Ejecutar un procedimiento o función PL/SQL almacenado
}
\description{
Este método es una implantación sencilla de la función
   genérica correspondiente.
}
\usage{
\S4method{oracleProc}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
}
\arguments{
  \item{conn}{
Objeto \code{OraConnection}.
}
  \item{statement}{
Vector de caracteres de longitud 1 con la sentencia SQL.
}
  \item{data}{
Elemento data.frame que especifica los datos de enlace.
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
Lista de objetos de marco de datos que contiene registros recuperados de la
  base de datos.
\\details{
  El número de registros recuperado depende de los parámetros \code{OUT} y \code{IN OUT}
  del procedimiento PL/SQL almacenado o de la función en el argumento 
  \code{statement}. 
}
}
\section{References}{
  For Oracle Database documentation see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{dbClearResult}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")

    # creating stored procedure test1 (first IN number, second OUT number)
    dbGetQuery(con, 'create or replace procedure test1
                 (first IN number, second OUT number)
                 is
                 BEGIN
                 select deptno+1 into second from dept where deptno = first;
                 END;')

    # creating data frame for PL/SQL stored procedure call with appropriate 
    # attributes
    test.df <- data.frame(input = 10, output =2L)
    attr(test.df$input, "ora.parameter_mode") <- "IN"
    attr(test.df$output, "ora.parameter_mode") <- "OUT"
    attr(test.df$input, "ora.parameter_name") <- ":input"
    attr(test.df$output, "ora.parameter_name") <- ":output"

    # calling stored procedure test1(first IN number, second OUT number)
    res1 <- oracleProc(con, ' BEGIN test1(:input, :output);
                 END;', test.df)

    # creating stored function test2(first IN number) return second OUT number
    dbGetQuery(con, 'create or replace function test2
                 (first IN number)
                 RETURN number
                 is
                 second number;
                 BEGIN
                 select deptno+1 into second from dept where deptno = first;
                 RETURN second;
                 END;')
 
    # creating data frame for PL/SQL stored function call with appropriate 
    # attributes
    test.df <- data.frame(y = 19, x = 40)
    attr(test.df$x, "ora.parameter_mode") <- "IN"
    attr(test.df$y, "ora.parameter_mode") <- "IN OUT"
    attr(test.df$y, "ora.parameter_name") <- ":output"

    # calling stored function test2(first IN number) return second OUT number
    res2 <- oracleProc(con, 'BEGIN :output := test2(:2); END;', test.df)

    # creating stored procedure test3(first OUT SYS_REFCURSOR)
    dbGetQuery(con, 'create or replace procedure test3
                 (first OUT SYS_REFCURSOR)
                 is
                 BEGIN
                 IF NOT firs
t%ISOPEN
                 THEN
                 OPEN first for SELECT * from dept;
                 END IF;
                 END;')

    # data frame for PL/SQL stored procedure call with cursor as OUT parameter
    # single cursor scenario
    test <- data.frame(x = NA)
    attr(test$x,  "ora.parameter_mode") <- "OUT"
    attr(test$x,  "ora.parameter_name") <- "cur"
    attr(test$x,  "ora.type") <- "cursor"

    # calling stored procedure test3(first OUT SYS_REFCURSOR)
    res3 <- oracleProc(con, ' BEGIN test3(:cur); END;', test)

    # creating stored function test4 return first OUT SYS_REFCURSOR
    dbGetQuery(con, 'create or replace function test4
                 RETURN SYS_REFCURSOR
                 is
                 first SYS_REFCURSOR;
                 BEGIN
                 IF NOT firs
t%ISOPEN
                 THEN
                 OPEN first for SELECT dname from dept ;
                 END IF;
                 RETURN first;
                 END;')

    # data frame for PL/SQL stored function call with cursor as OUT parameter
    test <- data.frame(x = NA, y = 10)
    attr(test$x,  "ora.parameter_mode") <- "OUT"
    attr(test$x,  "ora.parameter_name") <- "cur"
    attr(test$x,  "ora.type") <- "cursor"

    # calling stored function test4 return first OUT SYS_REFCURSOR
    res4 <- oracleProc(con, ' BEGIN :cur := test4(:2); END;', test)

    # multiple cursors case scenario
    # creating stored procedure test5 (first OUT SYS_REFCURSOR,
    # second OUT SYS_REFCURSOR, third OUT SYS_REFCURSOR)
    dbGetQuery(con, 'create or replace procedure test5
                 (first OUT SYS_REFCURSOR, second OUT SYS_REFCURSOR, third OUT SYS_REFCURSOR) is 
                 BEGIN 
                 IF NOT firs
t%ISOPEN THEN 
                 OPEN first for SELECT dname from dept; 
                 END IF; 
                 IF NOT secon
d%ISOPEN THEN 
                 OPEN second for SELECT * from dept; 
                 END IF; 
                 IF NOT thir
d%ISOPEN THEN 
                 OPEN third for SELECT deptno, dname, loc from dept where deptno = 10; 
                 END IF;  
                 END;')

    # data frame for 3 cursors
    test <- data.frame(x = NA, y = NA, z = NA)
    attr(test$x,  "ora.parameter_mode") <- "OUT"
    attr(test$x,  "ora.parameter_name") <- "cur1"
    attr(test$x,  "ora.type") <- "cursor"
    attr(test$y,  "ora.parameter_mode") <- "OUT"
    attr(test$y,  "ora.parameter_name") <- "cur2"
    attr(test$y,  "ora.type") <- "cursor"
    attr(test$z,  "ora.parameter_mode") <- "OUT"
    attr(test$z,  "ora.parameter_name") <- "cur3"
    attr(test$z,  "ora.type") <- "cursor"

    # calling stored procedure test5 (first OUT SYS_REFCURSOR, 
    # second OUT SYS_REFCURSOR, third OUT SYS_REFCURSOR)
    res5 <- oracleProc(con, ' BEGIN test5(:cur1, :cur2, :cur3);  END;', test)
  } 
}
\keyword{methods}
\keyword{database}
\keyword{interface}
