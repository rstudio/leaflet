library(testit)

bw <- c("black", "white")

# Do these cases make sense?
assert(
  colorBin(bw, NULL)(1) == "#777777",
  colorBin(bw, 1)(1) == "#FFFFFF",
  TRUE
)

# Outside of domain? Return na.color
suppressWarnings(
assert(
  identical("#808080", colorFactor(bw, letters)("foo")),
  identical("#808080", colorQuantile(bw, 0:1)(-1)),
  identical("#808080", colorQuantile(bw, 0:1)(2)),
  identical("#808080", colorNumeric(bw, c(0, 1))(-1)),
  identical("#808080", colorNumeric(bw, c(0, 1))(2)),
  is.na(colorFactor(bw, letters, na.color = NA)("foo")),
  is.na(colorQuantile(bw, 0:1, na.color = NA)(-1)),
  is.na(colorQuantile(bw, 0:1, na.color = NA)(2)),
  is.na(colorNumeric(bw, c(0, 1), na.color = NA)(-1)),
  is.na(colorNumeric(bw, c(0, 1), na.color = NA)(2)),
  has_warning(colorFactor(bw, letters, na.color = NA)("foo")),
  has_warning(colorQuantile(bw, 0:1, na.color = NA)(-1)),
  has_warning(colorQuantile(bw, 0:1, na.color = NA)(2)),
  has_warning(colorNumeric(bw, c(0, 1), na.color = NA)(-1)),
  has_warning(colorNumeric(bw, c(0, 1), na.color = NA)(2)),
  TRUE
)
)

assert(
  identical(
    c("#000000", "#7F7F7F", "#FFFFFF"),
    colorNumeric(colorRamp(bw), NULL)(c(0, 0.5, 1))
  ),
  identical(
    c("#000000", "#777777", "#FFFFFF", "#FFFFFF00", "blue"),
    colorNumeric(c(bw, "#FFFFFF00"), NULL, na.color = "blue", alpha = TRUE)(c(0, 0.25, 0.5, 1, NA))
  )
)

assert(
  identical(
    c("#000000", "#FFFFFF"),
    colorBin(bw, NULL)(c(1, 2))
  ),

  identical(
    c("#000000", "#FFFFFF"),
    colorBin(bw, c(1, 2))(c(1, 2))
  ),

  identical(
    c("#000000", "#FFFFFF"),
    colorBin(bw, c(1, 2), 2)(c(1, 2))
  ),

  identical(
    c("#000000", "#FFFFFF"),
    colorBin(bw, NULL, bins = c(1, 1.5, 2))(c(1, 2))
  ),

  identical(
    c("#000000", "#FFFFFF"),
    colorBin(bw, c(1, 2), bins = c(1, 1.5, 2))(c(1, 2))
  ),

  TRUE
)

assert(
  identical(
    c("#000000", "#777777", "#FFFFFF"),
    colorNumeric(bw, NULL)(1:3)
  ),

  identical(
    c("#000000", "#777777", "#FFFFFF"),
    colorNumeric(bw, c(1:3))(1:3)
  ),

  identical(
    rev(c("#000000", "#777777", "#FFFFFF")),
    colorNumeric(rev(bw), c(1:3))(1:3)
  ),

  TRUE
)

assert(

  # domain != unique(x)
  identical(
    c("#000000", "#0E0E0E", "#181818"),
    colorFactor(bw, LETTERS)(LETTERS[1:3])
  ),

  # domain == unique(x)
  identical(
    c("#000000", "#777777", "#FFFFFF"),
    colorFactor(bw, LETTERS[1:3])(LETTERS[1:3])
  ),

  # no domain
  identical(
    c("#000000", "#777777", "#FFFFFF"),
    colorFactor(bw, NULL)(LETTERS[1:3])
  ),

  # Non-factor domains are sorted unless instructed otherwise
  identical(
    c("#000000", "#777777", "#FFFFFF"),
    colorFactor(bw, rev(LETTERS[1:3]))(LETTERS[1:3])
  ),
  identical(
    rev(c("#000000", "#777777", "#FFFFFF")),
    colorFactor(bw, rev(LETTERS[1:3]), ordered = TRUE)(LETTERS[1:3])
  ),

  TRUE
)
