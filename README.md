# An R Interface to Leaflet Maps

[Leaflet](http://leafletjs.com) is an open-source JavaScript library for
interactive maps. This R package makes it easy to create Leaflet maps from R.

```r
library(leaflet)
m = leaflet() %>% tileLayer()
m  # a map with the default OSM tile layer

m = m %>% setView(c(42.0285, -93.65), zoom = 17)
m

m %>% mapPopup(42.0285, -93.65, 'Here is the <b>Department of Statistics</b>, ISU')
```

This package is not on CRAN yet, and you can install it from Github:

```r
devtools::install_github('rstudio/leaflet')
```

## License

This package is licensed to you under the terms of the [GNU General Public
License](http://www.gnu.org/licenses/gpl.html) version 3 or later.

Copyright 2013-2014 RStudio, Inc.
