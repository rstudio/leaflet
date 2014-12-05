\name{leafletController}
\alias{leafletController}
\title{Create a Leaflet map controller}
\usage{
leafletController(session, id)
}
\arguments{
\item{session}{The \code{session} argument passed through from the
\code{\link[shiny]{shinyServer}} server function.}

\item{id}{The string identifier that was passed to
\code{\link{leaflet}()}.}
}
\value{
A list of methods. See the package vignette \code{vignette('intro',
  'leaflet'} for details.
}
\description{
This function is called from \file{server.R} and returns an object that can
be used to manipulate the Leaflet map from R.
}
