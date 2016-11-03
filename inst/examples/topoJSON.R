library(leaflet)

# topoJSON as a string
R_topojsonObject_asString <-
  readr::read_file('https://rawgit.com/TrantorM/leaflet-choropleth/gh-pages/examples/basic_topo/crimes_by_district.topojson')


leaflet() %>%
  setView(-75.14, 40, zoom = 11) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addTopoJSON(
    R_topojsonObject_asString,
    popupProperty = JS("function(feature){return 'District ' + feature.properties.dist_num + '<br>' + feature.properties.incidents.toLocaleString() + ' incidents';}"),
    labelProperty = 'dist_num',
    color='#000000', fillColor='#ff0000', weight=1, fillOpacity = 0.5,
    highlightOptions =
      highlightOptions(fillOpacity=1, weight=2, opacity=0.7, color='#000000',
                       fillColor = 'orange',
                       bringToFront=TRUE)
  )
