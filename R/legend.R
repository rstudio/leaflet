#' Add a color legend to a map
#'
#' When a color palette function is used in a map (e.g.
#' \code{\link{colorNumeric}}), a color legend can be automatically derived from
#' the palette function. You can also manually specify the colors and labels for
#' the legend.
#' @inheritParams setView
#' @param position the position of the legend
#' @param pal the color palette function, generated from
#'   \code{\link{colorNumeric}()}, \code{colorBin()}, \code{colorQuantile()}, or
#'   \code{colorFactor()}
#' @param values the values used to generate colors from the palette function
#' @param na.label the legend label for \code{NA}s in \code{values}
#' @param bins the (approximate) number of tick-marks on the color gradient for
#'   the \code{colorNumeric} palette
#' @param colors a vector of (HTML) colors to be used in the legend if
#'   \code{pal} is not provided
#' @param opacity the opacity of colors
#' @param labels a vector of text labels in the legend corresponding to
#'   \code{colors}
#' @param title the legend title
#' @example inst/examples/legend.R
#' @export
addLegend = function(
  map, position = c('topright', 'bottomright', 'bottomleft', 'topleft'),
  pal, values, na.label = 'NA', bins = 7, colors, opacity = 0.5, labels,
  title = deparse(substitute(values))
) {
  position = match.arg(position)
  type = 'unknown'; na.color = NULL
  extra = NULL  # only used for numeric palettes to store extra info
  formatNum = function(x) format(x, scientific = FALSE, big.mark = ',')

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

      # choose pretty cut points to draw tick-marks on the color gradient
      cuts = pretty(values, n = bins)
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
      labels = formatNum(cuts)

    } else if (type == 'bin') {

      cuts = args$bins
      n = length(cuts)
      # use middle points to represent intervals
      mids = (cuts[-1] + cuts[-n]) / 2
      colors = pal(mids)
      labels = sprintf('%s &ndash; %s', formatNum(cuts[-n]), formatNum(cuts[-1]))

    } else if (type == 'quantile') {

      p = args$probs
      n = length(p)
      # the "middle points" in this case are the middle probabilities
      cuts = quantile(values, probs = p, na.rm = TRUE)
      mids = quantile(values, probs = (p[-1] + p[-n]) / 2, na.rm = TRUE)
      colors = pal(mids)
      p = paste0(round(p * 100), '%')
      cuts = sprintf('%s &ndash; %s', formatNum(cuts[-n]), formatNum(cuts[-1]))
      # mouse over the legend labels to see the values (quantiles)
      labels = sprintf('<span title="%s">%s &ndash; %s</span>', cuts, p[-n], p[-1])

    } else if (type == 'factor') {

      v = unique(na.omit(values))
      colors = pal(v)
      labels = as.character(v)

    } else stop('Palette function not supported')

    labels = formatNum(labels)
    if (!any(is.na(values))) na.color = NULL
  } else {
    if (length(colors) != length(labels))
      stop("'colors' and 'labels' must be of the same length")
  }

  map$x$legend = list(
    colors = I(unname(colors)), labels = I(unname(labels)),
    na_color = na.color, na_label = na.label, opacity = opacity,
    position = position, type = type, title = title, extra = extra
  )
  map
}