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
    var type = e.layerType,
		layer = e.layer;
    if (type== "polyline"){
      var infLayer = layer.getLatLngs();
    }
    if (type == "marker"){
      var infLayer = layer.getLatLng();
    }
    if (type == "rectangle"){
      var infLayer = layer.getLatLngs();
    }
    if (type == "polygon"){
      var infLayer = layer.getLatLngs();
    }
    if (type == "circle"){
      var infLayer = [layer.getLatLng(), layer.getRadius()];
    }
		drawnItems.addLayer(layer);
    if (!HTMLWidgets.shinyMode) return;
    Shiny.onInputChange(layerID +"_create_"+ type, infLayer);

  });

  this.on('draw:edited', function (e) {
    var layers = e.layers;
    if (!HTMLWidgets.shinyMode) return;
    layers.eachLayer(function (layer) {
      if (type== "polyline"){
      var infLayer = layer.getLatLngs();
    }
    if (type == "marker"){
      var infLayer = layer.getLatLng();
    }
    if (type == "rectangle"){
      var infLayer = layer.getLatLngs();
    }
    if (type == "polygon"){
      var infLayer = layer.getLatLngs();
    }
    if (type == "circle"){
      var infLayer = [layer.getLatLng(), layer.getRadius()];
    }
        Shiny.onInputChange(layerID +"_edit_"+ type, infLayer);
    });
  });
  this.on('draw:deleted', function (e) {
    var layers = e.layers;
    if (!HTMLWidgets.shinyMode) return;
    layers.eachLayer(function (layer) {
      if (type== "polyline"){
      var infLayer = layer.getLatLngs();
    }
    if (type == "marker"){
      var infLayer = layer.getLatLng();
    }
    if (type == "rectangle"){
      var infLayer = layer.getLatLngs();
    }
    if (type == "polygon"){
      var infLayer = layer.getLatLngs();
    }
    if (type == "circle"){
      var infLayer = [layer.getLatLng(), layer.getRadius()];
    }
        Shiny.onInputChange(layerID +"_delete_"+ type, infLayer);
    });
  });
};

LeafletWidget.methods.removeDrawToolbar = function(){
  this.drawControl.removeFrom(this);
}
