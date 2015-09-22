LeafletWidget.methods.addDrawToolbar = function(layerID,position,polyline,polygon,rectangle,circle,marker,edit,remove){
  if (this.drawControl) {
    this.drawControl.removeFrom(this);
  }
  var drawnItems = new L.FeatureGroup();
  this.layerManager.addLayer(drawnItems,"drawnItems",layerID,layerID);
  var drawControl = new L.Control.Draw({
    edit: {
      featureGroup: drawnItems,
      edit: edit,
      remove: remove
    },
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
    Shiny.onInputChange(layerID +"_edit", layers.toGeoJSON());
  });

  this.on('draw:deleted', function (e) {
    var layers = e.layers;
    if (!HTMLWidgets.shinyMode) return;
    Shiny.onInputChange(layerID +"_delete", layers.toGeoJSON());
  });

    this.on('draw:deletestart', function () {
    if (!HTMLWidgets.shinyMode) return;
      Shiny.onInputChange(layerID +"_deletestop", false );
      Shiny.onInputChange(layerID +"_deletestart", true );
  });

      this.on('draw:deletestop', function () {
    if (!HTMLWidgets.shinyMode) return;
      Shiny.onInputChange(layerID +"_deletestop", true );
      Shiny.onInputChange(layerID +"_deletestart", false );
  });

      this.on('draw:editstart', function () {
    if (!HTMLWidgets.shinyMode) return;
      Shiny.onInputChange(layerID +"_editstop", false );
      Shiny.onInputChange(layerID +"_editstart", true );
  });

      this.on('draw:editstop', function () {
    if (!HTMLWidgets.shinyMode) return;
      Shiny.onInputChange(layerID +"_editstop", true );
      Shiny.onInputChange(layerID +"_editstart", false );
  });

};

LeafletWidget.methods.removeDrawToolbar = function(){
  this.drawControl.removeFrom(this);
}
