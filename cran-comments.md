# Comments

## 2018-6-4
This submission is done by Barret Schloerke <barret@rstudio.com> on behalf of Joe Cheng <joe@rstudio.com>. Please submit any changes to be made to <barret@rstudio.com>.

- Barret


## Test environments
* local OS X install, R 3.5.0, --run-dontcheck
  * 0 errors | 0 warnings | 0 notes
* ubuntu 14.04.5 (on travis-ci), R version 3.5.0 (2017-01-27)
  * 0 errors | 0 warnings | 0 notes
* devtools::build_win() x86_64-w64-mingw32, R version 3.5.0 (2018-04-23)
  * 0 errors | 0 warnings | 0 notes
* devtools::build_win() x86_64-w64-mingw32, R Under development (unstable) (2018-06-03 r74839)
  * 0 errors | 0 warnings | 0 notes

I believe the warning and note below are transient within r-hub.
  * WARNING: Conversion of "README.md" failed:
    * the svg at https://travis-ci.org/rstudio/leaflet.svg?branch=master exists
  * NOTE: checking package dependencies
    * Packages suggested but not available for checking: ‘sf’ ‘rgdal’ ‘rgeos’
      * rgdal
        * I know rgdal has a source version that does not compile without an external library
        * The tests rgdal validated locally and on travis

* r-hub

  * Platform:   Windows Server 2008 R2 SP1, R-release, 32/64 bit
    http://builder.r-hub.io/status/leaflet_2.0.1.tar.gz-15775eb481a9459f904cba113f9323be
    ❯ checking top-level files ... WARNING
    ❯ checking package dependencies ... NOTE
      Packages suggested but not available for checking: 'rgdal' 'rgeos'
    0 errors ✔ | 1 warning ✖ | 1 note ✖


  * Platform:   Windows Server 2008 R2 SP1, R-devel, 32/64 bit
    http://builder.r-hub.io/status/leaflet_2.0.1.tar.gz-4f5603a8abeb470db77bb3adb682fc29
    ❯ checking top-level files ... WARNING
      Conversion of 'README.md' failed:
      pandoc.exe: Could not fetch https://travis-ci.org/rstudio/leaflet.svg?branch=master
      no store
      CallStack (from HasCallStack):
        error, called at .\System\X509\Win32.hs:56:31 in x509-system-1.6.4-E9zvdZ6nI282vjtOPFYSd1:System.X509.Win32
    ❯ checking package dependencies ... NOTE
      Packages suggested but not available for checking: 'rgdal' 'rgeos'
    0 errors ✔ | 1 warning ✖ | 1 note ✖

  * Platform:   Ubuntu Linux 16.04 LTS, R-release, GCC
    * checked with `_R_CHECK_FORCE_SUGGESTS_=0`
    http://builder.r-hub.io/status/leaflet_2.0.1.tar.gz-0bc1c360b5cb45a883cd87b5c8408b2f
    ❯ checking package dependencies ... NOTE
      Packages suggested but not available for checking: ‘sf’ ‘rgdal’ ‘rgeos’
    0 errors ✔ | 0 warnings ✔ | 1 note ✖

  * Platform:   Fedora Linux, R-devel, clang, gfortran
    * checked with `_R_CHECK_FORCE_SUGGESTS_=0`
    http://builder.r-hub.io/status/leaflet_2.0.1.tar.gz-dcd35d9761ef4e8596ec02e53207de49
    ❯ checking package dependencies ... NOTE
      Packages suggested but not available for checking: ‘sf’ ‘rgdal’ ‘rgeos’
    0 errors ✔ | 0 warnings ✔ | 1 note ✖

## Reverse dependencies

* Revdep maintainers were not contacted as this release is for bug fixes and enhancements from particular maintainers.

* I have run R CMD check on the 63 downstream dependencies.
  * https://github.com/rstudio/leaflet/blob/master/revdep/problems.md
  * No errors, warnings, or notes were introduced due to changes in leaflet

* All revdeps were able to be tested
