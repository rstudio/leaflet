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
  type = 'unknown'; extra = NULL; na.color = NULL
  formatNum = function(x) format(x, scientific = FALSE, big.mark = ',')

  if (!missing(pal)) {
    # a better default title when values is formula
    if (missing(title) && inherits(values, 'formula')) title = deparse(values[[2]])
    values = evalFormula(values, getMapData(map))

    type = attr(pal, 'colorType', exact = TRUE)
    args = attr(pal, 'colorArgs', exact = TRUE)
    na.color = args$na.color

    if (type == 'numeric' || type == 'bin') {

      if (type == 'numeric') n = bins else n = args$bins
      cuts = if (length(n) == 1) pretty(values, n = n) else n
      n = length(cuts)
      if (type == 'numeric') {
        r = range(values, na.rm = TRUE)
        cuts = cuts[cuts >= r[1] & cuts <= r[2]]
        n = length(cuts)
        p = (cuts - r[1]) / (r[2] - r[1])
        extra = c(
          (1 - p[1] / (p[2] - p[1])),  # top margin % of the color gradient span
          (n - 1) + (p[1] + 1 - p[n]) / (p[2] - p[1])  # height of color gradient
        ) / n
        p = c('', paste0(100 * p, '%'), '')
        colors = pal(c(r[1], cuts, r[2]))
        colors = paste(colors, p, sep = ' ', collapse = ', ')
        labels = formatNum(cuts)
      } else {
        mids = (cuts[-1] + cuts[-n]) / 2
        colors = pal(mids)
        labels = sprintf('%s &ndash; %s', formatNum(cuts[-n]), formatNum(cuts[-1]))
      }

    } else if (type == 'quantile') {

      p = args$probs
      n = length(p)
      cuts = quantile(values, probs = p, na.rm = TRUE)
      mids = quantile(values, probs = (p[-1] + p[-n]) / 2, na.rm = TRUE)
      colors = pal(mids)
      p = paste0(round(p * 100), '%')
      cuts = sprintf('%s &ndash; %s', formatNum(cuts[-n]), formatNum(cuts[-1]))
      labels = sprintf('<span title="%s">%s &ndash; %s</span>', cuts, p[-n], p[-1])

    } else if (type == 'factor') {

      v = unique(na.omit(values))
      colors = pal(v)
      labels = as.character(v)

    } else stop('Palette function not supported')

    labels = formatNum(labels)
    if (!any(is.na(values))) na.color = NULL
  }

  map$x$legend = list(
    colors = I(unname(colors)), labels = I(unname(labels)),
    na_color = na.color, na_label = na.label, opacity = opacity,
    position = position, type = type, title = title, extra = extra
  )
  map
}
