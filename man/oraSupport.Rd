\name{oraSupport}
\alias{oraInitDriver}            % driver-related function
\alias{oraDriverInfo}
\alias{oraDescribeDriver}
\alias{oraCloseDriver}           % connection-related 
\alias{oraNewConnection}
\alias{oraCloneConnection}
\alias{oraConnectionInfo}
\alias{oraDescribeConnection}
\alias{oraCloseConnection}
\alias{oraExecStatement}         % result-related
\alias{oraFetch}
\alias{oraQuickSQL}
\alias{oraResultInfo}
\alias{oraDescribeResult}
\alias{oraCloseResult}
\alias{oraReadTable}
\alias{oraWriteTable}            % convenience functions
\alias{oraTableFields}
\alias{oraDataType}
\alias{.OraPkgName}              % constants
\alias{.OraPkgVersion}
\alias{.OraPkgRCS}
\alias{.Oracle.NA.string}
\alias{.OraSQLKeywords}
\alias{.conflicts.OK}
%\non_function{}
\title{Support Functions}
\description{
   These functions are the workhorse behind the ROracle package, but
   users need not invoke these directly.
}
\usage{
   ## OraDriver-related
   oraInitDriver(max.con=10, fetch.default.rec = 500, force.reload=FALSE)
   oraDriverInfo(obj, what)
   oraDescribeDriver(obj, verbose = FALSE, ...)
   oraCloseDriver(drv, ...)

   ## OraConnection-related
   oraNewConnection(drv, username="", password="", 
      dbname = if(usingR()) Sys.getenv("ORACLE_SID") else getenv("ORACLE_SID"),
      max.results = 1)
   oraCloneConnection(drv, ...)
   oraConnectionInfo(obj, what)
   oraDescribeConnection(obj, verbose = FALSE, ...)
   oraCloseConnection(con, ..., force = FALSE)

   ## OraResult-related
   oraExecStatement(con, statement)
   oraFetch(res, n=0, ...)
   oraQuickSQL(con, statement, ...)
   oraResultInfo(obj, what)
   oraDescribeResult(obj, verbose = FALSE, ...)
   oraCloseResult(res, ...)

   ## data mappings and convenience functions
   oraDataType(obj, ...)
   oraReadTable(con, name, row.names = "row.names", check.names = TRUE, ...)
   oraWriteTable(con, name, value, field.types, row.names = TRUE, 
      overwrite=FALSE, append=FALSE, ...)
   oraTableFields(con, name, ...)
}
\arguments{
\item{max.con}{
   positive integer specifying maximum number of open connections.
   The current default of 10 is hardcoded in the C code.
}
\item{fetch.default.rec}{
   default number of rows to fetch (move to R/Splus).  This default is
   used in \code{oraFetch}. 
   The default is 500.
}
\item{force.reload}{
   logical indicating whether to re-initialize the driver.  This may be
   useful if you want to change the defaults (e.g., \code{fetch.default.rec}).
   Note that the driver is a singleton (subsequent inits just returned the
   previously initialized driver, thus this argument).
}
\item{obj}{
   any of the Oracle DBI objects (e.g., \code{OraConnection},
   \code{OraResult}).
}
\item{what}{
   character vector of metadata to extract, e.g., "version", "statement",
   "isSelect".
}
\item{verbose}{
   logical controlling how much information to display.
   Defaults to \code{FALSE}.
}
\item{drv}{
   an \code{OraDriver} object as produced by \code{oraInit}.
}
\item{con}{
   an \code{OraConnection} object as produced by \code{oraNewConnection}
   and \code{oraCloneConnection}.
}
\item{res}{
   an \code{OraResult} object as produced by by \code{oraExecStatement}.
}
\item{username}{
   a character string with the Oracle's user name.  It can also be any of 
   the Oracle-recognize login strings, e.g., "user/password" or 
   "user/password@dbname".
}
\item{password}{
   character string with the Oracle's password.
}
\item{dbname}{
   character string with the Oracle System Identification (SID).
}
\item{max.results}{
   positive integer indicating the maximum number of results that
   Oracle connections will hold open.  The current default of 1 
   is hardcoded in the C code.
}
\item{force}{
   logical indicating whether to close a connection that has open
   result sets.  The default is \code{FALSE}.
}
\item{statement}{
   character string holding one (and only one) SQL statement.
}
\item{n}{
   number of rows to fetch from the given result set. A value of -1
   indicates to retrieve all the rows.  The default of 0 specifies
   to extract whatever the \code{fetch.default.rec} was specified
   during driver initialization \code{oraInit}.
}
\item{name}{
   character vector of names (table names, fields, keywords).
}
\item{value}{
   a data.frame.
}
\item{field.types}{
   a list specifying the mapping from R/Splus fields in the data.frame
   \code{value} to SQL data types.  The default is
   \code{sapply(value,SQLDataType)}, see \code{OraSQLType}.
}
\item{row.names}{
   a logical specifying whether to prepend the \code{value} data.frame 
   row names or not.  The default is \code{TRUE}.
}
\item{check.names}{
   a logical specifying whether to convert DBMS field names into
   legal S names. Default is \code{TRUE}.
}
\item{overwrite}{
   logical indicating whether to replace the table \code{name} with
   the contents of the data.frame \code{value}.
   The defauls is \code{FALSE}.
}
\item{append}{
   logical indicating whether to append \code{value} to the existing
   table \code{name}.
}
\item{\dots}{
   placeholder for future use.
}
}
\value{
   \code{oraInitDriver} returns an \code{OraDriver} object.

   \code{oraDriverInfo} returns a list of name-value metadata pairs.

   \code{oraDescribeDriver} returns \code{NULL} (displays the object's 
   metadata).

   \code{oraCloseDriver} returns a logical indicating whether the 
   operation succeeded or not.

   \code{oraNewConnection} returns an \code{OraConnection} object.

   \code{oraCloneConnection} returns an \code{OraConnection} object.

   \code{oraConnectionInfo}returns a list of name-value metadata pairs.

   \code{oraDescribeConnection} returns \code{NULL} (displays the 
   object's metadata).

   \code{oraCloseConnection} returns a logical indicating whether the 
   operation succeeded or not.

   \code{oraExecStatement} returns an \code{OraResult} object.

   \code{oraFetch} returns a data.frame.

   \code{oraQuickSQL} returns either a data.frame if the \code{statement} is
   a \code{select}-like or NULL otherwise.

   \code{oraDescribeResult} returns \code{NULL} (displays the object's 
   metadata).
   
   \code{oraCloseResult} returns a logical indicating whether the 
   operation succeeded or not.
   
   \code{oraReadTable}  returns a data.frame with the contents of the
   DBMS table.
   
   \code{oraWriteTable}  returns a logical indicating whether the 
   operation succeeded or not.
   
   \code{oraTableFields} returns a character vector with the 
   table \code{name} field names.
   
   \code{oraDataType} retuns a character string with the closest
   
   \code{oraResultInfo} returns a list of name-value metadata pairs.
}
\section{Constants}{
\code{.OraPkgName} (currently \code{"ROracle"}),
\code{.OraPkgVersion} (the R package version),
\code{.OraPkgRCS} (the RCS revision),
\code{.Oracle.NA.string} (character that Oracle uses to 
denote \code{NULL} on input),
\code{.OraSQLKeywords} (a lot!)
\code{.conflicts.OK}.
%\non_function{}
}
\keyword{datasets}
\keyword{interface}
\keyword{database}
%\keyword{internal}
% vim:syntax=tex
