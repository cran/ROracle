% $Id: Oracle.Rd 155 2006-02-08 19:19:08Z dj $
\name{Oracle}
\alias{Oracle}
\title{
  Instantiate an Oracle client from the current \R session
}
\description{
This function creates and initializes an Oracle client from
the current \R session.
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
\code{DBIDriver} and the mixin (helper) class \code{dbObjectId}.
This object is used to create connections, using the
function \code{dbConnect},
to one or several Oracle database engines.
}
\section{Side Effects}{
The \R client part of the database communication is initialized,
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

\section{Prepared statements and data.frame bindings}{

As of version 0.5-0, \code{ROracle} implements \R data binding
to prepared SQL statements.  This is done in two stages with the functions
\code{\link[ROracle:dbPrepareStatement-methods]{dbPrepareStatement}} and \code{\link{dbExecStatement}}.

In the first stage of preparing a statement column numbers are embedded 
inside the SQL statement, e.g., 
\code{"insert into my\_table (id, name, val) VALUES (:1, :3, :2)"} 
and the S class of those columns are specified in the \code{bind=} argument
to \code{\link[ROracle:dbPrepareStatement-methods]{dbPrepareStatement}} 

In the second stage \code{\link{dbExecStatement}}
binds the pre-specified columns from a supplied  \code{data=} data frame 
to the SQL statement and the SQL statement is executed once for each
row in the input data frame.  This step can be repeated with new data
as many times as needed.

\emph{It is very important} to note that typically a prepared statement
implicitly will define a new transaction which needs to be
explicitly committed with \code{\link[DBI]{dbCommit}} or
rolled back with \code{\link[DBI]{dbRollback}}.

The current implementation allows only primitive types
\code{c("numeric", "integer", "logical", "character")} for binding.
}

\section{Transactions}{ 
The current implementation directly supports transaction
commits and rollbacks on a connection-wide basis through calls
to \code{\link[DBI]{dbCommit}} and \code{\link[DBI]{dbRollback}}.
Save points are not yet directly implemented, but you may be able
to define them and rollback to them through calls to dynamic SQL
with \code{\link[DBI]{dbGetQuery}}.

Notice that Oracle (and ANSI/ISO compliant DBMS) transactions are 
implicitly started when data definition SQL are executed (create
table, etc.), which helper functions like \code{\link[DBI]{dbWriteTable}}
may execute behind the scenes.   You may want or need to commit
or roll back your work before issuing any of these helper functions.
}

\section{References}{
For more details on the \R database interface
see the PDF file \code{DBI.pdf} under the \code{doc}
directory of this package, 
\url{http://stat.bell-labs/RS-DBI}, and
the Omega Project for Statistical Computing
at \url{http://www.omegahat.org}.

See the documentation at the Oracle Web site
\url{http://www.oracle.com} for details.
}
\author{David A. James}
\seealso{
On database managers:

\code{\link[DBI]{dbDriver}}
\code{\link{Oracle}}
\code{\link[DBI]{dbUnloadDriver}}

On connections:

\code{\link[DBI]{dbConnect}}
\code{\link[DBI]{dbDisconnect}}

On queries, prepared statements, and result objects:

\code{\link[DBI]{dbSendQuery}}
\code{\link[DBI]{fetch}}
\code{\link[DBI]{dbGetQuery}}
\code{\link[DBI]{dbClearResult}}
\code{\link[ROracle:dbPrepareStatement-methods]{dbPrepareStatement}}   % should be moved to DBI
\code{\link[ROracle:dbPrepareStatement-methods]{dbExecStatement}}       % should be moved to DBI

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
dbHasCompleted(rs)
[1] TRUE
dbClearResult(rs)      ## done with this query
[1] TRUE

## prepare and bind columns 2, 3, and 7 to the Oracle table 
## fields "cell", "erlangs", "blocking"
ps <- dbPrepareStatement(con, 
         "INSERT into my_table (cell, erlangs, blocking) VALUE (:2,:3,:7)",
         bind = my.data.frame)

## execute one sql INSERT per row using columns 2, 3 and 7 
ps <- dbExecStatement(ps, my.data.frame)
ps <- dbExecStatement(ps, more.data)

dbCommit(con)  ## ok, everything looks fine

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

dbDisconnect(con)     ## done with this connection
[1] TRUE
}
}
\keyword{interface}
\keyword{database}
% vim:syntax=tex
