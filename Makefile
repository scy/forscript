# Phony targets.
.PHONY: all clean texincludes expose

# Currently, the project only consists of the Exposé.
all: expose

# Required LaTeX includes in my dotfiles repository.
texincludes: unicode.tex article.tex

# Try to fetch missing TeX files from my dotfiles repository.
%.tex:
	curl -o $@ http://github.com/scy/dotscy/raw/master/.tex/$@ || wget -O $@ http://github.com/scy/dotscy/raw/master/.tex/$@

# The Exposé needs my includes.
expose.pdf: texincludes
	pdflatex expose.tex

# Phony Exposé target.
expose: expose.pdf

# Remove temporary TeX files and the includes.
clean:
	rm $(addprefix expose.,aux log out pdf) $(addsuffix .tex,unicode article)
