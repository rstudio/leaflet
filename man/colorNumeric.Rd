% Please edit documentation in R/colors.R
\name{colorNumeric}
\alias{colorBin}
\alias{colorFactor}
\alias{colorNumeric}
\alias{colorQuantile}
\alias{palette}
\title{Color mapping}
\usage{
colorNumeric(palette, domain = NULL)

colorBin(palette, domain = NULL, bins = 7)

colorQuantile(palette, domain = NULL, probs = seq(0, 1, 0.25), type = 7, ...)

colorFactor(palette, domain = NULL, levels = NULL, ordered = FALSE)
}
\arguments{
\item{palette}{The colors or color function that values will be mapped to}

\item{domain}{The possible values that can be mapped. For \code{colorNumeric}
  and \code{colorBin}, this can be a simple numeric range (e.g. \code{c(0,
  100)}); \code{colorQuantile} needs representative numeric data; and
  \code{colorFactor} needs categorical data. If \code{NULL}, then whenever
  the resulting color function is called, the \code{x} value will represent
  the domain; note that if the domain is \code{NULL} and the function is
  invoked multiple times, the encoding between values and colors may not be
  consistent.}

\item{bins}{Either a numeric vector of two or more unique cut points or a
single number (greater than or equal to 2) giving the number of intervals
into which the domain values are to be cut.}

\item{probs, type, ...}{See \code{\link[stats]{quantile}}}

\item{levels}{An alternate way of specifying levels; if specified, domain is
ignored}

\item{ordered}{If \code{TRUE} and \code{domain} needs to be coerced to a
factor, treat it as already in the correct order}
}
\value{
A function that takes a single parameter \code{x}; when called with a
  vector of numbers (except for \code{colorFactor}, which expects
  factors/characters), #RRGGBB color strings are returned.
}
\description{
Conveniently maps data values (numeric or factor/character) to colors
according to a given palette, which can be provided in a variety of formats.
}
\details{
\code{colorNumeric} is a simple linear mapping from continuous numeric data
to an interpolated palette.

\code{colorBin} also maps continuous numeric data, but performs
  binning based on value (see the \code{\link[base]{cut}} function).

\code{colorQuantile} similarly bins numeric data, but via the
  \code{\link[stats]{quantile}} function.

\code{colorFactor} maps factors to colors. If the palette is
  discrete and has a different number of colors than the number of factors,
  interpolation is used.

The \code{palette} argument can be any of the following:
\enumerate{
  \item{A character vector of RGB or named colors. Examples: \code{palette()}, \code{c("#000000", "#0000FF", "#FFFFFF")}, \code{topo.colors(10)}}
  \item{The name of an RColorBrewer palette, prefixed with \code{"brewer:"}, e.g. \code{"brewer:BuPu"}.}
  \item{A function that receives a single value between 0 and 1 and returns a color. Examples: \code{colorRamp(c("#000000", "#FFFFFF"), interpolate="spline")}.}
}
}
