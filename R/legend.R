#' Add a color legend to a map
#'
#' When a color palette function is used in a map (e.g.
#' \code{\link{colorNumeric}}), a color legend can be automatically derived from
#' the palette function. You can also manually specify the colors and labels for
#' the legend.
#'
#' The \code{labFormat} argument is a function that takes the argument
#' \code{type = c("numeric", "bin", "quantile", "factor")}, plus, arguments for
#' different types of color palettes. For the \code{colorNumeric()} palette,
#' \code{labFormat} takes a single argument, which is the breaks of the numeric
#' vector, and returns a character vector of the same length. For
#' \code{colorBin()}, \code{labFormat} also takes a vector of breaks of length
#' \code{n} but should return a character vector of length \code{n - 1}, with
#' the \code{i}-th element representing the interval \code{c(x[i], x[i + 1])}.
#' For \code{colorQuantile}, \code{labFormat} takes two arguments, the quantiles
#' and the associated probabilities (each of length \code{n}), and should return
#' a character vector of length \code{n - 1} (similar to the \code{colorBin()}
#' palette). For \code{colorFactor()}, \code{labFormat} takes one argument, the
#' unique values of the factor, and should return a character vector of the same
#' length.
#'
#' By default, \code{labFormat} is basically \code{format(scientific = FALSE,
#' big.mark = ',')} for the numeric palette, \code{as.character()} for the
#' factor palette, and a function to return labels of the form \samp{x[i] - x[i
#' + 1]} for bin and quantile palettes (in the case of quantile palettes,
#' \code{x} is the probabilities instead of the values of breaks).
#' @inheritParams setView
#' @param position the position of the legend
#' @param pal the color palette function, generated from
#'   \code{\link{colorNumeric}()}, \code{colorBin()}, \code{colorQuantile()}, or
#'   \code{colorFactor()}
#' @param values the values used to generate colors from the palette function
#' @param na.label the legend label for \code{NA}s in \code{values}
#' @param bins an approximate number of tick-marks on the color gradient for the
#'   \code{colorNumeric} palette if it is of length one; you can also provide a
#'   numeric vector as the pre-defined breaks (equally spaced)
#' @param colors a vector of (HTML) colors to be used in the legend if
#'   \code{pal} is not provided
#' @param opacity the opacity of colors
#' @param labels a vector of text labels in the legend corresponding to
#'   \code{colors}
#' @param labFormat a function to format the labels derived from \code{pal} and
#'   \code{values} (see Details below to know what \code{labelFormat()} returns
#'   by default; you can either use the helper function \code{labelFormat()}, or
#'   write your own function)
#' @param title the legend title
#' @param controlId the ID of the legend; subsequent calls to \code{addLegend}
#'   or \code{addControl} with the same \code{controlId} will replace this
#'   legend. The ID can also be used with \code{removeControl}.
#' @example inst/examples/legend.R
#' @export
addLegend = function(
  map, position = c('topright', 'bottomright', 'bottomleft', 'topleft'),
  pal, values, na.label = 'NA', bins = 7, colors, opacity = 0.5, labels,
  labFormat = labelFormat(), title = deparse(substitute(values)),
  controlId = NULL
) {
  position = match.arg(position)
  type = 'unknown'; na.color = NULL
  extra = NULL  # only used for numeric palettes to store extra info

  if (!missing(pal)) {
    if (!missing(colors))
      stop("You must provide either 'pal' or 'colors' (not both)")

    # a better default title when values is formula
    if (missing(title) && inherits(values, 'formula')) title = deparse(values[[2]])
    values = evalFormula(values, getMapData(map))

    type = attr(pal, 'colorType', exact = TRUE)
    args = attr(pal, 'colorArgs', exact = TRUE)
    na.color = args$na.color
    if (type != 'numeric' && !missing(bins))
      warning("'bins' is ignored because the palette type is not numeric")

    if (type == 'numeric') {

      # choose pretty cut points to draw tick-marks on the color gradient if
      # 'bins' is the number of bins, otherwise 'bins' is just the breaks
      cuts = if (length(bins) == 1) pretty(values, n = bins) else bins
      if (length(bins) > 2)
        if (!all(abs(diff(bins, differences = 2)) <= sqrt(.Machine$double.eps)))
          stop("The vector of breaks 'bins' must be equally spaced")
      n = length(cuts)
      r = range(values, na.rm = TRUE)
      # pretty cut points may be out of the range of `values`
      cuts = cuts[cuts >= r[1] & cuts <= r[2]]
      n = length(cuts)
      p = (cuts - r[1]) / (r[2] - r[1])  # percents relative to min(values)

      # [    |       |       |  ...  |    ]
      # min  p1      p2      p3 ...  pn   max
      #  |   +   |   +   |   +  ...  +   |
      # here |+| denotes a table row, and there are n rows

      # first, we draw the "cuts" vector in a <table> column (with dashes in
      # front of labels); then, we draw the color gradient on the left of the
      # column in a <span>; finally, we adjust the height and top margin of the
      # <span> so that "cuts" points to the correct positions on the <span>
      extra = c(
        (.5 - p[1] / (p[2] - p[1])),  # top margin % of the color gradient span
        (n - 1) + (p[1] + 1 - p[n]) / (p[2] - p[1])  # height of color gradient
      ) / n
      # syntax for the color gradient: linear-gradient(start-color, color1 p1%,
      # color2 p2%, ..., colorn pn%, end-color])
      p = c('', paste0(100 * p, '%'), '')
      colors = pal(c(r[1], cuts, r[2]))
      colors = paste(colors, p, sep = ' ', collapse = ', ')
      labels = labFormat(type = 'numeric', cuts)

    } else if (type == 'bin') {

      cuts = args$bins
      n = length(cuts)
      # use middle points to represent intervals
      mids = (cuts[-1] + cuts[-n]) / 2
      colors = pal(mids)
      labels = labFormat(type = 'bin', cuts)

    } else if (type == 'quantile') {

      p = args$probs
      n = length(p)
      # the "middle points" in this case are the middle probabilities
      cuts = quantile(values, probs = p, na.rm = TRUE)
      mids = quantile(values, probs = (p[-1] + p[-n]) / 2, na.rm = TRUE)
      colors = pal(mids)
      labels = labFormat(type = 'quantile', cuts, p)

    } else if (type == 'factor') {

      v = unique(na.omit(values))
      colors = pal(v)
      labels = labFormat(type = 'factor', v)

    } else stop('Palette function not supported')

    if (!any(is.na(values))) na.color = NULL
  } else {
    if (length(colors) != length(labels))
      stop("'colors' and 'labels' must be of the same length")
  }

  legend = list(
    colors = I(unname(colors)), labels = I(unname(labels)),
    na_color = na.color, na_label = na.label, opacity = opacity,
    position = position, type = type, title = title, extra = extra,
    controlId = controlId
  )
  invokeMethod(map, getMapData(map), "addLegend", legend)
}

