#' @export
createLeafletMap <- function(session, outputId) {

  # Need to provide some trivial output, just to get the binding to render
  session$output[[outputId]] <- renderText("")

  # This function is how we "dynamically" invoke code on the client. The
  # method parameter indicates what leaflet operation we want to perform,
  # and the other arguments will be serialized to JS objects and used as
  # client side function args.
  send <- function(method, func, msg) {
    
    msg <- msg[names(formals(func))]
    names(msg) <- NULL
    
    origDigits <- getOption('digits')
    options(digits=22)
    on.exit(options(digits=origDigits))
    session$sendCustomMessage('leaflet', list(
      mapId = outputId,
      method = method,
      args = msg
    ))
  }
  
  baseimpl <- function() {
    send(`__name__`, sys.function(), as.list(environment()))
  }
  
  # Turns a call like:
  #
  #     stub(setView(lat, lng, zoom, forceReset = FALSE))
  #
  # into:
  #
  #     list(setView = function(lat, lng, zoom, forceReset = FALSE) {
  #       send("setView", sys.function(), as.list(environment()))
  #     })
  stub <- function(prototype) {
    # Get the un-evaluated expression
    p <- substitute(prototype)
    # The function name is the first element
    name <- as.character(p[[1]])
    
    # Get textual representation of the expression; change name to "function"
    # and add a NULL function body
    txt <- paste(deparse(p), collapse = "\n")
    txt <- sub(name, "function", txt, fixed = TRUE)
    txt <- paste0(txt, "NULL")
    
    # Create the function
    func <- eval(parse(text = txt))
    
    # Replace the function body, using baseimpl's body as a template
    body(func) <- substituteDirect(
      body(baseimpl),
      as.environment(list("__name__"=name))
    )
    environment(func) <- environment(baseimpl)
    
    # Return as list
    structure(list(func), names = name)
  }
  
  c(
    stub(setView(lat, lng, zoom, forceReset = FALSE)),
    stub(addMarker(lat, lng, layerId = NULL, options = list())),
    stub(clearMarkers()),
    stub(clearShapes()),
    stub(fitBounds(lat1, lng1, lat2, lng2)),
    stub(addCircle(lat, lng, radius, layerId = NULL, options=list(), eachOptions=list())),
    stub(addRectangle(lat1, lng1, lat2, lng2, layerId = NULL, options=list())),
    stub(addPolygon(lat, lng, layerId, options, defaultOptions)),
    stub(showPopup(lat, lng, content, layerId = NULL, options=list())),
    stub(removePopup(layerId)),
    stub(clearPopups())
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
