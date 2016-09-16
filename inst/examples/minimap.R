library(leaflet)

l <- leaflet() %>% setView(0,0,3)

#' Default Minimap
l %>% addTiles() %>% addMiniMap()

#' <br/>
#' Different basemap for the minimap and togglable
l %>% addProviderTiles(providers$Esri.WorldStreetMap) %>%
  addMiniMap(
             tiles = providers$Esri.WorldStreetMap,
             toggleDisplay = T)

#' <br/>
#' Slightly advanced use case
#' Change minimap basemap to match main map's basemap
#' This approach will work for basemaps added via addProviderTiles
#' But not for one's added with addTiles using a URL schema.
m <- l
esri <- providers %>%
  purrr::keep(~ grepl('^Esri',.))

esri %>%
  purrr::walk(function(x) m <<- m %>% addProviderTiles(x,group=x))

m %>%
  addLayersControl(
    baseGroups = names(esri),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  addMiniMap(
             tiles = esri[[1]],
             toggleDisplay = T) %>%
  htmlwidgets::onRender("
    function(el, x) {
      var myMap = this.getMap();
      myMap.on('baselayerchange',
        function (e) {
          myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
        })
    }")

#' <br/><br/>
#' Another advanced use case
#' Minimap with markers.
#' Note the use of 'group' ID to find markers in main map and add corresponding CircleMarkers in minimap.
#' The V8 part is simply to read the JSON embeded in the Javascript.<br/>
#' For a geojson file `jsonlite::fromfromJSON()` or `geojsonio::regeojson_read()` will do
#'
jsURL <- 'https://rawgit.com/Norkart/Leaflet-MiniMap/master/example/local_pubs_restaurant_norway.js'
v8 <- V8::v8()
v8$source(jsURL)
geoJson <- geojsonio::as.json(v8$get('pubsGeoJSON'))

# This is the kicker, convert geojson to a Spatial object.
# This then allows us to use formulas in our markers, polygons etc.
spdf <- geojsonio::geojson_sp(geoJson)

icons <- awesomeIconList(
  pub = makeAwesomeIcon(icon='glass', library='fa', markerColor = 'red'),
  restaurant = makeAwesomeIcon(icon='cutlery', library='fa', markerColor = 'blue')
)

leaflet() %>% addTiles() %>%
  setView(10.758276373601069, 59.92448055859924, 13) %>%
  addAwesomeMarkers(data=spdf,
             label=~stringr::str_c(amenity,': ', name),
             icon = ~icons[amenity],
             options = markerOptions(riseOnHover = TRUE, opacity = 0.75),
             group = 'pubs') %>%
  addMiniMap() %>%
  htmlwidgets::onRender("
    function(el, t) {
      var myMap = this.getMap();

      var pubs = myMap.layerManager._byGroup.pubs;
      var pubs2 = new L.FeatureGroup();

      for(pub in pubs) {
        var m = new L.CircleMarker(pubs[pub]._latlng, {radius: 2});
        pubs2.addLayer(m);
      }
      var layers = new L.LayerGroup([myMap.minimap._layer, pubs2]);
      myMap.minimap.changeLayer(layers);
    }")

#' <br/><br/>
#' Finally combine the approaches in last 2 examples
#' Minimap w/ changable layers and circle markers.
m <- leaflet()
esri %>%
  purrr::walk(function(x) m <<- m %>% addProviderTiles(x,group=x))
m %>%
  setView(10.758276373601069, 59.92448055859924, 13) %>%
  addAwesomeMarkers(data=spdf,
             label=~stringr::str_c(amenity,': ', name),
             icon = ~icons[amenity],
             options = markerOptions(riseOnHover = TRUE, opacity = 0.75),
             group = 'pubs') %>%
  addLayersControl(
    baseGroups = names(esri),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  addMiniMap(tiles = esri[[1]],
             toggleDisplay = T) %>%
  htmlwidgets::onRender("
    function(el, t) {
      var myMap = this.getMap();

      var pubs = myMap.layerManager._byGroup.pubs;
      var pubs2 = new L.FeatureGroup();

      for(pub in pubs) {
        var m = new L.CircleMarker(pubs[pub]._latlng, {radius: 2});
        pubs2.addLayer(m);
      }
      var layers = new L.LayerGroup([myMap.minimap._layer, pubs2]);

      myMap.minimap.changeLayer(layers);

      myMap.on('baselayerchange',
        function (e) {
          myMap.minimap.changeLayer(
            new L.LayerGroup([L.tileLayer.provider(e.name), pubs2]));
        });
    }")
