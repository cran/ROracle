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
DBMS 테이블 조작을 위한 편리한 함수
}
\description{
이 함수는 상응하는 R 함수를 모방한 것입니다. 
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} 및
  \code{names}.
  단, 데이터베이스 엔진에서 원격으로 실행되는 코드를
  생성합니다.
}
\usage{
\S4method{dbReadTable}{OraConnection,character}(conn, name, schema = NULL, row.names = NULL, ...)
\S4method{dbWriteTable}{OraConnection,character,data.frame}(conn, name, value, row.names = FALSE, overwrite = FALSE,
             append = FALSE, ora.number = TRUE, schema = NULL, ...)
\S4method{dbExistsTable}{OraConnection,character}(conn, name, schema = NULL, ...)
\S4method{dbRemoveTable}{OraConnection,character}(conn, name, purge = FALSE, schema = NULL, ...)
\S4method{dbListTables}{OraConnection}(conn, schema = NULL, all = FALSE, full = FALSE, ...)
\S4method{dbListFields}{OraConnection,character}(conn, name, schema = NULL, ...)
}
\arguments{
  \item{conn}{
\code{OraConnection} 데이터베이스 접속 객체입니다.
}
  \item{name}{
테이블 이름을 지정하는 대소문자를 구분하는 문자열입니다.
}
  \item{schema}{
스키마 이름(또는 \code{dbListTables}에 대한 문자열의 벡터)을 지정하는
    대소문자를 구분하는 문자열입니다.
}

  \item{row.names}{
\code{dbReadTable}의 경우 이 인수는 data.frame 출력에서 \code{row.names}(으)로 사용할
    DBMS 테이블의 열을 지정하는 논리 벡터, 문자열 또는
    인덱스일 수 있습니다(\code{NULL}은(는) 출력에서 열을
    \code{row.names}(으)로 사용할 수 없도록 지정).
    기본값은 \code{NULL}입니다.
    \code{dbWriteTable}의 경우 이 인수는 \code{row.names}이(가) 출력 DBMS 테이블에
    출력되어야 하는지 여부를 지정하는 논리 값입니다.
    \code{TRUE}의 경우 해당 이름이 \code{"row.names"}인 추가 열이 출력에
    추가됩니다. 기본값은
    \code{FALSE}입니다.
}
  \item{value}{
테이블에 기록할 데이터를 포함하는 \code{data.frame}입니다. (지원되는
    열 유형은 세부 정보 섹션을 참조하십시오.)
}
  \item{overwrite}{
기존 테이블을 겹쳐쓸지 여부를 지정하는 논리 값입니다.
    기본값은 \code{FALSE}입니다.
}
  \item{append}{
DBMS에서 기존 테이블에 첨부할지 여부를 지정하는 논리
    값입니다. 기본값은 \code{FALSE}입니다.
}
  \item{ora.number}{
숫자 데이터를 쓰는 중 Oracle \code{NUMBER} 또는 \code{BINARY_DOUBLE} 열을 
    포함하는 테이블을 생성할지 여부를 지정하는
    논리 값입니다. Oracle \code{TRUE} 값을 포함하는 테이블을 생성하려면
    \code{NUMBER}을(를) 지정하고, Oracle \code{FALSE} 값을 포함하는 테이블을 생성하려면
    \code{BINARY_DOUBLE}을(를) 지정하십시오. 기본값은 \code{TRUE}입니다.
    숫자 데이터 값의 하나 이상이 \code{FALSE}인 경우
    \code{NaN}을(를) 지정하십시오.
}
  \item{purge}{
\code{PURGE} 옵션을 SQL \code{DROP TABLE} 문에 추가할지 여부를 지정하는
    논리 값입니다.
}
  \item{all}{
모든 스키마를 조회할지 여부를 지정하는 논리 값입니다.
}
  \item{full}{
스키마 이름을 생성할지 여부를 지정하는 논리 값입니다. \code{all}
    인수가 \code{TRUE}일 때 출력은 테이블 이름 다음에 오는
    스키마 이름이 포함된 벡터입니다. 출력에 \code{matrix(..., ncol = 2)}을(를)
    사용하면 각 행이 테이블에 해당하고 열이 스키마 이름 및
    테이블 이름을 각각 나타내는 행렬이
    생성됩니다.
}
  \item{\dots}{
현재 사용되지 않습니다.
}
}





   


