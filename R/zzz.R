.conflicts.OK <- TRUE
.First.lib <- function(lib, pkg) {
  library.dynam("ROracle", pkg, lib)
}
