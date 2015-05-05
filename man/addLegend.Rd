% Please edit documentation in R/legend.R
\name{addLegend}
\alias{addLegend}
\title{Add a color legend to a map}
\usage{
addLegend(map, position = c("topright", "bottomright", "bottomleft", "topleft"), 
    pal, values, na.label = "NA", bins = 7, colors, opacity = 0.5, labels, 
    title = deparse(substitute(values)))
}
\arguments{
\item{map}{a map widget object created from \code{\link{leaflet}()}}

\item{position}{the position of the legend}

\item{pal}{the color palette function, generated from
\code{\link{colorNumeric}()}, \code{colorBin()}, \code{colorQuantile()}, or
\code{colorFactor()}}

\item{values}{the values used to generate colors from the palette function}

\item{na.label}{the legend label for \code{NA}s in \code{values}}

\item{bins}{the (approximate) number of tick-marks on the color gradient for
the \code{colorNumeric} palette}

\item{colors}{a vector of (HTML) colors to be used in the legend if
\code{pal} is not provided}

\item{opacity}{the opacity of colors}

\item{labels}{a vector of text labels in the legend corresponding to
\code{colors}}

\item{title}{the legend title}
}
\description{
When a color palette function is used in a map (e.g.
\code{\link{colorNumeric}}), a color legend can be automatically derived from
the palette function. You can also manually specify the colors and labels for
the legend.
}
\examples{
library(leaflet)
# a manual legend
leaflet() \%>\% addTiles() \%>\% addLegend(
  position = 'bottomright',
  colors = rgb(t(col2rgb(palette())) / 255),
  labels = palette(), opacity = 1,
  title = 'An Obvious Legend'
)

# an automatic legend derived from the color palette
df = local({
  n = 300; x = rnorm(n); y = rnorm(n)
  z = sqrt(x^2 + y^2); z[sample(n, 10)] = NA
  data.frame(x, y, z)
})
pal = colorNumeric('OrRd', df$z)
leaflet(df) \%>\%
  addCircleMarkers(~x, ~y, color = ~pal(z)) \%>\%
  addLegend(pal = pal, values = ~z)
}
