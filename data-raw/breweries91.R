## code to prepare `breweries91` dataset goes here
# legacy script
breweries91 <- sf::st_as_sf(breweries91)
usethis::use_data(breweries91, overwrite = TRUE)
