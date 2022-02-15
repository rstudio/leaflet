## Comments

#### 2022-02-15

This submission is at Dr. Ripley's request; it fixes some unit tests that broke with a recent update to sf.

## Test environments

* local OS X install, R 3.6.1, --run-dontcheck
  * 0 errors | 0 warnings | 0 notes

* ubuntu 14.04.5 (on travis-ci), R version 3.6.1 (2017-01-27)
  * 0 errors | 0 warnings | 0 notes

* win-builder (devel)
  * 0 errors | 0 warnings | 0 notes

* R-hub windows-x86_64-devel (r-devel)
  * 0 errors | 0 warnings | 0 notes

* R-hub ubuntu-gcc-release (r-release)
  ❯ On ubuntu-gcc-release (r-release)
    checking package dependencies ... NOTE
    Packages suggested but not available for checking: 'sf', 'rgdal'
  * 0 errors ✖ | 0 warnings ✔ | 1 note ✖

* R-hub fedora-clang-devel (r-devel)
  * 0 errors | 0 warnings | 0 notes

## revdepcheck results

We checked 151 reverse dependencies (145 from CRAN + 6 from BioConductor), comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages
