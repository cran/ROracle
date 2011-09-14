##
## $Id: S4R.R st_server_demukhin_r/1 2011/07/22 22:11:37 vsashika Exp $
##
## S4/Splus/R compatibility 

## constant holding the appropriate error class returned by try() 
if(is.R()){
  ErrorClass <- "try-error"
} else {
  ErrorClass <- "Error"  
}
