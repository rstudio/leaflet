library(leaflet)
# Default Resolution
leaflet() %>% addTiles() %>% addTerminator()

# Custom Resolutions
leaflet() %>% addTiles() %>% addTerminator(resolution = 1)
leaflet() %>% addTiles() %>% addTerminator(resolution = 100)

# Custom Resolution + Custom Date and on a toggleable Layer
leaflet() %>% addTiles() %>%
  addTerminator(resolution = 10,
                time = "2013-06-20T21:00:00Z",
                group = "daylight") %>%
  addLayersControl(
    overlayGroups = c("daylight"),
    options = layersControlOptions(collapsed = FALSE)
  )
