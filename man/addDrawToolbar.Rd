% Please edit documentation in R/plugin-draw.R
\name{addDrawToolbar}
\alias{addDrawToolbar}
\alias{removeDrawToolbar}
\title{Add/remove drawing toolbar}
\usage{
addDrawToolbar(map, layerID = "drawnItems", position = c("topleft", "topright", 
    "bottomleft", "bottomright"), polyline = TRUE, polygon = TRUE, rectangle = TRUE, 
    circle = TRUE, marker = TRUE, edit = TRUE, remove = TRUE)

removeDrawToolbar(map)
}
\arguments{
\item{map}{the map to add/remove the toolbar to/from}

\item{layerID}{string, the layerID of the layer where drawn object will be
added}

\item{position}{string, the position of the toolbar}

\item{polyline}{logical}

\item{polygon}{logical}

\item{rectangle}{logical}

\item{circle}{logical}

\item{marker}{logical}

\item{edit}{logical}

\item{remove}{logical}
}
\value{
Modified map object.
        If used in a shiny app it will return input on every object created,
        edited or deleted.
        The input name will be \code{layerID_action} where
        \code{layerID} is
        the string passed to the function \code{addDrawToolbar},
        \code{action} is one of \code{create, delete, edit}.
        The input will contain a list with the GeoJSON representation of the
        created, edited or deleted item. In particular the input will be a
        list, the third component of that is a list with components
        \code{type} and \code{coordinates}, so for example to get the
        coordinates of a newly created item just use:
        \code{input$drawnItems_create[[3]]$coordinates}.
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
