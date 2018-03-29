/**
 * Leaflet.MarkerCluster.LayerSupport 1.0.5+87f3848
 * Sub-plugin for Leaflet.markercluster plugin (MCG in short); brings compatibility with L.Control.Layers and other Leaflet plugins.
 * (c) 2015-2017 Boris Seang
 * License MIT
 */
(function (root, factory) {
    if (typeof define === "function" && define.amd) {
        define(["leaflet"], factory);
    } else if (typeof module === "object" && module.exports) {
        factory(require("leaflet"));
    } else {
        factory(root.L);
    }
}(this, function (L, undefined) {

/**
 * Extends the L.MarkerClusterGroup class by mainly overriding methods for
 * addition/removal of layers, so that they can also be directly added/removed
 * from the map later on while still clustering in this group.
 * @type {L.MarkerClusterGroup}
 */
L.MarkerClusterGroup.LayerSupport = L.MarkerClusterGroup.extend({

	options: {
		// Buffer single addLayer and removeLayer requests for efficiency.
		singleAddRemoveBufferDuration: 100 // in ms.
	},

	initialize: function (options) {
		L.MarkerClusterGroup.prototype.initialize.call(this, options);

		// Replace the MCG internal featureGroup's so that they directly
		// access the map add/removal methods, bypassing the switch agent.
		this._featureGroup = new _ByPassingFeatureGroup();
		this._featureGroup.addEventParent(this);

		this._nonPointGroup = new _ByPassingFeatureGroup();
		this._nonPointGroup.addEventParent(this);

		// Keep track of what should be "represented" on map (can be clustered).
		this._layers = {};
		this._proxyLayerGroups = {};
		this._proxyLayerGroupsNeedRemoving = {};

		// Buffer single addLayer and removeLayer requests.
		this._singleAddRemoveBuffer = [];
	},

	/**
	 * Stamps the passed layers as being part of this group, but without adding
	 * them to the map right now.
	 * @param layers L.Layer|Array(L.Layer) layer(s) to be stamped.
	 * @returns {L.MarkerClusterGroup.LayerSupport} this.
	 */
	checkIn: function (layers) {
		var layersArray = this._toArray(layers);

		this._checkInGetSeparated(layersArray);

		return this;
	},

	/**
	 * Un-stamps the passed layers from being part of this group. It has to
	 * remove them from map (if they are) since they will no longer cluster.
	 * @param layers L.Layer|Array(L.Layer) layer(s) to be un-stamped.
	 * @returns {L.MarkerClusterGroup.LayerSupport} this.
	 */
	checkOut: function (layers) {
		var layersArray = this._toArray(layers),
		    separated = this._separateSingleFromGroupLayers(layersArray, {
		        groups: [],
		        singles: []
		    }),
		    groups = separated.groups,
		    singles = separated.singles,
		    i, layer;

		// Un-stamp single layers.
		for (i = 0; i < singles.length; i++) {
			layer = singles[i];
			delete this._layers[L.stamp(layer)];
			delete layer._mcgLayerSupportGroup;
		}

		// Batch remove single layers from MCG.
		// Note: as for standard MCG, if single layers have been added to
		// another MCG in the meantime, their __parent will have changed,
		// so weird things would happen.
		this._originalRemoveLayers(singles);

		// Dismiss Layer Groups.
		for (i = 0; i < groups.length; i++) {
			layer = groups[i];
			this._dismissProxyLayerGroup(layer);
		}

		return this;
	},

	/**
	 * Checks in and adds an array of layers to this group.
	 * Layer Groups are also added to the map to fire their event.
	 * @param layers (L.Layer|L.Layer[]) single and/or group layers to be added.
	 * @returns {L.MarkerClusterGroup.LayerSupport} this.
	 */
	addLayers: function (layers) {
		var layersArray = this._toArray(layers),
		    separated = this._checkInGetSeparated(layersArray),
		    groups = separated.groups,
		    i, group, id;

		// Batch add all single layers.
		this._originalAddLayers(separated.singles);

		// Add Layer Groups to the map so that they are registered there and
		// the map fires 'layeradd' events for them as well.
		for (i = 0; i < groups.length; i++) {
			group = groups[i];
			id = L.stamp(group);
			this._proxyLayerGroups[id] = group;
			delete this._proxyLayerGroupsNeedRemoving[id];
			if (this._map) {
				this._map._originalAddLayer(group);
			}
		}
	},
	addLayer: function (layer) {
		this._bufferSingleAddRemove(layer, "addLayers");
		return this;
	},
	_originalAddLayer: L.MarkerClusterGroup.prototype.addLayer,
	_originalAddLayers: L.MarkerClusterGroup.prototype.addLayers,

	/**
	 * Removes layers from this group but without check out.
	 * Layer Groups are also removed from the map to fire their event.
	 * @param layers (L.Layer|L.Layer[]) single and/or group layers to be removed.
	 * @returns {L.MarkerClusterGroup.LayerSupport} this.
	 */
	removeLayers: function (layers) {
		var layersArray = this._toArray(layers),
		    separated = this._separateSingleFromGroupLayers(layersArray, {
		        groups: [],
		        singles: []
		    }),
		    groups = separated.groups,
		    singles = separated.singles,
		    i = 0,
		    group, id;

		// Batch remove single layers from MCG.
		this._originalRemoveLayers(singles);

		// Remove Layer Groups from the map so that they are un-registered
		// there and the map fires 'layerremove' events for them as well.
		for (; i < groups.length; i++) {
			group = groups[i];
			id = L.stamp(group);
			delete this._proxyLayerGroups[id];
			if (this._map) {
				this._map._originalRemoveLayer(group);
			} else {
				this._proxyLayerGroupsNeedRemoving[id] = group;
			}
		}

		return this;
	},
	removeLayer: function (layer) {
		this._bufferSingleAddRemove(layer, "removeLayers");
		return this;
	},
	_originalRemoveLayer: L.MarkerClusterGroup.prototype.removeLayer,
	_originalRemoveLayers: L.MarkerClusterGroup.prototype.removeLayers,

	onAdd: function (map) {
		// Replace the map addLayer and removeLayer methods to place the
		// switch agent that redirects layers when required.
		map._originalAddLayer = map._originalAddLayer || map.addLayer;
		map._originalRemoveLayer = map._originalRemoveLayer || map.removeLayer;
		L.extend(map, _layerSwitchMap);

		// As this plugin allows the Application to add layers on map, some
		// checked in layers might have been added already, whereas LayerSupport
		// did not have a chance to inject the switch agent in to the map
		// (if it was never added to map before). Therefore we need to
		// remove all checked in layers from map!
		var toBeReAdded = this._removePreAddedLayers(map),
		    id, group, i;

		// Normal MCG onAdd.
		this._originalOnAdd.call(this, map);

		// If layer Groups are added/removed from this group while it is not
		// on map, Control.Layers gets out of sync until this is added back.

		// Restore proxy Layer Groups that may have been added to this
		// group while it was off map.
		for (id in this._proxyLayerGroups) {
			group = this._proxyLayerGroups[id];
			map._originalAddLayer(group);
		}

		// Remove proxy Layer Groups that may have been removed from this
		// group while it was off map.
		for (id in this._proxyLayerGroupsNeedRemoving) {
			group = this._proxyLayerGroupsNeedRemoving[id];
			map._originalRemoveLayer(group);
			delete this._proxyLayerGroupsNeedRemoving[id];
		}

		// Restore Layers.
		for (i = 0; i < toBeReAdded.length; i++) {
			map.addLayer(toBeReAdded[i]);
		}
	},
	_originalOnAdd: L.MarkerClusterGroup.prototype.onAdd,

	// Do not restore the original map methods when removing the group from it.
	// Leaving them as-is does not harm, whereas restoring the original ones
	// may kill the functionality of potential other LayerSupport groups on
	// the same map. Therefore we do not need to override onRemove.

	_bufferSingleAddRemove: function (layer, operationType) {
		var duration = this.options.singleAddRemoveBufferDuration,
		    fn;

		if (duration > 0) {
			this._singleAddRemoveBuffer.push({
				type: operationType,
				layer: layer
			});

			if (!this._singleAddRemoveBufferTimeout) {
				fn = L.bind(this._processSingleAddRemoveBuffer, this);

				this._singleAddRemoveBufferTimeout = setTimeout(fn, duration);
			}
		} else { // If duration <= 0, process synchronously.
			this[operationType](layer);
		}
	},
	_processSingleAddRemoveBuffer: function () {
		// For now, simply cut the processes at each operation change
		// (addLayers, removeLayers).
		var singleAddRemoveBuffer = this._singleAddRemoveBuffer,
		    i = 0,
		    layersBuffer = [],
		    currentOperation,
		    currentOperationType;

		for (; i < singleAddRemoveBuffer.length; i++) {
			currentOperation = singleAddRemoveBuffer[i];
			if (!currentOperationType) {
				currentOperationType = currentOperation.type;
			}
			if (currentOperation.type === currentOperationType) {
				layersBuffer.push(currentOperation.layer);
			} else {
				this[currentOperationType](layersBuffer);
				currentOperationType = currentOperation.type;
				layersBuffer = [currentOperation.layer];
			}
		}
		this[currentOperationType](layersBuffer);
		singleAddRemoveBuffer.length = 0;
		clearTimeout(this._singleAddRemoveBufferTimeout);
		this._singleAddRemoveBufferTimeout = null;
	},

	_checkInGetSeparated: function (layersArray) {
		var separated = this._separateSingleFromGroupLayers(layersArray, {
		        groups: [],
		        singles: []
		    }),
		    groups = separated.groups,
		    singles = separated.singles,
		    i, layer;

		// Recruit Layer Groups.
		// If they do not already belong to this group, they will be
		// removed from map (together will all child layers).
		for (i = 0; i < groups.length; i++) {
			layer = groups[i];
			this._recruitLayerGroupAsProxy(layer);
		}

		// Stamp single layers.
		for (i = 0; i < singles.length; i++) {
			layer = singles[i];

			// Remove from previous group first.
			this._removeFromOtherGroupsOrMap(layer);

			this._layers[L.stamp(layer)] = layer;
			layer._mcgLayerSupportGroup = this;
		}

		return separated;
	},

	_separateSingleFromGroupLayers: function (inputLayers, output) {
		var groups = output.groups,
		    singles = output.singles,
		    isArray = L.Util.isArray,
		    layer;

		for (var i = 0; i < inputLayers.length; i++) {
			layer = inputLayers[i];

			if (layer instanceof L.LayerGroup) {
				groups.push(layer);
				this._separateSingleFromGroupLayers(layer.getLayers(), output);
				continue;
			} else if (isArray(layer)) {
				this._separateSingleFromGroupLayers(layer, output);
				continue;
			}

			singles.push(layer);
		}

		return output;
	},

	// Recruit the LayerGroup as a proxy, so that any layer that is added
	// to / removed from that group later on is also added to / removed from
	// this group.
	// Check in and addition of already contained markers must be taken care
	// of externally.
	_recruitLayerGroupAsProxy: function (layerGroup) {
		var otherMcgLayerSupportGroup = layerGroup._proxyMcgLayerSupportGroup;

		// If it is not yet in this group, remove it from previous group
		// or from map.
		if (otherMcgLayerSupportGroup) {
			if (otherMcgLayerSupportGroup === this) {
				return;
			}
			// Remove from previous Layer Support group first.
			// It will also be removed from map with child layers.
			otherMcgLayerSupportGroup.checkOut(layerGroup);
		} else {
			this._removeFromOwnMap(layerGroup);
		}

		layerGroup._proxyMcgLayerSupportGroup = this;
		layerGroup._originalAddLayer =
			layerGroup._originalAddLayer || layerGroup.addLayer;
		layerGroup._originalRemoveLayer =
			layerGroup._originalRemoveLayer || layerGroup.removeLayer;
		L.extend(layerGroup, _proxyLayerGroup);
	},

	// Restore the normal LayerGroup behaviour.
	// Removal and check out of contained markers must be taken care of externally.
	_dismissProxyLayerGroup: function (layerGroup) {
		if (layerGroup._proxyMcgLayerSupportGroup === undefined ||
			layerGroup._proxyMcgLayerSupportGroup !== this) {

			return;
		}

		delete layerGroup._proxyMcgLayerSupportGroup;
		layerGroup.addLayer = layerGroup._originalAddLayer;
		layerGroup.removeLayer = layerGroup._originalRemoveLayer;

		var id = L.stamp(layerGroup);
		delete this._proxyLayerGroups[id];
		delete this._proxyLayerGroupsNeedRemoving[id];

		this._removeFromOwnMap(layerGroup);
	},

	_removeFromOtherGroupsOrMap: function (layer) {
		var otherMcgLayerSupportGroup = layer._mcgLayerSupportGroup;

		if (otherMcgLayerSupportGroup) { // It is a Layer Support group.
			if (otherMcgLayerSupportGroup === this) {
				return;
			}
			otherMcgLayerSupportGroup.checkOut(layer);

		} else if (layer.__parent) { // It is in a normal MCG.
			layer.__parent._group.removeLayer(layer);

		} else { // It could still be on a map.
			this._removeFromOwnMap(layer);
		}
	},

	// Remove layers that are being checked in, because they can now cluster.
	_removeFromOwnMap: function (layer) {
		if (layer._map) {
			// This correctly fires layerremove event for Layer Groups as well.
			layer._map.removeLayer(layer);
		}
	},

	// In case checked in layers have been added to map whereas map is not redirected.
	_removePreAddedLayers: function (map) {
		var layers = this._layers,
		    toBeReAdded = [],
		    layer;

		for (var id in layers) {
			layer = layers[id];
			if (layer._map) {
				toBeReAdded.push(layer);
				map._originalRemoveLayer(layer);
			}
		}

		return toBeReAdded;
	},

	_toArray: function (item) {
		return L.Util.isArray(item) ? item : [item];
	}

});

/**
 * Extends the FeatureGroup by overriding add/removal methods that directly
 * access the map original methods, bypassing the switch agent.
 * Used internally in Layer Support for _featureGroup and _nonPointGroup only.
 * @type {L.FeatureGroup}
 * @private
 */
var _ByPassingFeatureGroup = L.FeatureGroup.extend({

	// Re-implement just to change the map method.
	addLayer: function (layer) {
		if (this.hasLayer(layer)) {
			return this;
		}

		layer.addEventParent(this);

		var id = L.stamp(layer);

		this._layers[id] = layer;

		if (this._map) {
			// Use the original map addLayer.
			this._map._originalAddLayer(layer);
		}

		return this.fire('layeradd', {layer: layer});
	},

	// Re-implement just to change the map method.
	removeLayer: function (layer) {
		if (!this.hasLayer(layer)) {
			return this;
		}
		if (layer in this._layers) {
			layer = this._layers[layer];
		}

		layer.removeEventParent(this);

		var id = L.stamp(layer);

		if (this._map && this._layers[id]) {
			// Use the original map removeLayer.
			this._map._originalRemoveLayer(this._layers[id]);
		}

		delete this._layers[id];

		return this.fire('layerremove', {layer: layer});
	},

	onAdd: function (map) {
		this._map = map;
		// Use the original map addLayer.
		this.eachLayer(map._originalAddLayer, map);
	},

	onRemove: function (map) {
		// Use the original map removeLayer.
		this.eachLayer(map._originalRemoveLayer, map);
		this._map = null;
	}

});

/**
 * Toolbox to equip LayerGroups recruited as proxy.
 * @type {{addLayer: Function, removeLayer: Function}}
 * @private
 */
var _proxyLayerGroup = {

	// Re-implement to redirect addLayer to Layer Support group instead of map.
	addLayer: function (layer) {
		var id = this.getLayerId(layer);

		this._layers[id] = layer;

		if (this._map) {
			this._proxyMcgLayerSupportGroup.addLayer(layer);
		} else {
			this._proxyMcgLayerSupportGroup.checkIn(layer);
		}

		return this;
	},

	// Re-implement to redirect removeLayer to Layer Support group instead of map.
	removeLayer: function (layer) {

		var id = layer in this._layers ? layer : this.getLayerId(layer);

		this._proxyMcgLayerSupportGroup.removeLayer(layer);

		delete this._layers[id];

		return this;
	},

	// Make sure it uses addLayers when added to map.
	onAdd: function () {
		this._proxyMcgLayerSupportGroup.addLayers(this.getLayers());
	},

	// Make sure it uses removeLayers when removed from map.
	onRemove: function () {
		this._proxyMcgLayerSupportGroup.removeLayers(this.getLayers());
	}

};

/**
 * Toolbox to equip the Map with a switch agent that redirects layers
 * addition/removal to their Layer Support group when defined.
 * @type {{addLayer: Function, removeLayer: Function}}
 * @private
 */
var _layerSwitchMap = {

	addLayer: function (layer) {
		if (layer._mcgLayerSupportGroup) {
			// Use the original MCG addLayer.
			return layer._mcgLayerSupportGroup._originalAddLayer(layer);
		}

		return this._originalAddLayer(layer);
	},

	removeLayer: function (layer) {
		if (layer._mcgLayerSupportGroup) {
			// Use the original MCG removeLayer.
			return layer._mcgLayerSupportGroup._originalRemoveLayer(layer);
		}

		return this._originalRemoveLayer(layer);
	}

};

// Supply with a factory for consistency with Leaflet.
L.markerClusterGroup.layerSupport = function (options) {
	return new L.MarkerClusterGroup.LayerSupport(options);
};



}));

//# sourceMappingURL=leaflet.markercluster.layersupport-src.js.map