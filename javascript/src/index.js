import $ from "./global/jquery";
import L from "./global/leaflet";
import Shiny from "./global/shiny";
import HTMLWidgets from "./global/htmlwidgets";

import { log } from "./util";
import { getCRS } from "./crs_utils";

import ControlStore from "./control-store";
import LayerManager from "./layer-manager";

import defaultMethods from "./methods";

import "./fixup-default-icon";
import "./fixup-default-tooltip";
import "./fixup-url-protocol";

import DataFrame from "./dataframe";
import ClusterLayerStore from "./cluster-layer-store";

window.LeafletWidget = {};
window.LeafletWidget.utils = {};
let methods = window.LeafletWidget.methods = $.extend({}, defaultMethods);
window.LeafletWidget.DataFrame = DataFrame;
window.LeafletWidget.ClusterLayerStore = ClusterLayerStore;
window.LeafletWidget.utils.getCRS = getCRS;

// Send updated bounds back to app. Takes a leaflet event object as input.
function updateBounds(map) {
  let id = map.getContainer().id;
  let bounds = map.getBounds();

  Shiny.onInputChange(id + "_bounds", {
    north: bounds.getNorthEast().lat,
    east: bounds.getNorthEast().lng,
    south: bounds.getSouthWest().lat,
    west: bounds.getSouthWest().lng
  });
  Shiny.onInputChange(id + "_center", {
    lng: map.getCenter().lng,
    lat: map.getCenter().lat
  });
  Shiny.onInputChange(id + "_zoom", map.getZoom());
}

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
  let lastScreen = {x: null, y: null};
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
  factory: function(el, width, height) {

    let map = null;

    return {

      // we need to store our map in our returned object.
      getMap: function() {
        return map;
      } ,

      renderValue: function(data) {

        // Create an appropriate CRS Object if specified

        if(data && data.options && data.options.crs) {
          data.options.crs = getCRS(data.options.crs);
        }

        // As per https://github.com/rstudio/leaflet/pull/294#discussion_r79584810
        if(map) {
          map.remove();
          map = (function () { return; })(); // undefine map
        }

        if(data.options.mapFactory && typeof data.options.mapFactory === "function") {
          map = data.options.mapFactory(el, data.options);
        } else {
          map = L.map(el, data.options);
        }

        preventUnintendedZoomOnScroll(map);

        // Store some state in the map object
        map.leafletr = {
          // Has the map ever rendered successfully?
          hasRendered: false,
          // Data to be rendered when resize is called with area != 0
          pendingRenderData: null
        };

        // Check if the map is rendered statically (no output binding)
        if (HTMLWidgets.shinyMode &&
          /\bshiny-bound-output\b/.test(el.className)) {

          map.id = el.id;

          // Store the map on the element so we can find it later by ID
          $(el).data("leaflet-map", map);

          // When the map is clicked, send the coordinates back to the app
          map.on("click", function(e) {
            Shiny.onInputChange(map.id + "_click", {
              lat: e.latlng.lat,
              lng: e.latlng.lng,
              ".nonce": Math.random() // Force reactivity if lat/lng hasn't changed
            });
          });

          let groupTimerId = null;

          map
            .on("moveend", function(e) { updateBounds(e.target); })
            .on("layeradd layerremove", function(e) {
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
                  Shiny.onInputChange(map.id + "_groups",
                    map.layerManager.getVisibleGroups());
                }, 100);
              }
            });
        }
        this.doRenderValue(data, map);
      },
      doRenderValue: function(data, map) {
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
        let options = $.extend({ zoomToLimits: "always" }, data.options);

        if (!map.layerManager) {
          map.controls = new ControlStore(map);
          map.layerManager = new LayerManager(map);
        } else {
          map.controls.clear();
          map.layerManager.clear();
        }

        let explicitView = false;
        if (data.setView) {
          explicitView = true;
          map.setView.apply(map, data.setView);
        }
        if (data.fitBounds) {
          explicitView = true;
          methods.fitBounds.apply(map, data.fitBounds);
        }
        if (data.flyTo) {
          if (!explicitView && !map.leafletr.hasRendered) {
            // must be done to give a initial starting point
            map.fitWorld();
          }
          explicitView = true;
          map.flyTo.apply(map, data.flyTo);
        }
        if (data.flyToBounds) {
          if (!explicitView && !map.leafletr.hasRendered) {
            // must be done to give a initial starting point
            map.fitWorld();
          }
          explicitView = true;
          methods.flyToBounds.apply(map, data.flyToBounds);
        }
        if(data.options.center) {
          explicitView = true;
        }

        // Returns true if the zoomToLimits option says that the map should be
        // zoomed to map elements.
        function needsZoom() {
          return options.zoomToLimits === "always" ||
                 (options.zoomToLimits === "first" && !map.leafletr.hasRendered);
        }

        if (!explicitView && needsZoom() && !map.getZoom()) {
          if (data.limits && ! $.isEmptyObject(data.limits)) {
            // Use the natural limits of what's being drawn on the map
            // If the size of the bounding box is 0, leaflet gets all weird
            let pad = 0.006;
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

        for (let i = 0; data.calls && i < data.calls.length; i++) {
          let call = data.calls[i];
          if (methods[call.method])
            methods[call.method].apply(map, call.args);
          else
            log("Unknown method " + call.method);
        }

        map.leafletr.hasRendered = true;

        if (HTMLWidgets.shinyMode){
          setTimeout(function() { updateBounds(map); }, 1);
        }

      },
      resize: function(width, height) {
        if(map) {
          map.invalidateSize();
          if (map.leafletr.pendingRenderData) {
            this.doRenderValue(map.leafletr.pendingRenderData, map);
          }
        }
      }
    };
  }
});

function unpackArgs(arg) {
  if (!arg.hasOwnProperty("arg") && !arg.hasOwnProperty("evals")) {
    throw new Error("Malformed argument; .arg and .evals expected");
  }
  for (let i = 0; i < arg.evals.length; i++) {
    window.HTMLWidgets.evaluateStringMember(arg.arg, arg.evals[i]);
  }
  return arg.arg;
}

if (HTMLWidgets.shinyMode) {
  Shiny.addCustomMessageHandler("leaflet-calls", function(data) {
    let id = data.id;
    let el = document.getElementById(id);
    let map = el ? $(el).data("leaflet-map") : null;
    if (!map) {
      log("Couldn't find map with id " + id);
      return;
    }

    for (let i = 0; i < data.calls.length; i++) {
      let call = data.calls[i];
      let args = call.args.map(unpackArgs);
      if (call.dependencies) {
        Shiny.renderDependencies(call.dependencies);
      }
      if (methods[call.method])
        methods[call.method].apply(map, args);
      else
        log("Unknown method " + call.method);
    }
  });
}
