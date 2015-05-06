#' @param html the content of the control. May be provided as string or as HTML
#'   generated with Shiny/htmltools tags
#' @param position position of control: 'topleft', 'topright', 'bottomleft', or
#'   'bottomright'
#' @param classes extra CSS classes to append to the control
#'
#' @describeIn map-layers Add arbitrary HTML controls to the map
#' @export
addControl = function(
  map, html, position = c('topleft', 'topright', 'bottomleft', 'bottomright'),
  layerId = NULL, classes = c('info', 'legend'), data = getMapData(map)
) {

    position = match.arg(position)

    classes = paste(classes, collapse = ' ')
    deps = htmltools::resolveDependencies(htmltools::findDependencies(html))
    html = as.character(html)

    map$dependencies = c(map$dependencies, deps)
    invokeMethod(map, data, 'addControl', html, position, layerId, classes)
}

#' @export
#' @rdname remove
removeControl = function(map, layerId) {
    invokeMethod(map, NULL, 'removeControl', layerId)
}

#' @export
#' @rdname remove
clearControls = function(map) {
    invokeMethod(map, NULL, 'clearControls')
}

