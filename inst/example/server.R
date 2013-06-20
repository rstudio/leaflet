library(leaflet)
library(ggplot2)
library(maps)

data(uspop2000)

# From a future version of Shiny
observeEvent <- function(eventExpr, callback, env=parent.frame(), quoted=FALSE) {
  eventFunc <- exprToFunction(eventExpr, env, quoted)
  
  initialized <- FALSE
  invisible(observe({
    eventVal <- eventFunc()
    if (!initialized)
      initialized <<- TRUE
    else
      isolate(callback())
  }))
}

shinyServer(function(input, output, session) {
  # Create reactive values object to store our markers
  values <- reactiveValues(markers = NULL)
  
  # Create the map; this is not the "real" map, but rather a proxy object that
  # lets us control the leaflet map on the page.
  map <- createLeafletMap(session, 'map')
  
  observeEvent(input$addMarker, function() {
    map$addMarker(input$lat, input$lng, NULL, list(draggable = input$draggable))
    values$markers <- rbind(data.frame(lat=input$lat, long=input$lng),
                            values$markers)
  })
  
  observeEvent(input$map_click, function() {
    values$selectedCity <- NULL
    if (!input$addMarkerOnClick)
      return()
    map$addMarker(input$map_click$lat, input$map_click$lng, NULL)
    values$markers <- rbind(data.frame(lat=input$map_click$lat,
                                       long=input$map_click$lng),
                            values$markers)
  })
  
  observeEvent(input$map_marker_click, function() {
    updateNumericInput(session, 'lat', value=input$map_marker_click$lat)
    updateNumericInput(session, 'lng', value=input$map_marker_click$lng)
  })
  
  observeEvent(input$clearMarkers, function() {
    map$clearMarkers()
    values$markers <- NULL
  })
  
  popCol <- reactive({
    paste('Pop', input$year, sep='')
  })
  
  popSeries <- function(city) {
    c(
      sum(city$Pop2000),
      sum(city$Pop2001),
      sum(city$Pop2002),
      sum(city$Pop2003),
      sum(city$Pop2004),
      sum(city$Pop2005),
      sum(city$Pop2006),
      sum(city$Pop2007),
      sum(city$Pop2008),
      sum(city$Pop2009),
      sum(city$Pop2010)
    )
  }
  
  citiesInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(uspop2000[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)

    subset(uspop2000,
           Lat >= latRng[1] & Lat <= latRng[2] &
             Long >= lngRng[1] & Long <= lngRng[2])
  })
  
  topCitiesInBounds <- reactive({
    cities <- citiesInBounds()
    cities <- head(cities[order(cities[[popCol()]], decreasing=TRUE),],
                   as.numeric(input$maxCities))
  })
  
  radiusFactor <- 1000
  observe({
    map$clearShapes()
    cities <- topCitiesInBounds()

    if (nrow(cities) == 0)
      return()
    
    map$addCircle(
      cities$Lat,
      cities$Long,
      sqrt(cities[[popCol()]]) * radiusFactor / max(5, input$map_zoom)^2,
      row.names(cities),
      list(
        weight=1.2,
        fill=TRUE,
        color='#4A9'
      )
    )
  })
  
  observeEvent(input$map_shape_click, function() {
    event <- input$map_shape_click
    map$clearPopups()
    
    cities <- topCitiesInBounds()
    city <- cities[row.names(cities) == event$id,]
    values$selectedCity <- city
    content <- as.character(tagList(
      tags$strong(paste(city$City, city$State)),
      tags$br(),
      sprintf("Estimated population, %s:", input$year),
      tags$br(),
      prettyNum(city[[popCol()]], big.mark=',')
    ))
    map$showPopup(event$lat, event$lng, content, event$id)
  })
  
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
    
    data.frame(
      City = paste(topCitiesInBounds()$City, topCitiesInBounds()$State),
      Population = topCitiesInBounds()[[popCol()]])
  }, include.rownames = FALSE)
  
  output$markers <- renderTable({
    if (is.null(values$markers))
      return(NULL)

    data <- values$markers
    colnames(data) <- c('Latitude', 'Longitude')
    return(data)
    
  }, include.rownames = FALSE)
  
  observeEvent(input$randomLocation, function() {
    map$setView(runif(1, 29.4, 47),
                runif(1, -119, -74),
                as.integer(runif(1, 6, 9)))
  })
  
  output$cityTimeSeriesLabel <- renderText({
    if (is.null(values$selectedCity)) {
      'Total population of visible cities'
    } else {
      paste('Population of ',
            values$selectedCity$City,
            ', ',
            values$selectedCity$State,
            sep='')
    }
  })
  
  output$cityTimeSeries <- renderPlot({
    cities <- NULL
    if (!is.null(values$selectedCity))
      cities <- values$selectedCity
    else
      cities <- topCitiesInBounds()

    if (is.null(cities) || nrow(cities) == 0)
      return()
    
    popData <- popSeries(cities) / 1000
    df <- data.frame(year = c(2000:2010), pop = popData)
    p <- ggplot(df, aes(x = year, y = pop)) + geom_line()
    #p <- p + ylim(c(0, max(popData)))
    p <- p + ylab('Population (thousands)')
    p <- p + scale_x_continuous(breaks = seq(2000, 2010, 2))
    print(p)
  })
  outputOptions(output, 'cityTimeSeries', suspendWhenHidden=FALSE)
})
