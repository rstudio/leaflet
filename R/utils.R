# remove NULL elements from a list
filterNULL = function(x) {
  if (length(x) == 0 || !is.list(x)) return(x)
  x[!unlist(lapply(x, is.null))]
}

appendMapData = function(map, component, ...) {
  x = map$x[[component]]
  if (is.null(x)) x = list()
  n = length(x)
  x[[n + 1]] = evalFormula(list(...), map)
  map$x[[component]] = x
  map
}
