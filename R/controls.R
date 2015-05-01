#' @param html the content of the control. May be provided as string or as
#'   HTML generated with Shiny/htmltools tags
#' @param position position of control: 'topleft', 'topright',
#'   'bottomleft', or 'bottomright'
#' @param controlId the id of this control
#' @param classes extra CSS classes to append to the control
#'
#' @describeIn map-layers Add arbitrary HTML controls to the map
#' @export
addControl = function(map,
    html,
    position=c('topleft', 'topright', 'bottomleft', 'bottomright'),
    controlId=NULL,
    classes=c('info', 'legend'),
    data=getMapData(map)) {

    position <-
        if (missing(position)) position[1]
        else position

    classes <- paste(classes, collapse=' ')
    deps <- htmltools::resolveDependencies(htmltools::findDependencies(html))
    html <- as.character(html)

    map$dependencies <- c(map$dependencies, deps)
    invokeMethod(map, data, 'addControl', html, position, controlId, classes)
}

#' @export
removeControl = function(map, controlId) {
    invokeMethod(map, NULL, 'removeControl', controlId)
}

#' @export
clearControls = function(map) {
    invokeMethod(map, NULL, 'clearControls')
}

