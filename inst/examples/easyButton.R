library(leaflet)

#' Add two easy buttons.
#' first to set zoom level to 1,
#' second to find your self
leaflet() %>% addTiles() %>%
  addEasyButton(easyButton(
    icon='fa-globe', title='Zoom to Level 1',
    onClick=JS("function(btn, map){ map.setZoom(1);}"))) %>%
  addEasyButton(easyButton(
    icon='fa-crosshairs', title='Locate Me',
    onClick=JS("function(btn, map){ map.locate({setView: true});}")))

#' <br/><br/>Toggle Button to freeze/unfreeze clustering at a zoom level.
leaflet() %>% addTiles() %>%
  addMarkers(data=quakes,
             clusterOptions = markerClusterOptions(),
             clusterId = 'quakesCluster') %>%
  addEasyButton(easyButton(
    states = list(
      easyButtonState(
        stateName='unfrozen-markers',
        icon='ion-toggle',
        title='Freeze Clusters',
        onClick = JS("
          function(btn, map) {
            var clusterManager =
              map.layerManager.getLayer('cluster',
                                        'quakesCluster');
            clusterManager.freezeAtZoom();
            btn.state('frozen-markers');
          }")
      ),
      easyButtonState(
        stateName='frozen-markers',
        icon='ion-toggle-filled',
        title='UnFreeze Clusters',
        onClick = JS("
          function(btn, map) {
            var clusterManager =
              map.layerManager.getLayer('cluster',
                                        'quakesCluster');
            clusterManager.unfreeze();
            btn.state('unfrozen-markers');
          }")
      )
    )
  ))

#' <br/><br/>Add two easy buttons in a bar
#' first to set zoom level to 1
#' second to find your self
leaflet() %>% addTiles() %>%
  addEasyButtonBar(
    easyButton(
      icon='fa-globe', title='Zoom to Level 1',
      onClick=JS("function(btn, map){ map.setZoom(1);}")),
    easyButton(
      icon='fa-crosshairs', title='Locate Me',
      onClick=JS("function(btn, map){ map.locate({setView: true});}"))
  )
