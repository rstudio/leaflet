  LeafletWidget.methods.addSimpleGraticule = function(interval, showOriginLabel, redraw, layerId, group) {
    (function() {
      this.layerManager.addLayer(
        L.simpleGraticule({
          interval: interval,
          showOriginLabel: showOriginLabel,
          redraw: redraw
        }),
        'shape', layerId, group);
    }).call(this);
  };
