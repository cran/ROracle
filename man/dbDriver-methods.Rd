% $Id: dbDriver-methods.Rd,v 1.1 2003/11/03 22:41:41 dj Exp $
\name{dbDriver-methods}
\docType{methods}
\alias{dbDriver-methods}
\alias{dbUnloadDriver-methods}
\alias{dbDriver,character-method}
\alias{dbUnloadDriver,OraDriver-method}
\title{
  Oracle implementation of the Database Interface (DBI) classes 
  and drivers 
}
\description{
  Oracle driver initialization and closing
}
\section{Methods}{\describe{
\item{drvName}{
  character name of the driver to instantiate.
  }
\item{drv}{
  an object that inherits from \code{OraDriver} as created by
  \code{dbDriver}.
}
\item{...}{
  any other arguments are passed to the driver \code{drvName}.
  }
}
}
\references{
  See the Database Interface definition document
  \code{DBI.pdf} in the base directory of this package
  or
  \url{http://stat.bell-labs.com/RS-DBI}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbListTables}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{\dontrun{
# create an Oracle instance and set 10000 of rows per fetch.
m <- dbDriver("Oracle", fetch.default.records=10000)

con <- dbConnect(m, username="usr", password = "pwd",
           dbname = "iptraffic")
rs <- dbSubmitQuery(con, 
         "select * from HTTP_ACCESS where IP_ADDRESS = '127.0.0.1'")
df <- fetch(rs, n = 50)
df2 <- fetch(rs, n = -1)
dbClearResult(rs)

pcon <- dbConnect(p, "user", "password", "dbname")
dbListTables(pcon)
}
}
\keywords{methods}
\keyword{interface}
\keyword{database}
% vim: syntax=tex
