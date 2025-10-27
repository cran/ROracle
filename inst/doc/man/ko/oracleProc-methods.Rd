\name{oracleProc-methods}
\docType{methods}
\alias{oracleProc}
\alias{oracleProc,OraConnection,character-method}
\title{
저장된 PL/SQL 프로시저 또는 함수 실행
}
\description{
이 메소드는 해당하는 일반 함수를 간단히 구현한
   것입니다.
}
\usage{
\S4method{oracleProc}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
}
\arguments{
  \item{conn}{
\code{OraConnection} 객체입니다.
}
  \item{statement}{
SQL 문에서 길이가 1인 문자 벡터입니다.
}
  \item{data}{
바인드 데이터를 지정하는 data.frame입니다..
}
  \item{prefetch}{
ROracle이 서버에서 데이터를 검색하기 위해 사전 인출 버퍼를 사용하거나
    배열 인출을 사용할지 여부를 지정하는 논리 값입니다. \code{TRUE}의 경우 ROracle은 
    OCI 사전 인출 버퍼를 사용해서 서버에서 추가 데이터를 검색하므로 
    OCI에서 데이터를 인출하기 위해 단일 행 버퍼를 할당하여 RODBI/ROOCI에 
    필요한 메모리를 절약합니다. 사전 인출을 사용하면 모든 행에 대해 인출 호출이
    수행됩니다. \code{FALSE}(기본값)의 경우, ROracle은 배열 인출을 사용해서 
    데이터를 검색합니다.
}
  \item{bulk_read}{
한 번에 인출할 수 있는 행 수를 나타내는 정수 값입니다. 기본값은 
    1000L입니다. 사전 인출 옵션이 선택된 경우 사전 인출 버퍼에 메모리가 
    할당되고 OCI가 지정된 행 수를 한 번에 
    인출합니다. 사전 인출이 사용되지 않을 경우(기본값), 메모리는 
    RODBI/ROOCI 정의 버퍼에 할당됩니다. 이를 큰 값으로 설정하면 
    선택한 목록에 있는 열 수 및 열 유형을 기반으로 더 많은 
    메모리가 할당됩니다. 문자 유형 열의 경우 
    NLS 최대 너비의 몇 배에 달하는 최대 너비를 사용하여 정의 버퍼가 
    할당됩니다. 애플리케이션은 질의 결과를 기반으로 이 값을 조정해야 합니다.
    큰 값을 사용하면 큰 결과를 반환하는 질의 이점을 얻을 수 있습니다. 응용 
    프로그램은 필요에 따라 이 값을 조정할 수 있습니다.
}
  \item{bulk_write}{
한 번에 쓸 행 수를 나타내는 정수 값입니다. 기본값은
    1000L입니다. bulk_write 값이 지정된 경우 버퍼에 메모리가 
    할당되고 OCI가 해당 개수의 행을 한 번에 씁니다. bulk_write
    인수가 사용되지 않은 경우 바인드 버퍼에 대한 메모리를 할당하는 
    데 기본값이 사용됩니다. \code{bulk_write}을(를) 큰 값으로 설정하면
    삽입 목록에 있는 열 수 및 열 유형을 기반으로 더 많은 메모리가
    할당됩니다.
}
  \item{\dots}{
현재 사용되지 않습니다.
}
}
\value{
데이터베이스에서 인출한 레코드가 포함되어 있는 목록 또는 데이터
  프레임 객체입니다.
\\details{
  검색된 레코드 수는 \code{OUT} 인수에 저장된 PL/SQL 프로시저 또는
  함수의 \code{IN OUT} 및 \code{statement} 매개변수에 따라 
  다릅니다. 
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
                 IF NOT firs
t%ISOPEN
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
                 IF NOT firs
t%ISOPEN
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
                 IF NOT firs
t%ISOPEN THEN 
                 OPEN first for SELECT dname from dept; 
                 END IF; 
                 IF NOT secon
d%ISOPEN THEN 
                 OPEN second for SELECT * from dept; 
                 END IF; 
                 IF NOT thir
d%ISOPEN THEN 
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
