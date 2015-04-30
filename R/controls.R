#' @param position Defines position of control: 'topleft', 'topright', 'bottomleft', or 'bottomright'
#' @param html Defines content of the control. May be provided as string or as HTML generated with Shiny tags
#' @param controlId Id to assign to the control
#' @export
addControl = function(map, 
    position=c('topleft', 'topright', 'bottomleft', 'bottomright'), 
    html, 
    controlId=NULL,
    classes=c('info', 'legend'),
    data=getMapData(map)) {

    position <- 
        if (missing(position)) position[1]
        else position

    classes <- paste(classes, collapse=' ')
    html <- as.character(html);

    invokeMethod(map, data, 'addControl', position, html, controlId, classes)
}

#' @export
removeControl = function(map, controlId) {
    invokeMethod(map, NULL, 'removeControl', controlId)
}

#' @export 
clearControls = function(map) {
    invokeMethod(map, NULL, 'clearControls')
}

