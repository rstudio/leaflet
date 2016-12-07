/* global LeafletWidget, L, Shiny, HTMLWidgets */
LeafletWidget.methods.addAreaSelect = function(options) {
  (function() {
    var map = this;

    if(map.areaSelect) {
      map.areaSelect.remove();
      map.areaSelect = null;
    }

    map.areaSelect = L.areaSelect(options);

    map.areaSelect.on("change", function() {
      if (!HTMLWidgets.shinyMode) return;
      var bounds = map.areaSelect.getBounds();
      Shiny.onInputChange(map.id+"_area_selected",{
        "sw_lat" : bounds.getSouth(),
        "sw_lng" : bounds.getWest(),
        "ne_lat" : bounds.getNorth(),
        "ne_lng" : bounds.getEast()
      });
    });

    map.areaSelect.addTo(map);

  }).call(this);
};

LeafletWidget.methods.setAreaSelectDimensions = function(options) {
  (function() {
    var map = this;

    if(map.areaSelect) {
      map.areaSelect.setDimensions(options);
    }

  }).call(this);
};

LeafletWidget.methods.removeAreaSelect = function() {
  (function() {
    var map = this;

    if(map.areaSelect) {
      map.areaSelect.remove();
      map.areaSelect = null;
    }

  }).call(this);
};
