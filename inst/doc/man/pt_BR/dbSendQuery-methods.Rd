\name{dbSendQuery-methods}
\docType{methods}
\alias{dbSendQuery-methods}
\alias{dbGetQuery-methods}
\alias{dbClearResult-methods}
\alias{dbGetException-methods}
\alias{dbSendQuery,OraConnection,character-method}
\alias{dbGetQuery,OraConnection,character-method}
\alias{dbClearResult,OraResult-method}
\alias{dbGetException,OraConnection-method}
\alias{dbGetException,OraResult-method}
\alias{execute}
\alias{execute-methods}
\alias{execute,OraResult-method}
\title{
Executar uma instrução em determinada conexão de banco de dados
}
\description{
Estes métodos são implementações simples das funções genéricas
   correspondentes, exceto pelo método \code{execute}, que é uma extensão DBI específica para ROracle.
}
\section{Methods}{\describe{
\item{conn}{
  an \code{OraConnection} object.
  }
\item{statement}{a character vector of length 1 with the SQL statement.}
\item{res}{an \code{OraResult} object.}
\item{data}{a data.frame specifying bind data}
\item{prefetch=FALSE}{
  a logical value indicating TRUE or FALSE. When set to TRUE, ROracle will use
  OCI prefetch buffers to retrieve additional data from the server thus saving
  memory required in RODBI/ROOCI by allocating a single row buffer to fetch the
  data from OCI. Using prefetch results in a fetch call for every row. By
  default, prefetch is FALSE and array fetch is used to retrive the data from
  server.
}
\item{bulk_read=25L}{
  an integer value indicating the number of rows to fetch at a time. Default
  is 25L. When prefetch option is select, memory is allocated for prefetch
  buffers and OCI will fetch those many rows at a time. When prefetch is not 
  used(default) memory is allocated in RODBI/ROOCI define buffers. Setting this
  to a large value will result in more memory allocated based on the number of
  columns in the select list and the types of columns. For a column of 
  character, define buffers are allocated using the maximum width times the
  NLS maximum width. Application should adjust this value based on the query
  result and a larger value will benefit queries that return a large result.
  Application can tune this value to its need.
}
\item{\dots }{additional parameters.}
}
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{\dontrun{
drv <- dbDriver("Oracle")
con <- dbConnect(drv, "scott", "tiger")
res <- dbSendQuery(con, "select * from emp where deptno = :1",
                   data = data.frame(deptno = 10))
data <- fetch(res, n = -1)
res2 <- dbSendQuery(con, "select * from emp where deptno = :1",
                    data1 = data.frame(deptno = 10), prefetch=TRUE,
                    bulk_read=2L)
data1 <- fetch(res2, n = -1)
res3 <- dbSendQuery(con, "select * from emp where deptno = :1",
                    data2 = data.frame(deptno = 10), bulk_read=10L)
data2 <- fetch(res3, n = -1)
}
}
\keyword{methods}
\keyword{interface}
\keyword{database}
