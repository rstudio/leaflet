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
  this.elemIx = 0;
  this.on('draw:created', function (e) {
    var type = e.layerType,
		layer = e.layer;
    if (type== "polyline"){
      var inflayer = layer.getLatLngs();
    }
    if (type == "marker"){
      var inflayer = layer.getLatLng();
    }
    if (type == "rectangle"){
      var inflayer = layer.getLatLngs();
    }
    if (type == "polygon"){
      var inflayer = layer.getLatLngs();
    }
    if (type == "circle"){
      var inflayer = [layer.getLatLng(), layer.getRadius()];
    }
		drawnItems.addLayer(layer);
    if (!HTMLWidgets.shinyMode) return;
    Shiny.onInputChange(layerID + type, inflayer);

  });
};

LeafletWidget.methods.removeDrawToolbar = function(){
  this.drawControl.removeFrom(this);
}
