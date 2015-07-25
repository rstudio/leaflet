library(shiny)
# library(leaflet)
library(rgdal)
library(jsonlite)
r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()
geojson <- readLines("countries.geojson", warn = FALSE) %>%
  paste(collapse = "\n") %>%
  fromJSON(simplifyVector = FALSE)
geojson$style = list(
  weight = 1,
  color = "#555555",
  opacity = 1,
  fillOpacity = 0.8
)
# Gather GDP estimate from all countries
gdp_md_est <- sapply(geojson$features, function(feat) {
  feat$properties$gdp_md_est
})
# Gather population estimate from all countries
pop_est <- sapply(geojson$features, function(feat) {
  max(1, feat$properties$pop_est)
})
# Color by per-capita GDP using quantiles
pal <- colorQuantile("Greens", gdp_md_est / pop_est)
# Add a properties$style list to each feature
geojson$features <- lapply(geojson$features, function(feat) {
  feat$properties$style <- list(
    fillColor = pal(
      feat$properties$gdp_md_est / max(1, feat$properties$pop_est)),
    weight = 1,
    color = "#55555"
  )
  feat
})
countries <- sapply(geojson$features,function(x) x$properties$admin)
ui <-
  navbarPage(title="R-Shiny/Leaflet Interactions",
    tabPanel("Map",
    # Can't get map to show full-screen, see prod on old version
    # div(class="outer",
    # tags$head(includeCSS("inst/examples/styles.css")),
      fluidPage(
        fluidRow(
          column(2,
            actionButton("addLayers", "add layers"),
            actionButton("addbasemap", "addbasemap"),
            actionButton("clearbasemap", "clearbasemap"),
            actionButton("clear", "clear"),
            actionButton("addPopup", "addPopup"),
            actionButton("clearPopup", "clearPopup"),
            actionButton("addGeojson", "addGeojson"),
            actionButton("clearGeojson", "clearGeojson"),
            checkboxInput('popupAll', 'popupAll', value = FALSE),
            selectInput('countries', label = "countries", choices = countries,selected = NULL)
          ),
          column(10,
             # Can't get map to show full-screen, see prod on old version
             # uiOutput("mymap",inline=TRUE))
             leafletOutput("mymap","83.333%",800)

          )
        )
      )
    )
  )
