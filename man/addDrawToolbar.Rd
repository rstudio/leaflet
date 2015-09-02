% Please edit documentation in R/plugin-draw.R
\name{addDrawToolbar}
\alias{addDrawToolbar}
\title{Add drawing toolbar}
\usage{
addDrawToolbar(map)
}
\arguments{
\item{map}{the map to add the toolbar to}
}
\value{
modified map object
}
\description{
Add drawing toolbar
}
\examples{
map <- addTiles(leaflet())
map <- addDrawToolbar(map)
map
}
