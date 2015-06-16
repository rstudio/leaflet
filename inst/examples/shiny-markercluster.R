library(shiny)
library(leaflet)

shinyApp(
  ui = fluidPage(
    leafletOutput('map1'),
    actionButton('add', 'Add marker cluster'),
    actionButton('clear', 'Clear marker cluster'),
    selectizeInput('remove1', 'Remove markers', rownames(quakes), multiple = TRUE)
  ),
  server = function(input, output, session) {
    output$map1 = renderLeaflet({
      leaflet() %>% addTiles() %>% setView(180, -24, 4)
    })
    observeEvent(input$add, {
      leafletProxy('map1') %>% addMarkers(
        data = quakes,
        popup = ~sprintf('magnitude = %s', mag), layerId = rownames(quakes),
        clusterOptions = markerClusterOptions(), clusterId = 'cluster1'
      )
    })
    observeEvent(input$clear, {
      leafletProxy('map1') %>% clearMarkerClusters()
    })
    observe({
      leafletProxy('map1') %>% removeMarkerFromCluster(input$remove1, 'cluster1')
    })
    observe({
      print(input$map1_cluster_click)
      print(input$map1_marker_click)
    })
  }
)
