\name{oracleProc-methods}
\docType{methods}
\alias{oracleProc}
\alias{oracleProc,OraConnection,character-method}
\title{
PL/SQL Stored Procedure oder -Funktion ausführen
}
\description{
Diese Methode ist eine einfache Implementierung der entsprechenden
   generischen Funktion.
}
\usage{
\S4method{oracleProc}{OraConnection,character}(conn, statement, data = NULL,
          prefetch = FALSE, bulk_read = 1000L, bulk_write = 1000L, ...)
}
\arguments{
  \item{conn}{
Ein \code{OraConnection}-Objekt.
}
  \item{statement}{
Ein Zeichenvektor mit der Länge 1 mit der SQL-Anweisung.
}
  \item{data}{
Ein data.frame, der Bind-Daten angibt.
}
  \item{prefetch}{
Ein logischer Wert, der angibt, ob ROracle Prefetch-Puffer oder einen
    Array-Fetch verwendet, um Daten aus dem Server abzurufen. Bei \code{TRUE} ruft ROracle 
    zusätzliche Daten mit OCI-Prefetch-Puffern aus dem Server ab und spart dabei den 
    in RODBI/ROOCI benötigten Speicher, indem ein einzelner Zeilenpuffer für den Abruf 
    der Daten aus OCI verwendet wird. Die Verwendung von Prefetch führt zu einem Fetch-Aufruf für jede
    Zeile. Bei \code{FALSE} (Standardwert) verwendet ROracle einen Array-Fetch, um die Daten
    abzurufen.
}
  \item{bulk_read}{
Ein ganzzahliger Wert, der die Anzahl von Zeilen angibt, die jeweils abgerufen werden soll.
    Der Standardwert ist 1000L. Wenn die Prefetch-Option aktiviert ist, wird Speicher für
    Prefetch-Puffer zugewiesen, und OCI ruft jeweils die angegebene Anzahl von Zeilen ab.
    Wenn Prefetch nicht verwendet wird (Standard), wird Speicher in RODBI/ROOCI-
    Define-Puffern zugewiesen. Wenn Sie hier einen hohen Wert festlegen, wird mehr Speicher
    basierend auf der Anzahl von Spalten in der Select-Liste und den Spaltentypen zugewiesen.
    Bei einer Zeichenspalte werden Define-Puffer mit der maximalen Breite
    mal der maximalen NLS-Breite zugewiesen. Anwendungen müssen diesen 
    Wert entsprechend dem Abfrageergebnis anpassen. Ein hoher Wert kommt
    Abfragen zu Gute, die ein großes Ergebnis zurückgeben. Die Anwendung kann diesen
    Wert nach Bedarf optimieren.
}
  \item{bulk_write}{
Ein ganzzahliger Wert, der die Anzahl an Zeilen angibt, die jeweils geschrieben
    werden sollen. Der Standardwert ist 1000L. Wenn Sie einen bulk_write-Wert
    angeben, wird Speicher für Puffer zugewiesen, und OCI schreibt jeweils die entsprechende
    Anzahl an Zeilen. Wenn Sie das Argument bulk_write nicht verwenden, wird über den
    Standardwert Speicher für die Bind-Puffer zugewiesen. Wenn Sie \code{bulk_write} auf einen
    hohen Wert setzen, wird basierend auf der Anzahl von Spalten in der Einfügeliste
    und auf den Spaltentypen entsprechend mehr Speicher zugewiesen.
}
  \item{\dots}{
Aktuell nicht verwendet.
}
}
\value{
Ein Listen- oder Datenframeobjekt, das die Datensätze enthält, die von der
  Datenbank abgerufen werden.
\\details{
  Die Anzahl der abgerufenen Datensätze basiert auf den Parametern \code{OUT} und \code{IN OUT}
  der gespeicherten PL/SQL-Prozedur oder -Funktion in Argument 
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
