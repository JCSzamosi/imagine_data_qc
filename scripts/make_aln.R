library(DECIPHER)
library(tidyverse)
library(phyloseq)

load('cleaned/seqs_full.Rdata')

# Start by making a multisequence alignment of the ASVs
aln = AlignSeqs(DNAStringSet(seqs), processors = 10)

save(aln, file = 'intermed/aln_samfilt.Rdata')