## Test environments
* local OS X install, R 3.4.4
* ubuntu 12.04 (on travis-ci), R 3.4.4
* win-builder (devel and release)


## R CMD check results

0 errors | 0 warnings | 0 note


## Reverse dependencies

* I have run R CMD check on the NUMBER downstream dependencies.
  * https://github.com/rstudio/leaflet/blob/master/revdep/problems.md

### Failure Summary

* All revdep maintainers were notified on March 29, 2018 for a release date of April 16th.

2 false-positve Package failures:
* geoSpectral
  * error in example with both CRAN and new version of leaflet
* jpndistrict
  * error in test with both CRAN and new version of leaflet

3 packages that could not be tested:
* lawn
* robis
* segclust2d
