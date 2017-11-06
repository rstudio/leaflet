library(leaflet)

leaf <- leaflet() %>%
  addProviderTiles(providers$OpenStreetMap)

#' <br/>
#' Default Behavior
leaf %>%
  # central park
  fitBounds(-73.9, 40.75, -73.95,40.8) %>%
  addMeasure()

#' <br/>
#' Customization
leaf %>%
  # Berling, Germany with German localization
  fitBounds(13.76134, 52.675499, 13.0884, 52.33812) %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479",
    localization='de'
  )
