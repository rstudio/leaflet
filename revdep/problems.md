# amt

Version: 0.0.4.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘Rcpp’ ‘magrittr’
      All declared Imports should be used.
    ```

# blscrapeR

Version: 3.1.2

## In both

*   checking examples ... ERROR
    ```
    Running examples in ‘blscrapeR-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: qcew_api
    > ### Title: Request data from the Quarterly Census of Employment and Wages.
    > ### Aliases: qcew_api
    > ### Keywords: api bls cpi economics inflation unemployment
    > 
    > ### ** Examples
    > 
    > 
    > # A request for the employment levels and wages for NIACS 5112: Software Publishers.
    > dat <- qcew_api(year=2015, qtr="A", slice="area", sliceCode="US000")
    Please set a numeric year.
    Trying BLS servers...
    URL caused a warning. Please check your parameters and try again: https://data.bls.gov/cew/data/api/2015/A/area/US000.csv
    Error in qcew_api(year = 2015, qtr = "A", slice = "area", sliceCode = "US000") : 
      object 'qcewDat' not found
    Execution halted
    ```

# CDECRetrieve

Version: 0.1.1

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘lazyeval’ ‘purrr’ ‘roxygen2’
      All declared Imports should be used.
    ```

# geoSpectral

Version: 0.17.4

## In both

*   checking examples ... ERROR
    ```
    ...
    $header$Latitude
    [1] NA
    
    $header$Longitude
    [1] NA
    
    
    > 
    > #Convert the data.frame back to Spectra
    > sp2 <- as(df, "Spectra")
    > 
    > #Convert a bare data.frame to Spectra with minimal attributes
    > df2 <- data.frame(ch1=c(1,2,3,4), ch2=c(5,6,7,8), TIME=Sys.time()+1:4, LAT=1:4, LON=5:8)
    > attr(df2, "Units") <- "m-1"
    > attr(df2, "Wavelengths") <- c(500, 600)
    > attr(df2, "ShortName") <- "abs"
    > as(df2, "Spectra")
    Error in validityMethod(as(object, superClass)) : 
      tz1.set == tz2.set is not TRUE
    Calls: as ... anyStrings -> isTRUE -> validityMethod -> stopifnot
    Execution halted
    ```

# inlmisc

Version: 0.4.0

## In both

*   checking examples ... ERROR
    ```
    ...
    The error most likely occurred in:
    
    > ### Name: AddInsetMap
    > ### Title: Add Inset Map to Plot
    > ### Aliases: AddInsetMap
    > ### Keywords: hplot
    > 
    > ### ** Examples
    > 
    > nc <- rgdal::readOGR(system.file("shapes/sids.shp", package = "maptools")[1],
    +                      p4s = "+proj=longlat +datum=NAD27")
    OGR data source with driver: ESRI Shapefile 
    Source: "/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/inlmisc/maptools/shapes/sids.shp", layer: "sids"
    with 100 features
    It has 14 fields
    Integer64 fields read as strings:  CNTY_ CNTY_ID FIPSNO 
    > bb <- sp::bbox(nc[100, ])
    > xlim <- grDevices::extendrange(bb["x", ])
    > ylim <- grDevices::extendrange(bb["y", ])
    > PlotMap(raster::crs(nc), xlim = xlim, ylim = ylim, dms.tick = TRUE)
    Assertion failed: (0), function query, file ../../../../src/geos-3.6.1/src/index/strtree/AbstractSTRtree.cpp, line 287.
    ```

# jpmesh

Version: 1.1.0

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 176 marked UTF-8 strings
    ```

# jpndistrict

Version: 0.3.1

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 502 marked UTF-8 strings
    ```

# lawn

Version: 0.4.2

## In both

*   checking package dependencies ... NOTE
    ```
    Packages which this enhances but not available for checking:
      ‘maps’ ‘geojsonio’
    ```

# leafletCN

Version: 0.2.1

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 12.0Mb
      sub-directories of 1Mb or more:
        geojson  11.9Mb
    ```

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘rgeos’
      All declared Imports should be used.
    ```

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 1096 marked UTF-8 strings
    ```

# lingtypology

Version: 1.0.12

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 118 marked UTF-8 strings
    ```

# mapedit

Version: 0.4.1

## In both

*   checking package dependencies ... NOTE
    ```
    Package which this enhances but not available for checking: ‘geojsonio’
    ```

# mapr

Version: 0.4.0

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 164 marked UTF-8 strings
    ```

# mapsapi

Version: 0.3.5

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘plyr’
      All declared Imports should be used.
    ```

# metScanR

Version: 1.2.0

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 6 marked UTF-8 strings
    ```

# mgwrsar

Version: 0.1

## In both

*   checking Rd cross-references ... NOTE
    ```
    Packages unavailable to check Rd xrefs: ‘McSpatial’, ‘locfit’
    ```

# parlitools

Version: 0.2.1

## Newly fixed

*   checking re-building of vignette outputs ... WARNING
    ```
    Error in re-building vignettes:
      ...
    Linking to GEOS 3.6.1, GDAL 2.1.3, proj.4 4.9.3
    
    Attaching package: 'dplyr'
    
    The following objects are masked from 'package:stats':
    
        filter, lag
    
    The following objects are masked from 'package:base':
    
        intersect, setdiff, setequal, union
    
    Downloading constituency data
    Quitting from lines 67-110 (introduction.Rmd) 
    Error: processing vignette 'introduction.Rmd' failed with diagnostics:
    HTTP error 404.
    Execution halted
    ```

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 13 marked UTF-8 strings
    ```

# phenocamr

