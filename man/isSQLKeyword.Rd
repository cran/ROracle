\name{isSQLKeyword}
\alias{isSQLKeyword}
\title{
  Is a name an SQL keyword?
}
\description{
Verify whether a character vector contains SQL keywords
}
\usage{
isSQLKeyword(x, keywords=.SQLKeywords, case=c("lower", "upper", "any")[3])
}
\arguments{
\item{x}{
character vector of potential SQL identifiers.
}
\item{keywords}{
a character vector with SQL keywords.
By default it's \code{.SQLKeywords}, supplied in the RS-DBI
S chapter or R package.
}
\item{case}{
a character string specifying whether to make the comparison
as lower case, upper case, or any of the two.
it defaults to \code{any}.
}
}
\value{
a logical vector specifying whether the corresponding entry
is or is not an SQL keyword.
}
\section{References}{
The set of SQL keywords is stored in the character
vector \code{.SQLKeywords} and reflects the SQL ANSI/ISO 
standard as documented
in "X/Open SQL and RDA", 1994, ISBN 1-872630-68-8.
Users can easily override or update this vector.
}
\seealso{
\code{\link{make.SQL.names}}
}
\examples{\dontrun{
oracle.keywords <- c("CLUSTER", "COLUMN", "MINUS", "DBNAME)
isSQLKeyword(nam, c(.SQLKeywords, oracle.keywords))
[1]  T  T  T  F
}
}
\keyword{interface}
\keyword{database}
% docclass is function
% Converted by Sd2Rd version 1.15.2.1.
% vim:syntax=tex
