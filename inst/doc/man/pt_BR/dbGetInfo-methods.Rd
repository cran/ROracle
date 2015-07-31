\name{dbGetInfo-methods}
\docType{methods}
\alias{dbGetInfo}
\alias{dbGetStatement}
\alias{dbGetRowCount}
\alias{dbGetRowsAffected}
\alias{dbColumnInfo}
\alias{dbHasCompleted}
\alias{dbGetInfo,OraDriver-method}
\alias{dbGetInfo,ExtDriver-method}
\alias{dbGetInfo,OraConnection-method}
\alias{dbGetInfo,OraResult-method}
\alias{dbGetStatement,OraResult-method}
\alias{dbGetRowCount,OraResult-method}
\alias{dbGetRowsAffected,OraResult-method}
\alias{dbColumnInfo,OraResult-method}
\alias{dbHasCompleted,OraResult-method}
\title{
Metadados de interface de banco de dados
}
\description{
Estes métodos são implementações simples das funções genéricas
   correspondentes.
}
\usage{
\S4method{dbGetInfo}{OraDriver}(dbObj, ...)
\S4method{dbGetInfo}{ExtDriver}(dbObj, ...)
\S4method{dbGetInfo}{OraConnection}(dbObj, what, ...)
\S4method{dbGetInfo}{OraResult}(dbObj, what, ...)
\S4method{dbGetStatement}{OraResult}(res, ...)
\S4method{dbGetRowCount}{OraResult}(res, ...)
\S4method{dbGetRowsAffected}{OraResult}(res, ...)
\S4method{dbColumnInfo}{OraResult}(res, ...)
\S4method{dbHasCompleted}{OraResult}(res)
}
\arguments{
  \item{dbObj}{
Qualquer objeto que implemente alguma funcionalidade na
    interface R para bancos de dados (um driver, uma conexão ou um conjunto de e resultados).
}
  \item{what}{
Uma string de caracteres que especifica um elemento da lista de saída.
}
  \item{res}{
Um \code{OraResult}.
}
  \item{\dots}{
Não utilizado no momento.
}
}


































