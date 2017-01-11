# start toward a Shiny gadget for Leaflet and Leaflet.Draw
#   still missing many features but hopefully serves
#   as proof of concept

#' Leaflet Draw Shiny Gadget
#'
#' @param lf leaflet map currently with \code{addDrawToolbar} already
#'             added.
#' @param width,height valid \code{CSS} size for the gadget

drawonme <- function(lf = NULL, height = NULL, width = NULL) {
  # modeled after chemdoodle gadget
  #  https://github.com/zachcp/chemdoodle/blob/master/R/chemdoodle_sketcher_gadgets.R
  stopifnot(requireNamespace("miniUI"), requireNamespace("shiny"))
  ui <- miniUI::miniPage(
    miniUI::miniContentPanel(lf, height=NULL, width=NULL),
    miniUI::gadgetTitleBar("Draw Something", right = miniUI::miniTitleBarButton("done", "Done", primary = TRUE))
  )

  server <- function(input, output, session) {
    drawn <- list()
    edited <- list()

    shiny::observeEvent(input$undefined_draw_new_feature, {
      # we can clean this up
      drawn <<- c(drawn, list(input$undefined_draw_new_feature))
    })

    shiny::observeEvent(input$undefined_draw_edited_features, {
      edited <<- input$undefined_draw_edited_features
      # find the edited features and update drawn
      # start by getting the leaflet ids to do the match
      ids <- unlist(lapply(drawn, function(x){x$properties$`_leaflet_id`}))
      # now modify drawn to match edited
      lapply(edited$features, function(x){
        loc <- match(x$properties$`_leaflet_id`, ids)
        drawn[loc] <<- list(x)
      })
    })

    shiny::observeEvent(input$done, { shiny::stopApp(drawn) })
    shiny::observeEvent(input$cancel, { shiny::stopApp (NULL) })
  }

  shiny::runGadget(
    ui,
    server,
    viewer =  shiny::dialogViewer("Draw and Edit"),
    stopOnCancel = FALSE
  )
}


# example use
library(leaflet)
library(leaflet.extras)
library(mapview)

lf <- mapview(breweries91)@map %>%
  addTiles() %>%
  addDrawToolbar(editOptions = editToolbarOptions())

drawn <- drawonme(lf)
drawn

Reduce(
  function(x,y) {
    x %>% addGeoJSON(y)
  },
  drawn,
  init = lf
)

library(lawn)
l_pts <- lawn_featurecollection(
  as.list(unname(apply(breweries91@coords,MARGIN=1,lawn_point)))
)

l_poly <- lawn_featurecollection(
  list(lawn_polygon(drawn[[1]]$geometry$coordinates))
)

l_in <- lawn_within(l_pts, l_poly)
l_out <- lawn_featurecollection(Filter(
  function(pt) {
    !lawn_inside(pt, lawn_polygon(drawn[[1]]$geometry$coordinates))
  },
  as.list(unname(apply(breweries91@coords,MARGIN=1,lawn_point)))
))

view(l_in) %>%
  addGeoJSON(drawn[[1]])

view(l_out) %>%
  addGeoJSON(drawn[[1]])
