library(testit)
library(R6)

# This class is copied from Shiny
Map <- R6Class(
  'Map',
  portable = FALSE,
  public = list(
    initialize = function() {
      private$env <- new.env(parent=emptyenv())
    },
    get = function(key) {
      env[[key]]
    },
    set = function(key, value) {
      env[[key]] <- value
      value
    },
    mget = function(keys) {
      base::mget(keys, env)
    },
    mset = function(...) {
      args <- list(...)
      if (length(args) == 0)
        return()

      arg_names <- names(args)
      if (is.null(arg_names) || any(!nzchar(arg_names)))
        stop("All elements must be named")

      list2env(args, envir = env)
    },
    remove = function(key) {
      if (!self$containsKey(key))
        return(NULL)

      result <- env[[key]]
      rm(list=key, envir=env, inherits=FALSE)
      result
    },
    containsKey = function(key) {
      exists(key, envir=env, inherits=FALSE)
    },
    keys = function() {
      # Sadly, this is much faster than ls(), because it doesn't sort the keys.
      names(as.list(env, all.names=TRUE))
    },
    values = function() {
      as.list(env, all.names=TRUE)
    },
    clear = function() {
      private$env <- new.env(parent=emptyenv())
      invisible(NULL)
    },
    size = function() {
      length(env)
    }
  ),

  private = list(
    env = 'environment'
  )
)


# This class is copied from Shiny
Callbacks <- R6Class(
  'Callbacks',
  portable = FALSE,
  class = FALSE,
  public = list(
    .nextId = integer(0),
    .callbacks = 'Map',

    initialize = function() {
      .nextId <<- as.integer(.Machine$integer.max)
      .callbacks <<- Map$new()
    },
    register = function(callback) {
      id <- as.character(.nextId)
      .nextId <<- .nextId - 1L
      .callbacks$set(id, callback)
      return(function() {
        .callbacks$remove(id)
      })
    },
    invoke = function(..., onError=NULL) {
      # Ensure that calls are invoked in the order that they were registered
      keys <- as.character(sort(as.integer(.callbacks$keys()), decreasing = TRUE))
      callbacks <- .callbacks$mget(keys)

      for (callback in callbacks) {
        if (is.null(onError)) {
          callback(...)
        } else {
          tryCatch(callback(...), error = onError)
        }
      }
    },
    count = function() {
      .callbacks$size()
    }
  )
)


MockSession <- R6Class("MockSession",
  public = list(
    initialize = function() {
      self$token <- shiny:::createUniqueId(8)
    },
    sendCustomMessage = function(type, message) {
      self$.calls <- c(self$.calls, list(list(
        type = type,
        message = shiny:::toJSON(message)
      )))
    },
    onFlushed = function(func, once = TRUE) {
      unregister <- private$flushCallbacks$register(function(...) {
        func(...)
        if (once)
          unregister()
      })
    },
    onSessionEnded = function(func) {
      function() {}
    },
    token = 0,
    .flush = function() {
      private$flushCallbacks$invoke()
    },
    .calls = list()
  ),
  private = list(
    flushCallbacks = Callbacks$new()
  )
)


local <- leaflet()

mockSession <- MockSession$new()
remote <- leafletProxy("map", mockSession)

remote %>% addPolygons(lng=1:5, lat=1:5)

# Check that remote functions only get invoked after flush, by default
assert(
  "Remote functions are only invoked after flush",
  identical(mockSession$.calls, list())
)
mockSession$.flush()
expected <- list(
  list(type = "leaflet-calls", message = structure("{\"id\":\"map\",\"calls\":[{\"dependencies\":[],\"method\":\"addPolygons\",\"args\":[[[{\"lng\":[1,2,3,4,5],\"lat\":[1,2,3,4,5]}]],null,null,{\"lineCap\":null,\"lineJoin\":null,\"clickable\":true,\"pointerEvents\":null,\"className\":\"\",\"stroke\":true,\"color\":\"#03F\",\"weight\":5,\"opacity\":0.5,\"fill\":true,\"fillColor\":\"#03F\",\"fillOpacity\":0.2,\"dashArray\":null,\"smoothFactor\":1,\"noClip\":false},null]}]}", class = "json"))
)
# cat(deparse(mockSession$.calls), "\n")
assert(identical(mockSession$.calls, expected))


# Reset mock session
mockSession$.calls <- list()

# Create another remote map which doesn't wait until flush
remote2 <- leafletProxy("map", mockSession,
  data.frame(lat=10:1, lng=10:1),
  deferUntilFlush = FALSE
)
# Check that addMarkers() takes effect immediately, no flush required
remote2 %>% addMarkers()
expected2 <- list(structure(list(type = "leaflet-calls", message = structure("{\"id\":\"map\",\"calls\":[{\"dependencies\":[],\"method\":\"addMarkers\",\"args\":[[10,9,8,7,6,5,4,3,2,1],[10,9,8,7,6,5,4,3,2,1],null,null,null,{\"clickable\":true,\"draggable\":false,\"keyboard\":true,\"title\":\"\",\"alt\":\"\",\"zIndexOffset\":0,\"opacity\":1,\"riseOnHover\":false,\"riseOffset\":250},null,null,null]}]}", class = "json")), .Names = c("type",  "message")))
# cat(deparse(mockSession$.calls), "\n")
assert(identical(mockSession$.calls, expected2))
# Flushing should do nothing
mockSession$.flush()
# cat(deparse(mockSession$.calls), "\n")
assert(identical(mockSession$.calls, expected2))

# Reset mock session
mockSession$.calls <- list()

remote3 <- leafletProxy("map", mockSession,
  data.frame(lat=10:1, lng=10:1)
)
remote3 %>% clearShapes() %>% addMarkers()
assert(identical(mockSession$.calls, list()))
mockSession$.flush()
expected3 <- list(structure(list(type = "leaflet-calls", message = structure("{\"id\":\"map\",\"calls\":[{\"dependencies\":[],\"method\":\"clearShapes\",\"args\":[]}]}", class = "json")), .Names = c("type",  "message")), structure(list(type = "leaflet-calls", message = structure("{\"id\":\"map\",\"calls\":[{\"dependencies\":[],\"method\":\"addMarkers\",\"args\":[[10,9,8,7,6,5,4,3,2,1],[10,9,8,7,6,5,4,3,2,1],null,null,null,{\"clickable\":true,\"draggable\":false,\"keyboard\":true,\"title\":\"\",\"alt\":\"\",\"zIndexOffset\":0,\"opacity\":1,\"riseOnHover\":false,\"riseOffset\":250},null,null,null]}]}", class = "json")), .Names = c("type",  "message")))
# Check that multiple calls are invoked in order
assert(identical(mockSession$.calls, expected3))
