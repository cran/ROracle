\name{dbConnect-methods}
\docType{methods}
\alias{dbConnect}
\alias{dbDisconnect}
\alias{dbConnect,OraDriver-method}
\alias{dbConnect,ExtDriver-method}
\alias{dbDisconnect,OraConnection-method}
\title{
Verbindungsobjekt zu einem Oracle DBMS erstellen
}
\description{
Diese Methoden sind einfache Implementierungen der entsprechenden
   generischen Funktionen.
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
Ein Objekt der Klasse \code{OraDriver} oder \code{ExtDriver}.
}
  \item{conn}{
Ein \code{OraConnection}-Objekt, wie von \code{dbConnect} erzeugt.
}
  \item{username}{
Eine Zeichenfolge, die einen Benutzernamen angibt.
}
  \item{password}{
Eine Zeichenfolge, die ein Kennwort angibt.
}
  \item{dbname}{
Eine Zeichenfolge, die eine Verbindungs-ID angibt (weitere Informationen
    finden Sie in Kapitel 8, "Configuring Naming Methods", im Oracle
    Database Net Services Administrator's Guide). Sie ist identisch mit einem
    Teil der SQL*Plus-Verbindungszeichenfolge, die auf das "@"-Zeichen folgt. 
    Wenn Sie Oracle Wallet zur Speicherung von Benutzername und Kennwort verwenden, 
    muss diese Zeichenfolge die Verbindungszeichenfolge zum Erstellen des 
    Wallet Mappings sein (weitere Informationen finden Sie im Abschnitt "Configuring Clients to Use
    the External Password Store" in Kapitel 3 des Oracle Database Security Guide).
    Verbindungs-IDs für eine Oracle TimesTen IMDB-Instanz werden über die
    OCI Tnsnames- oder Easy Connect-Benennungsmethoden unterstützt. Weitere Informationen
    zu TimesTen-Verbindungen für OCI finden Sie in Kapitel 3, "TimesTen Support for OCI", im
    TimesTen In-Memory C Developer's Guide.
    Die unten dargestellten Beispiele zeigen verschiedene Arten zur Angabe der Verbindungs-ID.
}
  \item{prefetch}{
Ein logischer Wert, der TRUE oder FALSE angibt. Wenn der Wert auf TRUE gesetzt ist, verwendet ROracle
    OCI-Prefetch-Puffer, um zusätzliche Daten aus dem Server abzurufen und so Speicher zu
    sparen, der in RODBI/ROOCI benötigt wird, indem ein einzelner Zeilenpuffer für den Abruf 
    der Daten aus OCI verwendet wird. Die Verwendung von Prefetch führt zu einem Fetch-Aufruf für jede
    Zeile. Standardmäßig ist Prefetch FALSE und Array-Fetch wird verwendet, um die Daten aus
    dem Server abzurufen.
}
  \item{bulk_read}{
Ein ganzzahliger Wert, der die Anzahl von Zeilen angibt, die gleichzeitig abgerufen werden sollen.
    Der Standardwert beträgt 1000L. Wenn die Prefetch-Option gewählt ist, wird der Speicher für
    Prefetch-Puffer verwendet und OCI ruft diese Anzahl von Zeilen gleichzeitig ab.
    Wenn Prefetch nicht verwendet wird (Standard), wird der Speicher in RODBI/ROOCI-
    Define-Puffern zugewiesen. Wenn hier ein hoher Wert festgelegt wird, wird mehr Speicher
    basierend auf der Anzahl von Spalten in der Select-Liste und den Spaltentypen zugewiesen.
    Bei einer Zeichenspalte werden Define-Puffer mit der maximalen Breite
    mal der maximalen NLS-Breite zugewiesen. Anwendungen müssen diesen 
    Wert entsprechend dem Abfrageergebnis anpassen und ein hoher Wert kommt
    Abfragen zu Gute, die ein großes Ergebnis zurückgeben. Eine Anwendung kann diesen
    Wert nach Bedarf optimieren.
}
  \item{bulk_write}{
Ein ganzzahliger Wert, der die Anzahl von Zeilen angibt, die gleichzeitig eingefügt,
    aktualisiert oder gelöscht werden sollen. Der Standardwert ist 1000L. Wird der bulk_write-Wert in einem
    Argument angegeben, wird Puffern Speicher zugewiesen, und OCI schreibt die entsprechende
    Anzahl Zeilen gleichzeitig. Wird das Argument bulk_write nicht angegeben, wird über den Standardwert
    1000 den Bind-Puffern Speichern zugewiesen. Wenn Sie hierfür einen
    hohen Wert festlegen, wird basierend auf der Anzahl von Spalten in der Einfügeliste
    und auf den Spaltentypen entsprechend mehr Speicher zugewiesen.
}
  \item{stmt_cache}{
Ein ganzzahliger Wert, der die Anzahl von zu cachenden Anweisungen angibt. Er bedeutet, 
    dass Cursor verwendet werden können, ohne dass die Anweisungen erneut geparst werden 
    müssen. Der Standardwert ist 0L. Wenn der stmt_cache-Wert größer als 0L ist, muss
    der \code{prefetch}-Wert auf TRUE gesetzt werden.
}
  \item{external_credentials}{
Ein logischer Wert, der TRUE oder FALSE angibt. Wenn der Wert auf TRUE gesetzt ist, beginnt
    ROracle die OCI-Session, die mit externen Zugangsdaten authentifiziert ist, für die Verbindung.
    Der Standardwert ist FALSE.
}
  \item{sysdba}{
Ein logischer Wert, der TRUE oder FALSE angibt. Wenn der Wert auf TRUE gesetzt ist, beginnt
    ROracle die OCI-Session mit SYSDBA-Berechtigungen für die Verbindung.
    Der Standardwert ist FALSE.
}
  \item{\dots}{
Aktuell nicht verwendet
}
}
\value{
\item{dbConnect}{
    Ein Objekt \code{OraConnection}, dessen Klasse \code{DBIConnection} erweitert. 
    Dieses Objekt wird zur Ausführung von SQL-Abfragen in der Datenbank verwendet.
  }
  \item{dbDisconnect}{
    Ein logischer Wert, der angibt, ob der Vorgang erfolgreich war.
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
      Dieses Verbindungsobjekt wird für die Ausführung von Vorgängen mit der Datenbank verwendet.
      Wenn \code{prefetch} auf TRUE gesetzt ist, ist die Verwendung des OCI-Prefetch-Puffers
      für das Abrufen von zusätzlichen Daten aus dem Server zulässig.
      Das \code{bulk_read}-Argument wird verwendet, um einen ganzzahligen Wert festzulegen,
      der die Anzahl von gleichzeitig abzurufenden Zeilen angibt.
      Das \code{bulk_write}-Argument wird verwendet, um einen ganzzahligen Wert festzulegen,
      der die Anzahl der gleichzeitig zu schreibenden Zeilen angibt.
      Das \code{stmt_cache}-Argument wird zur Aktivierung oder Deaktivierung des Features zum
      Anweisungscaching verwendet. Sein Wert gibt die Größe des Anweisungscaches an.
      Das \code{external_credentials}-Argument wird verwendet, um die OCI-Session, die mit externen Zugangsdaten
      authentifiziert ist, für die Verbindung zu beginnen.
      Das \code{sysdba}-Argument wird verwendet, um die OCI-Session mit SYSDBA-
      Berechtigungen für die Verbindung zu beginnen.
      Wenn eine Verbindung mit einem \code{ExtDriver}-Treiber hergestellt wird, wird keines
      der Argumente, die Zugangsdaten angeben, verwendet. Eine Verbindung in diesem
      Modus ist ein Einzelobjekt, d.h. alle Aufrufe von \code{dbConnect} geben dasselbe
      Verbindungsobjekt zurück.
    }
    \item{dbDisconnect}{
      Diese Implementierung trennt die Verbindung zwischen R und dem Datenbankserver
      Sie gibt alle Ressourcen frei, die von dem Verbindungsobjekt verwendet werden. Sie gibt
      alle Ergebnismengen frei, die mit diesem Verbindungsobjekt verknüpft sind.
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
