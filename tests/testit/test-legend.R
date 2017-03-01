library(testit)

df = data.frame(x1 = 1:3, x2 = 1:3, x3 = 1:3, x4 = factor(1:3))
map = leaflet(df)
pal1 = colorNumeric('RdBu', df$x1)
pal2 = colorBin('RdBu', df$x2)
pal3 = colorQuantile('BuGn', df$x3)
pal4 = colorFactor('Dark2', df$x4)

# test syntax
assert(
  # either pal or colors, but not both
  has_error(addLegend(map, pal = pal1, colors = '#ffffff')),
  # values missing when pal is provided
  has_error(addLegend(map, pal = pal1)),
  # bins is provided when pal is not numeric
  has_warning(addLegend(map, pal = pal2, values = ~x2, bins = 10)),
  # colors provided, but labels missing
  has_error(addLegend(map, colors = '#ffffff')),
  # colors and labels not of the same length
  has_error(addLegend(map, colors = '#ffffff', labels = c('a', 'b')))
)

getLastLegend = function(map) {
  tail(map$x$calls, 1)[[1]]$args[[1]]
}

# automatic legends
m1 = addLegend(map, pal = pal1, values = ~x1)
l1 = getLastLegend(m1)
assert(
  l1$colors == "#67001F , #67001F 0%, #E68367 25%, #F7F7F7 50%, #6EACD1 75%, #053061 100%, #053061 ",
  l1$labels == c('1.0', '1.5', '2.0', '2.5', '3.0'),
  l1$type == 'numeric'
)

m2 = addLegend(map, pal = pal2, values = ~x2)
l2 = getLastLegend(m2)
assert(
  l2$colors == c("#CA0020", "#F4A582", "#92C5DE", "#0571B0"),
  l2$labels == c('1.0 &ndash; 1.5', '1.5 &ndash; 2.0', '2.0 &ndash; 2.5', '2.5 &ndash; 3.0'),
  l2$type == 'bin'
)

m3 = addLegend(map, pal = pal3, values = ~x3)
l3 = getLastLegend(m3)
assert(
  l3$colors == c("#EDF8FB", "#B2E2E2", "#66C2A4", "#238B45"),
  l3$labels == c(
    '<span title="1.0 &ndash; 1.5">0% &ndash; 25%</span>',
    '<span title="1.5 &ndash; 2.0">25% &ndash; 50%</span>',
    '<span title="2.0 &ndash; 2.5">50% &ndash; 75%</span>',
    '<span title="2.5 &ndash; 3.0">75% &ndash; 100%</span>'
  ),
  l3$type == 'quantile'
)

m4 = addLegend(map, pal = pal4, values = ~x4)
l4 = getLastLegend(m4)
assert(
  l4$colors == c("#1B9E77", "#D95F02", "#7570B3"),
  l4$labels == as.character(df$x4),
  l4$type == 'factor'
)

# manual legends
m5 = addLegend(map, colors = palette(), labels = palette())
l5 = getLastLegend(m5)
assert(
  l5$colors == palette(),
  l5$labels == palette()
)

# test the helper function labelFormat()
f = labelFormat(
  prefix = 'a', suffix = 'b', between = '--', digits = 1,
  transform = function(x) x / 10, big.mark = "'"
)
assert(
  'labelFormat() works',
  identical(f('bin', c(1.234, 2.345)), 'a0.1--0.2b'),
  identical(f('bin', c(123456.78, 987654.32)), "a12'345.7--98'765.4b"),
  TRUE
)
