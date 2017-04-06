library(crosstalk)
library(plotly)
library(leaflet)

sd <- SharedData$new(quakes)

p <- plot_ly(sd, x = ~depth, y = ~mag) %>%
  add_markers(alpha = 0.5) %>%
  layout(dragmode = "select") %>%
  highlight(dynamic = TRUE, persistent = TRUE)

map <- leaflet(sd) %>%
  addTiles() %>%
  addCircles()

# let leaflet know this is persistent selection
options(persistent = TRUE)

htmltools::browsable(htmltools::tagList(p, map))
