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
#' @param stateName a unique name for the state
#' @seealso \code{\link{easyButton}}
#' @describeIn easyButton state of an easyButton.
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

#' Creates an easy button.
#' @seealso \url{https://github.com/CliffCloud/Leaflet.EasyButton}
#' @param icon the button icon
#' @param title text to show on hover
#' @param onClick the action to take
#' @param position topleft|topright|bottomleft|bottomright
#' @param id id for the button
#' @param states the states
#' @export
easyButton <- function(
  icon = NULL,
  title = NULL,
  onClick = NULL,
  position = "topleft",
  id = NULL,
  states = NULL
) {
  if(!missing(onClick) && !inherits(onClick,'JS_EVAL')) {
    stop("onClick needs to be a returned value from a JS() call")
  }
  if(!is.null(states) && ! (
    inherits(states,'list') &&
    all(sapply(states,function(x) inherits(x,'leaflet_easybutton_state'))))) {
    stop("states needs to be a list() of easyButton instances")
  }
  structure(filterNULL(list(
    icon = as.character(icon),
    title = as.character(title),
    onClick = onClick,
    position = position,
    id = id,
    states = states
  )),
      class='leaflet_easybutton')
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
#' @describeIn easyButton add an EasyButton to the map
#' @export
addEasyButton <- function(
  map,
  button
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
#' @param ... a list of buttons created with \code{\link{easyButton}}
#' @seealso \code{\link{addEasyButton}}
#' @examples
#' library(leaflet)
#'
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   addEasyButtonBar(
#'    easyButton(
#'      icon = htmltools::span(class='star','&starf;'),
#'      onClick = JS("function(btn, map){ alert('Button 1');}")),
#'    easyButton(
#'      icon = htmltools::span(class='star','&target;'),
#'      onClick = JS("function(btn, map){ alert('Button 2');}")))
#'
#'
#' @describeIn easyButton add an EasyButton to the map
#' @export
addEasyButtonBar <- function(
  map,
  ...,
  position = 'topleft',
  id = NULL
) {
  buttons <- list(...)
  if(!length(buttons) >= 1 ||
    !all(sapply(buttons,function(x) inherits(x,'leaflet_easybutton')))) {
    stop('need buttons created with easyButton()')
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
