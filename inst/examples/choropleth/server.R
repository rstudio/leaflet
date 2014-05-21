library(leaflet)
library(RColorBrewer)
library(maps)

shinyServer(function(input, output, session) {
  output$map <- reactive(TRUE)

  map <- createLeafletMap(session, "map")

  # session$onFlushed is necessary to delay the drawing of the polygons until
  # after the map is created
  session$onFlushed(once=TRUE, function() {
    # Get shapes from the maps package
    states <- map("state", plot=FALSE, fill=TRUE)

    map$addPolygon(states$y, states$x, states$names,
      lapply(brewer.pal(9, "Blues"), function(x) {
        list(fillColor = x)
      }),
      list(fill=TRUE, fillOpacity=1, 
        stroke=TRUE, opacity=1, color="white", weight=1
      )
    )
  })
})
