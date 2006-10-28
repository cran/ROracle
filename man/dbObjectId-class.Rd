% $Id: dbObjectId-class.Rd 127 2003-11-04 03:09:25Z dj $
\name{dbObjectId-class}
\docType{class}
\alias{dbObjectId-class}
\title{Class dbObjectId}
\description{  
   A helper (mixin) class to provide external references in
   an R/S-Plus portable way.
}
\section{Objects from the Class}{A virtual Class: No objects may be created from it.}
\section{Slots}{
  \describe{
    \item{\code{Id}:}{Object of class \code{"integer"} 
    this is an integer vector holding an opaque reference into a C struct
    (may or may not be a C pointer, may or may not have length one).
    }
  }
}

\section{Methods}{
  \describe{
    \item{coerce}{\code{signature(from = "dbObjectId", to = "integer")}: ... }
    \item{coerce}{\code{signature(from = "dbObjectId", to = "numeric")}: ... }
    \item{coerce}{\code{signature(from = "dbObjectId", to = "character")}: ... }
    \item{format}{\code{signature(x = "dbObjectId")}: ... }
    \item{print}{\code{signature(x = "dbObjectId")}: ... }
    \item{show}{\code{signature(object = "dbObjectId")}: ... }
  }
}

\note{A cleaner mechanism would use external references, but
historically this class has existed mainly for R/S-Plus portability.}

\examples{\dontrun{
  pg <- dbDriver("PostgreSQL")
  con <- dbConnect(pg, "user", "password")
  is(pg, "dbObjectId")   ## True
  is(con, "dbObjectId")  ## True
  isIdCurrent(con)       ## True
  q("yes")
  \$ R 
  isIdCurrent(con)       ## False
}
}
\keyword{classes}
% vim: syntax=tex
