LeafletWidget.methods.addDrawToolbar = function(){
  var drawnItems = new L.FeatureGroup();
  this.layerManager.addLayer(drawnItems,"drawnItems");
  var drawControl = new L.Control.Draw({
    edit: {
      featureGroup: drawnItems
    }
  });
  this.addControl(drawControl);
  this.on('draw:created', function (e) {
    var type = e.layerType,
				layer = e.layer;
			  drawnItems.addLayer(layer);
  });
};



