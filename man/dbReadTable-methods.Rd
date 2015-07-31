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
  Convenience Functions for Manipulating DBMS Tables
}
\description{
  These functions mimic their R counterparts except that they generate
  code that gets remotely executed in a database engine:
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects}, and
  \code{names}.
}
\usage{
\S4method{dbReadTable}{OraConnection,character}(conn, name, schema = NULL, row.names = NULL, ...)
\S4method{dbWriteTable}{OraConnection,character,data.frame}(conn, name, value, row.names = FALSE, overwrite = FALSE,
             append = FALSE, ora.number = TRUE, schema = NULL, date = FALSE, ...)
\S4method{dbExistsTable}{OraConnection,character}(conn, name, schema = NULL, ...)
\S4method{dbRemoveTable}{OraConnection,character}(conn, name, purge = FALSE, schema = NULL, ...)
\S4method{dbListTables}{OraConnection}(conn, schema = NULL, all = FALSE, full = FALSE, ...)
\S4method{dbListFields}{OraConnection,character}(conn, name, schema = NULL, ...)
}
\arguments{
  \item{conn}{
    An \code{OraConnection} database connection object.
  }
  \item{name}{
    A case-sensitive character string specifying a table name.
  }
  \item{schema}{
    A case-sensitive character string specifying a schema name (or a
    vector of character strings for \code{dbListTables}).
  }
  \item{date}{
    A boolean flag to indicate whether to use date or DateTimep.
    By default, DateTime will be used instead of timestamp.
  }
  \item{row.names}{
    In the case of \code{dbReadTable}, this argument can be a string, an
    index or a logical vector specifying the column in the DBMS table to
    be used as \code{row.names} in the output data.frame (a \code{NULL}
    specifies that no column should be used as \code{row.names} in the
    output). The default is \code{NULL}.

    In the case of \code{dbWriteTable}, this argument should be a logical
    value specifying whether the \code{row.names} should be output to the
    output DBMS table; if \code{TRUE}, an extra column whose name is 
    \code{"row.names"} will be added to the output. The default is
    \code{FALSE}.
  }
  \item{value}{
    A \code{data.frame} containing the data to write to a table. (See
    Details section for supported column types.)
  }
  \item{overwrite}{
    A logical value specifying whether to overwrite an existing table
    or not. The default is \code{FALSE}.
  }
  \item{append}{
    A logical value specifying whether to append to an existing table
    in the DBMS. The default is \code{FALSE}.
  }
  \item{ora.number}{
    A logical value specifying whether to create a table with Oracle
    \code{NUMBER} or \code{BINARY_DOUBLE} columns while writing numeric
    data. Specify \code{TRUE} to create a table with Oracle \code{NUMBER} 
    values or specify \code{FALSE} to create a table with Oracle
    \code{BINARY_DOUBLE} values. The default value is \code{TRUE}.
    Specify \code{FALSE} if one or more of the numeric data values are
    \code{NaN}.
  }
  \item{purge}{
    A logical value specifying whether to add the \code{PURGE} option to the
    SQL \code{DROP TABLE} statement.
  }
  \item{all}{
    A logical value specifying whether to look at all schemas.
  }
  \item{full}{
    A logical value specifying whether to generate schema names. When argument
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

   The following attributes are used for mapping BLOB, CLOB, NCLOB, NCHAR, VARCHAR2,
   NVARCHAR2, CHAR, TIMESTAMP WITH TIME ZONE and TIMESTAMP WITH LOCAL TIME ZONE
   columns correctly in \code{dbWriteTable}:
   1) Attribute Name: \code{ora.type}
   This attribute indicates the type of the underlying column and can be
   "CLOB", "BLOB", "CHAR", "VARCHAR2", or "RAW". The user can specify
   TIMESTAMP, DATE, TIMESTAMP WITH TIME ZONE or any other column types
   supported by Oracle Database. ROacle does not parse the value; it is
   validated by the database. The user can provide one of the following
   values for \code{ora.type}: CLOB, BLOB, CHAR, TIMESTAMP WITH TIME
   ZONE, TIMESTAMP WITH LOCAL TIME ZONE and fractional_seconds_precision.
   2) Attribute Name: \code{ora.encoding}
   When UTF-8 is specified, the database uses NCLOB, NCHAR or NVARCHAR based on
   \code{ora.type}.
   3) Attribute Name: \code{ora.maxlength}
   One can specify the maximum length of CHAR, VARCHAR, NCHAR, NVARCHAR2, or
   RAW columns. For other data types, \code{ora.maxlength} does not
   apply and is ignored. The following default values are used for
   certain data types when \code{ora.maxlength} is not specified.
   CHAR                                       2000
   NCHAR                                      1000
   VARCHAR2                                   4000
   NVARCHAR2                                  2000
   RAW                                        2000
   4) Attribute Name: \code{ora.fractional_seconds_precision}
   One can specify the fractional part of the SECOND datetime field of
   TIMESTAMP, TIMESTAMP WITH TIME ZONE and TIMESTAMP WITH LOCAL TIME ZONE
   columns. It can be a number in the range 0 to 9. The default value is 6.

  \pkg{ROracle} methods such as \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch}, and \code{dbWriteTable} use the following mapping
  between \R and Oracle data types:
  \itemize{
    \item \code{logical} and \code{integer} map to Oracle \code{INTEGER}
    \item \code{numeric} maps to Oracle \code{NUMBER} if argument
    \code{ora.number} is \code{TRUE} or Oracle  \code{BINARY_DOUBLE} if
    \code{FALSE}
    \item \code{character} maps to Oracle \code{CLOB} if attribute 
    \code{ora.type} is \code{"CLOB"} or Oracle \code{NCLOB} if attribute
    \code{ora.type} is \code{"CLOB"} and \code{ora.encoding} is \code{"UTF-8"}
    or Oracle \code{CHAR(ora.maxlength)} if attribute \code{ora.type} is 
    \code{"CHAR"} or Oracle \code{NCHAR(ora.maxlength)} if attribute 
    \code{ora.type} is \code{"CHAR"} and \code{ora.encoding} is \code{"UTF-8"}
    or Oracle \code{NVARCHAR2(ora.maxlength)} if attribute \code{ora.encoding}
    is \code{"UTF-8"} or Oracle \code{VARCHAR2(ora.maxlength)}
    \item \code{Date} and \code{POSIXct} map to Oracle \code{DATE}
    \pkg{ROracle} - the ROracle package
    \R - the R application
    \item \code{POSIXct} maps to Oracle 
    \code{TIMESTAMP WITH TIME ZONE(ora.fractional_seconds_precision)} if 
    attribute \code{ora.type} is \code{"TIMESTAMP WITH TIME ZONE"} or Oracle 
    \code{TIMESTAMP WITH LOCAL TIME ZONE(ora.fractional_seconds_precision)} if
    attribute \code{ora.type} is \code{"TIMESTAMP WITH LOCAL TIME ZONE"} or
    Oracle \code{TIMESTAMP(ora.fractional_seconds_precision)} and if 
    \code{Date} is \code{FALSE} 
    \item \code{difftime} maps to Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} of \code{raw} vectors map to Oracle \code{BLOB} if 
    attribute \code{ora.type} is \code{"BLOB"} or Oracle 
    \code{RAW(ora.maxlength)}
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

   One can insert data into columns of the four data types listed above using a
   string with the correct format or POSIXct representation. String data is
   passed to the database directly and ROracle relies on databse to convert it
   to date time representation. ROracle driver converts the POSIXct
   representation to a string representation using the format
   "\%Y-\%m-\%d \%H:\%M:\%OS6" in a data frame that is used for DML operations.
   Data in this format corresponds to NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF" and is converted to SQLT_TIMESTAMP_LTZ to be
   bound to the Oracle database. An intermediate class "datetime" is created
   that represents character data to the ROracle driver internally.

   Columns having a date and time stamp data type are fetched by ROracle using
   the SQLT_TIMESTAMP data type. Columns having a time stamp with time zone or
   a time stamp with local time zone data types are fetched using
   SQLT_TIMESTAMP_LTZ data type. Columns of data type time stamp with local time
   zone undergo conversion to the session time zone that the R application runs
   in, therefore setting the time zone environment TZ in R will affect the data
   values in this column. ROracle driver maps the TZ environment variable to
   the session time zone and issues an alter DDL to set the session time zone
   when the connection is made to the database.

   To fetch data from columns with a timestamp with time zone or a timestamp
   with local time zone, the client and server must have the same time zone
   data file else an error will be reported.

   When these data types are selected from the database, they are converted to
   string representation using the NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF" that corresponds to "\%Y-\%m-\%d \%H:\%M:\%OS6"
   in R. An intermediate class "datetime" is created
   to represent this character data in ROracle driver. ROracle driver then
   converts it to POSIXct using the as.POSIXct() function. An R application
   sees the data in POSIXct form in the data frame.

   \preformatted{
R session time zone:
 R has the concept of a time zone in which the R engine operates. The time
 zone can be set to a string such as 'PST8PDT', 'America/Los_Angeles' and so on.
 These strings are self-explanatory and specify the time zone in which the
 session is operating.
 The R session time zone can be set in one of two ways:
 1. By entering the following on the Linux or Unix command line before starting
    R:
    setenv TZ = America/Los_Angeles on Linux/UNIX
    NOTE: Do not use this option on Windows as it does not allow one to
          set Oracle compatible timezone names for the environment variable TZ.
 2. By entering the following at the R prompt:
    Sys.setenv(TZ = "PST8PDT")

 We recommend using the option 2 as the R script works without any
 porting issues on Linux/Unix as well as Windows. Option 2 also allows you
 to specify Oracle compatible timezone names even on Windows.

 The R session time zone determines the time zone for all POSIXct time
 zone unqualified date-time types. It is also the time zone to which all
 qualified date-time types are converted when they are displayed by R.

 The following example demonstrates this.
 Sys.setenv(TZ = "PST8PDT")
 dt <- c(as.POSIXct("2010/3/13", tz = "PST8PDT"),
         as.POSIXct("2010/3/13 3:47:30.123456", tz = "PST8PDT"),
         as.POSIXct("2010/3/22", tz = "PST8PDT"),
         as.POSIXct("2010/3/22 7:02:30", tz = "PST8PDT"),
         as.POSIXct("2010/3/13"),
         as.POSIXct("2010/3/13 3:47:30.123456"),
         as.POSIXct("2010/3/22"),
         as.POSIXct("2010/3/22 7:02:30"))
 dt
 [1] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
 [3] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
 [5] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
 [7] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"

Note that the unqualified timestamps are also assumed to be in the R's
session time zone when they are displayed by R. Of course, R is also smart
enough to make the determination of whether the time falls into PST or PDT
based on when US Daylight savings begins, and displays PST or PDT
accordingly.

The following example makes this more obvious.
> Sys.setenv(TZ = "EST5EDT")
> dt <- c(as.POSIXct("2010/3/13", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13 3:47:30.123456", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22 7:02:30", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13"),
+         as.POSIXct("2010/3/13 3:47:30.123456"),
+         as.POSIXct("2010/3/22"),
+         as.POSIXct("2010/3/22 7:02:30"))

> dt
[1] "2010-03-13 03:00:00.000000 EST" "2010-03-13 06:47:30.123456 EST"
[3] "2010-03-22 03:00:00.000000 EDT" "2010-03-22 10:02:30.000000 EDT"
[5] "2010-03-13 00:00:00.000000 EST" "2010-03-13 03:47:30.123456 EST"
[7] "2010-03-22 00:00:00.000000 EDT" "2010-03-22 07:02:30.000000 EDT"

Note that all the time zone unqualified timestamps are assumed to be in
the session time zone. However, even the time zone qualified timestamps
are converted to session time zone and displayed. Note that all the
values are displayed by R in the R session's time zone (with the
timezone name also modified to EST or EDT to account for
daylight savings as applicable). Refer to Date-Time Classes at
http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html
and timezones at:
http://stat.ethz.ch/R-manual/R-devel/library/base/html/timezones.html
for details on how R handles dates and times and time zones)
Let's take an example where we use a longer time zone name
(often referred to as an 'Olson Name') as opposed to an abbreviation.
> Sys.setenv(TZ = "America/Los_Angeles")
> dt <- c(as.POSIXct("2010/3/13", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13 3:47:30.123456", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22", tz = "PST8PDT"),
+         as.POSIXct("2010/3/22 7:02:30", tz = "PST8PDT"),
+         as.POSIXct("2010/3/13"),
+         as.POSIXct("2010/3/13 3:47:30.123456"),
+         as.POSIXct("2010/3/22"),
+         as.POSIXct("2010/3/22 7:02:30"))
> dt
[1] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
[3] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"
[5] "2010-03-13 00:00:00.000000 PST" "2010-03-13 03:47:30.123456 PST"
[7] "2010-03-22 00:00:00.000000 PDT" "2010-03-22 07:02:30.000000 PDT"

