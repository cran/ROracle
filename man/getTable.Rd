\name{getTable}
\alias{getTable}
\alias{assignTable}
\alias{existsTable}
\alias{removeTable}
\title{
  Convenience functions for Importing/Exporting DBMS tables into R/S.
  (Note: not all yet implmented by the Oracle driver.)
}
\description{
  These functions mimic their R/S counterpart 
  \code{get},
  \code{assign},
  \code{exists}, and
  \code{remove},
  except that they generate SQL code that gets executed
  in a relational database engine.
  They all work over a \code{RDBMS connection}, and an SQL table name
  (their semantics have been tentatively extended a bit to preserve 
  \code{row.names}).
}
\usage{
  getTable(con, name,  ...)
  assignTable(con, name, value, row.names = T, ...)
  existsTable(con, name, ...)
  removeTable(con, name, ...)
}
\arguments{

\item{con}{
  a database connection object.
  }
\item{name}{
  a character string specifying the SQL table name.
  }
\item{value}{
  an R/S data.frame (or coerceable to data.frame).
  }
\item{row.names}{
  in the case of \code{getTable}, this argument can be a string or
  an index specifying the column in the SQL table to be used as 
  \code{row.names} in the output data.frame (a \code{NULL}, \code{""}, or 0 
  specifies that no column should be used as \code{row.names} in the output).

  In the case of \code{assignTable}, this argument should be a logical
  specifying whether the \code{row.names} should be appended to the
  output RDBMS table; if \code{TRUE}, the extra field will be named 
  \code{"row_names"}).
  }
\item{overwrite}{
  a logical specifying whether to overwrite an existing table
  or not.  Its default is \code{FALSE}.
  }
\item{append}{
  a logical specifying whether to append to an existing table
  in the RDBMS.
  Its default is \code{FALSE}.
  }
\item{\dots }{
  any optional arguments that the underlying database driver
  supports. 
  }

}

\value{
  \code{getTable} returns a data.frame;
  the other functions return \code{TRUE} or
  \code{FALSE} denoting whether the operation
  was successful or not.
}

\section{Side Effects}{
An SQL statement is generated and executed on the RDBMS;
the result set it produces is fetched in its entirety.
These operations may failed if the underlying database driver
runs out of available connections and/or result sets.

The semantics of \code{assign} are slightly extended to allow
appending to an existing table.  Also note that constraints
on the remote table may prevent certain assignments (e.g., 
appending data to a table with a primary key field could fail 
if there are duplicate values in the corresponding data frame 
column).
}
\references{
  See the The Omega Project for Statistical Computing 
  \url{http://www.omegahat.org} for details on the R/S database interface.
}
\note{The translation of identifiers between R/S and SQL is done through
  calls to \code{\link{make.names}} and \code{\link{make.SQL.names}}, 
  but we cannot guarantee that the conversion is reversible.  For
  details see \code{\link{make.SQL.names}}.
}
\seealso{
\code{\link{get}}
\code{\link{assign}}
\code{\link{exists}}
\code{\link{remove}}
\code{\link{dbConnect}}
\code{\link{Oracle}}
}
\examples{\dontrun{
con <- dbConnect("Oracle", group = "vitalAnalysis")
assignTable(con, "fuel_frame", fuel.frame)
removeTable(con, "fuel_frame")
if(existsTable(con, "RESULTS")){
   assignTable(con, "RESULTS", results2000, append = T)
else
   assignTable(con, "RESULTS", results2000)
}
}
}
\keyword{interface}
\keyword{database}
% docclass is function
% Converted by Sd2Rd version 1.15.2.1.
% vim:syntax=tex
