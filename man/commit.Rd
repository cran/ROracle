\name{commit}
\alias{commit}
\alias{rollback}
\title{
  RDBMS Transaction Management
}
\description{
Commit/rollback SQL transactions
}
\usage{
commit(con, ...)

rollback(con, ...)
}
\arguments{
\item{con}{
a \code{dbConnection} object, as
produced by the function 
\code{dbConnect}.
}
\item{\dots }{
any database-specific arguments.
}
}
\value{
NULL
}
\section{Side Effects}{
The current transaction on the connections \code{con}
is committed or rolled back.
}
\details{
Not all database engines implement transaction management,
MySQL, for instance.
}
\references{
See 
The Omega Project for Statistical Computing (\url{http://www.omegahat.org})
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
ora <- Oracle()
con <- dbConnect(ora)
rs <- dbExecStatement(con, 
      "delete * from PURGE as p where p.wavelength<0.03")
if(rowsAffected(rs) > 250){
  warning("dubious deletion -- rolling back transaction")
  rollback(con)
}
}
}
\keyword{interface}
\keyword{database}
% docclass is function
% Converted by Sd2Rd version 1.15.2.1.
% vim:syntax=tex
