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
  
  function vectorize(val, minLength) {
    if (typeof(val) !== 'object')
      val = [val];
    var origLength = val.length;
    while (val.length < minLength) {
      val.push(val[val.length % origLength]);
    }
    return val;
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
    lat1 = vectorize(lat1);
    lng1 = vectorize(lng1, lat1.length);
    lat2 = vectorize(lat2, lat1.length);
    lng2 = vectorize(lng2, lat1.length);
    layerId = vectorize(layerId, lat1.length);
    
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

  methods.addCircle = function(lat, lng, radius, layerId, options) {
    lat = vectorize(lat);
    lng = vectorize(lng, lat.length);
    radius = vectorize(radius, lat.length);
    layerId = vectorize(layerId, lat.length);
    
    for (var i = 0; i < lat.length; i++) {
      (function() {
        var circle = L.circle([lat[i], lng[i]], radius[i], options);
        var thisId = layerId[i];
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
