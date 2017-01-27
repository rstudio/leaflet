#' Add a color legend to a map
#'
#' When a color palette function is used in a map (e.g.
#' \code{\link{colorNumeric}}), a color legend can be automatically derived from
#' the palette function. You can also manually specify the colors and labels for
#' the legend.
#'
#' The \code{labFormat} argument is a function that takes the argument
#' \code{type = c("numeric", "bin", "quantile", "factor")}, plus, arguments for
#' different types of color palettes. For the \code{colorNumeric()} palette,
#' \code{labFormat} takes a single argument, which is the breaks of the numeric
#' vector, and returns a character vector of the same length. For
#' \code{colorBin()}, \code{labFormat} also takes a vector of breaks of length
#' \code{n} but should return a character vector of length \code{n - 1}, with
#' the \code{i}-th element representing the interval \code{c(x[i], x[i + 1])}.
#' For \code{colorQuantile}, \code{labFormat} takes two arguments, the quantiles
#' and the associated probabilities (each of length \code{n}), and should return
#' a character vector of length \code{n - 1} (similar to the \code{colorBin()}
#' palette). For \code{colorFactor()}, \code{labFormat} takes one argument, the
#' unique values of the factor, and should return a character vector of the same
#' length.
#'
#' By default, \code{labFormat} is basically \code{format(scientific = FALSE,
#' big.mark = ',')} for the numeric palette, \code{as.character()} for the
#' factor palette, and a function to return labels of the form \samp{x[i] - x[i
#' + 1]} for bin and quantile palettes (in the case of quantile palettes,
#' \code{x} is the probabilities instead of the values of breaks).
#' @inheritParams setView
#' @param position the position of the legend
#' @param pal the color palette function, generated from
#'   \code{\link{colorNumeric}()}, \code{colorBin()}, \code{colorQuantile()}, or
#'   \code{colorFactor()}
#' @param values the values used to generate colors from the palette function
#' @param na.label the legend label for \code{NA}s in \code{values}
#' @param bins an approximate number of tick-marks on the color gradient for the
#'   \code{colorNumeric} palette if it is of length one; you can also provide a
#'   numeric vector as the pre-defined breaks (equally spaced)
#' @param colors a vector of (HTML) colors to be used in the legend if
#'   \code{pal} is not provided
#' @param opacity the opacity of colors
#' @param labels a vector of text labels in the legend corresponding to
#'   \code{colors}
#' @param labFormat a function to format the labels derived from \code{pal} and
#'   \code{values} (see Details below to know what \code{labelFormat()} returns
#'   by default; you can either use the helper function \code{labelFormat()}, or
#'   write your own function)
#' @param title the legend title
#' @param className extra CSS classes to append to the control, space separated
#' @param layerId the ID of the legend; subsequent calls to \code{addLegend}
#'   or \code{addControl} with the same \code{layerId} will replace this
#'   legend. The ID can also be used with \code{removeControl}.
#' @param orientation a string specifying the orientation of the legend. Default:
#'   "vertical".
#' @param width Specifies the legends width (the color-bar; not the overall box) in 'px'. If NULL it will be calculated according to the orientation and tick number. Default = NULL.
#' @param height Specifies the legends height (the color-bar; not the overall box) in 'px'. If NULL it will be calculated according to the orientation and tick number. Default = NULL.
#' @example inst/examples/legend.R
#' @export
addLegend <- function(
  map, position = c('topright', 'bottomright', 'bottomleft', 'topleft'),
  pal, values, na.label = 'NA', bins = 7, colors, opacity = 0.5, labels,
  labFormat = labelFormat(), title = NULL, className = "info legend",
  layerId = NULL, orientation = c( "vertical", "horizontal" ),
  width = NULL, height = NULL
) {
  position = match.arg(position)
  orientation = match.arg(orientation)
  type = 'unknown'; na.color = NULL
  extra = NULL  # only used for numeric palettes to store extra info
  
  if (!missing(pal)) {
        if (!missing(colors))
            stop("You must provide either 'pal' or 'colors' (not both)")
        
        ## a better default title when values is formula
        if (missing(title) && inherits(values, 'formula')) title = deparse(values[[2]])
        values = evalFormula(values, getMapData(map))
        generate.legend <- function( bins = bins ){
            type = attr(pal, 'colorType', exact = TRUE)
            args = attr(pal, 'colorArgs', exact = TRUE)
            na.color = args$na.color
                                        # If na.color is transparent, don't show it on the legend
            if (!is.null(na.color) && col2rgb(na.color, alpha = TRUE)[[4]] == 0) {
                na.color = NULL
            }
            if (type == 'numeric') {

                ## choose pretty cut points to draw tick-marks on the color gradient if
                ## 'bins' is the number of bins, otherwise 'bins' is just the breaks
                cuts = if (length(bins) == 1) pretty(values, n = bins) else bins
                if (length(bins) > 2)
                    if (!all(abs(diff(bins, differences = 2)) <= sqrt(.Machine$double.eps)))
                        stop("The vector of breaks 'bins' must be equally spaced")
                n = length(cuts)
                r = range(values, na.rm = TRUE)
                ## pretty cut points may be out of the range of `values`
                cuts = cuts[cuts >= r[1] & cuts <= r[2]]
                n = length(cuts)
                p = (cuts - r[1]) / (r[2] - r[1])  # percents relative to min(values)

                ## [    |       |       |  ...  |    ]
                ## min  p1      p2      p3 ...  pn   max
                ##  |   +   |   +   |   +  ...  +   |
                ## here |+| denotes a table row, and there are n rows
                
                ## Since min and max may exceed the limits of the cut points, the client
                ## needs to know the first and last cut points in order to place the tick
                ## marks properly relative to the gradient.
                extra = list(p_1 = p[1], p_n = p[n])
                ## syntax for the color gradient: linear-gradient(start-color, color1 p1%,
                ## color2 p2%, ..., colorn pn%, end-color])
                p = c('', paste0(100 * p, '%'), '')
                colors = pal(c(r[1], cuts, r[2]))
                colors = paste(colors, p, sep = ' ', collapse = ', ')
                labels = labFormat(type = 'numeric', cuts)

                ## Calculating the width and height of the color-bar
                ## taken from the original JS wrapper
                default.thickness <- 18 # [px]; default width/height
                ## If width/height is given (depending on the orientation)
                ## this variable will be calculated from them
                single.bin.length <- 20 # [px]; distance between the ticks
                single.bin.percentage <- ( extra$p_n - extra$p_1 )/( n - 1 )
                if ( orientation == "vertical" ){
                    if ( is.null( height ) ){
                        height <- single.bin.length/ single.bin.percentage + 1
                    } else
                        single.bin.length <- height* single.bin.percentage - 1
                    if ( is.null( width ) )
                        width <- default.thickness
                } else {
                    if ( is.null( height ) )
                        height <- default.thickness
                    if ( is.null( width ) ){
                        width <- single.bin.length/ single.bin.percentage + 1
                    } else
                        single.bin.length <- width* single.bin.percentage - 1
                }
                ## calculating the tickOffset from the original JS wrapper
                ## via the extra$p_1, the total length and the single.bin.percentage
                if ( orientation == "vertical" ){
                    tick.offset.beginning <- ( height - 1/ single.bin.percentage )* extra$p_1
                    tick.offset.end <- ( height - 1/ single.bin.percentage )* ( 1 - extra$p_n )
                } else {
                    tick.offset.beginning <- ( width - 1/ single.bin.percentage )* extra$p_1   
                    tick.offset.end <- ( width - 1/ single.bin.percentage )* ( 1 - extra$p_n )
                }

            } else if (type == 'bin') {

                cuts = args$bins
                n = length(cuts)
                ## use middle points to represent intervals
                mids = (cuts[-1] + cuts[-n]) / 2
                colors = pal(mids)
                labels = labFormat(type = 'bin', cuts)
                tick.offset.beginning <- tick.offset.end <- single.bin.length <- NULL

            } else if (type == 'quantile') {

                p = args$probs
                n = length(p)
                ## the "middle points" in this case are the middle probabilities
                cuts = quantile(values, probs = p, na.rm = TRUE)
                mids = quantile(values, probs = (p[-1] + p[-n]) / 2, na.rm = TRUE)
                colors = pal(mids)
                labels = labFormat(type = 'quantile', cuts, p)
                tick.offset.beginning <- tick.offset.end <- single.bin.length <- NULL

            } else if (type == 'factor') {

                v = sort(unique(na.omit(values)))
                colors = pal(v)
                labels = labFormat(type = 'factor', v)
                tick.offset.beginning <- tick.offset.end <- single.bin.length <- NULL

            } else stop('Palette function not supported')
            
            if (!any(is.na(values))) na.color = NULL
            
            ## For convenience I will also provide the former singleBinHeight variable.
            ## It would just cause errors if defined at both this script and the wrapper.
            legend = list(
                colors = I(unname(colors)), labels = I(unname(labels)),
                na_color = na.color, na_label = na.label, opacity = opacity,
                position = position, type = type, title = title, extra = extra,
                layerId = layerId, className = className, orientation = orientation,
                totalWidth = width, totalHeight = height, tickOffset = tick.offset.beginning,
                tickOffsetEnd = tick.offset.end, singleBinLength = single.bin.length
            )
            return( legend )
        }
        legend <- generate.legend( bins )
    } else {
        if ( !missing( labels ) && !missing( colors ) ){
            if (length(colors) != length( labels ) )
                stop("'colors' and 'labels' must be of the same length")
            if ( orientation == "horizontal" ){
                warning( "To use the horizontal orientation of the legend please supply a palette." )
                orientation <- "vertical"
            }
            ## Heuristic width and height for supplied colors and corresponding labels
            singleBinLength <- 18 # size of colored square
            if ( is.null( title ) ){
                title.height <- title.width <- 0
            } else {
                title.height <- 18 # 16px character + 2px padding
                title.width <- nchar( title )* 8
            }
            ## width of colored bar + margin + label
            column.width <- singleBinLength + 8 + max( nchar( labels ) )* 8
            ## height colored bins + title + padding
            if ( is.null( height ) )
                height <- singleBinLength* length( colors ) + title.width + 2* 6
            ## the widest element controls the width + padding
            if ( is.null( width ) )
                widht <- max( column.width, title.width ) + 2*8
            
            legend <- list(
                colors = I( unname( colors ) ), labels = I( unname( labels ) ),
                na_color = na.color, na_label = na.label, opacity = opacity,
                position = position, type = type, title = title, extra = extra,
                layerId = layerId, className = className, orientation = orientation,
                totalWidth = width, totalHeight = height, tickOffset = 0,
                tickOffsetEnd = 0, singleBinLength = singleBinLength
            )
        } else
            stop( "'colors' and 'labels' must be supplied when 'pal' if omitted!" )
    }
    
    if ( legend$orientation == "horizontal" ){
        ## In case of the vertical orientation the labels can be whatever
        ## Now we have to check if the labels actually fit in the color-bar
        ## I will assign a default width of a character. (Via the inspector)
        ## With the two spaces in the collapse argument I took care of the
        ## spaces between the labels (which should be present)
        character.width <- 4 # [px]
        calculate.width <- function( legend ){
            label.width <- nchar( paste( legend$labels, sep = ' ', collapse = '  ' ) )*
                character.width
            total.width <- label.width + legend$tickOffset + legend$tickOffsetEnd
            return( total.width )
        }
        ## reduce the number of bins until the labels fit below the color-bar
        while( calculate.width( legend ) > legend$totalWidth ){
            ## It does not fit. So lets take less bins.
            bins <- bins - 1
            legend <- generate.legend( bins )
            if ( bins == 1 ){
                warning( "No labels fitting below your leaflet legend could be found!" )
                break
            }
        }
    }
  invokeMethod(map, getMapData(map), "addLegend", legend)
}

