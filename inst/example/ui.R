library(leaflet)

shinyUI(basicPage(
  leafletMapOutput("map", 800, 600, options=list(
    center = c(51.505, -0.09),
    zoom = 13
  )),
  tags$br(),
  actionButton('randomLocation', 'Random location'),
  tags$hr(),
  checkboxInput('randomMarkers', 'Spray random markers on map move/zoom'),
  tags$hr(),
  numericInput('lat', 'Latitude', 51.505),
  numericInput('lng', 'Longitude', -0.09),
  checkboxInput('draggable', 'Draggable?'),
  actionButton('addMarker', 'Add marker'),
  tags$hr(),
  actionButton('clearMarkers', 'Clear markers'),
  tags$hr(),
  verbatimTextOutput('mapInfo')
))