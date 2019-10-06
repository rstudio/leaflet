leaflet_envir <- environment()
.onLoad <- function(...) {
  makeActiveBinding("providers", function() {
    leaflet.providers::providers_loaded()$providers
  }, env = leaflet_envir)

  makeActiveBinding("providers.details", function() {
    leaflet.providers::providers_loaded()$providers_details
  }, env = leaflet_envir)

  makeActiveBinding("providers.version_num", function() {
    leaflet.providers::providers_loaded()$version_num
  }, env = leaflet_envir)

  makeActiveBinding("providers.src", function() {
    leaflet.providers::providers_loaded()$src
  }, env = leaflet_envir)
}
