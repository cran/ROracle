\name{getNumRows}
\alias{getNumRows}
\alias{getNumCols}
\title{
  Get number of rows/columns of an SQL table
}
\description{
 
Get the number of rows or columns of a remote SQL table
}
\usage{
getNumCols(con, name, ...)
getNumRows(con, name, ...)
}
\arguments{
\item{con}{
a \code{dbConnection} object.
}
\item{name}{
a character string specifying the name of the table on the remote RDBMS
}
\item{\dots }{
any additional arguments are passed to the implementing method.
}
}
\value{
an integer specifying the number of rows or columns.
}
\section{Side Effects}{
Depending on the driver, a new connection or a new cursor (result set)
will be opened for communicating with the RDBMS.  Therefore, drivers
that allow only one connection or one result set need to verify
that the connection specified as the first argument does not
have any pending work.
}
\examples{\dontrun{
con <- dbConnect("Oracle", group = "opto")
getNumRows(con, "WAVELENGTH")
[1] 118336
}
}
\seealso{
\code{\link{getTable}}
\code{\link{assignTable}}
\code{\link{removeTable}}
\code{\link{existsTable}}
}
\keyword{interface}
\keyword{database}
% docclass is function
% Converted by Sd2Rd version 1.15.2.1.
% vim:syntax=tex
