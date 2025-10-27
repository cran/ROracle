\name{oracleProc-methods}
\docType{methods}
\alias{oracleProc}
\alias{oracleProc,OraConnection,character-method}
\title{
Exécuter une procédure ou une fonction PL/SQL stockée
}
\description{
Cette méthode est une implémentation directe de
   la fonction générique correspondante.
}
\usage{
\S4method{oracleProc}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
}
\arguments{
  \item{conn}{
Objet \code{OraConnection}.
}
  \item{statement}{
Vecteur de caractère de longueur 1 avec l'instruction SQL.
}
  \item{data}{
Elément data.frame indiquant les données de liaison.
}
  \item{prefetch}{
Valeur logique indiquant si ROracle utilise les tampons de préextraction ou une
    extraction par tableau pour extraire des données du serveur. Si \code{TRUE}, ROracle 
    utilise les tampons de préextraction OCI pour extraire des données supplémentaires du serveur, 
    économisant ainsi la mémoire requise dans RODBI/ROOCI en allouant un seul tampon de ligne pour 
    extraire les données à partir d'OCI. L'utilisation de la préextraction génère un appel d'extraction pour 
    chaque ligne. Si \code{FALSE} (valeur par défaut), ROracle utilise l'extraction par tableau pour 
    extraire les données.
}
  \item{bulk_read}{
Valeur entière indiquant le nombre de lignes à extraire à la fois. La 
    valeur par défaut est 1000L. Lorsque l'option de préextraction est sélectionnée, la mémoire 
    est allouée aux tampons de préextraction et OCI extrait le nombre de lignes indiquée de manière 
    simultanée. Lorsque la préextraction n'est pas utilisée, ce qui est le paramètre par défaut, la mémoire est 
    allouée aux tampons définis RODBI/ROOCI. La définition de cette valeur sur un nombre plus important 
    entraîne l'allocation de plus de mémoire en fonction du nombre de colonnes dans la liste et les types
    de colonnes sélectionnés. Pour une colonne de type caractère, les tampons définis sont alloués
    à l'aide de la formule suivante : largeur maximale fois largeur maximale NLS. Une application doit
    ajuster cette valeur en fonction du résultat de requête. Une valeur plus importante est
    bénéfique pour les requêtes qui renvoient un résultat important. L'application peut régler
    cette valeur selon ses besoins.
}
  \item{bulk_write}{
Valeur entière indiquant le nombre de lignes à écrire simultanément.
    La valeur par défaut est 1000L. Lorsque la valeur bulk_write est spécifiée,
    la mémoire est allouée pour les tampons et OCI écrit ce nombre de lignes
    de manière simultanée. Lorsque l'argument bulk_write n'est pas spécifié, la valeur par défaut
    est utilisée pour allouer la mémoire aux tampons de liaison. Si \code{bulk_write} est défini
    sur une valeur élevée, davantage de mémoire est allouée en fonction du nombre de
    colonnes dans la liste d'insertion et des types de colonne.
}
  \item{\dots}{
Inutilisé actuellement.
}
}
\value{
Objet de structure de données ou liste contenant les enregistrements extraits à partir de
  la base de données.
\\details{
  Le nombre d'enregistrements extraits dépend des paramètres \code{OUT} et \code{IN OUT}
  de la procédure ou fonction PL/SQL stockée dans l'argument 
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
