
require_pkg <- function(pkg, githubRepo = NULL) {
  if (! requireNamespace(pkg, quietly = TRUE)) {
    if (!is.null(githubRepo)) {
      devtools::install_github(githubRepo)
    } else {
      install.packages(pkg)
    }
  }
}
require_pkg("ncdf4")
require_pkg("rmapshaper")
require_pkg("albersusa", "hrbrmstr/albersusa")


devtools::install(dependencies = TRUE)
cat("\n")

message("Removing ./docs/libs folder")
unlink("docs/libs", recursive = TRUE)
cat("\n")

system("cd docs; make clean; make;")
