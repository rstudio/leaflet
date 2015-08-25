leafletMeasureDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-measure",
      "1.2.0",
      system.file("htmlwidgets/lib/leaflet-measure", package = "leaflet"),
      script = "leaflet-measure.min.js",
      stylesheet = "leaflet-measure.css"
    )
  )
}

#' Add a measure control to the map.
#'
#' @param position standard \href{http://leafletjs.com/reference.html#control-positions}{Leaflet control position options}.
#' @param primaryLengthUnit,secondaryLengthUnit units used to display length
#'           results. secondaryLengthUnit is optional.
#'           Valid values are \code{"feet"}, \code{"meters"}, \code{"miles"}, and \code{"kilometers"}.
#' @param primaryAreaUnit,secondaryAreaUnit units used to display area results.
#'           secondaryAreaUnit is optional.  Valid values are
#'           \code{"acres"}, \code{"hectares"}, \code{"sqmeters"}, and \code{"sqmiles"}.
#' @param activeColor base color to use for map features rendered while
#'           actively performing a measurement.
#'           Value should be a color represented as a hexadecimal string.
#' @param completedColor base color to use for features generated
#'           from a completed measurement.
#'           Value should be a color represented as a hexadecimal string.
#' @param popupOptions \code{list} of ptions applied to the popup
#'           of the resulting measure feature.
#'           Properties may be any \href{http://leafletjs.com/reference.html#popup-options}{standard Leaflet popup options}.
#'
#' @return modified map
#' @examples
#' library(leaflet)
#'
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   # central park
#'   fitBounds( -73.9, 40.75, -73.95, 40.8 ) %>%
#'
#' leaf
#'
#' # customizing
#' leaf %>% addMeasure(
#'    position = "bottomleft"
#'   , primaryLengthUnit = "meters"
#'   , primaryAreaUnit = "sqmeters"
#'   , activeColor = "#3D535D"
#'   , completedColor = "#7D4479"
#' )
#'
#' @export
addMeasure <- function(
  map
  , position = "topright"
  , primaryLengthUnit = "feet"
  , secondaryLengthUnit = NULL
  , primaryAreaUnit = "acres"
  , secondaryAreaUnit = NULL
  , activeColor = "#ABE67E"
  , completedColor ="#C8F2BE"
  , popupOptions = list( className =  'leaflet-measure-resultpopup', autoPanPadding =  c(10,10) )
) {
  map$dependencies <- c(map$dependencies, leafletMeasureDependencies())
  invokeMethod(
    map
    , getMapData(map)
    , 'addMeasure'
    , Filter(
        Negate(is.null)
        ,list(
          position = position
          , primaryLengthUnit = primaryLengthUnit
          , secondaryLengthUnit = secondaryLengthUnit
          , primaryAreaUnit = primaryAreaUnit
          , secondaryAreaUnit = secondaryAreaUnit
          , activeColor = activeColor
          , completedColor = completedColor
          , popupOptions = popupOptions
        )
    )
  )
}

#' @export
#' @rdname remove
removeMeasure <- function( map ){
  invokeMethod(
    map
    , getMapData(map)
    , 'removeMeasure'
  )
}
