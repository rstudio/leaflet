#' Legacy functions
#'
#' These functions are provided for backwards compatibility with the first
#' iteration of the leaflet bindings
#' (\url{https://github.com/jcheng5/leaflet-shiny}).
#'
#' @param session,outputId Deprecated
#'
#' @rdname deprecated
#' @export
createLeafletMap <- function(session, outputId) {

  # Need to provide some trivial output, just to get the binding to render
  session$output[[outputId]] <- shiny::renderText("")

  # This function is how we "dynamically" invoke code on the client. The
  # method parameter indicates what leaflet operation we want to perform,
  # and the other arguments will be serialized to JS objects and used as
  # client side function args.
  send <- function(method, func, msg) {

    msg <- msg[names(formals(func))]
    names(msg) <- NULL

    opts <- options(digits = 22)
    on.exit(options(opts))

    session$sendCustomMessage("leaflet", list(
      mapId = outputId,
      method = method,
      args = msg
    ))

  }

  # Turns a call like:
  #
  #     stub(expression(setView(lat, lng, zoom, forceReset = FALSE)))
  #
  # into:
  #
  #     list(setView = function(lat, lng, zoom, forceReset = FALSE) {
  #       send("setView", sys.function(), as.list(environment()))
  #     })
  stub <- function(p) {
    # The function name is the first element
    name <- as.character(p[[1]])

    # Get textual representation of the expression; change name to "function"
    # and add a NULL function body
    txt <- paste(deparse(p), collapse = "\n")
    txt <- sub(name, "function", txt, fixed = TRUE)
    txt <- paste0(txt, "NULL")

    # Create the function
    func <- eval(parse(text = txt))

    # Replace the function body
    body(func) <- substituteDirect(
      quote(send(name, sys.function(), as.list(environment()))),
      list(name = name)
    )
    environment(func) <- environment(send)

    # Return as list
    structure(list(func), names = name)
  }

  obj <- lapply(expression(
    setView(lat, lng, zoom, forceReset = FALSE),
    addMarker(lat, lng, layerId = NULL, options = list(), eachOptions = list()),
    addCircleMarker(lat, lng, radius, layerId = NULL, options = list(), eachOptions = list()),
    clearMarkers(),
    fitBounds(lat1, lng1, lat2, lng2),
    addCircle(lat, lng, radius, layerId = NULL, options = list(), eachOptions = list()),
    addRectangle(lat1, lng1, lat2, lng2, layerId = NULL, options = list(), eachOptions = list()),
    addPolygon(lat, lng, layerId, options, defaultOptions),
    addGeoJSON(data, layerId),
    clearGeoJSON(),
    showPopup(lat, lng, content, layerId = NULL, options = list()),
    removePopup(layerId),
    clearPopups(),
    removeShape(layerId),
    clearShapes(),
    removeMarker(layerId),
    clearMarkers()
  ), stub)
  unlist(obj, recursive = FALSE)
}

#' @param width,height,initialTileLayer,initialTileLayerAttribution,options Deprecated
#' @rdname deprecated
#' @export
leafletMap <- function(
  outputId, width, height,
  initialTileLayer = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
  initialTileLayerAttribution = NULL,
  options = NULL) {

  if (missing(initialTileLayer) && is.null(initialTileLayerAttribution))
    initialTileLayerAttribution <- paste(
      "&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a>",
      "contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>"
    )

  shiny::addResourcePath("leaflet-legacy", system.file("legacy/www", package = "leaflet"))

  if (is.numeric(width))
    width <- sprintf("%dpx", width)
  if (is.numeric(height))
    height <- sprintf("%dpx", height)

  htmltools::tagList(
    htmltools::singleton(
      htmltools::tags$head(
        htmltools::tags$link(
          rel = "stylesheet",
          type = "text/css",
          href = "leaflet-legacy/leaflet.css"
        ),
        htmltools::tags$script(src = "leaflet-legacy/leaflet.js"),
        htmltools::tags$script(src = "leaflet-legacy/binding.js")
      )
    ),
    htmltools::tags$div(
      id = outputId, class = "leaflet-map-output",
      style = sprintf("width: %s; height: %s", width, height),
      `data-initial-tile-layer` = initialTileLayer,
      `data-initial-tile-layer-attrib` = initialTileLayerAttribution,

      htmltools::tags$script(
        type = "application/json", class = "leaflet-options",
        ifelse(is.null(options), "{}", RJSONIO::toJSON(options))
      )
    )
  )
}
