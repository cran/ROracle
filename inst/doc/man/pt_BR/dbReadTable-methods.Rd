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
Funções de Conveniência para Manipular Tabelas RDBMS
}
\description{
Estas funções simulam seus equivalentes no R 
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} e
  \code{names}.
  A diferença é que elas geram um código que é remotamente executado em
  um mecanismo de banco de dados.
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
Um objeto de conexão do banco de dados \code{OraConnection}.
}
  \item{name}{
Uma string de caracteres que distingue maiúsculas e minúsculas que especifica um nome da tabela.
}
  \item{schema}{
Uma string de caracteres que distingue maiúsculas e minúsculas que especifica o nome de um esquema (ou um
    vetor de strings de caracteres para \code{dbListTables}).
}

  \item{row.names}{
No caso de \code{dbReadTable}, esse argumento pode ser uma string, um
    índice ou um vetor lógico que especifica a coluna na tabela DBMS a
    ser usada como \code{row.names} no data.frame de saída (um(a) \code{NULL}
    especifica que nenhuma coluna deve ser usada como \code{row.names} na
    saída). O padrão é \code{NULL}.
    No caso de \code{dbWriteTable}, esse argumento deve ser um valor
    lógico que especifica se o(a) \code{row.names} deve ser a saída para a
    tabela DBMS de saída; se \code{TRUE}, uma coluna extra, cujo nome é 
    \code{"row.names"} será adicionada à saída. O padrão é
    \code{FALSE}.
}
  \item{value}{
Um(a) \code{data.frame} contendo os dados a serem gravados em uma tabela. (Consulte
    a seção Detalhes para ver os tipos de colunas suportadas.)
}
  \item{overwrite}{
Um valor lógico que especifica se uma tabela será substituída
    ou não. O padrão é \code{FALSE}.
}
  \item{append}{
Um valor lógico que especifica se uma tabela existente será acrescentada
    no DBMS. O padrão é \code{FALSE}.
}
  \item{ora.number}{
Um valor lógico que especifica se uma tabela será criada com as colunas
    \code{NUMBER} ou \code{BINARY_DOUBLE} do Oracle ao gravar dados
    numéricos. Especifique \code{TRUE} para criar uma tabela com os valores Oracle \code{NUMBER} 
    ou especifique \code{FALSE} para criar uma tabela com os valores Oracle
    \code{BINARY_DOUBLE}. O valor padrão é \code{TRUE}.
    Especifique \code{FALSE} se um ou mais dados valores de dados numéricos forem
    \code{NaN}.
}
  \item{purge}{
Um valor lógico que especifica se a opção \code{PURGE} será adicionada à
    instrução SQL \code{DROP TABLE}.
}
  \item{all}{
Um valor lógico que especifica se todos os esquemas serão verificados.
}
  \item{full}{
Um valor lógico que especifica se serão gerados nomes de esquemas. Quando o argumento
    \code{all} for \code{TRUE}, a saída será um vetor contendo os nomes de
    esquemas seguidos pelos nomes das tabelas. Usar \code{matrix(..., ncol = 2)}
    na saída gerará uma matriz em que cada linha corresponderá a uma
    tabela e as colunas representarão os nomes de esquemas e os nomes de tabelas
    respectivamente.
}
  \item{\dots}{
não utilizado no momento.
}
}





   


