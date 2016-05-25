export default class ControlStore {

  constructor(map) {
    this._controlsNoId = [];
    this._controlsById = {};
    this._map = map;
  }

  add(control, id, html) {
    if (typeof(id) !== "undefined" && id !== null) {
      if (this._controlsById[id]) {
        this._map.removeControl(this._controlsById[id]);
      }
      this._controlsById[id] = control;
    } else {
      this._controlsNoId.push(control);
    }
    this._map.addControl(control);
  }

  remove(id) {
    if (this._controlsById[id]) {
      let control = this._controlsById[id];
      this._map.removeControl(control);
      delete this._controlsById[id];
    }
  }

  clear() {
    for (let i = 0; i < this._controlsNoId.length; i++) {
      let control = this._controlsNoId[i];
      this._map.removeControl(control);
    }
    this._controlsNoId = [];

    for (let key in this._controlsById) {
      let control = this._controlsById[key];
      this._map.removeControl(control);
    }
    this._controlsById = {};
  }
}