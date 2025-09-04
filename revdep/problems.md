# mapview

<details>

* Version: 2.11.3
* GitHub: https://github.com/r-spatial/mapview
* Source code: https://github.com/cran/mapview
* Date/Publication: 2025-08-28 12:20:12 UTC
* Number of recursive dependencies: 104

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
      test-mapview.R................  134 tests [0;32mOK[0m 
      test-mapview.R................  135 tests [0;32mOK[0m 
      test-mapview.R................  136 tests [0;32mOK[0m 
      test-mapview.R................  137 tests [0;32mOK[0m 
      test-mapview.R................  138 tests [0;32mOK[0m 
      test-mapview.R................  138 tests [0;32mOK[0m 
      test-mapview.R................  138 tests [0;32mOK[0m Error in as(gadmCHE, "SpatialPolygons") : 
        no method or default for coercing "sf" to "SpatialPolygons"
      Calls: <Anonymous> ... eval -> mapview -> standardGeneric -> eval -> eval -> as
      Execution halted
    ```

