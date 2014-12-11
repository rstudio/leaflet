# remove NULL elements from a list
filterNULL = function(x) {
  if (length(x) == 0 || !is.list(x)) return(x)
  x[!unlist(lapply(x, is.null))]
}

appendMapData = function(map, data, component, ...) {
  x = map$x$calls
  if (is.null(x)) x = list()
  n = length(x)
  x[[n + 1]] = list(
    method = component,
    args = evalFormula(list(...), data)
  )
  map$x$calls = x
  map
}
