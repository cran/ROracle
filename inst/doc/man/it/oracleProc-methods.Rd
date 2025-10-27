\name{oracleProc-methods}
\docType{methods}
\alias{oracleProc}
\alias{oracleProc,OraConnection,character-method}
\title{
Esecuzione di una stored procedure o stored function PL/SQL
}
\description{
Questo metodo è un'implementazione semplice della corrispondente
   funzione generica.
}
\usage{
\S4method{oracleProc}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
}
\arguments{
  \item{conn}{
Oggetto \code{OraConnection}.
}
  \item{statement}{
Vettore di caratteri di lunghezza 1 con l'istruzione SQL.
}
  \item{data}{
data.frame che specifica i dati di bind.
}
  \item{prefetch}{
Valore logico che specifica se ROracle usa i buffer di recupero preliminare o un array 
    fetch per recuperare i dati dal server. Quando l'impostazione è \code{TRUE}, ROracle usa i 
    buffer di recupero preliminare OCI per recuperare ulteriori dati dal server, risparmiando 
    la memoria richiesta in RODBI/ROOCI mediante l'allocazione di un buffer con riga 
    singola per recuperare i dati da OCI. L'uso della funzione di recupero preliminare 
    genera una chiamata di FETCH per ogni riga. Con l'impostazione predefinita \code{FALSE}, 
    ROracle usa un array fetch per recuperare i dati.
}
  \item{bulk_read}{
Valore intero che indica il numero di righe da recuperare alla volta. Il valore 
    predefinito è 1000L. Quando si seleziona l'opzione di recupero preliminare, la 
    memoria viene allocata per i buffer di recupero preliminare e OCI recupera ogni 
    volta il numero di righe specificato. Quando l'opzione di recupero preliminare non 
    è usata (impostazione predefinita), la memoria viene allocata nei buffer di definizione 
    RODBI/ROOCI. L'impostazione di un valore elevato comporta l'allocazione di più memoria 
    in base al numero di colonne nella lista di selezione e ai tipi delle colonne. Per una colonna 
    di caratteri, i buffer di definizione vengono allocati utilizzando la larghezza massima moltiplicata 
    per la larghezza massima NLS. L'applicazione deve adeguare questo valore in base al risultato 
    della query. Un valore elevato risulterà più utile alle query che restituiscono grandi quantità di 
    risultati. L'applicazione può regolare questo valore in base alle esigenze.
}
  \item{bulk_write}{
Valore intero che indica il numero di righe da scrivere alla volta. Il valore
    predefinito è 1000L. Quando si specifica un valore bulk_write, la memoria 
    viene allocata per i buffer e OCI scrive ogni volta la quantità di righe 
    specificata. Se l'argomento bulk_write non viene usato, per allocare la 
    memoria per i buffer di autenticazione viene usato il valore predefinito 1000. 
    L'impostazione di \code{bulk_write} su un valore elevato comporta l'allocazione di più
    memoria in base al numero di colonne nella lista di inserimento e ai tipi delle colonne.
}
  \item{\dots}{
Attualmente inutilizzato.
}
}
\value{
Lista di oggetti data frame che contiene i record recuperati tramite fetch
  dal database.
\\details{
  Il numero dei record recuperati si basa sui parametri \code{OUT} e \code{IN OUT}
  della stored procedure o della stored function PL/SQL nell'argomento 
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
