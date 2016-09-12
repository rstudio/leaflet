  LeafletWidget.methods.addGraticule = function(interval, style, layerId, group) {
    (function() {
      this.layerManager.addLayer(
        L.graticule({
          interval: interval,
          style: style
        }),
        'shape', layerId, group);
    }).call(this);
  };
