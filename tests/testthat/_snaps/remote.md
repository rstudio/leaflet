# mockSession tests

    [[1]]
    [[1]]$type
    [1] "leaflet-calls"
    
    [[1]]$message
    {"id":"map","calls":[{"dependencies":[],"method":"addPolygons","args":[[[[{"lng":[1,2,3,4,5],"lat":[1,2,3,4,5]}]]],null,null,{"interactive":true,"className":"","stroke":true,"color":"#03F","weight":5,"opacity":0.5,"fill":true,"fillColor":"#03F","fillOpacity":0.2,"smoothFactor":1,"noClip":false},null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null],"evals":[]}]} 
    
    

---

    [[1]]
    [[1]]$type
    [1] "leaflet-calls"
    
    [[1]]$message
    {"id":"map","calls":[{"dependencies":[],"method":"addMarkers","args":[[10,9,8,7,6,5,4,3,2,1],[10,9,8,7,6,5,4,3,2,1],null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},null,null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null],"evals":[]}]} 
    
    

---

    [[1]]
    [[1]]$type
    [1] "leaflet-calls"
    
    [[1]]$message
    {"id":"map","calls":[{"dependencies":[],"method":"clearShapes","args":[],"evals":[]}]} 
    
    
    [[2]]
    [[2]]$type
    [1] "leaflet-calls"
    
    [[2]]$message
    {"id":"map","calls":[{"dependencies":[],"method":"addMarkers","args":[[10,9,8,7,6,5,4,3,2,1],[10,9,8,7,6,5,4,3,2,1],null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},null,null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null],"evals":[]}]} 
    
    

# leafletProxy with JS()

    [[1]]
    [[1]]$type
    [1] "leaflet-calls"
    
    [[1]]$message
    {"id":"map","calls":[{"dependencies":[{"name":"leaflet-markercluster","version":"1.0.5","src":{"href":"leaflet-markercluster-1.0.5"},"meta":null,"script":["leaflet.markercluster.js","leaflet.markercluster.freezable.js","leaflet.markercluster.layersupport.js"],"stylesheet":["MarkerCluster.css","MarkerCluster.Default.css"],"head":null,"attachment":null,"all_files":true}],"method":"addMarkers","args":[[52.37712,52.37783,52.37755],[4.905167,4.906357,4.905831],null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},null,null,{"showCoverageOnHover":true,"zoomToBoundsOnClick":true,"spiderfyOnMaxZoom":true,"removeOutsideVisibleBounds":true,"spiderLegPolylineOptions":{"weight":1.5,"color":"#222","opacity":0.5},"freezeAtZoom":false,"iconCreateFunction":"function(cluster) {console.log('Here comes cluster',cluster); return new L.DivIcon({html: '<div style=\"background-color:rgba(77,77,77,0.5)\"><span>' + cluster.getChildCount() + '<\/div><span>',className: 'marker-cluster'});}"},null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null],"evals":["8.iconCreateFunction"]}]} 
    
    

