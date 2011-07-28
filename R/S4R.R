##
## $Id: S4R.R st_server_demukhin_r/1 2011/07/22 22:11:37 vsashika Exp $
##
## S4/Splus/R compatibility 

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
