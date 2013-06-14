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
  values <- reactiveValues(markers = NULL)
  output$map <- reactive({10})
  
  map <- createLeafletMap(session, 'map')
  
  handleEvent(input$addMarker, function() {
    map$addMarker(input$lat, input$lng, NULL, list(draggable = input$draggable))
    values$markers <- rbind(data.frame(lat=input$lat, long=input$lng),
                            values$markers)
  })
  
  handleEvent(input$map_click, function() {
    if (!input$addMarkerOnClick)
      return()
    map$addMarker(input$map_click$lat, input$map_click$lng, NULL)
    values$markers <- rbind(data.frame(lat=input$map_click$lat,
                                       long=input$map_click$lng),
                            values$markers)
  })
  
  handleEvent(input$map_marker_click, function() {
    updateNumericInput(session, 'lat', value=input$map_marker_click$lat)
    updateNumericInput(session, 'lng', value=input$map_marker_click$lng)
  })
  
  handleEvent(input$clearMarkers, function() {
    map$clearMarkers()
    values$markers <- NULL
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
    cities <- head(cities[order(cities$pop, decreasing=TRUE),],
                   as.numeric(input$maxCities))
  })
  
  radiusFactor <- 1000
  observe({
    map$clearShapes()
    cities <- topCitiesInBounds()

    if (nrow(cities) == 0)
      return()
    
    map$addCircle(
      cities$lat,
      cities$long,
      sqrt(cities$pop) * radiusFactor / max(5, input$map_zoom)^2,
      cities$name,
      list(
        weight=1.2,
        fill=TRUE,
        color='#4A9'
      )
    )
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
  
  `%OR%` <- function(a, b) {
    if (is.null(a))
      b
    else
      a
  }
  output$desc <- reactive({
    if (is.null(input$map_bounds))
      return(list())
    list(
      lat = mean(c(input$map_bounds$north, input$map_bounds$south)),
      lng = mean(c(input$map_bounds$east, input$map_bounds$west)),
      zoom = input$map_zoom,
      shownCities = nrow(topCitiesInBounds()),
      totalCities = nrow(citiesInBounds())
    )
  })
  
  output$data <- renderTable({
    if (nrow(topCitiesInBounds()) == 0)
      return(NULL)
    
    data <- data.frame(Population = topCitiesInBounds()$pop)
    rownames(data) <- topCitiesInBounds()$name
    return(data)
  })
  
  output$markers <- renderTable({
    if (is.null(values$markers))
      return(NULL)

    data <- values$markers
    colnames(data) <- c('Latitude', 'Longitude')
    return(data)
    
  }, include.rownames = FALSE)
  
  handleEvent(input$randomLocation, function() {
    map$setView(runif(1, 29.4, 47),
                runif(1, -119, -74),
                as.integer(runif(1, 6, 9)))
  })
})
