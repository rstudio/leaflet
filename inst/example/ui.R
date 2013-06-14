library(leaflet)
library(ShinyDash)

addResourcePath(
  prefix = 'shinyDash',
  directoryPath = system.file('shinyDash', package='ShinyDash'))

row <- function(...) {
  tags$div(class="row", ...)
}
col <- function(width, ...) {
  tags$div(class=paste0("span", width), ...)
}
actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}

shinyUI(bootstrapPage(
  tags$head(tags$style(type="text/css", "
                       body {overflow-y: scroll;}
                       body, #data table td {font-family: Source Sans Pro; color: #444;}
                       #desc {font-size: 16px;}
                       #desc span {color: #944; font-size: 110%;}
                       #data table td { width: 90px; }
                       #data table td:first-child { width: 180px; }
                       ")),
  leafletMap("map", "100%", 600,
             initialTileLayer = "http://{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
             initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
             options=list(
               center = c(37.45, -93.85),
               zoom = 4
             )
  ),
  tags$div(
    class = "container",
    
    tags$p(tags$br()),
    row(
      col(
        7,
        h2('Population of U.S. Cities'),
        htmlWidgetOutput(
          outputId = 'desc',
          HTML(paste(
            'The map is centered at <span id="lat"></span>, <span id="lng"></span>',
            'with a zoom level of <span id="zoom"></span>.<br/>',
            'Top <span id="shownCities"></span> out of <span id="totalCities"></span> visible cities are displayed.'
          ))
        ),
        tags$br(),
        actionLink('randomLocation', 'Go to random location'),
        tags$hr(),
        checkboxInput('addMarkerOnClick', 'Add marker on click', FALSE),
        tags$hr(),
        selectInput('maxCities', 'Maximum cities to display', choices=c(
          5,
          25,
          50,
          100,
          200,
          500,
          All = 2000
        ), selected = 100)
      ),
      col(
        5,
        conditionalPanel(
          condition = 'output.markers',
          h4('Marker locations'),
          actionLink('clearMarkers', 'Clear markers')
        ),
        tableOutput('markers'),
        conditionalPanel(
          condition = 'output.data',
          h4('Visible cities')
        ),
        tableOutput('data')
      )
    )
  )
))