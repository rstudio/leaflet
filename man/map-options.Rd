% Please edit documentation in R/layers.R
\name{tileOptions}
\alias{WMSTileOptions}
\alias{markerClusterOptions}
\alias{markerOptions}
\alias{pathOptions}
\alias{popupOptions}
\alias{tileOptions}
\title{Extra options for map elements and layers}
\usage{
tileOptions(minZoom = 0, maxZoom = 18, maxNativeZoom = NULL, tileSize = 256, 
    subdomains = "abc", errorTileUrl = "", tms = FALSE, continuousWorld = FALSE, 
    noWrap = FALSE, zoomOffset = 0, zoomReverse = FALSE, opacity = 1, zIndex = NULL, 
    unloadInvisibleTiles = NULL, updateWhenIdle = NULL, detectRetina = FALSE, 
    reuseTiles = FALSE)

WMSTileOptions(styles = "", format = "image/jpeg", transparent = FALSE, 
    version = "1.1.1", crs = NULL, ...)

popupOptions(maxWidth = 300, minWidth = 50, maxHeight = NULL, autoPan = TRUE, 
    keepInView = FALSE, closeButton = TRUE, zoomAnimation = TRUE, closeOnClick = NULL, 
    className = "")

markerOptions(clickable = TRUE, draggable = FALSE, keyboard = TRUE, title = "", 
    alt = "", zIndexOffset = 0, opacity = 1, riseOnHover = FALSE, riseOffset = 250)

markerClusterOptions(showCoverageOnHover = TRUE, zoomToBoundsOnClick = TRUE, 
    spiderfyOnMaxZoom = TRUE, removeOutsideVisibleBounds = TRUE, ...)

pathOptions(lineCap = NULL, lineJoin = NULL, clickable = TRUE, pointerEvents = NULL, 
    className = "")
}
\arguments{
\item{minZoom, maxZoom, maxNativeZoom, tileSize, subdomains, errorTileUrl, tms, continuousWorld, noWrap, zoomOffset, zoomReverse, zIndex, unloadInvisibleTiles, updateWhenIdle, detectRetina, reuseTiles}{the tile layer options; see
\url{http://leafletjs.com/reference.html#tilelayer}}

\item{styles}{comma-separated list of WMS styles}

\item{format}{WMS image format (use \code{'image/png'} for layers with
transparency)}

\item{transparent}{if \code{TRUE}, the WMS service will return images with
transparency}

\item{version}{version of the WMS service to use}

\item{crs}{Coordinate Reference System to use for the WMS requests, defaults
to map CRS (don't change this if you're not sure what it means)}

\item{...}{other tile options for \code{WMSTileOptions()} (all arguments of
\code{tileOptions()} can be used)}

\item{maxWidth, minWidth, maxHeight, autoPan, keepInView, closeButton, zoomAnimation, closeOnClick}{popup options; see \url{http://leafletjs.com/reference.html#popup}}

\item{className}{a CSS class name set on an element}

\item{clickable}{whether the element emits mouse events}

\item{draggable, keyboard, title, alt, zIndexOffset, opacity, riseOnHover, riseOffset}{marker options; see \url{http://leafletjs.com/reference.html#marker}}

\item{showCoverageOnHover}{when you mouse over a cluster it shows the bounds
of its markers}

\item{zoomToBoundsOnClick}{when you click a cluster we zoom to its bounds}

\item{spiderfyOnMaxZoom}{when you click a cluster at the bottom zoom level we
spiderfy it so you can see all of its markers}

\item{removeOutsideVisibleBounds}{clusters and markers too far from the
viewport are removed from the map for performance}

\item{lineCap}{a string that defines
\href{https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-linecap}{shape
 to be used at the end} of the stroke}

\item{lineJoin}{a string that defines
\href{https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-linejoin}{shape
 to be used at the corners} of the stroke}

\item{pointerEvents}{sets the \code{pointer-events} attribute on the path if
SVG backend is used}
}
\description{
The rest of all possible options for map elements and layers that are not
listed in the layer functions.
}
\section{Functions}{
\itemize{
\item \code{tileOptions}: Options for tile layers

\item \code{WMSTileOptions}: Options for WMS tile layers

\item \code{popupOptions}: Options for popups

\item \code{markerOptions}: Options for markers

\item \code{markerClusterOptions}: Options for marker clusters

\item \code{pathOptions}: Options for vector layers (polylines, polygons,
rectangles, and circles, etc)
}}