#' @param prefix a prefix of legend labels
#' @param suffix a suffix of legend labels
#' @param between a separator between \code{x[i]} and \code{x[i + 1]} in legend
#'   labels (by default, it is a dash)
#' @param digits the number of digits of numeric values in labels
#' @param big.mark the thousand separator
#' @param transform a function to transform the label value
#' @param type the type of the legend (will be automatically derived if missing)
#' @rdname addLegend
#' @export
labelFormat = function(
  prefix = '', suffix = '', between = ' &ndash; ', digits = 3, big.mark = ',',
  transform = identity
) {

  formatNum = function(x) {
    format(
      round(transform(x), digits), trim = TRUE, scientific = FALSE,
      big.mark = big.mark
    )
  }

  function(type, ...) {
    switch(
      type,
      numeric = (function(cuts) {
        paste0(prefix, formatNum(cuts), suffix)
      })(...),
      bin = (function(cuts) {
        n = length(cuts)
        paste0(prefix, formatNum(cuts[-n]), between, formatNum(cuts[-1]), suffix)
      })(...),
      quantile = (function(cuts, p) {
        n = length(cuts)
        p = paste0(round(p * 100), '%')
        cuts = paste0(formatNum(cuts[-n]), between, formatNum(cuts[-1]))
        # mouse over the legend labels to see the values (quantiles)
        paste0(
          '<span title="', cuts, '">', prefix, p[-n], between, p[-1], suffix,
          '</span>'
        )
      })(...),
      factor = (function(cuts) {
        paste0(prefix, as.character(transform(cuts)), suffix)
      })(...)
    )
  }

}
