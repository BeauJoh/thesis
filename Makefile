
all: thesis.pdf #chapter-3-figures survey thesis-map.pdf

chapter-3-figures: chapter-3-analysis/generate_thesis_runtime_charts.R chapter-3-analysis/energy_charts.R
	cd chapter-3-analysis; Rscript energy_charts.R; Rscript generate_thesis_runtime_charts.R; cd ..;

chapter-4-figures: chapter-4-analysis/generate_thesis_runtime_charts.R
	cd chapter-4-analysis; Rscript generate_thesis_runtime_charts.R; cd ..;

survey: analysis/analysis.R
	cd analysis; Rscript analysis.R; cd ..;

grammarly: source/14-chapter-6-conclusions-and-future-work.md
	pkill Grammarly || true #if grammarly already exists kill it
	pandoc  --wrap=preserve \
		--filter pandoc-crossref \
		--filter pandoc-citeproc \
		--number-sections \
		-t plain \
		-o output/grammarly.txt source/14-chapter-6-conclusions-and-future-work.md
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

chapter-3.txt: source/11-chapter-3-ode.md
	pandoc source/11-chapter-3-ode.md \
		-o output/chapter-3.txt \
		--wrap=preserve \
		--filter pandoc-crossref \
		--filter pandoc-citeproc \
		--filter=./pandoc-tools/table-filter.py \
		--bibliography=source/bibliography.bib \
		./packages.yaml \

chapter-4.txt: source/12-chapter-4-aiwc.md
	pandoc source/12-chapter-4-aiwc.md \
		-o output/chapter-4.txt \
		--wrap=preserve \
		--filter pandoc-crossref \
		--filter pandoc-citeproc \
		--filter=./pandoc-tools/table-filter.py \
		--bibliography=source/bibliography.bib \
		./packages.yaml \

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

thesis.pdf: 
	mkdir -p output;
	pandoc source/*.md \
		-o output/thesis.pdf \
		--wrap=preserve \
		--filter pandoc-crossref \
		--filter pandoc-citeproc \
		--filter ./pandoc-tools/bib-filter.py \
		--filter=./pandoc-tools/table-filter.py \
		--bibliography=source/bibliography.bib \
		--csl=./pandoc-tools/ieee.csl \
		--variable papersize=a4paper \
		--variable document-class=book \
		--top-level-division=chapter \
		./packages.yaml \

thesis.tex: 
	pandoc source/*.md \
		-o output/thesis.tex \
		--wrap=preserve \
		--filter pandoc-crossref \
		--filter pandoc-citeproc \
		--filter ./pandoc-tools/bib-filter.py \
		--csl=./pandoc-tools/ieee.csl \
		--filter=./pandoc-tools/table-filter.py \
		--bibliography=source/bibliography.bib \
		--variable papersize=a4paper \
		--top-level-division=chapter \
		./packages.yaml \

clean:
	rm output/thesis-map.pdf output/thesis.pdf

