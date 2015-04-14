function recycle(values, length, inPlace) {
  if (length === 0 && !inPlace)
    return [];

  if (!(values instanceof Array)) {
    if (inPlace) {
      throw new Error("Can't do in-place recycling of a non-Array value");
    }
    values = [values];
  }
  if (typeof(length) === 'undefined')
    length = values.length;

  var dest = inPlace ? values : [];
  var origLength = values.length;
  while (dest.length < length) {
    dest.push(values[dest.length % origLength]);
  }
  if (dest.length > length) {
    dest.splice(length, dest.length - length);
  }
  return dest;
}

function asArray(value) {
  if (value instanceof Array)
    return value;
  else
    return [value];
}

var dataframe = (function() {
  var exports = {};

  var DataFrame = function() {
    this.columns = [];
    this.colnames = [];
    this.colstrict = [];

    this.effectiveLength = 0;
    this.colindices = {};
  };

  DataFrame.prototype._updateCachedProperties = function() {
    var self = this;
    this.effectiveLength = 0;
    this.colindices = {};

    $.each(this.columns, function(i, column) {
      self.effectiveLength = Math.max(self.effectiveLength, column.length);
      self.colindices[self.colnames[i]] = i;
    });
  };

  DataFrame.prototype._colIndex = function(colname) {
    var index = this.colindices[colname];
    if (typeof(index) === 'undefined')
      return -1;
    return index;
  };

  DataFrame.prototype.col = function(name, values, strict) {
    if (typeof(name) !== 'string')
      throw new Error('Invalid column name "' + name + '"');

    var index = this._colIndex(name);

    if (arguments.length === 1) {
      if (index < 0)
        return null;
      else
        return recycle(this.columns[index], this.effectiveLength);
    }

    if (index < 0) {
      index = this.colnames.length;
      this.colnames.push(name);
    }
    this.columns[index] = asArray(values);
    this.colstrict[index] = !!strict;

    // TODO: Validate strictness (ensure lengths match up with other stricts)

    this._updateCachedProperties();

    return this;
  };

  DataFrame.prototype.cbind = function(obj, strict) {
    var self = this, name;
    $.each(obj, function(name, coldata) {
      self.col(name, coldata);
    });
    return this;
  };

  DataFrame.prototype.get = function(row, col) {
    var self = this;

    if (row > this.effectiveLength)
      throw new Error('Row argument was out of bounds: ' + row + ' > ' + this.effectiveLength);

    var colIndex = -1;
    if (typeof(col) === 'undefined') {
      var rowData = {};
      $.each(this.colnames, function(i, name) {
        rowData[name] = self.columns[i][row % self.columns[i].length];
      });
      return rowData;
    } else if (typeof(col) === 'string') {
      colIndex = this._colIndex(col);
    } else if (typeof(col) === 'number') {
      colIndex = col;
    }
    if (colIndex < 0 || colIndex > this.columns.length)
      throw new Error('Unknown column index: ' + col);

    return this.columns[colIndex][row % this.columns[colIndex].length];
  };

  DataFrame.prototype.nrow = function() {
    return this.effectiveLength;
  };

  function test() {
    var df = new DataFrame();
    df.col("speed", [4, 4, 7, 7, 8, 9, 10, 10, 10, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 16, 16, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 20, 20, 20, 20, 20, 22, 23, 24, 24, 24, 24, 25])
      .col("dist", [2, 10, 4, 22, 16, 10, 18, 26, 34, 17, 28, 14, 20, 24, 28, 26, 34, 34, 46, 26, 36, 60, 80, 20, 26, 54, 32, 40, 32, 40, 50, 42, 56, 76, 84, 36, 46, 68, 32, 48, 52, 56, 64, 66, 54, 70, 92, 93, 120, 85])
      .col("color", ["yellow", "red"])
      .cbind({
        "Make" : ["Toyota", "Cadillac", "BMW"],
        "Model" : ["Corolla", "CTS", "435i"]
      })
    ;
    console.log(df.get(9, "speed"));
    console.log(df.get(9, "dist"));
    console.log(df.get(9, "color"));
    console.log(df.get(9, "Make"));
    console.log(df.get(9, "Model"));
    console.log(df.get(9));

  }

  return {
    create: function() {
      return new DataFrame();
    }
  };

})();

