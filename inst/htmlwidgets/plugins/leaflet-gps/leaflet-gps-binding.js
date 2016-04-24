  LeafletWidget.methods.addControlGPS = function() {
    (function() {
      if(this.gpscontrol) {
        this.gpscontrol.removeFrom( this );
      }
        this.gpscontrol = new L.Control.Gps();
        this.gpscontrol.addTo(this);
    }).call(this);
  };
