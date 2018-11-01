# Comments

## 2018-8-24

This submission is done to correct the testing issue from a scales update.

This submission is done by Barret Schloerke <barret@rstudio.com> on behalf of Joe Cheng <joe@rstudio.com>. Please submit any changes to be made to <barret@rstudio.com>.

- Barret


## Test environments
* local OS X install, R 3.5.1, --run-dontcheck
  * 0 errors | 0 warnings | 0 notes
* ubuntu 14.04.5 (on travis-ci), R version 3.5.0 (2017-01-27)
  * 0 errors | 0 warnings | 0 notes
* devtools::build_win() x86_64-w64-mingw32, R version 3.5.1 (2018-07-02)
  * 0 errors | 0 warnings | 0 notes
* devtools::build_win() x86_64-w64-mingw32, R Under development (unstable) (2018-08-22 r75177)
  * 0 errors | 0 warnings | 0 notes

## Reverse dependencies

* Revdep maintainers were not contacted as this release is for documentation fixes and to fix the cran test error.

* I have run R CMD check on the 66 downstream dependencies.
  * https://github.com/rstudio/leaflet/blob/master/revdep/problems.md
  * No errors, warnings, or notes were introduced due to changes in leaflet

* All revdeps except segclust2d were able to be tested
