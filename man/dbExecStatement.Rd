\name{dbExecStatement}
\alias{dbExecStatement}
\title{
  Execute an SQL statement on a given database connection
}
\description{
Submits and executes an arbitrary SQL statement on a
specific connection.
}
\usage{
dbExecStatement(con, statement, ...)
}
\arguments{
\item{con}{
a connection object (i.e., an object that extends 
\code{dbConnection}).
}
\item{statement}{
a character vector of length 1 with the SQL statement.
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
The statement is submitted to the server connected through
the connection \code{con.}
}
\details{
This function only submits and executes the SQL statement to
the database engine.  It does \emph{not} extracts any
records:  for that you need to use the function 
\code{fetch}.
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
% docclass is function
% Converted by Sd2Rd version 1.15.2.1.
% vim:syntax=tex
