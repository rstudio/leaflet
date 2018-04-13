import L from "./global/leaflet";

// add texxtsize, textOnly, and style
L.Tooltip.prototype.options.textsize = "10px";
L.Tooltip.prototype.options.textOnly = false;
L.Tooltip.prototype.options.style = null;

// copy original layout to not completely stomp it.
let initLayoutOriginal = L.Tooltip.prototype._initLayout;

L.Tooltip.prototype._initLayout = function() {
  initLayoutOriginal.call(this);
  this._container.style.fontSize = this.options.textsize;

  if (this.options.textOnly) {
    L.DomUtil.addClass(this._container, "leaflet-tooltip-text-only");
  }

  if (this.options.style) {
    for (let property in this.options.style) {
      this._container.style[property] = this.options.style[property];
    }
  }
};
