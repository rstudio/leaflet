#' Visual Testing scripts for vistest
#'
#' Visual testing examples to be used by the vistest package.
#'
#' @name zzz-test-viztest
#' @rdname zzz-test-viztest
#' @examples
#'
#'
#'
#' \donttest{
#' ## Helper function to load extra libraries
#' library_ <- function(...) {
#'   pkg <- as.character(substitute(...))
#'   pkgDesc <- base::suppressWarnings(utils::packageDescription(pkg))
#'   if (identical(pkgDesc, NA)) {
#'     install.packages(pkg)
#'   }
#'   base::library(pkg, character.only = TRUE)
#' }
#'
#'
#'
#' ##
#' library_(leaflet)
#'
#' polygon = list(
#'   type = "Polygon",
#'   coordinates = list(
#'     list(
#'       c(8.330469, 48.261570),
#'       c(8.339052, 48.261570),
#'       c(8.339052, 48.258227),
#'       c(8.330469, 48.258227),
#'       c(8.330469, 48.261570)
#'     )
#'   )
#' )
#'
#' # should produce an orange-ish rectangle around `Ramsel`
#' leaflet() %>%
#'   addTiles() %>%
#'   addGeoJSON(polygon, color="#F00") %>%
#'   setView(lng = 8.330469, lat = 48.26157, zoom = 15)
#'
#'
#' } # end donttest
NULL
