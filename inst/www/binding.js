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
    var self = this;
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

  // We use a Shiny output binding merely to detect when a leaflet map is
  // created and needs to be initialized. We are not expecting any real data
  // to be passed to renderValue.
  var leafletOutputBinding = new Shiny.OutputBinding();
  $.extend(leafletOutputBinding, {
    find: function(scope) {
      return $(scope).find(".leaflet-map-output");
    },
    renderValue: function(el, data) {
      var $el = $(el);
      var map = $el.data('leaflet-map');
      if (!map) {

        // A new map was detected. Create it, initialize supporting data
        // structures, and hook up event handlers.

        var id = this.getId(el);
        var leafletOptions = JSON.parse(
          $el.children('script.leaflet-options').text()
        );
        map = L.map(id, leafletOptions);
        map.id = id;
        $el.data('leaflet-map', map);
        
        maps[id] = map;
        map.markers = new LayerStore(map);
        map.shapes = new LayerStore(map);
        map.popups = new LayerStore(map);
        
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

        var initialTileLayer = $el.data('initial-tile-layer');
        var initialTileLayerAttrib = $el.data('initial-tile-layer-attrib');
        if (initialTileLayer) {
          L.tileLayer(initialTileLayer, {
            attribution: initialTileLayerAttrib
          }).addTo(map);
        }
      }
    }
  });
  Shiny.outputBindings.register(leafletOutputBinding, "leaflet-output-binding");
  
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
  
  function mergeOptions(length, options, eachOptions) {
    if (!eachOptions)
      return function() { return options || {}; }

    var keys = [];
    $.each(eachOptions, function(key, value) {
      eachOptions[key] = recycle(eachOptions[key], length);
      keys.push(key);
    });

    var allOptions = [];
    for (var i = 0; i < length; i++) {
      console.log(i);
      var thisOptions = {};
      for (var j = 0; j < keys.length; j++)
        thisOptions[keys[j]] = eachOptions[keys[j]][i];
      allOptions.push($.extend({}, options, thisOptions));
    }
    return function(index) { return allOptions[index]; };
  }

  var methods = {};

  methods.setView = function(lat, lng, zoom, forceReset) {
    this.setView([lat, lng], zoom, forceReset);
  };

  methods.addMarker = function(lat, lng, layerId, options) {
    var self = this;
    var marker = L.marker([lat, lng], options);
    this.markers.add(marker, layerId);
    marker.on('click', function(e) {
      Shiny.onInputChange(self.id + '_marker_click', {
        id: layerId,
        lat: e.target.getLatLng().lat,
        lng: e.target.getLatLng().lng,
        '.nonce': Math.random()  // force reactivity
      });
    });
  };

  methods.clearMarkers = function() {
    this.markers.clear();
  };

  methods.clearShapes = function() {
    this.shapes.clear();
  };

  methods.fitBounds = function(lat1, lng1, lat2, lng2) {
    this.fitBounds([
      [lat1, lng1], [lat2, lng2]
    ]);
  };

  methods.addRectangle = function(lat1, lng1, lat2, lng2, layerId, options) {
    var self = this;
    lat1 = recycle(lat1);
    lng1 = recycle(lng1, lat1.length);
    lat2 = recycle(lat2, lat1.length);
    lng2 = recycle(lng2, lat1.length);
    layerId = recycle(layerId, lat1.length);
    
    for (var i = 0; i < lat1.length; i++) {
      (function() {
        var rect = L.rectangle([
          [lat1[i], lng1[i]],
          [lat2[i], lng2[i]]
        ], options);
        var thisId = layerId[i];
        self.shapes.addLayer(rect, thisId);
        rect.on('click', function(e) {
          Shiny.onInputChange(self.id + '_shape_click', {
            id: thisId,
            lat: e.target.getLatLng().lat,
            lng: e.target.getLatLng().lng,
            '.nonce': Math.random()  // force reactivity
          });
        });
      })();
    }
  };
  
  /*
   * @param lat Array of latitude coordinates for polygons; different
   *   polygons are separated by null.
   * @param lng Array of longitude coordinates for polygons; different
   *   polygons are separated by null.
   * @param layerId Array of layer names.
   * @param options Array of objects that contain options, one for each
   *   polygon (or null for default), or null if none.
   * @param defaultOptions The default set of options that all polygons
   *   will use.
   */
  methods.addPolygon = function(lat, lng, layerId, options, defaultOptions) {
    var self = this;
    var coordPos = -1; // index into lat/lng
    var idPos = -1; // index into layerId
    if (options === null || typeof(options) === 'undefined' || options.length == 0) {
      options = [null];
    }
    while (++coordPos < lat.length && ++idPos < layerId.length) {
      (function() {
        var thisId = layerId[idPos];
        var points = [];
        while (coordPos < lat.length && lat[coordPos] !== null) {
          points.push([lat[coordPos], lng[coordPos]]);
          coordPos++;
        }
        points.pop();
        var opt = $.extend(true, {}, defaultOptions,
          options[idPos % options.length]);
        var polygon = L.polygon(points, opt);
        self.shapes.add(polygon, thisId);
        polygon.on('click', mouseHandler(this.id, thisId, 'shape_click'), this);
        polygon.on('mouseover', mouseHandler(this.id, thisId, 'shape_mouseover'), this);
        polygon.on('mouseout', mouseHandler(this.id, thisId, 'shape_mouseout'), this);
      }).call(this);
    }
  };

  function mouseHandler(mapId, layerId, eventName) {
    return function(e) {
      var lat = e.target.getLatLng ? e.target.getLatLng().lat : null;
      var lng = e.target.getLatLng ? e.target.getLatLng().lng : null;
      Shiny.onInputChange(mapId + '_' + eventName, {
        id: layerId,
        lat: lat,
        lng: lng,
        '.nonce': Math.random()  // force reactivity
      });
    };
  }

  methods.addCircle = function(lat, lng, radius, layerId, options, eachOptions) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('radius', radius)
      .col('layerId', layerId)
      .cbind(options)
      .cbind(eachOptions);

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

  methods.showPopup = function(lat, lng, content, layerId, options) {
    var popup = L.popup(options)
      .setLatLng([lat, lng])
      .setContent(content);
    this.popups.add(popup, layerId);
  };

  methods.removePopup = function(layerId) {
    this.popups.remove(layerId);
  };

  methods.clearPopups = function() {
    this.popups.clear();
  };

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

})();
