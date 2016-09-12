library(leaflet)

l <- leaflet() %>% setView(0,0,3)

#' Default Minimap
l %>% addTiles() %>% addMiniMap()

#' <br/>
#' Different basemap for the minimap and togglable
l %>% addProviderTiles(providers$Esri.WorldStreetMap) %>%
  addMiniMap(
             tiles = providers$Esri.WorldStreetMap,
             toggleDisplay = T)

#' <br/>
#' Slightly advanced use case
#' Change minimap basemap to match main map's basemap
#' This approach will work for basemaps added via addProviderTiles
#' But not for one's added with addTiles using a URL schema.
m <- l
esri <- providers %>%
  purrr::keep(~ grepl('^Esri',.))

esri %>%
  purrr::walk(function(x) m <<- m %>% addProviderTiles(x,group=x))

m %>%
  addLayersControl(
    baseGroups = names(esri),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  addMiniMap(
             tiles = esri[[1]],
             toggleDisplay = T) %>%
  htmlwidgets::onRender("function(el, x) { var myMap = this; this.on('baselayerchange', function (e) { myMap.minimap.changeLayer(L.tileLayer.provider(e.name)); }) }")

