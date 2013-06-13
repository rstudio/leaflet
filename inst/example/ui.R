library(leaflet)
library(ShinyDash)

addResourcePath(
  prefix = 'shinyDash',
  directoryPath = system.file('shinyDash', package='ShinyDash'))

shinyUI(basicPage(
  leafletMap("map", 800, 600, options=list(
    center = c(37.45, -93.85),
    zoom = 4
  )),
  htmlWidgetOutput(
      outputId = 'desc',
      HTML(paste(
        'The map is centered at <span id="lat"></span>, <span id="lng"></span>',
        'with a zoom level of <span id="zoom"></span>.<br/>',
        '<span id="shownCities"></span> out of <span id="totalCities"></span> known cities are displayed.'
      ))
  ),
  tags$br(),
  actionButton('randomLocation', 'Random location'),
  tags$hr(),
  checkboxInput('randomMarkers', 'Spray random markers on map move/zoom'),
  tags$hr(),
  numericInput('lat', 'Latitude', 37.45),
  numericInput('lng', 'Longitude', -93.85),
  checkboxInput('draggable', 'Draggable?'),
  actionButton('addMarker', 'Add marker'),
  tags$hr(),
  actionButton('clearMarkers', 'Clear markers'),
  tags$hr(),
  verbatimTextOutput('mapInfo')
))