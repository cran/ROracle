\name{methods.Oracle}
\alias{SQLDataType.OraConnection}
\alias{SQLDataType.OraManager}
\alias{SQLDataType.default}
\alias{as.OraConnection}
\alias{as.OraManager}
\alias{as.OraResultSet}
\alias{as.integer.OraConnection}
\alias{as.integer.OraManager}
\alias{as.integer.OraResultSet}
\alias{as.integer.dbObjectId}
\alias{assignTable.OraConnection}
\alias{close.OraConnection}
\alias{close.OraResultSet}
\alias{close.dbConnection}
\alias{close.resultSet}
\alias{commit.OraConnection}
\alias{dbConnect.OraConnection}
\alias{dbConnect.OraManager}
\alias{dbConnect.default}
\alias{dbExec.OraConnection}
\alias{dbExecStatement.OraConnection}
\alias{describe.OraConnection}
\alias{describe.OraManager}
\alias{describe.OraResultSet}
\alias{execStatement.OraConnection}
\alias{existsTable.OraConnection}
\alias{existsTable.dbConnection}
\alias{fetch.OraResultSet}
\alias{format.OraConnection}
\alias{format.OraManager}
\alias{format.OraResultSet}
\alias{format.dbObjectId}
\alias{getConnection.OraConnection}
\alias{getConnection.OraResultSet}
\alias{getConnection.default}
\alias{getConnections.OraManager}
\alias{getCurrentDatabase.OraConnection}
\alias{getDatabases.OraConnection}
\alias{getException.OraConnection}
\alias{getException.OraResultSet}
\alias{getFields.OraResultSet}
\alias{getFields.OraConnection}
\alias{getInfo.OraConnection}
\alias{getInfo.OraManager}
\alias{getInfo.OraResultSet}
\alias{getManager.OraConnection}
\alias{getManager.OraResultSet}
\alias{getNumCols.default}
\alias{getResultSets.OraConnection}
\alias{getRowCount.OraResultSet}
\alias{getRowsAffected}
\alias{getRowsAffected.OraResultSet}
\alias{getStatement.OraResultSet}
\alias{getTable.OraConnection}
\alias{getTable.dbConnection}
\alias{getTableFields.OraConnection}
\alias{getTableFields.OraResultSet}
\alias{getTableIndices.OraConnection}
\alias{getTables.OraConnection}
\alias{getVersion.OraConnection}
\alias{getVersion.OraManager}
\alias{hasCompleted.OraResultSet}
\alias{load.OraManager}
\alias{load.default}
\alias{loadManager.OraManager}
\alias{new.OraManager}
\alias{new.OraObject}
\alias{new.OraConnection}
\alias{new.OraResultSet}
\alias{new.dbObjectId}
\alias{new.default}
\alias{newConnection.OraManager}
\alias{print.OraConnection}
\alias{print.OraManager}
\alias{print.OraResultSet}
\alias{print.dbObjectId}
\alias{quickSQL.OraConnection}
\alias{removeTable.OraConnection}
\alias{removeTable.dbConnection}
\alias{rollback.OraConnection}
\alias{show.default}
\alias{unload.OraManager}

\title{Support Ora methods}
\description{
  Ora support methods. For details on what it does, see the 
  documentation of the generic function.
}
\usage{
<generic>.OraManager(obj, ...)   
}
\arguments{
  \item{<generic>}{refers to an actual generic function name, e.g., 
        \code{dbConnect}}
  \item{obj}{is some kind of Ora object}
  \item{\dots}{additional arguments}
}
\details{
  See \code{help(generic)} for a description of the
  functionality that this method provides in the
  context of the Ora driver.
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
m <- dbManager("Oracle")
con <- dbConnect(m, user="opto", pass="pure-light", dbname="opto")
}
}
\keyword{interface}
\keyword{database}
% vim:syntax=tex
