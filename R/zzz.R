## $Id: zzz.R st_server_demukhin_r/1 2011/07/22 22:11:37 vsashika Exp $

".First.lib" <- ".onLoad" <- 
function(lib, pkg) 
{
   if(!usingR()) library.dynam(.OraPkgName, pkg, lib)
}
