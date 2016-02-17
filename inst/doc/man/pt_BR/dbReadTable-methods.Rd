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
Essas funções imitam suas contrapartes R, exceto que elas geram
  código que é executado remotamente em um mecanismo de banco de dados:
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} e
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
Um objeto de conexão do banco de dados \code{OraConnection}.
}
  \item{name}{
Uma string de caracteres que distingue maiúsculas e minúsculas que especifica um nome da tabela.
}
  \item{schema}{
Uma string de caracteres que distingue maiúsculas e minúsculas que especifica o nome de um esquema (ou um
    vetor de strings de caracteres para \code{dbListTables}).
}
  \item{date}{
Um flag booliano que indica se deve ser usado date ou DateTimep.
    Por padrão, DateTime será usado no lugar de timestamp.
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
Os nomes de tabela, esquema e coluna distinguem maiúsculas de minúsculas, por exemplo, os nomes
  de tabela \code{ABC} e \code{abc} não são iguais. Todos os nomes de objeto de esquema
  de banco de dados não devem incluir aspas duplas, uma vez que eles são colocados entre
  aspas duplas quando a instrução SQL correspondente é gerada.
Os seguintes atributos são usados para mapear as colunas BLOB, CLOB, NCLOB, NCHAR, VARCHAR2,
   NVARCHAR2, CHAR, TIMESTAMP WITH TIME ZONE e TIMESTAMP WITH LOCAL TIME ZONE
   corretamente em \code{dbWriteTable}:   
   1) Nome do Atributo: \code{ora.type}
   Este atributo indica o tipo de coluna subjacente e pode ser 
   "CLOB", "BLOB", "CHAR", "VARCHAR2" ou "RAW". O usuário pode especificar
   TIMESTAMP, DATE, TIMESTAMP WITH TIME ZONE ou qualquer outro tipo de coluna
   suportado pelo Oracle Database. O ROracle não faz parsing do valor, ele é
   validado pelo banco de dados. O usuário pode fornecer um dos seguintes
   valores para \code{ora.type}: CLOB, BLOB, CHAR, TIMESTAMP WITH TIME
   ZONE, TIMESTAMP WITH LOCAL TIME ZONE e fractional_seconds_precision.
   2) Nome do Atributo: \code{ora.encoding}
   Quando UTF-8 é especificado, o banco de dados usa NCLOB, NCHAR ou NVARCHAR com base em 
   \code{ora.type}.
   3) Nome do Atributo: \code{ora.maxlength}
   É possível especificar o tamanho máximo das colunas CHAR, VARCHAR, NCHAR, NVARCHAR2 ou
   RAW. Para outros tipos de dados, \code{ora.maxlength} não se
   aplica e é ignorado. Os valores padrão a seguir são usados para
   determinados tipos de dados quando \code{ora.maxlength} não é especificado.
   CHAR                                       2000
   NCHAR                                      1000
   VARCHAR2                                   4000
   NVARCHAR2                                  2000
   RAW                                        2000
  4) Nome do Atributo: \code{ora.fractional_seconds_precision}
   É possível especificar a parte fracionária do campo de data e hora SECOND das colunas
   TIMESTAMP, TIMESTAMP WITH TIME ZONE e TIMESTAMP WITH LOCAL TIME ZONE.
   Pode ser um número na faixa de 0 a 9. O valor padrão é 6.
  Métodos \\pkg{ROracle} como \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} e \code{dbWriteTable} usam o seguinte mapeamento
  entre os tipos de dados \R e Oracle:
  \itemize{
   \item \code{logical} e \code{integer} mapeiam para Oracle \code{INTEGER}
    \item \code{numeric} mapeará para Oracle \code{NUMBER} se o argumento
    \code{ora.number} for \code{TRUE} ou Oracle \code{BINARY_DOUBLE} se
    \code{FALSE}
    \item \code{character} mapeará para Oracle \code{CLOB} se o atributo
    \code{ora.type} for \code{"CLOB"} ou Oracle \code{NCLOB} se o atributo
    \code{ora.type} for \code{"CLOB"} e \code{ora.encoding} for \code{"UTF-8"}
    ou Oracle \code{CHAR(ora.maxlength)} se o atributo \code{ora.type} for 
    \code{"CHAR"} ou Oracle \code{NCHAR(ora.maxlength)} se o atributo 
    \code{ora.type} for \code{"CHAR"} e \code{ora.encoding} for \code{"UTF-8"}
    ou Oracle \code{NVARCHAR2(ora.maxlength)} se o atributo \code{ora.encoding}
    for \code{"UTF-8"} ou Oracle \code{VARCHAR2(ora.maxlength)}
    \item \code{Date} e \code{POSIXct} mapeia para Oracle \code{DATE}
    \\pkg{ROracle} - o pacote ROracle
    \R - o aplicativo R
    \item \code{POSIXct} mapeará para Oracle 
    \code{TIMESTAMP WITH TIME ZONE(ora.fractional_seconds_precision)} se o 
    atributo \code{ora.type} for \code{"TIMESTAMP WITH TIME ZONE"} ou Oracle 
    \code{TIMESTAMP WITH LOCAL TIME ZONE(ora.fractional_seconds_precision)} se
    o atributo \code{ora.type} for \code{"TIMESTAMP WITH LOCAL TIME ZONE"} ou
    Oracle \code{TIMESTAMP(ora.fractional_seconds_precision)} e se 
    \code{Date} for \code{FALSE} 
    \item \code{difftime} mapeia para Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} de \code{raw} vetores mapearão para Oracle \code{BLOB} se 
    o atributo \code{ora.type} for \code{"BLOB"} ou Oracle 
    \code{RAW(ora.maxlength)}
    \item outros tipos de \R como \code{factor} são convertidos para 
    \code{character}
  }
   ROracle retorna valores das colunas do banco de dados que são do tipo de dados: data,
   time stamp, time stamp com fuso horário e time stamp com fuso horário local
   os tipos de dados no formato POSIXct do R. POSIXct refere-se a um
   horário que é armazenado internamente como o número de segundos desde o início de
   1970 em UTC. O número de segundos é intercambiado do driver R e ROracle no
   formato duplo de ponto flutuante. Na representação POSIXct, R usa a variável de ambiente TZ
   ou mapeia a variável de ambiente de fuso horário do SO para o seu
   próprio; portanto, a data será exibida neste formato de fuso horário.
   É possível inserir dados em colunas dos quatro tipos de dados listados acima usando uma
   string com o formato correto ou a representação POSIXct. Os dados da string são
   passados ao banco de dados diretamente e o ROracle conta com o banco de dados para convertê-los
   na representação de data e hora. O driver ROracle converte a representação POSIXct
   em uma representação de string usando o formato
   "\%Y-\%m-\%d \%H:\%M:\%OS6" em uma estrutura de dados que é usada para operações DML.
   Os dados nesse formato correspondem a NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF" e são convertidos em SQLT_TIMESTAMP_LTZ para serem
   vinculados ao banco de dados Oracle. Uma classe intermediária "datetime" é criada,
   a qual representa dados de caracteres para o driver ROracle internamente.
   As colunas que têm um tipo de dados de data e time stamp são extraídas pelo ROracle usando
   o tipo de dados SQLT_TIMESTAMP. As colunas que têm tipos de dados de time stamp com fuso horário ou
   um time stamp com fuso horário local são extraídas usando
   o tipo de dados SQLT_TIMESTAMP_LTZ. As colunas do tipo de dados time stamp com fuso horário local
   sofrem conversão para o fuso horário da sessão na qual o aplicativo R é executado;
   portanto, a definição do ambiente de fuso horário TZ no R afetará os valores de dados
   nesta coluna. O driver ROracle mapeia a variável de ambiente TZ para
  o fuso horário da sessão e emite uma DDL alternativa para definir o fuso horário da sessão
   quando a conexão é feita com o banco de dados.
   Para extrair dados de colunas com um timestamp com fuso horário ou um timestamp
   com fuso horário local, o cliente e o servidor deverão ter o mesmo arquivo de dados de fuso horário,
   caso contrário um erro será reportado.
   Quando esses tipos de dados são selecionados no banco de dados, eles são convertidos para
   a representação de string usando o NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF" que corresponde a "\%Y-\%m-\%d \%H:\%M:\%OS6"
   no R. Uma classe intermediária "datetime" é criada
   para representar esses dados de caracteres no driver ROracle. O driver ROracle então
   os converte em POSIXct usando a função as.POSIXct(). Um aplicativo R
   vê os dados na forma POSIXct na estrutura de dados.
   \\preformatted{
fuso horário da sessão R:
 R tem o conceito de um fuso horário no qual opera o mecanismo de R. O fuso
 horário pode ser definido para uma string como 'PST8PDT', 'America/Los_Angeles' e assim por diante.
 Essas strings são autoexplicativas e especificam o fuso horário no qual a
 sessão está operando.
 O fuso horário da sessão R pode ser definido de duas formas:
 1. Inserindo o seguinte na linha de comandos do Linux ou Unix antes de iniciar
    R:
    setenv TZ = America/Los_Angeles on Linux/UNIX
    OBSERVAÇÃO: Não use essa opção no Windows, pois ele não permite
          definir nomes de fusos horários compatíveis com o Oracle para a variável de ambiente TZ.
 2. Inserindo o seguinte no prompt do R:
    Sys.setenv(TZ = "PST8PDT")
 Recomendamos o uso da opção 2, pois o script do R funciona sem
 problemas tanto no Linux/Unix quanto no Windows. A opção 2 também permite que você
 especifique nomes de fusos horários compatíveis com o Oracle mesmo no Windows.
 O fuso horário da sessão do R determina o fuso horário de todos os tipos de data-hora não qualificados de fuso horário POSIXct.
 Ele também é o fuso horário para o qual todos os
 tipos de data-hora qualificados são convertidos quando exibidos por R.
 O exemplo a seguir demonstra isso.
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
Observe que há um pressuposto de que os timestamps não qualificados também estão no fuso horário da sessão do R
quando são exibidos por R. Naturalmente, o R também é inteligente o
bastante para fazer a determinação de se o horário se enquadra em PST ou PDT
com base em quando começa o horário de verão dos EUA, e exibe PST ou PDT
de acordo com a ocasião.
O exemplo a seguir mostra isso de forma mais óbvia.
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
Observe que parte-se do pressuposto de que todos os timestamps não qualificados de fuso horário estão no
fuso horário da sessão. Porém, mesmo os timestamps qualificados de fuso horário
são convertidos para o fuso horário da sessão e exibidos. Observe que todos os
valores são exibidos por R no fuso horário da sessão do R (com o nome do
fuso horário também modificado para EST ou EDT para dar conta do
horário de verão, conforme aplicável). Consulte as Classes de Data-Hora em
http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html
e os fusos horários em:
http://stat.ethz.ch/R-manual/R-devel/library/base/html/timezones.html
para ver detalhes sobre como o R lida com datas e horários e com horários e fusos horários)
Vamos ver um exemplo no qual usamos um nome de fuso horário mais longo
(frequentemente referido como um 'Olson Name'), em oposição a uma abreviação.
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
Observe que, em um caso como esse, o R não usa o nome longo quando os
valores são exibidos. Em vez disso, ele ainda exibe os valores usando
as abreviações "PST" e "PDT". Isso é significativo, porque a Oracle
não necessariamente gosta dessas abreviações. Por exemplo, um banco de dados da Oracle
não reconhece "PDT" como um fuso horário válido. Consulte "Fuso horário do R
e fuso horário da sessão do Oracle" para ver detalhes sobre fusos horários válidos.
}
   O exemplo abaixo mostra o efeito de alterar o fuso horário no ambiente do
   R:
   \\preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # Selecionando dados e exibindo-os
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
  Além disso, \code{dbWriteTable} sempre confirma automaticamente uma transação atual, além
  dos dados que insere, isto é, atua como instrução DDL mesmo que
  anexe linhas a uma tabela já existente.
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
