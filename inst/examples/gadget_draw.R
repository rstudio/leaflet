# start toward a Shiny gadget for Leaflet and Leaflet.Draw
#   still missing many features but hopefully serves
#   as proof of concept

#' Leaflet Draw Shiny Gadget
#'
#' @param lf leaflet map currently with \code{addDrawToolbar} already
#'             added.
#' @param width,height valid \code{CSS} size for the gadget

leafdraw_gadget <- function(lf = NULL, height = NULL, width = NULL) {
  # modeled after chemdoodle gadget
  #  https://github.com/zachcp/chemdoodle/blob/master/R/chemdoodle_sketcher_gadgets.R
  stopifnot(requireNamespace("miniUI"), requireNamespace("shiny"))
  ui <- miniUI::miniPage(
    miniUI::miniContentPanel(lf, height=NULL, width=NULL),

    miniUI::gadgetTitleBar("Draw Something", right = miniUI::miniTitleBarButton("done", "Done", primary = TRUE))
  )

  server <- function(input, output, session) {
    shiny::observeEvent(input$done, { shiny::stopApp(input$undefined_draw_new_feature) })
    shiny::observeEvent(input$cancel, { shiny::stopApp (NULL) })
  }

  shiny::runGadget(
    ui,
    server,
    viewer =  shiny::dialogViewer("View and Edit Data"),
    stopOnCancel = FALSE
  )
}


# example use
library(leaflet)
library(leaflet.extras)
library(mapview)

lf <- mapview(breweries91)@map %>%
  addTiles() %>%
  addDrawToolbar()

drawn <- leafdraw_gadget(lf)
drawn
