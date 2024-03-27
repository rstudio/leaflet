Please briefly describe your problem and what output you expect. If you have a question, please try using StackOverflow <https://stackoverflow.com> first.

Please include a minimal reprex. The goal of a reprex is to make it as easy as possible for me to recreate your problem so that I can fix it. If you've never heard of a reprex before, start by reading <https://reprex.tidyverse.org/>, and follow the advice further down the page. Do NOT include session info unless it's explicitly asked for, or you've used `reprex::reprex(..., session_info = TRUE)` to hide it away.  Make sure to have `webshot` installed to have `reprex` produces images of the leaflet htmlwidgets.
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

Brief description of the problem

```r
library(leaflet)
# insert reprex here
leaflet() %>% addTiles()
```
