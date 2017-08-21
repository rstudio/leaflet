library(leaflet)
pal <- colorQuantile("YlOrRd", quakes$mag)

leaflet(quakes) %>%
  addProviderTiles(providers$Esri.OceanBasemap, group = "basic") %>%
  addCircleMarkers(group = "detail", fillOpacity = 0.5,
  radius = ~mag * 5, color = ~pal(mag), stroke = FALSE) %>%
  addLegend(pal = pal, values = ~mag, group='detail', position='bottomleft')

l <- leaflet(quakes) %>%
  addProviderTiles(providers$Esri.OceanBasemap, group = "basic") %>%
  addMarkers(data = quakes, group = "basic") %>%
  addCircleMarkers(group = "detail", fillOpacity = 0.5,
  radius = ~mag * 5, color = ~pal(mag), stroke = FALSE) %>%
  addLegend(pal = pal, values = ~mag, group='detail', position='bottomleft')  %>%
  groupOptions("detail", zoomLevels = 7:18) %>%
  addControl(htmltools::HTML("Zoom Level"), position = "topright",
             layerId = "zoom_display")

# Just to show the zoom level
htmlwidgets::onRender(l, jsCode = htmlwidgets::JS(
  "function(el, x) {
    debugger;
    var map = this;
    detailsControl = document.getElementById('zoom_display');
    detailsControl.innerHTML = '<div>Zoom Level:'+map.getZoom()+'</div>';
    map.on('zoomend', function(e) {
       detailsControl = document.getElementById('zoom_display');
       detailsControl.innerHTML = '<div>Zoom Level:'+map.getZoom()+'</div>';
    });
  }"))
