# Given a local and/or remote operation and a map, execute one or the other
# depending on the type of the map object (regular or map proxy). If code was
# not provided for the appropriate mode, an error will be raised.

#' Extension points for plugins
#'
#' @param map a map object, as returned from \code{\link{leaflet}} or
#'   \code{\link{leafletProxy}}
#' @param funcName the name of the function that the user called that caused
#'   this \code{dispatch} call; for error message purposes
#' @param leaflet an action to be performed if the map is from
#'   \code{\link{leaflet}}
#' @param leaflet_proxy an action to be performed if the map is from
#'   \code{\link{leafletProxy}}
#'
#' @return \code{dispatch} returns the value of \code{leaflet} or
#'   \code{leaflet_proxy}, or an error. \code{invokeMethod} returns the
#'   \code{map} object that was passed in, possibly modified.
#'
#' @export
dispatch = function(map,
  funcName,
  leaflet = stop(paste(funcName, "requires a map proxy object")),
  leaflet_proxy = stop(paste(funcName, "does not support map proxy objects"))
) {
  if (inherits(map, "leaflet"))
    return(leaflet)
  else if (inherits(map, "leaflet_proxy"))
    return(leaflet_proxy)
  else
    stop("Invalid map parameter")
}

# remove NULL elements from a list
filterNULL = function(x) {
  if (length(x) == 0 || !is.list(x)) return(x)
  x[!unlist(lapply(x, is.null))]
}

#' @param data a data object that will be used when evaluating formulas in
#'   \code{...}
#' @param method the name of the JavaScript method to invoke
#' @param ... unnamed arguments to be passed to the JavaScript method
#' @rdname dispatch
#' @export
invokeMethod = function(map, data, method, ...) {
  args = evalFormula(list(...), data)

  dispatch(map,
    method,
    leaflet = {
      x = map$x$calls
      if (is.null(x)) x = list()
      n = length(x)
      x[[n + 1]] = list(method = method, args = args)
      map$x$calls = x
      map
    },
    leaflet_proxy = {
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
#' This is where \code{leafletProxy} comes in. It returns an object that can
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
#'     leafletProxy("map1", session) %>%
#'       removeMarker(input$map1_marker_click$id)
#'   })
#' }
#'
#' shinyApp(ui, server)
#'
#' }
#'
#' @export
leafletProxy <- function(mapId, session = shiny::getDefaultReactiveDomain(),
  data = NULL, deferUntilFlush = TRUE) {

  if (is.null(session)) {
    stop("leafletProxy must be called from the server function of a Shiny app")
  }

  structure(
    list(
      session = session,
      id = mapId,
      x = structure(
        list(),
        leafletData = data
      ),
      deferUntilFlush = deferUntilFlush,
      dependencies = NULL
    ),
    class = "leaflet_proxy"
  )
}

# Shiny versions <= 0.12.0.9001 can't guarantee that onFlushed
# callbacks are called in the order they were registered. Rather
# than wait for this to be fixed in Shiny and released to CRAN,
# work around this for older versions by maintaining our own
# queue of work items. The names in this environment are session
# tokens, and the values are lists of invokeRemote msg objects.
# During the course of execution, leafletProxy() should cause
# deferred messages to be appended to the appropriate value in
# sessionFlushQueue. It's the responsibility of invokeRemote to
# ensure that the sessionFlushQueue values are properly reaped
# as soon as possible, to prevent session objects from being
# leaked.
#
# When Shiny >0.12.0 goes to CRAN, we should update our version
# dependency and remove this entire mechanism.
sessionFlushQueue = new.env(parent = emptyenv())

invokeRemote = function(map, method, args = list()) {
  if (!inherits(map, "leaflet_proxy"))
    stop("Invalid map parameter; map proxy object was expected")

  msg <- list(
    id = map$id,
    calls = list(
      list(
        dependencies = lapply(map$dependencies, shiny::createWebDependency),
        method = method,
        args = args
      )
    )
  )

  sess <- map$session
  if (map$deferUntilFlush) {
    if (packageVersion("shiny") < "0.12.1.9000") {

      # See comment on sessionFlushQueue.

      if (is.null(sessionFlushQueue[[sess$token]])) {
        # If the current session doesn't have an entry in the sessionFlushQueue,
        # initialize it with a blank list.
        sessionFlushQueue[[sess$token]] <- list()

        # If the session ends before the next onFlushed call, remove the entry
        # for this session from the sessionFlushQueue.
        endedUnreg <- sess$onSessionEnded(function() {
          rm(list = sess$token, envir = sessionFlushQueue)
        })

        # On the next flush, pass all the messages to the client, and remove the
        # entry from sessionFlushQueue.
        sess$onFlushed(function() {
          on.exit(rm(list = sess$token, envir = sessionFlushQueue), add = TRUE)
          endedUnreg()
          for (msg in sessionFlushQueue[[sess$token]]) {
            sess$sendCustomMessage("leaflet-calls", msg)
          }
        }, once = TRUE)
      }

      # Append the current value to the apporpriate sessionFlushQueue entry,
      # which is now guaranteed to exist.
      sessionFlushQueue[[sess$token]] <- c(sessionFlushQueue[[sess$token]], list(msg))

    } else {
      sess$onFlushed(function() {
        sess$sendCustomMessage("leaflet-calls", msg)
      }, once = TRUE)
    }
  } else {
    sess$sendCustomMessage("leaflet-calls", msg)
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
