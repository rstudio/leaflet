library(leaflet)
library(leaflet.extras)
library(shiny)

#using examples from ?leaflet
rand_lng = function(n = 10) rnorm(n, -93.65, .01)
rand_lat = function(n = 10) rnorm(n, 42.0285, .01)
m = leaflet() %>%
  addTiles() %>%
  addPolygons(rand_lng(4), rand_lat(4), group = 'foo') %>%
  addPolygons(rand_lng(4), rand_lat(4), group = 'foo') %>%
  addDrawToolbar(targetGroup = "foo", editOptions = editToolbarOptions())

# do this in GlobalEnv only for example purposes
deleted <- list()
ui <- leafletOutput("leafmap")
server <- function(input, output, session) {
  output$leafmap <- renderLeaflet({m})

  observeEvent(input$leafmap_draw_deleted_features,{
    str(input$leafmap_draw_deleted_features, max.level=2)
    deleted <<- c(
      deleted,
      input$leafmap_draw_deleted_features
    )
  })
}
shinyApp(ui, server)

str(deleted, max.level=2)
