library(DECIPHER)
library(tidyverse)
library(phyloseq)

load('cleaned/ps_samfilt.Rdata')

# Extract the tax table and make sure it has its sequences associated
taxtab = data.frame(tax_table(ps_samfilt))
rownames(taxtab) = seqs_samfilt[rownames(taxtab)]
nohost = (taxtab
	%>% mutate(Seq = rownames(.))
	%>% filter(!is.na(Phylum),
			   Kingdom %in% c('Bacteria','Archaea')))

# Get the sequences on their own for clustering
seqs = as.character(nohost$Seq)

# Start by making a multisequence alignment of the ASVs
aln = AlignSeqs(DNAStringSet(seqs), processors = 10)

save(aln, file = 'intermed/aln_samfilt.Rdata')