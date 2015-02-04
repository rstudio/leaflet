#' Methods to add event listener map widget
#'
#' A series of methods to manipulate the map.
#' @param map a map widget object created from \code{\link{leaflet}()}
#' @param ... any arguments with names equal to event name, and value to javascript function. See example.
#' @references \url{http://leafletjs.com/reference.html#map-click}
#' @return The modified map widget.
#' @export
#' @examples library(leaflet)
#' m = leaflet() %>% addTiles() %>% setView(-93.65, 42.0285, zoom = 17) %>%
#'  addEventListener(click ="function(e) {alert('click');}",
#'  zoomend ="function(e) {alert('zoomend');}")
#'  m
addEventListener = function(map, ...) {

  list.event <- list(...)

  list.event <- lapply(names(list.event), function(x){
    list(method = x, event = JS(list.event[[x]]))
  })

  map$x$addEventListener = list.event

  map
}
