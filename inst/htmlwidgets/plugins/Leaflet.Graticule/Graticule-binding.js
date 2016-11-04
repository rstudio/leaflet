  LeafletWidget.methods.addGraticule = function(interval, sphere, style, layerId, group) {
    (function() {
      this.layerManager.addLayer(
        L.graticule({
          interval: interval,
          sphere: sphere,
          style: style
        }),
        'shape', layerId, group);
    }).call(this);
  };
