# amt

Version: 0.0.4.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘Rcpp’ ‘magrittr’
      All declared Imports should be used.
    ```

# CDECRetrieve

Version: 0.1.1

## In both

*   checking re-building of vignette outputs ... WARNING
    ```
    Error in re-building vignettes:
      ...
    Quitting from lines 100-102 (CDECRetrieve.Rmd) 
    Error: processing vignette 'CDECRetrieve.Rmd' failed with diagnostics:
    Table has inconsistent number of columns. Do you want fill = TRUE?
    Execution halted
    ```

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘lazyeval’ ‘purrr’ ‘roxygen2’
      All declared Imports should be used.
    ```

# epiflows

Version: 0.2.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘htmlwidgets’
      All declared Imports should be used.
    ```

# fingertipscharts

Version: 0.0.1

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘fingertipsR’ ‘mapproj’
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

# jpmesh

Version: 1.1.1

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 176 marked UTF-8 strings
    ```

# jpndistrict

Version: 0.3.2

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

Version: 1.0.13

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 120 marked UTF-8 strings
    ```

# mapedit

Version: 0.4.3

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

Version: 0.3.7

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘plyr’
      All declared Imports should be used.
    ```

# mapview

Version: 2.5.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘stars’
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

# MODIStsp

Version: 1.3.6

## In both

*   checking package dependencies ... ERROR
    ```
    Package required but not available: ‘gWidgetsRGtk2’
    
    See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
    manual.
    ```

# parlitools

Version: 0.2.1

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 13 marked UTF-8 strings
    ```

# pkgdown

Version: 1.1.0

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      nrow(out) not equal to 1.
      1/1 mismatches
      [1] 0 - 1 == -1
      
      ── 2. Failure: can autodetect published tutorials (@test-tutorials.R#31)  ──────
      out$name not equal to "test-1".
      Lengths differ: 0 is not 1
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      OK: 241 SKIPPED: 9 FAILED: 2
      1. Failure: can autodetect published tutorials (@test-tutorials.R#30) 
      2. Failure: can autodetect published tutorials (@test-tutorials.R#31) 
      
      Error: testthat unit tests failed
      Execution halted
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

# rtrek

Version: 0.1.0

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 992 marked UTF-8 strings
    ```

# segclust2d

Version: 0.1.0

## In both

*   checking whether package ‘segclust2d’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/checks.noindex/segclust2d/new/segclust2d.Rcheck/00install.out’ for details.
    ```

*   checking package dependencies ... NOTE
    ```
    Package suggested but not available for checking: ‘depmixS4’
    ```

## Installation

### Devel

```
* installing *source* package ‘segclust2d’ ...
** package ‘segclust2d’ successfully unpacked and MD5 sums checked
** libs
clang++  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/leaflet/new/Rcpp/include" -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/segclust2d/RcppArmadillo/include" -I/usr/local/include  -fopenmp -fPIC  -Wall -g -O2  -c RcppExports.cpp -o RcppExports.o
clang++  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/leaflet/new/Rcpp/include" -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/segclust2d/RcppArmadillo/include" -I/usr/local/include  -fopenmp -fPIC  -Wall -g -O2  -c SegTraj_DynProg.cpp -o SegTraj_DynProg.o
clang++  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/leaflet/new/Rcpp/include" -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/segclust2d/RcppArmadillo/include" -I/usr/local/include  -fopenmp -fPIC  -Wall -g -O2  -c SegTraj_EM.cpp -o SegTraj_EM.o
clang++  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/leaflet/new/Rcpp/include" -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/segclust2d/RcppArmadillo/include" -I/usr/local/include  -fopenmp -fPIC  -Wall -g -O2  -c SegTraj_Gmixt.cpp -o SegTraj_Gmixt.o
clang: error: unsupported option '-fopenmp'
clang: clang: errorerror: unsupported option '-fopenmp': unsupported option '-fopenmp'

clang: error: unsupported option '-fopenmp'
make: *** [SegTraj_EM.o] Error 1
make: *** Waiting for unfinished jobs....
make: *** [SegTraj_Gmixt.o] Error 1
make: *** [SegTraj_DynProg.o] Error 1
make: *** [RcppExports.o] Error 1
ERROR: compilation failed for package ‘segclust2d’
* removing ‘/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/checks.noindex/segclust2d/new/segclust2d.Rcheck/segclust2d’

```
### CRAN

```
* installing *source* package ‘segclust2d’ ...
** package ‘segclust2d’ successfully unpacked and MD5 sums checked
** libs
clang++  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/leaflet/old/Rcpp/include" -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/segclust2d/RcppArmadillo/include" -I/usr/local/include  -fopenmp -fPIC  -Wall -g -O2  -c RcppExports.cpp -o RcppExports.o
clang++  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/leaflet/old/Rcpp/include" -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/segclust2d/RcppArmadillo/include" -I/usr/local/include  -fopenmp -fPIC  -Wall -g -O2  -c SegTraj_DynProg.cpp -o SegTraj_DynProg.o
clang++  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/leaflet/old/Rcpp/include" -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/segclust2d/RcppArmadillo/include" -I/usr/local/include  -fopenmp -fPIC  -Wall -g -O2  -c SegTraj_EM.cpp -o SegTraj_EM.o
clang++  -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/leaflet/old/Rcpp/include" -I"/Users/barret/odrive/AmazonCloudDrive/git/rstudio/leaflet/leaflet/revdep/library.noindex/segclust2d/RcppArmadillo/include" -I/usr/local/include  -fopenmp -fPIC  -Wall -g -O2  -c SegTraj_Gmixt.cpp -o SegTraj_Gmixt.o
clang: error: unsupported option '-fopenmp'clang: clang: error: error
: unsupported option '-fopenmp'
unsupported option '-fopenmp'
clang: error: unsupported option '-fopenmp'
make: *** [SegTraj_EM.o] Error 1
make: *** Waiting for unfinished jobs....
make: *** [SegTraj_Gmixt.o] Error 1
make: *** [SegTraj_DynProg.o] Error 1
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

# SWMPrExtension

Version: 0.3.16

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘rgeos’
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

Version: 1.0.5

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘DT’ ‘ENMeval’ ‘RColorBrewer’ ‘XML’ ‘dismo’ ‘dplyr’ ‘leaflet.extras’
      ‘maptools’ ‘raster’ ‘rgdal’ ‘rgeos’ ‘rmarkdown’ ‘shinyjs’
      ‘shinythemes’ ‘spThin’ ‘spocc’ ‘testthat’
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

