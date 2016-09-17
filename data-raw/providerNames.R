# The JSON was extracted and fixed from ...
# https://github.com/leaflet-extras/leaflet-providers/blob/master/leaflet-providers.js

providers.details <- jsonlite::fromJSON(
  './inst/htmlwidgets/lib/leaflet-providers/providers.json')

variants <- purrr::map(providers.details, ~ names(.$variants))

providers <- purrr::map(names(providers.details), function(provider) {
  if(is.null(variants[[provider]])) {
    provider
  } else {
    c(provider, stringr::str_c(provider,'.',variants[[provider]]))
  }
}) %>% purrr::flatten_chr()

providers <- setNames(as.list(providers), providers)

devtools::use_data(providers.details, overwrite = TRUE)
devtools::use_data(providers, overwrite = TRUE)


