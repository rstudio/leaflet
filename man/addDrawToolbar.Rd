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

\item{layerID}{string, the layerID of the layer where drawn object will be
added}

\item{position}{string, the position of the toolbar}

\item{polyline}{logical}

\item{polygon}{logical}

\item{rectangle}{logical}

\item{circle}{logical}

\item{marker}{logical}

\item{edit}{logical}
}
\value{
Modified map object.
        If used in a shiny app it will return input on every object created,
        the input name and type will be \code{layerID_type} where
        \code{layerID} is
        the string passed to the function \code{addDrawToolbar} and
        \code{type} is one of the following string: \code{"polyline"},
        \code{"polygon"}, \code{"rectangle"}, \code{"circle"},
        \code{"marker"}.
        The input will contain Lat and Lngs of the point of the object,
        except for \code{type=circle} when it will contains the center and
        the radious.
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
