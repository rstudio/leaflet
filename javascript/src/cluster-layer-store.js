import { asArray } from "./util";

export default class ClusterLayerStore {
  constructor(group) {
    this._layers = {};
    this._group = group;
  }

  add(layer, id) {
    if (typeof(id) !== "undefined" && id !== null) {
      if (this._layers[id]) {
        this._group.removeLayer(this._layers[id]);
      }
      this._layers[id] = layer;
    }
    this._group.addLayer(layer);
  }

  remove(id) {
    if (typeof(id) === "undefined" || id === null) {
      return;
    }

    id = asArray(id);
    for (let i = 0; i < id.length; i++) {
      if (this._layers[id[i]]) {
        this._group.removeLayer(this._layers[id[i]]);
        delete this._layers[id[i]];
      }
    }
  }

  clear() {
    this._layers = {};
    this._group.clearLayers();
  }
}