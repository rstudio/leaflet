library(leaflet)

# adapted from http://leafletjs.com/examples/custom-icons.html

iconData = data.frame(
  lat = c(rnorm(10, 0), rnorm(10, 1), rnorm(10, 2)),
  lng = c(rnorm(10, 0), rnorm(10, 3), rnorm(10, 6)),
  group = rep(sort(c('green', 'red', 'orange')), each = 10),
  stringsAsFactors = FALSE
)

leaflet() %>% addMarkers(
  data = iconData,
  icon = ~ iconList(
    iconUrl = sprintf('http://leafletjs.com/docs/images/leaf-%s.png', group),
    shadowUrl = 'http://leafletjs.com/docs/images/leaf-shadow.png',
    iconSize = list(c(38, 95)), shadowSize = list(c(50, 64)),
    iconAnchor = list(c(22, 94)), shadowAnchor = list(c(4, 62)),
    popupAnchor = list(c(-3, -76))
  )
)


# use point symbols from base R graphics as icons
pchIcons = function(pch = 0:14, width = 30, height = 30, ...) {
  n = length(pch)
  files = character(n)
  # create a sequence of png images
  for (i in seq_len(n)) {
    f = tempfile()
    png(f, width = width, height = height, bg = 'transparent')
    par(mar = c(0, 0, 0, 0))
    plot.new()
    points(.5, .5, pch = pch[i], cex = min(width, height) / 8, ...)
    dev.off()
    files[i] = f
  }
  files
}

iconData = matrix(rnorm(500), ncol = 2)
res = kmeans(iconData, 10)
iconData = cbind(iconData, res$cluster)
colnames(iconData) = c('lat', 'lng', 'group')
iconData = as.data.frame(iconData)

# 10 random point shapes for the 10 clusters in iconData
shapes = sample(0:14, 10)
iconFiles = pchIcons(shapes, 40, 40, col = 'steelblue', lwd = 2)

# note the data has 250 rows, and the icon list is of length 10; they are
# connected by the `group` variable: the i-th row of iconData uses the
# group[i]-th icon in the icon list
leaflet() %>% addMarkers(
  data = iconData,
  icon = iconList(
    iconUrl = iconFiles,
    popupAnchor = list(c(20, 0))
  ),
  iconGroup = ~ group,
  popup = ~ sprintf(
    'lat = %.4f, long = %.4f, group = %s, pch = %s', lat, lng, group, shapes[group]
  )
)

unlink(iconFiles)  # clean up the tmp png files that have been embedded
