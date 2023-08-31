# leaflet 2.2.0

### Features

- Added support for SpatRaster and SpatVector objects from the terra package. (#728)

- `leaflet()` now uses jQuery 3.6.0 provided via the `{jquerylib}`package. As a result of this change, the HTML dependencies for `leaflet()` are included in the `dependencies` item of the htmlwidget object it returns. (#817, #821)

## Bug fixes and improvements

- Use correct license in OpenStreetMap attribution. (#811)

- Use `xfun::base64_uri()` for base64 encoding instead of **markdown** and **base64enc**. (#823)

- Remove dependencies on rgdal and rgeos. (#837)

- Respect option scrollWheelZoom=FALSE. (#827)

- Fixed #866: Correctly call `terra::has.RGB()` in `addRasterImage()` for a `SpatRaster` object. (#869)

# leaflet 2.1.2

## Bug fixes and improvements

- Removed S3 warnings found on R devel (#848)

# leaflet 2.1.1

## Bug fixes and improvements

- The default marker icon for `addMarkers` no longer worked, due to the CDN we were relying on apparently being retired. Fixed by pointing to a new CDN. (#782)

- New behavior from tile.openstreetmap.org caused `addTiles` default tileset to break when viewed under non-https protocol on recent versions of Chrome. Fixed by always using the https protocol to connect to openstreetmap. (#786)

# leaflet 2.1.0

## Bug fixes and improvements

- Enable JS function literals (wrapped in `htmlwidgets::JS()`) to be included in arguments to methods invoked on `leafletProxy` objects. (JS function literals could already be included with methods invoked on `leaflet` objects, so this change just brings `leafletProxy` to parity.) (#420)

- Add missing CSS rule to show `<img>` in right-pane and left-pane (rstudio/rmarkdown/issues#1949, #770)

- Allow for _hidden_ but not suspended leaflet maps to queue calls (such as add raster images) until they are rendered. If a new leaflet map is created, all pending calls are removed. (#771)

# leaflet 2.0.4.1

## Features

- Updated proj4.js to 2.6.2

## Bug fixes and improvements

- Minor tweaks to example data and tests, required to stay on CRAN

- Fixes broken URL (#742) and updated examples to run from system files (#576) including updated .Rmd and .html docs.

# leaflet 2.0.3

## Breaking changes

- `data("providers")` and `data("providers.details")` no longer exist. Please use `leaflet::providers` and `leaflet::providers.details`. (#636)

## Bug fixes and improvements

- Integrated data from `leaflet.providers` package. See [leaflet.providers](https://rstudio.github.io/leaflet.providers/) for details. (#636)
- Fixed [rstudio/crosstalk#58](https://github.com/rstudio/crosstalk/issues/58), which caused Leaflet maps that used Crosstalk shared data in Shiny apps, to be redrawn at incorrect times.
- invokeRemote() now resolves html dependencies before passing them to shiny::createWebDependency() (#620).
- Upgrade leaflet-provider to 1.4.0, enable more map variants such as CartoDB.Voyager (#567)
- `sf` objects with `names` attributes in the `st_geometry` now visualise correctly (#595)
- GeoJSON objects missing `properties` can now be displayed (#622)

# leaflet 2.0.2

## Bug fixes and improvements

- Require viridis >= 0.5.1 to avoid namespace issues with viridisLite (#557)
- Fixed broken mouse events after using leaflet-search from leaflet.extras within shiny applications (#563)
- Use leaflet namespace on `providers` in `addMiniMap` to make the function accessible in other packages. Fixes [r-tmap/tmap#231](https://github.com/r-tmap/tmap/issues/231). (#568)
- Require scales >= 1.0.0 to avoid exact color matching issues (#578)

# leaflet 2.0.1

## Features

- Added method `addMapPane` to add custom pane layers to have fine tune control over layer ordering. New feature from within leaflet.js v1.x. (#549)
- Exposed htmlwidgets sizingPolicy in leaflet() (#548)

## Bug fixes and improvements

- Default marker icon locations will now use unpkg.com instead of the leaflet cdn when using https or file protocols. (#544)
- `.leaflet-map-pane` `z-index` switched to 'auto'. Allows for map panes to appear above the map if they appear later in the dom. (#537)
- Use correct Leaflet.js scale control remove method. (#547)
- Start from world view if using flyTo or flyToBounds. (#552)

# leaflet 2.0.0

## Breaking changes

- Update to latest leaflet.js v1.3.1 (#453, 314616f) Please see https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html for the latest documentation

- All plugins updated to versions compatible with leaflet > 1.0 (#458)

  - jQuery, https://github.com/jquery/jquery
  - Leaflet (JavaScript library), https://github.com/Leaflet/Leaflet
  - Leaflet Providers, https://github.com/leaflet-extras/leaflet-providers
  - leaflet-measure, https://github.com/ljagis/leaflet-measure
  - Leaflet.Terminator, https://github.com/joergdietrich/Leaflet.Terminator
  - Leaflet.SimpleGraticule, https://github.com/ablakey/Leaflet.SimpleGraticule
  - Leaflet.MagnifyingGlass, https://github.com/bbecquet/Leaflet.MagnifyingGlass
  - Leaflet.MiniMap, https://github.com/Norkart/Leaflet-MiniMap
  - Leaflet.awesome-markers, https://github.com/lvoogdt/Leaflet.awesome-markers
  - Leaflet.EasyButton, https://github.com/CliffCloud/Leaflet.EasyButton/
  - Proj4Leaflet, https://github.com/kartena/Proj4Leaflet
  - leaflet-locationfilter, https://github.com/kajic/leaflet-locationfilter
  - leaflet-omnivore, https://github.com/mapbox/leaflet-omnivore
  - topojson, https://github.com/topojson/topojson

- Leaflet.label (https://github.com/Leaflet/Leaflet.labelExtension)

  - `L.Label` has been adopted within Leaflet.js to `L.Tooltip`
  - Tooltips are now displayed with default Leaflet.js styling
  - In custom javascript extensions, change all `*.bindLabel()` to `*.bindTooltip()`

## Bug fixes and features

- Relative protocols are used where possible when adding tiles (#526). In RStudio 1.1.x on linux and windows, a known issue of 'https://' routes fail to load, but works within browsers (rstudio/rstudio#2661).

- Added more providers for `addProviderTiles()`: "OpenStreetMap.CH", "OpenInfraMap", "OpenInfraMap.Power", "OpenInfraMap.Telecom", "OpenInfraMap.Petroleum", "OpenInfraMap.Water", "OpenPtMap", "OpenRailwayMap", "OpenFireMap", "SafeCast". (4aea447)

- `L.multiPolyline` was absorbed into `L.polyline`, which accepts multiple an array of polyline information. https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#polyline. (#515)

- Fix bug where icons where anchored to the top-center, not center-center (2a60751)

- Fix bug where markers would not appear in self contained knitr files (cc79bc3)

- leaflet-label plugin now L.tooltip in leaflet.js. labelOptions() now translates old options clickable to interactive and noHide to permanent.

- Fix a bug where the default `addTiles()` would not work with .html files
  served directly from the filesystem.

- Add `groupOptions` function. Currently the only option is letting you specify
  zoom levels at which a group should be visible.

- Fix bug with accessing columns in formulas when the data source is a Crosstalk
  SharedData object wrapping a spatial data frame or sf object.

- Fix strange wrapping behavior for legend, especially common for Chrome when
  browser zoom level is not 100%.

- Fix incorrect opacity on NA entry in legend. (PR #425)

- Added support for drag events (#405)

- Ensure type safety of .indexOf(stamp) (#396)

- `validateCoords()` warns on invalid polygon data (#393)

- Added `method` argument to `addRasterImage()` to enable nearest neighbor interpolation when projecting categorical rasters (#462)

- Added an `'auto'` method for `addRasterImage()`. Projected factor results are coerced into factors. (9accc7e)

- Added `data` parameter to remaining `addXXX()` methods, including addLegend. (f273edd, #491, #485)

- Added `preferCanvas` argument to `leafletOptions()` (#521)

# leaflet 1.1.0

- Add support for sf. sf, sfc, and sfg classes are supported with POINT,
  LINESTRING, MULTILINESTRING, POLYGON, and MULTIPOLYGON geometries (note
  that MULTIPOINT is not currently supported).

- Added support for Crosstalk (https://rstudio.github.io/crosstalk/).

- Added option to highlight polygons, polylines, circles, and rectangles on
  hover (use highlightOptions parameter).

- Fix behavior when data contains NA points, or zero rows. Previously this would
  cause an error.

- Added `popupOptions` parameter to all markers and shape layers.

- Upgraded existing plugins to their respective latest versions and added
  missing/new functionality from those plugins. (PR #293)

- Added Proj4Leaflet plugin (PR #294).

- Added EasyButton plugin (PR #295).

- Added Graticule plugin (PR #293).

- Color palette improvements. All color palette functions now support viridis
  palettes ("viridis", "magma", "inferno", and "plasma").

- Color palette functions now support reversing the order in which colors are
  used, via reverse=TRUE.

- `colorFactor` no longer interpolates qualitative RColorBrewer palettes,
  unless the number of factor levels being mapped exceeds the number of colors
  in the specified RColorBrewer palette. (Issue #300)

- Upgrade leaflet.js to 0.7.7.1 (PR #359)

- Added a way for the Map instance to be instantiated via a factory.

# leaflet 1.0.2

- When used with `leafletProxy`, `fitBounds` did not return its input object as
  output, so magrittr chains would break after `fitBounds` was called.

- Add addMeasure()/removeMeasure() functions to allow users to measure lines and
  areas, via the leaflet-measure plugin by @ljagis. (PR #171. Thanks, Kenton
  Russell!)

- Add `input${mapid}_center` Shiny event.

- Add support for labels on most layers, that show either statically or on
  hover. (PR #181. Thanks Bhaskar Karambelkar!)

- Add support for markers with configurable colors and icons, via the
  Leaflet.awesome-markers plugin by @lvoogdt. See `?addAwesomeMarkers`.
  (PR #184. Great work, Bhaskar!)

- Add support for the Leaflet.Terminator plugin by @joergdietrich. Overlays
  day and night regions on a map. See `?addTerminator`. (PR #184, thanks
  Bhaskar!)

- Add support for Leaflet.SimpleGraticule plugin by @ablakey. See
  `?addSimpleGraticule`. (PR #184, thanks again Bhaskar!)

- Add support for Leaflet.MagnifyingGlass plugin by @bbecquet. Adds a
  configurable magnifying glass that displays the area under the cursor at an
  increased zoom level. See `?addMagnifyingGlass`. (PR #184, still Bhaskar!)

- Add support for Leaflet-MiniMap plugin by @Norkart. Adds a mini map to the
  corner that can be used to see or change the bounds of the main map. See
  `?addMiniMap`. (PR #184, Bhaskar again!)

- `addScaleBar` and related functions added, for showing Leaflet's built-in
  scale bar in one of the corners of the map. (PR #201. Thanks Kent Johnson!)

# leaflet 1.0.1

- Fix #242: Compatibility with htmlwidgets 0.6 (thanks byzheng).

# leaflet 1.0.0

- Initial release
