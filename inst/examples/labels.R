library(leaflet)

# Marker + Label
leaflet() %>% addTiles() %>%
  addMarkers(
    lng=-118.456554, lat=34.078039,
    label='This is a label')

# Marker + Static Label using custom label options
leaflet() %>% addTiles() %>%
  addMarkers(
    lng=-118.456554, lat=34.078039,
    label='This is a static label',
    labelOptions = labelOptions(noHide = T))

# Polygon + HTML Label
leaflet() %>% addTiles() %>%
  addRectangles(
    lng1=-118.456554, lat1=34.078039,
    lng2=-118.436383, lat2=34.062717,
    fillColor = "transparent",
    label= htmltools::HTML("<em>I'm a HTML Label</em>")
  )

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

# Polygons with Label as formula
leaflet(cities) %>% addTiles() %>%
  addCircles(lng = ~Long, lat = ~Lat, weight = 1,
             radius = ~sqrt(Pop) * 30, label = ~as.character(City))

# Polygons with Label as formula and custom label options
leaflet(cities) %>% addTiles() %>%
  addCircles(lng = ~Long, lat = ~Lat, weight = 1,
             radius = ~sqrt(Pop) * 30, label = ~City,
               labelOptions = lapply(1:nrow(cities), function(x) {
                 labelOptions(opacity=0.8)
               })
             )

# Markers with Label as formula and custom Label options
leaflet(cities) %>% addTiles() %>%
  addMarkers(lng = ~Long, lat = ~Lat,
             label = ~City,
             labelOptions = lapply(1:nrow(cities), function(x) {
               labelOptions(opacity=0.9)
             })
             )


# Circle Markers with static Label as formula and custom Label options
leaflet(cities) %>% addTiles() %>%
  addCircleMarkers(lng = ~Long, lat = ~Lat,
             label = ~City,
             labelOptions = lapply(1:nrow(cities), function(x) {
               labelOptions(opacity=0.9, noHide = T)
             })
             )

# Markers with Label as HTMLized List and custom Label options
library(htmltools)
leaflet(cities) %>% addTiles() %>%
  addMarkers(lng = ~Long, lat = ~Lat,
             label = mapply(function(x, y) {
               HTML(sprintf("<em>%s:</em> %s", htmlEscape(x), htmlEscape(y)))},
               cities$City, cities$Pop, SIMPLIFY = F),
             labelOptions = lapply(1:nrow(cities), function(x) {
               labelOptions(opacity=0.9)
             })
             )
