\name{Oracle}
\alias{Oracle}
\alias{Extproc}
\title{
Instanciar um Cliente Oracle com base na sessão \R atual
}
\description{
Essa função cria e inicializa um cliente Oracle na
  sessão do \R atual. Ela retorna um objeto que permite conexão com
  um ou mais servidores Oracle.
}
\usage{
  Oracle(interruptible = FALSE, unicode_as_utf8 = TRUE,
         ora.attributes = FALSE, ora.objects = FALSE)
  Extproc(extproc.ctx = NULL)
}
\arguments{
  \item{interruptible}{
Um valor lógico que indica se o usuário tem permissão para interromper consultas de
     execução longa.
}
  \item{extproc.ctx}{
Um ponteiro externo que encapsula o contexto extproc.
}
  \item{unicode_as_utf8}{
Um valor lógico que indica se dados NCHAR, NVARCHAR e NCLOB
    codificados em UTF8 devem ser extraídos.
}
  \item{ora.attributes}{
Um valor lógico que indica se os atributos \code{ora.encoding},
    \code{ora.type} e \code{ora.maxlength} devem ser incluídos nos quadros de dados retornados por
    \code{dbGetQuery} e \code{fetch}.
}
  \item{ora.objects}{
Uma lógica que indica se será permitido o acesso a tabelas com tipos de objeto,
    como Coleções, tipos e varrays definidos pelo usuário.
}
}
\value{
Um objeto da classe \code{OraDriver} para \code{Oracle} ou
  \code{ExtDriver} para \code{Extproc} cuja classe estende \code{DBIDriver}.
  Esse objeto é usado para criar conexões, usando a função
  \code{dbConnect}, para um ou mais motores de banco de dados Oracle.
}
\section{Side Effects}{
  The \R client part of the database communication is initialized,
  but note that connecting to the database engine needs to be done through
  calls to \code{\link[DBI]{dbConnect}}.
}




\details{
Esse objeto é um singleton, ou seja, nas chamadas subsequentes,
  ele retorna o mesmo objeto inicializado. 
  Essa implementação permite que você se conecte a vários servidores host e
  execute diversas conexões em cada servidor simultaneamente.
  Quando \code{interruptible} é definido como TRUE, ele permite a interrupção
  de consultas de execução longa no servidor, executando a consulta em um thread. O
  thread principal verifica Ctrl-C e emite OCIBreak/OCIReset para cancelar a operação
  no servidor. Por padrão, \code{interruptible} é FALSE.
  Quando \code{unicode_as_utf8} é definido como FALSE, os dados NCHAR, NVARCHAR e NCLOB
  são extraídos usando o conjunto de caracteres que utiliza a definição NLS_LANG. Por padrão,
  \code{unicode_as_utf8} é definido como TRUE.
  Quando \code{ora.attributes} é definido como TRUE, os atributos \code{ora.encoding},
  \code{ora.type} e \code{ora.maxlength} são adicionados no quadro de dados de resultado
  retornados de dbGetQuery e da extração. Eles deverão ser usados com dbWriteTable para
  criar os mesmos tipos de dados que no Oracle DBMS conforme extraídos da tabela
  de origem.
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
