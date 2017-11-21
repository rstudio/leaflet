library(leaflet)

# Marker + Label on hover
leaflet() %>% addTiles() %>%
  addMarkers(
    lng=-118.456554, lat=34.078039,
    label='This is a label')
#' <br/><br/>

# Marker + Static Labels
leaflet() %>% addTiles() %>%
  addMarkers(
    lng=-118.456554, lat=34.078039,
    label='This is a static label',
    labelOptions = labelOptions(noHide = T))
#' <br/><br/>

# Circle Marker + Label in all 4 directions.
# Note the offset values for top and bottom directions.
leaflet() %>% addTiles() %>%
  setView(
    lng=-118.456554, lat=34.078039, zoom  = 16
  )%>%
  addCircleMarkers(
    lng=-118.45990, lat=34.078079, radius = 5,
    label='On the Right',
    labelOptions = labelOptions(noHide = T, direction = 'right')
  )%>%
  addCircleMarkers(
    lng=-118.45280, lat=34.078079, radius = 5,
    label='On the left',
    labelOptions = labelOptions(noHide = T, direction = 'left')
  )%>%
  addCircleMarkers(
    lng=-118.456554, lat=34.079979, radius = 5,
    label='On the Top',
    labelOptions = labelOptions(noHide = T, direction = 'top',
                                offset=c(0,-15))
  )%>%
  addCircleMarkers(
    lng=-118.456554, lat=34.076279, radius = 5,
    label='On the Bottom',
    labelOptions = labelOptions(noHide = T, direction = 'bottom',
                                offset=c(0,15)))
#' <br/><br/>


# Change Text Size and text Only and also a custom CSS
leaflet() %>% addTiles() %>% setView(-118.456554,34.09,13) %>%
  addMarkers(
    lng=-118.456554, lat=34.07,
    label='Default Label',
    labelOptions = labelOptions(noHide = T)) %>%
  addMarkers(
    lng=-118.456554, lat=34.085,
    label='Label w/o surrounding box',
    labelOptions = labelOptions(noHide = T, textOnly = TRUE)) %>%
  addMarkers(
    lng=-118.456554, lat=34.095,
    label='label w/ textsize 15px',
    labelOptions = labelOptions(noHide = T, textsize='15px')) %>%
  addMarkers(
    lng=-118.456554, lat=34.11,
    label='Label w/ custom CSS style',
    labelOptions = labelOptions(noHide = T, textOnly = FALSE,
                                style=list(
                                  'color'='red',
                                  'font-family'= 'serif',
                                  'font-style'= 'italic',
                                  'box-shadow' = '3px 3px rgba(0,0,0,0.25)',
                                  'font-size' = '12px',
                                  'border-color' = 'rgba(0,0,0,0.5)'
                                  )))
#' <br/><br/>

# Polygon + HTML Label
leaflet() %>% addTiles() %>%
  addRectangles(
    lng1=-118.456554, lat1=34.078039,
    lng2=-118.436383, lat2=34.062717,
    fillColor = "transparent",
    label= htmltools::HTML("<em>I'm a HTML Label</em>")
  )
#' <br/><br/>

# Examples with more than one Labels

cities <- read.csv(textConnection("
City,Lat,Long,Pop
Boston,42.3601,-71.0589,645966
Hartford,41.7627,-72.6743,125017
New York City,40.7127,-74.0059,8406000
Philadelphia,39.9500,-75.1667,1553000
Pittsburgh,40.4397,-79.9764,305841
Providence,41.8236,-71.4222,177994
"))
#' <br/><br/>

# Polygons with Label as formula
leaflet(cities) %>% addTiles() %>%
  addCircles(lng = ~Long, lat = ~Lat, weight = 1,
             radius = ~sqrt(Pop) * 30, label = ~as.character(City))
#' <br/><br/>

# Polygons with Label as formula and custom label options
leaflet(cities) %>% addTiles() %>%
  addCircles(lng = ~Long, lat = ~Lat, weight = 1,
             radius = ~sqrt(Pop) * 30, label = ~City,
               labelOptions = lapply(1:nrow(cities), function(x) {
                 labelOptions(opacity=0.8)
               }))
#' <br/><br/>

# Markers with Label as formula and custom Label options
leaflet(cities) %>% addTiles() %>%
  addMarkers(lng = ~Long, lat = ~Lat,
             label = ~City,
             labelOptions = lapply(1:nrow(cities), function(x) {
               labelOptions(opacity=0.9)
             }))
#' <br/><br/>


# Circle Markers with static Label as formula and custom Label options
leaflet(cities) %>% addTiles() %>%
  addCircleMarkers(lng = ~Long, lat = ~Lat,
             label = ~City,
             labelOptions = lapply(1:nrow(cities), function(x) {
               labelOptions(opacity=1, noHide = T,
                            direction = 'auto', offset=c(20,-15))
             }))
#' <br/><br/>

# Markers with Label as HTMLized List and custom Label options
library(htmltools)
leaflet(cities) %>% addTiles() %>%
  addMarkers(lng = ~Long, lat = ~Lat,
             label = mapply(function(x, y) {
               HTML(sprintf("<em>%s:</em> %s", htmlEscape(x), htmlEscape(y)))},
               cities$City, cities$Pop, SIMPLIFY = F),
             labelOptions = lapply(1:nrow(cities), function(x) {
               labelOptions(direction='auto')
             }))
#' <br/><br/>
