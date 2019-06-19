.onLoad <- function(libname, pkgname) {
  providers <<- leaflet.providers::providers()$providers
  providers.details <<- leaflet.providers::providers()$providers_details
  providers.version_num <<- leaflet.providers::providers()$version_num
}
