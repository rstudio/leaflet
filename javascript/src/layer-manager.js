import $ from "./global/jquery";
import L from "./global/leaflet";

import { asArray } from "./util";

export default class LayerManager {
  constructor(map) {
    this._map = map;

    // BEGIN layer indices

    // {<groupname>: {<stamp>: layer}}
    this._byGroup = {};
    // {<categoryName>: {<stamp>: layer}}
    this._byCategory = {};
    // {<categoryName_layerId>: layer}
    this._byLayerId = {};
    // {<stamp>: {
    //             "group": <groupname>,
    //             "layerId": <layerId>,
    //             "category": <category>,
    //             "container": <container>
    //           }
    // }
    this._byStamp = {};
    // {<crosstalkGroupName>: {<key>: [<stamp>, <stamp>, ...], ...}}
    this._byCrosstalkGroup = {};

    // END layer indices

    // {<categoryName>: L.layerGroup}
    this._categoryContainers = {};
    // {<groupName>: L.layerGroup}
    this._groupContainers = {};
  }

  addLayer(layer, category, layerId, group, ctGroup, ctKey) {
    // Was a group provided?
    let hasId = typeof(layerId) === "string";
    let grouped = typeof(group) === "string";

    let stamp = L.Util.stamp(layer);

    // This will be the default layer group to add the layer to.
    // We may overwrite this let before using it (i.e. if a group is assigned).
    // This one liner creates the _categoryContainers[category] entry if it
    // doesn't already exist.
    let container = this._categoryContainers[category] =
        this._categoryContainers[category] || L.layerGroup().addTo(this._map);

    let oldLayer = null;
    if (hasId) {
      // First, remove any layer with the same category and layerId
      let prefixedLayerId = this._layerIdKey(category, layerId);
      oldLayer = this._byLayerId[prefixedLayerId];
      if (oldLayer) {
        this._removeLayer(oldLayer);
      }

      // Update layerId index
      this._byLayerId[prefixedLayerId] = layer;
    }

    // Update group index
    if (grouped) {
      this._byGroup[group] = this._byGroup[group] || {};
      this._byGroup[group][stamp] = layer;

      // Since a group is assigned, don't add the layer to the category's layer
      // group; instead, use the group's layer group.
      // This one liner creates the _groupContainers[group] entry if it doesn't
      // already exist.
      container = this.getLayerGroup(group, true);
    }

    // Update category index
    this._byCategory[category] = this._byCategory[category] || {};
    this._byCategory[category][stamp] = layer;

    // Update stamp index
    let layerInfo = this._byStamp[stamp] = {
      layer: layer,
      group: group,
      ctGroup: ctGroup,
      ctKey: ctKey,
      layerId: layerId,
      category: category,
      container: container,
      hidden: false
    };

    // Update crosstalk group index
    if (ctGroup) {
      if (layer.setStyle) {
        // Need to save this info so we know what to set opacity to later
        layer.options.origOpacity = typeof(layer.options.opacity) !== "undefined" ? layer.options.opacity : 0.5;
        layer.options.origFillOpacity = typeof(layer.options.fillOpacity) !== "undefined" ? layer.options.fillOpacity : 0.2;
      }

      let ctg = this._byCrosstalkGroup[ctGroup];
      if (!ctg) {
        ctg = this._byCrosstalkGroup[ctGroup] = {};
        let crosstalk = global.crosstalk;
        let fs = crosstalk.filter.createHandle(crosstalk.group(ctGroup));

        let handleFilter = (e) => {
          if (!e.value) {
            let groupKeys = Object.keys(ctg);
            for (let i = 0; i < groupKeys.length; i++) {
              let key = groupKeys[i];
              let layerInfo = this._byStamp[ctg[key]];
              this._setVisibility(layerInfo, true);
            }
          } else {
            let selectedKeys = {};
            for (let i = 0; i < e.value.length; i++) {
              selectedKeys[e.value[i]] = true;
            }
            let groupKeys = Object.keys(ctg);
            for (let i = 0; i < groupKeys.length; i++) {
              let key = groupKeys[i];
              let layerInfo = this._byStamp[ctg[key]];
              this._setVisibility(layerInfo, selectedKeys[groupKeys[i]]);
            }
          }
        };
        fs.on("change", handleFilter);

        let handleSelection = (e) => {
          if (!e.value) {
            let groupKeys = Object.keys(ctg);
            for (let i = 0; i < groupKeys.length; i++) {
              let key = groupKeys[i];
              let layerInfo = this._byStamp[ctg[key]];
              this._setOpacity(layerInfo, 1.0);
            }
          } else {
            let selectedKeys = {};
            for (let i = 0; i < e.value.length; i++) {
              selectedKeys[e.value[i]] = true;
            }
            let groupKeys = Object.keys(ctg);
            for (let i = 0; i < groupKeys.length; i++) {
              let key = groupKeys[i];
              let layerInfo = this._byStamp[ctg[key]];
              this._setOpacity(layerInfo, selectedKeys[groupKeys[i]] ? 1.0 : 0.2);
            }
          }
        };
        crosstalk.group(ctGroup).var("selection").on("change", handleSelection);

        setTimeout(() => {
          handleFilter({value: fs.filteredKeys});
          handleSelection({value: crosstalk.group(ctGroup).var("selection").get()});
        }, 100);
      }

      if (!ctg[ctKey])
        ctg[ctKey] = [];
      ctg[ctKey].push(stamp);
    }

    // Add to container
    if (!layerInfo.hidden)
      container.addLayer(layer);

    return oldLayer;
  }

