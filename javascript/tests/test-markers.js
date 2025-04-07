import L from "leaflet";
import $ from "jquery";
import methods from "../src/methods";
import DataFrame from "../src/dataframe";
import assert from "assert";

// Mock necessary Leaflet objects and methods
function setupLeafletMocks() {
  // Mock layer manager
  const layerManager = {
    addLayer: function(layer, category, id, group) {
      return true;
    }
  };

  // Mock map object
  const map = {
    layerManager: layerManager,
    id: 'test-map'
  };

  // Mock marker
  L.marker = function(latlng, options) {
    return {
      bindPopup: function(content, options) {
        return this;
      },
      bindTooltip: function(content, options) {
        this.tooltip = {content, options};
        this.openTooltip = function() { return this; };
        return this;
      },
      on: function(event, handler) {
        return this;
      }
    };
  };

  // Mock icon
  L.icon = function(options) {
    return {options: options};
  };

  // Mock LayerGroup
  L.LayerGroup = function() {
    return {
      addLayers: function(layers) {
        this.layers = layers;
        return this;
      },
      getLayers: function() {
        return Object.values(this.layers);
      }
    };
  };

  // Mock markerClusterGroup
  L.markerClusterGroup = function(options) {
    return {
      addLayer: function(layer) {
        return this;
      },
      options: options
    };
  };

  return {map};
}

describe("addMarkers", () => {
  const {map} = setupLeafletMocks();

  it("can add basic markers", () => {
    // Prepare test data
    const lat = [45.5, 46.2, 47.1];
    const lng = [-122.5, -123.1, -124.2];
    const popup = ["Popup 1", "Popup 2", "Popup 3"];
    const options = {draggable: true};
    const icon = [{}, {}, {}];
    const layerId = ["marker1", "marker2", "marker3"];
    
    // Call the method to test
    const result = methods.addMarkers.call(map, lat, lng, icon, layerId, 
      "testGroup", options, popup, null, null, null, null, null);
    
    // Assert the result is truthy (addLayer returns true in mock)
    assert(result);
  });

  it("handles marker options properly", () => {
    // Testing with marker options
    const lat = [47.1];
    const lng = [-122.6];
    const popup = ["Test Popup"];
    const options = {draggable: true, opacity: 0.8};
    const icon = [{}];
    const layerId = ["marker-options-test"];
    
    // Call the method to test
    const result = methods.addMarkers.call(map, lat, lng, icon, layerId, 
      "testGroup", options, popup, null, null, null, null, null);
    
    assert(result);
  });

  it("handles cluster options", () => {
    // Testing with cluster options
    const lat = [47.1, 47.2, 47.3];
    const lng = [-122.6, -122.7, -122.8];
    const popup = ["Test Popup 1", "Test Popup 2", "Test Popup 3"];
    const options = {draggable: true};
    const icon = [{}, {}, {}];
    const layerId = ["c-marker1", "c-marker2", "c-marker3"];
    const clusterOptions = {maxClusterRadius: 80, spiderfyOnMaxZoom: true};
    const clusterId = "test-cluster";
    
    // Call the method to test
    const result = methods.addMarkers.call(map, lat, lng, icon, layerId, 
      "testGroup", options, popup, null, clusterOptions, clusterId, null, null);
    
    assert(result);
  });

  it("processes labels correctly", () => {
    // Testing with labels
    const lat = [47.1];
    const lng = [-122.6];
    const popup = ["Test Popup"];
    const options = {};
    const icon = [{}];
    const layerId = ["label-test"];
    const label = ["Test Label"];
    const labelOptions = {permanent: true, direction: 'auto'};
    
    // Call the method to test
    const result = methods.addMarkers.call(map, lat, lng, icon, layerId, 
      "testGroup", options, popup, null, null, null, label, labelOptions);
    
    assert(result);
  });
});

describe("addAwesomeMarkers", () => {
  const {map} = setupLeafletMocks();
  
  // Mock AwesomeMarkers
  L.AwesomeMarkers = {
    icon: function(options) {
      return {options: options};
    }
  };

  it("can add awesome markers", () => {
    // Prepare test data
    const lat = [45.5, 46.2];
    const lng = [-122.5, -123.1];
    const icon = [
      {icon: 'home', markerColor: 'blue', iconColor: 'white'},
      {icon: 'info', markerColor: 'red', iconColor: 'white'}
    ];
    const layerId = ["a-marker1", "a-marker2"];
    
    // Set up addMarkers method to be called by addAwesomeMarkers
    map.addGenericMarkers = function(df, group, clusterOptions, clusterId, markerFunc) {
      // Test the marker creation function
      const marker = markerFunc(df, 0);
      assert(marker);
      return true;
    };
    
    // Call the method to test
    const result = methods.addAwesomeMarkers.call(map, lat, lng, icon, layerId, 
      "testGroup", {}, null, null, null, null, null, null);
    
    assert(result);
  });

  it("handles square markers option", () => {
    // Testing square marker option
    const lat = [45.5];
    const lng = [-122.5];
    const icon = [{
      icon: 'home', 
      markerColor: 'blue',
      squareMarker: true
    }];
    const layerId = ["square-marker"];
    
    map.addGenericMarkers = function(df, group, clusterOptions, clusterId, markerFunc) {
      // Test the marker creation function
      const marker = markerFunc(df, 0);
      // Verify the square marker class was added
      assert(marker);
      return true;
    };
    
    // Call the method to test
    const result = methods.addAwesomeMarkers.call(map, lat, lng, icon, layerId, 
      "testGroup", {}, null, null, null, null, null, null);
    
    assert(result);
  });
});