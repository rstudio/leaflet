  LeafletWidget.methods.addMiniMap = function(position, width, height , collapsedWidth,
    collapsedHeight , zoomLevelOffset , zoomLevelFixed , zoomAnimation , toggleDisplay,
    autoToggleDisplay) {
    (function() {
      if(this.minimap) {
        this.minimap.removeFrom( this );
      }
      layer = new L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png');
        this.minimap = new L.Control.MiniMap(layer, {
          position: position,
          width: width,
          height: height,
          collapsedWidth: collapsedWidth,
          collapsedHeight: collapsedWidth,
          zoomLevelOffset: zoomLevelOffset,
          zoomLevelFixed: zoomLevelFixed,
          zoomAnimation: zoomAnimation,
          toggleDisplay: toggleDisplay,
          autoToggleDisplay: autoToggleDisplay
        });
        this.minimap.addTo(this);
    }).call(this);
  };
