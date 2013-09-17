\name{dbSendQuery-methods}
\docType{methods}
\alias{dbSendQuery}
\alias{dbGetQuery}
\alias{dbClearResult}
\alias{dbGetException}
\alias{execute}
\alias{dbSendQuery,OraConnection,character-method}
\alias{dbGetQuery,OraConnection,character-method}
\alias{dbClearResult,OraResult-method}
\alias{dbGetException,OraConnection-method}
\alias{execute,OraResult-method}
\title{
주어진 데이터베이스 접속에 명령문 실행
}
\description{
이 메소드는 해당하는 일반 함수를 간단히 구현한
   것입니다. 단, ROracle 특정 DBI 확장인 \code{execute}
   메소드는 예외입니다.
}
\usage{
\S4method{dbSendQuery}{OraConnection,character}(conn, statement, data = NULL, prefetch = FALSE, bulk_read = 1000L, ...)
\S4method{dbGetQuery}{OraConnection,character}(conn, statement, data = NULL, prefetch = FALSE, bulk_read = 1000L, ...)
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
바인드 데이터를 지정하는 data.frame입니다.
}
  \item{prefetch}{
TRUE 또는 FALSE를 나타내는 논리 값입니다. TRUE로 설정된 경우 ROracle은
    OCI 사전 인출 버퍼를 사용하여 서버에서 추가 데이터를 검색하므로
    OCI에서 데이터를 인출하기 위해 단일 행 버퍼를 할당하여 RODBI/ROOCI에
    필요한 메모리를 줄여줍니다. 사전 인출을 사용하면 모든 행에 대해 인출 호출이
    수행됩니다. 기본적으로 사전 인출은 FALSE이며 서버에서 데이터를 검색하는 데
    배열 인출이 사용됩니다.
}
  \item{bulk_read}{
한 번에 인출할 수 있는 행 수를 나타내는 정수 값입니다. 기본값은
    1000L입니다. 사전 인출 옵션이 선택된 경우 사전 인출 버퍼에 메모리가
    할당되고 OCI가 해당 개수의 행을 한 번에 인출합니다. 사전 인출이 사용되지
    않은 경우(기본값) 메모리가 RODBI/ROOCI 정의 버퍼에 할당됩니다. 이를
    큰 값으로 설정하면 선택한 목록의 열 수 및 열 유형을 기반으로
    더 많은 메모리가 할당됩니다. 문자 열의 경우 NLS 최대 너비의
    몇 배에 달하는 최대 너비를 사용하여 정의 버퍼가 할당됩니다.
    응용 프로그램은 쿼리 결과에 따라 이 값을 조정해야 하며, 큰 값을
    사용하면 큰 결과를 반환하는 질의 이점을 얻을 수 있습니다.
    응용 프로그램은 필요에 따라 이 값을 조정할 수 있습니다.
}
  \item{\dots}{
현재 사용되지 않습니다.
}
}
\value{
\item{dbSendQuery}{
    해당 클래스가 \code{OraResult}을(를) 확장하는 \code{DBIResult} 객체입니다. 
    이 객체는 \code{fetch} 함수를 사용하여 데이터베이스에서 데이터를 인출하는 데
    사용됩니다.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbGetQuery}{
      query statement is executed and data has fetched from database.
    }
    \item{dbSendQuery}{
      query statement is executed, but note that data needs to fetch through
      calls to \code{\link[DBI]{fetch}}.
    }
    \item{dbClearResult}{
      resources acquired by result set has free.
    }
    \item{dbGetException}{
      error information retrieved and then cleaned from driver.
    }
    \item{execute}{
      query statement is executed.
    }
  }
}
\details{
\\describe{
    \item{dbGetQuery}{
      구현 시 질의 문을 실행하고 데이터베이스에서 결과
      데이터를 인출합니다. 
    }
    \item{dbSendQuery}{
      구현 시 질의 문을 실행하고 결과 집합을 응용
      프로그램에 반환합니다. 이제 응용 프로그램이 결과 집합에서 작업을 수행할
      수 있습니다. 
    }
    \item{dbClearResult}{
      구현 시 결과 집합에 사용된 리소스를 해제합니다.
    }
    \item{dbGetException}{
      구현 시 오류 정보가 검색되지 않습니다.
    }
    \item{execute}{
      구현 시 질의 문이 실행됩니다.
    }
  }
}
\section{References}{
  For the Oracle Database documentaion see 
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
                        data1 = data.frame(deptno = 10), prefetch=TRUE,
                        bulk_read=2L)
    data1 <- fetch(res2, n = -1)
    res3 <- dbSendQuery(con, "select * from emp where deptno = :1",
                        data2 = data.frame(deptno = 10), bulk_read=10L)
    data2 <- fetch(res3, n = -1)
    res4 <- dbSendQuery(con, "select * from emp where ename = :1",
                        data3 = data.frame(ename = 'SMITH')) 
    data3 <- fetch(res4, n = -1)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
