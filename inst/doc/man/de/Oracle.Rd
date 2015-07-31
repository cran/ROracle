\name{Oracle}
\alias{Oracle}
\alias{Extproc}
\title{
Einen Oracle-Client von der aktuellen \R-Session instanziieren
}
\description{
Diese Funktion erstellt und initialisiert einen Oracle-Client von der
  aktuellen \R-Session. Sie gibt ein Objekt zurück, mit dessen Hilfe Sie eine
  Verbindung zu einem oder mehreren Oracle-Servern herstellen können.
}
\usage{
  Oracle(interruptible = FALSE, unicode_as_utf8 = TRUE,
         ora.attributes = FALSE)
  Extproc(extproc.ctx = NULL)
}
\arguments{
  \item{interruptible}{
Ein Logikoperator, der angibt, ob bei lange laufenden Abfragen Benutzer-Interrupts zulässig sein sollen.
}
  \item{extproc.ctx}{
Ein externer Pointer, der extproc-Kontext umschließt.
}
  \item{unicode_as_utf8}{
Ein Logikoperator, der angibt, ob NCHAR-, NVARCHAR- und NCLOB-Daten
    mit einer UTF8-Verschlüsselung abgerufen werden sollen.
}
  \item{ora.attributes}{
Ein Logikoperator, der angibt, ob die Attribute \code{ora.encoding},
    \code{ora.type} und \code{ora.maxlength} in die von 
    \code{dbGetQuery} und \code{fetch} zurückgegebenen Datenframes aufgenommen werden sollen.
}
}
\value{
Ein Objekt der Klasse \code{OraDriver} für \code{Oracle} oder
  \code{ExtDriver} für \code{Extproc}, dessen Klasse \code{DBIDriver} erweitert. 
  Dieses Objekt wird zum Erstellen von Verbindungen verwendet, wobei die Funktion
  \code{dbConnect} mit mindestens einer Oracle-Datenbank-Engine eingesetzt wird.
}
\section{Side Effects}{
  The \R client part of the database communication is initialized,
  but note that connecting to the database engine needs to be done through
  calls to \code{\link[DBI]{dbConnect}}.
}




\details{
Dies ist ein Einzelobjekt. Bei nachfolgenden Aufrufen wird also
  dasselbe initialisierte Objekt zurückgegeben. 
  Mit dieser Implementierung können Sie Verbindungen zu mehreren Hostservern herstellen
  und auf jedem Server mehrere Verbindungen gleichzeitig ausführen.
  Wenn \code{interruptible} auf TRUE gesetzt ist, können Abfragen mit langer Ausführungszeit
  auf dem Server durch Ausführen der Abfrage in einem Thread unterbrochen werden.
  Der Hauptthread prüft auf STRG-C und gibt den Befehl OCIBreak/OCIReset aus, um den Vorgang
  auf dem Server abzubrechen. Standardmäßig ist \code{interruptible} FALSE.
  Wenn \code{unicode_as_utf8} auf FALSE gesetzt ist, werden NCHAR-, NVARCHAR- und NCLOB-Daten
  über den in der Einstellung NLS_LANG definierten Zeichensatz abgerufen. Standardmäßig
  ist \code{unicode_as_utf8} auf TRUE gesetzt.
  Wenn \code{ora.attributes} auf TRUE gesetzt ist, werden die Attribute \code{ora.encoding},
  \code{ora.type} und \code{ora.maxlength} zum Ergebnisdatenframe hinzugefügt, der von
  dbGetQuery und FETCH zurückgegeben wird. Muss mit dbWriteTable verwendet werden,
  um dieselben Datentypen zu erstellen, die im Oracle DBMS von der Quelltabelle
  abgerufen wurden.
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
