% $Id: dbSetDataMappings-methods.Rd,v 1.1 2003/11/03 22:41:41 dj Exp $
\name{dbSetDataMappings-methods}
\docType{methods}
\alias{dbSetDataMappings-methods}
\alias{dbSetDataMappings,OraResult,data.frame-method}
\title{
  Set data mappings between Oracle and R/S-Plus
}
\description{
  Not yet implemented
}
\section{Methods}{\describe{
\item{res}{
  a \code{OraResult} object as returned by \code{dbSendQuery}.
  }
\item{flds}{
  a data.frame with field descriptions as returned by 
  \code{\link[DBI]{dbColumnInfo}}.
  }
\item{\dots }{
  any additional arguments are passed to the implementing method.
  }
}
}
\references{
  See the Database Interface definition document
  \code{DBI.pdf} in the base directory of this package
  or \url{http://stat.bell-labs.com/RS-DBI}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbColumnInfo}}.
}
\examples{\dontrun{
makeImage <- function(x) {
  .C("make_Image", as.integer(x), length(x))
}

res <- dbSendQuery(con, statement)
flds <- dbColumnInfo(res)
flds[3, "Sclass"] <- makeImage

dbSetDataMappings(rs, flds)

im <- fetch(rs, n = -1)
}
}
\keywords{methods}
\keyword{interface}
\keyword{database}
% vim: syntax=tex
