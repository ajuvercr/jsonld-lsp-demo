all: pdf


dir:
	mkdir -p build/chapters

pdf: dir
	pdflatex --output-directory build/ --shell-escape main.tex
	bibtex build/main
	pdflatex --output-directory build/ --shell-escape main.tex
	pdflatex --output-directory build/ --shell-escape main.tex

open: pdf
	${BROWSER} build/main.pdf

clean:
	rm -rf build/
