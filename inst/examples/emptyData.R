library(dplyr)
library(leaflet)
library(sp)

# Markers with empty data

leaflet(quakes[FALSE, ]) %>% addMarkers()
leaflet(quakes[FALSE, ]) %>% addAwesomeMarkers()
leaflet(quakes[FALSE, ]) %>% addCircleMarkers()
leaflet(quakes[FALSE, ]) %>% addCircles()

# Markers with missing data
# NewYork has missing Long
cities <- read.csv(textConnection("
City,Lat,Long,Pop
Boston,42.3601,-71.0589,645966
Hartford,41.7627,-72.6743,125017
New York City,40.7127,NA,8406000
Philadelphia,39.9500,-75.1667,1553000
Pittsburgh,40.4397,-79.9764,305841
Providence,41.8236,-71.4222,177994"))

leaflet(cities) %>% addTiles() %>% addMarkers()
leaflet(cities) %>% addTiles() %>% addAwesomeMarkers()
leaflet(cities) %>% addTiles() %>% addCircleMarkers()
leaflet(cities) %>% addTiles() %>% addCircles(radius = ~sqrt(Pop) * 30)
leaflet(cities) %>% addTiles() %>% addPopups(popup = ~as.character(City))

# Polylines with empty data

coords      <- matrix(c(1, 2, 3, 4), nrow = 2)
line        <- Line(coords)
sp_lines    <- SpatialLines(list(Lines(list(line), ID = 1)))
sp_lines_df <- sp::SpatialLinesDataFrame(sp_lines, data = data.frame(x = 1))

# This works ok
sp_lines_df %>% leaflet() %>% addPolylines()

# Subset the data to get SpatialLinesDataFrame without data
sub_df <- sp_lines_df[sp_lines_df$x > 1, ]

sub_df %>% leaflet() %>% addPolylines()
