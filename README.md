# Leaflet bindings for Shiny

[Leaflet](http://leafletjs.com) is an open-source JavaScript library for
interactive maps. [Shiny](http://rstudio.com/shiny) is an open-source R
framework for interactive web apps.

This R package makes it easy to integrate and control Leaflet maps from Shiny
applications. [Here's an example
application](http://glimmer.rstudio.com/jcheng/leaflet-demo) (see
inst/examples/population for the source).

You can use the two functions `leafletMap()` and `createLeafletMap()` from your
Shiny app to create Leaflet maps.

```r
library(leaflet)

# in ui.R
leafletMap(
  outputId, width, height,
  initialTileLayer = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  initialTileLayerAttribution = HTML(
    '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,
    <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
  ),
  options = NULL
)

# in server.R
createLeafletMap(session, outputId)
```

The map object created using `createLeafletMap()` has a number of methods to
manipulate the object, which can be called using the syntax `obj$method()`, e.g.

```r
map <- createLeafletMap(session, "myMap")
map$setView(0, 0, 8)
```

You may install the package and see the package vignette for more details.

```r
devtools::install_github('jcheng5/leaflet-shiny', build_vignettes = TRUE)
vignette('intro', 'leaflet')
```

## License

This package is licensed to you under the terms of the [GNU General Public
License](http://www.gnu.org/licenses/gpl.html) version 3 or later.

Copyright 2013-2014 RStudio, Inc.
