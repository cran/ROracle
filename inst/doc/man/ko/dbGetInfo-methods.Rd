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
데이터베이스 인터페이스 메타데이터
}
\description{
이 메소드는 해당하는 일반 함수를 간단히 구현한
   것입니다.
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
R 인터페이스에서 데이터베이스에 대한 일부 기능을
    구현하는 객체입니다(드라이버, 접속 또는 결과 집합).
}
  \item{what}{
출력 목록의 요소를 지정하는 문자열입니다.
}
  \item{res}{
\code{OraResult}입니다.
}
  \item{\dots}{
현재 사용되지 않습니다.
}
}


































\details{
테이블, 스키마 및 열 이름은 대소문자를 구분합니다. 예를 들어, 테이블 이름
  \code{ABC}과(와) \code{abc}은(는) 동일하지 않습니다. 모든 데이터베이스 스키마
  객체 이름은 해당 SQL 문이 생성될 때 큰 따옴표로 묶이므로
  큰 따옴표를 포함하지 않아야 합니다.
  \\pkg{ROracle} 메소드 \code{dbGetInfo}은(는) 드라이버 객체에 대한 다음
  세부정보를 제공합니다.
  \itemize{
    \item {\\$driverName} 드라이버 이름이 "Oracle (OCI)"입니다.
    \item {\\$driverVersion} 사용된 ROracle 드라이버의 버전입니다.
    \item {\\$clientVersion} 사용된 Oracle Client 라이브러리의 버전입니다.
    \item {\\$conTotal} 드라이버에 의해 인스턴스화된 접속 수입니다.
    \item {\\$conOpen} 현재 열린 접속 수입니다.
    \item {\\$interruptible} 장기 실행 질의가 중단될 수 있으면 TRUE입니다.
    \item {\\$unicode_as_utf8} 문자 데이터가 UTF8 인코딩 형식으로 인출되면
                              TRUE입니다.
    \item {\\$ora_attributes} 결과 집합 데이터 프레임의 각 열에 해당 Oracle DBMS 속성이 있으면
                             TRUE입니다.
    \item {\\$connections} 현재 열린 각 접속에 대한 정보입니다. 자세한 내용은
                          접속 객체의 \code{dbGetInfo}을(를) 참조하십시오.
  }
  \\pkg{ROracle} 메소드 \code{dbGetInfo}은(는) 접속 객체에 대한 다음
  세부정보를 제공합니다.
  \itemize{
    \item {\\$username} 이 접속의 사용자 이름입니다.
    \item {\\$dbname} 사용된 접속 별칭 또는 접속 문자열입니다.
    \item {\\$serverVersion} Oracle Database 서버의 버전입니다.
    \item {\\$serverType} 값이 "Oracle RDBMS"입니다.
    \item {\\$resTotal} 이 접속의 결과 집합 수입니다.
    \item {\\$resOpen} 이 접속에서 열린 결과 접속 수입니다.
    \item {\\$prefetch} 데이터를 인출하는 데 사전 인출 방식이 사용되면 TRUE입니다.
    \item {\\$bulk_read} DBMS에서 한 번에 인출할 행 수입니다.
    \item {\\$bulk_write} DBMS에 한 번에 쓸 행 수입니다.
    \item {\\$stmt_cache} 명령문 캐시가 사용될 때 TRUE입니다.
    \item {\\$results} 현재 열린 각 결과 집합에 대한 정보입니다. 자세한 내용은 결과 집합의
                      \code{dbGetInfo}을(를) 참조하십시오.
  }
  \\pkg{ROracle} 메소드 \code{dbGetInfo}은(는) 결과 집합 객체에 대한 다음 세부정보를
  제공합니다.
  \itemize{
    \item {\\$statement} 결과 집합 객체를 생성하는 데 사용되는 SQL 문입니다.
    \item {\\$isSelect} select 문이 지정되면 TRUE입니다.
    \item {\\$rowsAffected} DML 문에 의해 영향을 받은 행 수입니다.
    \item {\\$rowCount} 현재 결과 집합의 수입니다.
    \item {\\$completed} 결과 집합에 추가 행이 없으면 TRUE입니다.
    \item {\\$prefetch} 데이터를 인출하는 데 사전 인출 방식이 사용되면 TRUE입니다.
    \item {\\$bulk_read} DBMS에서 한 번에 인출할 행 수입니다.
    \item {\\$bulk_write} DBMS에 한 번에 쓸 행 수입니다.
    \item {\\$fields} 결과 집합의 각 열에 대한 정보입니다. 자세한 내용은
                     \code{dbColumnInfo}을(를) 참조하십시오.
  }
  \\pkg{ROracle} 메소드 \code{dbColumnInfo}은(는) 결과 집합의 각 열에 대한
  다음 세부정보를 제공합니다.
  \itemize{
    \item {\\$name} 열의 이름입니다.
    \item {\\$Sclass} Oracle RDBMS에서 반환된 데이터를 포함하는 객체의
                     R 유형입니다.
    \item {\\$type} Oracle RDBMS에서 생성된 열의 유형입니다.
    \item {\\$len} Oracle RDBMS의 VARCHAR, CHAR 및 RAW 열 유형 길이입니다.
                  다른 모든 열에는 NA가 포함됩니다.
    \item {\\$precision} 숫자 열의 전체 자릿수입니다.
    \item {\\$scale} 숫자 열의 소숫점 이하 자릿수입니다.
    \item {\\$nullOK} 열에 NULL 값이 제공될 수 있으면 TRUE입니다.
  }
   아래 예에서는 다음을 포함하여 테이블에 대한 드라이버, 접속, 결과 집합 및 열
   정보를 보여줍니다.
 \\preformatted{
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
\\preformatted{   library(ROracle)
필수 패키지 로드 중: DBI
> # ROracle 드라이버 객체 인스턴스화
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
사용자 이름:             scott 
접속 문자열:         
서버 버전:        11.2.0.4.0 
서버 유형:           Oracle RDBMS 
처리된 결과 수:     1 
OCI 사전 인출:          FALSE 
대량 읽기:             1000 
대량 쓰기:            1000 
명령문 캐시 크기:  0 
미해결된 결과 수:          1 
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
명령문:            select * from foo 
영향 받은 행 수:        0 
행 수:            0 
Select 문:     TRUE 
명령문 완료됨:  FALSE 
OCI 사전 인출:         FALSE 
대량 읽기:            1000 
대량 쓰기:           1000 
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
드라이버, 접속 또는 결과 집합 객체에 대한 정보입니다.
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
