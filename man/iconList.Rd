% Please edit documentation in R/layers.R
\name{iconList}
\alias{iconList}
\title{Create a list of icons}
\usage{
iconList(iconUrl = NULL, iconRetinaUrl = NULL, iconSize = NULL, iconAnchor = NULL, 
    shadowUrl = NULL, shadowRetinaUrl = NULL, shadowSize = NULL, shadowAnchor = NULL, 
    popupAnchor = NULL, className = NULL, embed = TRUE)
}
\arguments{
\item{iconUrl}{the URL to the icon image}

\item{iconRetinaUrl}{the URL to a retina sized version of the icon image}

\item{iconSize}{size of the icon image in pixels}

\item{iconAnchor}{the coordinates of the "tip" of the icon (relative to its
top left corner, i.e. the top left corner means \code{iconAnchor = c(0,
0)}), and the icon will be aligned so that this point is at the marker's
geographical location}

\item{shadowUrl}{the URL to the icon shadow image}

\item{shadowRetinaUrl}{the URL to the retina sized version of the icon shadow
image}

\item{shadowSize}{size of the shadow image in pixels}

\item{shadowAnchor}{the coordinates of the "tip" of the shadow}

\item{popupAnchor}{the coordinates of the point from which popups will
"open", relative to the icon anchor}

\item{className}{a custom class name to assign to both icon and shadow images}

\item{embed}{whether to base64 encode local image files}
}
\value{
A list of icon data that can be passed to the \code{icon} argument of
  \code{\link{addMarkers}()}.
}
\description{
An icon can be represented as a list of the form \code{list(iconUrl,
iconSize, ...)}. This function is vectorized over its arguments to create a
list of icons. See \url{http://leafletjs.com/reference.html#icon} for the
possible attributes of icons.
}
\details{
Note some icon attributes are of length 2, such as \code{iconSize} and
\code{iconAnchor}, and you have to make sure they are lists of vectors of
length 2, e.g. \code{iconSize = list(c(20, 40))} if all icons use the same
size, or \code{iconSize = list(c(20, 40), c(30, 80))} if the first icon size
is 20 x 40, and the second icon size is 30 x 80. Since \code{\link{mapply}()}
is applied to these arguments, shorter argument values will be re-cycled.
\code{NULL} values for these arguments will be ignored.
}
\note{
The argument \code{embed = TRUE} can be useful when you render the map
  in a static HTML document and you want it to be self-contained (i.e. no
  external image dependencies). If you are sure that the icon images will
  always be available along with the HTML document, it is not necessary to
  encode them. When using the icons in Shiny, you may (pre-)render the icon
  images under the \file{www} directory of the app, and use them without
  base64 encoding them, e.g. you can use an icon \file{www/foo.png} by
  \code{iconList(iconUrl = 'foo.png', embed = FALSE)} (note there is no
  \samp{www} prefix in the icon URL).
}
\examples{
library(leaflet)

# adapted from http://leafletjs.com/examples/custom-icons.html

iconData = data.frame(
  lat = c(rnorm(10, 0), rnorm(10, 1), rnorm(10, 2)),
  lng = c(rnorm(10, 0), rnorm(10, 3), rnorm(10, 6)),
  group = rep(sort(c('green', 'red', 'orange')), each = 10),
  stringsAsFactors = FALSE
)

leaflet() \%>\% addMarkers(
  data = iconData,
  icon = ~ iconList(
    iconUrl = sprintf('http://leafletjs.com/docs/images/leaf-\%s.png', group),
    shadowUrl = 'http://leafletjs.com/docs/images/leaf-shadow.png',
    iconSize = list(c(38, 95)), shadowSize = list(c(50, 64)),
    iconAnchor = list(c(22, 94)), shadowAnchor = list(c(4, 62)),
    popupAnchor = list(c(-3, -76))
  )
)


# use point symbols from base R graphics as icons
pchIcons = function(pch = 0:14, width = 30, height = 30, ...) {
  n = length(pch)
  files = character(n)
  # create a sequence of png images
  for (i in seq_len(n)) {
    f = tempfile()
    png(f, width = width, height = height, bg = 'transparent')
    par(mar = c(0, 0, 0, 0))
    plot.new()
    points(.5, .5, pch = pch[i], cex = min(width, height) / 8, ...)
    dev.off()
    files[i] = f
  }
  files
}

iconData = matrix(rnorm(500), ncol = 2)
res = kmeans(iconData, 10)
iconData = cbind(iconData, res$cluster)
colnames(iconData) = c('lat', 'lng', 'group')
iconData = as.data.frame(iconData)

# 10 random point shapes for the 10 clusters in iconData
shapes = sample(0:14, 10)
iconFiles = pchIcons(shapes, 40, 40, col = 'steelblue', lwd = 2)

# note the data has 250 rows, and the icon list is of length 10; they are
# connected by the `group` variable: the i-th row of iconData uses the
# group[i]-th icon in the icon list
leaflet() \%>\% addMarkers(
  data = iconData,
  icon = iconList(
    iconUrl = iconFiles,
    popupAnchor = list(c(20, 0))
  ),
  iconGroup = ~ group,
  popup = ~ sprintf(
    'lat = \%.4f, long = \%.4f, group = \%s, pch = \%s', lat, lng, group, shapes[group]
  )
)

unlink(iconFiles)  # clean up the tmp png files that have been embedded
}
