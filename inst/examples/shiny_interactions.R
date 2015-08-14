library(shiny)
library(leaflet)
library(rgdal)
library(jsonlite)
library(scales)
googleLink <- function(lat,lng,zoom) {
  sprintf("http://www.google.com/maps/place/%s,%s/@%s,%s,%sz/data=!3m1!1e3",
          lat, lng, lat, lng, zoom)
}
geojson <-   fromJSON(system.file("examples/countries.json", package = "leaflet"),simplifyVector = FALSE)

geojson$style = list(
  weight = 1,
  color = "#555555",
  opacity = 1,
  fillOpacity = 0.8
)
geojson$features <- lapply(geojson$features, function(feat) {
  feat$id <- feat$properties$admin # Must set ids
  feat
})

gdp_md_est <- sapply(geojson$features, function(feat) {feat$properties$gdp_md_est})
pop_est <- sapply(geojson$features, function(feat) {feat$properties$pop_est})
ids <- sapply(geojson$features,function(x) x$id)
allCountries <- data.frame(ids = ids, gdp_md_est = gdp_md_est, pop_est = pop_est , stringsAsFactors = FALSE)

# note id specified in GeoJSON on highest level (of single feature) for use in removeFeatureGeoJSON and styleFeatureGeoJSON
bermudaTriangle <- '{
    "type": "Feature",
"id": "Bermuda Triangle",
    "properties": {
    "name": "Bermuda Triangle",
    "area": 1150180
    },
    "geometry": {
    "type": "Polygon",
    "coordinates": [
    [
      [-64.73, 32.31],
      [-80.19, 25.76],
      [-66.09, 18.43],
      [-64.73, 32.31]
      ]
      ]
    }
    }'

ui <-
  navbarPage(title="R-Shiny/Leaflet Interactions",
    tabPanel("Map",
      fluidPage(
        fluidRow(
          column(10,
            div(class="outer",
              tags$head(includeCSS(system.file("examples/styles.css", package = "leaflet"))),
              leafletOutput("mymap","83.333%","100%")
            )
          ),
          column(2,
            h3(""),
            actionButton("addLayers", "add layers"),
            actionButton("addbasemap", "addbasemap"),
            actionButton("clearbasemap", "clearbasemap"),
            actionButton("clear", "clear"),
            actionButton("addPopup", "addPopup"),
            actionButton("clearPopup", "clearPopup"),
            actionButton("addGeojson", "addGeojson"),
            actionButton("clearGeojson", "clearGeojson"),
            actionButton("addBermuda", "addBermuda"),
            actionButton("removeBermuda", "removeBermuda"),
            checkboxInput('popupAll', 'popupAll', value = FALSE),
            selectInput('setstyle', label = "Color a Country Red!", choices = NULL,selected = NULL),
            selectInput('removefeature', label = "Remove a Country!", choices = NULL,selected = NULL),
            selectInput('addfeature', label = "Add back a Country!", choices = NULL,selected = NULL),
            selectInput('colorBy',label="Color by Selected Field!",choices=c("none","gdp_md_est","pop_est"),
                        selected = "None")
          )
        )
      )
    )
  )
