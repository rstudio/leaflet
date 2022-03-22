
library(leaflet)
library(sp)
#' <br/><br/>
#' The V8 part is simply to read the JSON embeded in the Javascript.<br/>
#' For a geojson file `jsonlite::fromfromJSON()` or `geojsonio::regeojson_read()` will do
#'
jsURL <- "https://rawgit.com/Norkart/Leaflet-MiniMap/master/example/local_pubs_restaurant_norway.js"
v8 <- V8::v8()
v8$source(jsURL)
geoJson <- geojsonio::as.json(v8$get("pubsGeoJSON"))

# This is the kicker, convert geojson to a Spatial object.
# This then allows us to use formulas in our markers, polygons etc.
spdf <- geojsonio::geojson_sp(geoJson)

icons <- awesomeIconList(
  pub = makeAwesomeIcon(icon = "glass", library = "fa", markerColor = "red"),
  restaurant = makeAwesomeIcon(icon = "cutlery", library = "fa", markerColor = "blue")
)

leaflet() %>% addTiles() %>%
  setView(10.758276373601069, 59.92448055859924, 13) %>%
  addAwesomeMarkers(data = spdf,
             label = ~stringr::str_c(amenity, ": ", name),
             icon = ~icons[amenity],
             options = markerOptions(riseOnHover = TRUE, opacity = 0.75),
             group = "pubs")


#' <br/><br/>
#' Another examples this time with polygons
url <- "https://www.partners-popdev.org/wp-content/themes/original-child/vendor/Geojson/States/Maharashtra.geojson"

mhSPDF <- geojsonio::geojson_read(url, what = "sp")

cols <- colorFactor(topo.colors(nrow(mhSPDF)), mhSPDF$NAME_2)

leaflet() %>% addProviderTiles(providers$Stamen.TonerLite) %>%
  setView(75.7139, 19.7515, 6) %>%
  addPolygons(data = mhSPDF, opacity = 5,
              label = ~NAME_2, weight = 1,
              fillColor = ~cols(NAME_2))
