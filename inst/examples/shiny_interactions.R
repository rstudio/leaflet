library(shiny)
library(leaflet)
library(rgdal)
library(jsonlite)
r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()
googleLink <- function(lat,lng,zoom) {
  sprintf("http://www.google.com/maps/place/%s,%s/@%s,%s,%sz/data=!3m1!1e3",
          lat, lng, lat, lng, zoom)
}
geojson <- paste(readLines(system.file("examples/countries.json", package = "leaflet")), collapse = "\n") %>%
  fromJSON(simplifyVector = FALSE)
geojson$style = list(
  weight = 1,
  color = "#555555",
  opacity = 1,
  fillOpacity = 0.8
)
gdp_md_est <- sapply(geojson$features, function(feat) {
  feat$properties$gdp_md_est
})
pop_est <- sapply(geojson$features, function(feat) {
  max(1, feat$properties$pop_est)
})
pal <- colorQuantile("Greens", gdp_md_est / pop_est)
geojson$features <- lapply(geojson$features, function(feat) {
  feat$id <- feat$properties$admin
  feat$properties$style <- list(
    fillColor = pal(
      feat$properties$gdp_md_est / max(1, feat$properties$pop_est)),
    weight = 1,
    color = "#55555"
  )
  feat
})
ids <- sapply(geojson$features,function(x) x$id)
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
            checkboxInput('popupAll', 'popupAll', value = FALSE),
            selectInput('setstyle', label = "Color a Country Blue!", choices = ids,selected = NULL),
            selectInput('removefeature', label = "Remove a Country!", choices = ids,selected = NULL),
            selectInput('addfeature', label = "Add back a Country!", choices = ids,selected = NULL)
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
          tags$strong(paste0("ID: ",input$mymap_geojson_click$properties$admin)),
          tags$a(target="_blank",href=googleLink(input$mymap_geojson_click$lat, input$mymap_geojson_click$lng,input$mymap_zoom),"Google Maps")
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
          tags$strong(paste0("Map Click: ",input$mymapn_click$id)),
          tags$a(target="_blank",href=googleLink(input$mymap_click$lat, input$mymap_click$lng,input$mymap_zoom),"Google Maps")
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
            tags$a(target="_blank",href=googleLink(input$mymap_click$lat, input$mymap_click$lng,input$mymap_zoom),"Google Maps")
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
            tags$a(target="_blank",href=googleLink(input$mymap_geojson_click$lat, input$mymap_geojson_click$lng,input$mymap_zoom),"Google Maps")
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
  observeEvent(input$setstyle, {
    leafletProxy("mymap") %>%
    setStyleGeoJSON(layerId ='geojsonlayer', featureId = input$setstyle, style = '{"fillColor" :"blue"}')
  })
  observeEvent(input$removefeature, {
    leafletProxy("mymap") %>%
      removeFeatureGeoJSON(layerId ='geojsonlayer', featureId = input$removefeature)
  })
  observeEvent(input$addfeature, {
    data <- geojson$features[[seq_along(geojson$features)[sapply(geojson$features,
              FUN = function(x) x[["id"]] == input$addfeature)]]]
    leafletProxy("mymap") %>%
      addFeatureGeoJSON(data, layerId ='geojsonlayer')
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
}
shinyApp(ui, server)

