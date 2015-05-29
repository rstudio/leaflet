% Please edit documentation in R/layers.R
\name{addRasterImage}
\alias{addRasterImage}
\title{Add a raster image as a layer}
\usage{
addRasterImage(map, x, colors = "Spectral", opacity = 1, attribution = NULL, 
    layerId = NULL, project = TRUE, maxBytes = 2 * 1024 * 1024)
}
\arguments{
\item{map}{a map widget object}

\item{x}{a \code{RasterLayer} object--see \code{\link[raster]{raster}}}

\item{colors}{the color palette (see \code{\link{colorNumeric}}) or function
to use to color the raster values (hint: if providing a function, set
\code{na.color} to \code{"#00000000"} to make \code{NA} areas transparent)}

\item{opacity}{the base opacity of the raster, expressed from 0 to 1}

\item{attribution}{the HTML string to show as the attribution for this layer}

\item{layerId}{the layer id}

\item{project}{if \code{TRUE}, automatically project \code{x} to the map
projection expected by Leaflet (\code{epsg:3785}); if \code{FALSE}, it's
the caller's responsibility to ensure that \code{x} is already projected,
and that \code{extent(x)} is expressed in WGS84 latitude/longitude
coordinates}

\item{maxBytes}{the maximum number of bytes to allow for the projected image
  (before base64 encoding); defaults to 2MB.}
}
\description{
Create an image overlay from a \code{RasterLayer} object. This is only
suitable for small to medium sized rasters, as the entire image will be
embedded into the HTML page (or passed over the websocket in a Shiny
context).
}
\examples{
library(raster)

r <- raster(xmn = -2.8, xmx = -2.79, ymn = 54.04, ymx = 54.05, nrows = 30, ncols = 30)
values(r) <- matrix(1:900, nrow(r), ncol(r), byrow = TRUE)
crs(r) <- CRS("+init=epsg:4326")

leaflet() \%>\% addTiles() \%>\% addRasterImage(r, colors = "Spectral", opacity = 0.8)
}
