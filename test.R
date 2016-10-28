.libPaths()

packageVersion("leaflet")

library(leaflet)

leaflet() %>% addAwesomeMarkers(0,0)
