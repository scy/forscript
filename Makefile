# Phony targets.
.PHONY: all texincludes expose clean clean-texincludes mrproper

# Top-level documents.
DOCS = expose thesis

# Binaries.
BINS = forscript

# “Everything” means the exposé, the thesis and the binaries.
all: $(DOCS) $(BINS)

# Required LaTeX includes in my dotfiles repository.
TEXINCLUDES = unicode.tex article.tex

# Try to fetch missing TeX files from my dotfiles repository.
$(TEXINCLUDES):
	curl -o $@ http://github.com/scy/dotscy/raw/master/.tex/$@ || wget -O $@ http://github.com/scy/dotscy/raw/master/.tex/$@

# A PDF needs my includes and its source file.
$(addsuffix .pdf,$(DOCS)): %.pdf: %.tex $(TEXINCLUDES)
	pdflatex $< && pdflatex $<

# The thesis source is built using noweave.
thesis.tex: thesis.nw $(TEXINCLUDES)
	noweave -latex -delay -t2 -autodefs c -index thesis.nw > thesis.tex

# A source file is built using notangle.
$(addsuffix .c,$(BINS)): thesis.nw
	notangle "-R$@" "$<" > "$@"

# A binary is built using the source file.
$(BINS): %: %.c
	gcc -std=c99 -Wl,-lrt -g -o "$@" -Wall -Wextra -pedantic -fstack-protector-all -pipe "$<"

# Phony exposé target.
expose: expose.pdf

# Phony thesis target.
thesis: thesis.pdf

# Phony texincludes target.
texincludes: clean-texincludes $(TEXINCLUDES)

# Remove temporary TeX and C files.
clean:
	# Remove aux files from PDF generation.
	rm -f $(foreach stem,$(DOCS),$(foreach ext,aux log out pdf,$(stem).$(ext)))
	# Remove weaved thesis TeX source.
	rm -f thesis.tex
	# Remove tangled C sources.
	rm -f $(addsuffix .c,$(BINS))

# Remove the includes, for example to force re-fetching them.
clean-texincludes:
	rm -f $(TEXINCLUDES)

# Make clean and also remove texincludes.
mrproper: clean-texincludes clean
