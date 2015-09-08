library(leaflet)

# Default Behavior
leaflet() %>% addTiles() %>% addMagnifyingGlass()

# With a Control Button
leaflet() %>% addTiles() %>% addMagnifyingGlass(showControlButton = TRUE)

# In a togglable layer
leaflet() %>% addTiles() %>%
  addMagnifyingGlass(group='magnify') %>%
  addLayersControl(
    overlayGroups = c("magnify"),
    options = layersControlOptions(collapsed = FALSE)
  )
