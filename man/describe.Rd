\name{describe}
\alias{describe}
\title{
  Describe an object through its meta-data
}
\description{
Prints a concise description of the meta-data associated
with an object
}
\usage{
describe(obj, verbose, ...)
}
\arguments{
\item{object}{
any object that implements some functionality under the R/S interface 
to databases, e.g.,
\code{dbManager},
\code{dbConnection},
\code{dbResultSet},
\code{resultSet}.
}
\item{verbose}{
a logical controling the amount of output. 
}
\item{\dots }{
any other argument that the individual methods may take.
}
}
\value{
NULL
}
\section{Side Effects}{
This function is used mainly for its printing side effects.
}
\section{References}{
See the Omega Project for Statistical Computing at
\url{http://www.omegahat.org}
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
Ora
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
> m <- dbManager("Oracle")
> ...
# Let's look at the status of the manager

> describe(m, verbose = F)   
OraManager id = (7269) 
  Max  connections: 16 
  Conn. processed: 1 
  Default records per fetch: 500 
  Open connections: 1 

> rs <- dbExecStatement(con, query)
> ...

# The following shows that we extracted only one field
# names "Tables in opto" plus its corresponding S class, internal 
# database type, and various other internal attributes.

> getFields(rs)
           name    Sclass              type len precision scale nullOK 
1 Tables in opto character FIELD_TYPE_STRING  64        64     0      F

# A full description of the result set is

> describe(rs, verbose = T)
OraResultSet id = (7269,3,1) 
  Statement: show tables 
  Has completed? no 
  Affected rows: -1 
  Rows fetched: 3 
  Fields:
            name    Sclass              type len precision scale nullOK 
1 Tables in opto character FIELD_TYPE_STRING  64        64     0      F
}
}
\keyword{database}
\keyword{interface}
% docclass is function
% Converted by Sd2Rd version 1.15.2.1.
% vim:syntax=tex
