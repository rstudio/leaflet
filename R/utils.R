# remove NULL elements from a list
filterNULL = function(x) {
  if (length(x) == 0 || !is.list(x)) return(x)
  x[!unlist(lapply(x, is.null))]
}

appendMapData = function(map, data, component, ...) {
  x = map$x[[component]]
  if (is.null(x)) x = list()
  n = length(x)
  x[[n + 1]] = evalFormula(list(...), data)
  map$x[[component]] = x
  map
}

makePolyList = function(lat, lng) {
  if (!identical(class(lat), class(lng)))
    stop("'lat' and 'lng' must be of the same class")
  if (is.list(lat) && is.list(lng)) return(list(lat = lat, lng = lng))
  if (!is.numeric(lat) || !is.numeric(lng))
    stop("Both 'lat' and 'lng' must be numeric vectors")
  i = is.na(lat) | is.na(lng)
  if (!any(i)) return(list(lat = list(lat), lng = list(lng)))
  chunks = cumsum(i)[!i]
  list(
    lat = unname(split(lat[!i], chunks)),
    lng = unname(split(lng[!i], chunks))
  )
}
