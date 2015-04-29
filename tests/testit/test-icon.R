library(testit)

f = tempfile()
unlink(f)

assert(
  'L.icon() constructs icons correctly',
  identical(L.icon(NULL), NULL),
  identical(L.icon(list(iconUrl = f)), list(iconUrl = f)),
  identical(
    L.icon(iconList(iconUrl = f, className = c('a', 'b'))),
    iconList(iconUrl = f, className = c('a', 'b'))
  ),
  TRUE
)

Rlogo = file.path(R.home('doc'), 'html', 'logo.jpg')

if (file.exists(Rlogo)) assert(
  'L.icon() base64 encodes local images',
  L.icon(list(iconUrl = Rlogo))$iconUrl != Rlogo
)

res = iconList(iconUrl = rep(f, 10), iconWidth = 10, iconHeight = c(10, 20))
assert(
  'iconList() works',
  length(res) == 2,
  res[[1]]$iconUrl == f,
  identical(res[[1]]$iconSize, c(10, 10)),
  identical(res[[2]]$iconSize, c(10, 20)),
  TRUE
)