server <- function(input, output, session) {
    # proxy <- leafletProxy("mymap")
    # output$mymap <- renderLeaflet(proxy)
    # Can't get map to show full-screen, see prod on old version
    # output$mymap <- renderUI(leafletOutput("mymap","100%","100%))
  observeEvent(input$addLayers, {
    leafletProxy("mymap") %>%
      addTiles(urlTemplate = "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/nexrad-n0q-900913/{z}/{x}/{y}.png",
               attribution = NULL, layerId = NULL, options = tileOptions(zIndex=1)) %>%
      addTiles(urlTemplate = "http://server.arcgisonline.com/ArcGIS/rest/services/USA_Topo_Maps/MapServer/tile/{z}/{y}/{x}",
               attribution = NULL, layerId = NULL, options = tileOptions(zIndex=0))
  })
  observe({
    content <- NULL
    if (is.null(input$mymap_geojson_click)==FALSE&&isolate({input$popupAll==FALSE})) {
      isolate({
        content <- as.character(tagList(

          tags$strong(paste0("ID: ",input$mymap_geojson_click$featureId)),
          tags$a(target="_blank",href=sprintf("http://www.google.com/maps/place/%s,%s/@%s,%s,%sz/data=!3m1!1e3",input$mymap_geojson_click$lat, input$mymap_geojson_click$lng,input$mymap_geojson_click$lat, input$mymap_geojson_click$lng,input$mymap_zoom), "Google Maps")

        ))
        leafletProxy("mymap") %>% clearPopups()
        leafletProxy("mymap") %>% addPopups(input$mymap_geojson_click$lng, input$mymap_geojson_click$lat, content)
      })
    }
  })
  observe({
    content <- NULL
    if (is.null(input$mymap_click)==FALSE&&isolate({input$popupAll==FALSE})) {
      isolate({
        content <- as.character(tagList(
          tags$strong(paste0("Map cLick: ",input$mymapn_click$id)),
          tags$a(target="_blank",href=sprintf("http://www.google.com/maps/place/%s,%s/@%s,%s,%sz/data=!3m1!1e3",input$mymap_click$lat, input$mymap_click$lng,input$mymap_click$lat, input$mymap_click$lng,input$mymap_zoom), "Google Maps")

        ))
        leafletProxy("mymap") %>% clearPopups()
        leafletProxy("mymap") %>% addPopups(input$mymap_click$lng+0.01, input$mymap_click$lat+0.01, content)
      })
    }
  })
  observe({
    if(is.null(input$mymap_click)==FALSE ){
      isolate({
        if(input$popupAll == TRUE){
          content <- as.character(tagList(
            tags$strong(paste0("all Click ",input$mymap_click$lat,input$mymap_click$lng)),
            tags$a(target="_blank",href=sprintf("http://www.google.com/maps/place/%s,%s/@%s,%s,%sz/data=!3m1!1e3",input$mymap_click$lat, input$mymap_click$lng,input$mymap_click$lat, input$mymap_click$lng,input$mymap_zoom), "Google Maps")

          ))
          leafletProxy("mymap") %>% clearPopups()
          leafletProxy("mymap") %>% addPopups(input$mymap_click$lng, input$mymap_click$lat, content)
        }
      })
    }
  })
  observe({
    if(is.null(input$mymap_geojson_click)==FALSE ){
      isolate({
        if(input$popupAll == TRUE){
          content <- as.character(tagList(
            tags$strong(paste0("all Click ",input$mymap_geojson_click$lat,input$mymap_geojson_click$lng)),
            tags$a(target="_blank",href=sprintf("http://www.google.com/maps/place/%s,%s/@%s,%s,%sz/data=!3m1!1e3",input$mymap_geojson_click$lat, input$mymap_geojson_click$lng,input$mymap_geojson_click$lat, input$mymap_geojson_click$lng,input$mymap_zoom), "Google Maps")

          ))
          leafletProxy("mymap") %>% clearPopups()
          leafletProxy("mymap") %>% addPopups(input$mymap_geojson_click$lng, input$mymap_geojson_click$lat, content)
        }
      })
    }
  })
  observeEvent(input$addGeojson, {
    leafletProxy("mymap") %>%
      addGeoJSON(geojson,layerId ='geojsonlayer')
  })
  observeEvent(input$countries, {
    leafletProxy("mymap") %>%
    setStyleGeoJSON(layerId ='geojsonlayer', featureId = input$countries, style = '{"fillColor" :"blue"}')
  })
  observeEvent(input$clearGeojson, {
    leafletProxy("mymap") %>%
      removeGeoJSON(layerId ='geojsonlayer')
  })
  observeEvent(input$addPopup, {
    content <- paste(sep = "<br/>",
                     "<b><a href='http://www.samurainoodle.com'>Samurai Noodle</a></b>",
                     "606 5th Ave. S",
                     "Seattle, WA 98138"
    )
    leafletProxy("mymap") %>%  addPopups(-122.327298, 47.597131, content,
                         options = popupOptions(closeButton = TRUE)
    )
  })
  observeEvent(input$clearPopup, {
    leafletProxy("mymap") %>% clearPopups()
  })
  observeEvent(input$addbasemap, {
    leafletProxy("mymap") %>% addProviderTiles("Acetate.terrain",options = providerTileOptions(noWrap = TRUE,zIndex=0),layerId="basemap")
  })
  observeEvent(input$clearbasemap, {
    leafletProxy("mymap") %>% removeTiles("basemap")
  })
  observeEvent(input$clear, {
    leafletProxy("mymap") %>% clearTiles()
  })
  output$mymap <- renderLeaflet({
    leaflet() %>%
    addMarkers(data = cbind(rnorm(40) * 2 + 13, rnorm(40) + 48))
  })
}
shinyApp(ui, server)

# //NOT WORKING YET
# /*methods.setStyleGeoJSON = function(layerId, attribute, value, command, style) {
#   var layerPicked = this.layerManager.getLayer("geojson", layerId)
#   layerPicked.eachLayer(function (layer) {
#     console.log(attribute)
#     console.log(layer.feature.properties[attribute])
#     console.log(layer.feature.properties[attribute]())
#     if (command == "=") {
#       if(layer.feature.properties[attribute]() == value) {
#         layer.setStyle(JSON.parse(style));
#       }
#     } else if (command == "<") {
#       if(layer.feature.properties[attribute]() < value) {
#         layer.setStyle(JSON.parse(style));
#       }
#     } else if (command == ">") {
#       if(layer.feature.properties[attribute]() > value) {
#         layer.setStyle(JSON.parse(style));
#       }
#     }
#   })
# };*/

