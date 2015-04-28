library(testit)
guessLL = guessLatLongCols  # just laziness

assert(
  'guessLatLongCols() guesses lat/long names',
  identical(guessLL(c('lat', 'lng')), list(lng = 'lng', lat = 'lat')),
  identical(guessLL(c('Lat', 'Lng')), list(lng = 'Lng', lat = 'Lat')),
  identical(guessLL(c('lat', 'long')), list(lng = 'long', lat = 'lat')),
  identical(guessLL(c('latitude', 'lng')), list(lng = 'lng', lat = 'latitude')),
  identical(guessLL(c('Latitude', 'Long')), list(lng = 'Long', lat = 'Latitude')),
  identical(suppressMessages(guessLL(c('Lat', 'lng', 'latt'))), list(lng = 'lng', lat = 'Lat')),
  identical(guessLL(c('Lat', 'foo'), stopOnFailure = FALSE), list(lng = NA, lat = NA)),
  TRUE
)

assert(
  'guessLatLongCols() stops by default if it is unable to figure out lat/lng names',
  has_error(guessLL(c('lat', 'foo'))),
  has_error(guessLL(c('lat', 'Lat', 'lng'))),
  has_error(guessLL(c('lat'))),
  has_error(guessLL(c('Lat', 'Long', 'latitude'))),
  TRUE
)
