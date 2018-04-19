# Comments

## 2018-4-19
This submission is done by Barret Schloerke <barret@rstudio.com> on behalf of Joe Cheng <joe@rstudio.com>. Please submit any changes to be made to <barret@rstudio.com>.

- Barret


## Test environments
* local OS X install, R 3.4.4, --run-dontcheck
  * 0 errors | 0 warnings | 0 note
* ubuntu 12.04 (on travis-ci), R version 3.4.4 (2017-01-27)
  * 0 errors | 0 warnings | 0 note

I believe the warning and note below are transient within r-hub.
  * WARNING: Conversion of "README.md" failed:
    * the svg at https://travis-ci.org/rstudio/leaflet.svg?branch=master exists
  * NOTE: checking examples:
    * The examples are taking a longer time only on windows and hardly any time is user or system.
  * NOTE: checking package dependencies
    * On linux... Packages suggested but not available for checking: ‘sf’ ‘rgdal’ ‘rgeos’

* r-hub
  * Platform:   Windows Server 2008 R2 SP1, R-release, 32/64 bit
    https://builder.r-hub.io/status/leaflet_2.0.0.tar.gz-530b3d51e28d4a0dae75211474df73e6
    ❯ checking top-level files ... WARNING
      Conversion of 'README.md' failed:
      pandoc.exe: Could not fetch https://travis-ci.org/rstudio/leaflet.svg?branch=master
      no store
      CallStack (from HasCallStack):
        error, called at .\System\X509\Win32.hs:56:31 in x509-system-1.6.4-E9zvdZ6nI282vjtOPFYSd1:System.X509.Win32
    ❯ checking examples ... NOTE
      Examples with CPU or elapsed time > 5s
      leaflet 1.26    1.7    5.33
              user system elapsed
      ** found \donttest examples: check also with --run-donttest

    0 errors ✔ | 1 warning ✖ | 1 note ✖

  * Platform:   Windows Server 2008 R2 SP1, R-devel, 32/64 bit
    https://builder.r-hub.io/status/leaflet_2.0.0.tar.gz-399d221fdf1648d5a6eb615f68abc1fa
    ❯ checking top-level files ... WARNING
      Conversion of 'README.md' failed:
      pandoc.exe: Could not fetch https://travis-ci.org/rstudio/leaflet.svg?branch=master
      no store
      CallStack (from HasCallStack):
        error, called at .\System\X509\Win32.hs:56:31 in x509-system-1.6.4-E9zvdZ6nI282vjtOPFYSd1:System.X509.Win32

    ❯ checking examples ... NOTE
      Examples with CPU or elapsed time > 5s
              user system elapsed
      leaflet 1.61   1.35    5.75
      ** found \donttest examples: check also with --run-donttest

    0 errors ✔ | 1 warning ✖ | 1 note ✖

  * Platform:   Ubuntu Linux 16.04 LTS, R-release, GCC
    https://builder.r-hub.io/status/leaflet_2.0.0.tar.gz-bba7e3975ec949f8ba24843bf68be6eb
    ❯ checking package dependencies ... NOTE
      Packages suggested but not available for checking: ‘sf’ ‘rgdal’ ‘rgeos’

    0 errors ✔ | 0 warnings ✔ | 1 note ✖

  * Platform:   Fedora Linux, R-devel, clang, gfortran
    https://builder.r-hub.io/status/leaflet_2.0.0.tar.gz-9178afdcb7594c9da0550ca2846bda0e
    ❯ checking package dependencies ... NOTE
      Packages suggested but not available for checking: ‘sf’ ‘rgdal’ ‘rgeos’

    0 errors ✔ | 0 warnings ✔ | 1 note ✖

## Reverse dependencies

* All revdep maintainers were notified on March 29, 2018 for a release date of April 16th.

* I have run R CMD check on the 60 downstream dependencies.
  * https://github.com/rstudio/leaflet/blob/master/revdep/problems.md

* No errors, warnings, or notes were introduced due to changes in leaflet

* Could not install: segclust2d
