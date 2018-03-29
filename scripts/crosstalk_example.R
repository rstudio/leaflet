# devtools::install_github("jcheng5/d3scatter")
library(d3scatter)
library(crosstalk)

# library(leaflet)

shared_quakes <- SharedData$new(quakes[sample(nrow(quakes), 100),])
bscols(
  leaflet(shared_quakes, width = "100%", height = 300) %>%
    addTiles() %>%
    addMarkers(),
  d3scatter(shared_quakes, ~depth, ~mag, width = "100%", height = 300)
)
