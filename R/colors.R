#' Color mapping
#'
#' Conveniently maps data values (numeric or factor/character) to colors
#' according to a given palette, which can be provided in a variety of formats.
#'
#' \code{colorNumeric} is a simple linear mapping from continuous numeric data
#' to an interpolated palette.
#'
#' @param palette The colors or color function that values will be mapped to
#' @param domain The possible values that can be mapped.
#'
#'   For \code{colorNumeric} and \code{colorBin}, this can be a simple numeric
#'   range (e.g. \code{c(0, 100)}); \code{colorQuantile} needs representative
#'   numeric data; and \code{colorFactor} needs categorical data.
#'
#'   If \code{NULL}, then whenever the resulting color function is called, the
#'   \code{x} value will represent the domain. This implies that if the function
#'   is invoked multiple times, the encoding between values and colors may not
#'   be consistent; if consistency is needed, you must provide a non-\code{NULL}
#'   domain.
#' @param na.color The color to return for \code{NA} values. Note that
#'   \code{na.color=NA} is valid.
#' @param alpha Whether alpha channels should be respected or ignored. If
#'   \code{TRUE} then colors without explicit alpha information will be treated
#'   as fully opaque.
#'
#' @return A function that takes a single parameter \code{x}; when called with a
#'   vector of numbers (except for \code{colorFactor}, which expects
#'   factors/characters), #RRGGBB color strings are returned (unless
#'   \code{alpha=TRUE} in which case #RRGGBBAA may also be possible).
#'
#' @export
colorNumeric = function(palette, domain, na.color = "#808080", alpha = FALSE) {
  rng = NULL
  if (length(domain) > 0) {
    rng = range(domain, na.rm = TRUE)
    if (!all(is.finite(rng))) {
      stop("Wasn't able to determine range of domain")
    }
  }

  pf = safePaletteFunc(palette, na.color, alpha)

  withColorAttr('numeric', list(na.color = na.color), function(x) {
    if (length(x) == 0 || all(is.na(x))) {
      return(pf(x))
    }

    if (is.null(rng)) rng = range(x, na.rm = TRUE)

    rescaled = scales::rescale(x, from = rng)
    if (any(rescaled < 0 | rescaled > 1, na.rm = TRUE))
      warning("Some values were outside the color scale and will be treated as NA")
    pf(rescaled)
  })
}

# Attach an attribute colorType to a color function f so we can derive legend
# items from it
withColorAttr = function(type, args = list(), fun) {
  structure(fun, colorType = type, colorArgs = args)
}

# domain may or may not be NULL.
# Iff domain is non-NULL, x may be NULL.
# bins is non-NULL. It may be a scalar value (# of breaks) or a set of breaks.
getBins = function(domain, x, bins, pretty) {
  if (is.null(domain) && is.null(x)) {
    stop("Assertion failed: domain and x can't both be NULL")
  }

  # Hard-coded bins
  if (length(bins) > 1) {
    return(bins)
  }

  if (bins < 2) {
    stop("Invalid bins value of ", bins, "; bin count must be at least 2")
  }
  if (pretty) {
    base::pretty(domain %||% x, n = bins)
  } else {
    rng = range(domain %||% x, na.rm = TRUE)
    seq(rng[1], rng[2], length.out = bins + 1)
  }
}

#' @details \code{colorBin} also maps continuous numeric data, but performs
#'   binning based on value (see the \code{\link[base]{cut}} function).
#' @param bins Either a numeric vector of two or more unique cut points or a
#'   single number (greater than or equal to 2) giving the number of intervals
#'   into which the domain values are to be cut.
#' @param pretty Whether to use the function \code{\link{pretty}()} to generate
#'   the bins when the argument \code{bins} is a single number. When
#'   \code{pretty = TRUE}, the actual number of bins may not be the number of
#'   bins you specified. When \code{pretty = FALSE}, \code{\link{seq}()} is used
#'   to generate the bins and the breaks may not be "pretty".
#' @rdname colorNumeric
#' @export
colorBin = function(palette, domain, bins = 7, pretty = TRUE,
  na.color = "#808080", alpha = FALSE) {

  # domain usually needs to be explicitly provided (even if NULL) but not if
  # breaks are specified
  if (missing(domain) && length(bins) > 1) {
    domain = NULL
  }
  autobin = is.null(domain) && length(bins) == 1
  if (!is.null(domain))
    bins = getBins(domain, NULL, bins, pretty)
  numColors = if (length(bins) == 1) bins else length(bins) - 1
  colorFunc = colorFactor(palette, domain = if (!autobin) 1:numColors, na.color = na.color)
  pf = safePaletteFunc(palette, na.color, alpha)

  withColorAttr('bin', list(bins = bins, na.color = na.color), function(x) {
    if (length(x) == 0 || all(is.na(x))) {
      return(pf(x))
    }
    binsToUse = getBins(domain, x, bins, pretty)
    ints = cut(x, binsToUse, labels = FALSE, include.lowest = TRUE, right = FALSE)
    if (any(is.na(x) != is.na(ints)))
      warning("Some values were outside the color scale and will be treated as NA")
    colorFunc(ints)
  })
}

