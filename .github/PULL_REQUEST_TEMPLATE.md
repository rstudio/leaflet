## Pull Request

Before you submit a pull request, please do the following:

* Add an entry to NEWS concisely describing what you changed.

* If appropriate, add unit tests in the tests/testthat directory.

* Run Build->Check Package in the RStudio IDE, or `devtools::check()`, to make sure your change did not add any messages, warnings, or errors.

Doing these things will make it easier for the leaflet development team to evaluate your pull request. Even so, we may still decide to modify your code or even not merge it at all. Factors that may prevent us from merging the pull request include:

* breaking backward compatibility
* adding a feature that we do not consider relevant for leaflet
* is hard to understand
* is hard to maintain in the future
* is computationally expensive
* is not intuitive for people to use

We will try to be responsive and provide feedback in case we decide not to merge your pull request.

## Minimal reproducible example

Finally, please include a minimal reprex. The goal of a reprex is to make it as easy as possible for me to recreate your problem so that I can fix it. If you've never heard of a reprex before, start by reading <https://github.com/jennybc/reprex#what-is-a-reprex>, and follow the advice further down the page. Do NOT include session info unless it's explicitly asked for, or you've used `reprex::reprex(..., si = TRUE)` to hide it away.  Make sure to have `webshot` installed to have `reprex` produces images of the leaflet htmlwidgets.
```r
# make sure webshot is installed to take pictures of htmlwidgets
if (!("webshot" %in% installed.packages()[, "Package"])) {
  install.packages("webshot")
  # restart R process to fully integrate with knitr
}
reprex::reprex({
  library(leaflet)
  # insert reprex here
  leaflet() %>% addTiles()
})
```

Delete these instructions once you have read them.

---

Brief description of the solution

```r
# insert reprex here
```

PR task list:
- [ ] Update NEWS
- [ ] Add tests (where appropriate)
  - R code tests: `tests/testthat/`
  - Visual tests: `R/zzz_viztest.R`
- [ ] Update documentation with `devtools::document()`
