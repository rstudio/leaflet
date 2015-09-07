library(leaflet)

leaflet() %>% addTiles() %>% addMagnifyingGlass()

leaflet() %>% addTiles() %>%
  addMagnifyingGlass(group='magnify') %>%
  addLayersControl(
    overlayGroups = c("magnify"),
    options = layersControlOptions(collapsed = FALSE)
  )
