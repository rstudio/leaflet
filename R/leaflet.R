#' Create a Leaflet map object in R
#'
#' This function is called from \file{server.R} and returns an object that can
#' be used to manipulate the Leaflet map from R.
#' @param session The \code{session} argument passed through from the
#'   \code{\link[shiny]{shinyServer}} server function.
#' @param outputId The string identifier that was passed to the corresponding
#'   \code{\link{leafletMap}()}.
#' @return A list of methods. See the package vignette \code{vignette('intro',
#'   'leaflet'} for details.
#' @importFrom shiny renderText
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

  structure(c(
    stub(setView(lat, lng, zoom, forceReset = FALSE)),
    stub(addMarker(lat, lng, layerId=NULL, options=list(), eachOptions=list())),
    stub(addCircleMarker(lat, lng, radius, layerId = NULL, options = list(), eachOptions=list())),
    stub(clearMarkers()),
    stub(clearShapes()),
    stub(fitBounds(lat1, lng1, lat2, lng2)),
    stub(addCircle(lat, lng, radius, layerId = NULL, options=list(), eachOptions=list())),
    stub(addRectangle(lat1, lng1, lat2, lng2, layerId = NULL, options=list(), eachOptions=list())),
    stub(addPolygon(lat, lng, layerId, options, defaultOptions)),
    stub(addGeoJSON(data, layerId)),
    stub(showPopup(lat, lng, content, layerId = NULL, options=list())),
    stub(removePopup(layerId)),
    stub(clearPopups()),
    stub(removeShape(layerId)),
    stub(clearShapes()),
    stub(removeMarker(layerId)),
    stub(clearMarkers())
  ), class = "leaflet_map")
}

#' Create a \code{div} element for a Leaflet map
#'
#' This function is called from \file{ui.R} (or from
#' \code{\link[shiny]{renderUI}()}); it creates a \code{<div>} that will contain
#' a Leaflet map.
#' @param outputId the id of the \samp{<div>} element
#' @param width,height The width and height of the map. They can either take a
#'   CSS length (e.g. \code{400px} or \code{50\%}) or a numeric value which will
#'   be interpreted as pixels.
#' @param initialTileLayer The URL template for the initial layer of tile images
#'   (the OpenStreetMap tiles are used by default). See
#'   \url{http://leafletjs.com/reference.html#tilelayer} for information about
#'   providing tile layer URLs.
#' @param initialTileLayerAttribution The attribution text of the map tiles.
#'   This is a link to OpenStreetMap with the license CC-BY-SA 2.0 by default.
#' @param options A list of map options. See
#'   \url{http://leafletjs.com/reference.html#map-options} for a full list of
#'   options.
#' @return An HTML tag list.
#' @export
leafletMap <- function(
  outputId, width, height,
  initialTileLayer = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  initialTileLayerAttribution,
  options = NULL
) {

  if (missing(initialTileLayerAttribution) && missing(initialTileLayer)) {
    initialTileLayerAttribution <- HTML('&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>')
  }

  addResourcePath("leaflet", system.file("www", package="leaflet"))

  if (is.numeric(width))
    width <- sprintf("%dpx", width)
  if (is.numeric(height))
    height <- sprintf("%dpx", height)

  tagList(
    singleton(
      tags$head(
        tags$link(rel="stylesheet", type="text/css", href="leaflet/leaflet.css"),
        tags$script(src="leaflet/leaflet.js"),
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
