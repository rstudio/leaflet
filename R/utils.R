dispatch = function(map,
  local = stop("Operation requires a map proxy object"),
  remote = stop("Operation does not support map proxy objects")
) {
  if (inherits(map, "leaflet"))
    return(local)
  else if (inherits(map, "leaflet_remote"))
    return(remote)
  else
    stop("Invalid map parameter")
}

# remove NULL elements from a list
filterNULL = function(x) {
  if (length(x) == 0 || !is.list(x)) return(x)
  x[!unlist(lapply(x, is.null))]
}

appendMapData = function(map, data, component, ...) {
  method = component
  args = evalFormula(list(...), data)

  dispatch(map,
    local = {
      x = map$x$calls
      if (is.null(x)) x = list()
      n = length(x)
      x[[n + 1]] = list(method = component, args = args)
      map$x$calls = x
      map
    },
    remote = {
      invokeRemote(map, method, args)
      map
    }
  )
}

#' @export
getMapProxy <- function(mapId, session = shiny::getDefaultReactiveDomain(),
  data = NULL) {
  structure(
    list(
      session = session,
      id = mapId,
      x = structure(
        list(),
        leafletData = data
      )
    ),
    class = "leaflet_remote"
  )
}

invokeRemote = function(map, method, args = list()) {
  if (!inherits(map, "leaflet_remote"))
    stop("Invalid map parameter; map proxy object was expected")

  map$session$sendCustomMessage("leaflet-calls", list(
    id = map$id,
    calls = list(
      list(
        method = method,
        args = args
      )
    )
  ))
}

# A helper function to generate the body of function(x, y) list(x = x, y = y),
# to save some typing efforts in writing tileOptions(), markerOptions(), ...
makeListFun = function(list) {
  if (is.function(list)) list = formals(list)
  nms = names(list)
  cat(sprintf('list(%s)\n', paste(nms, nms, sep = ' = ', collapse = ', ')))
}

"%||%" = function(a, b) {
  if (!is.null(a)) a else b
}
