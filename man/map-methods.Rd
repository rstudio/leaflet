% Please edit documentation in R/methods.R
\name{setView}
\alias{clearBounds}
\alias{fitBounds}
\alias{setMaxBounds}
\alias{setView}
\title{Methods to manipulate the map widget}
\usage{
setView(map, lng, lat, zoom, options = list())

fitBounds(map, lng1, lat1, lng2, lat2)

setMaxBounds(map, lng1, lat1, lng2, lat2)

clearBounds(map)
}
\arguments{
\item{map}{a map widget object created from \code{\link{leaflet}()}}

\item{lng}{The longitude of the map center}

\item{lat}{The latitude of the map center}

\item{zoom}{the zoom level}

\item{options}{a list of zoom/pan options (see
\url{http://leafletjs.com/reference.html#map-zoompanoptions})}

\item{lng1, lat1, lng2, lat2}{the coordinates of the map bounds}
}
\value{
The modified map widget.
}
\description{
A series of methods to manipulate the map.
}
\section{Functions}{
\itemize{
\item \code{setView}: Set the view of the map (center and zoom level)

\item \code{fitBounds}: Set the bounds of a map

\item \code{setMaxBounds}: Restricts the map view to the given bounds

\item \code{clearBounds}: Clear the bounds of a map, and the bounds will be
automatically determined from latitudes and longitudes of the map elements
if available (otherwise the full world view is used)
}}
\examples{
library(leaflet)
m = leaflet() \%>\% addTiles() \%>\% setView(-71.0382679, 42.3489054, zoom = 18)
m  # the RStudio 'headquarter'
m \%>\% fitBounds(-72, 40, -70, 43)
m \%>\% clearBounds()  # world view
}
\references{
\url{http://leafletjs.com/reference.html#map-set-methods}
}
