import L from "./global/leaflet";

let protocolRegex = /^\/\//;
let upgrade_protocol = function(urlTemplate) {
  if (protocolRegex.test(urlTemplate)) {
    if (window.location.protocol === "file:") {
      // if in a local file, support http
      // http should auto upgrade if necessary
      urlTemplate = "http:" + urlTemplate;
    }
  }
  return urlTemplate;
};

let originalLTileLayerInitialize = L.TileLayer.prototype.initialize;
L.TileLayer.prototype.initialize = function(urlTemplate, options) {
  urlTemplate = upgrade_protocol(urlTemplate);
  originalLTileLayerInitialize.call(this, urlTemplate, options);
};

let originalLTileLayerWMSInitialize = L.TileLayer.WMS.prototype.initialize;
L.TileLayer.WMS.prototype.initialize = function(urlTemplate, options) {
  urlTemplate = upgrade_protocol(urlTemplate);
  originalLTileLayerWMSInitialize.call(this, urlTemplate, options);
};
