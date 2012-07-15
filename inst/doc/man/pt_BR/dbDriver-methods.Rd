\name{dbDriver-methods}
\docType{methods}
\alias{dbDriver-methods}
\alias{dbUnloadDriver-methods}
\alias{dbDriver,character-method}
\alias{dbUnloadDriver,OraDriver-method}
\title{
A implementação da Oracle dos drivers e classes DBI (Database
  Interface)
}
\description{
Inicialização e fechamento de driver Oracle
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
# create an Oracle instance
drv <- dbDriver("Oracle")

con <- dbConnect(drv, "scott", "tiger")
res <- dbSendQuery(con, "select * from emp")
fetch(res, n = 5)
fetch(res)
dbClearResult(res)
}
}
\keyword{methods}
\keyword{interface}
\keyword{database}
