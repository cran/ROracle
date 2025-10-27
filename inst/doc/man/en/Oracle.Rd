\name{Oracle}
\alias{Oracle}
\alias{Extproc}
\title{
  Instantiate an Oracle client from the current \R session
}
\description{
  This function creates and initializes an Oracle client from the
  current \R session. It returns an object that allows you to connect to
  one or more Oracle servers.
}
\usage{
  Oracle(interruptible = FALSE, unicode_as_utf8 = TRUE,
         ora.attributes = FALSE, ora.objects = FALSE,
         sparse = FALSE)
  Extproc(extproc.ctx = NULL)
}
\arguments{
  \item{interruptible}{
    A logical indicating whether to allow user interrupts on long-running
    queries.
  }
  \item{extproc.ctx}{
    An external pointer wrapping extproc context.
  }
  \item{unicode_as_utf8}{
    A logical indicating whether to fetch NCHAR, NVARCHAR and NCLOB data
    encoded in UTF8.
  }
  \item{ora.attributes}{
    A logical indicating whether to include the attributes \code{ora.encoding},
    \code{ora.type}, and \code{ora.maxlength} in the data frames returned by
    \code{dbGetQuery} and \code{fetch}.
  }
  \item{ora.objects}{
    A logical indicating whether to allow access to tables with object types,
    such as Collections, user-defined types and varrays.
  }
  \item{sparse}{
    A logical indicating whether to use sparseVector method from Matrix
    library to construct sparse vectors returned by Oracle database. When
    TRUE, sparse vectors are constructed using sparseVector method of Matrix
    package. When FALSE, a dense vector is returned and one can use any of the
    R methods/packages to transform to sparse format.
  }
}
\value{
  An object of class \code{OraDriver} for \code{Oracle} or
  \code{ExtDriver} for \code{Extproc} whose class extends \code{DBIDriver}.
  This object is used to create connections, using the function
  \code{dbConnect}, to one or more Oracle database engines.
}
\section{Side Effects}{
  The \R client part of the database communication is initialized,
  but connecting to the database engine needs to be done through
  calls to \code{\link[DBI]{dbConnect}}.
}
\details{
  This object is a singleton, that is, on subsequent invocations
  it returns the same initialized object. 

  This implementation allows you to connect to multiple host servers and
  run multiple connections on each server simultaneously.

  When \code{interruptible} is set to TRUE, it allows for interrupting
  long-running queries on the server by executing the query in a thread. Main
  thread checks for Ctrl-C and issues OCIBreak/OCIReset to cancel the operation
  on the server. By default \code{interruptible} is FALSE.

  When \code{unicode_as_utf8} is set to FALSE, NCHAR, NVARCHAR and
  NCLOB data is fetched using the character set using the NLS_LANG
  setting. By default \code{unicode_as_utf8} is set to TRUE.

  When \code{ora.attributes} is set to TRUE attributes \code{ora.encoding},
  \code{ora.type}, \code{ora.format} and \code{ora.maxlength} are added in 
  result data frame returned from dbGetQuery and fetch. \code{ora.maxlength}
  in result data frame represents the dimension of vector column. 
  \code{ora.format} in data frame refer to format of the vector column 
  defined in the data base for the vector column. Format will be one of
  int8, float32, float64, binary or * which represents flex format. It 
  should be used with dbWriteTable to create the same data types as in the 
  Oracle DBMS as fetched from the source table.
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
  \url{ https://docs.oracle.com/en/database/}.
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

      ADDS <- list(data.frame(i+30, myFun(4, 10, 1), stringsAsFactors = FALSE))
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


    ## 
    ## Begin Table with a Vector type
    ##
    dbSendQuery(con, "create table vectab (col_1 vector(*,*))")
    dbSendQuery(con, "insert into vectab values('[1.1, 2.2, 3.3]')")
    dbGetQuery(con, "select * from vectab")

    # get vector data as populated by 
    res <- dbGetQuery(con, "select * from vectab")

    # display column meta data
    res <- dbSendQuery(con, 'SELECT * from vectab');
    dbColumnInfo(res)

    # fetch all data and display it
    df1 <- dbGetQuery(con, 'SELECT * from vectab');
    df1

    # number of rows in data frame(result)
    nrow(df1)
    # number of columns in data frame(result)
    ncol(df1)

    # insert statement with bind variable
    insBindStr <- "INSERT INTO vectab VALUES (:1)"

    # re-insert data retrived earlier
    dbSendQuery(con, insBindStr, df1) # insert all rows

    # fetch all data and display it
    res <- dbGetQuery(con, "select * from vectab")
    res

    # number of rows in data frame(result)
    nrow(res)
    # number of columns in data frame(result)
    ncol(res)

    # construct vector of list in number format
    vecdf <- NULL
    j <- 30
    for (i in 1:5)
    {
      id <- 100+i

      col_1 <- list(c(100+i+.1, 100+i+.2, 100+i+.3))
      row <- data.frame(id=id)
      row$col_1[[1]] <- col_1
      if (is.null(vecdf))
        vecdf <- row
      else
        vecdf[nrow(vecdf) + 1,] <- row

      str(vecdf)
    }

    # insert data in vecdf constructed above as a list of numbers
    dbSendQuery(con, insBindStr, vecdf[2]) # insert all rows

    # fetch all data and display it
    res <- dbGetQuery(con, "select * from vectab")
    res

    # number of rows in data frame(result)
    nrow(res)

    mxl = attr(res, "ora.maxlength")
    vecfmt = attr(res, "ora.format")

    # construct vector of list using fixed format string format
    vecdf <- NULL
    j <- 30
    for (i in 1:2)
    {
      id <- 100+i

      if (i == 2)
        col_1 <- list(NULL)
      else if (i == 3)
        col_1 <- list('')
      else
        col_1 <- list('[9.4, 9.6,9.7]')

      attr(col_1, "ora.type") <- "vector"
      attr(col_1, "ora.maxlength") <- mxl
      attr(col_1, "ora.format") <- vecfmt

      row <- data.frame(id=id)
      row$col_1[[1]] <- col_1
      if (is.null(vecdf))
        vecdf <- row
      else
        vecdf[nrow(vecdf) + 1,] <- row

      str(vecdf)
    }

    # insert data in vecdf constructed above as a list with fixed string
    dbSendQuery(con, insBindStr, vecdf[2]) # insert all rows
    dbSendQuery(con, "commit")

    # fetch all data and display it
    res <- dbGetQuery(con, "select * from vectab")
    res

    # number of rows in data frame(result)
    nrow(res)

    # construct vector of list in integer format
    vecdf <- NULL
    j <- 30
    for (i in 1:5)
    {
      id <- 100+i

      col_1 <- list(c(as.integer(900+i), as.integer(900+i), as.integer(900+i)))
      row <- data.frame(id=id)
      row$col_1[[1]] <- col_1
      if (is.null(vecdf))
        vecdf <- row
      else
        vecdf[nrow(vecdf) + 1,] <- row

      str(vecdf)
    }

    # insert data in vecdf constructed above as a list integers
    dbSendQuery(con, insBindStr, vecdf[2]) # insert all rows
    dbSendQuery(con, "commit")

    # fetch all data and display it
    res <- dbGetQuery(con, "select * from vectab")
    res

    # number of rows in data frame(result)
    nrow(res)

    # construct vector of list using variable string format
    vecdf <- NULL
    j <- 30
    for (i in 1:5)
    {
      id <- 1000+i

      str <- '['
      for (k in 1:7)
      {
        str <- paste(str, as.character(k*3+.7*i))
        str <- paste(str, ',');
      }
      str <- paste(str, as.character(k*3+.7*i))
      str <- paste(str, ']')
      row <- data.frame(id=id)
      row$col_1[[1]] <- str
      if (is.null(vecdf))
        vecdf <- row
      else
        vecdf[nrow(vecdf) + 1,] <- row

      str(vecdf)
    }

    # insert data in vecdf constructed above as a list of variable strings
    dbSendQuery(con, insBindStr, vecdf[2]) # insert all rows
    dbSendQuery(con, "commit")

    # fetch all data and display it
    res <- dbGetQuery(con, "select * from vectab")
    res

    # number of rows in data frame(result)
    nrow(res)

    res <- dbGetQuery(con, "drop table vectab")

    ##
    ## Create a table with a sparse vector column
    ##
    dbSendQuery(con, "CREATE TABLE sparse_vectab \
                  (\
                    id NUMBER, \
                    c1 VECTOR(*, *, SPARSE)\
                  )")

    dbSendQuery(con, "INSERT INTO sparse_vectab VALUES \
                  (101, '[10, [2, 3, 4], [10, 20, 30]]')")

    library(Matrix)

    # get vector data as populated by 
    res <- dbGetQuery(con, "select * from sparse_vectab", sparse = TRUE)

    # display column meta data
    res <- dbSendQuery(con, 'SELECT * from sparse_vectab');
    dbColumnInfo(res)

    # fetch all rows and display the sparse vector column
    df1 <- dbGetQuery(con, 'SELECT * from sparse_vectab', sparse = TRUE);
    df1$C1

    # number of rows in data frame(result)
    nrow(df1)
    # number of columns in data frame(result)
    ncol(df1)

    # insert statement with bind variable
    insBindStr <- "INSERT INTO sparse_vectab VALUES (:1, :2)"

    # re-insert data retrived earlier
    dbSendQuery(con, insBindStr, df1) # insert all rows

    # Fetch all rows and display the sparse vector column
    res <- dbGetQuery(con, "select * from sparse_vectab", sparse = TRUE)
    res$C1

    # retrieve and display all data as list of numeric
    res <- dbGetQuery(con, "select * from sparse_vectab")
    res$C1

    # number of rows in data frame(result)
    nrow(res)

    # construct R dsparseVector objects for inserting
    v1 <- new("dsparseVector", 
          i = c(1L, 2L, 3L), #integer indices
          x = c(1.12, 2.23, 3.12), 
          length = 320L)
    v2 <- new("dsparseVector", 
          i = c(1L, 2L, 3L, 4L), #integer indices
          x = c(1.12, 2.23, 3.12, 4.23), 
          length = 1000L)      
    vecdf <- data.frame(id = c(9, 10))
    vecdf$c1 <- list(v1, v2)
    attr(vecdf$c1, "ora.type") <- "vector"
    attr(vecdf$c1, "ora.format") <- "float32"

    # insert data in vecdf constructed above as a list of dsparseVector
    dbSendQuery(con, insBindStr, vecdf) # insert all rows
    dbSendQuery(con, "commit")

    # fetch all data and display it
    res <- dbGetQuery(con, "select * from sparse_vectab", sparse = TRUE)
    res$C1

    # number of rows in data frame(result)
    nrow(res)

    res <- dbGetQuery(con, "drop table sparse_vectab")
    ## 
    ## End of Table with a Vector type
    ##

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
