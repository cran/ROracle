\name{OraResult-class}
\docType{class}
\alias{OraResult-class}
\title{Class OraResult}
\description{
   Oracle's query results class.  This classes encapsulates the
   result of an SQL statement (either \code{select} or not).
}
\section{Generators}{
   The main generator is \code{\link[DBI]{dbSendQuery}}.
}
\section{Extends}{
Class \code{"DBIResult"}, directly.
Class \code{"OraObject"}, directly.
Class \code{"DBIObject"}, by class "DBIResult".
Class \code{"dbObjectId"}, by class "OraObject".
}
\section{Methods}{
  \describe{
    \item{coerce}{\code{signature(from = "OraConnection", to = "OraResult")}: ... }
    \item{dbClearResult}{\code{signature(res = "OraResult")}: ... }
    \item{dbColumnInfo}{\code{signature(res = "OraResult")}: ... }
    \item{dbGetException}{\code{signature(conn = "OraResult")}: ... }
    \item{dbGetInfo}{\code{signature(dbObj = "OraResult")}: ... }
    \item{dbGetRowCount}{\code{signature(res = "OraResult")}: ... }
    \item{dbGetRowsAffected}{\code{signature(res = "OraResult")}: ... }
    \item{dbGetStatement}{\code{signature(res = "OraResult")}: ... }
    \item{dbHasCompleted}{\code{signature(res = "OraResult")}: ... }
    \item{dbListFields}{\code{signature(conn = "OraResult", name = "missing")}: ... }
    \item{fetch}{\code{signature(res = "OraResult", n = "numeric")}: ... }
    \item{fetch}{\code{signature(res = "OraResult", n = "missing")}: ... }
    \item{summary}{\code{signature(object = "OraResult")}: ... }
  }
}
\references{
  See the Database Interface definition document
  \code{DBI.pdf} in the base directory of this package
  or \url{http://developer.r-project.org/db}.
}
\author{R-SIG-DB}

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
