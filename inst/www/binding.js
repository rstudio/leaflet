(function() {
  var maps = {};
  var markers = {}; // key: mapId, value: {key: markerId, value: marker}
  var markerGroups = {}; // key: mapId, value: layer-group
  var shapeGroups = {}; // key: mapId, value: layer-group
  var popupGroups = {}; // key: mapId, value: layer-group

  // This object will be the template for the "this" object that is used
  // in leaflet/shiny methods, down below.
  var me = {
    maps: maps,
    markers: markers,
    markerGroups: markerGroups,
    shapeGroups: shapeGroups,
    popupGroups: popupGroups
  };
  
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
        $el.data('leaflet-map', map);
        
        maps[id] = map;
        markerGroups[id] = L.layerGroup().addTo(map);
        shapeGroups[id] = L.layerGroup().addTo(map);
        popupGroups[id] = L.layerGroup().addTo(map);
        
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
      methods[data.method].apply($.extend({
        mapId: mapId,
        map: map
      }, me), data.args);
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
    this.map.setView([lat, lng], zoom, forceReset);
  };

  methods.addMarker = function(lat, lng, layerId, options) {
    var marker = L.marker([lat, lng], options);
    var markerId = layerId;
    var mapId = this.mapId;

    if (markerId) {
      this.markers[mapId] = this.markers[mapId] || {};
      var oldMarker = this.markers[mapId][markerId];
      if (oldMarker)
        this.markerGroups[mapId].removeLayer(oldMarker);
      this.markers[mapId][markerId] = marker;
    }
    this.markerGroups[mapId].addLayer(marker);
    marker.on('click', function(e) {
      Shiny.onInputChange(mapId + '_marker_click', {
        id: markerId,
        lat: e.target.getLatLng().lat,
        lng: e.target.getLatLng().lng,
        '.nonce': Math.random()  // force reactivity
      });
    });
  };

  methods.clearMarkers = function() {
    this.markerGroups[this.mapId].clearLayers();
    this.markers[this.mapId] = {};
  };

  methods.clearShapes = function() {
    this.shapeGroups[this.mapId].clearLayers();
  };

  methods.fitBounds = function(lat1, lng1, lat2, lng2) {
    this.map.fitBounds([
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
        self.shapeGroups[self.mapId].addLayer(rect);
        rect.on('click', function(e) {
          Shiny.onInputChange(self.mapId + '_shape_click', {
            id: thisId,
            lat: e.target.getLatLng().lat,
            lng: e.target.getLatLng().lng,
            '.nonce': Math.random()  // force reactivity
          });
        });
      })();
    }
  };

  methods.addCircle = function(lat, lng, radius, layerId, options) {
    var self = this;
    lat = vectorize(lat);
    lng = vectorize(lng, lat.length);
    radius = vectorize(radius, lat.length);
    layerId = vectorize(layerId, lat.length);
    
    for (var i = 0; i < lat.length; i++) {
      (function() {
        var circle = L.circle([lat[i], lng[i]], radius[i], options);
        var thisId = layerId[i];
        self.shapeGroups[self.mapId].addLayer(circle);
        circle.on('click', function(e) {
          Shiny.onInputChange(self.mapId + '_shape_click', {
            id: thisId,
            lat: e.target.getLatLng().lat,
            lng: e.target.getLatLng().lng,
            '.nonce': Math.random()  // force reactivity
          });
        });
      })();
    }
  };

  methods.showPopup = function(lat, lng, content, layerId, options) {
    var popup = L.popup(options)
      .setLatLng([lat, lng])
      .setContent(content);
    this.popupGroups[this.mapId].addLayer(popup);
  };

  methods.clearPopups = function() {
    this.popupGroups[this.mapId].clearLayers();
  };
})();
