\name{setDataMappings}
\alias{setDataMappings}
\title{
  Set data mappings between an RDBMS and R/S
}
\description{
Sets one or more conversion functions to handle the translation 
of SQL data types to R/S objects.  
This is only needed for non-primitive data, since all RS-DBI drivers 
handle the common base types (integers, numeric, strings, etc.)
}
\usage{
setDataMappings(res, ...)
}
\arguments{
\item{res}{
a \code{dbResultSet} object as returned by \code{dbExecStatement}.
}
\item{\dots }{
any additional arguments are passed to the implementing method.
}
}
\value{
a logical specifying whether the conversion functions were
successfully installed or not.
}
\section{Side Effects}{
Conversion functions are set up to be invoked for each element of
the corresponding fields in the result set.
}
\details{
The details on conversion functions (e.g., arguments,
whether they can invoke initializers and/or destructors)
have not been specified.
}
\note{
No driver has yet implemented this functionality.
}
\seealso{
\code{\link{dbExecStatement}}
\code{\link{dbExec}}
\code{\link{fetch}}
\code{\link{getFields}}
}
\examples{\dontrun{
makeImage <- function(x) {
  .C("make_Image", as.integer(x), length(x))
}

rs <- dbExecStatement(con, sql.query)
flds <- getFields(rs)
flds[3, "Sclass"] <- makeImage

setDataMappings(rs, flds)

im <- fetch(rs, n = -1)
}
}
\keyword{interface}
\keyword{database}
% docclass is function
% Converted by Sd2Rd version 1.15.2.1.
% vim:syntax=tex
