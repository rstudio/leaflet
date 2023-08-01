source("scripts/git_clean.R")
`%||%` <- function(x, y) if (!is.null(x)) x else y

require_pkg <- function(pkg, githubRepo = NULL) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    pak::pak(githubRepo %||% pkg)
  }
}
require_pkg("ncdf4")
require_pkg("rmapshaper")
require_pkg("geojsonio")
require_pkg("albersusa", "hrbrmstr/albersusa")


devtools::install(dependencies = TRUE)
cat("\n")

message("Removing ./docs/libs folder")
unlink("docs/libs", recursive = TRUE)
cat("\n")

system("cd docs && make clean && make -j 1")
