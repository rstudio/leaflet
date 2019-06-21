.onLoad <- function(libname, pkgname) {
  providers_info <- leaflet.providers::providers()

  providers <<- providers_info$providers
  providers.details <<- providers_info$providers_details
  providers.version_num <<- providers_info$version_num
  providers.src <<- providers_info$src
}
