% Please edit documentation in R/layers.R
\name{addRaster}
\alias{addRaster}
\title{Raster layers (experimental)}
\usage{
addRaster(map, x, layerId = paste0("leafletRaster", sample.int(9999999, 1)), 
    attribution = NULL, colorFunc = colorNumeric("RdBu", domain = c(minValue(x), 
        maxValue(x))), options = tileOptions())
}
\arguments{
\item{map}{a map widget object created from \code{\link{leaflet}()}}

\item{attribution}{the attribution text of the tile layer (HTML)}

\item{colorFunc}{The function to use to map values to colors.}

\item{options}{a list of extra options; see \code{\link{tileOptions}}}
}
\description{
Add a raster object (from the \code{raster} package) as a tile layer. The
raster object must be in WGS84. Note that this function currently ONLY works
in Shiny contexts, as it generates mapping tiles from the raster on-demand.
}
