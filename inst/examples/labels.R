library(leaflet)
leaflet() %>% addTiles() %>%
  addRectangles(
    lng1=-118.456554, lat1=34.078039,
    lng2=-118.436383, lat2=34.062717,
    fillColor = "transparent",
    label= "I'm a rectangle"
  )


cities <- read.csv(textConnection("
City,Lat,Long,Pop
Boston,42.3601,-71.0589,645966
Hartford,41.7627,-72.6743,125017
New York City,40.7127,-74.0059,8406000
Philadelphia,39.9500,-75.1667,1553000
Pittsburgh,40.4397,-79.9764,305841
Providence,41.8236,-71.4222,177994
"))

leaflet(cities) %>% addTiles() %>%
  addCircles(lng = ~Long, lat = ~Lat, weight = 1,
             radius = ~sqrt(Pop) * 30, label = ~City,
               labelOptions = lapply(1:nrow(cities), function(x) {
                 labelOptions(opacity=0.8)
               })
             )

leaflet(cities) %>% addTiles() %>%
  addMarkers(lng = ~Long, lat = ~Lat,
             label = ~City,
             labelOptions = lapply(1:nrow(cities), function(x) {
               labelOptions(opacity=0.9)
             })
             )

