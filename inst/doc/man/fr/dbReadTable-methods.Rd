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
Fonctions simplifiées de manipulation des tables SGBD
}
\description{
Ces fonctions imitent leurs équivalents R 
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} et
  \code{names},
  sauf qu'elles génèrent un code exécuté à distance dans un moteur
  de base de données.
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
Objet de connexion de base de données \code{OraConnection}.
}
  \item{name}{
Chaîne de caractères qui respecte les majuscules/minuscules indiquant un nom de table.
}
  \item{schema}{
Chaîne de caractères respectant les majuscules/minuscules indiquant un nom de schéma (ou un
    vecteur de chaînes de caractères pour \code{dbListTables}).
}

  \item{row.names}{
Dans le cas de \code{dbReadTable}, cet argument peut être une chaîne, un
    index ou un vecteur logique indiquant la colonne dans la table SGBD à
    utiliser en tant que \code{row.names} dans l'élément data.frame de sortie (\code{NULL}
    indique qu'aucune colonne ne doit être utilisée en tant que \code{row.names} dans la
    sortie). La valeur par défaut est \code{NULL}.
    Dans le cas de \code{dbWriteTable}, cet argument doit être une valeur
    logique indiquant si \code{row.names} doit être enregistré dans la
    table SGBD de sortie ; si \code{TRUE}, une colonne supplémentaire nommée
    \code{"row.names"} sera ajoutée à la sortie. La valeur par défaut est
    \code{FALSE}.
}
  \item{value}{
\code{data.frame} comportant les données à écrire dans une table. (Reportez-vous à
    la section de détails pour consulter les types de colonne pris en charge.)
}
  \item{overwrite}{
Valeur logique indiquant si une table existante doit être
    écrasée. La valeur par défaut est \code{FALSE}.
}
  \item{append}{
Valeur logique indiquant si des données doivent être ajoutées à la fin d'une table existante
    dans le SGBD. La valeur par défaut est \code{FALSE}.
}
  \item{ora.number}{
Valeur logique indiquant si une table doit être créée avec des colonnes
    \code{NUMBER} ou \code{BINARY_DOUBLE} Oracle lors de l'écriture de données
    numériques. Indiquez \code{TRUE} pour créer une table avec les valeurs \code{NUMBER} 
    Oracle, ou indiquez \code{FALSE} pour créer une table avec les valeurs \code{BINARY_DOUBLE}
    Oracle. La valeur par défaut est \code{TRUE}.
    Indiquez \code{FALSE} si au moins une des valeurs de données numériques est
    \code{NaN}.
}
  \item{purge}{
Valeur logique indiquant si l'option \code{PURGE} doit être ajoutée à
    l'instruction SQL \code{DROP TABLE}.
}
  \item{all}{
Valeur logique indiquant si tous les schémas doivent être consultés.
}
  \item{full}{
Valeur logique indiquant si des noms de schéma doivent être générés. Lorsque l'argument
    \code{all} est \code{TRUE}, la sortie est un vecteur comportant les noms
    de schéma suivis des noms de table. L'utilisation de \code{matrix(..., ncol = 2)}
    sur la sortie produit une matrice dans laquelle chaque ligne correspond à une
    table et les colonnes représentent les noms de schéma et les noms de table,
    respectivement.
}
  \item{\dots}{
inutilisé actuellement.
}
}





   


