locationFilter2Dependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-locationfilter2",
      "0.1.0",
      system.file("htmlwidgets/plugins/leaflet-locationfilter", package = "leaflet"),
      script = c("locationfilter.js", "locationfilter-bindings.js"),
      stylesheet = c("locationfilter.css")
    )
  )
}

addSelect <- function(map, data = getMapData(map)) {
  map$dependencies <- c(map$dependencies,
    leafletEasyButtonDependencies(),
    locationFilter2Dependencies())
  map <- addIonIcon(map)

  invokeMethod(map, data, "addSelect",
    getCrosstalkOptions(data)[["ctGroup"]]
  )
}

removeSelect <- function(map) {
  invokeMethod(map, NULL, "removeSelect")
}
