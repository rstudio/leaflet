# leaflet.opacity

<details>

* Version: 0.1.0
* GitHub: https://github.com/be-marc/leaflet.opacity
* Source code: https://github.com/cran/leaflet.opacity
* Date/Publication: 2018-11-29 16:00:10 UTC
* Number of recursive dependencies: 80

Run `revdepcheck::cloud_details(, "leaflet.opacity")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      y[1]: "opacity"
      ── Failure ('test-controls.R:52:3'): Initialize map dependencies in addHigherOpacity ──
      res$dependencies[[1]]$name not equal to "jquery-ui".
      1/1 mismatches
      x[1]: "jquery"
      y[1]: "jquery-ui"
      ── Failure ('test-controls.R:53:3'): Initialize map dependencies in addHigherOpacity ──
      res$dependencies[[2]]$name not equal to "opacity".
      1/1 mismatches
      x[1]: "leaflet"
      y[1]: "opacity"
      
      [ FAIL 6 | WARN 4 | SKIP 0 | PASS 3 ]
      Error: Test failures
      Execution halted
    ```

## In both

*   checking LazyData ... NOTE
    ```
      'LazyData' is specified without a 'data' directory
    ```

