# An R Interface to Leaflet Maps

<!-- badges: start -->
[![R build status](https://github.com/rstudio/leaflet/workflows/R-CMD-check/badge.svg)](https://github.com/rstudio/leaflet/actions)
[![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/leaflet)](https://www.r-pkg.org/pkg/leaflet)
[![](https://www.r-pkg.org/badges/version/leaflet)](https://www.r-pkg.org/pkg/leaflet)
[![RStudio community](https://img.shields.io/badge/community-leaflet-blue?style=social&logo=rstudio&logoColor=75AADB)](https://community.rstudio.com/new-topic?title=&tags=leaflet&body=%0A%0A%0A%20%20--------%0A%20%20%0A%20%20%3Csup%3EReferred%20here%20by%20%60leaflet%60%27s%20GitHub%3C/sup%3E%0A&u=barret)
<!-- badges: end -->

[Leaflet](https://leafletjs.com) is an open-source JavaScript library for
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

You can install this package from CRAN, or the development version from GitHub:

```r
# CRAN version
install.packages('leaflet')

# Or Github version
if (!require('devtools')) install.packages('devtools')
devtools::install_github('rstudio/leaflet')
```

## Documentation

In addition to the usual R package documentation, we also have extensive docs and examples at:
[https://rstudio.github.io/leaflet/](https://rstudio.github.io/leaflet/)

## Development

`leaflet`'s JavaScript build tools use Node.js, along with [yarn](https://yarnpkg.com/) to manage the JavaScript packages.

Install `yarn` using the [official instructions](https://classic.yarnpkg.com/en/docs/install).

You can test that Node.js and yarn are installed properly by running the following commands:

```bash
node --version
yarn --version
```

To make additions or modifications to the JavaScript `htmlwidgets` binding layer,
you must have all Node.js dependencies installed. Now you can build/minify/lint/test using `yarn build`, or run in "watch" mode
by just running `yarn watch`. JS sources go into `javascript/src` and tests go into
`javascript/tests`.

```bash
# install dependencies
yarn

# compile
yarn build

# watch
yarn watch
```


## License

This package is licensed to you under the terms of the [GNU General Public
License](https://www.gnu.org/licenses/gpl-3.0.html) version 3 or later.

Copyright 2013-2015 RStudio, Inc.
