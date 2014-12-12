#' Wrapper functions for using \pkg{leafletjs} in \pkg{shiny}
#'
#' Use \code{leafletOutput()} to create a UI element, and \code{renderLeaflet()}
#' to render the map widget.
#' @inheritParams htmlwidgets::shinyWidgetOutput
#' @param width,height the width and height of the map (see
#'   \code{\link[htmlwidgets]{shinyWidgetOutput}})
#' @rdname map-shiny
#' @export
leafletOutput = function(outputId, width = "100%", height = 400) {
  htmlwidgets::shinyWidgetOutput(outputId, "leaflet", width, height, "leaflet")
}

#' @rdname map-shiny
#' @export
renderLeaflet = function(expr, env = parent.frame(), quoted = FALSE) {
  htmlwidgets::shinyRenderWidget(expr, leafletOutput, env, quoted = TRUE)
}

#' Create a Leaflet map controller
#'
#' This function is called from \file{server.R} and returns an object that can
#' be used to manipulate the Leaflet map from R.
#' @param session The \code{session} argument passed through from the
#'   \code{\link[shiny]{shinyServer}} server function.
#' @param id The string identifier that was passed to
#'   \code{\link{leaflet}()}.
#' @return A list of methods. See the package vignette \code{vignette('intro',
#'   'leaflet'} for details.
#' @keywords internal
leafletController = function(session, id) {

  # This function is how we "dynamically" invoke code on the client. The
  # method parameter indicates what leaflet operation we want to perform,
  # and the other arguments will be serialized to JS objects and used as
  # client side function args.
  send = function(method, func, msg) {

    msg = msg[names(formals(func))]
    names(msg) = NULL

    opts = options(digits = 22)
    on.exit(options(opts))

    session$sendCustomMessage('leaflet', list(
      mapId = id,
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
  stub = function(p) {
    # The function name is the first element
    name = as.character(p[[1]])

    # Get textual representation of the expression; change name to "function"
    # and add a NULL function body
    txt = paste(deparse(p), collapse = "\n")
    txt = sub(name, "function", txt, fixed = TRUE)
    txt = paste0(txt, "NULL")

    # Create the function
    func = eval(parse(text = txt))

    # Replace the function body
    body(func) = substituteDirect(
      quote(send(name, sys.function(), as.list(environment()))),
      list(name = name)
    )
    environment(func) = environment(send)

    # Return as list
    structure(list(func), names = name)
  }

  obj = lapply(expression(
    setView(lat, lng, zoom, forceReset = FALSE),
    addMarker(lat, lng, layerId = NULL, options = list()),
    addCircleMarker(lat, lng, radius, layerId = NULL, options = list()),
    clearMarkers(),
    clearShapes(),
    fitBounds(lat1, lng1, lat2, lng2),
    addCircle(lat, lng, radius, layerId = NULL, options = list()),
    addRectangle(lat1, lng1, lat2, lng2, layerId = NULL, options = list()),
    addPolyline(lat, lng, layerId, options = list()),
    addPolygon(lat, lng, layerId, options = list()),
    addGeoJSON(data, layerId),
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
