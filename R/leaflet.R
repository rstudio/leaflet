#' Create a Leaflet map widget
#'
#' This function creates a Leaflet map widget using \pkg{htmlwidgets}. The
#' widget can be rendered on HTML pages generated from R Markdown, Shiny, or
#' other applications.
#' @param id a character string as the identifier of the map (you do not need to
#'   provide it unless you want to manipulate the map later in Shiny)
#' @param width the width of the map
#' @param height the height of the map
#' @param padding the padding of the map
#' @return A HTML widget object.
#' @example inst/examples/leaflet.R
#' @export
leaflet = function(data = NULL, id = NULL, width = NULL, height = NULL, padding = 0) {
  htmlwidgets::createWidget(
    'leaflet',
    list(mapId = id, data = data),
    width = width, height = height,
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultWidth = 'auto',
      defaultHeight = 'auto',
      padding = padding,
      browser.fill = TRUE
    )
  )
}
