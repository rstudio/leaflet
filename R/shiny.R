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

#' @export
leafletFullPage <- function(..., title = NULL, theme = NULL,
  header = NULL, headerHeight = 60, footer = NULL, footerHeight = 45) {

  absStyle <- function(top = "0", right = "0", bottom = "0", left = "0") {
    sprintf("position: absolute; top: %s; right: %s; bottom: %s; left: %s;",
      top, right, bottom, left)
  }

  headerHeight <- if (!is.null(header)) validateCssUnit(headerHeight) else "0"
  footerHeight <- if (!is.null(footer)) validateCssUnit(footerHeight) else "0"

  fluidPage(
    title = title,
    tags$style("html, body { width: 100%; height: 100%; }"),
    if (!is.null(header)) {
      div(style = absStyle(bottom = headerHeight),
        header
      )
    },
    div(style = absStyle(top = headerHeight, bottom = footerHeight),
      ...
    ),
    if (!is.null(footer)) {
      div(style = absStyle(top = footerHeight),
        footer
      )
    }
  )
}
