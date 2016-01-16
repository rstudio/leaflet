library(shiny)
library(leaflet)

ui <- fluidPage(
  selectInput("providerName", "Tile set", c(
    "Stamen.Toner",
    "Stamen.TonerLite",
    "Stamen.Watercolor"
  )),
  leafletOutput("map")
)

server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() %>% addTiles(layerId = "tiles") %>% setView(0, 0, 1)
  })

  observeEvent(input$providerName, {
    leafletProxy("map", session) %>%
      addProviderTiles(input$providerName, layerId = "tiles")
  })
}

shinyApp(ui, server)
