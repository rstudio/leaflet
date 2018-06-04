devtools::install_github("schloerke/viztest")
# source("scripts/viztest.R")


# compare to leaflet.js v0.7.x
# viztest::viztest(".", "rstudio/leaflet@d489e2c", resize = FALSE, stomp = TRUE)
viztest::viztest(".", "leaflet", resize = FALSE, stomp = TRUE)

# viztest::viztest(".", "rstudio/leaflet", resize = FALSE, stomp = TRUE, skip_old = TRUE)
