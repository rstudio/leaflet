(function() {
  var maps = {};
  var markers = {}; // key: mapId, value: {key: markerId, value: marker}
  var markerGroups = {}; // key: mapId, value: layer-group
  
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
          Shiny.onInputChange(id + '_zoom', {
            zoom: map.getZoom()
          });
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
  });

})();
