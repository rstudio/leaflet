handleEvent <- function(button, handler) {
  fun <- exprToFunction(button)
  observe({
    val <- fun()
    if (is.null(val) || identical(val, 0))
      return()
    
    isolate(handler())
  })
}

shinyServer(function(input, output, session) {
  output$map <- reactive({
    20
  })
  
  map <- createLeafletMap(session, 'map')
  
  handleEvent(input$addMarker, function() {
    map$addMarker(input$lat, input$lng, NULL, list(draggable = input$draggable))
  })
  
  handleEvent(input$map_click, function() {
    map$addMarker(input$map_click$lat, input$map_click$lng, 'clicked')
  })
  
  handleEvent(input$map_marker_click, function() {
    updateNumericInput(session, 'lat', value=input$map_marker_click$lat)
    updateNumericInput(session, 'lng', value=input$map_marker_click$lng)
  })
  
  handleEvent(input$clearMarkers, function() {
    map$clearMarkers()
  })
  
  # Run this code if input$map_bounds OR input$randomMarkers changes
  handleEvent({input$map_bounds; input$randomMarkers}, function() {
    map$clearMarkers()
    if (!input$randomMarkers)
      return()
    bounds <- input$map_bounds
    randPoint <- function() {
      list(lat = (bounds$north - bounds$south) * runif(1) + bounds$south,
           lng = (bounds$east - bounds$west) * runif(1) + bounds$west)
    }
    for (i in 1:20) {
      point <- randPoint()
      map$addMarker(point$lat, point$lng)
    }
  })
  
  output$mapInfo <- renderPrint({
    str(list(bounds = input$map_bounds,
         zoom = input$map_zoom))
  })
  
  handleEvent(input$randomLocation, function() {
    map$fitBounds(runif(1, -90, 90),
                  runif(1, -180, 180),
                  runif(1, -90, 90),
                  runif(1, -180, 180))
  })
})