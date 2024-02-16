#' @keywords internal
#' @aliases leaflet-package NULL
"_PACKAGE"

## usethis namespace: start
#' @importFrom grDevices col2rgb
#' @importFrom grDevices rgb
#' @importFrom htmlwidgets JS
#' @importFrom magrittr %>%
#' @importFrom methods substituteDirect
#' @importFrom stats na.omit
#' @importFrom stats quantile
#' @importFrom utils getFromNamespace
#' @importFrom utils packageVersion
## usethis namespace: end
NULL

## Re-exports
#' @export %>%
#' @export JS
NULL

# Added to the `use_release_issue()` checklist
release_bullets <- function() {
  c(
    "Update static imports: `staticimports::import()`",
    'Check Super Zip example: `shiny::runGitHub("rstudio/shiny-examples", subdir = "063-superzip-example")`',
    "Check licenses if bundled dependencies were updated",
    '`source("scripts/viztest.R")`'
  )
}
