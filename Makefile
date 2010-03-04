CC=gcc
CFLAGS+=-g -std=c99 -Wall -Wextra -pedantic -pipe
LDFLAGS+=-Wl,-lrt

# Phony targets.
.PHONY: all expose clean clean-texincludes mrproper

# Top-level documents.
DOCS = expose thesis

# Binaries.
BINS = forscript

# “Everything” means the exposé, the thesis and the binaries.
all: $(DOCS) $(BINS)

# A PDF needs its source file.
$(addsuffix .pdf,$(DOCS)): %.pdf: %.tex
	pdflatex $< && pdflatex $<

# The thesis source is built using noweave.
thesis.tex: thesis.nw
	noweave -latex -delay -t2 -autodefs c -index thesis.nw > thesis.tex

# A source file is built using notangle.
$(addsuffix .c,$(BINS)): thesis.nw
	notangle "-R$@" "$<" > "$@"

# A binary is built using the source file.
$(BINS): %: %.c
	$(CC) -o "$@" $(CFLAGS) $(LDFLAGS) "$<"

# Phony exposé target.
expose: expose.pdf

# Phony thesis target.
thesis: thesis.pdf

# Remove temporary TeX and C files.
clean:
	# Remove aux files from PDF generation.
	rm -f $(foreach stem,$(DOCS),$(foreach ext,aux log out pdf,$(stem).$(ext)))
	# Remove weaved thesis TeX source.
	rm -f thesis.tex
	# Remove tangled C sources.
	rm -f $(addsuffix .c,$(BINS))
