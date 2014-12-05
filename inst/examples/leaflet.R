# !formatR
library(leaflet)
m = leaflet() %>% tileLayer()
m  # a map with the default OSM tile layer

# set bounds
m %>% fitBounds(40, 0, 50, 10)

# move the center to Snedecor Hall
m = m %>% setView(c(42.0285, -93.65), zoom = 17)
m

# popup
m %>% mapPopup(42.0285, -93.65, 'Here is the <b>Department of Statistics</b>, ISU')
rand_lat = function(n = 10) rnorm(n, 42.0285, .01)
rand_lng = function(n = 10) rnorm(n, -93.65, .01)

# TODO: only one popup can be opened; need to bind all popups in a layer and show all
m %>% mapPopup(rand_lat(), rand_lng(), 'Random popups')

# marker
m %>% mapMarker(rand_lat(), rand_lng())

# circle (units in metres)
m %>% mapCircle(rand_lat(50), rand_lng(50), radius = runif(50, 5, 15))

# circle marker (units in pixels)
m %>% mapCircleMarker(rand_lat(50), rand_lng(50), options = list(color = '#ff0000'))
m %>% mapCircleMarker(rand_lat(100), rand_lng(100), radius = runif(100, 5, 15))

# rectangle
m %>% mapRectangle(
  rand_lat(), rand_lng(), rand_lat(), rand_lng(),
  options = list(color = 'red', fill = FALSE, dashArray = '5,5', weight = 3)
)

# polyline
m %>% mapPolyline(rand_lat(50), rand_lng(50))

# polygon
m %>% mapPolygon(rand_lat(), rand_lng(), layerId = 'foo')

# geoJSON
seattle_geojson <- list(
  type = "Feature",
  geometry = list(
    type = "MultiPolygon",
    coordinates = list(list(list(
      c(-122.36075812146,  47.6759920119894),
      c(-122.360781646764, 47.6668890126755),
      c(-122.360782108665,  47.6614990696722),
      c(-122.366199035722, 47.6614990696722),
      c(-122.366199035722,  47.6592874248973),
      c(-122.364582509469, 47.6576254522105),
      c(-122.363887331445,  47.6569107302038),
      c(-122.360865528129, 47.6538418253251),
      c(-122.360866157644,  47.6535254473167),
      c(-122.360866581103, 47.6533126275176),
      c(-122.362526540691,  47.6541872926348),
      c(-122.364442114483, 47.6551892850798),
      c(-122.366077719797,  47.6560733960606),
      c(-122.368818463838, 47.6579742346694),
      c(-122.370115159943,  47.6588730808334),
      c(-122.372295967029, 47.6604350102328),
      c(-122.37381369088,  47.660582362063),
      c(-122.375522972109, 47.6606413027949),
      c(-122.376079703095,  47.6608793094619),
      c(-122.376206315662, 47.6609242364243),
      c(-122.377610811371,  47.6606160735197),
      c(-122.379857378879, 47.6610306942278),
      c(-122.382454873022,  47.6627496239169),
      c(-122.385357955057, 47.6638573778241),
      c(-122.386007328104,  47.6640865692306),
      c(-122.387186331506, 47.6654326177161),
      c(-122.387802656231,  47.6661492860294),
      c(-122.388108244121, 47.6664548739202),
      c(-122.389177800763,  47.6663784774359),
      c(-122.390582858689, 47.6665072251861),
      c(-122.390793942299,  47.6659699214511),
      c(-122.391507906234, 47.6659200946229),
      c(-122.392883050767,  47.6664166747017),
      c(-122.392847210144, 47.6678696739431),
      c(-122.392904778401,  47.6709016021624),
      c(-122.39296705153, 47.6732047491624),
      c(-122.393000803496,  47.6759322346303),
      c(-122.37666945305, 47.6759896300663),
      c(-122.376486363943,  47.6759891899754),
      c(-122.366078869215, 47.6759641734893),
      c(-122.36075812146,  47.6759920119894)
    )))
  ),
  properties = list(
    name = "Ballard",
    population = 48000,
    # You can inline styles if you want
    style = list(
      fillColor = "yellow",
      weight = 2,
      color = "#000000"
    )
  ),
  id = "ballard"
)
m %>% setView(c(47.6759920119894, -122.36075812146), zoom = 13) %>% mapGeoJSON(seattle_geojson)


# use the OSM BW layer
leaflet() %>% tileLayer('http://{s}.www.toolserver.org/tiles/bw-mapnik/{z}/{x}/{y}.png', list(
  attribution = paste(
    '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,',
    '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
  )
))
