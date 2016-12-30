# devtools::install_github("rstudio/crosstalk@joe/simplify")
# devtools::install_github("rstudio/leaflet@crosstalk3")

library(crosstalk)
library(leaflet)
library(shiny)
library(dplyr)

rand_lng = function(n = 10) rnorm(n, -93.65, .01)
rand_lat = function(n = 10) rnorm(n, 42.0285, .01)

ui <- fluidPage(
  fluidRow(
    column(2,   filter_select(id="filterselect", label="Points", sharedData=pts, group=~id)),
    column(6, leafletOutput("leaflet1"))
  ),
  h4("Selected points"),
  verbatimTextOutput("selectedpoints")
)

server <- function(input, output, session) {
  pts <- SharedData$new(
    data.frame(
      id = 1:10,
      lng = rand_lng(),
      lat = rand_lat()
    ),
    key = ~id,
    group = "grp1"
  )

  output$leaflet1 <- renderLeaflet({
    leaflet(pts) %>%
      addTiles() %>%
      addMarkers()
  })

  output$selectedpoints <- renderPrint({
    df <- pts$data(withSelection = TRUE)

    cat(nrow(df), "observation(s) selected\n\n")
    str(dplyr::glimpse(df))
  })
}

shinyApp(ui, server)
