LeafletWidget.methods.addDrawToolbar = function(layerID,group,position,polyline,polygon,rectangle,circle,marker,edit,remove){
  if (this.drawControl) {
    this.drawControl.removeFrom(this);
  }
  var drawnItems = this.drawnItems;
  if (!drawnItems) {
    drawnItems = this.drawnItems = new L.FeatureGroup();
    this.layerManager.addLayer(drawnItems,"drawnItems",layerID,group);
  }

  if (typeof(marker) === "object" && marker.icon) {
    var opts = marker.icon;
    // Composite options (like points or sizes) are passed from R with each
    // individual component as its own option. We need to combine them now
    // into their composite form.
    if (opts.iconWidth) {
      opts.iconSize = [opts.iconWidth, opts.iconHeight];
    }
    if (opts.shadowWidth) {
      opts.shadowSize = [opts.shadowWidth, opts.shadowHeight];
    }
    if (opts.iconAnchorX) {
      opts.iconAnchor = [opts.iconAnchorX, opts.iconAnchorY];
    }
    if (opts.shadowAnchorX) {
      opts.shadowAnchor = [opts.shadowAnchorX, opts.shadowAnchorY];
    }
    if (opts.popupAnchorX) {
      opts.popupAnchor = [opts.popupAnchorX, opts.popupAnchorY];
    }

    marker.icon = new L.Icon(opts);
  }

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

  var prefix = this.id + "_" + layerID + "_";
  this.on('draw:created', function (e) {
    var layer = e.layer;
		drawnItems.addLayer(layer);
		if (e.layerType === "circle") {
		  e.layer.feature = {properties: {radius: e.layer.getRadius()}};
		}
    if (!HTMLWidgets.shinyMode) return;
	var id = L.stamp(layer);
    Shiny.onInputChange(prefix + "created", {id: id, json: layer.toGeoJSON()});
    Shiny.onInputChange(prefix + "features", drawnItems.toGeoJSON());
  });

  if (HTMLWidgets.shinyMode) {
    this.on('draw:edited', function (e) {
	  var editArray = [];
		e.layers.eachLayer(function(layer) {
		  var id = L.stamp(layer);
		  editArray.push(id);
		});
      Shiny.onInputChange(prefix + "edited", {id: editArray, json: e.layers.toGeoJSON()});
      Shiny.onInputChange(prefix + "features", drawnItems.toGeoJSON());
    });

    this.on('draw:deleted', function (e) {
      var delArray = [];
		e.layers.eachLayer(function(layer) {
		  var id = L.stamp(layer);
		  delArray.push(id);
		});
	  Shiny.onInputChange(prefix + "deleted", {id: delArray, json: e.layers.toGeoJSON()});
      Shiny.onInputChange(prefix + "features", drawnItems.toGeoJSON());
    });

    this.on('draw:deletestart', function () {
      Shiny.onInputChange(prefix + "deleting", true);
    });

    this.on('draw:deletestop', function () {
      Shiny.onInputChange(prefix + "deleting", null);
    });

    this.on('draw:editstart', function () {
      Shiny.onInputChange(prefix + "editing", true);
    });

    this.on('draw:editstop', function () {
      Shiny.onInputChange(prefix + "editing", null);
    });
  }
};

LeafletWidget.methods.removeDrawToolbar = function(){
  this.drawControl.removeFrom(this);
  delete this.drawControl;
}
