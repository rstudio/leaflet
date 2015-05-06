% Please edit documentation in R/legend.R
\name{addLegend}
\alias{addLegend}
\title{Add a color legend to a map}
\usage{
addLegend(map, position = c("topright", "bottomright", "bottomleft", "topleft"), 
    pal, values, na.label = "NA", bins = 7, colors, opacity = 0.5, labels, labelFormat, 
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

\item{bins}{an approximate number of tick-marks on the color gradient for the
\code{colorNumeric} palette if it is of length one; you can also provide a
numeric vector as the pre-defined breaks (equally spaced)}

\item{colors}{a vector of (HTML) colors to be used in the legend if
\code{pal} is not provided}

\item{opacity}{the opacity of colors}

\item{labels}{a vector of text labels in the legend corresponding to
\code{colors}}

\item{labelFormat}{a function to format the labels derived from \code{pal}
and \code{values}}

\item{title}{the legend title}
}
\description{
When a color palette function is used in a map (e.g.
\code{\link{colorNumeric}}), a color legend can be automatically derived from
the palette function. You can also manually specify the colors and labels for
the legend.
}
\details{
The \code{labelFormat} argument is a function with different arguments for
different types of color palettes. For the \code{colorNumeric()} palette,
\code{labelFormat} takes a single argument, which is the breaks of the
numeric vector, and returns a character vector of the same length. For
\code{colorBin()}, \code{labelFormat} also takes a vector of breaks of length
\code{n} but should return a character vector of length \code{n - 1}, with
the \code{i}-th element representing the interval \code{c(x[i], x[i + 1])}.
For \code{colorQuantile}, \code{labelFormat} takes two arguments, the
quantiles and the associated probabilities (each of length \code{n}), and
should return a character vector of length \code{n - 1} (similar to the
\code{colorBin()} palette). For \code{colorFactor()}, \code{labelFormat}
takes one argument, the unique values of the factor, and should return a
character vector of the same length.

By default, \code{labelFormat} is basically \code{format(scientific = FALSE,
big.mark = ',')} for the numeric palette, \code{as.character()} for the
factor palette, and a function to return labels of the form \samp{x[i] - x[i
+ 1]} for bin and quantile palettes (in the case of quantile palettes,
\code{x} is the probabilities instead of the values of breaks).
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

# format legend labels
df = data.frame(x = rnorm(100), y = rexp(100, 2), z = runif(100))
pal = colorBin('PuOr', df$z, bins = c(0, .1, .4, .9, 1))
leaflet(df) \%>\%
  addCircleMarkers(~x, ~y, color = ~pal(z)) \%>\%
  addLegend(pal = pal, values = ~z)

leaflet(df) \%>\%
  addCircleMarkers(~x, ~y, color = ~pal(z)) \%>\%
  addLegend(pal = pal, values = ~z, labelFormat = function(cuts) {
    n = length(cuts)
    p = paste0(round(cuts * 100), '\%')
    paste(p[-n], p[-1], sep = ' - ')
  })
}
