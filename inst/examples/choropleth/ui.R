library(leaflet)

shinyUI(fluidPage(
  
  # Add a little CSS to make the map background pure white
  tags$head(tags$style("
    .leaflet-container { background-color: white !important; }
  ")),

  leafletMap(
    "map", "100%", 500,
    # By default OpenStreetMap tiles are used; we want nothing in this case
    initialTileLayer = NULL,
    initialTileLayerAttribution = NULL,
    options=list(
      center = c(40, -98.85),
      zoom = 4,
      maxBounds = list(list(17, -180), list(59, 180))
    )
  )
))
