import L from "./global/leaflet";
import Proj4Leaflet from "./global/proj4leaflet";

// Helper function to instanciate a ICRS instance.
export function getCRS(crsOptions) {
  let crs = L.CRS.EPSG3857; // Default Spherical Mercator

  switch(crsOptions.crsClass) {
  case "L.CRS.EPSG3857":
    crs = L.CRS.EPSG3857;
    break;
  case "L.CRS.EPSG4326":
    crs = L.CRS.EPSG4326;
    break;
  case "L.CRS.EPSG3395":
    crs = L.CRS.EPSG3395;
    break;
  case "L.CRS.Simple":
    crs =L.CRS.Simple;
    break;
  case "L.Proj.CRS":
    if(crsOptions.options && crsOptions.options.bounds) {
      crsOptions.options.bounds = L.bounds(crsOptions.options.bounds);
    }
    if(crsOptions.options && crsOptions.options.transformation) {
      crsOptions.options.transformation = new L.Transformation(
        crsOptions.options.transformation[0],
        crsOptions.options.transformation[1],
        crsOptions.options.transformation[2],
        crsOptions.options.transformation[3]
      );
    }
    crs = new Proj4Leaflet.CRS(crsOptions.code, crsOptions.proj4def, crsOptions.options);
    break;
  case "L.Proj.CRS.TMS":
    if(crsOptions.options && crsOptions.options.bounds) {
      crsOptions.options.bounds = L.bounds(crsOptions.options.bounds);
    }
    if(crsOptions.options && crsOptions.options.transformation) {
      crsOptions.options.transformation =
        L.Transformation(
          crsOptions.options.transformation[0],
          crsOptions.options.transformation[1],
          crsOptions.options.transformation[2],
          crsOptions.options.transformation[3]
        );
    }
    // L.Proj.CRS.TMS is deprecated as of Leaflet 1.x, fall back to L.Proj.CRS
    //crs = new Proj4Leaflet.CRS.TMS(crsOptions.code, crsOptions.proj4def, crsOptions.projectedBounds, crsOptions.options);
    crs = new Proj4Leaflet.CRS(crsOptions.code, crsOptions.proj4def, crsOptions.options);
    break;
  }
  return crs;
}
