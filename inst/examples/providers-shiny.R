library(shiny)
library(leaflet)

ui <- fluidPage(
  fluidRow(
    column(
      3,
      selectInput(
        "providerName",
        "Tile set",
        c("CartoDB.Positron",
          "CartoDB.Voyager",
          "CartoDB.DarkMatter")
        )
    ),
    column(
      9,
      leafletOutput("map")

    )
  )
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
