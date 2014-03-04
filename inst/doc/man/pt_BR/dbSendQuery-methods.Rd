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
Executar uma instrução em determinada conexão de banco de dados
}
\description{
Estes métodos são implementações simples das funções genéricas
   correspondentes, exceto pelo método \code{execute}, que é uma extensão DBI específica para ROracle.
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
um objeto \code{OraConnection}.
}
  \item{statement}{
um vetor de caractere de comprimento 1 com a instrução SQL.
}
  \item{res}{
um objeto \code{OraResult}.
}
  \item{data}{
um data.frame especificando os dados de bind
}
  \item{prefetch}{
um valor lógico que indica TRUE ou FALSE. Quando definido como TRUE, o ROracle usará
    buffers de pré-extração do OCI para recuperar dados adicionais do servidor, salvando, assim,
    a memória necessária no RODBI/ROOCI alocando um único buffer de linha para extrair 
    os dados do OCI. Usando os resultados de pré-extração em uma chamada de extração para cada linha. Por
    padrão, a pré-extração é FALSE e a extração da array é usada para recuperar os dados do
    servidor.
}
  \item{bulk_read}{
um valor inteiro que indica o número de linhas a serem extraídas por vez. O padrão
    é 1000L. Quando a opção de pré-extração for selecionada, a memória será alocada para
    buffers de pré-extração e o OCI extrairá essa quantidade de linhas por vez. Quando a pré-extração não for 
    usada (padrão) a memória será alocada nos buffers de definição do RODBI/ROOCI. Definir
    essa opção para um valor grande resultará em mais memória alocada com base no 
    número de colunas na lista de seleção e nos tipos de colunas. Para uma coluna
    de caracteres, os buffers de definição são alocados usando a largura máxima vezes 
    a largura máxima de NLS. A aplicação deve ajustar esse valor com base no resultado 
    da consulta w um valor maior beneficiará as consultas que retornarem um
    resultado grande. A aplicação pode ajustar esse valor conforme necessário.
}
  \item{\dots}{
não utilizado no momento.
}
}
\value{
\item{dbSendQuery}{
    um objeto \code{OraResult} cuja classe estende \code{DBIResult}. Esse 
    objeto é usado para extrair dados do banco de dados, usando a função 
    \code{fetch}.
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
      A implementação executa a instrução de consulta e extrai 
      os dados de resultado do banco de dados. 
    }
    \item{dbSendQuery}{
      A implementação executa a instrução de consulta e retorna 
      o conjunto de resultados para a aplicação. Agora, a aplicação pode executar as operações 
      no conjunto de resultados. 
    }
    \item{dbClearResult}{
      A implementação libera os recursos ocupados pelo conjunto de resultados.
    }
    \item{dbGetException}{
      A implementação recupera as informações de erro.
    }
    \item{execute}{
      A implementação executa a instrução de consulta.
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
