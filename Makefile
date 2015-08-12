# Analyse the distribution of word lengths
# Written by Shaun Jackman

all: en.html fr.html compare-en-fr.html

clean:
	rm -f *.tsv *.html

.PHONY: all clean
.DELETE_ON_ERROR:

# Download the list of English words
en.txt:
	curl -o en.txt http://www-01.sil.org/linguistics/wordlists/english/wordlist/wordsEn.txt

# Download the list of French words
fr.txt:
	curl -o fr.txt https://raw.githubusercontent.com/atebits/Words/master/Words/fr.txt

# Calculate words lengths
%.length.tsv: %.txt
	awk '{print length}' $*.txt >$*.length.tsv

# Count word length frequencies
%.length.count.tsv: %.length.tsv
	sort -n $*.length.tsv |uniq -c >$*.length.count.tsv

# Tidy up the TSV file
%.tsv: %.length.count.tsv
	awk 'BEGIN {print "Length\tCount"} {print $$2 "\t" $$1}' $*.length.count.tsv >$*.tsv

# Render the word-length RMarkdown report to HTML
%.html: word-length.rmd %.tsv
	Rscript -e 'rmarkdown::render("word-length.rmd", output_file = "$*.html")' $*.tsv

# Render RMarkdown to HTML
%.html: %.rmd
	Rscript -e 'rmarkdown::render("$*.rmd")'

# Data dependencies of the compare-en-fr RMarkdown report
compare-en-fr.html: en.tsv fr.tsv

# Render a figure of this pipeline
Makefile.gv: Makefile
	makefile2graph >Makefile.gv

# Render a GraphViz file to PNG
%.png: %.gv
	dot -Tpng -o $*.png $*.gv
