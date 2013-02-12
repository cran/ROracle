\name{dbReadTable-methods}
\docType{methods}
\alias{dbReadTable-methods}
\alias{dbWriteTable-methods}
\alias{dbExistsTable-methods}
\alias{dbRemoveTable-methods}
\alias{dbListTables-methods}
\alias{dbListFields-methods}
\alias{dbReadTable,OraConnection,character-method}
\alias{dbWriteTable,OraConnection,character,data.frame-method}
\alias{dbExistsTable,OraConnection,character-method}
\alias{dbRemoveTable,OraConnection,character-method}
\alias{dbListTables,OraConnection-method}
\alias{dbListFields,OraConnection,character-method}
\title{
DBMS 테이블 조작을 위한 편리한 함수
}
\description{
이 함수는 상응하는 R 함수를 모방한 것입니다.
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects}, 
  \code{names}.
  단, 데이터베이스 엔진에서 원격으로 실행되는 코드를 생성합니다.
}
\section{Methods}{\describe{
\item{conn}{
  an \code{OraConnection} database connection object.
  }
\item{name}{
  a case sensitive character string specifying a table name.
  }
\item{schema}{
  a case sensitive character string specifying a schema name (or a
  vector of character strings for dbListTables).
  }
\item{all}{
  a boolean specifying whether to look at all schemas.
  }
\item{full}{
  a boolean specifying whether to generate schema names. When 'all' is
  set to TRUE the output is a vector containing schema names followed by
  the table names. One can do matrix(..., ncol = 2) on the output. This
  way each row of the matrix will correspond to a table with the first
  column being a schema name and the second - the tabel name.
  }
\item{value}{
  a data.frame (or coercible to data.frame). Vectors of types
  \code{logical}, \code{integer}, \code{numeric}, and \code{character}
  are supported natively; all other vectors must be coercible to
  \code{character}. \code{logical} and \code{integer} vectors map to
  INTEGER columns, \code{numeric} to NUMBER (or BINARY_DOUBLE if
  \code{ora.number} is set to \code{FALSE}), and \code{character} to
  VARCHAR2(4000).
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
\item{overwrite}{
  a logical specifying whether to overwrite an existing table
  or not.  Its default is \code{FALSE}.
  }
\item{append}{
  a logical specifying whether to append to an existing table
  in the DBMS.  Its default is \code{FALSE}.
  }
\item{ora.number}{
  a logical specifying whether to create a table with NUMBER or
  BINARY_DOUBLE columns while writing numeric data. The default value
  is \code{TRUE} - create NUMBER columns.
  }
\item{purge}{
  a logical specifying whether to add PURGE option to the DROP TABLE
  statement.
  }
\item{\dots }{any optional arguments.}
}
}

\value{
\code{dbReadTable}의 경우 data.frame, \code{dbListTables} 및 \code{dbListFields}의 경우 벡터,
   \code{dbExistsTable}의 경우 테이블이 존재하는지 여부를 나타내는
   논리 값입니다. 그렇지 않으면 작업이 성공 또는
   예외일 때 TRUE입니다.
}
\note{
   Note that the data.frame returned by \code{dbReadTable} only has
   primitive data, e.g., it does not coerce character data to
   factors. This is similar to the output produced by \code{fetch} and
   \code{dbGetQuery}.

   Table, schema, and column names are case sensitive, e.g., table
   names \code{ABC} and \code{abc} are not the same. All database schema
   object names should not include double quotes as they are enclosed in
   double quotes when the corresponding SQL statement is generated.

   \code{dbWriteTable} always auto commits a current transaction as well
   as the data it inserts, i.e. it acts as a DDL statement even if
   appends rows to an already existing table.
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
\examples{\dontrun{
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
