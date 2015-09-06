% Please edit documentation in R/plugin-awesomeMarkers.R
\name{makeAwesomeIcon}
\alias{addAwesomeMarkers}
\alias{makeAwesomeIcon}
\title{Creates a Marker with awesome-marker icons}
\usage{
makeAwesomeIcon(icon = NULL, prefix = NULL, markerColor = NULL, iconColor = NULL, 
    spin = NULL, extraClasses = NULL)

addAwesomeMarkers(map, lng = NULL, lat = NULL, layerId = NULL, group = NULL, 
    icon = NULL, popup = NULL, label = NULL, labelOptions = NULL, 
    options = markerOptions(), clusterOptions = NULL, clusterId = NULL, 
    data = getMapData(map))
}
\arguments{
\item{icon, prefix, markerColor, iconColor, spin, extraClasses}{see \url{https://github.com/lvoogdt/Leaflet.awesome-markers}}

\item{label}{a character vector of the HTML content for the labels}

\item{labelOptions}{A Vector of \code{\link{labelOptions}} to provide label
options for each label. Default \code{NULL}}

\item{clusterOptions}{if not \code{NULL}, markers will be clustered using
\href{https://github.com/Leaflet/Leaflet.markercluster}{Leaflet.markercluster};
 you can use \code{\link{markerClusterOptions}()} to specify marker cluster
options}

\item{clusterId}{the id for the marker cluster layer}

\item{icon}{the icon(s) for markers;}
}
\description{
Creates a Marker with awesome-marker icons
}
\section{Functions}{
\itemize{
\item \code{makeAwesomeIcon}: Create Awesome Markers

\item \code{addAwesomeMarkers}: add Awesome Markers to a Map | Layer
}}
