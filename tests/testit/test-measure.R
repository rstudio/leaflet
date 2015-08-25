library(testit)

# did the dependency get added?
assert(
  !is.na(Position(
    function(dep) dep$name == "leaflet-measure"
    , addMeasure(leaflet())$dependencies
  ))
)

# did the call get added?
assert(
  !is.na(Position(
    function(cl) cl$method == "addMeasure"
    , addMeasure(leaflet())$x$calls
  ))
)

# were options added as expected
assert(
  Filter(
    function(cl) cl$method == "addMeasure"
    , addMeasure(leaflet(), position = "bottomleft")$x$calls
  )[[1]]$args[[1]]$position == "bottomleft"
)

# are null options removed
# were options added as expected
assert(
  !("position" %in% names(Filter(
    function(cl) cl$method == "addMeasure"
    , addMeasure(leaflet(), position = NULL )$x$calls
  )[[1]]$args[[1]]))
)
