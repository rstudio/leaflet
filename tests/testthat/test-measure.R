
context("measure")

test_that("dependency got added", {
  expect_true(
    !is.na(Position(
      function(dep) dep$name == "leaflet-measure",
      addMeasure(leaflet())$dependencies
    ))
  )
})

test_that("call got added", {
  expect_true(
    !is.na(Position(
      function(cl) cl$method == "addMeasure",
      addMeasure(leaflet())$x$calls
    ))
  )
})

test_that("options added as expected", {
  expect_true(
    Filter(
      function(cl) cl$method == "addMeasure",
      addMeasure(leaflet(), position = "bottomleft")$x$calls
    )[[1]]$args[[1]]$position == "bottomleft"
  )
})

# are null options removed
# were options added as expected
test_that("null options removed", {
  expect_true(
    !("position" %in% names(Filter(
      function(cl) cl$method == "addMeasure"
      , addMeasure(leaflet(), position = NULL )$x$calls
    )[[1]]$args[[1]]))
  )
})
