# amt

Version: 0.0.3.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘Rcpp’
      All declared Imports should be used.
    ```

# CDECRetrieve

Version: 0.1.0

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
    [1] NA
    
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
    Error: tz1.set == tz2.set is not TRUE
    Execution halted
    ```

# jpmesh

Version: 1.1.0

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 176 marked UTF-8 strings
    ```

# jpndistrict

Version: 0.3.0

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      Loading required package: jpmesh
      This package provide map data is based on the Digital Map 25000(Map
      Image) published by Geospatial Information Authorityof Japan (Approval
      No.603FY2017 information usage <http://www.gsi.go.jp>)
      > 
      > test_check("jpndistrict")
      ── 1. Failure: jpn_pref (@test-spdf_jpn.R#20)  ─────────────────────────────────
      Names of `df_pref2` ('jis_code', 'prefecture', 'geometry') don't match 'jis_code', 'prefecture', '.'
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      OK: 41 SKIPPED: 0 FAILED: 1
      1. Failure: jpn_pref (@test-spdf_jpn.R#20) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

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

# leaflet.esri

Version: 0.2

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘htmlwidgets’ ‘shiny’
      All declared Imports should be used.
    ```

# leaflet.extras

Version: 0.2

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘shiny’
      All declared Imports should be used.
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

# parlitools

Version: 0.2.1

## In both

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
    HTTP error 524.
    Execution halted
    ```

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 13 marked UTF-8 strings
    ```

# RgoogleMaps

Version: 1.4.1

## In both

*   checking examples ... ERROR
    ```
    ...
    > 
    > 
    >    #points with a few additional options such as quantile boxes, additional buffers, etc.  
    > 
    > 
    >   bb <- qbbox(c(40.702147,40.711614,40.718217),c(-74.015794,-74.012318,-73.998284), 
    + 
    + 
    +             TYPE = "all", margin = list(m=rep(5,4), TYPE = c("perc", "abs")[1]));
    > 
    > 
    >  ##download the map:           
    > 
    > 
    > MyMap <- GetMap.bbox(bb$lonR, bb$latR,destfile = "MyTile3.png", maptype = "satellite") 
    Warning in download.file(urlStr, destfile, mode = "wb", quiet = TRUE) :
      cannot open URL 'http://maps.google.com/maps/api/staticmap?center=40.710182,-74.007039&zoom=15&size=640x640&maptype=satellite&format=png32&sensor=true': HTTP status was '403 Forbidden'
    Error in download.file(urlStr, destfile, mode = "wb", quiet = TRUE) : 
      cannot open URL 'http://maps.google.com/maps/api/staticmap?center=40.710182,-74.007039&zoom=15&size=640x640&maptype=satellite&format=png32&sensor=true'
    Calls: GetMap.bbox -> GetMap -> download.file
    Execution halted
    ```

# rpostgisLT

Version: 0.6.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘htmltools’
      All declared Imports should be used.
    ```

# segclust2d

Version: 0.1.0

## In both

*   checking whether package ‘segclust2d’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/checks.noindex/segclust2d/new/segclust2d.Rcheck/00install.out’ for details.
    ```

## Installation

### Devel

```
* installing *source* package ‘segclust2d’ ...
** package ‘segclust2d’ successfully unpacked and MD5 sums checked
** libs
clang++  -I/Library/Frameworks/R.framework/Resources/include -DNDEBUG  -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/leaflet/new/Rcpp/include" -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/segclust2d/RcppArmadillo/include" -I/usr/local/include  -fopenmp -fPIC  -Wall -g -O2  -c RcppExports.cpp -o RcppExports.o
clang: error: unsupported option '-fopenmp'
make: *** [RcppExports.o] Error 1
ERROR: compilation failed for package ‘segclust2d’
* removing ‘/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/checks.noindex/segclust2d/new/segclust2d.Rcheck/segclust2d’

```
### CRAN

```
* installing *source* package ‘segclust2d’ ...
** package ‘segclust2d’ successfully unpacked and MD5 sums checked
** libs
clang++  -I/Library/Frameworks/R.framework/Resources/include -DNDEBUG  -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/leaflet/old/Rcpp/include" -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/segclust2d/RcppArmadillo/include" -I/usr/local/include  -fopenmp -fPIC  -Wall -g -O2  -c RcppExports.cpp -o RcppExports.o
clang: error: unsupported option '-fopenmp'
make: *** [RcppExports.o] Error 1
ERROR: compilation failed for package ‘segclust2d’
* removing ‘/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/checks.noindex/segclust2d/old/segclust2d.Rcheck/segclust2d’

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
      installed size is  8.1Mb
    ```

# SWMPrExtension

Version: 0.3.12

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘rgeos’ ‘stringr’
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

*   checking installed package size ... NOTE
    ```
      installed size is  5.3Mb
      sub-directories of 1Mb or more:
        data   1.5Mb
        doc    3.3Mb
    ```

# trackeR

Version: 1.0.0

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  5.0Mb
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

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘RandomFields’ ‘data.table’
      All declared Imports should be used.
    ```

