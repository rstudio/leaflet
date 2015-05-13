% Please edit documentation in R/controls.R, R/layers.R
\name{removeControl}
\alias{clearControls}
\alias{clearGeoJSON}
\alias{clearMarkers}
\alias{clearPopups}
\alias{clearShapes}
\alias{clearTiles}
\alias{remove}
\alias{removeControl}
\alias{removeGeoJSON}
\alias{removeMarker}
\alias{removePopup}
\alias{removeShape}
\alias{removeTiles}
\title{Remove elements from a map}
\usage{
removeControl(map, layerId)

clearControls(map)

removeTiles(map, layerId)

clearTiles(map)

removePopup(map, layerId)

clearPopups(map)

removeMarker(map, layerId)

clearMarkers(map)

removeShape(map, layerId)

clearShapes(map)

removeGeoJSON(map, layerId)

clearGeoJSON(map)
}
\arguments{
\item{map}{a map widget object, possibly created from \code{\link{leaflet}}()
but more likely from \code{\link{leafletProxy}}()}

\item{layerId}{character vector; the layer id(s) of the item to remove}
}
\value{
the new \code{map} object
}
\description{
Remove one or more features from a map, identified by \code{layerId}; or,
clear all features of the given type.
}
\note{
When used with a \code{\link{leaflet}}() map object, these functions
  don't actually remove the features from the map object, but simply add an
  operation that will cause those features to be removed after they are
  added. In other words, if you add a polygon \code{"foo"} and the call
  \code{removeShape("foo")}, it's not smart enough to prevent the polygon
  from being added in the first place; instead, when the map is rendered, the
  polygon will be added and then removed.

  For that reason, these functions aren't that useful with \code{leaflet} map
  objects and are really intended to be used with \code{\link{leafletProxy}}
  instead.

  WMS tile layers are extensions of tile layers, so they can also be removed
  or cleared via \code{removeTiles()} or \code{clearTiles()}.
}
