#' @export
addLegend = function(
  map, position = c('topright', 'bottomright', 'bottomleft', 'topleft'),
  pal, values, na.label = 'NA', bins = 7, colors, labels, title = deparse(substitute(values))
) {
  position = match.arg(position)
  type = 'unknown'; extra = NULL
  formatNum = function(x) format(x, scientific = FALSE, big.mark = ',')

  if (!missing(pal)) {

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
        labels = sprintf('- %s', formatNum(cuts))
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
    if (type != 'numeric' && any(is.na(values))) {
      colors = c(colors, na.color)
      labels = c(labels, na.label)
    }
  }

  map$x$legend = list(
    colors = I(unname(colors)), labels = I(unname(labels)),
    position = position, type = type, title = title, extra = extra
  )
  map
}
