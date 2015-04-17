#' @export
addLegend = function(
  map, position = c('topright', 'bottomright', 'bottomleft', 'topleft'),
  pal, values, na.label = 'NA', bins = 7, colors, labels
) {
  position = match.arg(position)
  formatNum = function(x) format(x, scientific = FALSE, big.mark = ',')
  cuts = NULL

  if (!missing(pal)) {

    type = attr(pal, 'colorType', exact = TRUE)
    args = attr(pal, 'colorArgs', exact = TRUE)
    na.color = args$na.color

    if (type == 'numeric' || type == 'bin') {

      if (type == 'numeric') n = bins else n = args$bins
      cuts = if (length(n) == 1) pretty(values, n = n) else n
      if (type == 'numeric') {
        r = range(values, na.rm = TRUE)
        cuts = cuts[cuts >= r[1] & cuts <= r[2]]
      }
      colors = pal(cuts)
      labels = cuts

    } else if (type == 'quantile') {

      p = args$probs
      n = length(p)
      cuts = quantile(values, probs = p, na.rm = TRUE)
      mids = quantile(values, probs = (p[-1] + p[-n]) / 2, na.rm = TRUE)
      colors = pal(mids)
      labels = mids

    } else if (type == 'factor') {

      v = unique(na.omit(values))
      colors = pal(v)
      labels = as.character(v)

    } else stop('Palette function not supported')
    labels = formatNum(labels)
    if (any(is.na(values))) {
      colors = c(colors, na.color)
      labels = c(labels, na.label)
    }
  }

  map$x$legend = list(
    colors = I(unname(colors)), labels = I(unname(labels)),
    cuts = I(unname(cuts)), position = position
  )
  map
}
