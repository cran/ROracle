\name{dbReadTable-methods}
\docType{methods}
\alias{dbReadTable}
\alias{dbWriteTable}
\alias{dbExistsTable}
\alias{dbRemoveTable}
\alias{dbListTables}
\alias{dbListFields}
\alias{dbReadTable,OraConnection,character-method}
\alias{dbWriteTable,OraConnection,character,data.frame-method}
\alias{dbExistsTable,OraConnection,character-method}
\alias{dbRemoveTable,OraConnection,character-method}
\alias{dbListTables,OraConnection-method}
\alias{dbListFields,OraConnection,character-method}
\title{
  Convenience functions for manipulating DBMS tables
}
\description{
  These functions mimic their R counterpart 
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects}, and
  \code{names}
  except that they generate code that gets remotely executed in a database
  engine.
}
\usage{
\S4method{dbReadTable}{OraConnection,character}(conn, name, schema = NULL, row.names = NULL, ...)
\S4method{dbWriteTable}{OraConnection,character,data.frame}(conn, name, value, row.names = FALSE, overwrite = FALSE,
             append = FALSE, ora.number = TRUE, ...)
\S4method{dbExistsTable}{OraConnection,character}(conn, name, schema = NULL, ...)
\S4method{dbRemoveTable}{OraConnection,character}(conn, name, purge = FALSE, ...)
\S4method{dbListTables}{OraConnection}(conn, schema = NULL, all = FALSE, full = FALSE, ...)
\S4method{dbListFields}{OraConnection,character}(conn, name, schema = NULL, ...)
}
\arguments{
  \item{conn}{
    an \code{OraConnection} database connection object.
  }
  \item{name}{
    a case sensitive character string specifying a table name.
  }
  \item{schema}{
    a case sensitive character string specifying a schema name (or a
    vector of character strings for \code{dbListTables}).
  }
  \item{row.names}{
    in the case of \code{dbReadTable}, this argument can be a string, an
    index or a logical vector specifying the column in the DBMS table to
    be used as \code{row.names} in the output data.frame (a \code{NULL}
    specifies that no column should be used as \code{row.names} in the
    output). The default is \code{NULL}.

    In the case of \code{dbWriteTable}, this argument should be a logical
    specifying whether the \code{row.names} should be output to the
    output DBMS table; if \code{TRUE}, an extra column whose name is 
    \code{"row.names"} will be added to the output. The default is
    \code{FALSE}.
  }
  \item{value}{
    a \code{data.frame} containing the data to write to a table. (See
    Details section for supported column types.)
  }
  \item{overwrite}{
    a logical specifying whether to overwrite an existing table
    or not. The default is \code{FALSE}.
  }
  \item{append}{
    a logical specifying whether to append to an existing table
    in the DBMS. The default is \code{FALSE}.
  }
  \item{ora.number}{
    a logical specifying whether to create a table with Oracle
    \code{NUMBER} or \code{BINARY_DOUBLE} columns while writing numeric
    data. The default value is \code{TRUE}.
  }
  \item{purge}{
    a logical specifying whether to add \code{PURGE} option to the
    Oracle \code{DROP TABLE} statement.
  }
  \item{all}{
    a logical specifying whether to look at all schemas.
  }
  \item{full}{
    a logical specifying whether to generate schema names. When argument
    \code{all} is \code{TRUE}, the output is a vector containing schema
    names followed by the table names. Using \code{matrix(..., ncol = 2)}
    on the output produces a matrix where each row corresponds to a
    table and the columns represent the schema names and table names
    respectively.
  }
  \item{\dots}{currently unused.}
}
\details{
  Table, schema, and column names are case sensitive, e.g., table
  names \code{ABC} and \code{abc} are not the same. All database schema
  object names should not include double quotes as they are enclosed in
  double quotes when the corresponding SQL statement is generated.

  \pkg{ROracle} methods such as \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch}, and \code{dbWriteTable} use the following mapping
  between \R and Oracle data types:
  \itemize{
    \item \code{logical} and \code{integer} map to Oracle \code{INTEGER}
    \item \code{numeric} maps to Oracle \code{NUMBER} if argument
    \code{ora.number} is \code{TRUE} or Oracle  \code{BINARY_DOUBLE} if
    \code{FALSE}
    \item \code{character} maps to Oracle \code{VARCHAR2(4000)}
    \item \code{Date} and \code{POSIXct} map to Oracle \code{DATE}
    \pkg{ROracle} - the ROracle package
    \R - the R application
    \code{POSIXct} - the POSIXct class
    \code{TIMESTAMP}
    \code{TIMESTAMP WITH TIME ZONE}
    \code{TIMESTAMP WITH LOCAL TIME ZONE}
    \item \code{difftime} maps to Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} of \code{raw} vectors map to Oracle \code{RAW(2000)}
    \item other \R types such as \code{factor} are converted to
    \code{character}
  }

   ROracle returns values from database columns that are of data type: date,
   time stamp, time stamp with time zone and time stamp with local time zone
   data types in R's POSIXct format. POSIXct refers to a
   time that is internally stored as the number of seconds since the start of
   1970 in UTC. Number of seconds are exchanged from R and ROracle driver in
   floating point double format. In POSIXct representation R uses the TZ
   environment variable or maps the OS time zone environment variable to its
   own, therefore the date will be displayed in this time zone format.

   One can insert data into columns of the 4 data types listed above using a
   string with the correct format or POSIXct representation. String data is
   passed to the databse directly and ROracle relies on databse to convert it
   to date time representation. POSIXct data will be converted to Oracle's
   internal DateTime descriptor by adding the beginning of 1970 UTC to the
   number of seconds obtained from R. Any POSIXct variables in insert
   statement are bound as SQLT_TIMESTAMP_TZ.

   When these data types are selected from Oracle they are converted to POSIXct
   format by subtracting the start of 1970 UTC. When ROracle client and
   database have different time zone version files and an application uses the
   time zone data types it is recommended that they be the same as the region
   may have changed its zone. ROracle will report an error in this situation as
   it can cause data corruption or loss of information when operating on these
   data types.

   Columns having date and time stamp data type are fetched by ROracle using
   the SQLT_TIMESTAMP data type. Columns having time stamp with time zone and
   time stamp with local time zone data types are fetched using
   SQLT_TIMESTAMP_TZ data type. Columns of datatype time zone with local time
   zone undergo conversion to the session time zone that the R application runs
   in therefore setting the time zone environment TZ in R will affect the data
   values in this column. ROracle driver does not map the TZ environment
   variable to session time zone and
   does not issue an alter DDL to set the session time zone. In order to
   fetch data from columns with timestamp with time zone and timestamp with
   local time zone the client and server must have the same time zone data
   file else an error will be reported.
   
   Example below shows the effect of changing time zone in R environment:
   \preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # Selecting data and displaying it
   res <- dbGetQuery(con, selStr)
   R>     res[,1]
   [1] 1 2 3 4 5 6
   R>     res[,2]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:02 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R>     res[,3]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:03 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R>     res[,4]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:03 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R>     res[,5]
   [1] "2012-06-05 00:00:00 PDT" "2012-01-05 07:15:03 PST"
       "2012-01-05 00:00:00 PST" "2011-01-05 00:00:00 PST"
   [5] "2013-01-05 00:00:00 PST" "2020-01-05 00:00:00 PST"
   R> Sys.setenv(TZ='EST5EDT')
   R>     res[,1]
   [1] 1 2 3 4 5 6
   R>     res[,2]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:02 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"
   R>     res[,3]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:03 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"
   R>     res[,4]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:03 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"
   R>     res[,5]
   [1] "2012-06-05 03:00:00 EDT" "2012-01-05 10:15:03 EST"
       "2012-01-05 03:00:00 EST" "2011-01-05 03:00:00 EST"
   [5] "2013-01-05 03:00:00 EST" "2020-01-05 03:00:00 EST"}


  Also \code{dbWriteTable} always auto commits a current transaction as
  well as the data it inserts, i.e. it acts as a DDL statement even if
  appends rows to an already existing table.
}
\value{
  A \code{data.frame} in the case of \code{dbReadTable};
  a \code{vector} in the case of \code{dbListTables} and
  \code{dbListFields};
  a \code{logical} in the case of \code{dbExistsTable} indicating
  whether the table exists;
  otherwise \code{TRUE} when the operation was successful or an
  exception.
}
\section{References}{
  For the Oracle Database documentation see 
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
  For Datetime Data Types and Time Zone Support in Oracle see
  \url{http://docs.oracle.com/cd/E14072_01/server.112/e10729/ch4datetime.htm}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}}.
}
\examples{
  \dontrun{
    con <- dbConnect(Oracle(), "scott", "tiger")
    if (dbExistsTable(con, "FOO", "SCOTT"))
      dbRemoveTable(con, "FOO")

    foo <- dbReadTable(con, "EMP")
    row.names(foo) <- foo$EMPNO
    foo <- foo[,-1]

    dbWriteTable(con, "FOO", foo, row.names = TRUE)
    dbWriteTable(con, "FOO", foo, row.names = TRUE, overwrite = TRUE)
    dbReadTable(con, "FOO", row.names = 1)

    dbGetQuery(con, "delete from foo")
    dbWriteTable(con, "FOO", foo, row.names = TRUE, append = TRUE)
    dbReadTable(con, "FOO", row.names = 1)
    dbRemoveTable(con, "FOO")

    dbListTables(con)
    dbListFields(con, "EMP")

    if (dbExistsTable(con, "RORACLE_TEST", "SCOTT"))
      dbRemoveTable(con, "RORACLE_TEST")

    # example of POSIXct usage
    # A table is created using:
    createTab <- "create table RORACLE_TEST(row_num number, id1 date,
                 id2 timestamp, id3 timestamp with time zone, 
                 id4 timestamp with local time zone )"

    dbGetQuery(con, createTab)
    # Insert statement
    insStr <- "insert into RORACLE_TEST values(:1, :2, :3, :4, :5)";

    # Select statement
    selStr <- "select * from RORACLE_TEST";

    # Insert time stamp without time values in POSIXct form
    x <- 1; 
    y <- "2012-06-05";
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    # Insert date & times tamp with time values in POSIXct form
    x <- 2;
    y <- "2012-01-05 07:15:02";
    y <- as.POSIXct(y);
    z <- "2012-01-05 07:15:03.123";
    z <- as.POSIXct(z);
    dbGetQuery(con, insStr, data.frame(x, y, z,  z, z));

    # Insert list of date objects in POSIXct form
    x <- c(3, 4, 5, 6);
    y <- c('2012-01-05', '2011-01-05', '2013-01-05', '2020-01-05');
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    dbCommit (con)

    # Selecting data and displaying it
    res <- dbGetQuery(con, selStr)
    res[,1]
    res[,2]
    res[,3]
    res[,4]
    res[,5]
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