#' @param prefix a prefix of legend labels
#' @param suffix a suffix of legend labels
#' @param between a separator between \code{x[i]} and \code{x[i + 1]} in legend
#'   labels (by default, it is a dash)
#' @param digits the number of digits of numeric values in labels
#' @param big.mark the thousand separator
#' @param transform a function to transform the label value
#' @rdname addLegend
#' @export
labelFormat <- function(
  prefix = '', suffix = '', between = ' &ndash; ', digits = 3, big.mark = ',',
  transform = identity
) {

  formatNum <- function(x) {
    format(
      round(transform(x), digits), trim = TRUE, scientific = FALSE,
      big.mark = big.mark
    )
  }

  function(type, ...) {
    switch(
      type,
      numeric = (function(cuts) {
        paste0(prefix, formatNum(cuts), suffix)
      })(...),
      bin = (function(cuts) {
        n = length(cuts)
        paste0(prefix, formatNum(cuts[-n]), between, formatNum(cuts[-1]), suffix)
      })(...),
      quantile = (function(cuts, p) {
        n = length(cuts)
        p = paste0(round(p * 100), '%')
        cuts = paste0(formatNum(cuts[-n]), between, formatNum(cuts[-1]))
        # mouse over the legend labels to see the values (quantiles)
        paste0(
          '<span title="', cuts, '">', prefix, p[-n], between, p[-1], suffix,
          '</span>'
        )
      })(...),
      factor = (function(cuts) {
        paste0(prefix, as.character(transform(cuts)), suffix)
      })(...)
    )
  }

}
