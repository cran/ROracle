% $Id: safe.write.Rd st_server_demukhin_r/2 2011/07/27 13:16:05 paboyoun Exp $
\name{safe.write}
\alias{safe.write}
\title{Write a data.frame avoiding exceeding memory limits}
\description{
   This function batches calls to \code{write.table} to avoid
   exceeding memory limits for very large data.frames.
}
\usage{
safe.write(value, file, batch, ...)
}
\arguments{
  \item{value}{a data.frame;}
  \item{file}{a file object (connection, file name, etc).}
  \item{batch}{maximum number of rows to write at a time.}
  \item{\dots}{any other arguments are passed to \code{write.table}.}
}
\details{
   The function has a while loop invoking \code{\link[utils]{write.table}}
   for subsets of \code{batch} rows of \code{value}.  Since this is
   a helper function for \code{\link[ROracle]{oraWriteTable}} has hardcoded
   other arguments to \code{write.table}.
}
\value{
    \code{NULL}, invisibly.
}
\note{No error checking whatsoever is done.}

\seealso{\code{\link[utils]{write.table}}} 

\examples{\dontrun{
   ctr.file <- file("dump.sqloader", "w")
   safe.write(big.data, file = ctr.file, batch = 25000)
}
}
\keyword{internal}
%% vim: syntax=tex
