library(leaflet)
# Default
leaflet() %>% addTiles() %>% addSimpleGraticule()

# Custom Params
leaflet() %>% addTiles() %>% addSimpleGraticule(interval = 40, showOriginLabel = F)

# Custom Resolution + Custom Date and on a toggleable Layer
leaflet() %>% addTiles() %>%
  addSimpleGraticule(interval=40,
                showOriginLabel = F,
                group="graticule") %>%
  addLayersControl(
    overlayGroups = c("graticule"),
    options = layersControlOptions(collapsed = FALSE)
  )
