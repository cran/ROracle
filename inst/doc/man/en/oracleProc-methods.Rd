\name{oracleProc-methods}
\docType{methods}
\alias{oracleProc}
\alias{oracleProc,OraConnection,character-method}
\title{
   Execute a Stored PL/SQL Procedure or Function
}
\description{
   This method is a straight-forward implementation of the corresponding
   generic function.
}
\usage{
\S4method{oracleProc}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
}
\arguments{
  \item{conn}{An \code{OraConnection} object.}
  \item{statement}{A character vector of length 1 with the SQL statement.}
  \item{data}{A data.frame specifying bind data.}
  \item{prefetch}{
    A logical value that specifies whether ROracle uses prefetch buffers or an
    array fetch to retrieve data from the server. If \code{TRUE}, then ROracle
    uses OCI prefetch buffers to retrieve additional data from the server thus
    saving the memory required in RODBI/ROOCI by allocating a single row buffer
    to fetch the data from OCI. Using prefetch results in a fetch call for every
    row. If \code{FALSE} (the default), then ROracle uses an array fetch to
    retrieve the data.
  }
  \item{bulk_read}{
    An integer value indicating the number of rows to fetch at a time. The
    default value is 1000L. When the prefetch option is selected, memory is
    allocated for prefetch buffers and OCI fetches the specified number of rows
    at a time. When prefetch is not used, which is the default, memory is
    allocated in RODBI/ROOCI define buffers. Setting this to a large value
    results in more memory being allocated based on the number of columns in
    the select list and the types of columns. For a column of type character,
    define buffers are allocated using the maximum width times the NLS maximum
    width. An application should adjust this value based on the query result.
    A larger value benefits queries that return a large result. The
    application can tune this value as needed.
  }
  \item{bulk_write}{
    An integer value indicating the number of rows to write at a time. The
    default value is 1000L. When a bulk_write value is specified, memory is
    allocated for buffers and OCI writes that many rows at a time. If the
    bulk_write argument is not used, then the default value is used to
    allocate memory for the bind buffers. Setting \code{bulk_write} to a large
    value results in more memory being allocated based on the number of columns
    in the insert list and the types of columns.
  }
  \item{\dots}{Currently unused.}
}
\value{
  A list or data frame object that contains the records fetched from the
  database.
\details{
  The number of records retrieved is based on the \code{OUT} and \code{IN OUT}
  parameters of the stored PL/SQL procedure or function in argument 
  \code{statement}. 
}
}
\section{References}{
  For Oracle Database documentation see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{dbClearResult}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")

    # creating stored procedure test1 (first IN number, second OUT number)
    dbGetQuery(con, 'create or replace procedure test1
                 (first IN number, second OUT number)
                 is
                 BEGIN
                 select deptno+1 into second from dept where deptno = first;
                 END;')

    # creating data frame for PL/SQL stored procedure call with appropriate 
    # attributes
    test.df <- data.frame(input = 10, output =2L)
    attr(test.df$input, "ora.parameter_mode") <- "IN"
    attr(test.df$output, "ora.parameter_mode") <- "OUT"
    attr(test.df$input, "ora.parameter_name") <- ":input"
    attr(test.df$output, "ora.parameter_name") <- ":output"

    # calling stored procedure test1(first IN number, second OUT number)
    res1 <- oracleProc(con, ' BEGIN test1(:input, :output);
                 END;', test.df)

    # creating stored function test2(first IN number) return second OUT number
    dbGetQuery(con, 'create or replace function test2
                 (first IN number)
                 RETURN number
                 is
                 second number;
                 BEGIN
                 select deptno+1 into second from dept where deptno = first;
                 RETURN second;
                 END;')
 
    # creating data frame for PL/SQL stored function call with appropriate 
    # attributes
    test.df <- data.frame(y = 19, x = 40)
    attr(test.df$x, "ora.parameter_mode") <- "IN"
    attr(test.df$y, "ora.parameter_mode") <- "IN OUT"
    attr(test.df$y, "ora.parameter_name") <- ":output"

    # calling stored function test2(first IN number) return second OUT number
    res2 <- oracleProc(con, 'BEGIN :output := test2(:2); END;', test.df)

    # creating stored procedure test3(first OUT SYS_REFCURSOR)
    dbGetQuery(con, 'create or replace procedure test3
                 (first OUT SYS_REFCURSOR)
                 is
                 BEGIN
                 IF NOT first%ISOPEN
                 THEN
                 OPEN first for SELECT * from dept;
                 END IF;
                 END;')

    # data frame for PL/SQL stored procedure call with cursor as OUT parameter
    # single cursor scenario
    test <- data.frame(x = NA)
    attr(test$x,  "ora.parameter_mode") <- "OUT"
    attr(test$x,  "ora.parameter_name") <- "cur"
    attr(test$x,  "ora.type") <- "cursor"

    # calling stored procedure test3(first OUT SYS_REFCURSOR)
    res3 <- oracleProc(con, ' BEGIN test3(:cur); END;', test)

    # creating stored function test4 return first OUT SYS_REFCURSOR
    dbGetQuery(con, 'create or replace function test4
                 RETURN SYS_REFCURSOR
                 is
                 first SYS_REFCURSOR;
                 BEGIN
                 IF NOT first%ISOPEN
                 THEN
                 OPEN first for SELECT dname from dept ;
                 END IF;
                 RETURN first;
                 END;')

    # data frame for PL/SQL stored function call with cursor as OUT parameter
    test <- data.frame(x = NA, y = 10)
    attr(test$x,  "ora.parameter_mode") <- "OUT"
    attr(test$x,  "ora.parameter_name") <- "cur"
    attr(test$x,  "ora.type") <- "cursor"

    # calling stored function test4 return first OUT SYS_REFCURSOR
    res4 <- oracleProc(con, ' BEGIN :cur := test4(:2); END;', test)

    # multiple cursors case scenario
    # creating stored procedure test5 (first OUT SYS_REFCURSOR,
    # second OUT SYS_REFCURSOR, third OUT SYS_REFCURSOR)
    dbGetQuery(con, 'create or replace procedure test5
                 (first OUT SYS_REFCURSOR, second OUT SYS_REFCURSOR, third OUT SYS_REFCURSOR) is 
                 BEGIN 
                 IF NOT first%ISOPEN THEN 
                 OPEN first for SELECT dname from dept; 
                 END IF; 
                 IF NOT second%ISOPEN THEN 
                 OPEN second for SELECT * from dept; 
                 END IF; 
                 IF NOT third%ISOPEN THEN 
                 OPEN third for SELECT deptno, dname, loc from dept where deptno = 10; 
                 END IF;  
                 END;')

    # data frame for 3 cursors
    test <- data.frame(x = NA, y = NA, z = NA)
    attr(test$x,  "ora.parameter_mode") <- "OUT"
    attr(test$x,  "ora.parameter_name") <- "cur1"
    attr(test$x,  "ora.type") <- "cursor"
    attr(test$y,  "ora.parameter_mode") <- "OUT"
    attr(test$y,  "ora.parameter_name") <- "cur2"
    attr(test$y,  "ora.type") <- "cursor"
    attr(test$z,  "ora.parameter_mode") <- "OUT"
    attr(test$z,  "ora.parameter_name") <- "cur3"
    attr(test$z,  "ora.type") <- "cursor"

    # calling stored procedure test5 (first OUT SYS_REFCURSOR, 
    # second OUT SYS_REFCURSOR, third OUT SYS_REFCURSOR)
    res5 <- oracleProc(con, ' BEGIN test5(:cur1, :cur2, :cur3);  END;', test)
  } 
}
\keyword{methods}
\keyword{database}
\keyword{interface}
