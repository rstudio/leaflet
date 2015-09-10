LeafletWidget.methods.addDrawToolbar = function(layerID,position,polyline,polygon,rectangle,circle,marker,edit){
  if (this.drawControl) {
    this.drawControl.removeFrom(this);
  }
  var drawnItems = new L.FeatureGroup();
  this.layerManager.addLayer(drawnItems,"drawnItems",layerID);
  if (edit) {
    edit = { featureGroup: drawnItems};
  }
  var drawControl = new L.Control.Draw({
    edit: edit,
    position: position,
    draw: {
      polyline: polyline,
      polygon: polygon,
      rectangle: rectangle,
      circle: circle,
      marker: marker
    }
  });
  this.drawControl = drawControl;
  this.drawControl.addTo(this);
  this.on('draw:created', function (e) {
    var layer=e.layer;
		drawnItems.addLayer(layer);
    if (!HTMLWidgets.shinyMode) return;
    Shiny.onInputChange(layerID +"_create", layer.toGeoJSON());
  });

  this.on('draw:edited', function (e) {
    var layers = e.layers;
    if (!HTMLWidgets.shinyMode) return;
    layers.eachLayer(function (layer) {
      Shiny.onInputChange(layerID +"_edit", layer.toGeoJSON());
    });
  });

  this.on('draw:deleted', function (e) {
    var layers = e.layers;
    if (!HTMLWidgets.shinyMode) return;
    layers.eachLayer(function (layer) {
      Shiny.onInputChange(layerID +"_delete", layer.toGeoJSON());
    });
  });
};

LeafletWidget.methods.removeDrawToolbar = function(){
  this.drawControl.removeFrom(this);
}
