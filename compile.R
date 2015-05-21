set.seed(0102)
options(htmlwidgets.TOJSON_ARGS = list(pretty = TRUE))
Sys.setenv(R_KNITR_OPTIONS = 'knitr.chunk.tidy = FALSE')
knitr::opts_chunk$set(out.width = '100%')
library(leaflet)
f = rmarkdown::render(commandArgs(TRUE))
# remove version numbers in HTML
r = '-\\d+[.]\\d+([.]\\d+)?$'
v1 = rev(list.files('libs', r, full.names = TRUE))
v2 = gsub(r, '', v1)
x = readLines(f)
for (i in seq_along(v1)) {
  x = gsub(v1[i], v2[i], x, fixed = TRUE)
}
# delete lower versions of libraries, and only use higher versions
i = duplicated(v2)
unlink(c(v1[i], v2), recursive = TRUE)
file.rename(v1[!i], v2[!i])
writeLines(x, f)

