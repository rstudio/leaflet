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

library(shiny)
library(leaflet)
library(RColorBrewer)
library(maps)
library(sp)

# global.R ----

density = c(
  "Alabama" = 94.65,
  "Arizona" = 57.05,
  "Arkansas" = 56.43,
  "California" = 241.7,
  "Colorado" = 49.33,
  "Connecticut" = 739.1,
  "Delaware" = 464.3,
  "District of Columbia" = 10065,
  "Florida" = 353.4,
  "Georgia" = 169.5,
  "Idaho" = 19.15,
  "Illinois" = 231.5,
  "Indiana" = 181.7,
  "Iowa" = 54.81,
  "Kansas" = 35.09,
  "Kentucky" = 110,
  "Louisiana" = 105,
  "Maine" = 43.04,
  "Maryland" = 596.3,
  "Massachusetts" = 840.2,
  "Michigan" = 173.9,
  "Minnesota" = 67.14,
  "Mississippi" = 63.50,
  "Missouri" = 87.26,
  "Montana" = 6.858,
  "Nebraska" = 23.97,
  "Nevada" = 24.80,
  "New Hampshire" = 147,
  "New Jersey" = 1189 ,
  "New Mexico" = 17.16,
  "New York" = 412.3,
  "North Carolina" = 198.2,
  "North Dakota" = 9.916,
  "Ohio" = 281.9,
  "Oklahoma" = 55.22,
  "Oregon" = 40.33,
  "Pennsylvania" = 284.3,
  "Rhode Island" = 1006 ,
  "South Carolina" = 155.4,
  "South Dakota" = 98.07,
  "Tennessee" = 88.08,
  "Texas" = 98.07,
  "Utah" = 34.30,
  "Vermont" = 67.73,
  "Virginia" = 204.5,
  "Washington" = 102.6,
  "West Virginia" = 77.06,
  "Wisconsin" = 105.2,
  "Wyoming" = 5.851
)

# Breaks we'll use for coloring
densityBreaks <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)

# Construct break ranges for displaying in the legend
densityRanges <- data.frame(
  from = head(densityBreaks, length(densityBreaks)-1),
  to = tail(densityBreaks, length(densityBreaks)-1)
)

# Eight colors for eight buckets
palette <- c("#FFEDA0", "#FED976", "#FEB24C", "#FD8D3C",
             "#FC4E2A", "#E31A1C", "#BD0026", "#800026")
# Assign colors to states
colors <- structure(
  palette[cut(density, densityBreaks)],
  names = tolower(names(density))
)

pal <- colorQuantile("YlOrRd", NULL, n = 8) # display.brewer.all()

# The state names that come back from the maps package's state database has
# state:qualifier format. This function strips off the qualifier.
getStateName <- function(id) {
  strsplit(id, ":")[[1]][1]
}

states <- map("state", names(density), plot=FALSE, fill=TRUE)

states_sp = SpatialPolygonsDataFrame(states)
states_sp = as(states, class('SpatialPolygonsDataFrame'))
class(states_sp)
states_sp@data

# ui.R ----

ui <- fluidPage(

  # Add a little CSS to make the map background pure white
  tags$head(tags$style("
                       #showcase-code-position-toggle, #showcase-sxs-code { display: none; }
                       .floater { background-color: white; padding: 8px; opacity: 0.7; border-radius: 6px; box-shadow: 0 0 15px rgba(0,0,0,0.2); }
                       ")),

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
  ),

  absolutePanel(
    right = 30, top = 280, style = "", class = "floater",
    tags$table(
      mapply(function(from, to, color) {
        tags$tr(
          tags$td(tags$div(
            style = sprintf("width: 16px; height: 16px; background-color: %s;", color)
          )),
          tags$td(from, "-", to)
        )
      }, densityRanges$from, densityRanges$to, palette, SIMPLIFY=FALSE)
    )
  )
)

# server.R ----
server <- function(input, output, session) {
  # v <- reactiveValues(highlight = c())
  v <- reactiveValues(msg = "")

  #map <- createLeafletMap(session, "map")
  output$map1 <- renderLeaflet({
    # states <- map("state", fill=TRUE, plot=FALSE)
    leaflet() %>%
      addPolygons(
        data = states,
        fillColor = ~pal())
  })

  # Draw the given states, with or without highlighting
  drawStates <- function(stateNames, highlight = FALSE) {
    states <- map("state", stateNames, plot=FALSE, fill=TRUE)
    map1$addPolygon(I(states$y), I(states$x), I(states$names),
                   I(lapply(states$names, function(x) {
                     x <- strsplit(x, ":")[[1]][1]
                     list(fillColor = colors[[x]])
                   })),
                   I(list(fill=TRUE, fillOpacity=0.7,
                          stroke=TRUE, opacity=1, color="white", weight=ifelse(highlight, 4, 1)
                   ))
    )
  }

  observe({
    print(input$map1_zoom)
    map1$clearShapes()
    if (!is.null(input$map1_zoom) && input$map1_zoom > 6) {
      # Get shapes from the maps package
      drawStates(names(density))
    }
  })

  # input$map1_shape_mouseover gets updated a lot, even if the id doesn't change.
  # We don't want to update the polygons and stateInfo except when the id
  # changes, so use v$highlight to insulate the downstream reactives (as
  # writing to v$highlight doesn't trigger reactivity unless the new value
  # is different than the previous value).
  observe({
    v$highlight <- input$map1_shape_mouseover$id
  })

  # Dynamically render the box in the upper-right
  output$stateInfo <- renderUI({
    if (is.null(v$highlight)) {
      return(tags$div("Hover over a state"))
    } else {
      # Get a properly formatted state name
      stateName <- names(density)[getStateName(v$highlight) == tolower(names(density))]
      return(tags$div(
        tags$strong(stateName),
        tags$div(density[stateName], HTML("people/m<sup>2</sup>"))
      ))
    }
  })

  lastHighlighted <- c()
  # When v$highlight changes, unhighlight the old state (if any) and
  # highlight the new state
  observe({
    if (length(lastHighlighted) > 0)
      drawStates(getStateName(lastHighlighted), FALSE)
    lastHighlighted <<- v$highlight

    if (is.null(v$highlight))
      return()

    isolate({
      drawStates(getStateName(v$highlight), TRUE)
    })
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
  observeEvent(input$clearMarkers, {
    leafletProxy("map1") %>% clearMarkers()
  })

  output$message <- renderText(v$msg)
}

shinyApp(ui, server)

