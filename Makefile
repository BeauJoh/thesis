
all: thesis-map.pdf thesis.pdf

thesis-map.pdf: thesis-map.md
	pandoc  --wrap=preserve \
		--filter pandoc-crossref \
		--filter pandoc-citeproc \
		--filter=./pandoc-tools/table-filter.py \
		--variable papersize=a4paper \
		--variable sectionsDepth=-1 \
		./packages.yaml \
		-o output/thesis-map.pdf thesis-map.md

thesis.pdf: source/08-abbreviations.md source/09-chapter-1-introduction.md
	pandoc source/*.md \
		-o output/thesis.pdf \
		--wrap=preserve \
		--filter pandoc-crossref \
		--filter pandoc-citeproc \
		--filter=./pandoc-tools/table-filter.py \
		--bibliography=source/bibliography.bib \
		--variable papersize=a4paper \
		--top-level-division=chapter \
		./packages.yaml \

clean:
	rm output/thesis-map.pdf output/thesis.pdf

