library(leaflet)

#' Add a Level factor to quakes
quakes <- quakes %>%
  dplyr::mutate(mag.level = cut(mag, c(3, 4, 5, 6),
                                labels = c(">3 & <=4", ">4 & <=5", ">5 & <=6")))

l <- leaflet() %>% addTiles()

#' <br/><br/>
#' Default Clustering
l %>%
  addMarkers(data = quakes, clusterOptions = markerClusterOptions())

#' <br/><br/>
#' Clustering Frozen at level 5
l %>%
  addMarkers(data = quakes, clusterOptions = markerClusterOptions(freezeAtZoom = 6))

#' <br/><br/>
#' Clustering of Label Only Clusters
l %>%
  addLabelOnlyMarkers(data = quakes,
                      lng = ~long, lat = ~lat,
                      label = ~as.character(mag),
                      clusterOptions = markerClusterOptions(),
                      labelOptions = labelOptions(noHide = T,
                                                  direction = "auto"))
#' <br/><br/>
#' Clustering + Layers
quakes.df <- split(quakes, quakes$mag.level)

l2 <- l
names(quakes.df) %>%
  purrr::walk( function(df) {
    l2 <<- l2 %>%
      addMarkers(data = quakes.df[[df]],
                          lng = ~long, lat = ~lat,
                          label = ~as.character(mag),
                          popup = ~as.character(mag),
                          group = df,
                          clusterOptions = markerClusterOptions(removeOutsideVisibleBounds = F),
                          labelOptions = labelOptions(noHide = T,
                                                       direction = "auto"))
  })

l2 %>%
  addLayersControl(
    overlayGroups = names(quakes.df),
    options = layersControlOptions(collapsed = FALSE)
  )

#' <br/><br/>
#' Clustering with custom iconCreateFunction
leaflet(quakes) %>% addTiles() %>%
  addMarkers(clusterOptions =
               markerClusterOptions(iconCreateFunction =
                                      JS("
                                          function(cluster) {
                                             return new L.DivIcon({
                                               html: '<div style=\"background-color:rgba(77,77,77,0.5)\"><span>' + cluster.getChildCount() + '</div><span>',
                                               className: 'marker-cluster'
                                             });
                                           }")))
