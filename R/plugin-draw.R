

leafletDrawDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "Leaflet.draw",
      "0.2.3",
      system.file("htmlwidgets/lib/Leaflet.draw/dist/", package = "leaflet"),
      script = "leaflet.draw-src.js",
      stylesheet="leaflet.draw.css"
    ),
    htmltools::htmlDependency(
      "leaflet-draw-plugin",
      "0.0.1",
      system.file("htmlwidgets/plugins/leaflet-draw-plugin/", package = "leaflet"),
      script = "leaflet-draw-plugin.js"
    )
  )
}


#' Add/remove drawing toolbar
#'
#' Leaflet.draw plugin:
#' https://github.com/Leaflet/Leaflet.draw
#' @param map the map to add/remove the toolbar to/from
#' @param layerID string, the layerID of the layer where drawn object will be
#'        added
#' @param position string, the position of the toolbar
#' @param polyline logical
#' @param polygon logical
#' @param rectangle logical
#' @param circle logical
#' @param marker logical
#' @param edit logical
#' @param remove logical
#' @return Modified map object.
#'         If used in a shiny app it will return input on every object created,
#'         edited or deleted.
#'         The input name will be \code{layerID_action} where
#'         \code{layerID} is
#'         the string passed to the function \code{addDrawToolbar},
#'         \code{action} is one of \code{create, delete, edit}.
#'         The input will contain a list with the GeoJSON representation of the
#'         created, edited or deleted item. In particular the input will be a
#'         list, the third component of that is a list with components
#'         \code{type} and \code{coordinates}, so for example to get the
#'         coordinates of a newly created item just use:
#'         \code{input$drawnItems_create[[3]]$coordinates}.
#' @export
#' @examples
#' map <- addTiles(leaflet())
#' map <- addDrawToolbar(map)
#' map
addDrawToolbar <- function(map,layerID="drawnItems",
                           position = c('topleft', 'topright', 'bottomleft',
                                        'bottomright'),
                           polyline=TRUE,polygon=TRUE,rectangle=TRUE,
                           circle=TRUE,marker=TRUE,edit=TRUE, remove=TRUE) {

  position = match.arg(position)
  map$dependencies <- c(map$dependencies, leafletDrawDependencies())
  map$drawToolbar<-T
  invokeMethod(map,getMapData(map),method =  'addDrawToolbar',layerID,position,
               polyline,polygon,rectangle,circle,marker,edit,remove)
}

#' Customize draw plugin behavior
#'
#' Constructors for options objects that can be passed as the corresponding
#' parameter to \code{\link{addDrawToolbar}}.
#'
#' @param allowIntersection determines if line segments can cross
#' @param drawError configuration options for the error that displays if an
#'   intersection is detected
#' @param guidelineDistance distance in pixels between each guide dash
#' @param shapeOptions the options used when drawing the polyline/polygon on the
#'   map
#' @param metric determines which measurement system (metric or imperial) is
#'   used
#' @param zIndexOffset this should be a high number to ensure that you can draw
#'   over all other layers on the map
#' @param repeatMode determines if the draw tool remains enabled after drawing a
#'   shape
#'
#' @export
drawPolylineOptions <- function(allowIntersection = TRUE,
  drawError = list(color = "#b00b00", timeout = 2500),
  guidelineDistance = 20,
  shapeOptions = list(stroke = TRUE, color = '#f06eaa', weight = 4,
    opacity = 0.5, fill = FALSE, clickable = TRUE
  ), metric = TRUE, zIndexOffset = 2000, repeatMode = FALSE
) {
  list(
    allowIntersection = allowIntersection,
    drawError = drawError,
    guidelineDistance = guidelineDistance,
    shapeOptions = shapeOptions,
    metric = metric,
    zIndexOffset = zIndexOffset,
    repeatMode = repeatMode
  )
}

#' @rdname drawPolylineOptions
#' @param showArea Show the area of the drawn polygon. \strong{The area is only
#'   approximate and become less accurate the larger the polygon is.}
#' @export
drawPolygonOptions <- function(allowIntersection = TRUE,
  drawError = list(color = "#b00b00", timeout = 2500),
  guidelineDistance = 20,
  shapeOptions = list(stroke = TRUE, color = '#f06eaa', weight = 4,
    opacity = 0.5, fill = TRUE, fillColor = NULL, fillOpacity = 0.2,
    clickable = TRUE
  ), metric = TRUE, zIndexOffset = 2000, repeatMode = FALSE, showArea = FALSE
) {
  if (isTRUE(showArea) && isTRUE(allowIntersection)) {
    warning("showArea = TRUE will be ignored because allowIntersection is TRUE")
  }

  list(
    allowIntersection = allowIntersection,
    drawError = drawError,
    guidelineDistance = guidelineDistance,
    shapeOptions = shapeOptions,
    metric = metric,
    zIndexOffset = zIndexOffset,
    repeatMode = repeatMode,
    showArea = showArea
  )
}

#' @rdname drawPolylineOptions
#' @export
drawRectangleOptions <- function(shapeOptions = list(
  stroke = TRUE, color = '#f06eaa', weight = 4, opacity = 0.5,
  fill = TRUE, fillColor = NULL, fillOpacity = 0.2, clickable = TRUE),
  metric = TRUE, repeatMode = FALSE) {

  list(
    shapeOptions = shapeOptions,
    metric = metric,
    repeatMode = repeatMode
  )
}

#' @rdname drawPolylineOptions
#' @param showRadius whether to show the radius of the drawn circle
#' @export
drawCircleOptions <- function(shapeOptions = list(
  stroke = TRUE, color = '#f06eaa', weight = 4, opacity = 0.5,
  fill = TRUE, fillColor = NULL, fillOpacity = 0.2, clickable = TRUE),
  showRadius = TRUE, metric = TRUE, repeatMode = FALSE) {

  list(
    shapeOptions = shapeOptions,
    showRadius = showRadius,
    metric = metric,
    repeatMode = repeatMode
  )
}

#' @rdname drawPolylineOptions
#'
#' @param icon a custom icon, as created by \code{\link{makeIcon}}
#'
#' @export
drawMarkerOptions <- function(icon = NULL, zIndexOffset = 2000,
  repeatMode = FALSE) {

  if (!is.null(icon)) {
    if (!inherits(icon, "leaflet_icon")) {
      stop("Icon must be created using the makeIcon() function")
    }
    icon$iconUrl <- b64EncodePackedIcons(packStrings(icon$iconUrl))$data
    icon$iconRetinaUrl <- b64EncodePackedIcons(packStrings(icon$iconRetinaUrl))$data
    icon$iconShadowUrl <- b64EncodePackedIcons(packStrings(icon$iconShadowUrl))$data
    icon$iconShadowRetinaUrl <- b64EncodePackedIcons(packStrings(icon$iconShadowRetinaUrl))$data
  }

  filterNULL(list(icon = icon, zIndexOffset = zIndexOffset, repeatMode = repeatMode))
}

#' @describeIn addDrawToolbar
#' @export
removeDrawToolbar <- function(map){
  invokeMethod(map,getMapData(map),method =  'removeDrawToolbar')
}
