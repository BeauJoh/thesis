
all: thesis-map.pdf thesis.pdf

grammarly: source/09-chapter-1-introduction.md
	pkill Grammarly || true #if grammarly already exists kill it
	pandoc  --wrap=preserve \
		--filter pandoc-crossref \
		--filter pandoc-citeproc \
		--number-sections \
		-t plain \
		-o output/grammarly.txt source/09-chapter-1-introduction.md #now get just the text
	open -a Grammarly output/grammarly.txt #and open it in grammarly

thesis-map.pdf: thesis-map.md
	pandoc  --wrap=preserve \
		--filter pandoc-crossref \
		--filter pandoc-citeproc \
		--filter=./pandoc-tools/table-filter.py \
		--variable papersize=a4paper \
		--variable sectionsDepth=-1 \
		./packages.yaml \
		-o output/thesis-map.pdf thesis-map.md

introduction.pdf: source/09-chapter-1-introduction.md
	pandoc source/09-chapter-1-introduction.md \
		-o output/introduction.pdf \
		--wrap=preserve \
		--filter pandoc-crossref \
		--filter pandoc-citeproc \
		--filter=./pandoc-tools/table-filter.py \
		--bibliography=source/bibliography.bib \
		--variable papersize=a4paper \
		--top-level-division=chapter \
		./packages.yaml \

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

