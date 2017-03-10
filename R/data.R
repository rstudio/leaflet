#' City and town intercensal US population estimates (2000-2010)
#'
#' Intercensal estimates of the resident population for Incorporated Places and
#' Minor Civil Divisions: April 1, 2000 to July 1, 2010.
#' @docType data
#' @format A data frame containing \code{City}, \code{State}, \code{Lat},
#'   \code{Long}, and population estimates from 2000 to 2010 (columns
#'   \code{Pop2000} to \code{Pop2010}).
#' @source The US Census Bureau:
#'   \url{http://www.census.gov/popest/data/intercensal/cities/cities2010.html}
#' @noRd
#' @examples library(leaflet)
#' str(uspop2000)
#' p = uspop2000$Pop2010
#' p = (p - min(p))/(max(p) - min(p))
#' plot(Lat ~ Long, data = uspop2000, cex = sqrt(p), asp = 1, col = rgb(1, 0, 0, .3))

if(FALSE){
uspop2000 = NULL
if (file.exists('inst/csv/uspop2000.csv')) {
  uspop2000 = read.csv(
    text = readLines('inst/csv/uspop2000.csv', encoding = 'UTF-8'),
    stringsAsFactors = FALSE
  )
}
}

#' @docType data
#' @name atlStorms2005
#' @title Atlantic Ocean storms 2005
#' @description Atlantic Ocean storms 2005
#' @details This dataset contains storm tracks for selected storms
#' in the Atlantic Ocean basin for the year 2005
#' @format \code{sp::SpatialLinesDataFrame}
NULL

#' @docType data
#' @name gadmCHE
#' @title Administrative borders of Switzerland (level 1)
#' @description Administrative borders of Switzerland (level 1)
#' @details This dataset comes from \url{http://gadm.org}.
#' It was downloaded using \code{\link{getData}}.
#' @format \code{sp::SpatialPolygonsDataFrame}
#' @source
#' \url{http://gadm.org}
NULL

#'
#' @docType data
#' @name breweries91
#' @title Selected breweries in Franconia
#' @description Selected breweries in Franconia (zip code starting with 91...)
#' @details This dataset contains selected breweries in Franconia. It is a
#' subset of a larger database that was compiled by students at the
#' University of Marburg for a seminar called
#' "The Geography of Beer, sustainability in the food industry"
#' @format \code{sp::SpatialPointsDataFrame}
NULL

