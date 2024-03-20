library(DECIPHER)
library(dada2)
library(phyloseq)
library(tidyverse)

load('intermed/aln_samfilt.Rdata')
load('cleaned/ps_samfilt.Rdata')

taxtab = data.frame(tax_table(ps_samfilt))
rownames(taxtab) = seqs_samfilt[rownames(taxtab)]
nohost = (taxtab
	%>% mutate(Seq = rownames(.))
	%>% filter(!is.na(Phylum),
			   Kingdom %in% c('Bacteria','Archaea')))

# Get the sequences on their own for clustering
seqs = as.character(nohost$Seq)

# Create a distance matrix 
dmat = DistanceMatrix(aln, type = 'dist')

# Cluster sequences using UPGMA method (splits the difference between
# "complete" and "single" method with a maximum between-cluster difference of
# 0.01)
clsts = IdClusters(dmat, cutoff = 0.01, method = 'UPGMA')
	# Each sequence has its own row, in the order they were originally listed in
	# The cluster number that each sequence belongs to is listed in its row in
	# the "cluster" column

# Add the sequences to the data frame so we can make consensus sequences
clsts$seqs = seqs

save(list = c('dmat','clsts','seqs'), file = 'intermed/clst_samfilt.Rdata')