Note that in such a case, R doesn't use the long name when the
values are displayed, but instead still displays the values using
the abbreviations "PST" and "PDT". This is significant because Oracle
doesn't necessarily like these abbreviations. For example, an Oracle
databse doesn't recognize "PDT" as a valid time zone. See "R Time zone
and Oracle session time zone" for details on valid time zones.
}


   The example below shows the effect of changing the time zone in R
   environment:
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
  \url{http://docs.oracle.com/cd/E11882_01/server.112/e10729/ch4datetime.htm}.
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

    # Example of POSIXct usage.
    # A table is created using:
    createTab <- "create table RORACLE_TEST(row_num number, id1 date,
                 id2 timestamp, id3 timestamp with time zone, 
                 id4 timestamp with local time zone )"

    dbGetQuery(con, createTab)
    # Insert statement.
    insStr <- "insert into RORACLE_TEST values(:1, :2, :3, :4, :5)";

    # Select statement.
    selStr <- "select * from RORACLE_TEST";

    # Insert time stamp without time values in POSIXct form.
    x <- 1; 
    y <- "2012-06-05";
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    # Insert date & times stamp with time values in POSIXct form.
    x <- 2;
    y <- "2012-01-05 07:15:02";
    y <- as.POSIXct(y);
    z <- "2012-01-05 07:15:03.123";
    z <- as.POSIXct(z);
    dbGetQuery(con, insStr, data.frame(x, y, z,  z, z));

    # Insert list of date objects in POSIXct form.
    x <- c(3, 4, 5, 6);
    y <- c('2012-01-05', '2011-01-05', '2013-01-05', '2020-01-05');
    y <- as.POSIXct(y);
    dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

    dbCommit (con)

    # Selecting data and displaying it.
    res <- dbGetQuery(con, selStr)
    res[,1]
    res[,2]
    res[,3]
    res[,4]
    res[,5]

    # insert data in Date format
    a<-as.Date("2014-01-01")
    dbWriteTable(con, 'TEMP', data.frame(a), date = TRUE)

    # using attribute to map NCHAR, CLOB, BLOB, NCLOB columns correctly in 
    # dbWriteTable
    str1 <- paste(letters, collapse="")
    lstr1 <- paste(rep(str1, 200), collapse="")
    raw.lst <- vector("list",1)
    lraw.lst <- vector("list",1)
    raw.lst[[1L]] <- charToRaw(str1)
    lraw.lst[[1L]] <- rep(charToRaw(str1), 200)
    a <- as.POSIXct("2014-01-01 14:12:09.0194733")
    b <- as.POSIXct("2014-01-01 14:12:09.01947")
    test.df <- data.frame(char=str1, nchar=str1, varchar=str1, clob=lstr1,
                      nclob=lstr1, stringsAsFactors=FALSE)
    test.df$raw.typ <- raw.lst
    test.df$blob <- lraw.lst
    test.df$char_max <- str1 
    test.df$raw_max.typ <- raw.lst
    test.df$nvchar <- str1
    test.df$nvchar_max <- str1
    test.df$date_tz <- a
    test.df$date_ltz <- b

    # adding attributes
    attr(test.df$clob, "ora.type") <- "CLOB"
    attr(test.df$blob, "ora.type") <- "BLOB"
    attr(test.df$nclob, "ora.type") <- "CLOB"
    attr(test.df$nclob, "ora.encoding") <- "UTF-8"
    attr(test.df$char_max, "ora.maxlength") <- 3000
    attr(test.df$raw_max.typ, "ora.maxlength") <- 1000
    attr(test.df$nvchar, "ora.encoding") <- "UTF-8"
    attr(test.df$nvchar_max, "ora.encoding") <- "UTF-8"
    attr(test.df$nvchar_max, "ora.maxlength") <- 1500
    attr(test.df$char, "ora.type") <- "CHAR"
    attr(test.df$date_tz, "ora.type") <- "timestamp with time zone"
    attr(test.df$date_ltz, "ora.type") <- "timestamp with local time zone"
    attr(test.df$nchar, "ora.type") <- "CHAR"
    attr(test.df$nchar, "ora.encoding") <- "UTF-8"
    attr(test.df$date_tz, "ora.fractional_seconds_precision") <- 9
