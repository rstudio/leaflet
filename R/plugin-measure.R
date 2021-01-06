leafletMeasureDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-measure",
      "2.1.7",
      system.file("htmlwidgets/lib/leaflet-measure", package = "leaflet"),
      script = "leaflet-measure.min.js",
      stylesheet = "leaflet-measure.css"
    )
  )
}

#' Add a measure control to the map.
#'
#' @param map a map widget object
#' @param position standard \href{https://leafletjs.com/reference-1.3.4.html#control-positions}{Leaflet control position options}.
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
#' @param popupOptions \code{list} of options applied to the popup
#'           of the resulting measure feature.
#'           Properties may be any \href{https://leafletjs.com/reference-1.3.4.html#popup-option}{standard Leaflet popup options}.
#' @param captureZIndex Z-index of the marker used to capture measure clicks.
#'           Set this value higher than the z-index of all other map layers to
#'           disable click events on other layers while a measurement is active.
#' @param localization Locale to translate displayed text.
#'           Available locales include en (default), cn, de, es, fr, it, nl, pt,
#'           pt_BR, pt_PT, ru, and tr
#' @param decPoint Decimal point used when displaying measurements.
#'           If not specified, values are defined by the localization.
#' @param thousandsSep Thousands separator used when displaying measurements.
#'           If not specified, values are defined by the localization.
#'
#' @return modified map
#' @examples
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   # central park
#'   fitBounds( -73.9, 40.75, -73.95, 40.8 ) %>%
#'   addMeasure()
#'
#' leaf
#'
#' # customizing
#' leaf %>% addMeasure(
#'   position = "bottomleft",
#'   primaryLengthUnit = "meters",
#'   primaryAreaUnit = "sqmeters",
#'   activeColor = "#3D535D",
#'   completedColor = "#7D4479",
#'   localization = "de"
#' )
#'
#' @export
addMeasure <- function(
  map,
  position = "topright",
  primaryLengthUnit = "feet",
  secondaryLengthUnit = NULL,
  primaryAreaUnit = "acres",
  secondaryAreaUnit = NULL,
  activeColor = "#ABE67E",
  completedColor ="#C8F2BE",
  popupOptions = list( className =  "leaflet-measure-resultpopup", autoPanPadding =  c(10, 10) ),
  captureZIndex = 10000,
  localization = "en",
  decPoint = ".",
  thousandsSep = ","
) {
  map$dependencies <- c(map$dependencies, leafletMeasureDependencies())
  invokeMethod(
    map,
    getMapData(map),
    "addMeasure",
    Filter(
      Negate(is.null),
      list(
        position = position,
        primaryLengthUnit = primaryLengthUnit,
        secondaryLengthUnit = secondaryLengthUnit,
        primaryAreaUnit = primaryAreaUnit,
        secondaryAreaUnit = secondaryAreaUnit,
        activeColor = activeColor,
        completedColor = completedColor,
        popupOptions = popupOptions,
        captureZIndex = captureZIndex,
        localization = localization,
        decPoint = decPoint,
        thousandsSep = thousandsSep
      )
    )
  )
}

#' @export
#' @rdname remove
removeMeasure <- function( map ){
  invokeMethod(
    map,
    getMapData(map),
    "removeMeasure"
  )
}
