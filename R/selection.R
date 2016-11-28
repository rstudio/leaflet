areaSelectDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-areaselect",
      "0.1.0",
      system.file("htmlwidgets/plugins/leaflet-areaselect", package = "leaflet"),
      script = c("leaflet-areaselect.js", "areaselect-bindings.js"),
      stylesheet = c("leaflet-areaselect.css")
    )
  )
}

locationFilterDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-locationfilter",
      "0.1.0",
      system.file("htmlwidgets/plugins/leaflet-locationfilter", package = "leaflet"),
      script = c("locationfilter.js", "locationfilter-bindings.js"),
      stylesheet = c("locationfilter.css")
    )
  )
}

#' Adds a resizable centered box on top of the map letting users select a square area (bounding box).
#' @param map The map widget.
#' @param width Width in pixels.
#' @param heigth Height in pixels.
#' @param keepAspectRatio if set to TRUE the aspect ratio of the selection box can be changed.
#' @export
addAreaSelect <- function(map, width = 200, height = 300, keepAspectRatio = FALSE) {
  map$dependencies <- c(map$dependencies, areaSelectDependencies())
  options <- list(width=width, height=height, keepAspectRatio = keepAspectRatio)
  invokeMethod(map, getMapData(map), 'addAreaSelect', options)
}

#' Adds a button to dynamically add/remove area selection box.
#' @param position The position of the control button.
#' @describeIn addAreaSelect shows a button to add/remove area selection box
#' @export
addAreaSelectControl <- function(
  map,
  position = c('topleft','topright','bottomleft','bottomright'),
  width = 200, height = 300, keepAspectRatio = FALSE) {
  map$dependencies <- c(map$dependencies, areaSelectDependencies())
  position = match.arg(position)
  options <- list(width=width, height=height, keepAspectRatio = keepAspectRatio)
  addEasyButton(
    map,
    easyButton(
      position = position,
      states = list(
        easyButtonState(
          stateName='disabled-areaselect',
          icon='ion-ios-crop',
          title='Add Area Selection Box',
          onClick = JS(sprintf("
            function(btn, map) {
               LeafletWidget.methods.addAreaSelect.call(map, %s);
               btn.state('enabled-areaselect');

            }", jsonlite::toJSON(options, auto_unbox=T)))
        ),
        easyButtonState(
          stateName='enabled-areaselect',
          icon='ion-crop',
          title='Remove Area Selection Box',
          onClick = JS("
            function(btn, map) {
               LeafletWidget.methods.removeAreaSelect.call(map);
               btn.state('disabled-areaselect');
            }")
        )
      )
  )
  )
}

#' Changes the dimension of the area selection box.
#' @describeIn addAreaSelect change dimensions of the selection box.
#' @export
setAreaSelectDimensions <- function(map, width, height) {
  map$dependencies <- c(map$dependencies, areaSelectDependencies())
  options <- list(width=width, height=height)
  invokeMethod(map, getMapData(map), 'setAreaSelectDimensions', options)
}

#' Removes the area selection box.
#' @describeIn addAreaSelect removes the area selection box.
#' @export
removeAreaSelect <- function(map) {
  map$dependencies <- c(map$dependencies, areaSelectDependencies())
  invokeMethod(map, getMapData(map), 'removeAreaSelect')
}

#' Adds a  draggable/resizable rectangle on top of the map for location filtering.
#' @param map The map widget.
#' @param position The position of the control button.
#' @param enable If set to TRUE the location filter is enabled when added to the map.
#' @param sw_lat Latitude of South-West End of the filter box.
#' @param sw_lng Longitude of South-West End of the filter box.
#' @param ne_lat Latitude of North-East End of the filter box.
#' @param ne_lng Longitude of North-East End of the filter box.
#'
#' @export
addLocationFilter <- function(
  map,
  position = c('topleft','topright','bottomleft','bottomright'),
  enable = FALSE,
  sw_lat = NULL, sw_lng=NULL, ne_lat=NULL, ne_lng=NULL) {

  position = match.arg(position)

  bounds <- NULL
  if(!(
    is.null(sw_lat) && is.null(sw_lng) && is.null(ne_lat) && is.null(ne_lng)
  ) && (
    is.null(sw_lat) || is.null(sw_lng) || is.null(ne_lat) || is.null(ne_lng)
  )) {
    stop("Either specify all bounds or no bounds")
  }

  if(!is.null(sw_lat)) {
    bounds <- list(c(sw_lat,sw_lng),c(ne_lat,ne_lng))
  }

  map$dependencies <- c(map$dependencies, locationFilterDependencies())
  options <- filterNULL(list(position = position, enable = enable, bounds = bounds))
  invokeMethod(map, getMapData(map), 'addLocationFilter', options)
}

#' Removes the location filter box.
#' @describeIn addLocationFilter removes the location filter box.
#' @export
removeLocationFilter <- function(map) {
  map$dependencies <- c(map$dependencies, locationFilterDependencies())
  invokeMethod(map, getMapData(map), 'removeLocationFilter')
}
