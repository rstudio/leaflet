all:
	cp ../leaflet/vignettes/styles.css ../leaflet/vignettes/leaves.jpg ./
	Rscript compile.R leaflet.Rmd
	mv leaflet.html index.html
	# [Yihui] normally I `git commit --amend` and `git push -f` because the
	# gh-pages branch only stores by-products from leaflet.Rmd, and I do not want
	# to accumulate stuff in version control history, but I do check `git diff`
	# before I commit
