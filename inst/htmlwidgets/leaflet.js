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
  }

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
  }

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
  }

  DataFrame.prototype.nrow = function() {
    return this.effectiveLength;
  }

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
  var maps = {};

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
    for (key in this._layers) {
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

  var methods = {};

  methods.setView = function(center, zoom, options) {
    this.setView(center, zoom, options);
  };

  methods.fitBounds = function(lat1, lng1, lat2, lng2) {
    this.fitBounds([
      [lat1, lng1], [lat2, lng2]
    ]);
  };

  methods.popup = function(lat, lng, content, layerId, options) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('content', content)
      .col('layerId', layerId)
      .cbind(options);

    // only one popup
    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var popup = L.popup(df.get(i))
                     .setLatLng([df.get(i, 'lat'), df.get(i, 'lng')])
                     .setContent(df.get(i, 'content'))
                     .openOn(this);
        var thisId = df.get(i, 'layerId');
        this.popups.add(popup, thisId);
        marker.on('click', mouseHandler(this.id, thisId, 'marker_click'), this);
        marker.on('mouseover', mouseHandler(this.id, thisId, 'marker_mouseover'), this);
        marker.on('mouseout', mouseHandler(this.id, thisId, 'marker_mouseout'), this);
      }).call(this);
    }
  };

  methods.removePopup = function(layerId) {
    this.popups.remove(layerId);
  };

  methods.clearPopups = function() {
    this.popups.clear();
  };

  methods.marker = function(lat, lng, layerId, options) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('layerId', layerId)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var marker = L.marker([df.get(i, 'lat'), df.get(i, 'lng')], df.get(i));
        var thisId = df.get(i, 'layerId');
        this.markers.add(marker, thisId);
        marker.on('click', mouseHandler(this.id, thisId, 'marker_click'), this);
        marker.on('mouseover', mouseHandler(this.id, thisId, 'marker_mouseover'), this);
        marker.on('mouseout', mouseHandler(this.id, thisId, 'marker_mouseout'), this);
      }).call(this);
    }
  };

  methods.circle = function(lat, lng, radius, layerId, options) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('radius', radius)
      .col('layerId', layerId)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var circle = L.circle([df.get(i, 'lat'), df.get(i, 'lng')], df.get(i, 'radius'), df.get(i));
        var thisId = df.get(i, 'layerId');
        this.shapes.add(circle, thisId);
        circle.on('click', mouseHandler(this.id, thisId, 'shape_click'), this);
        circle.on('mouseover', mouseHandler(this.id, thisId, 'shape_mouseover'), this);
        circle.on('mouseout', mouseHandler(this.id, thisId, 'shape_mouseout'), this);
      }).call(this);
    }
  };

  methods.circleMarker = function(lat, lng, radius, layerId, options) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('radius', radius)
      .col('layerId', layerId)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var circle = L.circleMarker([df.get(i, 'lat'), df.get(i, 'lng')], df.get(i));
        var thisId = df.get(i, 'layerId');
        this.markers.add(circle, thisId);
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
  methods.polyline = function(lat, lng, layerId, options) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('layerId', layerId)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var geometry = HTMLWidgets.dataframeToD3({
          lat: asArray(df.get(i, 'lat')),
          lng: asArray(df.get(i, 'lng'))
        });
        var polyline = L.polyline(geometry, df.get(i));
        var thisId = df.get(i, 'layerId');
        this.shapes.add(polyline, thisId);
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

  methods.rectangle = function(lat1, lng1, lat2, lng2, layerId, options) {
    var df = dataframe.create()
      .col('lat1', lat1)
      .col('lng1', lng1)
      .col('lat2', lat2)
      .col('lng2', lng2)
      .col('layerId', layerId)
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
  methods.polygon = function(lat, lng, layerId, options) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('layerId', layerId)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var geometry = HTMLWidgets.dataframeToD3({
          lat: asArray(df.get(i, 'lat')),
          lng: asArray(df.get(i, 'lng'))
        });
        var polygon = L.polygon(geometry, df.get(i));
        var thisId = df.get(i, 'layerId');
        this.shapes.add(polygon, thisId);
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
      return L.map(el, {
        center: [51.505, -0.09],
        zoom: 13
      });
    },
    renderValue: function(el, data, map) {

      map.markers = new LayerStore(map);
      map.shapes = new LayerStore(map);
      map.popups = new LayerStore(map);
      map.geojson = new LayerStore(map);

      if (data.tileLayer instanceof Array) {
        data.tileLayer.map(function(layer) {
          L.tileLayer(layer.urlTemplate, layer.options).addTo(map);
        });
      }
      if (data.setView) {
        map.setView.apply(map, data.setView);
      }
      if (data.fitBounds) {
        methods.fitBounds.apply(map, data.fitBounds);
      }
      if (data.popup instanceof Array) {
        data.popup.map(function(params) {
          methods.popup.apply(map, params);
        });
      }
      if (data.marker instanceof Array) {
        data.marker.map(function(params) {
          methods.marker.apply(map, params);
        });
      }
      if (data.circle instanceof Array) {
        data.circle.map(function(params) {
          methods.circle.apply(map, params);
        });
      }
      if (data.circleMarker instanceof Array) {
        data.circleMarker.map(function(params) {
          methods.circleMarker.apply(map, params);
        });
      }
      if (data.polyline instanceof Array) {
        data.polyline.map(function(params) {
          methods.polyline.apply(map, params);
        });
      }
      if (data.rectangle instanceof Array) {
        data.rectangle.map(function(params) {
          methods.rectangle.apply(map, params);
        });
      }
      if (data.polygon instanceof Array) {
        data.polygon.map(function(params) {
          methods.polygon.apply(map, params);
        });
      }
      if (data.geoJSON instanceof Array) {
        data.geoJSON.map(function(params) {
          methods.geoJSON.apply(map, params);
        });
      }

      var id = data.mapId;
      if (id === null) return;
      maps[id] = map;

      if (!HTMLWidgets.shinyMode) return;

      // When the map is clicked, send the coordinates back to the app
      map.on('click', function(e) {
        Shiny.onInputChange(id + '_click', {
          lat: e.latlng.lat,
          lng: e.latlng.lng,
          '.nonce': Math.random() // Force reactivity if lat/lng hasn't changed
        });
      });

      // Send bounds info back to the app
      function updateBounds() {
        var bounds = map.getBounds();
        Shiny.onInputChange(id + '_bounds', {
          north: bounds.getNorthEast().lat,
          east: bounds.getNorthEast().lng,
          south: bounds.getSouthWest().lat,
          west: bounds.getSouthWest().lng
        });
        Shiny.onInputChange(id + '_zoom', map.getZoom());
      }
      setTimeout(updateBounds, 1);

      map.on('moveend', updateBounds);

    },
    resize: function(el, width, height, data) {

    }
  });

  if (!HTMLWidgets.shinyMode) return;

  // Shiny support via the Leaflet map controller
  Shiny.addCustomMessageHandler('leaflet', function(data) {
    var mapId = data.mapId;
    var map = maps[mapId];
    if (!map)
      return;

    if (methods[data.method]) {
      methods[data.method].apply(map, data.args);
    } else {
      throw new Error('Unknown method ' + data.method);
    }
  });

  /*
  function unflattenLatLng(lat, lng, levels) {
    var stack = [];
    function
  }
  */

})();
