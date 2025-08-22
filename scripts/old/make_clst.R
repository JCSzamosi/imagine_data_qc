library(DECIPHER)

load('cleaned/seqs_full.Rdata')

# Cluster sequences using UPGMA method (splits the difference between
# "complete" and "single" method with a maximum between-cluster difference of
# 0.01)
clsts = Clusterize(DNAStringSet(seqs), cutoff = 0.01,
                   includeTerminalGaps = TRUE,
									 processors = 10)
	# Each sequence has its own row, in the order they were originally listed in
	# The cluster number that each sequence belongs to is listed in its row in
	# the "cluster" column

# Add the sequences to the data frame so we can make consensus sequences
clsts$seqs = seqs[rownames(clsts)]

save('clsts', file = 'intermed/clst.Rdata')
