library(leaflet)

#' h1. Leaflet now with Proj4Leaflet support.

#' This is very very hackish for now.<br/>
#' <P>But as HTMLWidget's factory/initialize method has no way to pass params,
#' and the CRS can only be specified at Map creation time (even in 1.0), the only
#' way to support Proj4Leaflet is by destroying the default map and creating a new one.
#' I haven't thought all the details here. But this is the first hack at it.
#' A lot of stuff in the onRender can be moved to R, I just wanted something quick and dirty.
#' </P><br/><br/>Thoughts/Comments ?<br/><br/>

#' The code is adaptation of [this](https://github.com/turban/Leaflet.Graticule/blob/master/examples/mollweide.html) sans the graticule part.<br/><br/>
extJS <- htmltools::htmlDependency("countries", "1.0.0",
    src = c(href = "https://cdn.rawgit.com/turban/Leaflet.Graticule/master/examples/lib/"),
    script = "countries-110m.js"
)

addExtJS <- function(map) {
  map$dependencies <- c(map$dependencies, list(extJS))
  map
}

leaflet() %>% addTiles() %>%
  addProj4Leaflet() %>% # Add Proj4Leaflet plugin JSes.
  addExtJS() %>% # Load external GeoJson File
  htmlwidgets::onRender("
    function(el, x) {

      // remove the original map
      var oldMap = this;
      oldMap.remove();

      // Sphere Mollweide: http://spatialreference.org/ref/esri/53009/
      var crs = new L.Proj.CRS('ESRI:53009',
        '+proj=moll +lon_0=0 +x_0=0 +y_0=0 +a=6371000 +b=6371000 +units=m +no_defs',
        {
          resolutions: [65536, 32768, 16384, 8192, 4096, 2048]
        }
      );

      // create a new map in place of old map using new CRS
      var newMap = L.map(el.id, {
                        crs: crs,
                        maxZoom: 5
                        });

      L.geoJson(countries, {
        style: {
                  color: '#000',
                  weight: 0.5,
                  opacity: 1,
                  fillColor: '#fff',
                  fillOpacity: 1
                }
      }).addTo(newMap);
      newMap.fitWorld();

      //debugger;
    }
  ")

leaflet() %>% addTiles() %>%
  addProj4Leaflet() %>% # Add Proj4Leaflet plugin JSes.
  addExtJS() %>% # Load external GeoJson File
  # Graticule not strictly necessary just aesthetics
  addGraticule(style=
                 list( color= '#777',
                       weight= 1, opacity= 0.5)) %>%
  htmlwidgets::onRender("
    function(el, x) {

      // remove the original map
      var oldMap = this;
      oldMap.remove();

      // Sphere Mollweide: http://spatialreference.org/ref/esri/53009/
      var crs = new L.Proj.CRS('ESRI:53009',
        '+proj=moll +lon_0=0 +x_0=0 +y_0=0 +a=6371000 +b=6371000 +units=m +no_defs',
        {
          resolutions: [65536, 32768, 16384, 8192, 4096, 2048]
        }
      );

      // create a new map in place of old map using new CRS
      var newMap = L.map(el.id, {
                        crs: crs,
                        maxZoom: 5
                        });

    L.graticule({
        sphere: true,
        style: {
            color: '#777',
            opacity: 1,
            fillColor: '#ccf',
            fillOpacity: 1,
            weight: 2
        }
    }).addTo(newMap);


    L.graticule({
                        style: {
                        color: '#777',
                        weight: 1,
                        opacity: 0.5
                        }
                        }).addTo(newMap);


      L.geoJson(countries, {
        style: {
                  color: '#000',
                  weight: 0.5,
                  opacity: 1,
                  fillColor: '#fff',
                  fillOpacity: 1
                }
      }).addTo(newMap);
      newMap.fitWorld();

      //debugger;
    }
  ")