#' @details \code{colorQuantile} similarly bins numeric data, but via the
#'   \code{\link[stats]{quantile}} function.
#' @param n Number of equal-size quantiles desired. For more precise control,
#'   use the \code{probs} argument instead.
#' @param probs See \code{\link[stats]{quantile}}. If provided, the \code{n}
#'   argument is ignored.
#' @rdname colorNumeric
#' @export
colorQuantile = function(palette, domain, n = 4,
  probs = seq(0, 1, length.out = n + 1), na.color = "#808080", alpha = FALSE) {

  if (!is.null(domain)) {
    bins = quantile(domain, probs, na.rm = TRUE, names = FALSE)
    return(withColorAttr(
      'quantile', list(probs = probs, na.color = na.color),
      colorBin(palette, domain = NULL, bins = bins, na.color = na.color,
        alpha = alpha)
    ))
  }

  # I don't have a precise understanding of how quantiles are meant to map to colors.
  # If you say probs = seq(0, 1, 0.25), which has length 5, does that map to 4 colors
  # or 5? 4, right?
  colorFunc = colorFactor(palette, domain = 1:(length(probs) - 1),
    na.color = na.color, alpha = alpha)

  withColorAttr('quantile', list(probs = probs, na.color = na.color), function(x) {
    binsToUse = quantile(x, probs, na.rm = TRUE, names = FALSE)
    ints = cut(x, binsToUse, labels = FALSE, include.lowest = TRUE, right = FALSE)
    if (any(is.na(x) != is.na(ints)))
      warning("Some values were outside the color scale and will be treated as NA")
    colorFunc(ints)
  })
}

# If already a factor, return the levels. Otherwise, convert to factor then
# return the levels.
calcLevels = function(x, ordered) {
  if (is.null(x)) {
    NULL
  } else if (is.factor(x)) {
    levels(x)
  } else if (ordered) {
    unique(x)
  } else {
    sort(unique(x))
  }
}

getLevels = function(domain, x, lvls, ordered) {
  if (!is.null(lvls))
    return(lvls)

  if (!is.null(domain)) {
    return(calcLevels(domain, ordered))
  }

  if (!is.null(x)) {
    return(calcLevels(x, ordered))
  }
}

#' @details \code{colorFactor} maps factors to colors. If the palette is
#'   discrete and has a different number of colors than the number of factors,
#'   interpolation is used.
#' @param levels An alternate way of specifying levels; if specified, domain is
#'   ignored
#' @param ordered If \code{TRUE} and \code{domain} needs to be coerced to a
#'   factor, treat it as already in the correct order
#' @rdname colorNumeric
#' @export
colorFactor = function(palette, domain, levels = NULL, ordered = FALSE,
  na.color = "#808080", alpha = FALSE) {

  # domain usually needs to be explicitly provided (even if NULL) but not if
  # levels are specified
  if (missing(domain) && !is.null(levels)) {
    domain = NULL
  }

  if (!is.null(levels) && anyDuplicated(levels)) {
    warning("Duplicate levels detected")
    levels = unique(levels)
  }
  lvls = getLevels(domain, NULL, levels, ordered)
  hasFixedLevels = is.null(lvls)
  pf = safePaletteFunc(palette, na.color, alpha)

  withColorAttr('factor', list(na.color = na.color), function(x) {
    if (length(x) == 0 || all(is.na(x))) {
      return(pf(x))
    }

    lvls = getLevels(domain, x, lvls, ordered)

    if (!is.factor(x) || hasFixedLevels) {
      origNa = is.na(x)
      # Seems like we need to re-factor if hasFixedLevels, in case the x value
      # has a different set of levels (like if droplevels was called in between
      # when the domain was given and now)
      x = factor(x, lvls)
      if (any(is.na(x) != origNa)) {
        warning("Some values were outside the color scale and will be treated as NA")
      }
    }

    scaled = scales::rescale(as.integer(x), from = c(1, length(lvls)))
    if (any(scaled < 0 | scaled > 1, na.rm = TRUE)) {
      warning("Some values were outside the color scale and will be treated as NA")
    }
    pf(scaled)
  })
}

