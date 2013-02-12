\name{dbSetDataMappings-methods}
\docType{methods}
\alias{dbSetDataMappings-methods}
\alias{dbSetDataMappings,OraResult,data.frame-method}
\title{
Datenzuordnungen zwischen Oracle und R festlegen
}
\description{
Noch nicht implementiert
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

dbSetDataMappings(res, flds)

im <- fetch(res, n = -1)
}
}
\keyword{methods}
\keyword{interface}
\keyword{database}
