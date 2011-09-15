## $Id: zzz.R st_server_demukhin_r/2 2011/07/28 10:29:32 paboyoun Exp $

".First.lib" <- ".onLoad" <- 
function(lib, pkg) 
{
   if(!is.R()) library.dynam(.OraPkgName, pkg, lib)
}
