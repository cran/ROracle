\name{OraConnection-class}
\docType{class}
\alias{OraConnection-class}
\title{Class OraConnection}
\description{
  An Oracle connection class implementing the R database interface (DBI) API.}
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
    \item{dbSendQuery}{\code{signature(conn = "OraConnection", statement = "character", prefetch = FALSE, bulk_read = 25L, lob_prefetch = 1024L)}: ... }
    \item{dbGetQuery}{\code{signature(conn = "OraConnection", statement = "character", prefetch = FALSE, bulk_read = 25L, lob_prefetch = 1024L)}: ... }
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
con <- dbConnect(ora, "scott", "tiger")
dbListTables(con)
}
}
\keyword{database}
\keyword{interface}
\keyword{classes}
