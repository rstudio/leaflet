library(leaflet)
mapbox.tileIds <- list('Recent Imagery with Streets'='digitalglobe.nal0mpda',
                       'Recent Imagery'='digitalglobe.nal0g75k',
                       'Street Map'='digitalglobe.nako6329',
                       'Terrain Map'='digitalglobe.nako1fhg')

m <- leaflet() %>% setView(0,0,1)

names(mapbox.tileIds) %>%
  purrr::walk(function(x) {
    m <<- m %>%
      addProviderTiles(providers$MapBox, group = x,
                       options = providerTileOptions(
                         detectRetina = TRUE,
                         # id and accessToken are Mapbox specific options
                         id = mapbox.tileIds[[x]] ,
                         accessToken = Sys.getenv('DIGITALGLOBE_API_KEY')
                       ))
  })

m %>%
  setView(-77.0353, 38.8895, 15) %>%
  addLayersControl(
    baseGroups = names(mapbox.tileIds),
    options = layersControlOptions(collapsed = FALSE)
  )
