

leafletDrawDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "Leaflet.draw",
      "0.2.3",
      system.file("htmlwidgets/lib/Leaflet.draw/dist/", package = "leaflet"),
      script = "leaflet.draw.js",
      stylesheet="leaflet.draw.css"
    ),
    htmltools::htmlDependency(
      "leaflet-draw-plugin",
      "0.0.1",
      system.file("htmlwidgets/plugins/leaflet-draw-plugin/", package = "leaflet"),
      script = "leaflet-draw-plugin.js"
    )    )
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
#'         \code{type} and \type(coordinates), so for example to get the
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
                           circle=TRUE,marker=TRUE,edit=TRUE) {

  position = match.arg(position)
  map$dependencies <- c(map$dependencies, leafletDrawDependencies())
  map$drawToolbar<-T
  invokeMethod(map,getMapData(map),method =  'addDrawToolbar',layerID,position,
               polyline,polygon,rectangle,circle,marker,edit)
}

#' @describeIn addDrawToolbar
#' @export
removeDrawToolbar <- function(map){
  map$dependencies <- c(map$dependencies, leafletDrawDependencies())
  invokeMethod(map,getMapData(map),method =  'removeDrawToolbar')
}


