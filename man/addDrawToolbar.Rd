% Please edit documentation in R/plugin-draw.R
\name{addDrawToolbar}
\alias{addDrawToolbar}
\alias{removeDrawToolbar}
\title{Add/remove drawing toolbar}
\usage{
addDrawToolbar(map, layerID = "drawnItems", position = c("topleft", "topright", 
    "bottomleft", "bottomright"), polyline = TRUE, polygon = TRUE, rectangle = TRUE, 
    circle = TRUE, marker = TRUE, edit = TRUE)

removeDrawToolbar(map)
}
\arguments{
\item{map}{the map to add/remove the toolbar to/from}
}
\value{
modified map object
}
\description{
Leaflet.draw plugin:
https://github.com/Leaflet/Leaflet.draw
}
\section{Functions}{
\itemize{
\item \code{removeDrawToolbar}: 
}}
\examples{
map <- addTiles(leaflet())
map <- addDrawToolbar(map)
map
}
