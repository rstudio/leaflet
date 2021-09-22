library(R6)

# This class is copied from Shiny
Map <- R6Class(
  "Map",
  portable = FALSE,
  public = list(
    initialize = function() {
      private$env <- new.env(parent = emptyenv())
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
      rm(list = key, envir = env, inherits = FALSE)
      result
    },
    containsKey = function(key) {
      exists(key, envir = env, inherits = FALSE)
    },
    keys = function() {
      # Sadly, this is much faster than ls(), because it doesn't sort the keys.
      names(as.list(env, all.names = TRUE))
    },
    values = function() {
      as.list(env, all.names = TRUE)
    },
    clear = function() {
      private$env <- new.env(parent = emptyenv())
      invisible(NULL)
    },
    size = function() {
      length(env)
    }
  ),

  private = list(
    env = "environment"
  )
)


# This class is copied from Shiny
Callbacks <- R6Class(
  "Callbacks",
  portable = FALSE,
  class = FALSE,
  public = list(
    .nextId = integer(0),
    .callbacks = "Map",

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
    invoke = function(..., onError = NULL) {
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
      function() {
        # nothing
      }
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


test_that("mockSession tests", {
  testthat::local_edition(3)

  local <- leaflet()

  mockSession <- MockSession$new()
  remote <- leafletProxy("map", mockSession)

  remote %>% addPolygons(lng = 1:5, lat = 1:5)

  # Check that remote functions only get invoked after flush, by default
  # "Remote functions are only invoked after flush",
  expect_equal(mockSession$.calls, list())

  mockSession$.flush()

  expect_snapshot_output(mockSession$.calls)

  # Reset mock session
  mockSession$.calls <- list()

  # Create another remote map which doesn't wait until flush
  remote2 <- leafletProxy("map", mockSession,
    data.frame(lat = 10:1, lng = 10:1),
    deferUntilFlush = FALSE
  )
  # Check that addMarkers() takes effect immediately, no flush required
  remote2 %>% addMarkers()
  expect_snapshot_output(mockSession$.calls)
  beforeFlush <- mockSession$.calls
  # Flushing should do nothing
  mockSession$.flush()
  expect_identical(mockSession$.calls, beforeFlush)

  # Reset mock session
  mockSession$.calls <- list()

  remote3 <- leafletProxy("map", mockSession,
    data.frame(lat = 10:1, lng = 10:1)
  )
  remote3 %>% clearShapes() %>% addMarkers()
  expect_equal(mockSession$.calls, list())
  mockSession$.flush()
  expect_snapshot_output(mockSession$.calls)
})

test_that("leafletProxy with JS()", {
  testthat::local_edition(3)

  some_data <- data.frame(
    "lon"=c(4.905167,4.906357,4.905831),
    "lat"=c(52.37712,52.37783,52.37755),
    "number_var"=c(5,9,7),
    "name"=c("Jane","Harold","Mike"),
    stringsAsFactors = F
  )

  mockSession <- MockSession$new()
  remote <- leafletProxy("map", mockSession)
  remote %>% addMarkers(
    lng = some_data$lon,
    lat = some_data$lat,
    clusterOptions = markerClusterOptions(
      iconCreateFunction = JS(paste0("function(cluster) {",
        "console.log('Here comes cluster',cluster); ",
        "return new L.DivIcon({",
        "html: '<div style=\"background-color:rgba(77,77,77,0.5)\"><span>' + cluster.getChildCount() + '</div><span>',",
        "className: 'marker-cluster'",
        "});",
        "}"))
    )
  )
  mockSession$.flush()

  expect_snapshot_output(mockSession$.calls)
})
