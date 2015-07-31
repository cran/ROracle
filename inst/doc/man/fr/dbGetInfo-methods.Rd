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
Métadonnées d'interface de base de données
}
\description{
Ces méthodes sont des implémentations directes des
   fonctions génériques correspondantes.
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
Tout objet qui implémente des fonctionnalités dans l'interface R
    vers des bases de données (pilote, connexion ou ensemble de résultats).
}
  \item{what}{
Chaîne de caractères indiquant un élément de la liste de sortie.
}
  \item{res}{
Elément \code{OraResult}.
}
  \item{\dots}{
Inutilisé actuellement.
}
}


































\details{
Les noms de table, de schéma et de colonne respectent les majuscules/minuscules. Par exemple, les noms
  de table \code{ABC} et \code{abc} ne sont pas identiques. Les noms d'objet de schéma
  de base de données ne doivent pas comporter de guillemets car ils sont délimités par
  des guillemets lorsque l'instruction SQL correspondante est générée.
  La méthode \\pkg{ROracle} \code{dbGetInfo} fournit les détails suivants sur
  l'objet de pilote :
  \itemize{
    \item {\\$driverName} Nom du pilote, "Oracle (OCI)"
    \item {\\$driverVersion} Version du pilote ROracle utilisé
    \item {\\$clientVersion} Version de la bibliothèque Oracle Client utilisée
    \item {\\$conTotal} Nombre de connexions instanciées par le pilote
    \item {\\$conOpen} Nombre de connexions actuellement ouvertes
    \item {\\$interruptible} TRUE lorsqu'une requête à longue durée d'exécution peut être interrompue
    \item {\\$unicode_as_utf8} TRUE lorsque les données de caractères doivent être extraites au format
                              UTF8 encodé
    \item {\\$ora_attributes} TRUE lorsque chaque colonne d'une structure de données d'un ensemble de résultats
                             contient les attributs de SGBD Oracle correspondants
    \item {\\$connections} Informations sur chaque connexion actuellement ouverte. Pour plus de détails,
                          reportez-vous à \code{dbGetInfo} de l'objet de connexion
  }
  La méthode \\pkg{ROracle} \code{dbGetInfo} fournit les détails suivants
  sur l'objet de connexion :
  \itemize{
    \item {\\$username} Nom de l'utilisateur sur cette connexion
    \item {\\$dbname} Alias de connexion ou chaîne de connexion utilisés
    \item {\\$serverVersion} Version du serveur Oracle Database
    \item {\\$serverType} Valeur de "SGBDR Oracle"
    \item {\\$resTotal} Nombre d'ensembles de résultats sur cette connexion
    \item {\\$resOpen} Nombre d'ensemble de résultats ouverts sur cette connexion
    \item {\\$prefetch} TRUE lorsque le mécanisme de préextraction est utilisé pour extraire les données
    \item {\\$bulk_read} Nombre de lignes à extraire simultanément à partir du SGBD
    \item {\\$bulk_write} Nombre de lignes à écrire simultanément vers le SGBD
    \item {\\$stmt_cache} TRUE lorsque le cache d'instruction est utilisé
    \item {\\$results} Informations sur chaque ensemble de résultats actuellement ouvert. Reportez-vous
                      à \code{dbGetInfo} de l'ensemble de résultats pour plus détails.
  }
  La méthode \\pkg{ROracle} \code{dbGetInfo} fournit les détails suivant sur
  l'objet d'ensemble de résultats :
  \itemize{
    \item {\\$statement} Instruction SQL utilisée pour produire l'objet d'ensemble de résultats
    \item {\\$isSelect} TRUE lorsqu'une instruction SELECT est spécifiée
    \item {\\$rowsAffected} Nombre de lignes concernées par l'instruction DML
    \item {\\$rowCount} Nombre de lignes actuellement dans l'ensemble de résultats
    \item {\\$completed} TRUE s'il n'y a plus de lignes dans l'ensemble de résultats
    \item {\\$prefetch} TRUE lorsque le mécanisme de préextraction est utilisé pour extraire les données
    \item {\\$bulk_read} Nombre de lignes à extraire simultanément à partir du SGBD
    \item {\\$bulk_write} Nombre de lignes à écrire simultanément vers le SGBD
    \item {\\$fields} Informations sur chaque colonne dans l'ensemble de résultats. Reportez-vous à
                     \code{dbColumnInfo} pour plus de détails
  }
  La méthode \\pkg{ROracle} \code{dbColumnInfo} fournit les détails suivants sur
  chaque colonne dans l'ensemble de résultats :
  \itemize{
    \item {\\$name} Nom de la colonne
    \item {\\$Sclass} Type R de l'objet contenant les données renvoyé par
                     le SGBDR Oracle
    \item {\\$type} Type de colonne créé dans le SGBDR Oracle
    \item {\\$len} Longueur des types de colonne VARCHAR, CHAR et RAW dans le SGBDR Oracle.
                  Toutes les autres colonnes seront NA.
    \item {\\$precision} Précision du nombre de colonnes
    \item {\\$scale} Echelle du nombre de colonnes
    \item {\\$nullOK} TRUE lorsqu'une valeur NULL peut être présente dans la colonne
  }
   L'exemple ci-dessous montre les informations sur le pilote, la connexion, l'ensemble de résultats et la colonne
   pour une table contenant :
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
Chargement du package obligatoire : DBI
> # instancier l'objet de pilote ROracle
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
Nom utilisateur :             scott 
Chaîne de connexion :         
Version du serveur :        11.2.0.4.0 
Type de serveur :           Oracle RDBMS 
Résultats traités :     1 
Préextraction OCI :          FALSE 
Lecture globale :             1000 
Ecriture globale :            1000 
Taille du cache d'instructions :  0 
Résultats ouverts :          1 
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
Instruction :            select * from foo 
Lignes concernées :        0 
Nombre de lignes :            0 
Instruction SELECT :     TRUE 
Instruction terminée :  FALSE 
Préextraction OCI :         FALSE 
Lecture globale :            1000 
Ecriture globale :           1000 
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
Informations sur le pilote, la connexion ou un objet d'ensemble de résultats.
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
