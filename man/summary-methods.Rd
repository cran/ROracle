% $Id: summary-methods.Rd,v 1.2 2003/11/04 03:09:25 dj Exp dj $
\name{summary-methods}
\docType{methods}
\alias{coerce-methods}
\alias{summary-methods}
\alias{format-methods}
\alias{show-methods}
\alias{coerce,dbObjectId,integer-method}
\alias{coerce,dbObjectId,numeric-method}
\alias{coerce,dbObjectId,character-method}
\alias{coerce,OraObject,OraDriver-method}
\alias{coerce,OraConnection,OraResult-method}
\alias{coerce,OraConnection,OraDriver-method}
\alias{coerce,OraResult,OraConnection-method}
\alias{format,dbObjectId-method}
\alias{print,dbObjectId-method}
\alias{show,dbObjectId-method}
\alias{summary,OraObject-method}
\alias{summary,OraDriver-method}
\alias{summary,OraConnection-method}
\alias{summary,OraResult-method}
\alias{summary,OraPreparedStatement-method}
\title{Summarize an Oracle object}
\description{
   These methods are straight-forward implementations of the corresponding
   generic functions.
}
\section{Methods}{\describe{

\item{object = "DBIObject"}{
   Provides relevant metadata information on \code{object}, 
   for instance, the Oracle server file, the
   SQL statement associated with a result set, etc.  
   }
\item{from}{object to be coerced}
\item{to}{coercion class}
\item{x}{object to \code{format} or \code{print} or \code{show}}
}
}
\keyword{methods}
\keyword{database}
\keyword{interface}
% vim: syntax=tex