  _setVisibility(layerInfo, visible) {
    if (layerInfo.hidden ^ visible) {
      return;
    } else if (visible) {
      layerInfo.container.addLayer(layerInfo.layer);
      layerInfo.hidden = false;
    } else {
      layerInfo.container.removeLayer(layerInfo.layer);
      layerInfo.hidden = true;
    }
  }

  _setOpacity(layerInfo, opacity) {
    if (layerInfo.layer.setOpacity) {
      layerInfo.layer.setOpacity(opacity);
    } else if (layerInfo.layer.setStyle) {
      layerInfo.layer.setStyle({
        opacity: opacity * layerInfo.layer.options.origOpacity,
        fillOpacity: opacity * layerInfo.layer.options.origFillOpacity
      });
    }
  }

  getLayer(category, layerId) {
    return this._byLayerId[this._layerIdKey(category, layerId)];
  }

  removeLayer(category, layerIds) {
    // Find layer info
    $.each(asArray(layerIds), (i, layerId) => {
      let layer = this._byLayerId[this._layerIdKey(category, layerId)];
      if (layer) {
        this._removeLayer(layer);
      }
    });
  }

  clearLayers(category) {
    // Find all layers in _byCategory[category]
    let catTable = this._byCategory[category];
    if (!catTable) {
      return false;
    }

    // Remove all layers. Make copy of keys to avoid mutating the collection
    // behind the iterator you're accessing.
    let stamps = [];
    $.each(catTable, (k, v) => {
      stamps.push(k);
    });
    $.each(stamps, (i, stamp) => {
      this._removeLayer(stamp);
    });
  }

  getLayerGroup(group, ensureExists) {
    let g = this._groupContainers[group];
    if (ensureExists && !g) {
      this._byGroup[group] = this._byGroup[group] || {};
      g = this._groupContainers[group] = L.layerGroup();
      g.groupname = group;
      g.addTo(this._map);
    }
    return g;
  }

  getGroupNameFromLayerGroup(layerGroup) {
    return layerGroup.groupname;
  }

  getVisibleGroups() {
    let result = [];
    $.each(this._groupContainers, (k, v) => {
      if (this._map.hasLayer(v)) {
        result.push(k);
      }
    });
    return result;
  }

  clearGroup(group) {
    // Find all layers in _byGroup[group]
    let groupTable = this._byGroup[group];
    if (!groupTable) {
      return false;
    }

    // Remove all layers. Make copy of keys to avoid mutating the collection
    // behind the iterator you're accessing.
    let stamps = [];
    $.each(groupTable, (k, v) => {
      stamps.push(k);
    });
    $.each(stamps, (i, stamp) => {
      this._removeLayer(stamp);
    });
  }

  clear() {
    function clearLayerGroup(key, layerGroup) {
      layerGroup.clearLayers();
    }
    // Clear all indices and layerGroups
    this._byGroup = {};
    this._byCategory = {};
    this._byLayerId = {};
    this._byStamp = {};
    this._byCrosstalkGroup = {};
    $.each(this._categoryContainers, clearLayerGroup);
    this._categoryContainers = {};
    $.each(this._groupContainers, clearLayerGroup);
    this._groupContainers = {};
  }

  _removeLayer(layer) {
    let stamp;
    if (typeof(layer) === "string") {
      stamp = layer;
    } else {
      stamp = L.Util.stamp(layer);
    }

    let layerInfo = this._byStamp[stamp];
    if (!layerInfo) {
      return false;
    }

    layerInfo.container.removeLayer(stamp);
    if (typeof(layerInfo.group) === "string") {
      delete this._byGroup[layerInfo.group][stamp];
    }
    if (typeof(layerInfo.layerId) === "string") {
      delete this._byLayerId[this._layerIdKey(layerInfo.category, layerInfo.layerId)];
    }
    delete this._byCategory[layerInfo.category][stamp];
    delete this._byStamp[stamp];
    if (layerInfo.ctGroup) {
      let ctGroup = this._byCrosstalkGroup[layerInfo.ctGroup];
      let layersForKey = ctGroup[layerInfo.ctKey];
      let idx = layersForKey ? layersForKey.indexOf(stamp) : -1;
      if (idx >= 0) {
        if (layersForKey.length === 1) {
          delete ctGroup[layerInfo.ctKey];
        } else {
          layersForKey.splice(idx, 1);
        }
      }
    }
  }

  _layerIdKey(category, layerId) {
    return category + "\n" + layerId;
  }
}
