library(leaflet)
# Default
leaflet() %>% addTiles() %>% addMiniMap()

# Custom Options
leaflet() %>% addTiles() %>% addMiniMap(toggleDisplay = T)
