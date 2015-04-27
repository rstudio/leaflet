# Given a local and/or remote operation and a map, execute one or the other
# depending on the type of the map object (regular or map proxy). If code was
# not provided for the appropriate mode, an error will be raised.
dispatch = function(map,
  local = stop("Operation requires a map proxy object"),
  remote = stop("Operation does not support map proxy objects")
) {
  if (inherits(map, "leaflet"))
    return(local)
  else if (inherits(map, "leaflet_remote"))
    return(remote)
  else
    stop("Invalid map parameter")
}

# remove NULL elements from a list
filterNULL = function(x) {
  if (length(x) == 0 || !is.list(x)) return(x)
  x[!unlist(lapply(x, is.null))]
}

appendMapData = function(map, data, component, ...) {
  method = component
  args = evalFormula(list(...), data)

  dispatch(map,
    local = {
      x = map$x$calls
      if (is.null(x)) x = list()
      n = length(x)
      x[[n + 1]] = list(method = component, args = args)
      map$x$calls = x
      map
    },
    remote = {
      invokeRemote(map, method, args)
      map
    }
  )
}

#' Send commands to a Leaflet instance in a Shiny app
#'
#' Creates a map-like object that can be used to customize and control a map
#' that has already been rendered. For use in Shiny apps and Shiny docs only.
#'
#' Normally, you create a Leaflet map using the \code{\link{leaflet}} function.
#' This creates an in-memory representation of a map that you can customize
#' using functions like \code{\link{addPolygons}} and \code{\link{setView}}.
#' Such a map can be printed at the R console, included in an R Markdown
#' document, or rendered as a Shiny output.
#'
#' In the case of Shiny, you may want to further customize a map, even after it
#' is rendered to an output. At this point, the in-memory representation of the
#' map is long gone, and the user's web browser has already realized the Leaflet
#' map instance.
#'
#' This is where \code{getMapProxy} comes in. It returns an object that can
#' stand in for the usual Leaflet map object. The usual map functions like
#' \code{\link{addPolygons}} and \code{\link{setView}} can be called, and
#' instead of customizing an in-memory representation, these commands will
#' execute on the live Leaflet map instance.
#'
#' @param mapId single-element character vector indicating the output ID of the
#'   map to modify
#' @param session the Shiny session object to which the map belongs; usually the
#'   default value will suffice
#' @param data a data object; see Details under the \code{\link{leaflet}} help
#'   topic
#' @param deferUntilFlush indicates whether actions performed against this
#'   instance should be carried out right away, or whether they should be held
#'   until after the next time all of the outputs are updated; defaults to
#'   \code{TRUE}
#'
#' @examples
#' \donttest{
#' library(shiny)
#'
#' ui <- fluidPage(
#'   leafletOutput("map1")
#' )
#'
#' server <- function(input, output, session) {
#'   output$map1 <- renderLeaflet({
#'     leaflet() %>% addCircleMarkers(
#'       lng = runif(10),
#'       lat = runif(10),
#'       layerId = paste0("marker", 1:10))
#'   })
#'
#'   observeEvent(input$map1_marker_click, {
#'     getMapProxy("map1", session) %>%
#'       removeMarker(input$map1_marker_click$id)
#'   })
#' }
#'
#' shinyApp(ui, server)
#'
#' }
#'
#' @export
getMapProxy <- function(mapId, session = shiny::getDefaultReactiveDomain(),
  data = NULL, deferUntilFlush = TRUE) {
  structure(
    list(
      session = session,
      id = mapId,
      x = structure(
        list(),
        leafletData = data
      ),
      deferUntilFlush = deferUntilFlush
    ),
    class = "leaflet_remote"
  )
}

invokeRemote = function(map, method, args = list()) {
  if (!inherits(map, "leaflet_remote"))
    stop("Invalid map parameter; map proxy object was expected")

  msg <- list(
    id = map$id,
    calls = list(
      list(
        method = method,
        args = args
      )
    )
  )

  if (map$deferUntilFlush) {
    map$session$onFlushed(function() {
      map$session$sendCustomMessage("leaflet-calls", msg)
    }, once = TRUE)
  } else {
    map$session$sendCustomMessage("leaflet-calls", msg)
  }
}

# A helper function to generate the body of function(x, y) list(x = x, y = y),
# to save some typing efforts in writing tileOptions(), markerOptions(), ...
makeListFun = function(list) {
  if (is.function(list)) list = formals(list)
  nms = names(list)
  cat(sprintf('list(%s)\n', paste(nms, nms, sep = ' = ', collapse = ', ')))
}

"%||%" = function(a, b) {
  if (!is.null(a)) a else b
}
