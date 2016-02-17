\name{dbConnect-methods}
\docType{methods}
\alias{dbConnect}
\alias{dbDisconnect}
\alias{dbConnect,OraDriver-method}
\alias{dbConnect,ExtDriver-method}
\alias{dbDisconnect,OraConnection-method}
\title{
Oracle DBMS에 대한 접속 객체 생성
}
\description{
이 메소드는 해당하는 일반 함수를 간단히 구현한
   것입니다.
}
\usage{
\S4method{dbConnect}{OraDriver}(drv, username = "", password = "", dbname = "", prefetch = FALSE,
          bulk_read = 1000L, bulk_write = 1000L, stmt_cache = 0L,
          external_credentials = FALSE, sysdba = FALSE, ...)
\S4method{dbConnect}{ExtDriver}(drv, prefetch = FALSE, bulk_read = 1000L,
          bulk_write = 1000L, stmt_cache = 0L,
          external_credentials = FALSE, sysdba = FALSE, ...)
\S4method{dbDisconnect}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
\code{OraDriver} 또는 \code{ExtDriver} 클래스의 객체입니다.
}
  \item{conn}{
\code{OraConnection}(으)로 생성된 \code{dbConnect} 객체입니다.
}
  \item{username}{
사용자 이름을 지정하는 문자열입니다.
}
  \item{password}{
비밀번호를 지정하는 문자열입니다.
}
  \item{dbname}{
접속 식별자를 지정하는 문자열입니다. 자세한 내용은
    Oracle Database Net Services Administrator's Guide의 8장
    Configuring Naming Methods를 참조하십시오. 이 문자열은 SQL*Plus 접속
    문자열에서 '@' 기호 다음에 오는 부분과 동일합니다.
    Oracle Wallet을 사용하여 사용자 이름과 비밀번호를 저장하는
    경우 이 문자열은 전자 지갑 매핑을 생성하는 데 사용된 접속
    문자열이어야 합니다. 자세한 내용은 Oracle Database Security Guide의 3장
    Configuring Clients to Use the External Password Store를 참조하십시오.
    Oracle TimesTen IMDB 인스턴스에 대한 접속 식별자는 OCI tnsname 또는
    간편한 접속 이름 지정 규칙 방법을 통해 지원됩니다. OCI의 TimesTen 접속에 대한
    자세한 내용은 TimesTen In-Memory C Developer's Guide의 3장 TimesTen
    Support for OCI를 참조하십시오.
    아래의 예에서는 접속 식별자를 지정하는 다양한 방법을 보여줍니다.
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
    할당되고 OCI가 해당 개수의 행을 한 번에 인출합니다.
    사전 인출이 사용되지 않은 경우(기본값) 메모리가
    RODBI/ROOCI 정의 버퍼에 할당됩니다. 이를 큰 값으로 설정하면 선택한
    목록의 열 수 및 열 유형을 기반으로 더 많은 메모리가
    할당됩니다. 문자 유형 열의 경우 NLS 최대 너비의 몇 배에
    달하는 최대 너비를 사용하여 정의 버퍼가 할당됩니다. 애플리케이션은
    쿼리 결과에 따라 이 값을 조정해야 하며, 큰 값을 사용하면 큰 결과를
    반환하는 질의 이점을 얻을 수 있습니다. 애플리케이션은 필요에 따라
    이 값을 조정할 수 있습니다.
}
  \item{bulk_write}{
한 번에 삽입, 업데이트 또는 삭제할 행 수를 나타내는 정수 값입니다.
    기본값은 1000L입니다. 인수에서 bulk_write 값이
    제공된 경우 버퍼에 메모리가 할당되고 OCI가 해당 개수의 행을
    한 번에 씁니다. bulk_write 인수가 제공되지 않은 경우
    바인드 버퍼에 대한 메모리를 할당하는 데 기본값 1000이 사용됩니다.
    이를 큰 값으로 설정하면 삽입 목록의 열 수 및 열 유형을 기반으로
    더 많은 메모리가 할당됩니다.
}
  \item{stmt_cache}{
캐시할 문 수를 나타내는 정수 값입니다. 문을 다시 구문 분석하지
    않아도 커서를 사용할 준비가 되어 있음을 의미합니다. 기본값은
    0L입니다. stmt_cache 값이 0L보다 크면 \code{prefetch} 값이 TRUE로
    설정되어 있어야 합니다.
}
  \item{external_credentials}{
TRUE 또는 FALSE를 나타내는 논리 값입니다. TRUE로 설정된 경우 ROracle은
    접속에서 외부 인증서로 인증된 OCI 세션을 시작합니다.
    기본값은 FALSE입니다.
}
  \item{sysdba}{
TRUE 또는 FALSE를 나타내는 논리 값입니다. TRUE로 설정된 경우
    ROracle은 접속에서 SYSDBA 권한으로 OCI 세션을 시작합니다. 기본값은
    FALSE입니다.
}
  \item{\dots}{
현재 사용되지 않습니다.
}
}
\value{
\item{dbConnect}{
    해당 클래스가 \code{OraConnection}을(를) 확장하는 \code{DBIConnection} 객체입니다. 
    이 객체는 데이터베이스에서 SQL 질의를 실행하는 데 사용됩니다.
  }
  \item{dbDisconnect}{
    작업의 성공 여부를 나타내는 논리 값입니다.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbConnect}{
      Establishes a connection between R and an Oracle Database server.
    }
    \item{dbDisconnect}{
      Frees resources used by the connection object.
    }
  }
}
      





           
\details{
\\describe{
    \item{dbConnect}{
      이 접속 객체는 데이터베이스에서 작업을 실행하는 데 사용됩니다.
      \code{prefetch}이(가) TRUE로 설정된 경우 OCI 사전 인출 버퍼를 사용하여
      서버에서 추가 데이터를 검색할 수 있습니다.
      \code{bulk_read} 인수는 한 번에 인출할 수 있는 행 수를 나타내는
      정수 값을 설정하는 데 사용됩니다.
      \code{bulk_write} 인수는 한 번에 쓸 수 있는 행 수를 나타내는
      정수 값을 설정하는 데 사용됩니다.
      \code{stmt_cache} 인수는 명령문 캐싱 기능을 사용으로 설정하거나 사용 안함으로 설정하는 데
      사용됩니다. 해당 값은 명령문 캐시 크기를 지정합니다.
      \code{external_credentials} 인수는 접속에서 외부 인증서로 인증된 OCI 세션을
      시작하는 데 사용됩니다.
      \code{sysdba} 인수는 접속에서 SYSDBA 권한으로 OCI 세션을
      시작하는 데 사용됩니다.
      \code{ExtDriver} 드라이버를 사용하여 접속을 설정할 때 인증서를 지정하는
      인수를 사용하지 않습니다. 이 모드의 접속은
      단일 객체입니다. 즉, \code{dbConnect}에 대한 모든 호출은
      동일한 접속 객체를 반환합니다.
    }
    \item{dbDisconnect}{
      이 구현은 R과 데이터베이스 서버 사이의 접속을
      해제합니다. 접속 객체에서 사용된 모든 리소스를 해제합니다. 이 접속
      객체와 연관된 모든 결과 집합을 해제합니다.
    }
  }
}
\section{References}{
  For the Oracle Database documentation see
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
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    ## Create an Oracle Database instance and create one connection on the
    ## same machine.
    drv <- dbDriver("Oracle")

    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection to a
    ## remote database using the SID in the connect string. 
    drv <- dbDriver("Oracle")

    ## Refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.
    host <- "myhost"
    port <- 1521
    sid <- "mysid"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
        "(CONNECT_DATA=(SID=", sid, ")))", sep = "")

    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection to a
    ## remote database using the service name.
    drv <- dbDriver("Oracle")

    ## Refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.

    host <- "myhost"
    port <- 1521
    svc <- "mydb.example.com"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
      "(CONNECT_DATA=(SERVICE_NAME=", svc, ")))", sep = "")
    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Use Oracle Wallet authentication.
    con <- dbConnect(drv, username ="", password="", 
    dbname = "<wallet_connect_string>")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Connect to a TimesTen IMDB instance using the easy connect 
    ## naming method where SampleDb is a direct driver TimesTen DSN.
    con <- dbConnect(drv, username ="scott", password="tiger", 
                     dbname = "localhost/SampleDb:timesten_direct")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from dual")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Connect to an extproc (this assumes that the driver has already
    ## been initialized in the embedded R code by passing an external
    ## pointer representing the extproc context).
    con <- dbConnect(Extproc())

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from dual")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Create connection with SYSDBA privileges.
    con <- dbConnect(drv, username ="scott", password="tiger",
                     sysdba = TRUE)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")
    
    ## Use OS authentication as an example of external authentication
    ## Make sure that databse user exist to allow an OS authentication

    ## Create connection authenticated with external credentials.
    con <- dbConnect(drv, username ="", password="",
                     external_credentials = TRUE)
    
    ## Above dbConnect() used OS credentials to connect with database.

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
