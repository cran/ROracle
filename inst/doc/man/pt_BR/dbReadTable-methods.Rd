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
Os nomes de tabela, esquema e coluna fazem distinção entre maiúsculas e minúsculas; por exemplo,
  os nomes de tabela \code{ABC} e \code{abc} não são iguais. Todos os nomes de objeto de esquema
  de banco de dados não devem incluir aspas duplas, já que eles são colocados
  entre aspas duplas quando a instrução SQL correspondente é gerada.
   Os seguintes atributos são usados para mapear as colunas BLOB, CLOB, NCLOB, NCHAR, VARCHAR2,
   NVARCHAR2, CHAR, TIMESTAMP WITH TIME ZONE e TIMESTAMP WITH LOCAL TIME ZONE
   corretamente no \code{dbWriteTable}:
   1) Nome do Atributo: \code{ora.type}
   Esse atributo indicará o tipo da coluna subjacente e poderá ter
   "CLOB", "BLOB", "CHAR", "VARCHAR2" ou "RAW". Podemos permitir que o usuário especifique
   time stamp, Date, time stamp com fuso horário ou qualquer outro tipo de coluna
   suportado pelo Oracle DB. Ele não será analisado pelo ROracle e deixará o BD
   validá-lo. Os seguintes valores \code{ora.type} podem ser fornecidos pelo usuário:
   clob, blob, char, time stamp com fuso horário, time stamp com fuso horário local
   e fractional_seconds_precision.
   2) Nome do Atributo: \code{ora.encoding}
   Quando UTF-8 for especificado, ele usará NCLOB, NCHAR ou NVARCHAR com base em
   "ora.type".
   3) Nome do Atributo: \code{ora.maxlength}
   É possível especificar o tamanho máximo das colunas CHAR, VARCHAR, NCHAR, NVARCHAR2 ou
   RAW. Para outros tipos de dados, não é aplicável e será ignorado.
   Os seguintes valores padrão são usados para determinados tipos de dados quando
   \code{ora.maxlength} não foi especificado \code{NULL}
   CHAR                                       2000
   NCHAR                                      1000
   VARCHAR2                                   4000
   NVARCHAR2                                  2000
   RAW                                        2000
   4) Nome do Atributo: \code{ora.fractional_seconds_precision}
   É possível especificar a parte fracionária do campo de data/hora SECOND das
   colunas TIMESTAMP, TIMESTAMP WITH TIME ZONE e TIMESTAMP WITH LOCAL
   TIME ZONE. Pode ser um número na faixa de 0 a 9. O valor padrão é 6.
  Os métodos do \\pkg{ROracle}, como \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} e \code{dbWriteTable}, usam o seguinte mapeamento
  entre os tipos de dados \R e Oracle:
  \itemize{
    \item \code{logical} e \code{integer} são mapeados para Oracle \code{INTEGER}
    \item \code{numeric} será mapeado para Oracle \code{NUMBER} se o argumento
    \code{ora.number} for \code{TRUE} ou Oracle \code{BINARY_DOUBLE} se
    \code{FALSE}
    \item \code{character} será mapeado para Oracle \code{CLOB} se o atributo 
    \code{ora.type} for \code{"CLOB"} ou Oracle \code{NCLOB} se o atributo
    \code{ora.type} for \code{"CLOB"} e \code{ora.encoding} for \code{"UTF-8"}
    ou Oracle \code{CHAR(ora.maxlength)} se o atributo \code{ora.type} for 
    \code{"CHAR"} ou Oracle \code{NCHAR(ora.maxlength)} se o atributo 
    \code{ora.type} for \code{"CHAR"} e \code{ora.encoding} for \code{"UTF-8"}
    ou Oracle \code{NVARCHAR2(ora.maxlength)} se o atributo \code{ora.encoding}
    for \code{"UTF-8"} ou Oracle \code{VARCHAR2(ora.maxlength)}
    \item \code{Date} e \code{POSIXct} são mapeados para Oracle \code{DATE}
    \\pkg{ROracle} - o pacote ROracle
    \R - a aplicação R
    \item \code{POSIXct} é mapeado para Oracle 
    \code{TIMESTAMP WITH TIME ZONE(ora.fractional_seconds_precision)} se o 
    atributo \code{ora.type} for \code{"TIMESTAMP WITH TIME ZONE"} ou Oracle 
    \code{TIMESTAMP WITH LOCAL TIME ZONE(ora.fractional_seconds_precision)} se
    o atributo \code{ora.type} for \code{"TIMESTAMP WITH LOCAL TIME ZONE"} ou
    Oracle \code{TIMESTAMP(ora.fractional_seconds_precision)} e se 
    \code{Date} for \code{FALSE} 
    \item \code{difftime} é mapeado para Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} de \code{raw} vetores serão mapeados para Oracle \code{BLOB} se 
    o atributo \code{ora.type} for \code{"BLOB"} ou Oracle 
    \code{RAW(ora.maxlength)}
    \item outros tipos \R, como \code{factor}, são convertidos em
    \code{character}
  }
   O ROracle retorna valores de colunas do banco de dados que são do tipo de dados: date,
   time stamp, time stamp com fuso horário e time stamp com fuso horário local
   no formato POSIXct do R. POSIXct se refere a um
   tempo que é armazenado internamente como o número de segundos desde o início de
   1970 no UTC. O número de segundos é trocado do formato de driver R e ROracle em
   ponto flutuante duplo. Na representação POSIXct, R usa a variável
   de ambiente TZ ou mapeia a variável de ambiente de fuso horário do SO para o seu
   próprio; portanto, a data será exibida nesse formato de fuso horário.
   É possível inserir dados nas colunas dos quatro tipos de dados listados acima usando uma
   string com o formato correto ou a representação POSIXct. Os dados de string são
   transmitidos ao banco de dados diretamente e o ROracle confia no banco de dados para convertê-los
   em representação de data/hora. O driver ROracle converte a representação POSIXct
   em uma representação de string usando o formato
   "\%Y-\%m-\%d \%H:\%M:\%OS6" em um quadro de dados utilizado nas operações DML.
   Os dados nesse formato correspondem a NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF" e são convertidos em SQLT_TIMESTAMP_LTZ para
   serem ligados ao banco de dados Oracle. É criada uma classe intermediária "datetime"
   que representa dados de caractere para o driver ROracle internamente.
   As colunas que têm um tipo de dados date e time stamp são extraídas pelo ROracle usando
   o tipo de dados SQLT_TIMESTAMP. As colunas que têm um tipo de dados time stamp com fuso horário ou
   time stamp com fuso horário local são extraídas usando o
   tipo de dados SQLT_TIMESTAMP_LTZ. As colunas do tipo de dados time stamp com fuso horário
   local passam por conversão para o fuso horário da sessão na aplicação em que R é executado;
   portanto, a definição do ambiente de fuso horário TZ no R afetará os valores
   de dados nessa coluna. O driver ROracle mapeia a variável de ambiente TZ para
   o fuso horário da sessão e emite uma DDL de alteração para definir o fuso horário da sessão
   quando a conexão é estabelecida com o banco de dados.
   Para extrair dados de colunas com um timestamp com fuso horário ou um timestamp
   com fuso horário local, o cliente e servidor devem ter o mesmo arquivo de dados
   de fuso horário, senão um erro será reportado.
   Quando esses tipos de dados são selecionados no banco de dados, eles são convertidos em
   representação de string usando NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF" que corresponde a "\%Y-\%m-\%d \%H:\%M:\%OS6"
   no R. Uma classe intermediária "datetime" é criada
   para representar esses dados de caracteres no driver ROracle. O driver ROracle então
   os converte em POSIXct usando a função as.POSIXct(). Uma aplicação R
   vê os dados no formato POSIXct no quadro de dados.
   \\preformatted{
Fuso horário da sessão do R:
 O R tem o conceito de um fuso horário no qual o motor do R opera. O fuso
 horário pode ser definido como uma string, como 'PST8PDT', 'America/Los_Angeles' e assim por diante.
 Essas strings são autoexplicativas e especificam o fuso horário no qual a
 sessão está operando.
 O fuso horário da sessão do R pode ser definido de uma de duas maneiras:
 1. Informando o seguinte na linha de comandos do Linux ou Unix antes de iniciar o
    R:
    setenv TZ = America/Los_Angeles on Linux/UNIX
    OBSERVAÇÃO: Não use essa opção no Windows, já que ela não permite definir
          nomes de fuso horário compatíveis com Oracle para a variável de ambiente TZ.
 2. Informando o seguinte no prompt do R:
    Sys.setenv(TZ = "PST8PDT")
 É recomendável o uso da opção 2 porque o script R funciona sem qualquer
 problema de porta no Linux/Unix, bem como no Windows. A opção 2 também permite que você
 especifique nomes de fuso horário compatíveis com Oracle, mesmo no Windows.
 O fuso horário da sessão do R determina o fuso horário de todos os tipos de data/hora não
 qualificados de fuso horário POSIXct. É também o fuso horário no qual todos os
 tipos de data/hora qualificados são convertidos quando são exibidos pelo R.
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
Observe que timestamps não qualificados também são assumidos como estando no
fuso horário da sessão do R quando são exibidos pelo R. É claro que o R também é inteligente
o suficiente para determinar se o horário se enquadra em PST ou PDT,
com base em quando começa o Horário de Verão nos EUA, e exibe PST ou PDT
em conformidade.
O exemplo a seguir deixa isso mais claro.
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
Observe que todos os timestamps não qualificados de fuso horário são assumidos como
estando no fuso horário da sessão. Entretanto, mesmo os timestamps qualificados de fuso horário
são convertidos no fuso horário da sessão e exibidos. Observe que todos os
valores são exibidos pelo R no fuso horário da sessão do R (com o
nome de fuso horário modificado para EST ou EDT para levar em conta
o horário de verão, conforme aplicável). Consulte Date-Time Classes em
http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html
e timezones em
http://stat.ethz.ch/R-manual/R-devel/library/base/html/timezones.html
para obter detalhes sobre como o R trata datas, horários e fusos horários)
Vejamos um exemplo em que usamos um nome de fuso horário maior
(geralmente referido como 'Olson Name'), em vez de uma abreviação.
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
Observe que, nesse caso, R não usa o nome grande quando os
valores são exibidos; em vez disso, ainda exibe os valores usando
as abreviações "PST" e "PDT". Isso é importante porque a Oracle
não necessariamente gosta dessas abreviações. Por exemplo, um banco de
dados Oracle não reconhece "PDT" como um fuso horário válido. Consulte "R Time zone
and Oracle session time zone" para obter detalhes sobre fusos horários válidos.
}
   O exemplo a seguir mostra o efeito de alterar o fuso horário
   no ambiente R:
   \\preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # Selecting data and displaying it
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
  Além disso, \code{dbWriteTable} sempre confirma automaticamente uma transação atual, bem
  como os dados que ele insere, isto é, ele age como uma instrução DDL, ainda que
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
