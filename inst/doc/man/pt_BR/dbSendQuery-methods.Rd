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
Executar uma Instrução em uma Determinada Conexão de Banco de Dados
}
\description{
Estes métodos são implementações simples das funções genéricas
   correspondentes, exceto pelo método \code{execute}, que é uma
   extensão DBI específica do ROracle.
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
Um objeto \code{OraConnection}.
}
  \item{statement}{
Um vetor de caractere de comprimento 1 com a instrução SQL.
}
  \item{res}{
Um objeto \code{OraResult}.
}
  \item{data}{
Um \code{data.frame} que especifica dados de binding
}
  \item{prefetch}{
Um valor lógico que especifica se o ROracle usa buffers de pré-extração ou uma
    extração de array para recuperar dados do servidor. Se \code{TRUE}, o ROracle 
    usará buffers de pré-extração do OCI para recuperar dados adicionais do servidor, com isso 
    economizando a memória exigida em RODBI/ROOCI ao alocar um buffer de linha única 
    para extrair os dados do OCI. O uso de pré-extração resulta em uma chamada de extração para cada
    linha. Se \code{FALSE} (o padrão), o ROracle usará uma extração de array para 
    recuperar os dados.
}
  \item{bulk_read}{
Um valor inteiro que indica o número de linhas a serem extraídas por vez. O 
    valor padrão é 1000L. Quando a opção de pré-extração é selecionada, a memória é 
    alocada para buffers de pré-extração e o OCI extrai o número especificado de linhas 
    por vez. Quando a pré-extração não é usada, que é o padrão, a memória é 
    alocada em buffers de definições RODBI/ROOCI. A definição dessa opção com um valor grande 
    resulta em mais memória alocada com base no número de colunas na 
    lista de seleção e nos tipos de colunas. Para uma coluna de caractere de tipo, 
    os buffers de definição serão alocados usando a largura máxima vezes a largura máxima 
    de NLS. Um aplicativo deve ajustar esse valor com base no resultado da consulta.
     Um valor maior beneficia as consultas que retornam um resultado grande. O 
    aplicativo pode ajustar esse valor conforme necessário.
}
  \item{bulk_write}{
Um valor inteiro que indica o número de linhas a serem gravadas por vez. O
    valor padrão é 1000L. Quando um valor bulk_write é especificado, a memória é 
    alocada para buffers e o OCI grava várias linhas de uma vez. Se o
    argumento bulk_write não for usado, o valor padrão será usado para 
    alocar memória para os buffers de binding. A definição de \code{bulk_write} com um valor
    grande resultará em mais memória alocada com base no número de colunas
    na lista de inserção e nos tipos de colunas.
}
  \item{\dots}{
Não utilizado no momento.
}
}
\value{
\item{dbSendQuery}{
    Um objeto \code{OraResult} cuja classe estende \code{DBIResult}. Esse 
    objeto é usado para extrair dados de um banco de dados, usando a função 
    \code{fetch}.
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
      Essa função executa uma instrução de consulta e extrai os dados resultantes
      do banco de dados. Não a utilize para chamar consultas PL/SQL.
    }
    \item{dbSendQuery}{
      Essa função executa uma instrução de consulta e retorna um conjunto de resultados para o 
      aplicativo. O aplicativo então pode executar operações com base no conjunto de resultados.
      Não o utilize para chamar consultas PL/SQL.
    }
     \item{oracleProc}{
      Essa função executa um procedimento armazenado PL/SQL ou uma instrução de consulta
      de função e retorna o resultado.
    }
    \item{dbClearResult}{
      Essa função libera recursos utilizados pelo conjunto de resultados.
    }
    \item{dbGetException}{
      Essa função recupera informações de erros.
    }
    \item{execute}{
      Essa função executa a instrução de consulta especificada.
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
