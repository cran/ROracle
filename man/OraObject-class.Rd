\name{OraObject-class}
\docType{class}
\alias{OraObject-class}
\title{Class OraObject}
\description{
   Base class for all Oracle-specific DBI classes
}
\section{Objects from the Class}{
   A virtual Class: No objects may be created from it.
}
\section{Extends}{
Class \code{"DBIObject"}, directly.
Class \code{"dbObjectId"}, directly.
}
\section{Methods}{
  \describe{
    \item{coerce}{\code{signature(from = "OraObject", to = "OraDriver")}: ... }
    \item{dbDataType}{\code{signature(dbObj = "OraObject")}: ... }
    \item{isSQLKeyword}{\code{signature(dbObj = "OraObject", name = "character")}: ... }
    \item{make.db.names}{\code{signature(dbObj = "OraObject", snames = "character")}: ... }
    \item{SQLKeywords}{\code{signature(dbObj = "OraObject")}: ... }
  }
}
\references{
  See the Database Interface definition document
  \code{DBI.pdf} in the base directory of this package
  or \url{http://developer.r-project.org/db}.
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
