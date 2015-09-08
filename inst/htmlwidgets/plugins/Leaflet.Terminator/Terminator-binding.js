  LeafletWidget.methods.addTerminator = function(resolution, time, layerId, group) {
    (function() {
      this.layerManager.addLayer(
        L.terminator({
          resolution: resolution,
          time: time,
          group: group
        }),
        'shape', layerId, group);
    }).call(this);
  };


