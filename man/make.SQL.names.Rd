\name{make.SQL.names}
\alias{make.SQL.names}
\title{
  Make R/S identifiers into legal SQL identifiers.
}
\description{
Produce legal SQL identifiers from an R/S chacter vector.
}
\usage{
make.SQL.names(snames, keywords = .SQL92keywords, unique=T, allow.keywords=T)
}
\arguments{
\item{snames}{
a character vector of R/S identifiers (syntactic names).
}
\item{keywords}{
a character vector of SQL keywords.  Typically, DBMS engines
have slightly different sets of keywords, and each driver will
have its own list, e.g., \code{.OraSQLKeywords}, \code{.MySQLKeywords}.
}
\item{unique}{
logical describing whether the resulting set of SQL names should be unique.
Its default is \code{TRUE}.
Following the SQL 92 standard, uniqueness of SQL identifiers 
is determined regardless of whether letters are upper or lower case.
}
\item{allow.keywords }{
logical describing whether SQL keywords should be allowed in the resulting
set of SQL names.
Its default is \code{TRUE}
}
}
\value{
a character vector with legal SQL identifiers.
}
\details{
The algorithm first invokes 
\code{make.names}
and then replaces each occurrence of a dot ``.'' by an underscore
``\_''.
}
\section{References}{
The set of SQL keywords is stored in the character
vector \code{.SQLKeywords} and reflects the SQL ANSI/ISO 
standard as documented
in "X/Open SQL and RDA", 1994, ISBN 1-872630-68-8.
Users can easily override or update this vector.
}
\section{Bugs}{
The current mapping is not guaranteed to be fully reversible: some 
SQL identifiers that get mapped into R/S identifiers with 
\code{make.names}
and then back to SQL with \code{\link{make.SQL.names}}
will not be equal to the original SQL indetifiers (e.g., compound
SQL identifiers of the form \code{username.tablename} will 
loose the dot ``.'').
}
\seealso{
\code{\link{isSQLKeyword}}
\code{\link{make.names}}
\code{\link{getTable}}
\code{\link{existsTable}}
\code{\link{assignTable}}
\code{\link{removeTable}}
\code{\link{dbConnect}}
}
\examples{\dontrun{
# This example shows how we could export a bunch of data.frames
# into tables on a remote database.

con <- dbConnect("Oracle", user="iptraffic", pass = pwd)

export <- c("trantime.email", "trantime.print", "round.trip.time.email")
tabs <- make.SQL.names(export, unique = T, allow.keywords = T)

for(i in seq(along = export) )
   assignTable(con, name = tabs[i],  get(export[i]))
}
}
\keyword{interface}
\keyword{database}
% docclass is function
% Converted by Sd2Rd version 1.15.2.1.
% vim:syntax=tex
