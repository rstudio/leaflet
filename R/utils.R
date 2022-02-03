# @staticimports pkg:staticimports
#  is_installed system_file get_package_version

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
dispatch <- function(map,
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

#' remove NULL elements from a list
#' @param x A list whose NULL elements will be filtered
#' @export
filterNULL <- function(x) {
  if (length(x) == 0 || !is.list(x)) return(x)
  x[!unlist(lapply(x, is.null))]
}

#' @param data a data object that will be used when evaluating formulas in
#'   \code{...}
#' @param method the name of the JavaScript method to invoke
#' @param ... unnamed arguments to be passed to the JavaScript method
#' @rdname dispatch
#' @import crosstalk
#' @export
invokeMethod <- function(map, data, method, ...) {
  if (crosstalk::is.SharedData(data)) {
    map$dependencies <- c(map$dependencies, crosstalk::crosstalkLibs())
    data <- data$data()
  } else {
    NULL
  }

  args <- evalFormula(list(...), data)

  dispatch(map,
    method,
    leaflet = {
      x <- map$x$calls
      if (is.null(x)) x <- list()
      n <- length(x)
      x[[n + 1]] <- list(method = method, args = args)
      map$x$calls <- x
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
#'   map to modify (if invoked from a Shiny module, the namespace will be added
#'   automatically)
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
#' library(shiny)
#'
#' ui <- fluidPage(
#'   leafletOutput("map1")
#' )
#'
#' map <- leaflet() %>% addCircleMarkers(
#'   lng = runif(10),
#'   lat = runif(10),
#'   layerId = paste0("marker", 1:10))

#' server <- function(input, output, session) {
#'   output$map1 <- renderLeaflet(map)
#'
#'   observeEvent(input$map1_marker_click, {
#'     leafletProxy("map1", session) %>%
#'       removeMarker(input$map1_marker_click$id)
#'   })
#' }
#'
#' app <- shinyApp(ui, server)
#' \donttest{if (interactive()) app}
#'
#' @export
leafletProxy <- function(mapId, session = shiny::getDefaultReactiveDomain(),
  data = NULL, deferUntilFlush = TRUE) {

  if (is.null(session)) {
    stop("leafletProxy must be called from the server function of a Shiny app")
  }

  # If this is a new enough version of Shiny that it supports modules, and
  # we're in a module (nzchar(session$ns(NULL))), and the mapId doesn't begin
  # with the current namespace, then add the namespace.
  #
  # We could also have unconditionally done `mapId <- session$ns(mapId)`, but
  # older versions of Leaflet would have broken unless the user did session$ns
  # themselves, and we hate to break their code unnecessarily.
  #
  # This won't be necessary in future versions of Shiny, as session$ns (and
  # other forms of ns()) will be smart enough to only namespace un-namespaced
  # IDs.
  if (
    !is.null(session$ns) &&
    nzchar(session$ns(NULL)) &&
    substring(mapId, 1, nchar(session$ns(""))) != session$ns("")
  ) {
    mapId <- session$ns(mapId)
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
sessionFlushQueue <- new.env(parent = emptyenv())

invokeRemote <- function(map, method, args = list()) {
  if (!inherits(map, "leaflet_proxy"))
    stop("Invalid map parameter; map proxy object was expected")

  deps <- htmltools::resolveDependencies(map$dependencies)

  msg <- list(
    id = map$id,
    calls = list(
      list(
        dependencies = lapply(deps, shiny::createWebDependency),
        method = method,
        args = args,
        evals = htmlwidgets::JSEvals(args)
      )
    )
  )

  sess <- map$session
  if (map$deferUntilFlush) {
    if (is_installed("shiny", "0.12.1.9000")) {

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
        }, once = TRUE) # nolint
      }

      # Append the current value to the apporpriate sessionFlushQueue entry,
      # which is now guaranteed to exist.
      sessionFlushQueue[[sess$token]] <- c(sessionFlushQueue[[sess$token]], list(msg))

    } else {
      sess$onFlushed(function() {
        sess$sendCustomMessage("leaflet-calls", msg)
      }, once = TRUE) # nolint
    }
  } else {
    sess$sendCustomMessage("leaflet-calls", msg)
  }
  map
}

# A helper function to generate the body of function(x, y) list(x = x, y = y),
# to save some typing efforts in writing tileOptions(), markerOptions(), ...
makeListFun <- function(list) {
  if (is.function(list)) list <- formals(list)
  nms <- names(list)
  cat(sprintf("list(%s)\n", paste(nms, nms, sep = " = ", collapse = ", ")))
}

"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}

#' Utility function to check if a coordinates is valid
#' @param lng vector with longitude values
#' @param lat vector with latitude values
#' @param funcName Name of calling function
#' @param warn A boolean. Whether to generate a warning message if there are rows with missing/invalid data
#' @param mode if \code{"point"} then warn about any \code{NA} lng/lat values;
#'   if \code{"polygon"} then \code{NA} values are expected to be used as
#'   polygon delimiters
#' @export
validateCoords <- function(lng, lat, funcName, warn = TRUE,
  mode = c("point", "polygon")) {

  mode <- match.arg(mode)

  if (is.null(lng) && is.null(lat)) {
    stop(funcName, " requires non-NULL longitude/latitude values")
  } else if (is.null(lng)) {
    stop(funcName, " requires non-NULL longitude values")
  } else if (is.null(lat)) {
    stop(funcName, " requires non-NULL latitude values")
  }

  if (!is.numeric(lng) && !is.numeric(lat)) {
    stop(funcName, " requires numeric longitude/latitude values")
  } else if (!is.numeric(lng)) {
    stop(funcName, " requires numeric longitude values")
  } else if (!is.numeric(lat)) {
    stop(funcName, " requires numeric latitude values")
  }

  if (mode == "point") {
    incomplete <- is.na(lat) | is.na(lng)
   if (any(incomplete)) {
      warning(sprintf("Data contains %s rows with either missing or invalid lat/lon values and will be ignored", sum(incomplete))) # nolint
    }
  } else if (mode == "polygon") {
    incomplete <- is.na(lat) != is.na(lng)
   if (any(incomplete)) {
      warning(sprintf("Data contains %s rows with either missing or invalid lat/lon values and will be ignored", sum(incomplete))) # nolint
    }
    lng <- lng[!incomplete]
    lat <- lat[!incomplete]
  }

  data.frame(lng = lng, lat = lat)

}
