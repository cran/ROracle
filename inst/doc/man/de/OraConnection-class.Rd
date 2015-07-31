\name{OraConnection-class}
\docType{class}
\alias{OraConnection-class}
\title{
Klasse "OraConnection"
}
\description{
Eine Oracle-Verbindungsklasse, die die R-Datenbankschnittstellen-(DBI-)API implementiert.
}
\section{Generators}{
    The method \code{\link[DBI]{dbConnect}} is the main generator.
}
\section{Extends}{
Class \code{"DBIConnection"}, directly.
Class \code{"DBIObject"}, by class \code{"DBIConnection"}, distance 2.
}
\section{Methods}{
  \describe{
    \item{dbDisconnect}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbSendQuery}{\code{signature(conn = "OraConnection", statement = "character", prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L)}: ... }
    \item{dbGetQuery}{\code{signature(conn = "OraConnection", statement = "character", prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L)}: ... }
    \item{dbGetException}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbListResults}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbListTables}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbReadTable}{\code{signature(conn = "OraConnection", name = "character")}: ... }
    \item{dbWriteTable}{\code{signature(conn = "OraConnection", name = "character", value = "data.frame")}: ... }
    \item{dbExistsTable}{\code{signature(conn = "OraConnection", name = "character")}: ... }
    \item{dbRemoveTable}{\code{signature(conn = "OraConnection", name = "character")}: ... }
    \item{dbListFields}{\code{signature(conn = "OraConnection", name = "character")}: ... }
    \item{dbCommit}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbRollback}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbGetInfo}{\code{signature(dbObj = "OraConnection")}: ... }
    \item{summary}{\code{signature(object = "OraConnection")}: ... }
    \item{show}{\code{signature(object = "OraConnection")} }
  }
}
\seealso{
 DBI classes:
 \code{\link{OraDriver-class}}
 \code{\link{OraConnection-class}}
 \code{\link{OraResult-class}}
}
\examples{\dontrun{
ora <- dbDriver("Oracle")
## connecting without a connect string
con <- dbConnect(ora, "scott", "tiger")

## connecting with a connection string with SID
host <- "myhost"
port <- 1521
sid <- "mysid"
connect.string <- paste(
  "(DESCRIPTION=",
  "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
  "(CONNECT_DATA=(SID=", sid, ")))", sep = "")

## use username/password authentication
con <- dbConnect(drv, username = "scott", password = "tiger",
                 dbname = connect.string)

## connecting with a connection string with service name
host <- "myhost"
port <- 1521
svc <- "mydb.example.com"
connect.string <- paste(
  "(DESCRIPTION=",
  "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
  "(CONNECT_DATA=(SERVICE_NAME=", svc, ")))", sep = "")
## use username/password authentication
con <- dbConnect(drv, username = "scott", password = "tiger",
                 dbname = connect.string)

## Please refer to "Oracle Database Net Services Administator's Guide", which
## has the topic "Connect Identifier and Connect Descriptor Syntax
## Characteristics"

dbListTables(con)
}
}
\keyword{database}
\keyword{interface}
\keyword{classes}