R> # displaying the data frame
R> test.df
char                         nchar
1 abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz
varchar
1 abcdefghijklmnopqrstuvwxyz
clob
1 abcdefghijklmnopqrstuvwxyz...
nclob
1 abcdefghijklmnopqrstuvwxyz...
raw.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
blob
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a,...
char_max
1 abcdefghijklmnopqrstuvwxyz
raw_max.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
nvchar                       nvchar_max
1 abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz
date_tz                      date_ltz
1 2014-01-01 14:12:09.019473 2014-01-01 14:12:09.01946

    dbWriteTable(con, name="TEST_TAB", value=test.df)
    res <- dbReadTable(con, name="TEST_TAB")
R> res
char
1 abcdefghijklmnopqrstuvwxyz
nchar
1 abcdefghijklmnopqrstuvwxyz
varchar
1 abcdefghijklmnopqrstuvwxyz
clob
1 abcdefghijklmnopqrstuvwxyz...
nclob
1 abcdefghijklmnopqrstuvwxyz...
raw.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
blob
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a,...
char_max                                                                                           
1 abcdefghijklmnopqrstuvwxyz
raw_max.typ
1 61, 62, 63, 64, 65, 66, 67, 68, 69, 6a, 6b, 6c, 6d, 6e, 6f, 70, 71, 72, 73,
  74, 75, 76, 77, 78, 79, 7a
nvchar                       nvchar_max
1 abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz
date_tz                      date_ltz
1 2014-01-01 14:12:09.019473 2014-01-01 14:12:09.01946
  }
  \dontrun{
    df <- data.frame(A=c(0,1,NaN,4), B=c(NA, 2,3,NaN))
    con <- dbConnect(Oracle(), "scott", "tiger")
    dbWriteTable(con,"TEST", df, row.names = FALSE, ora.number=FALSE)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
