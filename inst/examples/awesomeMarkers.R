library(leaflet)

leaflet() %>% addTiles() %>%
  addAwesomeMarkers()

cities <- read.csv(textConnection("
City,Lat,Long,Pop
Boston,42.3601,-71.0589,645966
Hartford,41.7627,-72.6743,125017
New York City,40.7127,-74.0059,8406000
Philadelphia,39.9500,-75.1667,1553000
Pittsburgh,40.4397,-79.9764,305841
Providence,41.8236,-71.4222,177994
"))

icons <- lapply(seq_along(nrow(cities)), createAwesomeMarkerIcon)

leaflet(cities) %>% addTiles() %>%
  addAwesomeMarkers() %>%
  addMarkers(lng = ~Long, lat = ~Lat,
             label = ~City
  )

leaflet() %>% addTiles() %>%
  addMarkers(
    lng=-118.456554, lat=34.078039,
    label='This is a label',
    icon = createAwesomeMarkerIcon()
  )
