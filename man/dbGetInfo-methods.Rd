\name{dbGetInfo-methods}
\docType{methods}
\alias{dbGetInfo}
\alias{dbGetStatement}
\alias{dbGetRowCount}
\alias{dbGetRowsAffected}
\alias{dbColumnInfo}
\alias{dbHasCompleted}
\alias{dbGetInfo,OraDriver-method}
\alias{dbGetInfo,ExtDriver-method}
\alias{dbGetInfo,OraConnection-method}
\alias{dbGetInfo,OraResult-method}
\alias{dbGetStatement,OraResult-method}
\alias{dbGetRowCount,OraResult-method}
\alias{dbGetRowsAffected,OraResult-method}
\alias{dbColumnInfo,OraResult-method}
\alias{dbHasCompleted,OraResult-method}
\title{
  Database interface Metadata
}
\description{
   These methods are straight-forward implementations of the corresponding
   generic functions.
}
\usage{
\S4method{dbGetInfo}{OraDriver}(dbObj, ...)
\S4method{dbGetInfo}{ExtDriver}(dbObj, ...)
\S4method{dbGetInfo}{OraConnection}(dbObj, what, ...)
\S4method{dbGetInfo}{OraResult}(dbObj, what, ...)
\S4method{dbGetStatement}{OraResult}(res, ...)
\S4method{dbGetRowCount}{OraResult}(res, ...)
\S4method{dbGetRowsAffected}{OraResult}(res, ...)
\S4method{dbColumnInfo}{OraResult}(res, ...)
\S4method{dbHasCompleted}{OraResult}(res)
}
\arguments{
  \item{dbObj}{
    Any object that implements some functionality in the R
    interface to databases (a driver, a connection, or a result set).
  }
  \item{what}{A character string specifying an element of the output list.}
  \item{res}{An \code{OraResult}.}
  \item{\dots}{Currently unused.}
}
\details{
  Table, schema, and column names are case sensitive, for example, table
  names \code{ABC} and \code{abc} are not the same. All database schema
  object names should not include double quotes as they are enclosed in
  double quotes when the corresponding SQL statement is generated.

  The \pkg{ROracle} method \code{dbGetInfo} provides following details about
  the driver object:
  \itemize{
    \item {\$driverName} The name of the driver, "Oracle (OCI)"
    \item {\$driverVersion} The version of the ROracle driver used
    \item {\$clientVersion} The version of the Oracle Client library used
    \item {\$conTotal} The number of connections instantiated by the driver
    \item {\$conOpen} The number of connections open currently
    \item {\$interruptible} TRUE when a long-running query can be interrupted
    \item {\$unicode_as_utf8} TRUE when character data is to be fetched in UTF8
                              encoded format
    \item {\$ora_attributes} TRUE when each column in a result set data frame
                             has corresponding Oracle DBMS attributes
    \item {\$connections} Information about each connection currently open, see
                          \code{dbGetInfo} of connection object for details
  }
  The \pkg{ROracle} method \code{dbGetInfo} provides following the details
  about the connection object:
  \itemize{
    \item {\$username} The name of the user on this connection
    \item {\$dbname} The connect alias or the connect string used
    \item {\$serverVersion} The version of the Oracle Database server
    \item {\$serverType} The value "Oracle RDBMS"
    \item {\$resTotal} The number of result sets on this connection
    \item {\$resOpen} The number of result sets open on this connection
    \item {\$prefetch} TRUE when prefetch mechanism is used to fetch data
    \item {\$bulk_read} The number of rows to fetch at a time from DBMS
    \item {\$bulk_write} The number of rows to write at a time to DBMS
    \item {\$stmt_cache} TRUE when the statement cache is used
    \item {\$results} Information about each result set currently open, see
                      \code{dbGetInfo} of result set for details
  }
  The \pkg{ROracle} method \code{dbGetInfo} provides the following details
  about the result set object:
  \itemize{
    \item {\$statement} SQL statement used to produce the result set object
    \item {\$isSelect} TRUE when a select statement is specified
    \item {\$rowsAffected} The number of rows affected by DML statment
    \item {\$rowCount} The number of rows in result set currently
    \item {\$completed} TRUE if there are no more rows in the result set
    \item {\$prefetch} TRUE when the prefetch mechanism used to fetch data
    \item {\$bulk_read} The number of rows to fetch at a time from DBMS
    \item {\$bulk_write} The number of rows to write at a time to DBMS
    \item {\$fields} Information about each column in the the result set, see
                     \code{dbColumnInfo} for details
  }
  The \pkg{ROracle} method  \code{dbColumnInfo} provides following details
  about each column in the result set:
  \itemize{
    \item {\$name} The name of the column
    \item {\$Sclass} The R type of the object containing the data returned by
                     the Oracle RDBMS
    \item {\$type} The type of column as created in Oracle RDBMS
    \item {\$len} Length of VARCHAR, CHAR and RAW column type in Oracle RDBMS.
                  All other columns will have NA.
    \item {\$precision} The precision of number column
    \item {\$scale} The scale of number column
    \item {\$nullOK} TRUE when a NULL value can be present in the column
  }

   The example below shows the driver, connection, result set, and column
   information for a table containing:
 \preformatted{
   create table foo(
     a number(21),
     b number,
     c char(20),
     d varchar(300),
     e binary_double,
     f binary_float,
     g clob,
     h blob,
     i bfile,
     j date,
     m timestamp,
     n timestamp with time zone,
     o timestamp with local time zone,
     r interval day to second,
     s raw(234)
   );
 }

\preformatted{   library(ROracle)
Loading required package: DBI
> # instantiate ROracle driver object
> drv <- Oracle()
> con <- dbConnect(drv, "scott", "tiger")
> rs <- dbSendQuery(con, "select * from foo")
> dbGetInfo(drv)
$driverName
[1] "Oracle (OCI)"

$driverVersion
[1] "1.1-12"

$clientVersion
[1] "11.2.0.4.0"

$conTotal
[1] 1

$conOpen
[1] 1

$interruptible
[1] FALSE

$unicode_as_utf8
[1] TRUE

$ora_attributes
[1] TRUE

$connections
$connections[[1]]
User name:             scott 
Connect string:         
Server version:        11.2.0.4.0 
Server type:           Oracle RDBMS 
Results processed:     1 
OCI prefetch:          FALSE 
Bulk read:             1000 
Bulk write:            1000 
Statement cache size:  0 
Open results:          1 


> dbGetInfo(con)
$username
[1] "scott"

$dbname
[1] ""

$serverVersion
[1] "11.2.0.4.0"

$serverType
[1] "Oracle RDBMS"

$resTotal
[1] 1

$resOpen
[1] 1

$prefetch
[1] FALSE

$bulk_read
[1] 1000

$bulk_write
[1] 1000

$stmt_cache
[1] 0

$results
$results[[1]]
Statement:            select * from foo 
Rows affected:        0 
Row count:            0 
Select statement:     TRUE 
Statement completed:  FALSE 
OCI prefetch:         FALSE 
Bulk read:            1000 
Bulk write:           1000 


> dbGetInfo(rs)
$statement
[1] "select * from foo"

$isSelect
[1] TRUE

$rowsAffected
[1] 0

$rowCount
[1] 0

$completed
[1] FALSE

$prefetch
[1] FALSE

$bulk_read
[1] 1000

$bulk_write
[1] 1000

$fields
   name    Sclass                           type len precision scale nullOK
1     A   numeric                         NUMBER  NA        21     0   TRUE
2     B   numeric                         NUMBER  NA         0  -127   TRUE
3     C character                           CHAR  20         0     0   TRUE
4     D character                       VARCHAR2 300         0     0   TRUE
5     E   numeric                  BINARY_DOUBLE  NA         0     0   TRUE
6     F   numeric                   BINARY_FLOAT  NA         0     0   TRUE
7     G character                           CLOB  NA         0     0   TRUE
8     H       raw                           BLOB  NA         0     0   TRUE
9     I       raw                          BFILE  NA         0     0   TRUE
10    J   POSIXct                           DATE  NA         0     0   TRUE
11    M   POSIXct                      TIMESTAMP  NA         0     6   TRUE
12    N   POSIXct       TIMESTAMP WITH TIME ZONE  NA         0     6   TRUE
13    O   POSIXct TIMESTAMP WITH LOCAL TIME ZONE  NA         0     6   TRUE
14    R  difftime         INTERVAL DAY TO SECOND  NA         2     6   TRUE
15    S       raw                            RAW 234         0     0   TRUE

   }
}
\value{
  Information about driver, connection or a result set object.
}
\section{References}{
  For the Oracle Database documentaion see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbListTables}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")

    rs <- dbSendQuery(con, "select * from emp")

    # Get the SQL statement for the result set object rs
    dbGetStatement(rs)

    # Are there any more rows in result set?
    dbHasCompleted(rs)

    # Information about columns in result set rs object
    dbColumnInfo(rs)

    # DBIDriver info
    names(dbGetInfo(drv))

    # DBIConnection info
    names(dbGetInfo(con))

    # DBIResult info
    names(dbGetInfo(rs)) 
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
