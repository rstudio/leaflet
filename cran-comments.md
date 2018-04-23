# Comments

## 2018-4-20
Resubmitting to avoid example execution time NOTE. Test environment outputs updated below.

- Barret

## 2018-4-19
This submission is done by Barret Schloerke <barret@rstudio.com> on behalf of Joe Cheng <joe@rstudio.com>. Please submit any changes to be made to <barret@rstudio.com>.

- Barret


## Test environments
* local OS X install, R 3.4.4, --run-dontcheck
  * 0 errors | 0 warnings | 0 notes
* ubuntu 12.04 (on travis-ci), R version 3.4.4 (2017-01-27)
  * 0 errors | 0 warnings | 0 notes
* devtools::build_win() x86_64-w64-mingw32, R version 3.4.4 (2018-03-15)
  * 0 errors | 0 warnings | 0 notes

I believe the warning and note below are transient within r-hub.
  * WARNING: Conversion of "README.md" failed:
    * the svg at https://travis-ci.org/rstudio/leaflet.svg?branch=master exists
  * NOTE: checking package dependencies
    * On linux... Packages suggested but not available for checking: ‘sf’ ‘rgdal’ ‘rgeos’

* r-hub
  * Platform:   Windows Server 2008 R2 SP1, R-release, 32/64 bit
    https://builder.r-hub.io/status/leaflet_2.0.0.tar.gz-3915b63fe8c34d99b3ad7aa4b6e94640
    ❯ checking top-level files ... WARNING
      Conversion of 'README.md' failed:
      pandoc.exe: Could not fetch https://travis-ci.org/rstudio/leaflet.svg?branch=master
      no store
      CallStack (from HasCallStack):
        error, called at .\System\X509\Win32.hs:56:31 in x509-system-1.6.4-E9zvdZ6nI282vjtOPFYSd1:System.X509.Win32

    0 errors ✔ | 1 warning ✖ | 0 notes ✔

  * Platform:   Windows Server 2008 R2 SP1, R-devel, 32/64 bit
    https://builder.r-hub.io/status/leaflet_2.0.0.tar.gz-fb1316cbeb5f48eba08e959769a990d4
    ❯ checking top-level files ... WARNING
      Conversion of 'README.md' failed:
      pandoc.exe: Could not fetch https://travis-ci.org/rstudio/leaflet.svg?branch=master
      no store
      CallStack (from HasCallStack):
        error, called at .\System\X509\Win32.hs:56:31 in x509-system-1.6.4-E9zvdZ6nI282vjtOPFYSd1:System.X509.Win32

    0 errors ✔ | 1 warning ✖ | 0 notes ✔

  * Platform:   Ubuntu Linux 16.04 LTS, R-release, GCC
    * checked with `_R_CHECK_FORCE_SUGGESTS_=0`
    https://builder.r-hub.io/status/leaflet_2.0.0.tar.gz-cec4735e750d4f1ea05dca55c153a847
    ❯ checking package dependencies ... NOTE
      Packages suggested but not available for checking: ‘sf’ ‘rgdal’ ‘rgeos’

    0 errors ✔ | 0 warnings ✔ | 1 note ✖

  * Platform:   Fedora Linux, R-devel, clang, gfortran
    * checked with `_R_CHECK_FORCE_SUGGESTS_=0`
    https://builder.r-hub.io/status/leaflet_2.0.0.tar.gz-09d8a5861fb74ed3baa34d727f1df82b
    ❯ checking package dependencies ... NOTE
      Packages suggested but not available for checking: ‘sf’ ‘rgdal’ ‘rgeos’

    0 errors ✔ | 0 warnings ✔ | 1 note ✖

## Reverse dependencies

* All revdep maintainers were notified on March 29, 2018 for a release date of April 16th.

* I have run R CMD check on the 60 downstream dependencies.
  * https://github.com/rstudio/leaflet/blob/master/revdep/problems.md

* No errors, warnings, or notes were introduced due to changes in leaflet

* Could not install: segclust2d
