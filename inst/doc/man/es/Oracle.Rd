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
         ora.attributes = FALSE)
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
}
\keyword{interface}
\keyword{database}
