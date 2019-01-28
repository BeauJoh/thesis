
all: figure wide-slides.pdf #slides.pdf 

figure: analysis_tools/generate-figures.Rmd
	mkdir -p output;
	Rscript -e "library(knitr); knit(input='analysis_tools/generate-figures.Rmd',output='output/figures.md')"

wide-slides.pdf: slides.md wide-packages.yaml anu-beamer-template-corrections.tex
	mkdir -p output;
	pandoc slides.md \
		--wrap=preserve \
		--filter pandoc-crossref \
		--filter pandoc-citeproc \
		--filter ./pandoc-tools/bib-filter.py \
		--filter=./pandoc-tools/table-filter.py \
		--bibliography=../source/bibliography.bib \
		--csl=./pandoc-tools/ieee.csl \
		--latex-engine-opt=-shell-escape \
		--include-in-header=./anu-beamer-template-corrections.tex \
		./wide-packages.yaml \
		-t beamer \
		-o wide-slides.pdf

slides.pdf: slides.md packages.yaml anu-beamer-template-corrections.tex
	mkdir -p output;
	pandoc slides.md \
		--wrap=preserve \
		--filter pandoc-crossref \
		--filter pandoc-citeproc \
		--filter ./pandoc-tools/bib-filter.py \
		--filter=./pandoc-tools/table-filter.py \
		--bibliography=../source/bibliography.bib \
		--csl=./pandoc-tools/ieee.csl \
		--latex-engine-opt=-shell-escape \
		--include-in-header=./anu-beamer-template-corrections.tex \
		./packages.yaml \
		-t beamer \
		-o slides.pdf


clean:
	rm -rf slides.pdf output figure

