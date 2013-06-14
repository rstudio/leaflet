#' @export
createLeafletMap <- function(session, outputId) {
  send <- function(method, ...) {
    origDigits <- getOption('digits')
    options(digits=22)
    on.exit(options(digits=origDigits))
    session$sendCustomMessage('leaflet', list(
      mapId = outputId,
      method = method,
      args = list(...)
    ))
  }
  list(
    setView = function(lat, lng, zoom, forceReset = FALSE) {
      send('setView', lat, lng, zoom, forceReset)
    },
    addMarker = function(lat, lng, layerId = NULL, options = list()) {
      send('addMarker', lat, lng, layerId, options)
    },
    clearMarkers = function() {
      send('clearMarkers')
    },
    clearShapes = function() {
      send('clearShapes')
    },
    fitBounds = function(lat1, lng1, lat2, lng2) {
      send('fitBounds', lat1, lng1, lat2, lng2)
    },
    addRectangle = function(lat1, lng1, lat2, lng2,
                            layerId = NULL, options=list()) {
      send('addRectangle', lat1, lng1, lat2, lng2, layerId, options)
    },
    addCircle = function(lat1, lng1, radius, layerId = NULL, options=list()) {
      send('addCircle', lat1, lng1, radius, layerId, options)
    },
    showPopup = function(lat1, lng1, content, layerId = NULL, options=list()) {
      send('showPopup', lat1, lng1, content, layerId, options)
    },
    clearPopups = function() {
      send('clearPopups')
    }
  )
}

#' @export
leafletMap <- function(
  outputId, width, height,
  initialTileLayer = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', 
  initialTileLayerAttribution = HTML('&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'),
  options=NULL) {
  
  addResourcePath("leaflet", system.file("www", package="leaflet"))

  if (is.numeric(width))
    width <- sprintf("%dpx", width)
  if (is.numeric(height))
    height <- sprintf("%dpx", height)
  
  tagList(
    singleton(
      tags$head(
        HTML('<link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.5/leaflet.css" />
<!--[if lte IE 8]>
  <link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.5/leaflet.ie.css" />
<![endif]-->
<script src="http://cdn.leafletjs.com/leaflet-0.5/leaflet.js"></script>'),
        tags$script(src="leaflet/binding.js")
      )
    ),
    tags$div(
      id = outputId, class = "leaflet-map-output",
      style = sprintf("width: %s; height: %s", width, height),
      `data-initial-tile-layer` = initialTileLayer,
      `data-initial-tile-layer-attrib` = initialTileLayerAttribution,
      
      tags$script(
        type="application/json", class="leaflet-options",
        ifelse(is.null(options), "{}", RJSONIO::toJSON(options))
      )
    )
  )
}
