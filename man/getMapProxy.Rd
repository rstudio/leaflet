% Please edit documentation in R/utils.R
\name{getMapProxy}
\alias{getMapProxy}
\title{Send commands to a Leaflet instance in a Shiny app}
\usage{
getMapProxy(mapId, session = shiny::getDefaultReactiveDomain(), data = NULL)
}
\description{
Creates a map-like object that can be used to customize and control a map
that has already been rendered. For use in Shiny apps and Shiny docs only.
}
\details{
Normally, you create a Leaflet map using the \code{\link{leaflet}} function.
This creates an in-memory representation of a map that you can customize
using functions like \code{\link{addPolygons}} and \code{\link{setView}}.
Such a map can be printed at the R console, included in an R Markdown
document, or rendered as a Shiny output.

In the case of Shiny, you may want to further customize a map, even after it
is rendered to an output. At this point, the in-memory representation of the
map is long gone, and the user's web browser has already realized the Leaflet
map instance.

This is where \code{getMapProxy} comes in. It returns an object that can
stand in for the usual Leaflet map object. The usual map functions like
\code{\link{addPolygons}} and \code{\link{setView}} can be called, and
instead of customizing an in-memory representation, these commands will
execute on the live Leaflet map instance.
}
\examples{
\donttest{
library(shiny)

ui <- fluidPage(leafletOutput("map1"))

server <- function(input, output, session) {
    output$map1 <- renderLeaflet({
        leaflet() \%>\% addCircleMarkers(lng = runif(10), lat = runif(10), 
            layerId = paste0("marker", 1:10))
    })
    
    observeEvent(input$map1_marker_click, {
        getMapProxy("map1", session) \%>\% removeMarker(input$map1_marker_click$id)
    })
}

shinyApp(ui, server)

}
}
