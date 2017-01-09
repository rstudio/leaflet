# devtools::install_github("rstudio/leaflet")

library(leaflet)
library(leaflet.extras)
library(lawn)
library(geojsonio)
library(sf)
library(htmlwidgets)

pts <- gr_point(n=10, c(-93.64, 42.0185 , -93.66, 42.0385))

#convert to simple features
pts_sf <- st_as_sf(geojson_sp(
  geojson_list(lawn:::convert(pts))
))

#make a leaflet to experiment
lf <- pts_sf %>%
  leaflet() %>%
  addCircles() %>%
  addDrawToolbar(editOptions=editToolbarOptions()) %>%
  addTiles()

library(shiny)
#options(shiny.trace=TRUE)
ui <- lf
server <- function(input, output, session) {
  observeEvent(input$undefined_draw_new_feature,{
    print(input$undefined_draw_new_feature)
    edit_shape <<- input$undefined_draw_new_feature
  })
}
shinyApp(ui, server)


# we should have saved edit_shape in GlobalEnv
#  if anything was drawn with Leaflet.Draw
#  let's assume it was a polygon

shape_sf <- st_polygon(
  list(
    matrix(unlist(edit_shape$geometry$coordinates[[1]]),ncol=2,byrow=TRUE)
  )
)
shape_sfc <- st_sfc(shape_sf,crs=st_crs(pts_sf))
st_intersection(pts_sf, shape_sfc)
# map to see result (sort of invert)
leaflet() %>%
  addCircles(data=st_intersection(pts_sf, shape_sfc)) %>%
  addCircles(data=st_difference(pts_sf, shape_sfc), color = "red") %>%
  addPolygons(data=shape_sfc) %>%
  addTiles()
