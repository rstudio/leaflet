library(leaflet)

icon.glyphicon <- makeAwesomeIcon(icon= 'flag', markerColor = 'blue',
                                  iconColor = 'black')
icon.fa <- makeAwesomeIcon(icon = 'flag', markerColor = 'red', prefix='fa',
                           iconColor = 'black')
icon.ion <- makeAwesomeIcon(icon = 'home', markerColor = 'green',
                            prefix='ion')


# Marker + Label
leaflet() %>% addTiles() %>%
  addAwesomeMarkers(
    lng=-118.456554, lat=34.078039,
    label='This is a label',
    icon = icon.glyphicon) %>%
  addBootstrap()

leaflet() %>% addTiles() %>%
  addAwesomeMarkers(
    lng=-118.456554, lat=34.078039,
    label='This is a label',
    icon = icon.fa) %>%
  addFontAwesome()

leaflet() %>% addTiles() %>%
  addAwesomeMarkers(
    lng=-118.456554, lat=34.078039,
    label='This is a label',
    icon = icon.ion) %>%
  addIonIcon()

# Marker + Static Label using custom label options
leaflet() %>% addTiles() %>%
  addAwesomeMarkers(
    lng=-118.456554, lat=34.078039,
    label='This is a static label',
    labelOptions = labelOptions(noHide = T),
    icon = icon.fa) %>%
  addFontAwesome()


cities <- read.csv(textConnection("
City,Lat,Long,Pop
Boston,42.3601,-71.0589,645966
Hartford,41.7627,-72.6743,125017
New York City,40.7127,-74.0059,8406000
Philadelphia,39.9500,-75.1667,1553000
Pittsburgh,40.4397,-79.9764,305841
Providence,41.8236,-71.4222,177994
"))

library(dplyr)
cities <- cities %>% mutate(PopCat=ifelse(Pop <500000,'blue','red'))


leaflet(cities) %>% addTiles() %>%
  addAwesomeMarkers(lng = ~Long, lat = ~Lat,
             label = ~City,
             icon = icon.ion
  ) %>%
  addIonIcon()

icon.pop <- awesomeIcons(icon = 'users',
                           markerColor = ifelse(cities$Pop <500000,'blue','red'),
                           prefix='fa',
                           iconColor = 'black')

leaflet(cities) %>% addTiles() %>%
  addAwesomeMarkers(lng = ~Long, lat = ~Lat,
             label = ~City,
             icon = icon.pop
  ) %>%
  addFontAwesome()

# Make a list of icons. We'll index into it based on name.
popIcons <- awesomeIconList(
  blue = makeAwesomeIcon(icon='users',prefix='fa', markerColor = 'blue'),
  red = makeAwesomeIcon(icon='users',prefix='fa', markerColor = 'red')
)

leaflet(cities) %>% addTiles() %>%
  addAwesomeMarkers(lng = ~Long, lat = ~Lat,
             label = ~City,
             labelOptions = rep(labelOptions(noHide = T),nrow(cities)),
             icon = ~popIcons[PopCat]
  ) %>%
  addFontAwesome()
