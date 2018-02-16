context("colors")

# Like expect_warning, but returns the result of the expr
with_warning <- function(expr) {
  expect_warning(result <- force(expr))
  result
}

test_that("factors match by name, not position", {

  full <- factor(letters[1:5])
  pal <- colorFactor("magma", na.color = NA, levels = full)

  partial <- full[2:4]
  expect_identical(pal(partial), pal(droplevels(partial)))

  # Sending in values outside of the color scale should result in a warning and na.color
  expect_warning(pal(letters[10:20]))
  expect_true(suppressWarnings(all(is.na(pal(letters[10:20])))))
})

test_that("qualitative palettes don't interpolate", {
  pal <- colorFactor("Accent", na.color = NA, levels = letters[1:5])

  allColors <- RColorBrewer::brewer.pal(
    n = RColorBrewer::brewer.pal.info["Accent", "maxcolors"],
    name = "Accent")

  # If we're not interpolating, then the colors for each level should match
  # exactly with the color in the corresponding position in the palette.
  expect_identical(pal(letters[1:5]), allColors[1:5])

  # Same behavior when domain is provided initially
  expect_identical(
    colorFactor("Accent", domain = rep(letters[1:5], 2))(letters[1:5]),
    allColors[1:5]
  )
  # Same behavior when domain is provided initially, and is a factor
  expect_identical(
    colorFactor("Accent", domain = factor(rep(letters[5:1], 2)))(letters[1:5]),
    allColors[1:5]
  )
  # Same behavior when domain is provided initially, and is not a factor
  expect_identical(
    colorFactor("Accent", domain = rep(letters[5:1], 2), ordered = TRUE)(letters[5:1]),
    allColors[1:5]
  )
  # Same behavior when no domain or level is provided initially
  expect_identical(
    colorFactor("Accent", NULL)(letters[1:5]),
    allColors[1:5]
  )

  # Values outside of the originally provided levels should be NA with warning
  expect_warning(pal(letters[6]))
  expect_true(suppressWarnings(is.na(pal(letters[6]))))
})

test_that("OK, qualitative palettes sometimes interpolate", {
  pal <- colorFactor("Accent", na.color = NA, levels = letters[1:20])

  allColors <- RColorBrewer::brewer.pal(
    n = RColorBrewer::brewer.pal.info["Accent", "maxcolors"],
    name = "Accent")

  result <- with_warning(pal(letters[1:20]))
  # The first and last levels are the first and last palette colors
  expect_true(all(result[c(1, 20)] %in% allColors))
  # All the rest are interpolated though
  expect_true(!any(result[-c(1, 20)] %in% allColors))
})

verifyReversal <- function(colorFunc, values, ..., filter = identity) {
  f1 <- filter(colorFunc("Blues", domain = values, ...)(values))
  f2 <- filter(colorFunc("Blues", domain = NULL, ...)(values))
  f3 <- filter(colorFunc("Blues", domain = values, reverse = FALSE, ...)(values))
  f4 <- filter(colorFunc("Blues", domain = NULL, reverse = FALSE, ...)(values))
  r1 <- filter(colorFunc("Blues", domain = values, reverse = TRUE, ...)(values))
  r2 <- filter(colorFunc("Blues", domain = NULL, reverse = TRUE, ...)(values))

  expect_identical(f1, f2)
  expect_identical(f1, f3)
  expect_identical(f1, f4)
  expect_identical(r1, r2)
  expect_identical(f1, rev(r1))
}

test_that("colorNumeric can be reversed", {
  verifyReversal(colorNumeric, 1:10)
})

test_that("colorBin can be reversed", {
  # colorBin needs to filter because with 10 values and 7 bins, there is some
  # repetition that occurs in the results. Hard to explain but easy to see:
  # scales::show_col(colorBin("Blues", NULL)(1:8))
  # scales::show_col(colorBin("Blues", NULL, reverse = TRUE)(1:8))

  verifyReversal(colorBin, 1:10, filter = unique)
})

test_that("colorQuantile can be reversed", {
  verifyReversal(colorQuantile, 1:10, n = 7)
})

test_that("colorFactor can be reversed", {
  # With interpolation
  verifyReversal(colorFactor, letters, filter = with_warning)

  # Without interpolation
  accent <- suppressWarnings(RColorBrewer::brewer.pal(Inf, "Accent"))
  result1 <- colorFactor("Accent", NULL)(letters[1:5])
  expect_identical(result1, head(accent, 5))
  # Reversing a qualitative palette means we should pull the same colors, but
  # apply them in reverse order
  result2 <- colorFactor("Accent", NULL, reverse = TRUE)(letters[1:5])
  expect_identical(result2, rev(head(accent, 5)))
})
