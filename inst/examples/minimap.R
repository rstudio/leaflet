library(leaflet)

l <- leaflet() %>% setView(0,0,1)

#' Default Minimap
l %>% addTiles() %>% addMiniMap()

#' <br/>
#' Different basemap for the minimap and togglable
l %>% addProviderTiles(providers$Esri.WorldStreetMap) %>%
  addMiniMap(
             tiles = providers$Esri.WorldStreetMap,
             toggleDisplay = T)