server <- function(input, output, session) {
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addMarkers(data = cbind(rnorm(40) * 2 + 13, rnorm(40) + 48))
  })
  addedData <- reactiveValues()
  addedData$df <- allCountries
  removedData <- reactiveValues()
  removedData$ids <- data.frame(ids = as.character(), gdp_md_est = as.numeric(), pop_est = as.numeric(), stringsAsFactors = FALSE)

  observeEvent(input$colorBy, {
    if (input$colorBy == "none") {
      for (i in 1:length(addedData$df$ids)) {
        leafletProxy("mymap") %>%
          styleFeatureGeoJSON(layerId ='geojsonlayer', featureId = addedData$df$ids[i],
                          style = sprintf('{"fillColor": "%s"}',"blue"))
      }
    } else {
      colorByData <- rescale(addedData$df[[input$colorBy]])
      pal <- colorBin("Greens", 0:1,bins=10)
      addColorSetStyle <- function(featureId,color) {
        leafletProxy("mymap") %>%
          styleFeatureGeoJSON(layerId ='geojsonlayer', featureId = featureId,
                          style = sprintf('{"fillColor": "%s"}',pal(color)))
      }
      mapply(addColorSetStyle,addedData$df$ids,colorByData)
    }
  })

  observeEvent(input$addLayers, {
    leafletProxy("mymap") %>%
      addTiles(urlTemplate = "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/nexrad-n0q-900913/{z}/{x}/{y}.png",
               attribution = NULL, layerId = NULL, options = tileOptions(zIndex=1)) %>%
      addTiles(urlTemplate = "http://server.arcgisonline.com/ArcGIS/rest/services/USA_Topo_Maps/MapServer/tile/{z}/{y}/{x}",
               attribution = NULL, layerId = NULL, options = tileOptions(zIndex=0)) %>%
      addWMSTiles(baseUrl = "http://gis1.usgs.gov/arcgis/services/gap/PADUS_Status/MapServer/WMSServer",layers = "0",
                  layerId = "wms_protectedArea",options = WMSTileOptions(styles = "", format = "image/png8", transparent = TRUE,
                                                                          opacity = ".5",zIndex="2.1"))
  })
  observeEvent(input$mymap_geojson_click, {
    if (input$popupAll==FALSE) {
      content <- as.character(tagList(
        tags$strong(paste0("GeoJSON ID: ",input$mymap_geojson_click$properties$admin)),
        tags$a(target="_blank",href=googleLink(input$mymap_geojson_click$lat, input$mymap_geojson_click$lng,input$mymap_zoom),"Google Maps")
      ))
      leafletProxy("mymap") %>% clearPopups()
      leafletProxy("mymap") %>% addPopups(input$mymap_geojson_click$lng, input$mymap_geojson_click$lat, content)
    }
  })
  observeEvent(input$mymap_click, {
    if (input$popupAll==FALSE) {
        content <- as.character(tagList(
          tags$strong("Basemap Click "),
          tags$a(target="_blank",href=googleLink(input$mymap_click$lat, input$mymap_click$lng,input$mymap_zoom),"Google Maps")
        ))
        leafletProxy("mymap") %>% clearPopups()
        leafletProxy("mymap") %>% addPopups(input$mymap_click$lng+0.01, input$mymap_click$lat+0.01, content)
    }
  })
  observeEvent(input$mymap_click,{
    if(input$popupAll == TRUE){
      content <- as.character(tagList(
        tags$strong("All Click "),
        tags$a(target="_blank",href=googleLink(input$mymap_click$lat, input$mymap_click$lng,input$mymap_zoom),"Google Maps")
      ))
      leafletProxy("mymap") %>% clearPopups()
      leafletProxy("mymap") %>% addPopups(input$mymap_click$lng, input$mymap_click$lat, content)
    }
  })
  observeEvent(input$mymap_geojson_click, {
    if(input$popupAll == TRUE){
      content <- as.character(tagList(
        tags$strong("All Click "),
        tags$a(target="_blank",href=googleLink(input$mymap_geojson_click$lat, input$mymap_geojson_click$lng,input$mymap_zoom),"Google Maps")
      ))
      leafletProxy("mymap") %>% clearPopups()
      leafletProxy("mymap") %>% addPopups(input$mymap_geojson_click$lng, input$mymap_geojson_click$lat, content)
    }
  })
  observeEvent(input$addGeojson, {
    leafletProxy("mymap") %>%
      addGeoJSON(geojson,layerId ='geojsonlayer',smoothFactor=2)
    updateSelectizeInput(session, 'setstyle', choices = addedData$df$ids, server = TRUE)
    updateSelectizeInput(session, 'removefeature', choices = addedData$df$ids, server = TRUE)
    updateSelectizeInput(session, 'addfeature', choices = NULL, server = TRUE)
  })
  observeEvent(input$setstyle, {
    leafletProxy("mymap") %>%
    styleFeatureGeoJSON(layerId ='geojsonlayer', featureId = input$setstyle, style = '{"fillColor" :"red"}')
  })
  observeEvent(input$removefeature, {
    if(is.null(input$removefeature)==FALSE && input$removefeature != "") {
      leafletProxy("mymap") %>%
      removeFeatureGeoJSON(layerId ='geojsonlayer', featureId = input$removefeature)
      if (length(addedData$df$ids) > 1) {
        addedData$df <- addedData$df[-c(which(addedData$df$ids==input$removefeature)),]
      }
      removedData$df <- rbind(removedData$df,allCountries[which(allCountries$ids==input$removefeature),])
      updateSelectizeInput(session, 'setstyle', choices = addedData$df$ids, server = TRUE, selected=NULL)
      updateSelectizeInput(session, 'removefeature', choices = addedData$df$ids, server = TRUE, selected=NULL)
      updateSelectizeInput(session, 'addfeature', choices = removedData$df$ids, server = TRUE, selected=NULL)
    }
  })
  observeEvent(input$addfeature, {
    if(is.null(input$addfeature)==FALSE && input$addfeature != "") {
      geojson <- geojson$features[[seq_along(geojson$features)[sapply(geojson$features,
              FUN = function(x) x[["id"]] == input$addfeature)]]]
      leafletProxy("mymap") %>%
      addFeatureGeoJSON(geojson, layerId ='geojsonlayer') # can use a list (slow)
      if (length(addedData$df$ids) > 1) {
        removedData$df <- removedData$df[-c(which(removedData$df$ids==input$addfeature)),]
      }
      addedData$df <- rbind(addedData$df,allCountries[which(allCountries$ids==input$addfeature),])
      updateSelectizeInput(session, 'setstyle', choices = addedData$df$ids, server = TRUE, selected=NULL)
      updateSelectizeInput(session, 'removefeature', choices = addedData$df$ids, server = TRUE, selected=NULL)
      updateSelectizeInput(session, 'addfeature', choices = removedData$df$ids, server = TRUE, selected=NULL)
    }
  })
  observeEvent(input$clearGeojson, {
    leafletProxy("mymap") %>% removeGeoJSON(layerId ='geojsonlayer')
  })
  observeEvent(input$addPopup, {
    content <- paste(sep = "<br/>",
                     "<b><a href='http://www.samurainoodle.com'>Samurai Noodle</a></b>",
                     "606 5th Ave. S",
                     "Seattle, WA 98138"
    )
    leafletProxy("mymap") %>%  addPopups(-122.327298, 47.597131, content,
                         options = popupOptions(closeButton = TRUE))
  })
  observeEvent(input$clearPopup, {
    leafletProxy("mymap") %>% clearPopups()
  })
  observeEvent(input$addbasemap, {
    leafletProxy("mymap") %>% addProviderTiles("Acetate.terrain",options = providerTileOptions(noWrap = TRUE,zIndex=0),layerId="basemap")
  })
  observeEvent(input$clearbasemap, {
    leafletProxy("mymap") %>% removeTiles("basemap") %>% removeTiles("wms_protectedArea")
  })
  observeEvent(input$clear, {
    leafletProxy("mymap") %>% clearTiles()
  })
  # need ability to bring to top
  observeEvent(input$mymap_geojson_mouseover, {
        leafletProxy("mymap") %>%
          styleFeatureGeoJSON(layerId ='geojsonlayer', featureId = input$mymap_geojson_mouseover$featureId,
                              style = list(weight=1,color="black")) # or string
  })
  observeEvent(input$mymap_geojson_mouseout, {
        leafletProxy("mymap") %>%
          styleFeatureGeoJSON(layerId ='geojsonlayer', featureId = input$mymap_geojson_mouseout$featureId,
                              style = '{"weight": 1, "color": "#555555"}') # or string
  })
  observeEvent(input$addBermuda, {
    # geoJSON layer must already be added
    # simplified example, not added to addedData
    leafletProxy("mymap") %>%
      addFeatureGeoJSON(as.character(minify(bermudaTriangle)), layerId ='geojsonlayer') # can use a GeoJSON string (as.character)
  })
  observeEvent(input$removeBermuda, {
    leafletProxy("mymap") %>%
      removeFeatureGeoJSON(layerId ='geojsonlayer', featureId = "Bermuda Triangle")
  })
}
shinyApp(ui, server)

