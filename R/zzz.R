## $Id: zzz.R 155 2006-02-08 19:19:08Z dj $

".First.lib" <- 
function(lib, pkg) 
{
   library.dynam(.OraPkgName, pkg, lib)
}
