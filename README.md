# An R Interface to Leaflet Maps

[![Build Status](https://travis-ci.org/rstudio/leaflet.svg)](https://travis-ci.org/rstudio/leaflet)

[Leaflet](http://leafletjs.com) is an open-source JavaScript library for
interactive maps. This R package makes it easy to create Leaflet maps from R.

```r
library(leaflet)
m = leaflet() %>% addTiles()
m  # a map with the default OSM tile layer

m = m %>% setView(-93.65, 42.0285, zoom = 17)
m

m %>% addPopups(-93.65, 42.0285, 'Here is the <b>Department of Statistics</b>, ISU')
```

## Installation

This package is not on CRAN yet, but you can install it from Github:

```r
if (!require('devtools')) install.packages('devtools')
devtools::install_github('rstudio/leaflet')
```

## Documentation

In addition to the usual R package documentation, we also have extensive docs and examples at:
http://rstudio.github.io/leaflet

## License

This package is licensed to you under the terms of the [GNU General Public
License](http://www.gnu.org/licenses/gpl.html) version 3 or later.

Copyright 2013-2015 RStudio, Inc.
