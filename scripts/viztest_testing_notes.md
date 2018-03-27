## Known Issues
* The top left zoom icons changed css and are now bigger
* The rings css is different in the new leaflet.js
* Minor map changes are tolerated
* The css of the map popups text changed to not be as bold
* Icon images have shifted up half an image for all custom image icons (such as the R logos)
* The lines on the terminator (light / darkness) have been reduced for the new version
* The grid in the first image is thicker

# Validate
Each new/*.html file should have the following features within the html file.


* addGraticule.html
  - should have a grid over the world

* addLayersControl.html
  - should have a icon in the top right corner to change the background and add/remove the markers

* addLegend.html
  - 1 - should contian an obvious legend in the bottom right
  - 2,3,4 - contain resonable legends in the bottom left corner

* addMeasure.html
  - 1 - Should be able to hover over the top right icon. Then click multiple times. Click the "Finish Measurement" button to stop. (Finished result may be in German, but caused by interference between the first and second widget)
  - 2 - Should be able to hover over the bottom left icon. Should be the same as the first image, but in German and purple.

* addMiniMap.html
  - should have a minimap in the bottom right corner

* addProviderTiles.html
  - should have a watercolor looking map

* addRasterImage.html
  - should contain a rainbow of color from red down to purple over Lancaster

* addScaleBar.html
  - should contain a distance scale in the top right corner

* addSimpleGraticule.html
  - should contian a grid over the world

* addTerminator.html
  - should contain a leaflet widget with the location of the sun and night

* easyButton.html
  - should contain an extra star button that will reset the zoom to the world view

* groupOptions.html
  - should have many markers over New Zealand

* icons.html
  - 1 - should be green, yellow, then red icons of a leaf on a twig
  - 2 - should be random hollow shapes that appear to be grouped

* leaflet.html
  - 1 - world map
  - 2 - europe map
  - 3 - zoomed in on ISU campus (Snedecor Hall)
  - 4 - should add a popup over Snedecor Hall
  - 5 - should contain "Random Popup"s over Ames, IA
  - 6 - should contain random markers over Ames, IA
  - 7 - should contain random markers that display "A random letter X" when clicked
  - 8 - should contain the R logo over Auckland
  - 9 - should contain many randomly located R logos around Auckland
  - 10 - should have a RStudio logo over boston and seattle (cities near top left corner)
  - 11 - should be random blue circles around Ames, IA
  - 12 - should be random red circles around Ames, IA
  - 13 - should be random blue circles around Ames, IA with different radiuses
  - 14 - should be random red, dashed rectangles around Ames, IA
  - 15 - should be random blue line drawn over Ames, IA
  - 16 - should be random blue polygon drawn over Ames, IA with the center portions not filled in
  - 17 - should be a yellow neighborhood drawn over a Seattle neighborhood
  - 18 - should be a dark map of Seattle
  - 19 - shold be blue circles over Ames, IA
  - 20 - shold be red circles over Ames, IA
  - 21 - shold be different colored circles over Ames, IA
  - 22 - shold be many shades of green circles over Ames, IA

* leafletProxy.html
  - should have a leaflet html widget appear, but tiles may not have loaded in time
  - should contian blue circles
  - will be a static image

* map-methods.html
  - 1 - should have a very zoomed in version of boston harbor area
  - 2 - should contian a state view of Massachusetts
  - 3 - should view the whole world

* map-shiny.html
  - should have a leaflet html widget appear, but tiles may not have loaded in time
  - will be a static image

* mapOptions.html
  - should contian a popup of "R was born here" in Auckland
