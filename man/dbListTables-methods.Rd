% $Id: dbListTables-methods.Rd 155 2006-02-08 19:19:08Z dj $
\name{dbListTables-methods}
\docType{methods}
\alias{dbListTables-methods}
\alias{dbListFields-methods}
\alias{dbListConnections-methods}
\alias{dbListResults-methods}
\alias{dbListTables,OraConnection-method}
\alias{dbListFields,OraConnection,character-method}
\alias{dbListFields,OraResult,missing-method}
\alias{dbListConnections,OraDriver-method}
\alias{dbListResults,OraConnection-method}
\title{
  List items from an Oracle DBMS and from objects 
}
\description{
   These methods are straight-forward implementations of the corresponding
   generic functions.
}
\section{Methods}{\describe{
  \item{drv}{an \code{OraDriver}.}
  \item{conn}{an \code{OraConnection}.}
  \item{name}{a character string with the table name.}
  \item{\dots}{currently not used.}
}
}
\references{
  See the Database Interface definition document
  \code{DBI.pdf} in the base directory of this package
  or
  \url{http://stat.bell-labs.com/RS-DBI}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbColumnInfo}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}}
}

\examples{\dontrun{
drv <- dbDriver("Oracle")
# after working awhile...
for(con in dbListConnections(drv)){
   dbGetStatement(dbListResults(con))
}
}
}
\keyword{methods}
\keyword{interface}
\keyword{database}
% vim: syntax=tex
