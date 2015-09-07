

leafletDrawDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "Leaflet.draw",
      "1.0.0",
      system.file("htmlwidgets/lib/Leaflet.draw/dist/", package = "leaflet"),
      script = "leaflet.draw.js",
      stylesheet="leaflet.draw.css"
    ),
    htmltools::htmlDependency(
      "leaflet-draw-plugin",
      "0.2.3",
      system.file("htmlwidgets/plugins/leaflet-draw-plugin/", package = "leaflet"),
      script = "leaflet-draw-plugin.js"
    )    )
}


#' Add/remove drawing toolbar
#'
#' Leaflet.draw plugin:
#' https://github.com/Leaflet/Leaflet.draw
#' @param map the map to add/remove the toolbar to/from
#' @return modified map object
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


