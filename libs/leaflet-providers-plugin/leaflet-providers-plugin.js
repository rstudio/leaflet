LeafletWidget.methods.addProviderTiles = function(provider, layerId, options) {
  this.tiles.add(L.tileLayer.provider(provider, options), layerId);
};

