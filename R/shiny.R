#' Wrapper functions for using \pkg{leaflet} in \pkg{shiny}
#'
#' Use \code{leafletOutput()} to create a UI element, and \code{renderLeaflet()}
#' to render the map widget.
#' @inheritParams htmlwidgets::shinyWidgetOutput
#' @param width,height the width and height of the map (see
#'   \code{\link[htmlwidgets]{shinyWidgetOutput}})
#' @rdname map-shiny
#' @export
#' @examples # !formatR
#' \donttest{library(leaflet)
#' library(shiny)
#' app = shinyApp(
#'   ui = fluidPage(leafletOutput('myMap')),
#'   server = function(input, output) {
#'     map = leaflet() %>% addTiles() %>% setView(-93.65, 42.0285, zoom = 17)
#'     output$myMap = renderLeaflet(map)
#'   }
#' )
#'
#' if (interactive()) print(app)}
leafletOutput = function(outputId, width = "100%", height = 400) {
  htmlwidgets::shinyWidgetOutput(outputId, "leaflet", width, height, "leaflet")
}

#' @rdname map-shiny
#' @export
renderLeaflet = function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) expr = substitute(expr)  # force quoted
  htmlwidgets::shinyRenderWidget(expr, leafletOutput, env, quoted = TRUE)
}
