# !formatR
library(leaflet)
# a manual legend
leaflet() %>% addTiles() %>% addLegend(
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
leaflet(df) %>%
  addCircleMarkers(~x, ~y, color = ~pal(z)) %>%
  addLegend(pal = pal, values = ~z)

# format legend labels
df = data.frame(x = rnorm(100), y = rexp(100, 2), z = runif(100))
pal = colorBin('PuOr', df$z, bins = c(0, .1, .4, .9, 1))
leaflet(df) %>%
  addCircleMarkers(~x, ~y, color = ~pal(z)) %>%
  addLegend(pal = pal, values = ~z)

leaflet(df) %>%
  addCircleMarkers(~x, ~y, color = ~pal(z)) %>%
  addLegend(pal = pal, values = ~z, labFormat = labelFormat(
    prefix = '(', suffix = ')%', between = ', ',
    transform = function(x) 100 * x
  ))
