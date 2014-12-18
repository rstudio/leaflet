library(testit)

bw = c("black", "white")

# These currently error, but maybe shouldn't...?
assert(
  has_error(colorBin(bw, NULL)(1)),            # Return "#000000"?
  has_error(colorBin(bw, 1)(1)),               # Return "#000000"?
  TRUE
)

# Outside of domain? Return na.color
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

assert(
  identical(
    c("#000000", "#7F7F7F", "#FFFFFF"),
    colorNumeric(colorRamp(bw), NULL)(c(0, 0.5, 1))
  )
)

assert(
  identical(
    c("#000000", "#FFFFFF"),
    colorBin(bw, NULL)(c(1,2))
  ),

  identical(
    c("#000000", "#FFFFFF"),
    colorBin(bw, c(1,2))(c(1,2))
  ),

  identical(
    c("#000000", "#FFFFFF"),
    colorBin(bw, c(1,2), 2)(c(1,2))
  ),

  identical(
    c("#000000", "#FFFFFF"),
    colorBin(bw, NULL, bins=c(1,1.5,2))(c(1,2))
  ),

  identical(
    c("#000000", "#FFFFFF"),
    colorBin(bw, c(1,2), bins=c(1,1.5,2))(c(1,2))
  ),

  TRUE
)

assert(
  identical(
    c("#000000", "#7F7F7F", "#FFFFFF"),
    colorNumeric(bw, NULL)(1:3)
  ),

  identical(
    c("#000000", "#7F7F7F", "#FFFFFF"),
    colorNumeric(bw, c(1:3))(1:3)
  ),

  identical(
    rev(c("#000000", "#7F7F7F", "#FFFFFF")),
    colorNumeric(rev(bw), c(1:3))(1:3)
  ),

  TRUE
)

assert(

  # domain != unique(x)
  identical(
    c("#000000", "#0A0A0A", "#141414"),
    colorFactor(bw, LETTERS)(LETTERS[1:3])
  ),

  # domain == unique(x)
  identical(
    c("#000000", "#7F7F7F", "#FFFFFF"),
    colorFactor(bw, LETTERS[1:3])(LETTERS[1:3])
  ),

  # no domain
  identical(
    c("#000000", "#7F7F7F", "#FFFFFF"),
    colorFactor(bw, NULL)(LETTERS[1:3])
  ),

  # Non-factor domains are sorted unless instructed otherwise
  identical(
    c("#000000", "#7F7F7F", "#FFFFFF"),
    colorFactor(bw, rev(LETTERS[1:3]))(LETTERS[1:3])
  ),
  identical(
    rev(c("#000000", "#7F7F7F", "#FFFFFF")),
    colorFactor(bw, rev(LETTERS[1:3]), ordered = TRUE)(LETTERS[1:3])
  ),

  TRUE
)
