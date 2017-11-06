library(leaflet)
# Default
l <- leaflet() %>% addProviderTiles(providers$OpenStreetMap) %>% setView(0,0,1)

#' Default simple Graticule
l %>% addSimpleGraticule()

#' <br/>
#' Custom Params
l %>% addSimpleGraticule(interval = 40, showOriginLabel = F)

#' <br/>
#' Custom Resolution + Custom Date and on a toggleable Layer
l %>%
  addSimpleGraticule(interval=40,
                showOriginLabel = F,
                group="graticule") %>%
  addLayersControl(
    overlayGroups = c("graticule"),
    options = layersControlOptions(collapsed = FALSE)
  )
