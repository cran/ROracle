\name{Oracle}
\alias{Oracle}
\alias{Extproc}
\title{
Instanciar un Cliente de Oracle desde la Sesión Actual \R
}
\description{
Esta función crea e inicializa un cliente de Oracle desde la
  sesión actual \R. Devuelve un objeto que permitirá conectarse a
  uno o más servidores de Oracle.
}
\usage{
  Oracle(interruptible = FALSE, unicode_as_utf8 = TRUE,
         ora.attributes = FALSE, ora.objects = FALSE)
  Extproc(extproc.ctx = NULL)
}
\arguments{
  \item{interruptible}{
Lógica que indica si el usuario puede interrumpir consultas de
    larga duración.
}
  \item{extproc.ctx}{
Contexto extproc de envoltorio de puntero externo.
}
  \item{unicode_as_utf8}{
Lógica que indica si se van a recuperar los datos de NCHAR, NVARCHAR y NCLOB
    codificados en UTF8.
}
  \item{ora.attributes}{
Lógica que indica si se van a incluir los atributos \code{ora.encoding},
    \code{ora.type} y \code{ora.maxlength} en los marcos de datos que devuelve
    \code{dbGetQuery} y \code{fetch}.
}
  \item{ora.objects}{
Lógica que indica si se permite el acceso a tablas con tipos de objeto,
    como recopilaciones, varrays y tipos definidos por el usuario.
}
}
\value{
Objeto de la clase \code{OraDriver} para \code{Oracle} o
  \code{ExtDriver} para \code{Extproc} cuya clase se amplía a \code{DBIDriver}.
  Este objeto se usa para crear conexiones con la función
  \code{dbConnect} a uno o más motores de bases de datos Oracle.
}
\section{Side Effects}{
  The \R client part of the database communication is initialized,
  but note that connecting to the database engine needs to be done through
  calls to \code{\link[DBI]{dbConnect}}.
}




