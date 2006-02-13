% $Id: OraConnection-class.Rd,v 1.3 2006/02/08 19:17:00 dj Exp dj $
\name{OraConnection-class}
\docType{class}
\alias{OraConnection-class}
\title{Class OraConnection}
\description{Oracle connection class.}
\section{Generators}{
    The method \code{\link[DBI]{dbConnect}} is the main generator.
}
\section{Extends}{
Class \code{"DBIConnection"}, directly.
Class \code{"OraObject"}, directly.
Class \code{"DBIObject"}, by class "DBIConnection".
Class \code{"dbObjectId"}, by class "OraObject".
}
\section{Methods}{
  \describe{
    \item{coerce}{\code{signature(from = "OraConnection", to = "OraResult")}: ... }
    \item{dbCallProc}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbCommit}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbConnect}{\code{signature(drv = "OraConnection")}: ... }
    \item{dbDisconnect}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbExistsTable}{\code{signature(conn = "OraConnection", name = "character")}: ... }
    \item{dbGetException}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbGetInfo}{\code{signature(dbObj = "OraConnection")}: ... }
    \item{dbGetQuery}{\code{signature(conn = "OraConnection", statement = "character")}: ... }
    \item{dbListFields}{\code{signature(conn = "OraConnection", name = "character")}: ... }
    \item{dbListResults}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbListTables}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbReadTable}{\code{signature(conn = "OraConnection", name = "character")}: ... }
    \item{dbRemoveTable}{\code{signature(conn = "OraConnection", name = "character")}: ... }
    \item{dbRollback}{\code{signature(conn = "OraConnection")}: ... }
    \item{dbSendQuery}{\code{signature(conn = "OraConnection", statement = "character")}: ... }
    \item{dbWriteTable}{\code{signature(conn = "OraConnection", name = "character", value = "data.frame")}: ... }
    \item{summary}{\code{signature(object = "OraConnection")}: ... }
  }
}
\references{
  See the Database Interface definition document
  \code{DBI.pdf} in the base directory of this package
  or \url{http://stat.bell-labs.com/RS-DBI}.
}

\seealso{
 DBI classes:
 \code{\link{OraObject-class}}
 \code{\link{OraDriver-class}}
 \code{\link{OraConnection-class}}
 \code{\link{OraResult-class}}
}

\examples{\dontrun{
ora <- dbDriver("Oracle")
con <- dbConnect(ora, "user/password@dbname")
}
}
\keyword{database}
\keyword{interface}
\keyword{classes}
% vim: syntax=tex