Version: 1.1.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘DT’ ‘leaflet’ ‘plotly’ ‘shinydashboard’
      All declared Imports should be used.
    ```

# rdwd

Version: 0.10.2

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  5.1Mb
      sub-directories of 1Mb or more:
        R     2.0Mb
        doc   2.1Mb
    ```

# rpostgisLT

Version: 0.6.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘htmltools’
      All declared Imports should be used.
    ```

# SpatialEpiApp

Version: 0.3

## In both

*   checking package dependencies ... NOTE
    ```
    Package suggested but not available for checking: ‘INLA’
    ```

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘RColorBrewer’ ‘SpatialEpi’ ‘dplyr’ ‘dygraphs’ ‘ggplot2’
      ‘htmlwidgets’ ‘knitr’ ‘leaflet’ ‘mapproj’ ‘maptools’ ‘rgdal’ ‘rgeos’
      ‘rmarkdown’ ‘shinyjs’ ‘spdep’ ‘xts’
      All declared Imports should be used.
    ```

# statesRcontiguous

Version: 0.1.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘dplyr’ ‘magrittr’
      All declared Imports should be used.
    ```

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 34 marked UTF-8 strings
    ```

# stationaRy

Version: 0.4.1

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  8.2Mb
    ```

# SWMPrExtension

Version: 0.3.14

## In both

*   checking examples ... ERROR
    ```
    Running examples in ‘SWMPrExtension-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: national_sk_map
    > ### Title: Reserve National Map with Seasonal Kendall Results
    > ### Aliases: national_sk_map
    > 
    > ### ** Examples
    > 
    > ##National map highlighting west coast states and NERRS (including AK)
    > nerr_states_west <- c('02', '06', '41', '53')
    > 
    > nerrs_codes <- c('pdb', 'sos', 'sfb', 'elk', 'tjr', 'kac')
    > nerrs_sk_results <- c('inc', 'inc', 'dec', 'insig', 'insuff', 'dec')
    > 
    > national_sk_map(sk_reserve = nerrs_codes, sk_results = nerrs_sk_results)
    Assertion failed: (!"should never be reached"), function itemsTree, file ../../../../src/geos-3.6.1/src/index/strtree/AbstractSTRtree.cpp, line 373.
    ```

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘rgeos’
      All declared Imports should be used.
    ```

# teachingApps

Version: 1.0.2

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘data.table’ ‘datasets’ ‘stats’
      All declared Imports should be used.
    ```

# tilegramsR

Version: 0.2.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘sp’
      All declared Imports should be used.
    ```

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 341 marked UTF-8 strings
    ```

# tmap

Version: 1.11-2

## In both

*   checking examples ... ERROR
    ```
    Running examples in ‘tmap-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: tm_xlab
    > ### Title: Axis labels
    > ### Aliases: tm_xlab tm_ylab
    > 
    > ### ** Examples
    > 
    > data(World)
    > 
    > qtm(World, fill="#FFF8DC", projection="longlat", inner.margins=0) +
    + 	tm_grid(x = seq(-180, 180, by=20), y=seq(-90,90,by=10), col = "gray70") +
    + 	tm_xlab("Longitude") +
    + 	tm_ylab("Latitude")
    Assertion failed: (0), function query, file ../../../../src/geos-3.6.1/src/index/strtree/AbstractSTRtree.cpp, line 287.
    ```

*   checking re-building of vignette outputs ... WARNING
    ```
    Error in re-building vignettes:
      ...
    Assertion failed: (0), function query, file ../../../../src/geos-3.6.1/src/index/strtree/AbstractSTRtree.cpp, line 287.
    ```

*   checking installed package size ... NOTE
    ```
      installed size is  5.8Mb
      sub-directories of 1Mb or more:
        data   1.5Mb
        doc    3.3Mb
    ```

# trackeR

Version: 1.0.0

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  5.2Mb
      sub-directories of 1Mb or more:
        data   1.2Mb
        doc    2.7Mb
    ```

# USAboundaries

Version: 0.3.1

## In both

*   checking package dependencies ... NOTE
    ```
    Package suggested but not available for checking: ‘USAboundariesData’
    ```

# wallace

Version: 1.0.4

## In both

*   checking package dependencies ... NOTE
    ```
    Package suggested but not available for checking: ‘RSelenium’
    ```

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘DT’ ‘ENMeval’ ‘RColorBrewer’ ‘dismo’ ‘dplyr’ ‘leaflet.extras’
      ‘maptools’ ‘raster’ ‘rgdal’ ‘rgeos’ ‘shinyjs’ ‘shinythemes’ ‘spThin’
      ‘spocc’
      All declared Imports should be used.
    ```

# windfarmGA

Version: 1.2.1

## In both

*   checking examples ... ERROR
    ```
    ...
    > ### Name: GridFilter
    > ### Title: Make a grid from a Polygon
    > ### Aliases: GridFilter
    > 
    > ### ** Examples
    > 
    > library(sp)
    > 
    > ## Exemplary input Polygon with 2km x 2km:
    > Polygon1 <- Polygon(rbind(c(0, 0), c(0, 2000),
    + c(2000, 2000), c(2000, 0)))
    > Polygon1 <- Polygons(list(Polygon1),1);
    > Polygon1 <- SpatialPolygons(list(Polygon1))
    > Projection <- "+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000
    + +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
    > proj4string(Polygon1) <- CRS(Projection)
    > plot(Polygon1,axes=TRUE)
    > 
    > ## Create a Grid
    > GridFilter(Polygon1,200,1,TRUE)
    Assertion failed: (0), function query, file ../../../../src/geos-3.6.1/src/index/strtree/AbstractSTRtree.cpp, line 287.
    ```

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘RandomFields’ ‘data.table’
      All declared Imports should be used.
    ```

