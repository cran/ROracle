\name{dbConnect}
\alias{dbConnect}
\title{
  Create a connection to a RDBMS
}
\description{
  Connect to a RDBMS going through the appropriate authorization
  procedure
}
\usage{
dbConnect(mgr, ...)
}
\arguments{
\item{mgr}{
a \code{dbManager} object, 
a character string specifying the RDBMS, e.g., "MySQL", 
"Oracle", "Informix", or another \code{dbConnect} object.
}
\item{\dots }{
authorization arguments needed by the RDBMS instance;
these typically include \code{user}, \code{password},
\code{dbname}, \code{host}, \code{port}, etc.
For details see the appropriate \code{dbManager}.
}
}
\value{
An object that extends \code{dbConnect} and 
\code{dbObjectId} in a database-specific manner.
For instance \code{dbConnect("Oracle")} produces
an object of class \code{OraConnection}.

This object is used to direct SQL commands to the database engine.
}
\section{Side Effects}{
A connection between R/S and the database server is established,
and the R/S program becodes a client of the database engine.
Typically the connections is through the TCP/IP protocol, 
but this will depend on vendor-specific details.
}
\details{
Some implementations (e.g., RS-MySQL, RS-Oracle) may allow you
to have multiple connecions open, so you may invoke this 
function repeatedly assigning its output to different objects.
}
\notes{
Make sure you close the connection using \code{close(con)}
when it is not longer needed.
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
# create a Oracle instance and create one connection.
> m <- dbManager("Oracle")
> m
OraManager id = (7269) 

# open the connection using user, passsword, etc., as
# specified in the file \file{\$HOME/.my.cnf}
> con <- dbConnect(m)    

# Let's look at the status of the manager
> describe(m)
OraManager id = (7269) 
  Max  connections: 16 
  Conn. processed: 1 
  Default records per fetch: 500 

# Run an SQL statement by creating first a resultSet object
> rs <- dbExecStatement(con, 
         statement = "SELECT w.laser_id, w.wavelength, p.cut_off 
                      FROM WL w, PURGE P
                      WHERE w.laser_id = p.laser_id
                      SORT BY w.laser_id")
> rs
OraResultSet id = (12629,1,3)

# we now fetch records from the restulSet into a data.frame
> data <- fetch(rs, n = -1)   # extract all rows
> dim(data)
[1] 1779  18
}
}
\keyword{interface}
\keyword{database}
% vim:syntax=tex
