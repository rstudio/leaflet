library(shiny)
library(leaflet)

coor <- sp::coordinates(gadmCHE)

ui <- fluidPage(
  leafletOutput("map"),
  radioButtons("color", "Color", choices = c("blue", "red",  "green")),
  sliderInput("radius", "Radius", min = 1, max = 30, value=5, animate = TRUE)
)

server <- function(input, output, session){
  output$map <- renderLeaflet({
    leaflet(data=gadmCHE) %>%
      addPolygons(layerId = ~NAME_1, weight = 1) %>%
      addCircleMarkers(layerId = gadmCHE$NAME_1, data = coor, weight = 1)
  })

  observe({
    leafletProxy("map", data = gadmCHE) %>%
      setCircleMarkerRadius(gadmCHE$NAME_1, input$radius)
  })

  observe({
    leafletProxy("map", data = gadmCHE) %>%
      setShapeStyle(layerId = ~NAME_1, fillColor=input$color, color = input$color) %>%
      setCircleMarkerStyle(layerId = ~NAME_1, fillColor = input$color, color = input$color)
  })

}

shinyApp(ui, server)