#' @details The \code{palette} argument can be any of the following:
#' \enumerate{
#'   \item{A character vector of RGB or named colors. Examples: \code{palette()}, \code{c("#000000", "#0000FF", "#FFFFFF")}, \code{topo.colors(10)}}
#'   \item{The name of an RColorBrewer palette, e.g. \code{"BuPu"} or \code{"Greens"}.}
#'   \item{A function that receives a single value between 0 and 1 and returns a color. Examples: \code{colorRamp(c("#000000", "#FFFFFF"), interpolate="spline")}.}
#' }
#' @examples
#' pal = colorBin("Greens", domain = 0:100)
#' pal(runif(10, 60, 100))
#'
#' \donttest{
#' # Exponential distribution, mapped continuously
#' previewColors(colorNumeric("Blues", domain = NULL), sort(rexp(16)))
#' # Exponential distribution, mapped by interval
#' previewColors(colorBin("Blues", domain = NULL, bins = 4), sort(rexp(16)))
#' # Exponential distribution, mapped by quantile
#' previewColors(colorQuantile("Blues", domain = NULL), sort(rexp(16)))
#'
#' # Categorical data; by default, the values being colored span the gamut...
#' previewColors(colorFactor("RdYlBu", domain = NULL), LETTERS[1:5])
#' # ...unless the data is a factor, without droplevels...
#' previewColors(colorFactor("RdYlBu", domain = NULL), factor(LETTERS[1:5], levels=LETTERS))
#' # ...or the domain is stated explicitly.
#' previewColors(colorFactor("RdYlBu", levels = LETTERS), LETTERS[1:5])
#' }
#' @rdname colorNumeric
#' @name colorNumeric
NULL


safePaletteFunc = function(pal, na.color, alpha) {
  toPaletteFunc(pal, alpha=alpha) %>% filterRGB() %>% filterZeroLength() %>%
    filterNA(na.color) %>% filterRange()
}

toPaletteFunc = function(pal, alpha) {
  UseMethod("toPaletteFunc")
}

# Strings are interpreted as color names, unless length is 1 and it's the name
# of an RColorBrewer palette
toPaletteFunc.character = function(pal, alpha) {
  if (length(pal) == 1 && pal %in% row.names(RColorBrewer::brewer.pal.info)) {
    return(scales::colour_ramp(
      RColorBrewer::brewer.pal(RColorBrewer::brewer.pal.info[pal, 'maxcolors'], pal),
      alpha = alpha
    ))
  }

  scales::colour_ramp(pal, alpha = alpha)
}

# Accept colorRamp style matrix
toPaletteFunc.matrix = function(pal, alpha) {
  toPaletteFunc(rgb(pal, maxColorValue = 255), alpha = alpha)
}

# If a function, just assume it's already a function over [0-1]
toPaletteFunc.function = function(pal, alpha) {
  pal
}

#' Color previewing utility
#'
#' @param pal A color mapping function, like those returned from \code{\link{colorNumeric}}, et al
#' @param values A set of values to preview colors for
#' @return An HTML-based list of the colors and values
#' @export
previewColors = function(pal, values) {
  heading = htmltools::tags$code(deparse(substitute(pal)))
  subheading = htmltools::tags$code(deparse(substitute(values)))

  htmltools::browsable(
    with(htmltools::tags, htmltools::tagList(
      head(
        style(type = "text/css",
          "table { border-spacing: 1px; }",
          "body { font-family: Helvetica; font-size: 13px; color: #444; }",
          ".swatch { width: 24px; height: 18px; }",
          ".value { padding-left: 6px; }",
          "h3 code { font-weight: normal; }"
        )
      ),
      h3("Colors:", heading, br(), "Values:", class = "subhead", subheading),
      table(
        mapply(pal(values), values, FUN = function(color, x) {
          htmltools::tagList(tr(
            td(class = "swatch", style = paste0("background-color:", color)),
            td(class = "value", format(x, digits = 5))
          ))
        })
      )
    ))
  )
}

# colorRamp(space = 'Lab') throws error when called with
# zero-length input
filterZeroLength = function(f) {
  force(f)
  function(x) {
    if (length(x) == 0) {
      character(0)
    } else {
      f(x)
    }
  }
}

# Wraps an underlying non-NA-safe function (like colorRamp).
filterNA = function(f, na.color) {
  force(f)
  function(x) {
    results = character(length(x))
    nas = is.na(x)
    results[nas] = na.color
    results[!nas] = f(x[!nas])
    results
  }
}

# Wraps a function that may return RGB color matrix instead of rgb string.
filterRGB = function(f) {
  force(f)
  function(x) {
    results = f(x)
    if (is.character(results)) {
      results
    } else if (is.matrix(results)) {
      rgb(results, maxColorValue = 255)
    } else {
      stop("Unexpected result type ", class(x)[[1]])
    }
  }
}

filterRange = function(f) {
  force(f)
  function(x) {
    x[x < 0 | x > 1] = NA
    f(x)
  }
}
