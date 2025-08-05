# AtlasMaker

<details>

* Version: 0.1.0
* GitHub: https://github.com/rachel-greenlee/AtlasMaker
* Source code: https://github.com/cran/AtlasMaker
* Date/Publication: 2023-07-17 14:10:05 UTC
* Number of recursive dependencies: 51

Run `revdepcheck::cloud_details(, "AtlasMaker")` for more info

</details>

## Newly broken

*   checking data for non-ASCII characters ... WARNING
    ```
      Error loading dataset 'amphibians':
       Error in .requirePackage(package) : unable to find required package 'sp'
      
      Error loading dataset 'birds':
       Error in .requirePackage(package) : unable to find required package 'sp'
      
      Error loading dataset 'flowering_plants':
       Error in .requirePackage(package) : unable to find required package 'sp'
      
      Error loading dataset 'reptiles':
       Error in .requirePackage(package) : unable to find required package 'sp'
      
      The dataset(s) may use package(s) not declared in Depends/Imports.
    ```

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  6.7Mb
      sub-directories of 1Mb or more:
        data   6.5Mb
    ```

# leafgl

<details>

* Version: 0.2.2
* GitHub: https://github.com/r-spatial/leafgl
* Source code: https://github.com/cran/leafgl
* Date/Publication: 2024-11-13 18:10:02 UTC
* Number of recursive dependencies: 82

Run `revdepcheck::cloud_details(, "leafgl")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Complete output:
      > library(testthat)
      > library(leafgl)
      > 
      > test_check("leafgl")
      [ FAIL 3 | WARN 0 | SKIP 0 | PASS 370 ]
      
      ══ Failed tests ════════════════════════════════════════════════════════════════
    ...
       2. │ └─base::withCallingHandlers(...)
       3. ├─sf::as_Spatial(gadm)
       4. └─base::loadNamespace(x)
       5.   └─base::withRestarts(stop(cond), retry_loadNamespace = function() NULL)
       6.     └─base (local) withOneRestart(expr, restarts[[1L]])
       7.       └─base (local) doWithOneRestart(return(expr), restart)
      
      [ FAIL 3 | WARN 0 | SKIP 0 | PASS 370 ]
      Error: Test failures
      Execution halted
    ```

# leaflet.extras2

<details>

* Version: 1.3.1
* GitHub: https://github.com/trafficonese/leaflet.extras2
* Source code: https://github.com/cran/leaflet.extras2
* Date/Publication: 2025-03-05 13:40:06 UTC
* Number of recursive dependencies: 83

Run `revdepcheck::cloud_details(, "leaflet.extras2")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Complete output:
      > library(testthat)
      > library(htmltools)
      > library(leaflet)
      > library(leaflet.extras2)
      > 
      > test_check("leaflet.extras2")
      [ FAIL 1 | WARN 0 | SKIP 0 | PASS 440 ]
    ...
      ── Error ('test-playback.R:355:3'): playback ───────────────────────────────────
      Error: unable to find an inherited method for function 'coordinates' for signature 'obj = "sf"'
      Backtrace:
          ▆
       1. └─sp::coordinates(leaflet::atlStorms2005[1, ]) at test-playback.R:355:3
       2.   └─methods (local) `<fn>`(`<list>`, `<S4: standardGeneric>`, `<env>`)
      
      [ FAIL 1 | WARN 0 | SKIP 0 | PASS 440 ]
      Error: Test failures
      Execution halted
    ```

# lingtypology

<details>

* Version: 1.1.22
* GitHub: https://github.com/ropensci/lingtypology
* Source code: https://github.com/cran/lingtypology
* Date/Publication: 2025-06-14 15:50:02 UTC
* Number of recursive dependencies: 72

Run `revdepcheck::cloud_details(, "lingtypology")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Complete output:
      > library(testthat)
      > library(lingtypology)
      Based on the Glottolog v. 5.2
      > 
      > test_check("lingtypology")
      [ FAIL 1 | WARN 0 | SKIP 34 | PASS 0 ]
      
    ...
      Error in `leaflet::addProviderTiles(leaflet::addTiles(m, tile[1]), tile[1], 
          group = tile.name[1], options = leaflet::providerTileOptions(opacity = tile.opacity))`: Unknown tile provider 'OpenStreetMap.BlackAndWhite'; either use a known provider or pass `check = FALSE` to `addProviderTiles()`
      Backtrace:
          ▆
       1. └─lingtypology::map.feature(...) at test-mapfeature.R:161:1
       2.   └─leaflet::addProviderTiles(...)
      
      [ FAIL 1 | WARN 0 | SKIP 34 | PASS 0 ]
      Error: Test failures
      Execution halted
    ```

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  7.7Mb
      sub-directories of 1Mb or more:
        data   6.5Mb
    ```

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 60812 marked UTF-8 strings
    ```

# mapview

<details>

* Version: 2.11.2
* GitHub: https://github.com/r-spatial/mapview
* Source code: https://github.com/cran/mapview
* Date/Publication: 2023-10-13 09:10:02 UTC
* Number of recursive dependencies: 111

Run `revdepcheck::cloud_details(, "mapview")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘tinytest.R’
    Running the tests in ‘tests/tinytest.R’ failed.
    Complete output:
      > if (requireNamespace("tinytest", quietly=TRUE)) {
      +   tinytest::test_package("mapview")
      + }
      
      test-color.R..................    0 tests    
      test-color.R..................    1 tests [0;32mOK[0m 
      test-color.R..................    2 tests [0;32mOK[0m 
    ...
      test-mapview.R................  118 tests [0;32mOK[0m 
      test-mapview.R................  119 tests [0;32mOK[0m 
      test-mapview.R................  120 tests [0;32mOK[0m 
      test-mapview.R................  121 tests [0;32mOK[0m 
      test-mapview.R................  122 tests [0;32mOK[0m 
      test-mapview.R................  122 tests [0;32mOK[0m 
      test-mapview.R................  122 tests [0;32mOK[0m Error in as(atlStorms2005, "SpatialLines") : 
        no method or default for coercing "sf" to "SpatialLines"
      Calls: <Anonymous> ... eval -> mapview -> standardGeneric -> eval -> eval -> as
      Execution halted
    ```

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 1 marked UTF-8 string
    ```

# rapr

<details>

* Version: 1.0.0
* GitHub: https://github.com/brownag/rapr
* Source code: https://github.com/cran/rapr
* Date/Publication: 2025-05-12 08:40:02 UTC
* Number of recursive dependencies: 63

Run `revdepcheck::cloud_details(, "rapr")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘tinytest.R’
    Running the tests in ‘tests/tinytest.R’ failed.
    Complete output:
      > 
      > if ( requireNamespace("tinytest", quietly=TRUE) ){
      +   tinytest::test_package("rapr")
      + }
      
      test_rapr.R...................    0 tests    
      test_rapr.R...................    0 tests    
    ...
      test_rapr.R...................   10 tests [0;32mOK[0m 
      test_rapr.R...................   10 tests [0;32mOK[0m 
      test_rapr.R...................   11 tests [0;32mOK[0m 
      test_rapr.R...................   12 tests [0;32mOK[0m 
      test_rapr.R...................   13 tests [0;32mOK[0m 
      test_rapr.R...................   14 tests [0;32mOK[0m 
      test_rapr.R...................   14 tests [0;32mOK[0m Error in sfc2SpatialPolygons(from, IDs) : 
        package sp required, please install it first
      Calls: <Anonymous> ... <Anonymous> -> as_Spatial -> .as_Spatial -> sfc2SpatialPolygons
      Execution halted
    ```

