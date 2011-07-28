% $Id: oraParseConParams.Rd st_server_demukhin_r/1 2011/07/22 22:11:35 vsashika Exp $
\name{oraParseConParams}
\alias{oraParseConParams}
\title{Parse an Oracle connection string}
\description{
   Parse an oracle connections string of the form
   "user/password@dbname" to determine the three
   Oracle's connection parameters "username", "passwd"
   and "dbname".
}
\usage{
oraParseConParams(username="", password="", dbname=ifelse(usingR(), Sys.getenv("ORACLE_SID"), getenv("ORACLE_SID")))
}
\arguments{
  \item{username}{a character string of the form "username/passwd@dbname".
  Default is "".}
  \item{password}{an optional password.  If non-empty and there's also
  a password in the connection string \code{username}, this password
  overrides the one in \code{username}.
  Default is "".}
  \item{dbname}{an optional database name (Oracle SID).  If non-empty and
  there's also a database name in the connection string \code{username},
  this database name overrides the one in \code{username}.}
}
\details{
  Both \code{username} and \code{password} may be emtpy, in which case
  the \code{username} is set to "/"; this instructs Oracle to use the
  operating system user/password authentication (Oracle needs to be 
  set up to do this.)
}
\value{
  A 3-element character vector with the \code{username}, \code{passwd},
  and \code{dbname} suitable for a call to \code{dbConnect}.
}
\references{http://stat.bell-labs.com/RS-DBI}
\seealso{\code{\link[DBI]{dbConnect}}, \code{\link{Oracle}}}
\examples{\dontrun{
   conParams <- parse.OraConParams("user/pwd@dbname")
}
}
\keyword{database}
\keyword{interface}
% vim:syntax=tex
