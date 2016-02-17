\name{dbDriver-methods}
\docType{methods}
\alias{dbUnloadDriver}
\alias{dbUnloadDriver,OraDriver-method}
\alias{dbUnloadDriver,ExtDriver-method}
\title{
Oracle에서 DBI(데이터베이스 인터페이스) 클래스 및 드라이버 구현
}
\description{
Oracle 드라이버 초기화 및 마감.
}
\usage{
\S4method{dbUnloadDriver}{OraDriver}(drv, ...)
\S4method{dbUnloadDriver}{ExtDriver}(drv, ...)
}
\arguments{
  \item{drv}{
\code{OraDriver}에 의해 생성된 \code{ExtDriver} 또는 \code{dbDriver}에서
    상속되는 객체입니다.
}

  \item{...}{
다른 모든 인수는 \code{drvName} 드라이버에 전달됩니다.
}
}
\value{
\item{dbDriver}{
    해당 클래스가 \code{OraDriver}을(를) 확장하는 \code{ExtDriver} 또는 \code{DBIDriver}
    객체입니다. 이 객체는 \code{dbConnect} 함수를 사용하여 하나 이상의
    Oracle Database 엔진에 대한 접속을 생성하는 데 사용됩니다.
  }
  \item{dbUnloadDriver}{
    드라이버 객체에서 점유된 모든 리소스를 해제합니다.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbDriver}{
      The \R client part of the database communication is initialized,
      but note that connecting to the database engine needs to be done through
      calls to \code{\link[DBI]{dbConnect}}.
    }
    \item{dbUnloadDriver}{
      Remove the communication link between the \R client and the database.
    }
  }
}





\details{
\\describe{
    \item{dbDriver}{
      이 객체는 단일 객체입니다. 즉, \code{dbDriver}의 후속 호출 시 동일한
      초기화된 객체가 반환됩니다.
      이 구현에서는 여러 호스트 서버에 접속하고 각 서버에서
      여러 접속을 동시에 실행할 수 있습니다.
      \code{interruptible}이(가) TRUE로 설정된 경우 서버에서 스레드에 질의를
      실행하여 장기 실행 질의를 중단할 수 있습니다.
      기본 스레드는 Ctrl-C를 검사하고 OCIBreak/OCIReset을 실행하여
      서버에서 작업을 취소합니다. 기본적으로 \code{interruptible}은(는) FALSE입니다.
      \code{unicode_as_utf8}이(가) FALSE로 설정된 경우 NLS_LANG 설정에 의해
      지정된 문자 집합을 사용하여 NCHAR, NVARCHAR 및 NCLOB
      데이터가 인출됩니다. 기본적으로 \code{unicode_as_utf8}은(는) TRUE로 설정됩니다.
      \code{ora.attributes}이(가) TRUE로 설정된 경우 \code{dbGetQuery} 및 \code{fetch}의
      결과 집합에 해당 열에 대한 \code{ora.encoding}, \code{ora.type} 및 \code{ora.maxlength}과(와)
      같은 DBMS 관련 속성이
      포함됩니다.
    }
    \item{dbUnloadDriver}{
      이 구현에서는 \R 클라이언트와 데이터베이스 사이의 통신 링크를
      제거합니다. 모든 접속 및 이러한 접속 객체와 연관된 모든
      결과 집합을 해제합니다.
    }
  }
}
\section{References}{
  For Oracle Database documentation, see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
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
    # first load the library
    library("ROracle")

    # create an Oracle instance
    drv <- dbDriver("Oracle")

    con <- dbConnect(drv, "scott", "tiger")
    dbListTables(con)

    # fetch all results from the emp table
    res <- dbGetQuery(con, "select * from emp")

    # dbSendQuery can be used to fetch data in chunks 
    # as well as all of data at once
    res <- dbSendQuery(con, "select * from emp")

    # fetch all results
    fetch(res)

    # or a chunk at a time
    fetch(res, n = 5)

    # describing the schema for the emp table using dbGetInfo
    dbGetInfo(res, what = 'fields')

    # clear the result
    dbClearResult(res)

    # disconnect from the database
    dbDisconnect(con)

    # free the driver object
    dbUnloadDriver(drv)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
