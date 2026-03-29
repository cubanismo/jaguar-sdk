
TARGETS = 12\ -\ Cinepak\ for\ Jaguar.pdf
LOGFILES = $(subst .pdf,.log,$(TARGETS)) texput.log
AUXFILES = $(subst .pdf,.aux,$(TARGETS))
OUTFILES = $(subst .pdf,.out,$(TARGETS))
TOCFILES = $(subst .pdf,.toc,$(TARGETS))

all: $(TARGETS)

.SUFFIXES: .pdf .tex

.tex.pdf:
	pdflatex "$<" && pdflatex "$<"

.PHONY: clean
clean:
	$(RM) -f $(TARGETS) $(LOGFILES) $(AUXFILES) $(OUTFILES) $(TOCFILES)
