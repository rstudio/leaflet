leafletPolylineoffsetDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-polylineoffset",
      "1.1.1",
      system.file("htmlwidgets/lib/leaflet-polylineoffset", package = "leaflet"),
      script = "leaflet.polylineoffset.js"
    )
  )
}
