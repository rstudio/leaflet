
testthat::test_that("Checking of tile providers works correctly", {
  expect_no_error(
    leaflet() %>% addProviderTiles(providers[[1]])
  )

  expect_no_error(
    leaflet() %>% addProviderTiles("FAKETILESET123", .check = FALSE)
  )

  expect_error(
    leaflet() %>% addProviderTiles("FAKETILESET123")
  )
})
