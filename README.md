# Leaflet bindings for Shiny

[Leaflet](http://leafletjs.com) is an open-source JavaScript library for interactive maps.

[Shiny](http://rstudio.com/shiny) is an open-source R framework for interactive webapps.

This R package makes it easy to integrate and control Leaflet maps from Shiny applications. [Here's an example application](http://glimmer.rstudio.com/jcheng/leaflet-demo) (see inst/examples/population for the source).

## Documentation

### Functions

Use the following two functions from your Shiny app to create Leaflet maps.

----

##### leafletMap(outputId, width, height, initialTileLayer = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', initialTileLayerAttribution = HTML('&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'), options=NULL)

The `leafletMap` function is called from `ui.R` (or from `renderUI`); it
creates a `<div>` that will contain a Leaflet map. The `width` and `height`
parameters can either take a CSS length (e.g. `"400px"` or `"50%"`) or a numeric
value which will be interpreted as pixels. The `options` parameter is a list of
[map options](http://leafletjs.com/reference.html#map-options).

See [TileLayer](http://leafletjs.com/reference.html#tilelayer) for information
about providing tile layer URLs.

----

##### createLeafletMap(session, outputId)

The `createLeafletMap` function is called from `server.R` and returns an object
that can be used to manipulate the Leaflet map from R (see Methods, below).
The `session` argument should be passed through from the `shinyServer` server
function. `outputId` is the string identifier that was passed to the
corresponding `leafletMap`.

----

### Methods

The following are methods that can be called on the map object that is created
using `createLeafletMap()`. For example:

```r
map <- createLeafletMap(session, "myMap")
map$setView(0, 0, 8)
```

All of the methods that add something to the map take a `layerId` parameter.
This `layerId` is optional but useful for several purposes:

* Calling the same add function with the same `layerId` value will replace the
  old layer instead of just adding a new one
* You can call `removePopup`, `removeMarker`, or `removeShape` with a `layerId`
  to remove the old layer
* You will need a `layerId` to subscribe to events. See Events section below.

----

##### setView(lat, lng, zoom, forceReset = FALSE)

Sets the center and zoom level of the map. `forceReset` will completely reset
the map view, without animations.

----

##### fitBounds(lat1, lng1, lat2, lng2)

Modifies the center and zoom level of the map such that the specified bounds are
visible.

----

##### addMarker(lat, lng, layerId=NULL, options=list(), eachOptions=list())

Adds markers at the designated points. The number of markers added will be the
maximum length of `lat`, `lng`, and `layerId` (if provided); if the lengths of
these arguments are not equal, the shorter arguments will be recycled.

`options` is a list of
[marker options](http://leafletjs.com/reference.html#marker-options) that will
be applied to all of the markers; `eachOptions` is the same except that each
option value can be a vector, where each element corresponds to a single marker
(recycling will be used if necessary).

Events: `input$MAPID_LAYERID_marker_click`,
`input$MAPID_LAYERID_marker_mouseover`, `input$MAPID_LAYERID_marker_mouseout`

----

##### addCircleMarker(lat, lng, radius, layerId = NULL, options = list(), eachOptions=list())

Adds circle markers. Circle markers are like circles, but their pixel radius
remains constant as the user zooms in and out.

The number of circle markers added will be the maximum length of `lat`, `lng`,
`radius`, and `layerId`; if the lengths of these arguments are
not equal, the shorter arguments will be recycled.

The `radius` argument is specified in pixels.

`options` is a list of
[path options](http://leafletjs.com/reference.html#path-options) that will
be applied to all of the markers; `eachOptions` is the same except that each
option value can be a vector, where each element corresponds to a single marker
(recycling will be used if necessary).

Events: `input$MAPID_LAYERID_marker_click`,
`input$MAPID_LAYERID_marker_mouseover`, `input$MAPID_LAYERID_marker_mouseout`

----

##### addCircle(lat, lng, radius, layerId = NULL, options=list(), eachOptions=list())

Adds circle overlays to the map.

The number of circle overlays added will be the maximum length of `lat`, `lng`,
`radius`, and `layerId`; if the lengths of these arguments are
not equal, the shorter arguments will be recycled.

The `radius` argument is specified in meters.

`options` is a list of
[path options](http://leafletjs.com/reference.html#path-options) that will
be applied to all of the circles; `eachOptions` is the same except that each
option value can be a vector, where each element corresponds to a single circle
(recycling will be used if necessary).

Events: `input$MAPID_LAYERID_shape_click`,
`input$MAPID_LAYERID_shape_mouseover`, `input$MAPID_LAYERID_shape_mouseout`

----

##### addRectangle(lat1, lng1, lat2, lng2, layerId = NULL, options=list(), eachOptions=list())

Adds rectangular overlays to the map.

The number of rectangles added will be the maximum length of `lat1`, `lng1`,
`lat2`, `lng2`, and `layerId`; if the lengths of these arguments
are not equal, the shorter arguments will be recycled.

`options` is a list of
[path options](http://leafletjs.com/reference.html#path-options) that will
be applied to all of the rectangles; `eachOptions` is the same except that each
option value can be a vector, where each element corresponds to a single
rectangle (recycling will be used if necessary).

Events: `input$MAPID_LAYERID_shape_click`,
`input$MAPID_LAYERID_shape_mouseover`, `input$MAPID_LAYERID_shape_mouseout`

----

##### addPolygon(lat, lng, layerId, options, defaultOptions)

Adds polygon overlays to the map. `lat` and `lng` encode successive points of
each polygon; the end of a polygon is specified with (`NA`, `NA`). (This is the
path representation scheme used by the `maps` package.)

The length of `layerId` should equal the number of polygons represented in
`lat`/`lng`.

`options` and `defaultOptions` serve the same purpose as `options`/`eachOptions`
in `addCircle` and `addPolygon`, but are not consistent for historical reasons.
This ought to be fixed in a future, compatibility-breaking release.
`defaultOptions` is a list of
[path options](http://leafletjs.com/reference.html#path-options) that will
be applied to all of the polygons. `options` is a list of lists of path options
that will be applied to the corresponding polygon.

----

##### addGeoJSON(data, layerId)

Adds GeoJSON to the map. `data` can be either a GeoJSON string (must be a
**single-element** character vector) or structured GeoJSON data (in the form of
nested lists). The `layerId` is a single-element character vector that refers to
the GeoJSON data in its entirety.

Each GeoJSON feature can include a `style` member, either directly on the
feature object or in the feature object's `properties` member. See [path
options](http://leafletjs.com/reference.html#path-options) to see what style
options are available.

If a GeoJSON feature has an `id` member, that value will be passed back during
events as a `featureId` field on the event object.

Events: `input$MAPID_LAYERID_geojson_click`,
`input$MAPID_LAYERID_geojson_mouseover`, `input$MAPID_LAYERID_geojson_mouseout`

----

##### clearMarkers()

Clears all markers currently on the map.

----

##### clearShapes()

Clears all shapes currently on the map.

----

##### showPopup(lat, lng, content, layerId = NULL, options=list())

Show a popup at the specified location, with the given content. The content
string will be interpreted as HTML.

`options` is a list of
[popup options](http://leafletjs.com/reference.html#popup-options).

----

##### removePopup(layerId)

Remove the specified popup.

----

##### clearPopups()

Remove all popups.

----

### Events

TODO

----

### Sources

Population data is from US Census Bureau:
http://www.census.gov/popest/data/intercensal/cities/cities2010.html
http://www.census.gov/popest/data/intercensal/cities/files/SUB-EST00INT.csv~/lea

Location data is from USGS:
http://geonames.usgs.gov/domestic/download_data.htm
http://geonames.usgs.gov/docs/stategaz/NationalFile_20130602.zip

### License

This package is licensed to you under the terms of the [GNU General Public License](http://www.gnu.org/licenses/gpl.html) version 3 or later.

Copyright 2013 RStudio, Inc.
