library(maps)

data(us.cities)

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
  
#   handleEvent(input$map_click, function() {
#     map$addMarker(input$map_click$lat, input$map_click$lng, 'clicked')
#   })
  
  handleEvent(input$map_marker_click, function() {
    updateNumericInput(session, 'lat', value=input$map_marker_click$lat)
    updateNumericInput(session, 'lng', value=input$map_marker_click$lng)
  })
  
  handleEvent(input$clearMarkers, function() {
    map$clearMarkers()
  })
  
  handleEvent(input$randomMarkers, map$clearMarkers)

  # Run this code if input$map_bounds OR input$randomMarkers changes
  handleEvent({input$map_bounds; input$randomMarkers}, function() {
    if (!input$randomMarkers)
      return()
    map$clearMarkers()
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
  
  citiesInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(us.cities[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)

    subset(us.cities,
           lat >= latRng[1] & lat <= latRng[2] &
             long >= lngRng[1] & long <= lngRng[2])
  })
  
  topCitiesInBounds <- reactive({
    cities <- citiesInBounds()
    cities <- head(cities[order(cities$pop, decreasing=TRUE),], 100)
  })
  
  radiusFactor <- 0.03
  observe({
    map$clearShapes()
    cities <- topCitiesInBounds()

    if (nrow(cities) == 0)
      return()
    
    for (i in 1:nrow(cities)) {
      map$addCircle(
        cities$lat[[i]],
        cities$long[[i]],
        cities$pop[[i]] * radiusFactor,
        cities$name[[i]],
        list(
          weight=1.2,
          fill=TRUE
        )
      )
    }
  })
  
  handleEvent(input$map_shape_click, function() {
    click <- input$map_shape_click
    map$clearPopups()
    
    cities <- topCitiesInBounds()
    city <- as.list(cities[cities$name == click$id,])
    content <- as.character(tagList(
      tags$strong(city$name),
      tags$br(),
      "Population: ",
      as.character(city$pop)
    ))
    map$showPopup(click$lat, click$lng, content)
  })
  
  output$mapInfo <- renderPrint({
    str(list(bounds = input$map_bounds,
         zoom = input$map_zoom))
  })
  
  output$desc <- reactive({
    list(
      lat = mean(c(input$map_bounds$north, input$map_bounds$south)),
      lng = mean(c(input$map_bounds$east, input$map_bounds$west)),
      zoom = input$map_zoom,
      shownCities = nrow(topCitiesInBounds()),
      totalCities = nrow(citiesInBounds())
    )
  })
  
  handleEvent(input$randomLocation, function() {
    map$fitBounds(runif(1, -90, 90),
                  runif(1, -180, 180),
                  runif(1, -90, 90),
                  runif(1, -180, 180))
  })
})
