% $Id: dbConnect-methods.Rd 155 2006-02-08 19:19:08Z dj $
\name{dbConnect-methods}
\docType{methods}
\alias{dbDisconnect-methods}
\alias{dbConnect-methods}
\alias{dbDisconnect,OraConnection-method}
\alias{dbConnect,OraDriver-method}
\alias{dbConnect,OraConnection-method}
\alias{dbConnect,character-method}
\title{
  Create a connection object to an Oracle DBMS
}
\description{
   These methods are straight-forward implementations of the corresponding
   generic functions.
}
\section{Methods}{\describe{
\item{drv}{
  an object of class \code{OraDriver}, or
  the character string "Oracle" or an \code{OraConnection}.
  }
\item{conn}{
  an \code{OraConnection} object as produced by \code{dbConnect}.
  }
\item{username}{string of the Oracle login name}.
\item{password}{string with the Oracle password}.
\item{dbname}{string with the Oracle SID, System Identification 
      (database name). The default takes this fromt the 
      environment variable \code{ORACLE\_SID}}.
\item{\dots }{
  Must specify user, password and optionally dbname.  Also
  you may specify an Oracle connection string, e.g., 
  "user/password@SID".
  }
}
}
\section{Side Effects}{
  A connection between R/S-Plus and an Oracle  server is 
  established.   The current implementation supports up to
  10 simultaneous connections.
}
\references{
  See the Database Interface definition document
  \code{DBI.pdf} in the base directory of this package
  or \url{http://stat.bell-labs.com/RS-DBI}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{\dontrun{
# create an Oracle instance and create one connection.
drv <- dbDriver("Oracle")

# open the connection using user, passsword, etc., as
con <- dbConnect(drv, "user/password@dbname")

# Run an SQL statement by creating first a resultSet object
rs <- dbSendQuery(con, statement = paste(
                      "SELECT w.laser_id, w.wavelength, p.cut_off",
                      "FROM WL w, PURGE P", 
                      "WHERE w.laser_id = p.laser_id", 
                      "SORT BY w.laser_id")
# we now fetch records from the resultSet into a data.frame
data <- fetch(rs, n = -1)   # extract all rows
dim(data)
}
}
\keyword{methods}
\keyword{interface}
\keyword{database}
% vim: syntax=tex
