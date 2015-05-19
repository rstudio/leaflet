HTML_FILES := $(patsubst %.Rmd, %.html ,$(wildcard *.Rmd)) \
              $(patsubst %.md, %.html ,$(wildcard *.md))

all: html


html: $(HTML_FILES)

%.html: %.Rmd _includes/* _output.yaml
	Rscript compile.R "$<"

%.html: %.md
	Rscript compile.R "$<"

.PHONY: clean
clean:
	$(RM) $(HTML_FILES)
	$(RM) -r libs

