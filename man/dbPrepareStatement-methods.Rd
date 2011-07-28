% $Id: dbPrepareStatement-methods.Rd st_server_demukhin_r/1 2011/07/22 22:11:32 vsashika Exp $
\name{dbPrepareStatement-methods}
\docType{methods}
\alias{dbPrepareStatement}
\alias{dbPrepareStatement-methods}
\alias{dbPrepareStatement,OraConnection,character,character-method}
\alias{dbPrepareStatement,OraConnection,character,data.frame-method}
\alias{dbExecStatement}
\alias{dbExecStatement-methods}
\alias{dbExecStatement,OraPreparedStatement,data.frame-method}
\title{
Create a prepared SQL statement for repeated execution
}
\description{
  These methods parse and cache SQL statements 
  and binds R data for repeated execution.
}

\synopsis{
  dbPrepareStatement(conn, statement, bind, ...)
  dbExecStatement(ps, data, ...)
}
\usage{
  dbPrepareStatement(conn, statement, bind, ...)
  dbExecStatement(ps, data, ...)
}
\arguments{
  \item{conn}{a database connection}
  \item{statement}{a string with an SQL statement, possibly with
  embedded column number specifications of the form \code{:columnNum} 
  (e.g., \code{:1,:2,:6}) for binding those columns in the \code{data} 
  argument to \code{dbExecStatement}.
  }
  \item{bind}{a character vector parallel to the column specifications
  describing their R classes (e.g., \code{"character"}, \code{"numeric"}).
  You may supply a data.frame, in which case \code{bind=} is set to
  \code{sapply(data, class)}.
  }
  \item{ps}{a prepared statement object as produced by
  \code{dbPrepareStatement}.
  }
  \item{data}{a \code{data.frame} whose columns are to be bound to the
  SQL statement.
  }
  \item{\dots}{other arguments are passed to the driver implementation.
  For instance, the argument \code{ora.buf.size} is used to specify 
  the size of Oracle's internal binding buffers (ROracle sets these to
  500 elements by default).
  }
}

\details{
Prepared statements are SQL statements that are parsed and cached 
by the server to increase performance when the SQL code is to be executed 
repeatedly but with different data.

There are three distinct operations involved with prepared statements:
parsing and caching the SQL statement, binding \code{data.frame}
columns to the SQL, and executing the code (possibly repeatedly).

The function \code{dbPrepareStatement} takes a connection where
to parse and cache the SQL code.  Part of this operation is to
embed references to \code{data.frame} column numbers in the SQL code
and to specify their classes through the \code{bind=} argument.
The \code{ROracle} package uses \code{:n} inside
the SQL statement to bind the $n'th$ column, but other RDBMSs
use the question mark to signal a place holder, e.g., \code{?}.

The object that \code{dbPrepareStatement} produces is then
used together with a \code{data.frame} (which should agree with the 
bound specification) in calls to \code{dbExecStatement} to be executed
for each row of the \code{data.frame}.  This can be repeated with
new data.

Embedding column names, instead of column numbers, is not supported,
since some valid R names are not legal SQL names (e.g., R names
with dots \code{"."} in them).
}
\value{
An object whose class extends \code{DBIPreparedStatement}.

In the current \code{ROracle} implementation the \code{OraPreparedStatement}
class specializes (extends) \code{OraResultSet}, thus prepared
statment objects inherit all result set methods, e.g.,
\code{\link[DBI]{fetch}},
\code{\link[DBI]{dbClearResult}}, 
\code{\link[DBI]{dbGetStatement}},
\code{\link[DBI]{dbGetRowsAffected}}.
}

\section{Warning}{
Typically changes to the RDMBS made through prepared statements
are \emph{not} committed implicitly -- the user needs to issue
calls to \code{dbCommit(conn)}.

In the case of \code{ROracle}, committing the changes does not
close the prepared statement, but this behavior is an extension
to the ANSI/ISO SQL99 standard.
}

\note{These functions are \code{ROracle} extensions to the 
DBI as of version 0.1-7.}

\seealso{
 \code{\link[ROracle]{DBIPreparedStatement-class}}
 \code{\link{OraPreparedStatement-class}}
 \code{\link{OraResult-class}}
 \code{\link[DBI]{dbSendQuery}}
 \code{\link[DBI]{dbGetQuery}}
 \code{\link[DBI]{dbGetInfo}}
 \code{\link{summary}}
}

\examples{\dontrun{
  con <- dbConnect("Oracle", "user/password")

  ps <- dbPrepareStatement(con, 
           "INSERT into QUAKES (lat, long1, mag) VALUES (:1, :2, :4)",
           bind = c("numeric", "numeric", "numeric"))

  dbExecStatement(ps, data = quakes)
  dbExecStatement(ps, data = more.quakes)
  ...
  dbExecStatement(ps, data = yet.more.quakes)

  ## how many rows have we (tentatively) inserted?
  summary(ps)

  ## everything looks fine, so let's commit and wrap up
  dbCommit(con)
  dbClearResult(ps)
}
}
\keyword{database}
\keyword{interface}
\keyword{classes}
\keyword{methods}
% vim: syntax=tex