\details{
Les noms de table, de schéma et de colonne respectent les majuscules/minuscules, par exemple, les noms
  de table \code{ABC} et \code{abc} ne sont pas identiques. Les noms d'objet de schéma
  de base de données ne doivent pas comprendre de guillemets car ils sont délimités par
  des guillemets lorsque l'instruction SQL correspondante est générée.
  Les méthodes \\pkg{ROracle} telles que \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} et \code{dbWriteTable} utilisent le mapping suivant
  entre les types de données Oracle et \R :
  \itemize{
    \item \code{logical} et \code{integer} sont mappés à Oracle \code{INTEGER}
    \item \code{numeric} est mappé à Oracle \code{NUMBER} si l'argument
    \code{ora.number} est \code{TRUE} ou à Oracle \code{BINARY_DOUBLE} si
    \code{FALSE}
    \item \code{character} est mappé à Oracle \code{VARCHAR2(4000)}
    \item \code{Date} et \code{POSIXct} sont mappés à Oracle \code{DATE}
    \\pkg{ROracle} - package ROracle
    \R - application R
    \code{POSIXct} - classe POSIXct
    \code{TIMESTAMP}
    \code{TIMESTAMP WITH TIME ZONE}
    \code{TIMESTAMP WITH LOCAL TIME ZONE}
    \item \code{difftime} est mappé à Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} vecteurs sur \code{raw} sont mappés à Oracle \code{RAW(2000)}
    \item les autres types \R tels que \code{factor} sont convertis vers
    \code{character}
  }
   ROracle renvoie les valeurs des colonnes de base de données avec un type de données : les types de données de date,
   d'horodatage, d'horodatage avec fuseau horaire et d'horodatage avec fuseau horaire local
   au format POSIXct de R. POSIXct fait référence à une heure
   stockée en interne correspondant au nombre de secondes depuis le début
   de l'année 1970 UTC. Le nombre de secondes est échangé du pilote ROracle et R au
   format DOUBLE à virgule flottante. Dans la représentation POSIXct, R utilise la
   variable d'environnement TZ ou mappe la variable d'environnement de fuseau horaire du système
   d'exploitation à la sienne afin que la date soit affichée dans ce format de fuseau horaire.
   Il est possible d'insérer des données dans les colonnes des 4 types de données répertoriés ci-dessus à l'aide d'une
   chaîne au format correct ou d'une représentation POSIXct. Les données de chaîne sont
   directement transmises à la base de données et ROracle dépend de la base de données pour les convertir
   en représentation date/heure. Les données POSIXct seront converties au format du descripteur DateTime
   Oracle interne en ajoutant le début de l'année 1970 UTC au nombre
   de secondes obtenu de R. Les variables POSIXct de l'instruction
   INSERT sont liées en tant que SQLT_TIMESTAMP_TZ.
   Une fois ces types de données sélectionnés dans Oracle, ils sont convertis au format POSIXct
   en retranchant le début de l'année 1970 UTC. Lorsque le client et
   la base de données ROracle ont plusieurs fichiers de version de fuseau horaire et qu'une application utilise les types de données
   de fuseau horaire, il est recommandé qu'ils soient identiques car la région
   peut avoir modifié son fuseau. Si ces fichiers ne sont pas identiques, ROracle signalera une erreur car cette situation
   peut provoquer un endommagement des données ou une perte d'informations lors de l'exécution de ces
   types de données.
   Les colonnes possédant un type de données d'horodatage sont extraites par ROracle à l'aide
   du type de données SQLT_TIMESTAMP. Les colonnes avec les types de données d'horodatage avec fuseau horaire et
   d'horodatage avec fuseau horaire local sont extraites à l'aide du
   type de données SQLT_TIMESTAMP_TZ. Les colonnes avec les types de données d'horodatage avec fuseau horaire local
   sont converties au fuseau horaire de la session exécutée par l'application R ;
   la définition de l'environnement de fuseau horaire TZ dans R aura donc une incidence sur les valeurs des données
   de cette colonne. Le pilote ROracle ne mappe pas la variable d'environnement TZ
   au fuseau horaire de la session et
   n'émet pas d'instruction DDL modifiée pour définir le fuseau horaire de la session. Afin d'extraire
   les données des colonnes avec un horodatage avec fuseau horaire et avec un horodatage avec
   fuseau horaire local, le client et le serveur doivent posséder le même fichier de données de fuseau horaire,
   sinon une erreur sera signalée.
   L'exemple ci-dessous indique l'effet d'une modification de fuseau horaire dans un environnement R :
   \\preformatted{   R> Sys.timezone()
   [1] "PST8PDT"
   # Sélection et affichage des données
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
  De plus, \code{dbWriteTable} valide (commit) toujours automatiquement la transaction en cours ainsi que
  les données qu'il insère, c'est-à-dire qu'il agit en tant qu'instruction DDL même si
  des lignes sont ajoutées à une table existante.
}
\value{
\code{data.frame} dans le cas de \code{dbReadTable} ;
  \code{vector} dans le cas de \code{dbListTables} et
  \code{dbListFields} ;
  \code{logical} dans le cas de \code{dbExistsTable} indiquant
  si la table existe ;
  sinon, \code{TRUE} lorsque l'opération est effectuée ou 
  exception.
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
