\name{dbConnect-methods}
\docType{methods}
\alias{dbDisconnect-methods}
\alias{dbConnect-methods}
\alias{dbDisconnect,OraConnection-method}
\alias{dbConnect,OraDriver-method}
\alias{dbConnect,OraConnection-method}
\title{
Oracle DBMS에 대한 접속 객체 생성
}
\description{
이 메소드는 해당하는 일반 함수를 간단히 구현한
   것입니다.
}
\section{Methods}{\describe{
\item{drv}{
  an object of class \code{OraDriver}.
}
\item{conn}{
  an \code{OraConnection} object as produced by \code{dbConnect}.
}
\item{username}{
  a character string specifying a user name.
}
\item{password}{
  a character string specifying a password.
}
\item{dbname}{
  a character string specifying a connect identifier (for more
  informations refer to chapter 8 (Configuring Naming Methods) of Oracle
  Database Net Services Administrator's Guide). This is the same as part
  of the SQL*Plus connect string that follows the '@' sign. 
  If you are using Oracle Wallet to store username and password, 
  then this string should be the connect string used to create the 
  wallet mapping (for more information refer to the chapter 3 
  (Configuring Clients to Use the External Password Store)
  of Oracle Database Ssecurity Guide).
}
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
\item{\dots }{
  any optional arguments.
}
}
}
\section{Side Effects}{
  A connection between R and an Oracle  server is established.
}
\references{
For the Oracle Database documentaion see
\url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
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
## create an Oracle instance and create one connection.
drv <- dbDriver("Oracle")

## use username/password authentication
con <- dbConnect(drv, username = "scott", password = "tiger")

## run an SQL statement by creating first a resultSet object
rs <- dbSendQuery(con, "select * from emp where deptno = 10")

## we now fetch records from the resultSet into a data.frame
data <- fetch(rs)       ## extract all rows
dim(data)
}
\dontrun{
## create an Oracle instance and create one connection.
drv <- dbDriver("Oracle")

## use Oracle wallet authentication
con <- dbConnect(drv, username ="", password="", 
                 dbname = "<wallet_connect_string>")

## run an SQL statement by creating first a resultSet object
rs <- dbSendQuery(con, "select * from emp where deptno = 10")

## we now fetch records from the resultSet into a data.frame
data <- fetch(rs)       ## extract all rows
dim(data)
}
}
\keyword{methods}
\keyword{interface}
\keyword{database}
