library(shiny)
library(leaflet)

geodata <- paste(readLines(system.file("examples/test.json", package = "leaflet")), collapse = "\n")

ui <- fluidPage(
  leafletOutput("map1"),
  checkboxInput("addMarker", "Add marker on click"),
  actionButton("clearMarkers", "Clear all markers"),
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
    if (input$addMarker) {
      getMapProxy("map1") %>%
        addMarkers(lng = input$map1_click$lng, lat = input$map1_click$lat)
    }
  })
  observeEvent(input$map1_zoom, {
    v$msg <- paste("Zoom changed to", input$map1_zoom)
  })
  observeEvent(input$map1_bounds, {
    v$msg <- paste("Bounds changed to", paste(input$map1_bounds, collapse = ", "))
  })
  observeEvent(input$clearMarkers, {
    getMapProxy("map1") %>% clearMarkers()
  })

  output$message <- renderText(v$msg)
}

shinyApp(ui, server)