(function() {
  function LayerStore(map) {
    this._layers = {};
    this._group = L.layerGroup().addTo(map);
  }

  LayerStore.prototype.add = function(layer, id) {
    if (typeof(id) !== 'undefined' && id !== null) {
      if (this._layers[id]) {
        this._group.removeLayer(this._layers[id]);
      }
      this._layers[id] = layer;
    }
    this._group.addLayer(layer);
  };

  LayerStore.prototype.remove = function(id) {
    if (this._layers[id]) {
      this._group.removeLayer(this._layers[id]);
      delete this._layers[id];
    }
  };

  LayerStore.prototype.get = function(id) {
    return this._layers[id];
  };

  LayerStore.prototype.clear = function() {
    this._layers = {};
    this._group.clearLayers();
  };

  LayerStore.prototype.each = function(iterator) {
    this._group.eachLayer(iterator);
  };

  LayerStore.prototype.keys = function() {
    var keys = [];
    for (var key in this._layers) {
      if (this._layers.hasOwnProperty(key))
        keys.push(key);
    }
    return keys;
  };

  function mouseHandler(mapId, layerId, eventName, extraInfo) {
    return function(e) {
      if (!HTMLWidgets.shinyMode) return;
      var lat = e.target.getLatLng ? e.target.getLatLng().lat : null;
      var lng = e.target.getLatLng ? e.target.getLatLng().lng : null;
      Shiny.onInputChange(mapId + '_' + eventName, $.extend({
        id: layerId,
        lat: lat,
        lng: lng,
        '.nonce': Math.random()  // force reactivity
      }, extraInfo));
    };
  }

  // Send updated bounds back to app. Takes a leaflet event object as input.
  function updateBounds(map) {
    var id = map.getContainer().id;
    var bounds = map.getBounds();

    Shiny.onInputChange(id + '_bounds', {
      north: bounds.getNorthEast().lat,
      east: bounds.getNorthEast().lng,
      south: bounds.getSouthWest().lat,
      west: bounds.getSouthWest().lng
    });
    Shiny.onInputChange(id + '_zoom', map.getZoom());
  }

  var methods = {};

  methods.setView = function(center, zoom, options) {
    this.setView(center, zoom, options);
  };

  methods.fitBounds = function(lat1, lng1, lat2, lng2) {
    this.fitBounds([
      [lat1, lng1], [lat2, lng2]
    ]);
  };

  methods.popup = function(lat, lng, popup, layerId, options) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('popup', popup)
      .col('layerId', layerId)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var popup = L.popup(df.get(i))
                     .setLatLng([df.get(i, 'lat'), df.get(i, 'lng')])
                     .setContent(df.get(i, 'popup'));
        var thisId = df.get(i, 'layerId');
        this.popups.add(popup, thisId);
        popup.on('click', mouseHandler(this.id, thisId, 'popup_click'), this);
        popup.on('mouseover', mouseHandler(this.id, thisId, 'popup_mouseover'), this);
        popup.on('mouseout', mouseHandler(this.id, thisId, 'popup_mouseout'), this);
      }).call(this);
    }
  };

  methods.removePopup = function(layerId) {
    this.popups.remove(layerId);
  };

  methods.clearPopups = function() {
    this.popups.clear();
  };

  methods.tileLayer = function(urlTemplate, options) {
    this.tiles.add(L.tileLayer(urlTemplate, options));
  };

  methods.marker = function(lat, lng, layerId, options, popup) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('layerId', layerId)
      .col('popup', popup)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var marker = L.marker([df.get(i, 'lat'), df.get(i, 'lng')], df.get(i));
        var thisId = df.get(i, 'layerId');
        this.markers.add(marker, thisId);
        var popup = df.get(i, 'popup');
        if (popup !== null) marker.bindPopup(popup);
        marker.on('click', mouseHandler(this.id, thisId, 'marker_click'), this);
        marker.on('mouseover', mouseHandler(this.id, thisId, 'marker_mouseover'), this);
        marker.on('mouseout', mouseHandler(this.id, thisId, 'marker_mouseout'), this);
      }).call(this);
    }
  };

  methods.circle = function(lat, lng, radius, layerId, options, popup) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('radius', radius)
      .col('layerId', layerId)
      .col('popup', popup)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var circle = L.circle([df.get(i, 'lat'), df.get(i, 'lng')], df.get(i, 'radius'), df.get(i));
        var thisId = df.get(i, 'layerId');
        this.shapes.add(circle, thisId);
        var popup = df.get(i, 'popup');
        if (popup !== null) circle.bindPopup(popup);
        circle.on('click', mouseHandler(this.id, thisId, 'shape_click'), this);
        circle.on('mouseover', mouseHandler(this.id, thisId, 'shape_mouseover'), this);
        circle.on('mouseout', mouseHandler(this.id, thisId, 'shape_mouseout'), this);
      }).call(this);
    }
  };

  methods.circleMarker = function(lat, lng, radius, layerId, options, popup) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('radius', radius)
      .col('layerId', layerId)
      .col('popup', popup)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var circle = L.circleMarker([df.get(i, 'lat'), df.get(i, 'lng')], df.get(i));
        var thisId = df.get(i, 'layerId');
        this.markers.add(circle, thisId);
        var popup = df.get(i, 'popup');
        if (popup !== null) circle.bindPopup(popup);
        circle.on('click', mouseHandler(this.id, thisId, 'marker_click'), this);
        circle.on('mouseover', mouseHandler(this.id, thisId, 'marker_mouseover'), this);
        circle.on('mouseout', mouseHandler(this.id, thisId, 'marker_mouseout'), this);
      }).call(this);
    }
  };

  /*
   * @param lat Array of arrays of latitude coordinates for polylines
   * @param lng Array of arrays of longitude coordinates for polylines
   */
  methods.polyline = function(polygons, layerId, options, popup) {
    var df = dataframe.create()
      .col('shapes', polygons)
      .col('layerId', layerId)
      .col('popup', popup)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var shape = df.get(i, 'shapes')[0];
        shape = HTMLWidgets.dataframeToD3(shape);
        var polyline = L.polyline(shape, df.get(i));
        var thisId = df.get(i, 'layerId');
        this.shapes.add(polyline, thisId);
        var popup = df.get(i, 'popup');
        if (popup !== null) polyline.bindPopup(popup);
        polyline.on('click', mouseHandler(this.id, thisId, 'shape_click'), this);
        polyline.on('mouseover', mouseHandler(this.id, thisId, 'shape_mouseover'), this);
        polyline.on('mouseout', mouseHandler(this.id, thisId, 'shape_mouseout'), this);
      }).call(this);
    }
  };

  methods.removeMarker = function(layerId) {
    this.markers.remove(layerId);
  };

  methods.clearMarkers = function() {
    this.markers.clear();
  };

  methods.removeShape = function(layerId) {
    this.shapes.remove(layerId);
  };

  methods.clearShapes = function() {
    this.shapes.clear();
  };

  methods.rectangle = function(lat1, lng1, lat2, lng2, layerId, options, popup) {
    var df = dataframe.create()
      .col('lat1', lat1)
      .col('lng1', lng1)
      .col('lat2', lat2)
      .col('lng2', lng2)
      .col('layerId', layerId)
      .col('popup', popup)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var rect = L.rectangle([
            [df.get(i, 'lat1'), df.get(i, 'lng1')],
            [df.get(i, 'lat2'), df.get(i, 'lng2')]
          ],
          df.get(i));
        var thisId = df.get(i, 'layerId');
        this.shapes.add(rect, thisId);
        var popup = df.get(i, 'popup');
        if (popup !== null) rect.bindPopup(popup);
        rect.on('click', mouseHandler(this.id, thisId, 'shape_click'), this);
        rect.on('mouseover', mouseHandler(this.id, thisId, 'shape_mouseover'), this);
        rect.on('mouseout', mouseHandler(this.id, thisId, 'shape_mouseout'), this);
      }).call(this);
    }
  };

  /*
   * @param lat Array of arrays of latitude coordinates for polygons
   * @param lng Array of arrays of longitude coordinates for polygons
   */
  methods.polygon = function(polygons, layerId, options, popup) {
    var df = dataframe.create()
      .col('shapes', polygons)
      .col('layerId', layerId)
      .col('popup', popup)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var shapes = df.get(i, 'shapes');
        for (var j = 0; j < shapes.length; j++) {
          shapes[j] = HTMLWidgets.dataframeToD3(shapes[j]);
        }
        var polygon = L.polygon(shapes, df.get(i));
        var thisId = df.get(i, 'layerId');
        this.shapes.add(polygon, thisId);
        var popup = df.get(i, 'popup');
        if (popup !== null) polygon.bindPopup(popup);
        polygon.on('click', mouseHandler(this.id, thisId, 'shape_click'), this);
        polygon.on('mouseover', mouseHandler(this.id, thisId, 'shape_mouseover'), this);
        polygon.on('mouseout', mouseHandler(this.id, thisId, 'shape_mouseout'), this);
      }).call(this);
    }
  };

  methods.geoJSON = function(data, layerId) {
    var self = this;
    if (typeof(data) === "string") {
      data = JSON.parse(data);
    }

    var globalStyle = data.style || {};

    var gjlayer = L.geoJson(data, {
      style: function(feature) {
        if (feature.style || feature.properties.style) {
          return $.extend({}, globalStyle, feature.style, feature.properties.style);
        } else {
          return globalStyle;
        }
      },
      onEachFeature: function(feature, layer) {
        var extraInfo = {
          featureId: feature.id,
          properties: feature.properties
        };
        var popup = feature.properties.popup;
        if (typeof popup !== 'undefined' && popup !== null) layer.bindPopup(popup);
        layer.on("click", mouseHandler(self.id, layerId, "geojson_click", extraInfo), this);
        layer.on("mouseover", mouseHandler(self.id, layerId, "geojson_mouseover", extraInfo), this);
        layer.on("mouseout", mouseHandler(self.id, layerId, "geojson_mouseout", extraInfo), this);
      }
    });
    this.geojson.add(gjlayer, layerId);
  };

  HTMLWidgets.widget({
    name: "leaflet",
    type: "output",
    initialize: function(el, width, height) {
      // hard-coding center/zoom here for a non-empty initial view, since there
      // is no way for htmlwidgets to pass initial params to initialize()
      var map = L.map(el, {
        center: [51.505, -0.09],
        zoom: 13
      });

      // Store some state in the map object
      map.leafletr = {
        hasRendered: false
      };

      if (!HTMLWidgets.shinyMode) return map;

      // The map is rendered staticly (no output binding, so no this.getId())
      if (typeof this.getId === 'undefined') return map;

      map.id = this.getId(el);

      // When the map is clicked, send the coordinates back to the app
      map.on('click', function(e) {
        Shiny.onInputChange(map.id + '_click', {
          lat: e.latlng.lat,
          lng: e.latlng.lng,
          '.nonce': Math.random() // Force reactivity if lat/lng hasn't changed
        });
      });

      map.on('moveend', function(e) { updateBounds(e.target); });

      return map;
    },
    renderValue: function(el, data, map) {
      // Merge data options into defaults
      var options = $.extend({ zoomToLimits: "always" }, data.options);

      if (!map.markers) {
        map.markers = new LayerStore(map);
        map.shapes = new LayerStore(map);
        map.popups = new LayerStore(map);
        map.geojson = new LayerStore(map);
        map.tiles = new LayerStore(map);
      } else {
        map.markers.clear();
        map.shapes.clear();
        map.popups.clear();
        map.geojson.clear();
        map.tiles.clear();
      }

      var explicitView = false;
      if (data.setView) {
        explicitView = true;
        map.setView.apply(map, data.setView);
      }
      if (data.fitBounds) {
        explicitView = true;
        methods.fitBounds.apply(map, data.fitBounds);
      }

      // Returns true if the zoomToLimits option says that the map should be
      // zoomed to map elements.
      function needsZoom() {
        return options.zoomToLimits === "always" ||
               (options.zoomToLimits === "first" && !map.leafletr.hasRendered);
      }

      if (!explicitView && needsZoom()) {
        if (data.limits) {
          // Use the natural limits of what's being drawn on the map
          // If the size of the bounding box is 0, leaflet gets all weird
          var pad = 0.006;
          if (data.limits.lat[0] === data.limits.lat[1]) {
            data.limits.lat[0] = data.limits.lat[0] - pad;
            data.limits.lat[1] = data.limits.lat[1] + pad;
          }
          if (data.limits.lng[0] === data.limits.lng[1]) {
            data.limits.lng[0] = data.limits.lng[0] - pad;
            data.limits.lng[1] = data.limits.lng[1] + pad;
          }
          map.fitBounds([
            [ data.limits.lat[0], data.limits.lng[0] ],
            [ data.limits.lat[1], data.limits.lng[1] ]
          ]);
        } else {
          map.fitWorld();
        }
      }

      for (var i = 0; data.calls && i < data.calls.length; i++) {
        var call = data.calls[i];
        if (methods[call.method])
          methods[call.method].apply(map, call.args);
      }

      map.leafletr.hasRendered = true;

      if (!HTMLWidgets.shinyMode) return;

      setTimeout(function() { updateBounds(map); }, 1);
    },
    resize: function(el, width, height, data) {

    }
  });

  if (!HTMLWidgets.shinyMode) return;

  // Shiny support via the Leaflet map controller
  Shiny.addCustomMessageHandler('leaflet', function(data) {
    var mapId = data.mapId;
    var map = document.getElementById(mapId);
    if (!map)
      return;

    if (methods[data.method]) {
      methods[data.method].apply(map, data.args);
    } else {
      throw new Error('Unknown method ' + data.method);
    }
  });

})();



// In RMarkdown's self-contained mode, we don't have a way to carry around the
// images that Leaflet needs but doesn't load into the page. Instead, we'll set
// data URIs for the default marker, and let any others be loaded via CDN.
if (typeof(L.Icon.Default.imagePath) === "undefined") {
  L.Icon.Default.imagePath = "http://cdn.leafletjs.com/leaflet-0.7.3/images";

  if (L.Browser.retina) {
    L.Icon.Default.prototype.options.iconUrl = "data:image/png;base64,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";
  } else {
    L.Icon.Default.prototype.options.iconUrl = "data:image/png;base64,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";
  }
}
