% Please edit documentation in R/layers.R
\name{makeIconSet}
\alias{makeIconSet}
\title{Make icon set}
\usage{
makeIconSet(...)
}
\description{
Make icon set
}
\examples{
iconSet = makeIconSet(red = makeIcon("leaf-red.png", iconWidth = 32, iconHeight = 32), 
    green = makeIcon("leaf-green.png", iconWidth = 32, iconHeight = 32))

iconSet[c("red", "green", "red")]
}
