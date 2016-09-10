# Now that there is a providers list
# You can programmatically add providers
# Here I show how to add all 'ESRI' provided basemaps.
# Checkout the providers list for all available providers.

library(leaflet)

m <- leaflet() %>% setView(0,0,1)

esri <- providers %>%
  purrr::keep(~ grepl('^Esri',.))

esri %>%
  purrr::walk(function(x) m <<- m %>% addProviderTiles(x,group=x))

m %>%
  addLayersControl(
    baseGroups = names(esri),
    options = layersControlOptions(collapsed = FALSE)
  )
