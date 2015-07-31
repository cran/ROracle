\name{dbConnect-methods}
\docType{methods}
\alias{dbConnect}
\alias{dbDisconnect}
\alias{dbConnect,OraDriver-method}
\alias{dbConnect,ExtDriver-method}
\alias{dbDisconnect,OraConnection-method}
\title{
Créer un objet de connexion pour un SGBD Oracle
}
\description{
Ces méthodes sont des implémentations directes des
   fonctions génériques correspondantes.
}
\usage{
\S4method{dbConnect}{OraDriver}(drv, username = "", password = "", dbname = "", prefetch = FALSE,
          bulk_read = 1000L, bulk_write = 1000L, stmt_cache = 0L,
          external_credentials = FALSE, sysdba = FALSE, ...)
\S4method{dbConnect}{ExtDriver}(drv, prefetch = FALSE, bulk_read = 1000L,
          bulk_write = 1000L, stmt_cache = 0L,
          external_credentials = FALSE, sysdba = FALSE, ...)
\S4method{dbDisconnect}{OraConnection}(conn, ...)
}
\arguments{
  \item{drv}{
Objet de la classe \code{OraDriver} ou \code{ExtDriver}.
}
  \item{conn}{
Objet \code{OraConnection} tel que produit par \code{dbConnect}.
}
  \item{username}{
Chaîne de caractères indiquant un nom utilisateur.
}
  \item{password}{
Chaîne de caractères indiquant un mot de passe.
}
  \item{dbname}{
Chaîne de caractères indiquant un identificateur de connexion (pour plus
    d'informations, reportez-vous au chapitre 8 relatif à la configuration des méthodes de dénomination du manuel Oracle
    Database Net Services Administrator's Guide). Il s'agit de la chaîne qui fait partie
    de la chaîne de connexion SQL*Plus suivant le signe '@'. 
    Si vous utilisez Oracle Wallet pour stocker le nom utilisateur et le mot de passe, 
    cette chaîne doit être la chaîne de connexion utilisée pour créer le 
    mapping de portefeuille (pour plus d'informations, reportez-vous au chapitre 3 relatif à la configuration
    des clients pour l'utilisation de la banque de mots de passe externe du manuel Oracle Database Security Guide).
    Les identificateurs de connexion pour une instance Oracle TimesTen IMDB sont pris en charge via
    les méthodes de dénomination OCI tnsnames ou Easy Connect. Pour plus d'informations
    sur les connexions TimesTen pour OCI, reportez-vous au chapitre 3 relatif à la prise en charge de TimesTen pour OCI,
    dans le manuel TimesTen In-Memory C Developer's Guide.
    Les exemples ci-dessous illustrent plusieurs façons de spécifier l'identificateur de connexion.
}
  \item{prefetch}{
Valeur logique indiquant TRUE ou FALSE. Lorsque cette valeur est définie sur TRUE, ROracle utilise
    les tampons de préextraction OCI pour extraire des données supplémentaires du serveur, économisant ainsi
    la mémoire requise dans RODBI/ROOCI en attribuant un seul tampon de ligne pour extraire 
    les données à partir d'OCI. L'utilisation de la préextraction génère un appel d'extraction pour chaque ligne. Par
    défaut, la préextraction est définie sur FALSE et l'extraction par tableau est utilisée pour extraire les données à partir
    du serveur.
}
  \item{bulk_read}{
Valeur entière indiquant le nombre de lignes à extraire à la fois. La
    valeur par défaut est 1000L. Lorsque l'option de préextraction est sélectionnée, la mémoire est
    allouée aux tampons de préextraction et OCI extrait ce nombre de lignes à la fois.
    Lorsque la préextraction n'est pas utilisée (par défaut), la mémoire est allouée aux tampons définis
    RODBI/ROOCI. La définition de cette valeur sur un nombre plus important se traduira par l'allocation de plus de mémoire
    en fonction du nombre de colonnes dans la liste et les types
    de colonnes sélectionnés. Pour une colonne de type caractère, les tampons définis sont alloués
    à l'aide de la formule suivante : largeur maximale fois largeur maximale NLS. Les applications doivent
    ajuster cette valeur en fonction du résultat de requête et une valeur plus importante sera bénéfique pour
    les requêtes qui renvoient un résultat important. Une application peut régler cette valeur selon
    ses besoins.
}
  \item{bulk_write}{
Valeur entière indiquant le nombre de lignes à insérer, mettre à jour ou supprimer
    simultanément. La valeur par défaut est 1000L. Lorsque la valeur bulk_write est donnée
    dans l'argument, la mémoire est allouée pour les tampons et OCI écrit ce nombre
    de lignes de manière simultanée. Lorsque l'argument bulk_write n'est pas spécifié, la valeur par défaut
    1000 est utilisée pour allouer la mémoire aux tampons de liaison. Si cet argument est défini
    sur une valeur élevée, davantage de mémoire est allouée en fonction du nombre de
    colonnes dans la liste d'insertion et des types de colonne.
}
  \item{stmt_cache}{
Valeur entière indiquant le nombre d'instructions à mettre en mémoire cache. Signifie 
    que les curseurs sont prêts à être utilisés sans nécessité d'analyser à nouveau 
    les instructions. La valeur par défaut est 0L. Si la valeur stmt_cache est supérieure à 0L,
    la valeur \code{prefetch} doit être définie sur TRUE.
}
  \item{external_credentials}{
Valeur logique indiquant TRUE ou FALSE. Lorsqu'elle est définie sur TRUE, ROracle démarre
    la session OCI authentifiée avec des informations d'identification externes sur la connexion.
    La valeur par défaut est FALSE.
}
  \item{sysdba}{
Valeur logique indiquant TRUE ou FALSE. Lorsque cette valeur est définie sur TRUE, ROracle démarre
    la session OCI avec des privilèges SYSDBA sur la connexion. La valeur
    par défaut est FALSE.
}
  \item{\dots}{
Inutilisé actuellement.
}
}
\value{
\item{dbConnect}{
    Objet \code{OraConnection} dont la classe étend \code{DBIConnection}. 
    Cet objet est utilisé pour exécuter des requêtes SQL sur la base de données.
  }
  \item{dbDisconnect}{
    Valeur logique indiquant si l'opération a réussi.
  }
}
\section{Side Effects}{
  \describe{
    \item{dbConnect}{
      Establishes a connection between R and an Oracle Database server.
    }
    \item{dbDisconnect}{
      Frees resources used by the connection object.
    }
  }
}
      





           
\details{
\\describe{
    \item{dbConnect}{
      Cet objet de connexion est utilisé pour exécuter des opérations sur la base de données.
      Lorsque \code{prefetch} est défini sur TRUE, cela permet l'utilisation du tampon de préextraction OCI
      pour extraire des données supplémentaires à partir du serveur.
      L'argument \code{bulk_read} est utilisé pour définir une valeur entière indiquant
      le nombre de lignes à extraire simultanément.
      L'argument \code{bulk_write} est utilisé pour définir une valeur entière indiquant
      le nombre de lignes à écrire simultanément.
      L'argument \code{stmt_cache} est utilisé pour activer ou désactiver la fonctionnalité de mise en cache
      d'instruction. Sa valeur indique la taille du cache d'instructions.
      L'argument \code{external_credentials} est utilisé pour démarrer la session OCI
      authentifiée avec des informations d'identification externes sur la connexion.
      L'argument \code{sysdba} est utilisé pour démarrer la session OCI avec des privilèges SYSDBA
      sur la connexion.
      Lors de l'établissement d'une connexion avec un pilote \code{ExtDriver}, aucun
      argument indiquant des informations d'identification n'est utilisé. Une connexion dans ce
      mode est un objet singleton, c'est-à-dire que tous les appels vers \code{dbConnect}
      renvoient le même objet de connexion.
    }
    \item{dbDisconnect}{
      Cette implémentation interrompt la connexion entre R et le serveur
      de base de données. Elle libère toutes les ressources utilisées par l'objet de connexion,
      ainsi que tous les ensembles de résultats associés à cet objet de connexion.
    }
  }
}
\section{References}{
  For the Oracle Database documentation see
  \url{http://www.oracle.com/technetwork/indexes/documentation/index.html}.
}
\seealso{
  \code{\link{Oracle}},
  \code{\link[DBI]{dbConnect}},
  \code{\link[DBI]{dbSendQuery}},
  \code{\link[DBI]{dbGetQuery}},
  \code{\link[DBI]{fetch}},
  \code{\link[DBI]{dbCommit}},
  \code{\link[DBI]{dbGetInfo}},
  \code{\link[DBI]{dbReadTable}}.
}
\examples{
  \dontrun{
    ## Create an Oracle Database instance and create one connection on the
    ## same machine.
    drv <- dbDriver("Oracle")

    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection to a
    ## remote database using the SID in the connect string. 
    drv <- dbDriver("Oracle")

    ## Refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.
    host <- "myhost"
    port <- 1521
    sid <- "mysid"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
        "(CONNECT_DATA=(SID=", sid, ")))", sep = "")

    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection to a
    ## remote database using the service name.
    drv <- dbDriver("Oracle")

    ## Refer to Oracle Database Net Services Administator's Guide for
    ## details on connect string specification.

    host <- "myhost"
    port <- 1521
    svc <- "mydb.example.com"
    connect.string <- paste(
      "(DESCRIPTION=",
      "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
      "(CONNECT_DATA=(SERVICE_NAME=", svc, ")))", sep = "")
    ## Use username/password authentication.
    con <- dbConnect(drv, username = "scott", password = "tiger",
                     dbname = connect.string)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Use Oracle Wallet authentication.
    con <- dbConnect(drv, username ="", password="", 
    dbname = "<wallet_connect_string>")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Connect to a TimesTen IMDB instance using the easy connect 
    ## naming method where SampleDb is a direct driver TimesTen DSN.
    con <- dbConnect(drv, username ="scott", password="tiger", 
                     dbname = "localhost/SampleDb:timesten_direct")

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from dual")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Connect to an extproc (this assumes that the driver has already
    ## been initialized in the embedded R code by passing an external
    ## pointer representing the extproc context).
    con <- dbConnect(Extproc())

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from dual")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")

    ## Create connection with SYSDBA privileges.
    con <- dbConnect(drv, username ="scott", password="tiger",
                     sysdba = TRUE)

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
  \dontrun{
    ## Create an Oracle Database instance and create one connection.
    drv <- dbDriver("Oracle")
    
    ## Use OS authentication as an example of external authentication
    ## Make sure that databse user exist to allow an OS authentication

    ## Create connection authenticated with external credentials.
    con <- dbConnect(drv, username ="", password="",
                     external_credentials = TRUE)
    
    ## Above dbConnect() used OS credentials to connect with database.

    ## Run a SQL statement by creating first a resultSet object.
    rs <- dbSendQuery(con, "select * from emp where deptno = 10")

    ## We now fetch records from the resultSet into a data.frame.
    data <- fetch(rs)       ## extract all rows
    dim(data)
  }
}
\keyword{methods}
\keyword{interface}
\keyword{database}
