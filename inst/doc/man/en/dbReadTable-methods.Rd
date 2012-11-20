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
    \item \code{Date} and \code{POSIXt} map to Oracle
    \code{TIMESTAMP WITH TIME ZONE}
    \item \code{difftime} maps to Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} of \code{raw} vectors map to Oracle \code{RAW(2000)}
    \item other \R types such as \code{factor} are converted to
    \code{character}
  }

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
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
