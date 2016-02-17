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
Ces fonctions imitent leurs équivalents R, sauf qu'elles génèrent 
  un code exécuté à distance dans un moteur de base de données :
  \code{get},
  \code{assign},
  \code{exists}, 
  \code{remove},
  \code{objects} et
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
Objet de connexion de base de données \code{OraConnection}.
}
  \item{name}{
Chaîne de caractères qui respecte les majuscules/minuscules indiquant un nom de table.
}
  \item{schema}{
Chaîne de caractères respectant les majuscules/minuscules indiquant un nom de schéma (ou un
    vecteur de chaînes de caractères pour \code{dbListTables}).
}
  \item{date}{
Indicateur booléen qui indique si la date ou DateTime doit être utilisé.
    Par défaut, DateTime sera utilisé au lieu de l'horodatage.
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
   Les attributs suivants sont utilisés pour le mapping des colonnes BLOB, CLOB, NCLOB, NCHAR, VARCHAR2,
   NVARCHAR2, CHAR, TIMESTAMP WITH TIME ZONE et TIMESTAMP WITH LOCAL TIME ZONE
   dans \code{dbWriteTable} :
   1) Nom d'attribut : \code{ora.type}
   Cet attribut indique le type de la colonne sous-jacente et peut être
   "CLOB", "BLOB", "CHAR", "VARCHAR2" ou "RAW". L'utilisateur peut spécifier
   TIMESTAMP, DATE, TIMESTAMP WITH TIME ZONE ou tout autre type de colonne
   pris en charge par Oracle Database. Cette valeur n'est pas analysée par ROacle et
   est validée par la base de données. L'utilisateur peut fournir l'une des valeurs
   suivantes pour \code{ora.type} : CLOB, BLOB, CHAR, TIMESTAMP WITH TIME
   ZONE, TIMESTAMP WITH LOCAL TIME ZONE et fractional_seconds_precision.
   2) Nom d'attribut : \code{ora.encoding}
   Si UTF-8 est spécifié, la base de données utilise NCLOB, NCHAR ou NVARCHAR en fonction
   de \code{ora.type}.
   3) Nom d'attribut : \code{ora.maxlength}
   Il est possible de spécifier la longueur maximale des colonnes CHAR, VARCHAR, NCHAR, NVARCHAR2 et
   RAW. Pour les autres types de données, \code{ora.maxlength} ne
   s'applique pas et est ignoré. Les valeurs par défaut suivantes sont utilisées pour
   certains types de données lorsque \code{ora.maxlength} n'est pas spécifié.
   CHAR                                       2000
   NCHAR                                      1000
   VARCHAR2                                   4000
   NVARCHAR2                                  2000
   RAW                                        2000
   4) Nom d'attribut : \code{ora.fractional_seconds_precision}
   Il est possible de spécifier la partie fractionnaire du champ date/heure SECOND des colonnes
   TIMESTAMP, TIMESTAMP WITH TIME ZONE et TIMESTAMP WITH LOCAL TIME ZONE.
   Il peut s'agir d'un nombre compris entre 0 et 9. La valeur par défaut est 6.
  Les méthodes \\pkg{ROracle} telles que \code{dbReadTable}, \code{dbGetQuery},
  \code{fetch} et \code{dbWriteTable} utilisent le mapping suivant
  entre les types de données Oracle et \R :
  \itemize{
    \item \code{logical} et \code{integer} sont mappés avec Oracle \code{INTEGER}
    \item \code{numeric} est mappé avec Oracle \code{NUMBER} si l'argument
    \code{ora.number} est \code{TRUE} ou Oracle \code{BINARY_DOUBLE} si
    \code{FALSE}
    \item \code{character} est mappé avec Oracle \code{CLOB} si l'attribut 
    \code{ora.type} est \code{"CLOB"} ou Oracle \code{NCLOB} si l'attribut
    \code{ora.type} est \code{"CLOB"} et \code{ora.encoding} est \code{"UTF-8"}
    ou Oracle \code{CHAR(ora.maxlength)} si l'attribut \code{ora.type} est 
    \code{"CHAR"} ou Oracle \code{NCHAR(ora.maxlength)} si l'attribut 
    \code{ora.type} est \code{"CHAR"} et \code{ora.encoding} est \code{"UTF-8"}
    ou Oracle \code{NVARCHAR2(ora.maxlength)} si l'attribut \code{ora.encoding}
    est \code{"UTF-8"} ou Oracle \code{VARCHAR2(ora.maxlength)}
    \item \code{Date} et \code{POSIXct} sont mappés avec Oracle \code{DATE}
    \\pkg{ROracle} - package ROracle
    \R - application R
    \item \code{POSIXct} est mappé avec Oracle 
    \code{TIMESTAMP WITH TIME ZONE(ora.fractional_seconds_precision)} si 
    l'attribut \code{ora.type} est \code{"TIMESTAMP WITH TIME ZONE"} ou Oracle 
    \code{TIMESTAMP WITH LOCAL TIME ZONE(ora.fractional_seconds_precision)} si
    l'attribut \code{ora.type} est \code{"TIMESTAMP WITH LOCAL TIME ZONE"} ou
    Oracle \code{TIMESTAMP(ora.fractional_seconds_precision)} et si 
    \code{Date} est \code{FALSE} 
    \item \code{difftime} est mappé avec Oracle \code{INTERVAL DAY TO SECOND}
    \item \code{list} sur \code{raw} vecteurs sont mappés avec Oracle \code{BLOB} si 
    l'attribut \code{ora.type} est \code{"BLOB"} ou Oracle 
    \code{RAW(ora.maxlength)}
    \item les autres types \R tels que \code{factor} sont convertis vers
    \code{character}
  }
   ROracle renvoie les valeurs des colonnes de base de données avec les types de données suivants : date,
   horodatage, horodatage avec fuseau horaire et horodatage avec fuseau horaire local
   au format POSIXct de R. POSIXct fait référence à une heure
   stockée en interne correspondant au nombre de secondes écoulées depuis le début
   de l'année 1970 en temps UTC. Le nombre de secondes est échangé à partir du pilote ROracle et R au
   format double à virgule flottante. Dans la représentation POSIXct, R utilise la
   variable d'environnement TZ ou mappe la variable d'environnement de fuseau horaire du système
   d'exploitation avec la sienne afin que la date soit affichée dans ce format de fuseau horaire.
   Il est possible d'insérer des données dans les colonnes des 4 types de données répertoriés ci-dessus à l'aide d'une
   chaîne au format correct ou d'une représentation POSIXct. Les données de chaîne sont
   directement transmises à la base de données et ROracle dépend de la base de données pour les convertir
   en représentation date/heure. Le pilote ROracle convertit la représentation POSIXct
   en une représentation de chaîne à l'aide du format
   "\%Y-\%m-\%d \%H:\%M:\%OS6" dans une structure de données qui est utilisée pour les opérations DML.
   Les données dans ce format correspondent à NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF" et sont converties en SQLT_TIMESTAMP_LTZ pour être
   liées à la base de données Oracle. Une classe intermédiaire "datetime" est créée.
   Elle représente les données de caractère dans le pilote ROracle en interne.
   Les colonnes possédant un type de données d'horodatage sont extraites par ROracle à l'aide
   du type de données SQLT_TIMESTAMP. Les colonnes avec les types de données d'horodatage avec fuseau horaire ou
   d'horodatage avec fuseau horaire local sont extraites à l'aide du
   type de données SQLT_TIMESTAMP_LTZ. Les colonnes avec les types de données d'horodatage avec fuseau horaire local
   sont converties au fuseau horaire de la session exécutant l'application R.
   La définition de l'environnement de fuseau horaire TZ dans R aura donc une incidence sur les valeurs des données
   de cette colonne. Le pilote ROracle mappe la variable d'environnement TZ au
   fuseau horaire de la session et émet une instruction de modification DDL pour définir le fuseau horaire de la session
   lorsque la connexion est établie avec la base de données.
   Afin d'extraire les données des colonnes avec un horodatage avec fuseau horaire ou avec un horodatage avec
   fuseau horaire local, le client et le serveur doivent posséder le même fichier de données de fuseau horaire,
   sinon une erreur est signalée.
   Lorsque ces types de données sont sélectionnés dans la base de données, ils sont convertis en
   représentation de chaîne à l'aide de NLS_TIMESTAMP_TZ_FORMAT
   "YYYY-MM-DD HH24:MI:SSXFF", qui correspond à "\%Y-\%m-\%d \%H:\%M:\%OS6"
   dans R. Une classe intermédiaire "datetime" est créée
   pour représenter ces données de caractère dans le pilote ROracle. Le pilote ROracle la convertit
   ensuite en POSIXct à l'aide de la fonction as.POSIXct(). Une application R
   voit les données au format POSIXct dans la structure de données.
   \\preformatted{
Fuseau horaire de session R :
 R comprend le concept d'un fuseau horaire dans lequel fonctionne le moteur R. Le fuseau
 horaire peut être défini sur une chaîne comme 'PST8PDT', 'America/Los_Angeles', etc.
 Ces chaînes sont explicites et spécifient le fuseau horaire dans lequel
 la session est en cours.
 Le fuseau horaire de session R peut être défini de deux manières :
 1. Entrez la chaîne suivante sur la ligne de commande Linux ou Unix avant
    le démarrage de R :
    setenv TZ = America/Los_Angeles sur Linux/UNIX
    Remarque : n'utilisez pas cette option sous Windows car elle ne permet pas de
          définir des noms de fuseau horaire compatibles avec Oracle pour la variable d'environnement TZ.
 2. Entrez la chaîne suivante à l'invite R :
    Sys.setenv(TZ = "PST8PDT")
 Nous vous recommandons l'option 2 car le script R fonctionne
 sans problème de prise en charge sous Linux/Unix, ainsi que sous Windows. L'option 2 permet également
 de spécifier des noms de fuseau horaire compatibles avec Oracle même sous Windows.
 Le fuseau horaire de session R détermine le fuseau horaire de tous les types de date et d'heure non qualifiés
 de fuseau horaire POSIXct. Il s'agit également du fuseau horaire vers lequel tous
 les types de date et d'heure qualifiés sont convertis lorsqu'ils sont affichés par R.
 L'exemple suivant le démontre.
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
Les horodatages non qualifiés sont également supposés être dans le
fuseau horaire de session de R lorsqu'ils sont affichés par R. Bien sûr, R est
assez intelligent pour déterminer si l'heure est PST ou PDT
en fonction de la date américaine de passage à l'heure d'été, et
affiche PST ou PDT selon ce critère.
L'exemple suivant met cela en évidence.
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
Tous les horodatages non qualifiés de fuseau horaire sont supposés être
dans le fuseau horaire de session. Toutefois, même les horodatages qualifiés de fuseau horaire
sont convertis vers le fuseau horaire de session et affichés. Toutes les
valeurs sont affichées par R dans le fuseau horaire de la session R (le
nom de fuseau horaire est également remplacé par EST ou EDT selon l'heure d'hiver
ou d'été). Reportez-vous aux classes de date/heure sur
http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html
et aux fuseaux horaires sur :
http://stat.ethz.ch/R-manual/R-devel/library/base/html/timezones.html
pour plus d'informations sur la manière dont R gère les dates, les heures et les fuseaux horaires)
Voici un exemple dans lequel est utilisé un nom de fuseau horaire plus long
(souvent appelé 'nom Olson') et non une abréviation.
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
Dans ce cas, R n'utilise pas le nom long lorsque
les valeurs sont affichées, mais il affiche les valeurs à l'aide
des abréviations "PST" et "PDT". Ceci est important car Oracle
n'apprécie pas particulièrement ces abréviations. Par exemple, une base de données Oracle
ne reconnaît pas "PDT" comme un fuseau horaire valide. Reportez-vous à la section sur le fuseau horaire R
et le fuseau horaire de session Oracle pour plus d'informations sur les fuseaux horaires valides.
}
   L'exemple ci-dessous montre l'incidence de la modification du fuseau horaire dans
   l'environnement R :
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
  De plus, \code{dbWriteTable} valide (commit) toujours automatiquement la transaction en cours et
  les données qu'elle insère, c'est-à-dire qu'il agit en tant qu'instruction DDL même si
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
