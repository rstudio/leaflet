function recycle(values, length, inPlace) {
  if (length === 0 && !inPlace)
    return [];

  if (!(values instanceof Array)) {
    if (inPlace) {
      throw new Error("Can't do in-place recycling of a non-Array value");
    }
    values = [values];
  }
  if (typeof(length) === 'undefined')
    length = values.length;

  var dest = inPlace ? values : [];
  var origLength = values.length;
  while (dest.length < length) {
    dest.push(values[dest.length % origLength]);
  }
  if (dest.length > length) {
    dest.splice(length, dest.length - length);
  }
  return dest;
}

function asArray(value) {
  if (value instanceof Array)
    return value;
  else
    return [value];
}

var dataframe = (function() {
  var exports = {};

  var DataFrame = function() {
    this.columns = [];
    this.colnames = [];
    this.colstrict = [];

    this.effectiveLength = 0;
    this.colindices = {};
  };

  DataFrame.prototype._updateCachedProperties = function() {
    var self = this;
    this.effectiveLength = 0;
    this.colindices = {};

    $.each(this.columns, function(i, column) {
      self.effectiveLength = Math.max(self.effectiveLength, column.length);
      self.colindices[self.colnames[i]] = i;
    });
  };

  DataFrame.prototype._colIndex = function(colname) {
    var index = this.colindices[colname];
    if (typeof(index) === 'undefined')
      return -1;
    return index;
  };

  DataFrame.prototype.col = function(name, values, strict) {
    if (typeof(name) !== 'string')
      throw new Error('Invalid column name "' + name + '"');

    var index = this._colIndex(name);

    if (arguments.length === 1) {
      if (index < 0)
        return null;
      else
        return recycle(this.columns[index], this.effectiveLength);
    }

    if (index < 0) {
      index = this.colnames.length;
      this.colnames.push(name);
    }
    this.columns[index] = asArray(values);
    this.colstrict[index] = !!strict;

    // TODO: Validate strictness (ensure lengths match up with other stricts)

    this._updateCachedProperties();

    return this;
  };

  DataFrame.prototype.cbind = function(obj, strict) {
    var self = this, name;
    $.each(obj, function(name, coldata) {
      self.col(name, coldata);
    });
    return this;
  };

  DataFrame.prototype.get = function(row, col) {
    var self = this;

    if (row > this.effectiveLength)
      throw new Error('Row argument was out of bounds: ' + row + ' > ' + this.effectiveLength);

    var colIndex = -1;
    if (typeof(col) === 'undefined') {
      var rowData = {};
      $.each(this.colnames, function(i, name) {
        rowData[name] = self.columns[i][row % self.columns[i].length];
      });
      return rowData;
    } else if (typeof(col) === 'string') {
      colIndex = this._colIndex(col);
    } else if (typeof(col) === 'number') {
      colIndex = col;
    }
    if (colIndex < 0 || colIndex > this.columns.length)
      throw new Error('Unknown column index: ' + col);

    return this.columns[colIndex][row % this.columns[colIndex].length];
  };

  DataFrame.prototype.nrow = function() {
    return this.effectiveLength;
  };

  function test() {
    var df = new DataFrame();
    df.col("speed", [4, 4, 7, 7, 8, 9, 10, 10, 10, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 16, 16, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 20, 20, 20, 20, 20, 22, 23, 24, 24, 24, 24, 25])
      .col("dist", [2, 10, 4, 22, 16, 10, 18, 26, 34, 17, 28, 14, 20, 24, 28, 26, 34, 34, 46, 26, 36, 60, 80, 20, 26, 54, 32, 40, 32, 40, 50, 42, 56, 76, 84, 36, 46, 68, 32, 48, 52, 56, 64, 66, 54, 70, 92, 93, 120, 85])
      .col("color", ["yellow", "red"])
      .cbind({
        "Make" : ["Toyota", "Cadillac", "BMW"],
        "Model" : ["Corolla", "CTS", "435i"]
      })
    ;
    console.log(df.get(9, "speed"));
    console.log(df.get(9, "dist"));
    console.log(df.get(9, "color"));
    console.log(df.get(9, "Make"));
    console.log(df.get(9, "Model"));
    console.log(df.get(9));

  }

  return {
    create: function() {
      return new DataFrame();
    }
  };

})();

