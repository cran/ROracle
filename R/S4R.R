## This file defines some functions that mimic S4 functionality,
## namely:  new, as, show.

usingR <- function(major=0, minor=0){
  if(is.null(version$language))
    return(FALSE)
  if(version$language!="R")
    return(FALSE)
  version$major>=major && version$minor>=minor
}

## constant holding the appropriate error class returned by try() 
if(usingR()){
  ErrorClass <- "try-error"
} else {
  ErrorClass <- "Error"  
}

as <- function(object, classname)
{
  get(paste("as", as.character(classname), sep = "."))(object)
}

new <- function(classname, ...)
{
  if(!is.character(classname))
    stop("classname must be a character string")
  #class(classname) <- classname
  #UseMethod("new")
  do.call(paste("new", classname[1], sep="."), list(...))
}

new.default <- function(classname, ...)
{
  structure(list(...), class = unclass(classname))
}

show <- function(object, ...)
{
  UseMethod("show")
}

show.default <- function(object)
{
   print(object)
   invisible(NULL)
}

oldClass <- class

"oldClass<-" <- function(x, value)
{
  class(x) <- value
  x
}
