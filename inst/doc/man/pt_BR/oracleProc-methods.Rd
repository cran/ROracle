\name{oracleProc-methods}
\docType{methods}
\alias{oracleProc}
\alias{oracleProc,OraConnection,character-method}
\title{
Executar um Procedure ou Função PL/SQL Armazenado(a)
}
\description{
Este método é uma implementação simples da função genérica
   correspondente.
}
\usage{
\S4method{oracleProc}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
}
\arguments{
  \item{conn}{
Um objeto \code{OraConnection}.
}
  \item{statement}{
Um vetor de caractere de comprimento 1 com a instrução SQL.
}
  \item{data}{
Um data.frame especificando dados de bind.
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
Uma lista de objetos de frame de dados que contém os registros extraídos do
  banco de dados.
\\details{
  O número de registros recuperados se baseia nos parâmetros \code{OUT} e \code{IN OUT}
  do procedure ou função PL/SQL armazenado(a) no argumento 
  \code{statement}. 
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
