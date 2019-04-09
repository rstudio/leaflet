leafletPolylineoffsetDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-polylineoffset",
      "1.1.1",
      system.file("htmlwidgets/lib/leaflet-polylineoffset", package = "leafletfmm"),
      script = "leaflet.polylineoffset.js"
    )
  )
}
