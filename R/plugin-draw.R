

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
      "1.0.0",
      system.file("htmlwidgets/plugins/leaflet-draw-plugin/", package = "leaflet"),
      script = "leaflet-draw-plugin.js"
    )    )
}


#' Add drawing toolbar
#'
#' @param map the map to add the toolbar to
#' @return modified map object
#' @export
#' @examples
#' map <- addTiles(leaflet())
#' map <- addDrawToolbar(map)
#' map
addDrawToolbar = function(map) {
 map$dependencies <- c(map$dependencies, leafletDrawDependencies())
 map$drawToolbar<-T
 invokeMethod(map,getMapData(map),method =  'addDrawToolbar')
}



