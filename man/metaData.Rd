\name{metaData}
\alias{hasCompleted}
\alias{getAffectedRows}
\alias{getConnection}
\alias{getConnections}
\alias{getCurrentDatabase}
\alias{getDatabases}
\alias{getException}
\alias{getFields}
\alias{getInfo}
\alias{getResultSet}
\alias{getResultSets}
\alias{getStatement}
\alias{getTables}
\alias{getTableFields}
\alias{getTableIndices}
\alias{getRowCount}
\alias{getNullOk}
\alias{getVersion}
\title{
  R/S database interface meta-data
}
\description{
Extract meta-data associated with various objects
}
\usage{
getInfo(dbObject, what)      # meta-data for any dbObject
getConnection(what, ...)

getConnections(mgr)          # meta-data for dbManager objects
getDatabases(obj, ...)       
getTables(obj, dbname, row.names, ...)
getVersion(obj, ...)
getTableIndices(res, table, dbname, ...)

getCurrentDatabase(con)      # meta-data for dbConnection objects
getException(con, ...)
getResultSets(con, ...)
getTableFields(res, table, dbname, ...)

getStatement(res)             # meta-data for dbResultSet objects
getFields(res, ...)
hasCompleted(res, ...)
getRowCount(res, ...)
getRowsAffected(res, ...)
getNullOk(res, ...)
}
\arguments{
\item{dbObject}{
  any object that implements some functionality in the R/S
  interface to databases (e.g., \code{dbManager},
  \code{dbConnection}, \code{dbResultSet}).
  
}
\item{mgr}{
  refers to a \code{dbManager} object.
  
}
\item{con}{
  refers to a \code{dbConnection} object.
  
}
\item{rs}{
  refers to a \code{dbResultSet} object.
  
}
\item{dbname}{
  refers to a database name (instance) on the server.
  
}
\item{table}{
  refers to a table name in either the current database or 
  in \code{dbname}.
  
}
}
\value{
either a character vector or a named list of meta-data objects.
}
\details{
These functions implement a minimal set of more or less
obvious meta-data describing the most important aspects of
the R/S to RDBMS interface.

The \code{getInfo} works very similarly 
to the function \code{options} 
in that it attempts to 
extract what the user may request, possibly NULL if it can't
locate the specific piece of meta-data.

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
m <- dbManager(dbms)

# Extract meta-data information.  What MySQL databases are there 
# available on host "wyner"

> getDatabases(m, host = "wyner")
   Database 
1     mysql
2      opto
3      test
4 iptraffic
5     fraud

# What tables are there in the Oracle "opto" database? 

> dbTables(m, dbname = "opto", host = "wyner")
  Tables in opto 
1           PBCT
2          PURGE
3             WL
4          liv25
5          liv85

# let's look at some result set meta-data

> con <- dbConnect(m)
> rs <- dbExecStatement(con, query.sql)

> getStatement(rs)
[1] "show tables"

> hasCompleted(rs)
[1] 0

> getRowCount(rs)
[1] 3

> info <- getInfo(rs)
> names(info)
[1] "statement"     "isSelect"        "rowsAffected"     
[4] "rowCount"     "completed"    "fieldDescription"
> getStatement(rs)
[1] "show tables"

# the following are pieces of meta-data associated with 
# the R/S DBI implementation, versions for the various pieces 
# of software (client, server, interface), etc.

# dbManager object

> names(getInfo(m))  
[1] "connectionIds"     "fetch_default_rec"
[3] "managerId"         "length"           
[5] "num_con"           "counter"          
[7] "clientVersion"    

#  dbConnection object

> names(getInfo(con))
[1] "host"            "user"           
[3] "dbname"          "conType"        
[5] "serverVersion"   "protocolVersion"
[7] "threadId"        "rsId"           

# resultSet object

> names(getInfo(rs)) 
[1] "statement"        "isSelect"        
[3] "rowsAffected"     "rowCount"        
[5] "completed"        "fieldDescription"
}
}
\keyword{interface}
\keyword{database}
% vim:syntax=tex
