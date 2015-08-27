library(leaflet)

# match the heatmap demo from Leaflet.heat
# https://github.com/Leaflet/Leaflet.heat/blob/gh-pages/demo/index.html

# get the data to match exactly
addressPoints <- readLines(
  "http://leaflet.github.io/Leaflet.markercluster/example/realworld.10000.js"
)
addressPoints <- apply(
  jsonlite::fromJSON(
    sprintf("[%s]",
      paste0(
        addressPoints[4:(length(addressPoints)-1)]
        ,collapse=""
      )
    )
  )
  ,MARGIN = 2
  ,as.numeric
)

# create our heatmap
leaf <- leaflet() %>%
  setView( 175.475,-37.87, 12 ) %>%
  addHeatmap(addressPoints)

leaf

# customize our heatmap with options
leaf <- leaflet() %>%
  addTiles() %>%
  setView( 175.475,-37.87, 12 ) %>%
  addHeatmap(
    addressPoints
    ,blur = 50
    ,gradient = colorNumeric(
      palette = "Purples"
      ,domain = c(0,1)
    )
  )

leaf

# replicate the example provided by
#   http://www.d3noob.org/2014/02/generate-heatmap-with-leafletheat-and.html

earthquakes <- readLines(
  "http://bl.ocks.org/d3noob/raw/8973028/2013-earthquake.js"
)
earthquakes <- apply(
  jsonlite::fromJSON(
    sprintf("[%s]",
            paste0(
              earthquakes[5:(length(earthquakes)-1)]
              ,collapse=""
            )
    )
  )
  ,MARGIN = 2
  ,as.numeric
)

leaflet() %>%
  addTiles() %>%
  setView( 174.146, -41.5546, 10 ) %>%
  addHeatmap(
    earthquakes,
    radius = 20,
    blur = 15,
    maxZoom = 17
  )

#  using data(quakes)
data(quakes)
quakes_mat <- matrix(t(quakes[,c(1:2,4)]),ncol=3,byrow=TRUE)
leaflet() %>%
  addTiles( ) %>%
  setView( 178, -20, 5 ) %>%
  addHeatmap( quakes_mat, blur = 20, max = 0.02, radius = 10,
              gradient = colorNumeric("Greys", 0:1) )

# to remove the heatmap
leaf %>% clearHeatmap()
