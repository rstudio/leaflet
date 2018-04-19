source("scripts/git_clean.R")

if (!require("rhub", quietly = TRUE)) install.packages("rhub")

build_file <- rhub:::build_package(".", "../builds")
rhub::check_for_cran(build_file, email = "barret@rstudio.com")
