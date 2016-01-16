library(testit)

res = evalFormula(structure(list(1, ~x, ~x + 1), class = 'FOO'), data.frame(x = 2))

assert(
  'evalFormula() does not discard the class of a list',
  identical(class(res), c('FOO'))
)

assert(
  'evalFormula() evaluates formulae in a list',
  res[[2]] == 2, res[[3]] == 3
)