\details{
Este objeto es un singleton, es decir, en llamadas posteriores,
  devuelve el mismo objeto inicializado. 
  Esta implantación permite conectarse a varios servidores host y
  ejecutar varias conexiones en cada servidor de manera simultánea.
  Cuando \code{interruptible} se define como TRUE, permite la interrupción de consultas
  de larga duración en el servidor, al ejecutar la consulta en un thread. El thread principal
  comprueba Ctrl-C y emite OCIBreak/OCIReset para cancelar la operación en
  el servidor. Por defecto, \code{interruptible} es FALSE.
  Cuando \code{unicode_as_utf8} se define en FALSE, se recuperan los datos de NCHAR, NVARCHAR
  y NCLOB con el juego de caracteres mediante el valor NLS_LANG. Por defecto,
  \code{unicode_as_utf8} se define en TRUE.
  Cuando \code{ora.attributes} se define en TRUE, se agregan los
  atributos \code{ora.encoding}, \code{ora.type} y \code{ora.maxlength} en el marco de datos resultante
  que devuelve de dbGetQuery y se recupera. Se debe utilizar con dbWriteTable para
  crear los mismos tipos de dato en Oracle DBMS que se recuperan de la tabla
  origen.
}
\section{Oracle user authentication}{
  In order to establish a connection to an Oracle server users need to provide
  a user name, a password, and possibly a connect identifier (for more
  information refer to chapter 8 (Configuring Naming Methods) of Oracle
  Database Net Services Administrator's Guide). This is the same as the part
  of the SQL*Plus connect string that follows the '@' sign.

  Connections to an Oracle TimesTen IMDB instance are established using the OCI
  tnsnames or easy connect naming methods. For additional information on 
  TimesTen connections for OCI see chapter 3 
  (TimesTen Support for Oracle Call Interface) of the Oracle TimesTen In-Memory
  C Developer's Guide.
}

\section{Transactions}{ 
  The current implementation directly supports transaction
  commits and rollbacks on a connection-wide basis through calls
  to \code{\link[DBI]{dbCommit}} and \code{\link[DBI]{dbRollback}}.
  Save points are not yet directly implemented, but you may be able
  to define them and rollback to them through calls to dynamic SQL
  with \code{\link[DBI]{dbGetQuery}}.

  Notice that Oracle (and ANSI/ISO compliant DBMS) transactions are 
  implicitly started when data definition SQL statements are executed (create
  table, etc.), which helper functions like \code{\link[DBI]{dbWriteTable}}
  may execute behind the scenes. You may want or need to commit
  or roll back your work before issuing any of these helper functions.
}

\section{References}{
  For Oracle Database documentation, see
  \url{ http://docs.oracle.com/en/database/}.
}
\author{David A. James and Denis Mukhin}
\seealso{
  On database managers:

  \code{\link[DBI]{dbDriver}}
  \code{\link[DBI]{dbUnloadDriver}}
  \code{\link[DBI]{dbListConnections}}

  On connections:

  \code{\link[DBI]{dbConnect}}
  \code{\link[DBI]{dbDisconnect}}
  \code{\link[DBI]{dbSendQuery}}
  \code{\link[DBI]{dbGetQuery}}
  \code{\link[DBI]{dbGetException}}
  \code{\link[DBI]{dbListResults}}

  Convenience methods:
  \code{\link[DBI]{dbListTables}}
  \code{\link[DBI]{dbReadTable}}
  \code{\link[DBI]{dbWriteTable}}
  \code{\link[DBI]{dbExistsTable}}
  \code{\link[DBI]{dbRemoveTable}}
  \code{\link[DBI]{dbListFields}}

  On transaction management:

  \code{\link[DBI]{dbCommit}}
  \code{\link[DBI]{dbRollback}}

  On queries and result objects:

  \code{\link[DBI]{fetch}}
  \code{\link[DBI]{dbClearResult}}
  \code{\link[DBI]{dbColumnInfo}}
  \code{\link[DBI]{dbGetStatement}}
  \code{\link[DBI]{dbHasCompleted}}
  \code{\link[DBI]{dbGetRowsAffected}}
  \code{\link[DBI]{dbGetRowCount}}

  On meta-data:

  \code{\link[methods]{show}}
  \code{\link[base]{summary}}
  \code{\link[DBI]{dbGetInfo}}
}
\examples{
  \dontrun{
    library(ROracle)

    ## create a Oracle instance and create one connection.
    ora <- Oracle()         ## or dbDriver("Oracle")
    con <- dbConnect(ora, username = "scott", password = "tiger", 
                     dbname = "inst1")

    ## if you are connecting to a local database
    con <- dbConnect(ora, username = "scott", password = "tiger")

    ## execute a statement and fetch its output in chunks of no more
    ## than 5000 rows at a time
    rs   <- dbSendQuery(con, "select * from emp where deptno = 10")
    while (!dbHasCompleted(rs)) {
      df <- fetch(rs, n = 5000)
      ## process df
    }
    dbClearResult(rs)       ## done with this query

    ## execute and fetch a statement with bind data
    df <- dbGetQuery(con, "select * from emp where deptno = :1",
                     data = data.frame(depno = 10))

    ## create a copy of emp table
    dbGetQuery(con, "create table foo as select * from emp")

    ## execute and bind an INSERT statement
    my.data = data.frame(empno = c(8001, 8002), ename = c('MUKHIN', 'ABOYOUN'))
    more.data = data.frame(empno = c(8003), ename = c('JAMES'))
    rs <- dbSendQuery(con, "insert into foo (empno, ename) values (:1, :2)",
                      data = my.data)

    ## execute with more data
    execute(rs, data = more.data)
    dbClearResult(rs)       ## done with this query

    ## ok, everything looks fine
    dbCommit(con)           

    ## a concise description of the driver 
    summary(ora)

    ## done with this connection
    dbDisconnect(con)
  }
  \dontrun{
    library(ROracle)

    ## create an Oracle instance and create one connection to access data stored
    ## in object data types such as Collections, user defined types and varrays.
    ora <- Oracle(ora.attributes = TRUE, ora.objects = TRUE)

    con <- dbConnect(ora, username = "scott", password = "tiger", 
                     dbname = "inst1")

    ## if you are connecting to a local database
    con <- dbConnect(ora, username = "scott", password = "tiger")

    ##
    ## object table with embedded object
    ##
    dbSendQuery(con, 
                "CREATE OR REPLACE TYPE address AS OBJECT(\
                   no NUMBER,\
                   street VARCHAR(32)\
                )")

    dbSendQuery(con,
                "CREATE OR REPLACE TYPE employee AS OBJECT \
                 ( \
                   id                NUMBER, \
                   name              VARCHAR(16), \
                   birthday          DATE, \
                   resume            CLOB, \
                   addr              ADDRESS \
                 )")

    dbSendQuery(con, "CREATE TABLE emp_tab OF employee")

    # funtion to generate data
    myFun <- function(i = 1000, j = 2000, n = 1)
    {
      a <- do.call(paste0, replicate(i, sample(LETTERS, n, TRUE), FALSE))
      b <- do.call(paste0, replicate(j, sample(letters, n, TRUE), FALSE))
      paste0(a, " ", b)
    }

    # construct data frame to bind in insert statement into emp_tab table
    df <- NULL
    for (i in 101:200) {
      ID <- i + 10
      NAME <- paste("First", i, " Last", i+1, sep ="")
      z <- 946713600 + (i * 86400)
      BIRTHDAY <- as.POSIXct(z, origin = "1970-01-01")
      RESUME <- myFun(12, 2000, 1)
      attr(RESUME, "ora.type") <- "clob"

      ADDS <- list(data.frame(i+30, myFun(4, 10, 1),stringsAsFactors = FALSE))
      attr(ADDS, "ora.type") <- "ADDRESS"
      rowin <- data.frame(ID, NAME, BIRTHDAY, RESUME, stringsAsFactors = FALSE)
      rowin$ADDR <- ADDS
      attr(rowin, "ora.type") <- "EMPLOYEE"

      if (is.null(df))
        df <- rowin
      else
        df[nrow(df) + 1,] <- rowin
    }

    dbSendQuery(con,
                "insert into emp_tab(ID, NAME, BIRTHDAY, RESUME, ADDR) \
                 values (:1, :2, :3, :4, :5)", df)


    ##
    ## table with id and embedded object
    ##
    dbSendQuery(con, "CREATE OR REPLACE TYPE addss AS OBJECT(\
                          no NUMBER,\
                          street VARCHAR(32)\
                        )")

    dbSendQuery(con, "CREATE OR REPLACE TYPE employee AS OBJECT\
                      (\
                      id                NUMBER,\
                      name              VARCHAR(16),\
                      birthday          DATE,\
                      resume            CLOB,\
                      addr              ADDSS\
                      )")

    dbSendQuery(con, "create table emp_tab_b(id number, emp employee)")

    ## insert rows into table
    dbSendQuery(con,
    "insert into emp_tab_b values(1\
      employee(1, 'Sandy'\
             to_date('1972 08 23', 'YYYY MM DD')\
             'This is a comment'\
             ADDSS(500, 'Oracle pkwy'\
              ))")

    dbSendQuery(con,
    "insert into emp_tab_b values(2,\
      employee(2, 'Sandy 2',\
             to_date('1975 08 25', 'YYYY MM DD'),\
             'This is a comment2',\
             ADDSS(NULL, 'Oracle pkwy')\
              ))")

    ## funtion to generate data
    myFun <- function(i = 1000, j = 2000, n = 1)
    {
      a <- do.call(paste0, replicate(i, sample(LETTERS, n, TRUE), FALSE))
      b <- do.call(paste0, replicate(j, sample(letters, n, TRUE), FALSE))
      paste0(a, " ", b)
    }

    ## construct data frame to bind in insert statement into emp_tab_b table
    df <- NULL
    for (i in 101:200) {
      ID <- i + 10
      NAME <- paste("First", i, " Last", i+1, sep ="")
      z <- 946713600 + (i * 86400)
      BIRTHDAY <- as.POSIXct(z, origin = "1970-01-01")
      RESUME <- myFun(12, 2000, 1)
      attr(RESUME, "ora.type") <- "clob"
  
      ADDS <- data.frame(i+30, myFun(4, 10, 1),stringsAsFactors = FALSE)
      rowin <- data.frame(ID, NAME, BIRTHDAY, RESUME, stringsAsFactors = FALSE)
      rowin$ADDR <- ADDS

      elem <- list(rowin)
      attr(elem, "ora.type") <- "EMPLOYEE"

      row <- data.frame(ID = i)
      row$EMP <- elem
      if (is.null(df))
        df <- row

      df[nrow(df) + 1,] <- row
    }

    dbSendQuery(con, "insert into emp_tab_b values(:1, :2)", df)

    ##
    ## Table with simple object type
    ##

    dbSendQuery(con, "CREATE OR REPLACE TYPE a AS OBJECT (\
                         A1 NUMBER,\
                         A2 VARCHAR(20)\
                         )")

    dbSendQuery(con, "create table obja (id number, a a)")

    dbSendQuery(con, "insert into obja values(1, A(1, '111111'))")
    ## funtion to generate data
    myFun <- function(i = 1000, j = 2000, n = 1)
    {
      a <- do.call(paste0, replicate(i, sample(LETTERS, n, TRUE), FALSE))
      b <- do.call(paste0, replicate(j, sample(letters, n, TRUE), FALSE))
      paste0(a, " ", b)
    }

    ## construct data frame to bind in insert statement into obja table
    df <- NULL
    for (i in 101:200) {
      A1 <- i + 10
      A2 <- paste("First", i, " Last", i+1, sep ="")
      rowin <- data.frame(A1, A2, stringsAsFactors = FALSE)

      elem <- list(rowin)
      attr(elem, "ora.type") <- "A"

      row <- data.frame(ID = i)
      row$EMP <- elem
      if (is.null(df))
        df <- row

      df[nrow(df) + 1,] <- row
    }

    dbSendQuery(con, "insert into obja values(:1, :2)", df)

    ## 
    ## Table with a Varray type
    ##
    dbSendQuery(con, "CREATE OR REPLACE TYPE varr is varray(10) of number")

    dbSendQuery(con, "create table test(a number, b varr)")
    dbSendQuery(con, "insert into TEST values(1, VARR(1, 2, 3, 4, 5, 6))")
    dbSendQuery(con, "insert into TEST values(2, VARR(7, NULL, 9, 10, 11))")
    dbSendQuery(con, "insert into TEST values(3, NULL))")
    dbSendQuery(con, "insert into TEST values(4, VARR(12, NULL, 18, 19))")

    ## construct data frame to bind in insert statement into test table
    df <- NULL
    j <- 13
    i <- 11
    nrow <- 1
    ncol <- 10
    for (i in 101:200) {
      A <- i + 10
      VARR <- data.frame(matrix(rnorm(nrow*ncol),nrow, ncol))
      B <- list(VARR)
      rowin <- data.frame(A=A)
      rowin$B <- list(B)
      attr(rowin$B, "ora.type") <- "VARR"

      if (is.null(df))
        df <- rowin
      else
        df[nrow(df) + 1,] <- rowin
    }

    dbSendQuery(con, "insert into test(A, B) values (:1, :2)", df)

    # check the data in table
    dbGetQuery(con, "select * from test")


    ## execute a statement and fetch its output in chunks of no more
    ## than 5000 rows at a time
    rs   <- dbSendQuery(con, "select * from emp where deptno = 10")
    while (!dbHasCompleted(rs)) {
      df <- fetch(rs, n = 5000)
      ## process df
    }
    dbClearResult(rs)       ## done with this query

    ## execute and fetch a statement with bind data
    df <- dbGetQuery(con, "select * from emp where deptno = :1",
                     data = data.frame(depno = 10))

    ## create a copy of emp table
    dbGetQuery(con, "create table foo as select * from emp")

    ## execute and bind an INSERT statement
    my.data = data.frame(empno = c(8001, 8002), ename = c('MUKHIN', 'ABOYOUN'))
    more.data = data.frame(empno = c(8003), ename = c('JAMES'))
    rs <- dbSendQuery(con, "insert into foo (empno, ename) values (:1, :2)",
                      data = my.data)

    ## execute with more data
    execute(rs, data = more.data)
    dbClearResult(rs)       ## done with this query

    ## ok, everything looks fine
    dbCommit(con)           

    ## a concise description of the driver 
    summary(ora)

    ## done with this connection
    dbDisconnect(con)
  }
}
\keyword{interface}
\keyword{database}
