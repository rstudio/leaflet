# example
# allows bidirectional flow not to overlap
leaflet(corunaroads) %>%
  addTiles() %>%
  addPolylines(offset = 2.5)
