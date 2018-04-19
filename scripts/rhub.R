source("scripts/git_clean.R")

if (!require("rhub", quietly = TRUE)) install.packages("rhub")

build_file <- rhub:::build_package(".", "../builds")

rhub::check_for_cran(
  build_file,
  email = "barret@rstudio.com",
  platforms = c("windows-x86_64-release", rhub:::default_cran_check_platforms(build_file)),
  env_vars = c("_R_CHECK_FORCE_SUGGESTS_" = "0"),
  check_args = "--run-donttest"
)