\details{
Os nomes de tabela, esquema e coluna distinguem maiúsculas de minúsculas, por exemplo, os nomes
  de tabela \code{ABC} e \code{abc} não são iguais. Todos os nomes de objeto de esquema
  de banco de dados não devem incluir aspas duplas, uma vez que eles são colocados entre
  aspas duplas quando a instrução SQL correspondente é gerada.
  O método \code{dbGetInfo} do \\pkg{ROracle} fornece os seguintes detalhes sobre
  o objeto de driver:
  \itemize{
    \item {\\$driverName} O nome do driver, "Oracle (OCI)"
    \item {\\$driverVersion} A versão do driver ROracle utilizada
    \item {\\$clientVersion} A versão da biblioteca do Cliente Oracle utilizada
    \item {\\$conTotal} O número de conexões instanciadas pelo driver
    \item {\\$conOpen} O número de conexões abertas atualmente
    \item {\\$interruptible} TRUE quando uma consulta de execução longa pode ser interrompida
    \item {\\$unicode_as_utf8} TRUE quando dados de caracteres devem ser extraídos em formato
                              codificado UTF8
    \item {\\$ora_attributes} TRUE quando cada coluna em um quadro de dados de conjunto de resultados
                             tem atributos Oracle DBMS correspondentes
    \item {\\$connections} Informações sobre cada conexão atualmente aberta, consulte
                          \code{dbGetInfo} do objeto de conexão para obter detalhes
  }
  O método \code{dbGetInfo} do \\pkg{ROracle} fornece os seguintes detalhes
  sobre o objeto de conexão:
  \itemize{
    \item {\\$username} O nome do usuário nesta conexão
    \item {\\$dbname} O alias ou a string de conexão utilizado
    \item {\\$serverVersion} A versão do servidor Oracle Database
    \item {\\$serverType} O valor "Oracle RDBMS"
    \item {\\$resTotal} O número de conjuntos de resultados neste conexão
    \item {\\$resOpen} O número de conjuntos de resultados abertos nesta conexão
    \item {\\$prefetch} TRUE quando o mecanismo de pré-extração é usado para extrair dados
    \item {\\$bulk_read} O número de linhas a serem extraídas por vez do DBMS
    \item {\\$bulk_write} O número de linhas a serem gravadas por vez no DBMS
    \item {\\$stmt_cache} TRUE quando o cache de instruções é utilizado
    \item {\\$results} Informações sobre cada conjunto de resultados aberto atualmente, consulte
                      \code{dbGetInfo} do conjunto de resultados para obter detalhes
  }
  O método \code{dbGetInfo} do \\pkg{ROracle} fornece os seguintes detalhes
  sobre o objeto de conjunto de resultados:
  \itemize{
    \item {\\$statement} Instrução SQL usada para produzir o objeto de conjunto de resultados
    \item {\\$isSelect} TRUE quando uma instrução select é especificada
    \item {\\$rowsAffected} O número de linhas afetadas pela instrução DML
    \item {\\$rowCount} O número de linhas no conjunto de resultados atualmente
    \item {\\$completed} TRUE se não houver mais linhas no conjunto de resultados
    \item {\\$prefetch} TRUE quando o mecanismo de pré-extração é utilizado para extrair dados
    \item {\\$bulk_read} O número de linhas a serem extraídas por vez do DBMS
    \item {\\$bulk_write} O número de linhas a serem gravadas por vez no DBMS
    \item {\\$fields} Informações sobre cada coluna no conjunto de resultados, consulte
                     \code{dbColumnInfo} para obter detalhes
  }
  O método \code{dbColumnInfo} do \\pkg{ROracle} fornece os seguintes detalhes
  sobre cada coluna no conjunto de resultados:
  \itemize{
    \item {\\$name} O nome da coluna
    \item {\\$Sclass} O tipo R do objeto que contém os dados retornados pelo
                     Oracle RDBMS
    \item {\\$type} O tipo de coluna conforme criada no Oracle RDBMS
    \item {\\$len} Tamanho do tipo de coluna VARCHAR, CHAR e RAW no Oracle RDBMS.
                  Todas as outras colunas terão NA.
    \item {\\$precision} A precisão da coluna de número
    \item {\\$scale} A escala da coluna de número
    \item {\\$nullOK} TRUE quando um valor NULL pode estar presente na coluna
  }
   O exemplo a seguir mostra as informações de driver, conexão, conjunto de resultados e coluna
   para uma tabela contendo:
 \\preformatted{
   create table foo(
     a number(21),
     b number,
     c char(20),
     d varchar(300),
     e binary_double,
     f binary_float,
     g clob,
     h blob,
     i bfile,
     j date,
     m timestamp,
     n timestamp with time zone,
     o timestamp with local time zone,
     r interval day to second,
     s raw(234)
   );
 }
\\preformatted{   library(ROracle)
Carregando o pacote exigido: DBI
> # instantiate ROracle driver object
> drv <- Oracle()
> con <- dbConnect(drv, "scott", "tiger")
> rs <- dbSendQuery(con, "select * from foo")
> dbGetInfo(drv)
$driverName
[1] "Oracle (OCI)"
$driverVersion
[1] "1.1-12"
$clientVersion
[1] "11.2.0.4.0"
$conTotal
[1] 1
$conOpen
[1] 1
$interruptible
[1] FALSE
$unicode_as_utf8
[1] TRUE
$ora_attributes
[1] TRUE
$connections
$connections[[1]]
Nome do usuário:             scott 
String de conexão:         
Versão do servidor:        11.2.0.4.0 
Tipo de servidor:           Oracle RDBMS 
Resultados processados:     1 
Pré-extração do OCI:          FALSE 
Leitura em massa:             1000 
Gravação em massa:            1000 
Tamanho do cache de instruções:  0 
Resultados abertos:          1 
> dbGetInfo(con)
$username
[1] "scott"
$dbname
[1] ""
$serverVersion
[1] "11.2.0.4.0"
$serverType
[1] "Oracle RDBMS"
$resTotal
[1] 1
$resOpen
[1] 1
$prefetch
[1] FALSE
$bulk_read
[1] 1000
$bulk_write
[1] 1000
$stmt_cache
[1] 0
$results
$results[[1]]
Instrução:            select * from foo 
Linhas afetadas:        0 
Contagem de linhas:            0 
Instrução select:     TRUE 
Instrução concluída:  FALSE 
Pré-extração do OCI:         FALSE 
Leitura em massa:            1000 
Gravação em massa:           1000 
> dbGetInfo(rs)
$statement
[1] "select * from foo"
$isSelect
[1] TRUE
$rowsAffected
[1] 0
$rowCount
[1] 0
$completed
[1] FALSE
$prefetch
[1] FALSE
$bulk_read
[1] 1000
$bulk_write
[1] 1000
$fields
   name    Sclass                           type len precision scale nullOK
1     A   numeric                         NUMBER  NA        21     0   TRUE
2     B   numeric                         NUMBER  NA         0  -127   TRUE
3     C character                           CHAR  20         0     0   TRUE
4     D character                       VARCHAR2 300         0     0   TRUE
5     E   numeric                  BINARY_DOUBLE  NA         0     0   TRUE
6     F   numeric                   BINARY_FLOAT  NA         0     0   TRUE
7     G character                           CLOB  NA         0     0   TRUE
8     H       raw                           BLOB  NA         0     0   TRUE
9     I       raw                          BFILE  NA         0     0   TRUE
10    J   POSIXct                           DATE  NA         0     0   TRUE
11    M   POSIXct                      TIMESTAMP  NA         0     6   TRUE
12    N   POSIXct       TIMESTAMP WITH TIME ZONE  NA         0     6   TRUE
13    O   POSIXct TIMESTAMP WITH LOCAL TIME ZONE  NA         0     6   TRUE
14    R  difftime         INTERVAL DAY TO SECOND  NA         2     6   TRUE
15    S       raw                            RAW 234         0     0   TRUE
   }
}
\value{
Informações sobre um objeto de driver, conexão ou conjunto de resultados.
}
\section{References}{
  For the Oracle Database documentaion see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbDriver}},
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
    drv <- dbDriver("Oracle")
    con <- dbConnect(drv, "scott", "tiger")

    rs <- dbSendQuery(con, "select * from emp")

    # Get the SQL statement for the result set object rs
    dbGetStatement(rs)

    # Are there any more rows in result set?
    dbHasCompleted(rs)

    # Information about columns in result set rs object
    dbColumnInfo(rs)

    # DBIDriver info
    names(dbGetInfo(drv))

    # DBIConnection info
    names(dbGetInfo(con))

    # DBIResult info
    names(dbGetInfo(rs)) 
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
