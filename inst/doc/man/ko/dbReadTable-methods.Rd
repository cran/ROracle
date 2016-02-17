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
이러한 함수는 데이터베이스 엔진에서 원격으로 실행되는 코드를
  생성한다는 것만 제외하면 해당 R 함수의 기능을 모방합니다.
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} 및
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
\code{OraConnection} 데이터베이스 접속 객체입니다.
}
  \item{name}{
테이블 이름을 지정하는 대소문자를 구분하는 문자열입니다.
}
  \item{schema}{
스키마 이름(또는 \code{dbListTables}에 대한 문자열의 벡터)을 지정하는
    대소문자를 구분하는 문자열입니다.
}
  \item{date}{
date 또는 DateTime을 사용할지 여부를 나타내는 부울 플래그입니다.
    기본적으로 timestamp 대신 DateTime이 사용됩니다.
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
    열 유형은 세부정보 섹션을 참조하십시오.)
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
  테이블 이름 \code{ABC}과(와) \code{abc}은(는) 동일하지 않습니다. 모든 데이터베이스 스키마
  객체 이름은 해당 SQL 문이 생성될 때 큰따옴표 안에 포함되기
  때문에 큰따옴표를 포함하지 않아야 합니다.
   다음 속성은 \code{dbWriteTable}에서 BLOB, CLOB, NCLOB, NCHAR, VARCHAR2,
   NVARCHAR2, CHAR, TIMESTAMP WITH TIME ZONE 및 TIMESTAMP WITH LOCAL TIME ZONE 열을
   올바르게 매핑하기 위해 사용됩니다.
   1) 속성 이름: \code{ora.type}
   이 속성은 기본 열의 유형을 나타내며, "CLOB", "BLOB", "CHAR",
   "VARCHAR2" 또는 "RAW"일 수 있습니다. 사용자는
   TIMESTAMP, DATE, TIMESTAMP WITH TIME ZONE 또는 Oracle 데이터베이스에서
   지원되는 다른 모든 열 유형을 지정할 수 있습니다. ROacle은 값을 구문 분석하지 않으며,
   데이터베이스에서 검증됩니다. 사용자는 \code{ora.type}에 대해 다음 중 하나의 값을
   제공할 수 있습니다. CLOB, BLOB, CHAR, TIMESTAMP WITH TIME
   ZONE, TIMESTAMP WITH LOCAL TIME ZONE 및 fractional_seconds_precision.
   2) 속성 이름: \code{ora.encoding}
   UTF-8이 지정된 경우 데이터베이스는 \code{ora.type}을 기반으로 NCLOB, NCHAR 또는 NVARCHAR을
   사용합니다.
   3) 속성 이름: \code{ora.maxlength}
   CHAR, VARCHAR, NCHAR, NVARCHAR2 또는 RAW 열의 최대 길이를 지정할 수
   있습니다. 다른 데이터 유형의 경우에는 \code{ora.maxlength}이(가)
   적용되지 않고 무시됩니다. \code{ora.maxlength}이 지정되지 않은 경우에는 특정 데이터
   유형에 대해 다음 기본값이 사용됩니다.
   CHAR                                       2000
   NCHAR                                      1000
   VARCHAR2                                   4000
   NVARCHAR2                                  2000
   RAW                                        2000
   4) 속성 이름: \code{ora.fractional_seconds_precision}
   TIMESTAMP, TIMESTAMP WITH TIME ZONE 및 TIMESTAMP WITH LOCAL
   TIME ZONE 열의 SECOND 날짜/시간 필드 일부를 지정할 수 있습니다.
   0~9까지 범위의 숫자일 수 있습니다. 기본값은 6입니다.
  \code{dbReadTable}, \code{dbGetQuery}, \code{fetch} 및 \code{dbWriteTable}과(와) 같은
  \\pkg{ROracle} 메소드는 \R과 Oracle 데이터
  유형 사이에 다음과 같은 매핑을 사용합니다.
  \itemize{
    \item \code{logical} 및 \code{integer}을(를) Oracle \code{INTEGER}에 매핑
    \item \code{numeric}이(가) \code{NUMBER}인 경우 \code{ora.number}을(를)
    Oracle \code{TRUE}에 매핑, 또는 \code{BINARY_DOUBLE}인 경우 Oracle \code{FALSE}에
    매핑
    \item \code{character}이(가) \code{CLOB}인 경우 \code{ora.type}을(를) 
    Oracle \code{"CLOB"}에 매핑, 또는 \code{NCLOB}이(가) \code{ora.type}이고
    \code{"CLOB"}이(가) \code{ora.encoding}인 경우 Oracle \code{"UTF-8"}에 매핑,
    또는 \code{CHAR(ora.maxlength)} 속성이 \code{ora.type}인 경우 
    Oracle \code{"CHAR"}에 매핑 또는 \code{NCHAR(ora.maxlength)} 속성이 
    \code{ora.type}이고 \code{"CHAR"}이(가) \code{ora.encoding}인 경우
    Oracle \code{"UTF-8"}에 매핑,  또는 \code{NVARCHAR2(ora.maxlength)} 속성이
    \code{ora.encoding}인 경우 Oracle \code{"UTF-8"}에 매핑, 또는 Oracle \code{VARCHAR2(ora.maxlength)}에 매핑
    \item \code{Date} 및 \code{POSIXct}을(를) Oracle \code{DATE}에 매핑
    \\pkg{ROracle} - ROracle 패키지
    \R - R 애플리케이션
    \item \code{POSIXct} 속성이 \code{TIMESTAMP WITH TIME ZONE(ora.fractional_seconds_precision)}인 경우 
    \code{ora.type}을(를) 
    Oracle \code{"TIMESTAMP WITH TIME ZONE"}에 매핑 또는 \code{TIMESTAMP WITH LOCAL TIME ZONE(ora.fractional_seconds_precision)} 속성이 
    \code{ora.type}인 경우
    Oracle \code{"TIMESTAMP WITH LOCAL TIME ZONE"}에 매핑 또는
    \code{TIMESTAMP(ora.fractional_seconds_precision)}이(가) \code{Date}인 경우 
    Oracle \code{FALSE}에 매핑 
    \item \code{difftime}을(를) Oracle \code{INTERVAL DAY TO SECOND}에 매핑
    \item \code{list} 속성이 \code{raw}인 경우 \code{BLOB} 벡터의 
    \code{ora.type}을(를) Oracle \code{"BLOB"}에 매핑 또는 
    Oracle \code{RAW(ora.maxlength)}에 매핑
    \item \code{factor}과(와) 같은 다른 \R 유형은 \code{character}(으)로
    변환됨
  }
   ROracle은 R의 POSIXct 형식으로 된 날짜, 시간 기록, TIMESTAMP WITH
   TIME ZONE, TIMESTAMP WITH LOCAL TIME ZONE 데이터 유형인 데이터베이스 열에서
   값을 반환합니다. POSIXct는 1970년부터
   시작해서(UTC) 이후의 초 수로 내부적으로 저장되는 시간을
   참조합니다. 초 수는 R 및 ROracle 드라이버에서 부동 소수점 double
   형식으로 교환됩니다. POSIXct 표현에서 R은 TZ
   환경 변수를 사용하거나 OS 시간대 환경 변수를 해당 고유값으로 매핑하므로,
   날짜가 이 시간대 형식으로 표시됩니다.
   올바른 형식의 문자열 또는 POSIXct 표현을 사용해서 위에 나열된
   4가지 데이터 유형의 열로 데이터를 삽입할 수 있습니다. 문자열 데이터는
   데이터베이스로 직접 전달되며 ROracle은 데이터베이스를 사용해서 이를
   날짜/시간 표현으로 변환합니다. ROracle 드라이버는 POSIXct 표현을
   문자열 표현으로 변환하며, 이를 위해 DML 작업에서 사용되는
   날짜 프레임에서 "\%Y-\%m-\%d \%H:\%M:\%OS6" 형식을 사용합니다.
   이 형식의 데이터는 NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF"에 해당하며, Oracle 데이터베이스에 바인딩되는
   SQLT_TIMESTAMP_LTZ로 변환됩니다. ROracle 드라이버에 대한 문자 데이터를 내부적으로
   나타내는 중간 클래스 "datetime"이 생성됩니다.
   날짜 및 시간 기록 데이터 유형을 갖는 열은 SQLT_TIMESTAMP 데이터 유형을
   사용해서 ROracle에서 인출됩니다. TIMESTAMP WITH TIME ZONE 또는 TIMESTAMP WITH LOCAL TIME ZONE
   데이터 유형을 갖는 열은 SQLT_TIMESTAMP_LTZ 데이터 유형을
   사용해서 인출됩니다. TIMESTAMP WITH LOCAL TIME ZONE 데이터 유형을 갖는
   열은 R 애플리케이션이 실행되는 세션 시간대로 변환되므로,
   R에서 시간대 환경 TZ를 설정하면 이 열에 있는 데이터 값에
   영향을 줍니다. ROracle 드라이버는 TZ 환경 변수를 세션 시간대로
   매핑하고 데이터베이스에 접속이 수행된 경우 변경 DDL을 실행해서
   세션 시간대를 설정합니다.
   TIMESTAMP WITH TIME ZONE 또는 TIMESTAMP WITH LOCAL TIME ZONE를 갖는 열에서
   데이터를 인출하려면, 클라이언트와 서버의 시간대 데이터 파일이 동일해야
   하며, 그렇지 않으면 오류가 보고됩니다.
   데이터베이스에서 이러한 데이터 유형을 선택하면 R에서
   "\%Y-\%m-\%d \%H:\%M:\%OS6"에 해당하는
   NLS_TIMESTAMP_TZ_FORMAT"YYYY-MM-DD HH24:MI:SSXFF"를 사용해서 문자열 표현으로
   변환됩니다. ROracle 드라이버에서 이 문자를 나타내기 위한
   내부 클래스 "datetime"이 생성됩니다. 그런 다음 ROracle
   드라이버는 as.POSIXct() 함수를 사용해서 이를 POSIXct로 변환합니다. R 애플리케이션은
   데이터 프레임에서 POSIXct 형식으로 데이터를 확인합니다.
   \\preformatted{
R 세션 시간대:
 R은 R 엔진이 작동하는 시간대 개념을 갖고 있습니다. 시간대는
 'PST8PDT', 'America/Los_Angeles' 등과 같은 문자열로 설정할 수 있습니다.
 이러한 문자열은 사용자가 스스로 해석할 수 있으며, 세션이 작동하는
 시간대를 지정합니다.
 R 세션 시간대는 다음 방법 중 하나로 설정할 수 있습니다.
 1. R을 시작하기 전에 Linux 또는 Unix 명령행에 다음을
    입력합니다.
    setenv TZ = America/Los_Angeles on Linux/UNIX
    참고: Windows에서는 환경 변수 TZ에 대해 Oracle 호환 시간대 이름을
          설정하도록 허용되지 않으므로, 이 옵션을 사용하지 마십시오.
 2. R 프롬프트에서 다음을 입력합니다.
    Sys.setenv(TZ = "PST8PDT")
 R 스크립트는 Linux/Unix는 물론 Windows에서도 어떠한 이식
 문제 없이 작동하기 때문에 두번째 옵션을 사용하는 것이 좋습니다. 두번째 옵션을 사용할 경우에는
 Windows에서 Oracle 호환 시간대 이름을 지정할 수도 있습니다.
 R 세션 시간대는 POSIXct 시간대로 적합하지 않은 모든 날짜-시간
 유형에 대해 시간대를 확인합니다. 또한 이 시간대는 R에서 표시될 때
 적격한 모든 날짜-시간 유형이 변환되는 시간대이기도 합니다.
 다음 예제는 이에 대해 설명합니다.
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
적합하지 않은 시간대는 R에서 표시될 때 R의 세션 시간대로
설정되는 것으로 간주됩니다. 물론 R은 미국 일광 절약 시간이 시작되는
시점을 기준으로 시간이 PST 또는 PDT에 속하는지 여부를 충분히
확인할 수 있으며, 그에 따라 PST 또는 PDT를
표시합니다.
다음 예제는 이를 보다 명확하게 보여줍니다.
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
적합하지 않은 모든 시간대 시간 기록은 세션 시간대로 설정되는
것으로 간주됩니다. 하지만 적합한 시간대 시간 기록도 세션 시간대로
변환되어 표시됩니다. 모든 값은 R에서
R 세션의 시간대로 표시됩니다(적용 가능한 경우 일광
절약 시간을 나타내기 위해 시간대 이름이 EST 또는
EDT로 수정됨). http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html에서
날짜-시간 클래스를 참조하고
http://stat.ethz.ch/R-manual/R-devel/library/base/html/timezones.html에서
시간대를 참조하여
R의 날짜 및 시간과 시간대 처리 방법을 확인하십시오.
짧은 축약 표현 대신 긴 시간대 이름(종종 'Olson Name'이라고도
부름)을 사용하는 경우의 예를 들어보겠습니다.
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
이러한 경우에 R은 값이 표시될 때 긴 이름을 사용하지 않지만,
대신 "PST" 및 "PDT" 축약을 사용해서 값을 계속
표시합니다. 이러한 특성은 Oracle에서
반드시 이러한 축약을 사용해야 할 필요가 없기 때문에 중요합니다. 예를 들어, Oracle
데이터베이스는 "PDT"를 적합한 시간대로 인식하지 않습니다. 적합한 시간대에
대한 자세한 내용은 "R 시간대 및 Oracle 세션 시간대"를 참조하십시오.
}
   아래 예에서는 R 환경의 시간대 변경 효과를
   보여줍니다.
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
  또한 \code{dbWriteTable}은(는) 삽입하는 데이터뿐만 아니라 현재 트랜잭션도
  항상 자동 커밋합니다. 즉, 기존 테이블에 행을 추가하는 경우에도
  DDL 문으로 작동합니다.
}
\value{
\code{data.frame}의 경우 \code{dbReadTable};
  \code{vector} 및 \code{dbListTables}의 경우
  \code{dbListFields};
  테이블 존재 여부를 나타내는
  \code{logical}의 경우 \code{dbExistsTable};
  그렇지 않으면 작업의 성공 시 또는 예외사항 발생 시 \code{TRUE}입니다.
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
