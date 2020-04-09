# example

leaflet(atlStorms2005[1,]) %>%
  addTiles() %>%
  addPolylines(color = "blue", offset = 10) %>%
  addPolylines(color = "black", offset = 0)

