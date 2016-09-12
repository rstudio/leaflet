library(leaflet)
# Default
l <- leaflet() %>% addTiles() %>% setView(0,0,1)

l %>% addSimpleGraticule()

# Custom Params
l %>% addSimpleGraticule(interval = 40, showOriginLabel = F)

# Custom Resolution + Custom Date and on a toggleable Layer
l %>%
  addSimpleGraticule(interval=40,
                showOriginLabel = F,
                group="graticule") %>%
  addLayersControl(
    overlayGroups = c("graticule"),
    options = layersControlOptions(collapsed = FALSE)
  )
