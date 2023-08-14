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

release_bullets <- function() {
  c(
    "Update static imports: `staticimports::import()`",
    "`system(\"npm run build\")`",
    "Rebuild website: `source(\"scripts/docs_update.R\")",
    'Check Super Zip example: `shiny::runGitHub("rstudio/shiny-examples", subdir = "063-superzip-example")`',
    "Check licenses if bundled dependencies were updated",
    '`source("scripts/viztest.R")`'
  )
}
