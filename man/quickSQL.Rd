\name{quickSQL}
\alias{quickSQL}
\title{
  Quick SQL Execution
}
\description{
Simplifies queries by submitting an SQL command and fetching 
its output in one function
}
\usage{
quickSQL(con, statement, ...)
}
\arguments{
\item{con}{
an open \code{dbConnection} object.
}
\item{statement}{
an SQL statement as a character vector.
}
\item{\dots }{
any additional arguments specific to the database engine
may be specified.
}
}
\value{
a \code{data.frame}
in the case of a \code{SELECT}-like statement, or
NULL otherwise.
}
\details{
This function simply calls \code{\link{dbExecStatement}}
followed by \code{fetch}.
}
\section{Bugs:}{
Perhaps this function should be named \code{dbQuery}
or \code{dbImmediate}?
}
\section{References}{
See the Omega Project for Statistical Computing
at \url{http://www.omegahat.org}
for more details on the R/S database interface.
}
\seealso{
On database managers:

\code{\link{dbManager}}
\code{\link{Oracle}}
\code{\link{load}}
\code{\link{unload}}

On connections, SQL statements and resultSets:

\code{\link{dbExecStatement}}
\code{\link{dbExec}}
\code{\link{fetch}}
\code{\link{quickSQL}}

On transaction management:

\code{\link{commit}}
\code{\link{rollback}}

On meta-data:

\code{\link{describe}}
\code{\link{getVersion}}
\code{\link{getDatabases}}
\code{\link{getTables}}
\code{\link{getFields}}
\code{\link{getCurrentDatabase}}
\code{\link{getTableIndices}}
\code{\link{getException}}
\code{\link{getStatement}}
\code{\link{hasCompleted}}
\code{\link{getRowCount}}
\code{\link{getAffectedRows}}
\code{\link{getNullOk}}
\code{\link{getInfo}}
}
\examples{\dontrun{
# The following extract all the tables in the current database

mgr <- dbManager("Oracle")
con <- dbConnect(mgr)
quickSQL(con, "select * from PURGE")
}
}
\keyword{interface}
\keyword{database}
% vim:syntax=tex
