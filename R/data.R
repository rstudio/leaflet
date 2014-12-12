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