\details{
Os nomes de tabelas, esquemas e colunas distinguem maiúsculas e minúsculas, por exemplo, os nomes das
  tabelas \code{ABC} e \code{abc} não são o mesmo. Todos os nomes de objetos
  do esquema do banco de dados não devem incluir aspas duplas, pois eles ficam entre
  aspas duplas quando a instrução SQL correspondente é gerada.
  Os métodos \\pkg{ROracle} como \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} e \code{dbWriteTable} usam o seguinte mapeamento
  entre os tipos de dados \R e Oracle:
  \itemize{
    \item \code{logical} e \code{integer} mapeiam para o Oracle \code{INTEGER}
    \item \code{numeric} mapeia para o Oracle \code{NUMBER} se o argumento
    \code{ora.number} for \code{TRUE} ou o Oracle \code{BINARY_DOUBLE} se
    \code{FALSE}
    \item \code{character} mapeia para o Oracle \code{VARCHAR2(4000)}
    \item \code{Date} e \code{POSIXct} mapeiam para o Oracle \code{DATE}
    \\pkg{ROracle} - o pacote ROracle
    \R - a aplicação R
    \code{POSIXct} - a classe POSIXct
    \code{TIMESTAMP}
    \code{TIMESTAMP WITH TIME ZONE}
    \code{TIMESTAMP WITH LOCAL TIME ZONE}
    \item \code{difftime} mapeia para o Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} de \code{raw} vetores mapeiam para o Oracle \code{RAW(2000)}
    \item outros tipos \R como \code{factor} são convertidos para
    \code{character}
  }
   O ROracle retorna valores das colunas do banco de dados que são de tipos de dados: data,
   timestamp, timestamp com fuso horário e timestamp com tipos de dados do
   fuso horário local no formato POSIXct do R. POSIXct se refere a uma
   hora que é internamente armazenada como o número de segundos desde o início de
   1970 em UTC. O número de segundos são trocados do driver R e ROracle no
   formato duplo do ponto flutuante. Na representação POSIXct R usa a variável de ambiente
   TZ ou mapeia a variável de ambiente do fuso horário do SO para a sua
   própria variável, portanto, a data será exibida nesse formato de fuso horário.
   É possível inserir dados nas colunas dos 4 tipos de dados listados acima usando uma
   string com o formato correto ou a representação POSIXct. Os dados da string são
   especificados ao banco de dados diretamente e o ROracle confia no banco de dados para convertê-los
   na representação de data e hora. Os dados POSIXct serão convertidos no descritor
   de DateTime interno do Oracle adicionando o início do UTC de 1970 ao
   número de segundos obtidos de R. Qualquer variável POSIXct na instrução de inserção
   está vinculada como SQLT_TIMESTAMP_TZ.
   Quando esses tipos de dados são selecionados no Oracle, eles são convertidos no formato POSIXct
   subtraindo o início do UTC de 1970. Quando o cliente e o banco de dados do ROracle
   tiver arquivos com versão de fuso horário diferentes e uma aplicação usar os
   tipos de dados do fuso horário, recomenda-se que eles iguais, pois  região
   pode ter alterado seu fuso. O ROracle reportará um erro nessa situação, pois
   ele pode causar a corrupção dos dados ou a perda de informações ao operar nesses
   tipos de dados.
   As colunas com data e tipo de dados de timestamp são extraídas pelo ROracle usando
   o tipo de dados SQLT_TIMESTAMP. As colunas com timestamp com fuso horário e
   timestamp com tipos de dados de fuso horário local são extraídas usando
   o tipo de dados SQLT_TIMESTAMP_TZ. As colunas de fuso horário de tipos de dados com fuso horário
   local são submetidas à conversão para o fuso horário de sessão que a aplicação R executa,
   portanto, definir o TZ do ambiente do fuso horário no R afetará os valores dos
   dados nessa coluna. O driver ROracle não mapeia a variável de ambiente
   TZ para o fuso horário da sessão e
   não emite uma DDL alternativa para definir o fuso horário da sessão. Para extrair dados
   das colunas com timestamp com fuso horário e timestamp com
   fuso horário local o cliente e o servidor devem ter o mesmo arquivo de dados
   de fuso horário, caso contrário, um erro será reportado.
   O exemplo a seguir mostra o efeito de alterar o fuso horário no ambiente R:
   \\preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # Seleção e exibição de dados
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
  Além disso, \code{dbWriteTable} sempre confirma automaticamente uma transação atual, bem como
  os dados que ela insere, ou seja, ela age como uma instrução DDL mesmo que
  acrescente linhas a uma tabela já existente.
}
\value{
Um \code{data.frame} no caso de \code{dbReadTable};
  um \code{vector} no caso de \code{dbListTables} e
  \code{dbListFields};
  um \code{logical} no caso de \code{dbExistsTable} indicando se
  se a tabela existe;
  caso contrário, \code{TRUE} quando a operação for concluída com sucesso ou uma
  exceção.
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
