library(DECIPHER)
library(tidyverse)
library(phyloseq)

load('cleaned/seqs_samfilt.Rdata')

# Start by making a multisequence alignment of the ASVs
aln = AlignSeqs(DNAStringSet(seqs_samfilt), processors = 10)

save(aln, file = 'intermed/aln_samfilt.Rdata')