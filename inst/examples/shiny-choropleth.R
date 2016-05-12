# Goal here is to replicate this choropleth example from leafletjs.com:
#   [Interactive Choropleth Map](http://leafletjs.com/examples/choropleth.html)

library(shiny)
library(RColorBrewer)
library(rgdal)
library(leaflet)

# load states
states = readOGR(system.file("examples/us-states.json", package = 'leaflet'), layer = "OGRGeoJSON")

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

# ui.R ----

ui <- fluidPage(

  # Add a little CSS to make the map background pure white
  tags$head(tags$style("
    showcase-code-position-toggle, #showcase-sxs-code { display: none; }
    .floater { background-color: white; padding: 8px; opacity: 0.8; border-radius: 6px; box-shadow: 0 0 15px rgba(0,0,0,0.2); }")),

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
  v <- reactiveValues(highlight = c())

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
        opacity = 0.8)
  })

  # input$map1_shape_mouseover gets updated a lot, even if the id doesn't change.
  # We don't want to update the polygons and stateInfo except when the id
  # changes, so use v$highlight to insulate the downstream reactives (as
  # writing to v$highlight doesn't trigger reactivity unless the new value
  # is different than the previous value).
  observe({
    v$highlight <- sub(" highlight", "", input$map1_shape_mouseover$id)

    # nullify highlight if mouseout == mouseover
    if (length(input$map1_shape_mouseout$id) > 0 && input$map1_shape_mouseout$id == input$map1_shape_mouseover$id){
      v$highlight <- NULL
    }
  })

  # Dynamically render the box in the upper-right
  output$stateInfo <- renderUI({
    if (is.null(v$highlight)) {
      return(div("Hover over a state"))
    } else {
      return(div(
        strong(v$highlight), br(),
        subset(states@data, name == v$highlight, density), HTML("people/m<sup>2</sup>")
      ))
    }
  })

  # When v$highlight changes, unhighlight the old state (if any) and
  # highlight the new state
  last_highlight <- c()
  observe({
    proxy <- leafletProxy("map1", data = states)

    # clear highlight polygon if null or not same as previous
    if (is.null(v$highlight) || (length(last_highlight) > 0 && !is.null(v$highlight) && last_highlight != v$highlight)){
      proxy %>% clearGroup("highlight")
    }

    # record last highlight
    last_highlight <<- v$highlight

    # skip adding highlight if no new highlight
    if (length(last_highlight) == 0 || is.null(last_highlight))
      return()

    isolate({
      # add highlight polygon
      proxy %>%
        addPolygons(
          data = subset(states, name == v$highlight),
          group="highlight", layerId = sprintf("%s highlight", v$highlight),
          smoothFactor = 0.2,
          stroke = T, color = "gray", weight = 5,
          fillColor = "transparent")
    })
  })
}

shinyApp(ui, server)
