(function() {
  var maps = {};
  var markers = {}; // key: mapId, value: {key: markerId, value: marker}
  var markerGroups = {}; // key: mapId, value: layer-group
  var shapeGroups = {}; // key: mapId, value: layer-group
  var popupGroups = {}; // key: mapId, value: layer-group
  
  var leafletOutputBinding = new Shiny.OutputBinding();
  $.extend(leafletOutputBinding, {
    find: function(scope) {
      return $(scope).find(".leaflet-map-output");
    },
    renderValue: function(el, data) {
      var $el = $(el);
      var map = $el.data('leaflet-map');
      if (!map) {
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
        
        map.on('click', function(e) {
          Shiny.onInputChange(id + '_click', {
            lat: e.latlng.lat,
            lng: e.latlng.lng
          });
        });
        
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
        
        map.on('moveend', function(e) {
          updateBounds();
        });

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
    
    if (data.method === 'addMarker') {
      var marker = L.marker([data.args[0], data.args[1]], data.args[3]);
      var markerId = data.args[2];
      if (markerId) {
        markers[mapId] = markers[mapId] || {};
        var oldMarker = markers[mapId][markerId];
        if (oldMarker)
          markerGroups[mapId].removeLayer(oldMarker);
        markers[mapId][markerId] = marker;
      }
      markerGroups[mapId].addLayer(marker);
      marker.on('click', function(e) {
        Shiny.onInputChange(mapId + '_marker_click', {
          id: markerId,
          lat: e.target.getLatLng().lat,
          lng: e.target.getLatLng().lng
        });
      });
    }
    
    if (data.method === 'clearMarkers') {
      markerGroups[mapId].clearLayers();
      markers[mapId] = {};
    }
    
    if (data.method === 'fitBounds') {
      map.fitBounds([
        [data.args[0], data.args[1]],
        [data.args[2], data.args[3]]
      ]);
    }

    if (data.method === 'setView') {
      map.setView([data.args[0], data.args[1]],
        data.args[2], data.args[3]);
    }
    
    if (data.method === 'addRectangle') {
      (function() {
        var lat1 = vectorize(data.args[0]);
        var lng1 = vectorize(data.args[1], lat1.length);
        var lat2 = vectorize(data.args[2], lat1.length);
        var lng2 = vectorize(data.args[3], lat1.length);
        var id = vectorize(data.args[4], lat1.length);
        var options = data.args[5];
        
        for (var i = 0; i < lat1.length; i++) {
          (function() {
            var rect = L.rectangle([
              [lat1[i], lng1[i]],
              [lat2[i], lng2[i]]
            ], options);
            var thisId = id[i];
            shapeGroups[mapId].addLayer(rect);
            rect.on('click', function(e) {
              Shiny.onInputChange(mapId + '_shape_click', {
                id: thisId,
                lat: e.target.getLatLng().lat,
                lng: e.target.getLatLng().lng
              });
            });
          })();
        }
      })();
    }
    
    if (data.method === 'addCircle') {
      (function() {
        var lat = vectorize(data.args[0]);
        var lng = vectorize(data.args[1], lat.length);
        var radius = vectorize(data.args[2], lat.length);
        var id = vectorize(data.args[3], lat.length);
        var options = data.args[4];
        
        for (var i = 0; i < lat.length; i++) {
          (function() {
            var circle = L.circle([lat[i], lng[i]], radius[i], options);
            var thisId = id[i];
            shapeGroups[mapId].addLayer(circle);
            circle.on('click', function(e) {
              Shiny.onInputChange(mapId + '_shape_click', {
                id: thisId,
                lat: e.target.getLatLng().lat,
                lng: e.target.getLatLng().lng
              });
            });
          })();
        }
      })();
    }
    
    if (data.method === 'clearShapes') {
      shapeGroups[mapId].clearLayers();
    }
    
    if (data.method === 'showPopup') {
      var popup = L.popup(data.args[4])
        .setLatLng([data.args[0], data.args[1]])
        .setContent(data.args[2]);
      popupGroups[mapId].addLayer(popup);
    }
    
    if (data.method === 'clearPopups') {
      popupGroups[mapId].clearLayers();
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

})();
