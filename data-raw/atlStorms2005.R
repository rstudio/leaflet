## code to prepare `atlStorms2005` dataset goes here
# legacy script

atlStorms2005 <- sf::st_as_sf(atlStorms2005)

usethis::use_data(atlStorms2005, overwrite = TRUE)
