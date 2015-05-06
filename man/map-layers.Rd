% Please edit documentation in R/controls.R, R/layers.R
\name{addControl}
\alias{addCircleMarkers}
\alias{addCircles}
\alias{addControl}
\alias{addGeoJSON}
\alias{addMarkers}
\alias{addPolygons}
\alias{addPolylines}
\alias{addPopups}
\alias{addRectangles}
\alias{addTiles}
\alias{addWMSTiles}
\title{Graphics elements and layers}
\usage{
addControl(map, html, position = c("topleft", "topright", "bottomleft", 
    "bottomright"), layerId = NULL, classes = c("info", "legend"), 
    data = getMapData(map))

addTiles(map, urlTemplate = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", 
    attribution = NULL, layerId = NULL, options = tileOptions())

addWMSTiles(map, baseUrl, layerId = NULL, options = tileOptions(), attribution = NULL, 
    layers = "", styles = "", format = "image/jpeg", transparent = FALSE, 
    version = "1.1.1", crs = NULL)

addPopups(map, lng = NULL, lat = NULL, popup, layerId = NULL, options = popupOptions(), 
    data = getMapData(map))

addMarkers(map, lng = NULL, lat = NULL, layerId = NULL, icon = NULL, 
    popup = NULL, options = markerOptions(), data = getMapData(map))

addCircleMarkers(map, lng = NULL, lat = NULL, radius = 10, layerId = NULL, 
    stroke = TRUE, color = "#03F", weight = 5, opacity = 0.5, fill = TRUE, 
    fillColor = color, fillOpacity = 0.2, dashArray = NULL, popup = NULL, 
    options = pathOptions(), data = getMapData(map))

addCircles(map, lng = NULL, lat = NULL, radius = 10, layerId = NULL, 
    stroke = TRUE, color = "#03F", weight = 5, opacity = 0.5, fill = TRUE, 
    fillColor = color, fillOpacity = 0.2, dashArray = NULL, popup = NULL, 
    options = pathOptions(), data = getMapData(map))

addPolylines(map, lng = NULL, lat = NULL, layerId = NULL, stroke = TRUE, 
    color = "#03F", weight = 5, opacity = 0.5, fill = FALSE, fillColor = color, 
    fillOpacity = 0.2, dashArray = NULL, smoothFactor = 1, noClip = FALSE, 
    popup = NULL, options = pathOptions(), data = getMapData(map))

addRectangles(map, lng1, lat1, lng2, lat2, layerId = NULL, stroke = TRUE, 
    color = "#03F", weight = 5, opacity = 0.5, fill = TRUE, fillColor = color, 
    fillOpacity = 0.2, dashArray = NULL, smoothFactor = 1, noClip = FALSE, 
    popup = NULL, options = pathOptions(), data = getMapData(map))

addPolygons(map, lng = NULL, lat = NULL, layerId = NULL, stroke = TRUE, 
    color = "#03F", weight = 5, opacity = 0.5, fill = TRUE, fillColor = color, 
    fillOpacity = 0.2, dashArray = NULL, smoothFactor = 1, noClip = FALSE, 
    popup = NULL, options = pathOptions(), data = getMapData(map))

addGeoJSON(map, geojson, layerId = NULL)
}
\arguments{
\item{map}{a map widget object created from \code{\link{leaflet}()}}

\item{html}{the content of the control. May be provided as string or as HTML
generated with Shiny/htmltools tags}

\item{position}{position of control: 'topleft', 'topright', 'bottomleft', or
'bottomright'}

\item{layerId}{the layer id}

\item{classes}{extra CSS classes to append to the control}

\item{data}{the data object from which the argument values are derived; by
default, it is the \code{data} object provided to \code{leaflet()}
initially, but can be overridden}

\item{urlTemplate}{a character string as the URL template}

\item{attribution}{the attribution text of the tile layer (HTML)}

\item{options}{a list of extra options for tile layers, popups, paths
(circles, rectangles, polygons, ...), or other map elements}

\item{baseUrl}{a base URL of the WMS service}

\item{layers}{comma-separated list of WMS layers to show}

\item{styles}{comma-separated list of WMS styles}

\item{format}{WMS image format (use \code{'image/png'} for layers with
transparency)}

\item{transparent}{if \code{TRUE}, the WMS service will return images with
transparency}

\item{version}{version of the WMS service to use}

\item{crs}{Coordinate Reference System to use for the WMS requests, defaults
to map CRS (don't change this if you're not sure what it means)}

\item{lng}{a numeric vector of longitudes, or a one-sided formula of the form
\code{~x} where \code{x} is a variable in \code{data}; by default (if not
explicitly provided), it will be automatically inferred from \code{data} by
looking for a column named \code{lng}, \code{long}, or \code{longitude}
(case-insensitively)}

\item{lat}{a vector of latitudes or a formula (similar to the \code{lng}
argument; the names \code{lat} and \code{latitude} are used when guessing
the latitude column from \code{data})}

\item{popup}{a character vector of the HTML content for the popups (you are
recommended to escape the text using \code{\link[htmltools]{htmlEscape}()}
for security reasons)}

\item{icon}{the icon(s) for markers; an icon is represented by an R list of
the form \code{list(iconUrl = '?', iconSize = c(x, y))}, and you can use
\code{\link{icons}()} to create multiple icons; note when you use an R
list that contains images as local files, these local image files will be
base64 encoded into the HTML page so the icon images will still be
available even when you publish the map elsewhere}

\item{radius}{a numeric vector of radii for the circles; it can also be a
one-sided formula, in which case the radius values are derived from the
\code{data} (units in meters for circles, and pixels for circle markers)}

\item{stroke}{whether to draw stroke along the path (e.g. the borders of
polygons or circles)}

\item{color}{stroke color}

\item{weight}{stroke width in pixels}

\item{opacity}{stroke opacity (or layer opacity for tile layers)}

\item{fill}{whether to fill the path with color (e.g. filling on polygons or
circles)}

\item{fillColor}{fill color}

\item{fillOpacity}{fill opacity}

\item{dashArray}{a string that defines the stroke
\href{https://developer.mozilla.org/en/SVG/Attribute/stroke-dasharray}{dash
pattern}}

\item{smoothFactor}{how much to simplify the polyline on each zoom level
(more means better performance and less accurate representation)}

\item{noClip}{whether to disable polyline clipping}

\item{lng1, lat1, lng2, lat2}{latitudes and longitudes of the south-west and
north-east corners of rectangles}

\item{geojson}{a GeoJSON list}
}
\value{
the new \code{map} object
}
\description{
Add graphics elements and layers to the map widget.
}
\section{Functions}{
\itemize{
\item \code{addControl}: Add arbitrary HTML controls to the map

\item \code{addTiles}: Add a tile layer to the map

\item \code{addWMSTiles}: Add a WMS tile layer to the map

\item \code{addPopups}: Add popups to the map

\item \code{addMarkers}: Add markders to the map

\item \code{addCircleMarkers}: Add circle markers to the map

\item \code{addCircles}: Add circles to the map

\item \code{addPolylines}: Add polylines to the map

\item \code{addRectangles}: Add rectangles to the map

\item \code{addPolygons}: Add polygons to the map

\item \code{addGeoJSON}: Add GeoJSON layers to the map
}}
\references{
The Leaflet API documentation:
  \url{http://leafletjs.com/reference.html}
}
\seealso{
\code{\link{tileOptions}}, \code{\link{popupOptions}},
  \code{\link{markerOptions}}, \code{\link{pathOptions}}
}
