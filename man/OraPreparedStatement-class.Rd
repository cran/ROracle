% $Id: OraPreparedStatement-class.Rd,v 1.3 2006/02/08 19:17:00 dj Exp dj $
\name{OraPreparedStatement-class}
\docType{class}
\alias{OraPreparedStatement-class}
\title{Oracle Prepared Statement}
\description{
A class that encapsulates the information on an Oracle
prepared statement
}
\section{Objects from the Class}{
Use the method \code{\link[ROracle:dbPrepareStatement-methods]{dbPrepareStatement}} to create an Oracle 
prepared statement and \code{\link{dbExecStatement}} to re-bind new 
data and execute the cached statement.
}
\section{Slots}{
  \describe{
    \item{\code{Id}:}{an opaque reference into the prepared statement.}
  }
}
\section{Extends}{
Class \code{"DBIPreparedStatement"}, directly.
Class \code{"OraResult"}, directly.
Class \code{"DBIObject"}, by class "DBIPreparedStatement".
Class \code{"DBIResult"}, by class "OraResult".
Class \code{"OraObject"}, by class "OraResult".
Class \code{"dbObjectId"}, by class "OraResult".
}
\section{Methods}{
  \describe{
    \item{dbExecStatement}{\code{signature(ps = "OraPreparedStatement", data = "data.frame")}: 
    executes a prepared statement re-binding new data to it.
    }
    \item{dbGetInfo}{\code{signature(dbObj = "OraPreparedStatement")}: 
    returns a list of metadata associated with the prepared statement.
    }
    \item{summary}{\code{signature(object = "OraPreparedStatement")}: 
    writes a brief summary of the status of the prepared statement. 
    }
  }
}

\section{Background}{
Oracle's prepared statements (like other RDBMS') are SQL statements
that are parsed and cached to increase performance 
when the SQL code is to be executed repeatedly but with different data;
for instance when inserting the rows of a \code{data.frame} into a table
the SQL for each row is exactly the same, only the row data changes.

The function \code{\link[ROracle:dbPrepareStatement-methods]{dbPrepareStatement}} creates objects that
extend the base class \code{DBIPreparedStatement}.
These objects are simple references into C structures that store
the various aspects (the text of the SQL statement, sets of buffers
for transferring data back and forth, etc).

The function \code{\link{dbExecStatement}} takes a prepared statement
object and a \code{data.frame} and binds one or more of its columns to
the RDBMS table or object according to the specification in the prepared
statement.
}
\note{As of the DBI version 0.1-5 prepared statements are not part 
of the R/S Database Interface definition (DBI).}

\references{
  See the Database Interface definition document
  \code{DBI.pdf} in the base directory of this package
  or \url{http://stat.bell-labs.com/RS-DBI}.
}

\seealso{
 DBI classes:
 \code{\link{OraObject-class}}
 \code{\link{OraDriver-class}}
 \code{\link{OraConnection-class}}
 \code{\link{OraResult-class}}
 \code{\link{OraPreparedStatement-class}}
}

\examples{\dontrun{
  ora <- dbDriver("Oracle")
  con <- dbconnect(ora, "user/password")
  ps <- dbPrepareStatement(con, 
           "INSERT into QUAKES (lat, long_1) VALUES (:1, :2)",
           bind = c("numeric", "numeric"))
  dbExecStatement(ps, quakes)
  dbCommit(con)
}
}
\keyword{database}
\keyword{interface}
\keyword{classes}
%% vim: syntax=tex
