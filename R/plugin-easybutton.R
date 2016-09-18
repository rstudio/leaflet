leafletEasyButtonDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-easybutton",
      "1.3.1",
      system.file("htmlwidgets/plugins/Leaflet.EasyButton", package = "leaflet"),
      script = c("easy-button.js", "EasyButton-binding.js"),
      stylesheet = c('easy-button.css')
    )
  )
}

#' Create an easyButton statestate
#' @param stateName the name of the state
#' @param icon the button icon
#' @param title text to show on hover
#' @param onClick the action to take
#' @export
easyButtonState <- function(
   stateName,
   icon,
   title,
   onClick
) {
  if(!inherits(onClick,'JS_EVAL')) {
    stop("onClick needs to be a returned value from a JS() call")
  }
  structure(list(
    stateName = as.character(stateName),
    icon = as.character(icon),
    title = as.character(title),
    onClick = onClick
  ),
      class='leaflet_easybutton_state')
}

#' Create a list of easyButton states.
#' @param ... states created from \code{\link{easyButtonState}()}
#' @export
easyButtonStateList <- function(...) {
  res = structure(
    list(...),
    class = "leaflet_easybutton_state_list"
  )
  cls = unlist(lapply(res, inherits, 'leaflet_easybutton_state'))
  if (any(!cls))
    stop('Arguments passed to easyButtonStateList() must be icon objects returned from easyButtonState()')
  res
}

#' Creates an easy button.
#' see \url{https://github.com/CliffCloud/Leaflet.EasyButton}
#' @param icon the button icon
#' @param title text to show on hover
#' @param onClick the action to take
#' @param position topleft|topright|bottomleft|bottomright
#' @param id id for the button
#' @param states the states
#' @export
easyButton <- function(
  icon = htmltools::span(class='easy-button','•'),
  title = "Easy Button",
  onClick = JS("function(btn, map){alert('That was easy!');}"),
  position = "topleft",
  id = NULL,
  states = NULL
) {
  if(!inherits(onClick,'JS_EVAL')) {
    stop("onClick needs to be a returned value from a JS() call")
  }
  if(!is.null(states) && !inherits(states,'leaflet_easybutton_state_list')) {
    stop("states needs to be a returned value from a easyButtonStateList() call")
  }
  structure(list(
    icon = as.character(icon),
    title = as.character(title),
    onClick = onClick,
    position = position,
    id = id,
    states = states
  ),
      class='leaflet_easybutton')
}

#' Creates a list of easy buttons.
#' @param ... icons created from \code{\link{easyButton}()}
#' @export
easyButtonList = function(...) {
  res = structure(
    list(...),
    class = "leaflet_easybutton_list"
  )
  cls = unlist(lapply(res, inherits, 'leaflet_easybutton'))
  if (any(!cls))
    stop('Arguments passed to easyButtonList() must be icon objects returned from easyButton()')
  res
}

#' Add a EasyButton on the map
#' see \url{https://github.com/CliffCloud/Leaflet.EasyButton}
#'
#' @param map a map widget object
#' @param button the button object created with \code{\link{easyButton}}
#' @examples
#' library(leaflet)
#'
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   addEasyButton(easyButton(
#'      icon = htmltools::span(class='star','&starf;'),
#'      onClick = JS("function(btn, map){ map.setZoom(1);}")))
#'
#' @export
addEasyButton <- function(
  map,
  button = easyButton()
) {

  if(!inherits(button,'leaflet_easybutton')) {
    stop('button should be created with easyButton()')
  }

  map$dependencies <- c(map$dependencies, leafletEasyButtonDependencies())

  # Add dependencies for various icon libs if required.
  if(is.null(button$states)) {
    if(grepl('fa-',button$icon))
      map$dependencies <- c(map$dependencies, leafletAmFontAwesomeDependencies())
    if(grepl('glyphicon-',button$icon))
      map$dependencies <- c(map$dependencies, leafletAmBootstrapDependencies())
    if(grepl('ion-',button$icon))
      map$dependencies <- c(map$dependencies, leafletAmIonIconDependencies())
  } else {
    if(any(sapply(button$states,function(x) grepl('fa-',x$icon))))
      map$dependencies <- c(map$dependencies, leafletAmFontAwesomeDependencies())
    if(any(sapply(button$states,function(x) grepl('glyphicon-',x$icon))))
      map$dependencies <- c(map$dependencies, leafletAmBootstrapDependencies())
    if(any(sapply(button$states,function(x) grepl('ion-',x$icon))))
      map$dependencies <- c(map$dependencies, leafletAmIonIconDependencies())
  }

  invokeMethod(
    map,
    getMapData(map),
    'addEasyButton',
    button
  )
}

#' Add a easyButton bar on the map
#' see \url{https://github.com/CliffCloud/Leaflet.EasyButton}
#'
#' @param map a map widget object
#' @param buttons the buttons object created with \code{\link{easyButtonList}}
#' @param position topleft|topright|bottomleft|bottomright
#' @param id id for the button bar
#' @examples
#' library(leaflet)
#'
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   addEasyButtonBar(easyButtonList(
#'    easyButton(
#'      icon = htmltools::span(class='star','&starf;'),
#'      onClick = JS("function(btn, map){ alert("Button 1");}")),
#'    easyButton(
#'      icon = htmltools::span(class='star','&target;'),
#'      onClick = JS("function(btn, map){ alert("Button 2");}"))))
#'
#'
#' @export
addEasyButtonBar <- function(
  map,
  buttons,
  position = 'topleft',
  id = NULL
) {
  if(!inherits(buttons,'leaflet_easybutton_list')) {
    stop('button should be created with easyButtonList()')
  }

  map$dependencies <- c(map$dependencies, leafletEasyButtonDependencies())

  # Add dependencies for various icon libs if required.
  for(button in buttons) {
    if(is.null(button$states)) {
      if(grepl('fa-',button$icon))
        map$dependencies <- c(map$dependencies, leafletAmFontAwesomeDependencies())
      if(grepl('glyphicon-',button$icon))
        map$dependencies <- c(map$dependencies, leafletAmBootstrapDependencies())
      if(grepl('ion-',button$icon))
        map$dependencies <- c(map$dependencies, leafletAmIonIconDependencies())
    } else {
      if(any(sapply(button$states,function(x) grepl('fa-',x$icon))))
        map$dependencies <- c(map$dependencies, leafletAmFontAwesomeDependencies())
      if(any(sapply(button$states,function(x) grepl('glyphicon-',x$icon))))
        map$dependencies <- c(map$dependencies, leafletAmBootstrapDependencies())
      if(any(sapply(button$states,function(x) grepl('ion-',x$icon))))
        map$dependencies <- c(map$dependencies, leafletAmIonIconDependencies())
    }
  }

  invokeMethod(
    map,
    getMapData(map),
    'addEasyButtonBar',
    buttons,
    position,
    id
  )
}