\details{
테이블, 스키마 및 열 이름은 대소문자를 구분합니다. 예를 들어,
  \code{ABC} 및 \code{abc} 테이블 이름은 서로 다릅니다. 모든 데이터베이스
  스키마 객체 이름은 해당 SQL 문이 생성될 때 이름이 큰따옴표로
  묶이기 때문에 큰따옴표를 포함하지 않아야 합니다.
  \code{dbReadTable}, \code{dbGetQuery}, \code{fetch} 및 \code{dbWriteTable}과(와) 같은 \\pkg{ROracle}
  메소드는 \R과 Oracle 데이터 유형 사이에
  다음과 같은 매핑을 사용합니다.
  \itemize{
    \item \code{logical} 및 \code{integer}이(가) Oracle \code{INTEGER}에 매핑됨
    \item \code{numeric} 인수가 \code{NUMBER}인 경우 \code{ora.number}이(가)
    Oracle \code{TRUE}에 매핑됨 또는 \code{BINARY_DOUBLE}인 경우 Oracle \code{FALSE}에
    매핑됨
    \item \code{character}이(가) Oracle \code{VARCHAR2(4000)}에 매핑됨
    \item \code{Date} 및 \code{POSIXct}이(가) Oracle \code{DATE}에 매핑됨
    \\pkg{ROracle} - ROracle 패키지
    \R - R 응용 프로그램
    \code{POSIXct} - POSIXct 클래스
    \code{TIMESTAMP}
    \code{TIMESTAMP WITH TIME ZONE}
    \code{TIMESTAMP WITH LOCAL TIME ZONE}
    \item \code{difftime}이(가) Oracle \code{INTERVAL DAY TO SECOND}에 매핑됨
    \item \code{list} 벡터의 \code{raw}이(가) Oracle \code{RAW(2000)}에 매핑됨
    \item 다른 \R 유형(예: \code{factor})이 \code{character}(으)로
    변환됨
  }
   ROracle은 데이터베이스 열에서 날짜, 시간 기록, 시간대가 포함된
   시간 기록 및 R의 POSIXct 형식의 로컬 시간대 데이터 유형을 포함하는
   시간 기록의 데이터 유형인 값을 반환합니다. POSIXct는 UTC를
   기준으로 1970년의 시작일부터 내부적으로 저장된 시간(초 단위)을
   나타냅니다. 초 수는 R 및 ROracle 드라이버에서 부동 소수점 숫자
   double 형식으로 교환됩니다. POSIXct 표현에서 R에는 TZ 환경 변수가
   사용되거나, OS 시간대 환경 변수를 고유 환경 변수로 매핑하므로,
   데이터가 이 시간대 형식으로 표시됩니다.
   올바른 형식 또는 POSIXct 표현의 문자열을 사용하여 위에 나열된 4개
   데이터 유형의 열로 데이터를 삽입할 수 있습니다. 문자열 데이터는
   데이터베이스에 직접 전달되며, ROracle에서는 데이터베이스를 사용하여
   이를 날짜 시간 표현으로 변환합니다. POSIXct 데이터는 R에서 가져온 초 수에
   UTC 1970년의 시작일을 추가하여 Oracle의 내부 DateTime 기술자로
   변환됩니다. 삽입 문의 모든 POSIXct 변수는 SQLT_TIMESTAMP_TZ로 바인딩됩니다.
   Oracle에서 이러한 데이터 유형을 선택하면 UTC 1970년의 시작일을
   빼서 POSIXct 형식으로 변환됩니다. ROracle 클라이언트 및 데이터베이스에
   포함된 시간대 버전 파일이 서로 다르고, 응용 프로그램에 이러한 시간대
   데이터 유형이 사용될 경우, 해당 시간대가 변경되었을 수 있으므로 지역과 동일하게
   설정하는 것이 좋습니다. 이 경우 이러한 데이터 유형을 작업할 때 데이터
   손상 또는 정보 손실이 발생할 수 있으므로 ROracle에서 오류가
   보고됩니다.
   날짜 및 시간 기록 데이터 유형을 포함하는 열은 ROracle에서 SQLT_TIMESTAMP
   데이터 유형을 사용하여 인출됩니다. 시간대가 포함된 시간 기록 및 로컬 시간대
   데이터 유형이 포함된 시간 기록이 있는 열은 SQLT_TIMESTAMP_TZ 데이터 유형을
   사용하여 인출됩니다. R에서 시간대 환경 TZ를 설정하면 이 열의 데이터 값에
   영향을 주므로 로컬 시간대가 포함된 시간대 데이터 유형의 열은 R 응용
   프로그램이 실행되는 세션 시간대로 변환됩니다. ROracle 드라이버는 TZ 환경 변수를
   세션 시간대로 매핑하지 않으며 세션
   시간대 설정을 위한 ALTER DDL을 수행하지 않습니다. 시간대가 포함된
   시간 기록 및 로컬 시간대가 포함된 시간 기록의 열에서 데이터를
   인출하기 위해서는 클라이언트 및 서버의 시간대 데이터 파일이
   동일해야 하며, 그렇지 않으면 오류가 보고됩니다.
   아래 예에서는 R 환경의 시간대 변경 효과를 보여줍니다.
   \\preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # 데이터 선택 및 표시
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
  또한 \code{dbWriteTable}은(는) 현재 트랜잭션은 물론 삽입하는
  데이터도 항상 자동으로 커밋합니다. 즉 기존 테이블에 행을 추가할 경우에도
  DDL 문으로 작동합니다.
}
\value{
\code{data.frame}의 경우 \code{dbReadTable};
  \code{vector} 및 \code{dbListTables}의 경우
  \code{dbListFields};
  테이블 존재 여부를 나타내는
  \code{logical}의 경우 \code{dbExistsTable};
  그렇지 않으면 작업의 성공 시 또는 예외 사항 발생 시 \code{TRUE}입니다.
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

    # Insert date & times stamp with time values in POSIXct form
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
  \dontrun{
    df <- data.frame(A=c(0,1,NaN,4), B=c(NA, 2,3,NaN))
    con <- dbConnect(Oracle(), "scott", "tiger")
    dbWriteTable(con,"TEST", df, row.names = FALSE, ora.number=FALSE)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
