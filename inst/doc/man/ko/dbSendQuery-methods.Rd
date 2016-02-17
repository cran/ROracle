\name{dbSendQuery-methods}
\docType{methods}
\alias{dbSendQuery}
\alias{dbGetQuery}
\alias{oracleProc}
\alias{dbClearResult}
\alias{dbGetException}
\alias{execute}
\alias{dbSendQuery,OraConnection,character-method}
\alias{dbGetQuery,OraConnection,character-method}
\alias{dbClearResult,OraResult-method}
\alias{oracleProc,OraConnection,character-method}
\alias{dbGetException,OraConnection-method}
\alias{execute,OraResult-method}
\title{
제공된 데이터베이스 접속에서 명령문 실행
}
\description{
이러한 메소드는 ROracle 특정 DBI 확장인 \code{execute} 메소드를 제외하고
   해당하는 일반 함수를 간단히 구현한
   것입니다.
}
\usage{
\S4method{dbSendQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbGetQuery}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{oracleProc}{OraConnection,character}(conn, statement, data = NULL, 
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
\S4method{dbClearResult}{OraResult}(res, ...)
\S4method{dbGetException}{OraConnection}(conn, ...)

execute(res, ...)
\S4method{execute}{OraResult}(res, data = NULL, ...)
}
\arguments{
  \item{conn}{
\code{OraConnection} 객체입니다.
}
  \item{statement}{
SQL 문에서 길이가 1인 문자 벡터입니다.
}
  \item{res}{
\code{OraResult} 객체입니다.
}
  \item{data}{
바인드 데이터를 지정하는 \code{data.frame}입니다.
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
    할당됩니다. 응용 프로그램은 질의 결과를 기반으로 이 값을 조정해야 합니다.
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
\item{dbSendQuery}{
    해당 클래스가 \code{OraResult}을(를) 확장하는 \code{DBIResult} 객체입니다. 이 
    객체는 \code{fetch} 함수를 사용해서 데이터베이스에서 데이터를 인출하는 데 
    사용됩니다.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      Query statement is executed and data is fetched from database.
    }
    \item{dbSendQuery}{
      Query statement is executed, but data needs to be fetched through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{oracleProc}{
      PL/SQL stored procedure or function query statement is executed and 
      result is returned.
    }
    \item{dbClearResult}{
      Resources acquired by the result set are freed.
    }
    \item{dbGetException}{
      Error information is retrieved and then cleaned from the driver.
    }
    \item{execute}{
      Query statement is executed.
    }
  }
}
\details{
\\describe{
    \item{dbGetQuery}{
      이 함수는 질의 문을 실행하고 데이터베이스에서 결과 데이터를
      인출합니다. PL/SQL 질의 호출에는 사용하지 않아야 합니다.
    }
    \item{dbSendQuery}{
      이 함수는 질의 문을 실행하고 결과 집합을 응용 프로그램에 
      반환합니다. 그런 다음 응용 프로그램이 결과 집합에서 작업을 수행할 수 있습니다.
      PL/SQL 질의 호출에는 사용하지 않아야 합니다.
    }
     \item{oracleProc}{
      이 함수는 PL/SQL 내장 프로시저 또는 함수 질의 명령문을 실행하고
      결과를 반환합니다.
    }
    \item{dbClearResult}{
      이 함수는 결과 집합에서 사용된 리소스를 해제합니다.
    }
    \item{dbGetException}{
      이 함수는 오류 정보를 검색합니다.
    }
    \item{execute}{
      이 함수는 지정된 질의 문을 실행합니다.
    }
  }
}
\section{References}{
  For the Oracle Database documentation see 
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")
    res <- dbSendQuery(con, "select * from emp where deptno = :1",
                       data = data.frame(deptno = 10))
    data <- fetch(res, n = -1)
    res2 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data1 <- data.frame(deptno = 10), prefetch=TRUE,
                        bulk_read=2L)
    data1 <- fetch(res2, n = -1)
    data1

    res3 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data2 <- data.frame(deptno = 10), bulk_read=10L)
    data2 <- fetch(res3, n = -1)
    data2

    res4 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data3 <- data.frame(deptno = 10), bulk_write=10L)
    data3 <- fetch(res4, n = -1)
    data3

    res5 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data4 <- data.frame(ename = 'SMITH')) 
    data4 <- fetch(res5, n = -1)
    data4
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
