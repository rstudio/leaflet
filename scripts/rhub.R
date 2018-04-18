source("scripts/git_clean.R")

if (!require("rhub")) install.packages("rhub")

build_file <- rhub:::build_package(".", "../builds")
rhub::check_for_cran(build_file)
