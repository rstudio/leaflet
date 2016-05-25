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

You can install this package from CRAN, or the development version from Github:

```r
# CRAN version
install.packages('leaflet')

# Or Github version
if (!require('devtools')) install.packages('devtools')
devtools::install_github('rstudio/leaflet')
```

## Documentation

In addition to the usual R package documentation, we also have extensive docs and examples at:
http://rstudio.github.io/leaflet You may use [Github issues](https://github.com/rstudio/leaflet/issues) to file bug reports or feature requests, and ask questions on [StackOverflow](http://stackoverflow.com/questions/tagged/r+leaflet) or in the [Shiny mailing list](https://groups.google.com/forum/#!forum/shiny-discuss).

## Development

To make additions or modifications to the JavaScript htmlwidgets binding layer,
you must use Grunt to build and test. Please make sure Node.js is installed on
your system, then run:

```
npm install -g grunt-cli
npm install
```

Now you can build/minify/lint/test using `grunt build`, or run in "watch" mode
by just running `grunt`. JS sources go into `javascript/src` and tests go into
`javascript/tests`.

## License

This package is licensed to you under the terms of the [GNU General Public
License](http://www.gnu.org/licenses/gpl.html) version 3 or later.

Copyright 2013-2015 RStudio, Inc.
