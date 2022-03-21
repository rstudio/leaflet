import L from "./global/leaflet";

// In RMarkdown's self-contained mode, we don't have a way to carry around the
// images that Leaflet needs but doesn't load into the page. Instead, we'll use
// the unpkg CDN.
if (typeof(L.Icon.Default.imagePath) === "undefined") {
  L.Icon.Default.imagePath = "https://unpkg.com/leaflet@1.3.1/dist/images/";
}
