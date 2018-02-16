library(testit)

icons <- c("leaf-green.png", "leaf-red.png")
m <- leaflet(data = data.frame(color = sample.int(2, 30, replace = TRUE))) %>%
  addMarkers(1:30, 30:1, icon = icons(
    iconUrl = ~icons[color],
    shadowUrl = c("leaf-shadow.png"),
    iconWidth = 38, iconHeight = 95, iconAnchorX = 22, iconAnchorY = 94,
    shadowWidth = 50, shadowHeight = 64, shadowAnchorX = 4, shadowAnchorY = 62
  ))
assert(
  "icon deduping works",
  identical(length(m$x$calls[[1]]$args[[3]]$iconUrl$data), 2L),
  TRUE
)
