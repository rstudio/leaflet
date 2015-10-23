LeafletWidget.methods.addMagnifyingGlass = function(radius, zoomOffset, fixedZoom, fixedPosition,
 latLng, layers, showControlButton, layerId, group) {
  (function() {

    // See comment in MagnifyingGlass-binding.css
    if (/\bQt\b/.test(window.navigator.userAgent)) {
      $(this.getContainer()).addClass("qtwebkit");
    }

    if(!layers) {
      layers = [ L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png') ]
    }
    var glass = L.magnifyingGlass({
        radius: radius,
        zoomOffset: zoomOffset,
        fixedZoom: fixedZoom,
        fixedPosition: fixedPosition,
        latLng: latLng,
        layers: layers
      });

    this.layerManager.addLayer(glass, 'shape', layerId, group);

    if(showControlButton) {
      if(this.magnifyingGlassControl) {
        this.magnifyingGlassControl.removeFrom(this);
      }
      this.magnifyingGlassControl = L.control.magnifyingglass(glass,
        {forceSeparateButton: true});
      this.magnifyingGlassControl.addTo(this);
    }
  }).call(this);
};
