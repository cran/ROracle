\name{fetch}
\alias{fetch}
\title{
  Fetch records from a previously executed SELECT statement
}
\description{
Fetch records from a previously executed SELECT statement
}
\usage{
fetch(res, n, ...)
}
\arguments{

\item{res}{
  a \code{resultSet} object.
  This object needs to be the result of a \code{SELECT}
  or \code{SELECT}-like statement, as produced
  by \code{dbExec.}
  or \code{dbExecStatement.}
  SQL statements such as \code{INSERT}, \code{DELETE},
  do not create result sets.
  }
\item{n}{
  maximum number of records to retrieve per fetch.
  Use \code{n = -1} to retrieve all pending records.
  Some implementations may recognize other special values
  (RS-MySQL interprets \code{n = 0} to mean "use whatever
  default was set in the call to \code{MySQL}).
  }
\item{\dots }{
  any other database-engine specific arguments.
  }

}

\value{
  a data.frame with as many rows as records  were fetched
  and as many columns as fields in the result set.
}
\section{Side Effects}{
  As the R/S client fetches records the remote database server
  updates its cursor accordingly.
}
\details{
  See the notes for the various database server implementations.
}
\note{
  Make sure you close the result set with \code{close(resultSet)}
  as soon as you finish retrieving the records you want.
}
\references{
  See the Omega Project for Statistical Computing
  (\url{http://www.omegahat.org})
  for details on the R/S interface to databases.
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
# Run an SQL statement by creating first a resultSet object
> m <- Oracle()
> con <- dbConnect(m)    
> rs <- dbExecStatement(con, 
         statement = "SELECT w.laser_id, w.wavelength, p.cut_off 
                      FROM WL w, PURGE P
                      WHERE w.laser_id = p.laser_id
                      ORDER BY w.laser_id")
> rs
OraResultSet id = (12629,1,3)

# we now fetch the first 100 records from the restulSet into a data.frame
> data1 <- fetch(rs, n = 100)   
> dim(data)
[1] 10  18

> hasCompleted(rs)
[1] 0

# let's get all remaining records
> data2 <- fetch(rs, n = -1)
}
}
\keyword{interface}
\keyword{database}
% docclass is function
% Converted by Sd2Rd version 1.15.2.1.
% vim:syntax=tex
