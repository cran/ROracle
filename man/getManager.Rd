\name{getManager}
\alias{getManager}
\title{
  Get a database manager object from a derived handle
}
\description{
Get the dbManager handle from some other dbObject -- useful
when one forgets to save the manager handle 
}
\usage{
getManager(obj, ...)
}
\arguments{
\item{obj}{
any \code{dbObject}, i.e., any remote reference to a RDBMS
as implemented by the R/S database interface (a \code{dbConnection},
\code{dbResultSet}, etc.)
}
\item{\dots }{
any other arguments are passed to the implementing method.
}
}
\value{
a \code{dbManager} object.
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
> mgr <- dbManager(con)
}
}
\keyword{interface}
\keyword{database}
\keyword{}
% vim:syntax=tex
