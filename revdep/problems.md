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

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 13 marked UTF-8 strings
    ```

# rdwd

Version: 0.9.0

## In both

*   checking re-building of vignette outputs ... WARNING
    ```
    Error in re-building vignettes:
      ...
    Quitting from lines 112-121 (rdwd.Rmd) 
    Error: processing vignette 'rdwd.Rmd' failed with diagnostics:
    cannot open URL 'ftp://ftp-cdc.dwd.de/pub/CDC/observations_germany/climate/monthly/kl/historical/monatswerte_KL_03987_18930101_20161231_hist.zip'
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

Version: 1.11-1

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

