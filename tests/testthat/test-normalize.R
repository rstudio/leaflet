context("normalize")

# guessLatLongCols --------------------------------------------------------
ll_names <- function(lng, lat) list(lng = lng, lat = lat)

test_that("guesses lat/long names", {

  # Abbreviations
  expect_equal(guessLatLongCols(c('lat', 'lng')), ll_names("lng", "lat"))
  expect_equal(guessLatLongCols(c('lat', 'lon')), ll_names("lon", "lat"))
  expect_equal(guessLatLongCols(c('lat', 'long')), ll_names("long", "lat"))

  # Ignores case
  expect_equal(guessLatLongCols(c('Lat', 'Lng')), ll_names("Lng", "Lat"))

  # Understands full names
  expect_equal(
    guessLatLongCols(c('latitude', 'longitude')),
    ll_names("longitude", "latitude")
  )
})

test_that("gives message if additional columns", {
  expect_message(
    guessLatLongCols(c("lat", "lon", "foo")),
    "Assuming 'lon' and 'lat'"
  )
})

test_that("fails if not lat/long columns present", {
  expect_error(
    guessLatLongCols(c('Lat', 'foo')),
    "Couldn't infer longitude/latitude columns"
  )

  expect_error(
    guessLatLongCols(c('Lat', 'lat', "Long")),
    "Couldn't infer longitude/latitude columns"
  )
})
