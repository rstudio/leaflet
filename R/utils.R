# remove NULL elements from a list
filterNULL = function(x) {
  if (length(x) == 0 || !is.list(x)) return(x)
  x[!unlist(lapply(x, is.null))]
}

appendList = function(x, val) {
  if (is.null(x)) x = list()
  n = length(x)
  x[[n + 1]] = val
  x
}
