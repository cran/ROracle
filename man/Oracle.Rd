\name{Oracle}
\alias{Oracle}
\alias{OraDriver}    % but this is a class!!!
\title{
  Instantiate an Oracle client from the current R or S session
}
\description{
This function creates and initializes an Oracle client from
the current R/Splus session.
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
An object \code{OraDriver} whose class extends 
\code{DBIDriver} and 
\code{dbObjectId}.
This object is used to create connections, using the
function \code{dbConnect},
to one or several Oracle database engines.
}
\section{Side Effects}{
The R/Splus client part of the database communication is initialized,
but note that connecting to the database engine needs to be done through
calls to \code{\link[DBI]{dbConnect}}.
}
\details{
This object is a singleton, that is, on subsequent invocations
it returns the same initialized object. 

This implementation allows you to connect
to multiple host servers and run multiple connections on each server
simultaneously.
}
\section{Oracle user authentication}{
In order to establish a connection to an Oracle server
users need to provide a user name, a password, and possibly
an ``Oracle SID'' (i.e., a database name);
by default the Oracle SID is taken from the environment variable 
\code{\$ORACLE\_SID}.
The function \code{dbConnect} allows authentication strings 
similar to the Oracle monitor \code{SQL*Plus}, namely, a 
string of any of the following forms:
\enumerate{
\item \code{"user/passsword"} 
\item \code{"user/password@dbname"}
\item \code{"/"} (provided the Oracle server is set up to use the
   underlying operating system users and passwords);
}
}
\section{References}{
See the Omega Project for Statistical Computing
at \url{http://www.omegahat.org}
for more details on the R/Splus database interface.

See the documentation at the Oracle Web site
\url{http://www.oracle.com} for details.
}
\seealso{
On database managers:

\code{\link[DBI]{dbDriver}}
\code{\link{Oracle}}
\code{\link[DBI]{dbUnloadDriver}}

On connections:

\code{\link[DBI]{dbConnect}}
\code{\link[DBI]{dbDisconnect}}

On queries and result objects:

\code{\link[DBI]{dbSendQuery}}
\code{\link[DBI]{fetch}}
\code{\link[DBI]{dbGetQuery}}
\code{\link[DBI]{dbClearResult}}

On transaction management:

\code{\link[DBI]{dbCommit}}
\code{\link[DBI]{dbRollback}}

On meta-data:

\code{\link[DBI]{dbGetInfo}}
\code{\link[base]{summary}}
\code{\link[DBI]{dbListTables}}
\code{\link[DBI]{dbListFields}}
\code{\link[DBI]{dbListConnections}}
\code{\link[DBI]{dbListResults}}
\code{\link[DBI]{dbGetException}}
\code{\link[DBI]{dbGetStatement}}
\code{\link[DBI]{dbHasCompleted}}
\code{\link[DBI]{dbGetRowCount}}
\code{\link[DBI]{dbGetAffectedRows}}
}
\examples{\dontrun{
## create a Oracle instance and create one connection.
ora <- Oracle()     ## or dbDriver("Oracle")
con <- dbConnect(ora, user = "opto", password="pure-light", db="oras")

## you can also use Oracle's user/password@dbname convention
con2 <- dbConnect(ora, user = "opto/pure-light@oras")

## or if you have defined the ORACLE_SID shell variable
con3 <- dbConnect(ora, user = "opto", password = "pure-light")

## clone an existing connection
w <- dbConnect(con)

## execute a statement and fetch its output in chunks of no more
## than 5000 rows at a time

rs <- dbSendQuery(con, "select * from HTTP_ACCESS where IP_ADDRESS='127.0.0.1'")

while(!dbHasCompleted(rs)){
   df <- fetch(rs, n = 5000)
   process(df)
}

## a concise description of the driver 
summary(ora)

<OraDriver:(24694)> 
  Driver name:  Oracle (ProC/C++) 
  Max  connections: 10 
  Conn. processed: 9 
  Default records per fetch: 500 
  Open connections: 2 

## a full description of the ora connection
summary(con, verbose = T)

<OraConnection:(25272,0)> 
  User: opto 
  Dbname: oras 
  Oracle Server version: 
    Oracle8 Enterprise Edition Release 8.0.4.0.0 - Production 
    PL/SQL Release 8.0.4.0.0 - Production 
    CORE Version 4.0.4.0.0 - Production 
    TNS for Solaris: Version 8.0.4.0.0 - Production 
    NLSRTL Version 3.3.1.0.0 - Production 

dbHasCompleted(rs)
[1] TRUE
dbClearResult(rs)      ## done with this query
[1] TRUE
dbDisconnect(con)     ## done with this connection
[1] TRUE
}
}
\keyword{interface}
\keyword{database}
% vim:syntax=tex
