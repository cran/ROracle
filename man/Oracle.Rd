\name{Oracle}
\alias{Oracle}
\alias{OraManager}
\title{
  Instantiate an Oracle client from the current R or S session
}
\description{
This function creates and initializes an Oracle client.
It returns an object that allows you to connect
to one or several Oracle servers.
}
\usage{
Oracle(max.con = 10, fetch.default.rec = 500, force.reload = F)
}
\arguments{
\item{max.con }{
  maximum number of connections that we intend to have open.
  This can be up to 10, a limit hard-coded in the current implementation.
  }
\item{fetch.default.rec}{
  number of records to fetch at one time from the database.
  (The \code{fetch} method uses this number as a default.)
  }
\item{force.reload}{
  should we reload (reinitialize) the client code?
  Setting this to \code{TRUE} allows you to change
  default settings.  Notice that all connections should be closed
  before re-loading.
  }
}
\value{
An object \code{OraManager} that extends 
\code{dbManager} and 
\code{dbObjectId}.
This object is required to create connections
to one or several Oracle database engines.
}
\section{Side Effects}{
The R/S client part of the database communication is initialized,
but note that connecting to the database engine needs to be done through
calls to \code{\link{dbConnect}}.
}
\details{
This object is a singleton, that is, on subsequent invocations
it returns the same initialized object. 

This implementation allows you to connect
to multiple host servers and run multiple connections on each server
simultaneously.
}
\section{User authentication}{
The usual methods to pass authentication parameters to the
server (e.g., user, password, database name) is either through the the 
arguments \code{user}, \code{password}, and \code{dbname} to
\code{\link{dbConnect}}, or the Oracle's environemnt variable
\code{\$ORACLE\_SID}.

}
\section{References}{
See the Omega Project for Statistical Computing
at \url{http://www.omegahat.org}
for more details on the R/S database interface.

See the documentation at the Oracle Web site
\url{http://www.mysql.com} for details.
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
m <- dbManager("Oracle")
con <- dbConnect(m, user = "opto", password="pure-light", db="oras")

# you can also use Oracle's user/password@dbname convention
con2 <- dbConnect(m, user = "opto/pure-light@oras")

# or if you have defined the ORACLE_SID shell variable
con3 <- dbConnect(m, user = "opto", password = "pure-light")

# clone an existing connection
w <- dbConnect(con)

# execute a statement and fetch its output chunks at a time
rs <- dbExec(con, "select * from HTTP_ACCESS where IP_ADDRESS = '127.0.0.1'")
df <- fetch(rs, n = 50)
hasCompleted(rs)
df2 <- fetch(rs, n = -1)
hasCompleted(rs)
[1] TRUE
close(rs)
getTables(con)    
}
}
\keyword{interface}
\keyword{database}
% vim:syntax=tex
