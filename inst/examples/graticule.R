library(leaflet)
# Default
l <- leaflet() %>% addTiles() %>% setView(0,0,1)

l %>% addGraticule()

# Custom Params
l %>% addGraticule(interval = 40, style = list(color='#FF0000', weight=1))

# on a toggleable Layer
l %>%
  addGraticule(group="graticule") %>%
  addLayersControl(
    overlayGroups = c("graticule"),
    options = layersControlOptions(collapsed = FALSE)
  )
