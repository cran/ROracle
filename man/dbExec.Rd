\name{dbExec}
\alias{dbExec}
\title{
  Execute an SQL script on a given database connection
}
\description{
Submits and executes an arbitrary SQL script (one or more
statements) on a specific connection.
}
\usage{
dbExec(con, statement, ...)
}
\arguments{
\item{con}{
a connection object (i.e., an object that extends 
\code{dbConnection}).
}
\item{script}{
a character vector with one or more SQL statements.
}
\item{\dots }{
database-specific parameters may be specified.
}
}
\value{
an object that extends \code{dbResult}, in the case of
an SQL statement that produces no output (e.g., \code{INSERT}),
or \code{dbResultSet} in the case of a 
\code{SELECT}-like statement.
}
\section{Side Effects}{
The statements are submitted to the server connected through
the connection \code{con.}
}
\details{
This function submits and executes SQL scripts, i.e., one or 
more SQL statements, to the database engine.  To fetch records you need to 
use the function \code{fetch}.
Currently it is undefined how multiple result sets are to be
processed.
}
\section{Bugs}{
  Current implementations can only handle one-statement scripts.
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
mgr <- dbManger("Oracle")
con <- dbConnect(mgr)
rs <- dbExecStatement(con, "SELECT * from liv25")
data <- fetch(rs, n = -1)
}
}
\keyword{interface}
\keyword{database}
% vim:syntax=tex