(function() {
  // This class simulates a mipmap, which shrinks images by powers of two. This
  // stepwise reduction results in "pixel-perfect downscaling" (where every
  // pixel of the original image has some contribution to the downscaled image)
  // as opposed to a single-step downscaling which will discard a lot of data
  // (and with sparse images at small scales can give very surprising results).
  function Mipmapper(img) {
    this._layers = [img];
  }
  // The various functions on this class take a callback function BUT MAY OR MAY
  // NOT actually behave asynchronously.
  Mipmapper.prototype.getBySize = function(desiredWidth, desiredHeight, callback) {
    var self = this;
    var i = 0;
    var lastImg = this._layers[0];
    function testNext() {
      self.getByIndex(i, function(img) {
        // If current image is invalid (i.e. too small to be rendered) or
        // it's smaller than what we wanted, return the last known good image.
        if (!img || img.width < desiredWidth || img.height < desiredHeight) {
          callback(lastImg);
          return;
        } else {
          lastImg = img;
          i++;
          testNext();
          return;
        }
      });
    }
    testNext();
  };
  Mipmapper.prototype.getByIndex = function(i, callback) {
    var self = this;
    if (this._layers[i]) {
      callback(this._layers[i]);
      return;
    }

    this.getByIndex(i-1, function(prevImg) {
      if (!prevImg) {
        // prevImg could not be calculated (too small, possibly)
        callback(null);
        return;
      }
      if (prevImg.width < 2 || prevImg.height < 2) {
        // Can't reduce this image any further
        callback(null);
        return;
      }
      // If reduce ever becomes truly asynchronous, we should stuff a promise or
      // something into self._layers[i] before calling self.reduce(), to prevent
      // redundant reduce operations from happening.
      self.reduce(prevImg, function(reducedImg) {
        self._layers[i] = reducedImg;
        callback(reducedImg);
        return;
      });
    });
  };
  Mipmapper.prototype.reduce = function(img, callback) {
      var imgDataCanvas = document.createElement("canvas");
      imgDataCanvas.width = Math.ceil(img.width / 2);
      imgDataCanvas.height = Math.ceil(img.height / 2);
      imgDataCanvas.style.display = "none";
      document.body.appendChild(imgDataCanvas);
      try {
        var imgDataCtx = imgDataCanvas.getContext("2d");
        imgDataCtx.drawImage(img, 0, 0, img.width/2, img.height/2);
        callback(imgDataCanvas);
      } finally {
        document.body.removeChild(imgDataCanvas);
      }

  };

  function LayerManager(map) {
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

    // END layer indices

    // {<categoryName>: L.layerGroup}
    this._categoryContainers = {};
    // {<groupName>: L.layerGroup}
    this._groupContainers = {};
  }
  LayerManager.prototype.addLayer = function(layer, category, layerId, group) {
    // Was a group provided?
    var hasId = typeof(layerId) === "string";
    var grouped = typeof(group) === "string";

    var stamp = L.Util.stamp(layer);

    // This will be the default layer group to add the layer to.
    // We may overwrite this var before using it (i.e. if a group is assigned).
    // This one liner creates the _categoryContainers[category] entry if it
    // doesn't already exist.
    var container = this._categoryContainers[category] =
        this._categoryContainers[category] || L.layerGroup().addTo(this._map);

    var oldLayer = null;
    if (hasId) {
      // First, remove any layer with the same category and layerId
      var prefixedLayerId = this._layerIdKey(category, layerId);
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
    this._byStamp[stamp] = {
      layer: layer,
      group: group,
      layerId: layerId,
      category: category,
      container: container
    };

    // Add to container
    container.addLayer(layer);

    return oldLayer;
  };
  LayerManager.prototype.getLayer = function(category, layerId) {
    return this._byLayerId[this._layerIdKey(category, layerId)];
  };
  LayerManager.prototype.removeLayer = function(category, layerId) {
    // Find layer info
    var layer = this._byLayerId[this._layerIdKey(category, layerId)];
    if (!layer) {
      return false;
    }
    this._removeLayer(layer);
    return true;
  };
  LayerManager.prototype.clearLayers = function(category) {
    var self = this;

    // Find all layers in _byCategory[category]
    var catTable = this._byCategory[category];
    if (!catTable) {
      return false;
    }

    // Remove all layers. Make copy of keys to avoid mutating the collection
    // behind the iterator you're accessing.
    var stamps = [];
    $.each(catTable, function(k, v) {
      stamps.push(k);
    });
    $.each(stamps, function(i, stamp) {
      self._removeLayer(stamp);
    });
  };
  LayerManager.prototype.getLayerGroup = function(group, ensureExists) {
    var g = this._groupContainers[group];
    if (ensureExists && !g) {
      this._byGroup[group] = this._byGroup[group] || {};
      g = this._groupContainers[group] = L.layerGroup();
      g.groupname = group;
      g.addTo(this._map);
    }
    return g;
  };
  LayerManager.prototype.getGroupNameFromLayerGroup = function(layerGroup) {
    return layerGroup.groupname;
  };
  LayerManager.prototype.getVisibleGroups = function() {
    var self = this;
    var result = [];
    $.each(this._groupContainers, function(k, v) {
      if (self._map.hasLayer(v)) {
        result.push(k);
      }
    });
    return result;
  };
  LayerManager.prototype.clearGroup = function(group) {
    var self = this;

    // Find all layers in _byGroup[group]
    var groupTable = this._byGroup[group];
    if (!groupTable) {
      return false;
    }

    // Remove all layers. Make copy of keys to avoid mutating the collection
    // behind the iterator you're accessing.
    var stamps = [];
    $.each(groupTable, function(k, v) {
      stamps.push(k);
    });
    $.each(stamps, function(i, stamp) {
      self._removeLayer(stamp);
    });
  };
  LayerManager.prototype.clear = function() {
    function clearLayerGroup(key, layerGroup) {
      layerGroup.clearLayers();
    }
    // Clear all indices and layerGroups
    this._byGroup = {};
    this._byCategory = {};
    this._byLayerId = {};
    this._byStamp = {};
    $.each(this._categoryContainers, clearLayerGroup);
    this._categoryContainers = {};
    $.each(this._groupContainers, clearLayerGroup);
    this._groupContainers = {};
  };
  LayerManager.prototype._removeLayer = function(layer) {
    var stamp;
    if (typeof(layer) === "string") {
      stamp = layer;
    } else {
      stamp = L.Util.stamp(layer);
    }

    var layerInfo = this._byStamp[stamp];
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
  };
  LayerManager.prototype._layerIdKey = function(category, layerId) {
    return category + "\n" + layerId;
  };

  function ControlStore(map) {
    this._controlsNoId = [];
    this._controlsById = {};
    this._map = map
  }

  ControlStore.prototype.add = function(control, id, html) {
    if (typeof(id) !== 'undefined' && id !== null) {
      if (this._controlsById[id]) {
        this._map.removeControl(this._controlsById[id]);
      }
      this._controlsById[id] = control;
    } else {
      this._controlsNoId.push(control)
    }
    this._map.addControl(control);
  };

  ControlStore.prototype.remove = function(id) {
    if (this._controlsById[id]) {
      var control = this._controlsById[id];
      this._map.removeControl(control);
      delete this._controlsById[id];
    }
  };

  ControlStore.prototype.clear = function() {
    for (var i = 0; i < this._controlsNoId.length; i++) {
      var control = this._controlsNoId[i];
      this._map.removeControl(control);
    };
    this._controlsNoId = [];

    for (var key in this._controlsById) {
      var control = this._controlsById[key];
      this._map.removeControl(control)
    }
    this._controlsById = {}
  }

  function ClusterLayerStore(group) {
    this._layers = {};
    this._group = group;
  }

  ClusterLayerStore.prototype.add = function(layer, id) {
    if (typeof(id) !== 'undefined' && id !== null) {
      if (this._layers[id]) {
        this._group.removeLayer(this._layers[id]);
      }
      this._layers[id] = layer;
    }
    this._group.addLayer(layer);
  };

  ClusterLayerStore.prototype.remove = function(id) {
    if (typeof(id) === 'undefined' || id === null) {
      return;
    }

    id = asArray(id);
    for (var i = 0; i < id.length; i++) {
      if (this._layers[id[i]]) {
        this._group.removeLayer(this._layers[id[i]]);
        delete this._layers[id[i]];
      }
    }
  };

  ClusterLayerStore.prototype.clear = function() {
    this._layers = {};
    this._group.clearLayers();
  };

  function mouseHandler(mapId, layerId, group, eventName, extraInfo) {
    return function(e) {
      if (!HTMLWidgets.shinyMode) return;

      var eventInfo = $.extend(
        {
          id: layerId,
          '.nonce': Math.random()  // force reactivity
        },
        group !== null ? {group: group} : null,
        e.target.getLatLng ? e.target.getLatLng() : e.latlng,
        extraInfo
      );

      Shiny.onInputChange(mapId + '_' + eventName, eventInfo);
    };
  }

  // Send updated bounds back to app. Takes a leaflet event object as input.
  function updateBounds(map) {
    var id = map.getContainer().id;
    var bounds = map.getBounds();

    Shiny.onInputChange(id + '_bounds', {
      north: bounds.getNorthEast().lat,
      east: bounds.getNorthEast().lng,
      south: bounds.getSouthWest().lat,
      west: bounds.getSouthWest().lng
    });
    Shiny.onInputChange(id + '_zoom', map.getZoom());
  }

  window.LeafletWidget = {};
  var methods = window.LeafletWidget.methods = {};

  methods.clearGroup = function(group) {
    var self = this;
    $.each(asArray(group), function(i, v) {
      self.layerManager.clearGroup(v);
    });
  };

  methods.setView = function(center, zoom, options) {
    this.setView(center, zoom, options);
  };

  methods.fitBounds = function(lat1, lng1, lat2, lng2) {
    this.fitBounds([
      [lat1, lng1], [lat2, lng2]
    ]);
  };

  methods.setMaxBounds = function(lat1, lng1, lat2, lng2) {
    this.setMaxBounds([
      [lat1, lng1], [lat2, lng2]
    ]);
  };

  methods.addPopups = function(lat, lng, popup, layerId, group, options) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('popup', popup)
      .col('layerId', layerId)
      .col('group', group)
      .cbind(options);

    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var popup = L.popup(df.get(i))
                     .setLatLng([df.get(i, 'lat'), df.get(i, 'lng')])
                     .setContent(df.get(i, 'popup'));
        var thisId = df.get(i, 'layerId');
        var thisGroup = df.get(i, 'group');
        this.layerManager.addLayer(popup, "popup", thisId, thisGroup);
        popup.on('click', mouseHandler(this.id, thisId, thisGroup, 'popup_click'), this);
        popup.on('mouseover', mouseHandler(this.id, thisId, thisGroup, 'popup_mouseover'), this);
        popup.on('mouseout', mouseHandler(this.id, thisId, thisGroup, 'popup_mouseout'), this);
      }).call(this);
    }
  };

  methods.removePopup = function(layerId) {
    this.layerManager.removeLayer("popup", layerId);
  };

  methods.clearPopups = function() {
    this.layerManager.clearLayers("popup");
  };

  methods.addTiles = function(urlTemplate, layerId, group, options) {
    this.layerManager.addLayer(L.tileLayer(urlTemplate, options), "tile", layerId, group);
  };

  methods.removeTiles = function(layerId) {
    this.layerManager.removeLayer("tile", layerId);
  };

  methods.clearTiles = function() {
    this.layerManager.clearLayers("tile");
  };

  methods.addWMSTiles = function(baseUrl, layerId, group, options) {
    this.layerManager.addLayer(L.tileLayer.wms(baseUrl, options), "tile", layerId, group);
  };

  // Given:
  //   {data: ["a", "b", "c"], index: [0, 1, 0, 2]}
  // returns:
  //   ["a", "b", "a", "c"]
  function unpackStrings(iconset) {
    if (!iconset) {
      return iconset;
    }
    if (typeof(iconset.index) === 'undefined') {
      return iconset;
    }

    iconset.data = asArray(iconset.data);
    iconset.index = asArray(iconset.index);

    return $.map(iconset.index, function(e, i) {
      return iconset.data[e];
    });
  }

  function addMarkers(map, df, group, clusterOptions, clusterId, markerFunc) {
    (function() {
      var clusterGroup = this.layerManager.getLayer("cluster", clusterId),
          cluster = clusterOptions !== null;
      if (cluster && !clusterGroup) {
        clusterGroup = L.markerClusterGroup(clusterOptions);
        clusterGroup.clusterLayerStore = new ClusterLayerStore(clusterGroup);
      }
      var extraInfo = cluster ? { clusterId: clusterId } : {};

      for (var i = 0; i < df.nrow(); i++) {
        (function() {
          var marker = markerFunc(df, i);
          var thisId = df.get(i, 'layerId');
          var thisGroup = cluster ? null : df.get(i, 'group');
          if (cluster) {
            clusterGroup.clusterLayerStore.add(marker, thisId);
          } else {
            this.layerManager.addLayer(marker, "marker", thisId, thisGroup);
          }
          var popup = df.get(i, 'popup');
          if (popup !== null) marker.bindPopup(popup);
          marker.on('click', mouseHandler(this.id, thisId, thisGroup, 'marker_click', extraInfo), this);
          marker.on('mouseover', mouseHandler(this.id, thisId, thisGroup, 'marker_mouseover', extraInfo), this);
          marker.on('mouseout', mouseHandler(this.id, thisId, thisGroup, 'marker_mouseout', extraInfo), this);
        }).call(this);
      }

      if (cluster) {
        this.layerManager.addLayer(clusterGroup, "cluster", clusterId, group);
      }
    }).call(map);
  }

  methods.addMarkers = function(lat, lng, icon, layerId, group, options, popup,
                                clusterOptions, clusterId) {
    if (icon) {
      // Unpack icons
      icon.iconUrl         = unpackStrings(icon.iconUrl);
      icon.iconRetinaUrl   = unpackStrings(icon.iconRetinaUrl);
      icon.shadowUrl       = unpackStrings(icon.shadowUrl);
      icon.shadowRetinaUrl = unpackStrings(icon.shadowRetinaUrl);

      // This cbinds the icon URLs and any other icon options; they're all
      // present on the icon object.
      var icondf = dataframe.create().cbind(icon);

      // Constructs an icon from a specified row of the icon dataframe.
      var getIcon = function(i) {
        var opts = icondf.get(i);
        if (!opts.iconUrl) {
          return new L.Icon.Default();
        }

        // Composite options (like points or sizes) are passed from R with each
        // individual component as its own option. We need to combine them now
        // into their composite form.
        if (opts.iconWidth) {
          opts.iconSize = [opts.iconWidth, opts.iconHeight];
        }
        if (opts.shadowWidth) {
          opts.shadowSize = [opts.shadowWidth, opts.shadowHeight];
        }
        if (opts.iconAnchorX) {
          opts.iconAnchor = [opts.iconAnchorX, opts.iconAnchorY];
        }
        if (opts.shadowAnchorX) {
          opts.shadowAnchor = [opts.shadowAnchorX, opts.shadowAnchorY];
        }
        if (opts.popupAnchorX) {
          opts.popupAnchor = [opts.popupAnchorX, opts.popupAnchorY];
        }

        return new L.Icon(opts);
      };
    }

    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('layerId', layerId)
      .col('group', group)
      .col('popup', popup)
      .cbind(options);

    if (icon) icondf.effectiveLength = df.nrow();

    addMarkers(this, df, group, clusterOptions, clusterId, function(df, i) {
      var options = df.get(i);
      if (icon) options.icon = getIcon(i);
      return L.marker([df.get(i, 'lat'), df.get(i, 'lng')], options);
    });
  };

  addLayers = function(map, category, df, layerFunc) {
    for (var i = 0; i < df.nrow(); i++) {
      (function() {
        var layer = layerFunc(df, i);
        var thisId = df.get(i, 'layerId');
        var thisGroup = df.get(i, 'group');
        this.layerManager.addLayer(layer, category, thisId, thisGroup);
        if (layer.bindPopup) {
          var popup = df.get(i, 'popup');
          if (popup !== null) layer.bindPopup(popup);
        }
        layer.on('click', mouseHandler(this.id, thisId, thisGroup, category + '_click'), this);
        layer.on('mouseover', mouseHandler(this.id, thisId, thisGroup, category + '_mouseover'), this);
        layer.on('mouseout', mouseHandler(this.id, thisId, thisGroup, category + '_mouseout'), this);
      }).call(map);
    }
  }

  methods.addCircles = function(lat, lng, radius, layerId, group, options, popup) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('radius', radius)
      .col('layerId', layerId)
      .col('group', group)
      .col('popup', popup)
      .cbind(options);

    addLayers(this, "shape", df, function(df, i) {
      return L.circle([df.get(i, 'lat'), df.get(i, 'lng')], df.get(i, 'radius'), df.get(i));
    });
  };

  methods.addCircleMarkers = function(lat, lng, radius, layerId, group, options, clusterOptions, clusterId, popup) {
    var df = dataframe.create()
      .col('lat', lat)
      .col('lng', lng)
      .col('radius', radius)
      .col('layerId', layerId)
      .col('group', group)
      .col('popup', popup)
      .cbind(options);

    addMarkers(this, df, group, clusterOptions, clusterId, function(df, i) {
      return L.circleMarker([df.get(i, 'lat'), df.get(i, 'lng')], df.get(i));
    });
  };

  /*
   * @param lat Array of arrays of latitude coordinates for polylines
   * @param lng Array of arrays of longitude coordinates for polylines
   */
  methods.addPolylines = function(polygons, layerId, group, options, popup) {
    var df = dataframe.create()
      .col('shapes', polygons)
      .col('layerId', layerId)
      .col('group', group)
      .col('popup', popup)
      .cbind(options);

    addLayers(this, "shape", df, function(df, i) {
        var shape = df.get(i, 'shapes')[0];
        shape = HTMLWidgets.dataframeToD3(shape);
        return L.polyline(shape, df.get(i));
    });
  };

  methods.removeMarker = function(layerId) {
    this.layerManager.removeLayer("marker", layerId);
  };

  methods.clearMarkers = function() {
    this.layerManager.clearLayers("marker");
  };

  methods.removeMarkerCluster = function(layerId) {
    this.layerManager.removeLayer("cluster", layerId);
  }

  methods.removeMarkerFromCluster = function(layerId, clusterId) {
    var cluster = this.layerManager.getLayer("cluster", clusterId);
    if (!cluster) return;
    cluster.clusterLayerStore.remove(layerId);
  }

  methods.clearMarkerClusters = function() {
    this.layerManager.clearLayers("cluster");
  };

  methods.removeShape = function(layerId) {
    this.layerManager.removeLayer("shape", layerId);
  };

  methods.clearShapes = function() {
    this.layerManager.clearLayers("shape");
  };

  methods.addRectangles = function(lat1, lng1, lat2, lng2, layerId, group, options, popup) {
    var df = dataframe.create()
      .col('lat1', lat1)
      .col('lng1', lng1)
      .col('lat2', lat2)
      .col('lng2', lng2)
      .col('layerId', layerId)
      .col('group', group)
      .col('popup', popup)
      .cbind(options);

    addLayers(this, "shape", df, function(df, i) {
      return L.rectangle([
          [df.get(i, 'lat1'), df.get(i, 'lng1')],
          [df.get(i, 'lat2'), df.get(i, 'lng2')]
        ],
        df.get(i));
    });
  };

  /*
   * @param lat Array of arrays of latitude coordinates for polygons
   * @param lng Array of arrays of longitude coordinates for polygons
   */
  methods.addPolygons = function(polygons, layerId, group, options, popup) {
    var df = dataframe.create()
      .col('shapes', polygons)
      .col('layerId', layerId)
      .col('group', group)
      .col('popup', popup)
      .cbind(options);

    addLayers(this, "shape", df, function(df, i) {
      var shapes = df.get(i, 'shapes');
      for (var j = 0; j < shapes.length; j++) {
        shapes[j] = HTMLWidgets.dataframeToD3(shapes[j]);
      }
      return L.polygon(shapes, df.get(i));
    });
  };

  methods.addGeoJSON = function(data, layerId, group, style) {
    var self = this;
    if (typeof(data) === "string") {
      data = JSON.parse(data);
    }

    var globalStyle = $.extend({}, style, data.style || {});

    var gjlayer = L.geoJson(data, {
      style: function(feature) {
        if (feature.style || feature.properties.style) {
          return $.extend({}, globalStyle, feature.style, feature.properties.style);
        } else {
          return globalStyle;
        }
      },
      onEachFeature: function(feature, layer) {
        var extraInfo = {
          featureId: feature.id,
          properties: feature.properties
        };
        var popup = feature.properties.popup;
        if (typeof popup !== 'undefined' && popup !== null) layer.bindPopup(popup);
        layer.on("click", mouseHandler(self.id, layerId, group, "geojson_click", extraInfo), this);
        layer.on("mouseover", mouseHandler(self.id, layerId, group, "geojson_mouseover", extraInfo), this);
        layer.on("mouseout", mouseHandler(self.id, layerId, group, "geojson_mouseout", extraInfo), this);
      }
    });
    this.layerManager.addLayer(gjlayer, "geojson", layerId, group);
  };

  methods.removeGeoJSON = function(layerId) {
    this.layerManager.removeLayer("geojson", layerId);
  };

  methods.clearGeoJSON = function() {
    this.layerManager.clearLayers("geojson");
  };

  methods.addTopoJSON = function(data, layerId, group, style) {
    var self = this;
    if (typeof(data) === "string") {
      data = JSON.parse(data);
    }

    var globalStyle = $.extend({}, style, data.style || {});

    var gjlayer = L.geoJson(null, {
      style: function(feature) {
        if (feature.style || feature.properties.style) {
          return $.extend({}, globalStyle, feature.style, feature.properties.style);
        } else {
          return globalStyle;
        }
      },
      onEachFeature: function(feature, layer) {
        var extraInfo = {
          featureId: feature.id,
          properties: feature.properties
        };
        var popup = feature.properties.popup;
        if (typeof popup !== 'undefined' && popup !== null) layer.bindPopup(popup);
        layer.on("click", mouseHandler(self.id, layerId, group, "topojson_click", extraInfo), this);
        layer.on("mouseover", mouseHandler(self.id, layerId, group, "topojson_mouseover", extraInfo), this);
        layer.on("mouseout", mouseHandler(self.id, layerId, group, "topojson_mouseout", extraInfo), this);
      }
    });
    omnivore.topojson.parse(data, null, gjlayer);
    this.layerManager.addLayer(gjlayer, "topojson", layerId, group);
  };

  methods.removeTopoJSON = function(layerId) {
    this.layerManager.removeLayer("topojson", layerId);
  };

  methods.clearTopoJSON = function() {
    this.layerManager.clearLayers("topojson");
  };

  methods.addControl = function(html, position, layerId, classes) {
    function onAdd(map) {
      var div = L.DomUtil.create('div', classes);
      if (typeof layerId !== 'undefined' && layerId !== null) {
        div.setAttribute('id', layerId)
      }
      this._div = div;

      // It's possible for window.Shiny to be true but Shiny.initializeInputs to
      // not be, when a static leaflet widget is included as part of the shiny
      // UI directly (not through leafletOutput or uiOutput). In this case we
      // don't do the normal Shiny stuff as that will all happen when Shiny
      // itself loads and binds the entire doc.

      if (window.Shiny && Shiny.initializeInputs) {
        Shiny.renderHtml(html, this._div);
        Shiny.initializeInputs(this._div);
        Shiny.bindAll(this._div);
      } else {
        this._div.innerHTML = html;
      }

      return this._div;
    }
    function onRemove(map) {
      if (window.Shiny && Shiny.unbindAll) {
        Shiny.unbindAll(this._div);
      }
    }
    var Control = L.Control.extend({
      options: {position: position},
      onAdd: onAdd,
      onRemove: onRemove
    })
    this.controls.add(new Control, layerId, html);
  };

  methods.removeControl = function(layerId) {
    this.controls.remove(layerId);
  };

  methods.clearControls = function() {
    this.controls.clear();
  };

  methods.addLegend = function(options) {
    var legend = L.control({position: options.position});
    var gradSpan;

    legend.onAdd = function (map) {
      var div = L.DomUtil.create('div', options.className),
          colors = options.colors,
          labels = options.labels,
          legendHTML = '';
      if (options.type === 'numeric') {
        // # Formatting constants.
        var singleBinHeight = 20;  // The distance between tick marks, in px
        var vMargin = 8; // If 1st tick mark starts at top of gradient, how
                         // many extra px are needed for the top half of the
                         // 1st label? (ditto for last tick mark/label)
        var tickWidth = 4;     // How wide should tick marks be, in px?
        var labelPadding = 6;  // How much distance to reserve for tick mark?
                               // (Must be >= tickWidth)

        // # Derived formatting parameters.

        // What's the height of a single bin, in percentage (of gradient height)?
        // It might not just be 1/(n-1), if the gradient extends past the tick
        // marks (which can be the case for pretty cut points).
        var singleBinPct = (options.extra.p_n - options.extra.p_1) / (labels.length - 1);
        // Each bin is `singleBinHeight` high. How tall is the gradient?
        var totalHeight = (1 / singleBinPct) * singleBinHeight + 1;
        // How far should the first tick be shifted down, relative to the top
        // of the gradient?
        var tickOffset = (singleBinHeight / singleBinPct) * options.extra.p_1;

        gradSpan = $('<span/>').css({
          'background': 'linear-gradient(' + colors + ')',
          'opacity': options.opacity,
          'height': totalHeight + 'px',
          'width': '18px',
          'display': 'block',
          'margin-top': vMargin + 'px'
        });
        var leftDiv = $('<div/>').css('float', 'left'),
            rightDiv = $('<div/>').css('float', 'left');
        leftDiv.append(gradSpan);
        $(div).append(leftDiv).append(rightDiv)
          .append($("<br clear='both'/>"));

        // Have to attach the div to the body at this early point, so that the
        // svg text getComputedTextLength() actually works, below.
        document.body.appendChild(div);

        var ns = 'http://www.w3.org/2000/svg';
        var svg = document.createElementNS(ns, 'svg');
        rightDiv.append(svg);
        var g = document.createElementNS(ns, 'g');
        $(g).attr("transform", "translate(0, " + vMargin + ")");
        svg.appendChild(g);

        // max label width needed to set width of svg, and right-justify text
        var maxLblWidth = 0;

        // Create tick marks and labels
        $.each(labels, function(i, label) {
          var y = tickOffset + i*singleBinHeight + 0.5;

          var thisLabel = document.createElementNS(ns, 'text');
          $(thisLabel)
            .text(labels[i])
            .attr('y', y)
            .attr('dx', labelPadding)
            .attr('dy', '0.5ex');
          g.appendChild(thisLabel);
          maxLblWidth = Math.max(maxLblWidth, thisLabel.getComputedTextLength());

          var thisTick = document.createElementNS(ns, 'line');
          $(thisTick)
            .attr('x1', 0)
            .attr('x2', tickWidth)
            .attr('y1', y)
            .attr('y2', y)
            .attr('stroke-width', 1);
          g.appendChild(thisTick);
        });

        // Now that we know the max label width, we can right-justify
        $(svg).find('text')
          .attr('dx', labelPadding + maxLblWidth)
          .attr('text-anchor', 'end');
        // Final size for <svg>
        $(svg).css({
          width: (maxLblWidth + labelPadding) + "px",
          height: totalHeight + vMargin*2 + "px"
        });

        if (options.na_color) {
          $(div).append('<div><i style="background:' + options.na_color +
                        '"></i> ' + options.na_label + '</div>');
        }
      } else {
        if (options.na_color) {
          colors.push(options.na_color);
          labels.push(options.na_label);
        }
        for (var i = 0; i < colors.length; i++) {
          legendHTML += '<i style="background:' + colors[i] + ';opacity:' +
                        options.opacity + '"></i> ' + labels[i] + '<br/>';
        }
        div.innerHTML = legendHTML;
      }
      if (options.title)
        $(div).prepend('<div style="margin-bottom:3px"><strong>' +
                        options.title + '</strong></div>');
      return div;
    };

    this.controls.add(legend, options.layerId);
  };

  methods.addLayersControl = function(baseGroups, overlayGroups, options) {

    var self = this;

    // Only allow one layers control at a time
    methods.removeLayersControl.call(this);

    var firstLayer = true;
    var base = {};
    $.each(asArray(baseGroups), function(i, g) {
      var layer = self.layerManager.getLayerGroup(g, true);
      if (layer) {
        base[g] = layer;

        // Check if >1 base layers are visible; if so, hide all but the first one
        if (self.hasLayer(layer)) {
          if (firstLayer) {
            firstLayer = false;
          } else {
            self.removeLayer(layer);
          }
        }
      }
    });
    var overlay = {};
    $.each(asArray(overlayGroups), function(i, g) {
      var layer = self.layerManager.getLayerGroup(g, true);
      if (layer) {
        overlay[g] = layer;
      }
    });

    var layersControl = L.control.layers(base, overlay, options).addTo(this);
    this.currentLayersControl = layersControl;
  };

  methods.removeLayersControl = function() {
    if (this.currentLayersControl) {
      this.currentLayersControl.removeFrom(this);
      this.currentLayersControl = null;
    }
  };

  methods.hideGroup = function(group) {
    var self = this;
    $.each(asArray(group), function(i, g) {
      var layer = self.layerManager.getLayerGroup(g, true);
      if (layer) {
        self.removeLayer(layer);
      }
    });
  };

  methods.showGroup = function(group) {
    var self = this;
    $.each(asArray(group), function(i, g) {
      var layer = self.layerManager.getLayerGroup(g, true);
      if (layer) {
        self.addLayer(layer);
      }
    });
  };

  methods.addRasterImage = function(uri, bounds, opacity, attribution, layerId, group) {
    // uri is a data URI containing an image. We want to paint this image as a
    // layer at (top-left) bounds[0] to (bottom-right) bounds[1].

    // We can't simply use ImageOverlay, as it uses bilinear scaling which looks
    // awful as you zoom in (and sometimes shifts positions or disappears).
    // Instead, we'll use a TileLayer.Canvas to draw pieces of the image.

    // First, some helper functions.

    // degree2tile converts latitude, longitude, and zoom to x and y tile
    // numbers. The tile numbers returned can be non-integral, as there's no
    // reason to expect that the lat/lng inputs are exactly on the border of two
    // tiles.
    //
    // We'll use this to convert the bounds we got from the server, into coords
    // in tile-space at a given zoom level. Note that once we do the conversion,
    // we don't to do any more trigonometry to convert between pixel coordinates
    // and tile coordinates; the source image pixel coords, destination canvas
    // pixel coords, and tile coords all can be scaled linearly.
    function degree2tile(lat, lng, zoom) {
      // See http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
      var latRad = lat * Math.PI / 180;
      var n = Math.pow(2, zoom);
      var x = (lng + 180) / 360 * n
      var y = (1 - Math.log(Math.tan(latRad) + (1 / Math.cos(latRad))) / Math.PI) / 2 * n
      return {x: x, y: y};
    }

    // Given a range [from,to) and either one or two numbers, returns true if
    // there is any overlap between [x,x1) and the range--or if x1 is omitted,
    // then returns true if x is within [from,to).
    function overlap(from, to, x, /* optional */ x1) {
      if (arguments.length == 3)
        x1 = x;
      return x < to && x1 >= from;
    }

    function getCanvasSmoothingProperty(ctx) {
      var candidates = ["imageSmoothingEnabled", "mozImageSmoothingEnabled",
          "webkitImageSmoothingEnabled", "msImageSmoothingEnabled"];
      for (var i = 0; i < candidates.length; i++) {
        if (typeof(ctx[candidates[i]]) !== "undefined") {
          return candidates[i];
        }
      }
      return null;
    }

    // Our general strategy is to:
    // 1. Load the data URI in an Image() object, so we can get its pixel
    //    dimensions and the underlying image data. (We could have done this
    //    by not encoding as PNG at all but just send an array of RGBA values
    //    from the server, but that would inflate the JSON too much.)
    // 2. Create a hidden canvas that we use just to extract the image data
    //    from the Image (using Context2D.getImageData()).
    // 3. Create a TileLayer.Canvas and add it to the map.

    // We want to synchronously create and attach the TileLayer.Canvas (so an
    // immediate call to clearRasters() will be respected, for example), but
    // Image loads its data asynchronously. Fortunately we can resolve this
    // by putting TileLayer.Canvas into async mode, which will let us create
    // and attach the layer but have it wait until the image is loaded before
    // it actually draws anything.

    // These are the variables that we will populate once the image is loaded.
    var imgData = null; // 1d row-major array, four [0-255] integers per pixel
    var imgDataMipMapper = null;
    var w = null;       // image width in pixels
    var h = null;       // image height in pixels

    // We'll use this array to store callbacks that need to be invoked once
    // imgData, w, and h have been resolved.
    var imgDataCallbacks = [];

    // Consumers of imgData, w, and h can call this to be notified when data
    // is available. Unlike most async/promise-based APIs, the callback will
    // be invoked immediately/synchronously if the data is already available.
    function getImageData(callback) {
      if (imgData != null) {
        callback(imgData, w, h, imgDataMipMapper);
      } else {
        imgDataCallbacks.push(callback);
      }
    }

    var img = new Image();
    img.onload = function() {
      // Save size
      w = img.width;
      h = img.height;

      // Create a dummy canvas to extract the image data
      var imgDataCanvas = document.createElement("canvas");
      imgDataCanvas.width = w;
      imgDataCanvas.height = h;
      imgDataCanvas.style.display = "none";
      document.body.appendChild(imgDataCanvas);

      var imgDataCtx = imgDataCanvas.getContext("2d");
      imgDataCtx.drawImage(img, 0, 0);

      // Save the image data.
      imgData = imgDataCtx.getImageData(0, 0, w, h).data;
      imgDataMipMapper = new Mipmapper(img);

      // Done with the canvas, remove it from the page so it can be gc'd.
      document.body.removeChild(imgDataCanvas);

      // Alert any getImageData callers who are waiting.
      for (var i = 0; i < imgDataCallbacks.length; i++) {
        imgDataCallbacks[i](imgData, w, h, imgDataMipMapper);
      }
      imgDataCallbacks = [];
    };
    img.src = uri;

    var canvasTiles = L.tileLayer.canvas({
      opacity: opacity,
      attribution: attribution,
      detectRetina: true,
      async: true
    });

    canvasTiles.drawTile = function(canvas, tilePoint, zoom) {
      getImageData(function(imgData, w, h, mipmapper) {
        try {
          // The Context2D we'll being drawing onto. It's always 256x256.
          var ctx = canvas.getContext('2d');

          // Convert our image data's top-left and bottom-right locations into
          // x/y tile coordinates. This is essentially doing a spherical mercator
          // projection, then multiplying by 2^zoom.
          var topLeft = degree2tile(bounds[0][0], bounds[0][1], zoom);
          var bottomRight = degree2tile(bounds[1][0], bounds[1][1], zoom);
          // The size of the image in x/y tile coordinates.
          var extent = {x: bottomRight.x - topLeft.x, y: bottomRight.y - topLeft.y};

          // Short circuit if tile is totally disjoint from image.
          if (!overlap(tilePoint.x, tilePoint.x + 1, topLeft.x, bottomRight.x))
            return;
          if (!overlap(tilePoint.y, tilePoint.y + 1, topLeft.y, bottomRight.y))
            return;

          // The linear resolution of the tile we're drawing is always 256px per tile unit.
          // If the linear resolution (in either direction) of the image is less than 256px
          // per tile unit, then use nearest neighbor; otherwise, use the canvas's built-in
          // scaling.
          var imgRes = {
            x: w / extent.x,
            y: h / extent.y
          };

          // We can do the actual drawing in one of three ways:
          // - Call drawImage(). This is easy and fast, and results in smooth
          //   interpolation (bilinear?). This is what we want when we are
          //   reducing the image from its native size.
          // - Call drawImage() with imageSmoothingEnabled=false. This is easy
          //   and fast and gives us nearest-neighbor interpolation, which is what
          //   we want when enlarging the image. However, it's unsupported on many
          //   browsers (including QtWebkit).
          // - Do a manual nearest-neighbor interpolation. This is what we'll fall
          //   back to when enlarging, and imageSmoothingEnabled isn't supported.
          //   In theory it's slower, but still pretty fast on my machine, and the
          //   results look the same AFAICT.

          // Is imageSmoothingEnabled supported? If so, we can let canvas do
          // nearest-neighbor interpolation for us.
          var smoothingProperty = getCanvasSmoothingProperty(ctx);

          if (smoothingProperty || imgRes.x >= 256 && imgRes.y >= 256) {
            // Use built-in scaling

            // Turn off anti-aliasing if necessary
            if (smoothingProperty) {
              ctx[smoothingProperty] = imgRes.x >= 256 && imgRes.y >= 256;
            }

            // Don't necessarily draw with the full-size image; if we're
            // downscaling, use the mipmapper to get a pre-downscaled image
            // (see comments on Mipmapper class for why this matters).
            mipmapper.getBySize(extent.x*256, extent.y*256, function(mip) {
              // It's possible that the image will go off the edge of the canvas--
              // that's OK, the canvas should clip appropriately.
              ctx.drawImage(mip,
                // Convert abs tile coords to rel tile coords, then *256 to convert
                // to rel pixel coords
                (topLeft.x - tilePoint.x) * 256,
                (topLeft.y - tilePoint.y) * 256,
                // Always draw the whole thing and let canvas clip; so we can just
                // convert from size in tile coords straight to pixels
                extent.x * 256,
                extent.y * 256
              );
            });

          } else {
            // Use manual nearest-neighbor interpolation

            // Calculate the source image pixel coordinates that correspond with
            // the top-left and bottom-right of this tile. (If the source image
            // only partially overlaps the tile, we use max/min to limit the
            // sourceStart/End to only reflect the overlapping portion.)
            var sourceStart = {
              x: Math.max(0, Math.floor((tilePoint.x - topLeft.x) * imgRes.x)),
              y: Math.max(0, Math.floor((tilePoint.y - topLeft.y) * imgRes.y))
            };
            var sourceEnd = {
              x: Math.min(w, Math.ceil((tilePoint.x + 1 - topLeft.x) * imgRes.x)),
              y: Math.min(h, Math.ceil((tilePoint.y + 1 - topLeft.y) * imgRes.y))
            };

            // The size, in dest pixels, that each source pixel should occupy.
            // This might be greater or less than 1 (e.g. if x and y resolution
            // are very different).
            var pixelSize = {
              x: 256 / imgRes.x,
              y: 256 / imgRes.y
            };

            // For each pixel in the source image that overlaps the tile...
            for (var row = sourceStart.y; row < sourceEnd.y; row++) {
              for (var col = sourceStart.x; col < sourceEnd.x; col++) {
                // ...extract the pixel data...
                var i = ((row * w) + col) * 4;
                var r = imgData[i];
                var g = imgData[i+1];
                var b = imgData[i+2];
                var a = imgData[i+3];
                ctx.fillStyle = "rgba(" + [r,g,b,a/255].join(",") + ")";

                // ...calculate the corresponding pixel coord in the dest image
                // where it should be drawn...
                var pixelPos = {
                  x: (((col / imgRes.x) + topLeft.x) - tilePoint.x) * 256,
                  y: (((row / imgRes.y) + topLeft.y) - tilePoint.y) * 256
                };

                // ...and draw a rectangle there.
                ctx.fillRect(
                  Math.round(pixelPos.x),
                  Math.round(pixelPos.y),
                  // Looks crazy, but this is necessary to prevent rounding from
                  // causing overlap between this rect and its neighbors. The
                  // minuend is the location of the next pixel, while the
                  // subtrahend is the position of the current pixel (to turn an
                  // absolute coordinate to a width/height). Yes, I had to look
                  // up minuend and subtrahend.
                  Math.round(pixelPos.x + pixelSize.x) - Math.round(pixelPos.x),
                  Math.round(pixelPos.y + pixelSize.y) - Math.round(pixelPos.y));
              }
            }
          }
        } finally {
          canvasTiles.tileDrawn(canvas);
        }
      });
    };

    this.layerManager.addLayer(canvasTiles, "image", layerId, group);
  };

  methods.removeImage = function(layerId) {
    this.layerManager.removeLayer("image", layerId);
  };

  methods.clearImages = function() {
    this.layerManager.clearLayers("image");
  };

  function preventUnintendedZoomOnScroll(map) {
    // Prevent unwanted scroll capturing. Similar in purpose to
    // https://github.com/CliffCloud/Leaflet.Sleep but with a
    // different set of heuristics.

    // The basic idea is that when a mousewheel/DOMMouseScroll
    // event is seen, we disable scroll wheel zooming until the
    // user moves their mouse cursor or clicks on the map. This
    // is slightly trickier than just listening for mousemove,
    // because mousemove is fired when the page is scrolled,
    // even if the user did not physically move the mouse. We
    // handle this by examining the mousemove event's screenX
    // and screenY properties; if they change, we know it's a
    // "true" move.

    // lastScreen can never be null, but its x and y can.
    var lastScreen = {x: null, y: null};
    $(document).on("mousewheel DOMMouseScroll", "*", function(e) {
      // Disable zooming (until the mouse moves or click)
      map.scrollWheelZoom.disable();
      // Any mousemove events at this screen position will be ignored.
      lastScreen = {x: e.originalEvent.screenX, y: e.originalEvent.screenY};
    });
    $(document).on("mousemove", "*", function(e) {
      // Did the mouse really move?
      if (lastScreen.x !== null && e.screenX !== lastScreen.x || e.screenY !== lastScreen.y) {
        // It really moved. Enable zooming.
        map.scrollWheelZoom.enable();
        lastScreen = {x: null, y: null};
      }
    });
    $(document).on("mousedown", ".leaflet", function(e) {
      // Clicking always enables zooming.
      map.scrollWheelZoom.enable();
      lastScreen = {x: null, y: null};
    });
  }

  HTMLWidgets.widget({
    name: "leaflet",
    type: "output",
    initialize: function(el, width, height) {
      // hard-coding center/zoom here for a non-empty initial view, since there
      // is no way for htmlwidgets to pass initial params to initialize()
      var map = L.map(el, {
        center: [51.505, -0.09],
        zoom: 13
      });

      preventUnintendedZoomOnScroll(map);

      // Store some state in the map object
      map.leafletr = {
        // Has the map ever rendered successfully?
        hasRendered: false,
        // Data to be rendered when resize is called with area != 0
        pendingRenderData: null
      };

      if (!HTMLWidgets.shinyMode) return map;

      // The map is rendered staticly (no output binding, so no this.getId())
      if (typeof this.getId === 'undefined') return map;

      map.id = this.getId(el);

      // Store the map on the element so we can find it later by ID
      $(el).data("leaflet-map", map);

      // When the map is clicked, send the coordinates back to the app
      map.on('click', function(e) {
        Shiny.onInputChange(map.id + '_click', {
          lat: e.latlng.lat,
          lng: e.latlng.lng,
          '.nonce': Math.random() // Force reactivity if lat/lng hasn't changed
        });
      });

      var groupTimerId = null;

      map
        .on('moveend', function(e) { updateBounds(e.target); })
        .on('layeradd layerremove', function(e) {
          // If the layer that's coming or going is a group we created, tell
          // the server.
          if (map.layerManager.getGroupNameFromLayerGroup(e.layer)) {
            // But to avoid chattiness, coalesce events
            if (groupTimerId) {
              clearTimeout(groupTimerId);
              groupTimerId = null;
            }
            groupTimerId = setTimeout(function() {
              groupTimerId = null;
              Shiny.onInputChange(map.id + '_groups',
                map.layerManager.getVisibleGroups());
            }, 100);
          }
        });

      return map;
    },
    renderValue: function(el, data, map) {
      // Leaflet does not behave well when you set up a bunch of layers when
      // the map is not visible (width/height == 0). Popups get misaligned
      // relative to their owning markers, and the fitBounds calculations
      // are off. Therefore we wait until the map is actually showing to
      // render the value (we rely on the resize() callback being invoked
      // at the appropriate time).
      //
      // There may be an issue with leafletProxy() calls being made while
      // the map is not being viewed--not sure what the right solution is
      // there.
      if (el.offsetWidth === 0 || el.offsetHeight === 0) {
        map.leafletr.pendingRenderData = data;
        return;
      }
      map.leafletr.pendingRenderData = null;

      // Merge data options into defaults
      var options = $.extend({ zoomToLimits: "always" }, data.options);

      if (!map.layerManager) {
        map.controls = new ControlStore(map);
        map.layerManager = new LayerManager(map);
      } else {
        map.controls.clear();
        map.layerManager.clear();
      }

      var explicitView = false;
      if (data.setView) {
        explicitView = true;
        map.setView.apply(map, data.setView);
      }
      if (data.fitBounds) {
        explicitView = true;
        methods.fitBounds.apply(map, data.fitBounds);
      }

      // Returns true if the zoomToLimits option says that the map should be
      // zoomed to map elements.
      function needsZoom() {
        return options.zoomToLimits === "always" ||
               (options.zoomToLimits === "first" && !map.leafletr.hasRendered);
      }

      if (!explicitView && needsZoom()) {
        if (data.limits) {
          // Use the natural limits of what's being drawn on the map
          // If the size of the bounding box is 0, leaflet gets all weird
          var pad = 0.006;
          if (data.limits.lat[0] === data.limits.lat[1]) {
            data.limits.lat[0] = data.limits.lat[0] - pad;
            data.limits.lat[1] = data.limits.lat[1] + pad;
          }
          if (data.limits.lng[0] === data.limits.lng[1]) {
            data.limits.lng[0] = data.limits.lng[0] - pad;
            data.limits.lng[1] = data.limits.lng[1] + pad;
          }
          map.fitBounds([
            [ data.limits.lat[0], data.limits.lng[0] ],
            [ data.limits.lat[1], data.limits.lng[1] ]
          ]);
        } else {
          map.fitWorld();
        }
      }

      for (var i = 0; data.calls && i < data.calls.length; i++) {
        var call = data.calls[i];
        if (methods[call.method])
          methods[call.method].apply(map, call.args);
        else
          console.log("Unknown method " + call.method);
      }

      map.leafletr.hasRendered = true;

      if (!HTMLWidgets.shinyMode) return;

      setTimeout(function() { updateBounds(map); }, 1);
    },
    resize: function(el, width, height, map) {
      map.invalidateSize();
      if (map.leafletr.pendingRenderData) {
        this.renderValue(el, map.leafletr.pendingRenderData, map);
      }
    }
  });

  if (!HTMLWidgets.shinyMode) return;

  Shiny.addCustomMessageHandler('leaflet-calls', function(data) {
    var id = data.id;
    var el = document.getElementById(id);
    var map = el ? $(el).data('leaflet-map') : null;
    if (!map) {
      console.log("Couldn't find map with id " + id);
      return;
    }

    for (var i = 0; i < data.calls.length; i++) {
      var call = data.calls[i];
      if (call.dependencies) {
        Shiny.renderDependencies(call.dependencies);
      }
      if (methods[call.method])
        methods[call.method].apply(map, call.args);
      else
        console.log("Unknown method " + call.method);
    }
  });

})();



// In RMarkdown's self-contained mode, we don't have a way to carry around the
// images that Leaflet needs but doesn't load into the page. Instead, we'll set
// data URIs for the default marker, and let any others be loaded via CDN.
if (typeof(L.Icon.Default.imagePath) === "undefined") {
  L.Icon.Default.imagePath = "http://cdn.leafletjs.com/leaflet-0.7.3/images";

  if (L.Browser.retina) {
    L.Icon.Default.prototype.options.iconUrl = "data:image/png;base64,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";
  } else {
    L.Icon.Default.prototype.options.iconUrl = "data:image/png;base64,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";
  }
}
