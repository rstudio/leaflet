test_that("evalFormula() does not discard the class of a list", {
  res <- evalFormula(structure(list(1, ~x, ~x + 1), class = "FOO"), data.frame(x = 2))

  expect_s3_class(res, "FOO")
})

test_that("evalFormula() evaluates formulae in a list", {
  res <- evalFormula(structure(list(1, ~x, ~x + 1), class = "FOO"), data.frame(x = 2))

  expect_equal(res[[2]], 2)
  expect_equal(res[[3]], 3)
})
