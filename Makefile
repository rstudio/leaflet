all:
	Rscript -e "rmarkdown::render('../leaflet/vignettes/leaflet.Rmd', 'html_document')"
	cp ../leaflet/vignettes/styles.css ./
	rm -r leaflet_files
	mv ../leaflet/vignettes/leaflet_files ../leaflet/vignettes/leaflet.html ./
	mv leaflet.html index.html
	# [Yihui] normally I `git commit --amend` and `git push -f` because the
	# gh-pages branch only stores by-products from leaflet.Rmd, and I do not want
	# to accumulate stuff in version control history, but I do check `git diff`
	# before I commit
