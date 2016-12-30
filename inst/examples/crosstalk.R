# devtools::install_github("rstudio/crosstalk")
# devtools::install_github("rstudio/leaflet")

library(crosstalk)
library(leaflet)
library(htmlwidgets)

rand_lng = function(n = 10) rnorm(n, -93.65, .01)
rand_lat = function(n = 10) rnorm(n, 42.0285, .01)

pts <- SharedData$new(
  data.frame(
    lng = rand_lng(),
    lat = rand_lat()
  ),
  group = "grp1"
)


lf <- leaflet(pts) %>%
  addTiles() %>%
  addMarkers()


onRender(
  lf,
"
function(el,x) {
  debugger;
  var sl = new crosstalk.SelectionHandle('grp1');
  sl.on('change', function(val){console.log(val);})
}
"
)
