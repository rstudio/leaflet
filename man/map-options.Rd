% Please edit documentation in R/layers.R
\name{tileOptions}
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

popupOptions(maxWidth = 300, minWidth = 50, maxHeight = NULL, autoPan = TRUE, 
    keepInView = FALSE, closeButton = TRUE, zoomAnimation = TRUE, closeOnClick = NULL, 
    className = "")

markerOptions(clickable = TRUE, draggable = FALSE, keyboard = TRUE, title = "", 
    alt = "", zIndexOffset = 0, opacity = 1, riseOnHover = FALSE, riseOffset = 250)

pathOptions(lineCap = NULL, lineJoin = NULL, clickable = TRUE, pointerEvents = NULL, 
    className = "")
}
\arguments{
\item{minZoom, maxZoom, maxNativeZoom, tileSize, subdomains, errorTileUrl, attribution, tms, continuousWorld, noWrap, zoomOffset, zoomReverse, zIndex, unloadInvisibleTiles, updateWhenIdle, detectRetina, reuseTiles}{the tile layer options; see
\url{http://leafletjs.com/reference.html#tilelayer}}

\item{maxWidth, minWidth, maxHeight, autoPan, keepInView, closeButton, zoomAnimation, closeOnClick}{popup options; see \url{http://leafletjs.com/reference.html#popup}}

\item{className}{a CSS class name set on an element}

\item{clickable}{whether the element emits mouse events}

\item{draggable, keyboard, title, alt, zIndexOffset, opacity, riseOnHover, riseOffset}{marker options; see \url{http://leafletjs.com/reference.html#marker}}

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

\item \code{popupOptions}: Options for popups

\item \code{markerOptions}: Options for markers

\item \code{pathOptions}: Options for vector layers (polylines, polygons,
rectangles, and circles, etc)
}}
