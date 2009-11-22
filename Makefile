# Phony targets.
.PHONY: all texincludes expose clean clean-texincludes mrproper

# Top-level documents.
DOCS = expose thesis

# “Everything” means the exposé and the thesis.
all: $(DOCS)

# Required LaTeX includes in my dotfiles repository.
TEXINCLUDES = unicode.tex article.tex

# Try to fetch missing TeX files from my dotfiles repository.
$(TEXINCLUDES):
	curl -o $@ http://github.com/scy/dotscy/raw/master/.tex/$@ || wget -O $@ http://github.com/scy/dotscy/raw/master/.tex/$@

# A PDF needs my includes and its source file.
$(addsuffix .pdf,$(DOCS)): %.pdf: %.tex $(TEXINCLUDES)
	pdflatex $<

# The thesis source is built using noweave.
thesis.tex: thesis.nw $(TEXINCLUDES)
	noweave -latex -delay -t -index thesis.nw > thesis.tex

# Phony exposé target.
expose: expose.pdf

# Phony thesis target.
thesis: thesis.pdf

# Phony texincludes target.
texincludes: clean-texincludes $(TEXINCLUDES)

# Remove temporary TeX files.
clean:
	# Remove aux files from PDF generation.
	rm -f $(foreach stem,$(DOCS),$(foreach ext,aux log out pdf,$(stem).$(ext)))
	# Remove weaved thesis TeX source.
	rm -f thesis.tex

# Remove the includes, for example to force re-fetching them.
clean-texincludes:
	rm -f $(TEXINCLUDES)

# Make clean and also remove texincludes.
mrproper: clean-texincludes clean
