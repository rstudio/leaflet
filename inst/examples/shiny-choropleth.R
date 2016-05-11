# Goal:
#   replicate http://leafletjs.com/examples/choropleth.html
# TODO:
# - convert states from class map to SpatialPolygonsDataFrame
#   - [kasc2spixdf {adehabitat} | inside-R | A Community Site for R](http://www.inside-r.org/packages/cran/adehabitat/docs/kasc2spixdf)
#   - https://github.com/rstudio/leaflet/blob/master/R/normalize.R#L195-L200
# - left_join data and color palette based on column
# - choropleth examples
#   - [Creating a Leaflet choropleth map with a pop-up in R](https://rpubs.com/walkerke/leaflet_choropleth)
#   - [Interactive Mapping with Leaflet in R | R-bloggers](http://www.r-bloggers.com/interactive-mapping-with-leaflet-in-r/)
# - Herman's [Shiny - Welcome to Shiny](http://shiny.rstudio.com/tutorial/js-lesson1/)
# - see R/plugin-*.R
# - [map_data. ggplot2 2.1.0](http://docs.ggplot2.org/current/map_data.html)
# - [Spatial Data in R: Vector Data](http://www.nickeubank.com/wp-content/uploads/2015/10/RGIS1_SpatialDataTypes_part1_vectorData.html)
# - [Robin Lovelace - Basic mapping and attribute joins in R](http://robinlovelace.net/r/2014/11/10/attribute-joins.html)

library(shiny)
library(RColorBrewer) # TODO: replace with interval
#library(maps)
library(rgdal)
#library(sp)
library(leaflet)

# library(devtools)
# load_all(leaflet)

# global.R ----

# TODO: change to system.file()
states = readOGR(
  "/Users/bbest/github/leaflet_bbest/inst/examples/us-states.json", layer = "OGRGeoJSON")

# setup color palette ----

# breaks we'll use for coloring
breaks <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
nb = length(breaks)

# construct break ranges for displaying in the legend
break_labels <- c(
  sprintf("%d - %d", breaks[1:(nb-2)], breaks[2:(nb-1)]),
  "1000+")

# get colors
colors = brewer.pal("YlOrRd", n = nb-1)

# The state names that come back from the maps package's state database has
# state:qualifier format. This function strips off the qualifier.
getStateName <- function(id) {
  strsplit(id, ":")[[1]][1]
}

# ui.R ----

ui <- fluidPage(

  # Add a little CSS to make the map background pure white
  tags$head(tags$style("
    showcase-code-position-toggle, #showcase-sxs-code { display: none; }
    .floater { background-color: white; padding: 8px; opacity: 0.7; border-radius: 6px; box-shadow: 0 0 15px rgba(0,0,0,0.2); }")),

  # leafletMap(
  #   "map", "100%", 500,
  #   # By default OpenStreetMap tiles are used; we want nothing in this case
  #   #initialTileLayer = NULL,
  #   #initialTileLayerAttribution = NULL,
  #   options=list(
  #     center = c(40, -98.85),
  #     zoom = 4,
  #     maxBounds = list(list(17, -180), list(59, 180))
  #   )
  # )
  leafletOutput("map1"),

  textOutput("message", container = h3),

  absolutePanel(
    right = 30, top = 10, width = 200, class = "floater",

    h4("US Population Density"),
    uiOutput("stateInfo")
  )
)

# server.R ----
server <- function(input, output, session) {
  # v <- reactiveValues(highlight = c())
  v <- reactiveValues(msg = "")

  output$map1 <- renderLeaflet({

    # draw leaflet map
    leaflet(states) %>%
      addProviderTiles("Stamen.TonerLite") %>%
      setView(-98.58, 39.83, 4) %>%
      addPolygons(
        group = 'states', layerId = states@data$name,
        smoothFactor = 0.2,
        stroke = T, color = "white", weight = 3,
        fillOpacity = 0.7, fillColor = ~colors[cut(density, breaks)]) %>%
      addLegend(
        "bottomright", colors = colors, labels = break_labels,
        opacity = 0.7)
  })

  # Draw the given states, with or without highlighting
  # drawStates <- function(stateNames, highlight = FALSE) {
  #   states <- map("state", stateNames, plot=FALSE, fill=TRUE)
  #   map1$addPolygon(I(states$y), I(states$x), I(states$names),
  #                  I(lapply(states$names, function(x) {
  #                    x <- strsplit(x, ":")[[1]][1]
  #                    list(fillColor = colors[[x]])
  #                  })),
  #                  I(list(fill=TRUE, fillOpacity=0.7,
  #                         stroke=TRUE, opacity=1, color="white", weight=ifelse(highlight, 4, 1)
  #                  ))
  #   )
  # }

  # observe({
  #   print(input$map1_zoom)
  #   map1$clearShapes()
  #   if (!is.null(input$map1_zoom) && input$map1_zoom > 6) {
  #     # Get shapes from the maps package
  #     drawStates(names(density))
  #   }
  # })

  # input$map1_shape_mouseover gets updated a lot, even if the id doesn't change.
  # We don't want to update the polygons and stateInfo except when the id
  # changes, so use v$highlight to insulate the downstream reactives (as
  # writing to v$highlight doesn't trigger reactivity unless the new value
  # is different than the previous value).
  observe({
    v$highlighted_state <- input$map1_shape_mouseover$id
  })

  # Dynamically render the box in the upper-right
  output$stateInfo <- renderUI({
    if (is.null(v$highlighted_state)) {
      return(div("Hover over a state"))
    } else {
      # Get a properly formatted state name
      #stateName <- names(density)[getStateName(v$highlight) == tolower(names(density))]
      return(div(
        strong(v$highlighted_state), br(),
        #div(density[stateName], HTML("people/mi<sup>2</sup>"))
        subset(states@data, name == v$highlighted_state, density), HTML("people/m<sup>2</sup>")
      ))
    }
  })

  #lastHighlighted <- c()
  # When v$highlight changes, unhighlight the old state (if any) and
  # highlight the new state
  # observe({
  #   if (length(lastHighlighted) > 0)
  #     drawStates(getStateName(lastHighlighted), FALSE)
  #   lastHighlighted <<- v$highlight
  #
  #   if (is.null(v$highlight))
  #     return()
  #
  #   isolate({
  #     drawStates(getStateName(v$highlight), TRUE)
  #   })
  # })



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
      leafletProxy("map1") %>%
        addMarkers(lng = input$map1_click$lng, lat = input$map1_click$lat)
    }
  })
  observeEvent(input$map1_zoom, {
    v$msg <- paste("Zoom changed to", input$map1_zoom)
  })
  observeEvent(input$map1_bounds, {
    v$msg <- paste("Bounds changed to", paste(input$map1_bounds, collapse = ", "))
  })
  # observeEvent(input$clearMarkers, {
  #   leafletProxy("map1") %>% clearMarkers()
  # })

  output$message <- renderText(v$msg)
}

shinyApp(ui, server)

