library(shiny)
library(leaflet)

geodata <- paste(readLines(system.file("examples/test.json", package = "leaflet")), collapse = "\n")

ui <- fluidPage(
  leafletOutput("map1"),
  textOutput("message", container = h3)
)

server <- function(input, output, session) {
  v <- reactiveValues(msg = "")

  output$map1 <- renderLeaflet({
    m = leaflet() %>%
      addGeoJSON(geodata) %>%
      addCircles(-60, 60, radius = 5e5, layerId = "circle") %>%
      fitBounds(-87.1875, 71.4131, 128.3203, 0.3515)
  })

  observeEvent(input$map1_geojson_mouseover, {
    v$msg <- paste("Mouse is over", input$map1_geojson_mouseover$featureId)
  })
  observeEvent(input$map1_geojson_mouseout, {
    v$msg <- ""
  })
  observeEvent(input$map1_geojson_click, {
    v$msg <- paste("Clicked on", input$map1_geojson_click$featureId)
  })
  observeEvent(input$map1_shape_mouseover, {
    v$msg <- paste("Mouse is over shape", input$map1_shape_mouseover$id)
  })
  observeEvent(input$map1_shape_mouseout, {
    v$msg <- ""
  })
  observeEvent(input$map1_shape_click, {
    v$msg <- paste("Clicked shape", input$map1_shape_click$id)
  })
  observeEvent(input$map1_click, {
    v$msg <- paste("Clicked map at", input$map1_click$lat, "/", input$map1_click$lng)
  })
  observeEvent(input$map1_zoom, {
    v$msg <- paste("Zoom changed to", input$map1_zoom)
  })
  observeEvent(input$map1_bounds, {
    v$msg <- paste("Bounds changed to", paste(input$map1_bounds, collapse = ", "))
  })

  output$message <- renderText(v$msg)
}

shinyApp(ui, server)
