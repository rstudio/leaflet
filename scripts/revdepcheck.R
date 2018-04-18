source("scripts/git_clean.R")

if (!require("revdepcheck")) devtools::install_github("r-lib/revdepcheck")

revdepcheck::revdep_check()
