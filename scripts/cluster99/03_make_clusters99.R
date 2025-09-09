# Load packages

library(DECIPHER)

# Define I/O variables

outdir = 'intermed'
indir = 'cleaned'
inseq = 'full_seqs.Rdata')
inf = file.path(indir, inseq)

load(inf)

# Cluster sequences using UPGMA method (splits the difference between
# "complete" and "single" method with a maximum between-cluster difference of
# 0.01)
clsts = Clusterize(DNAStringSet(seqs), cutoff = 0.01,
                   includeTerminalGaps = TRUE,
									 processors = 40)
	# Each sequence has its own row, in the order they were originally listed in
	# The cluster number that each sequence belongs to is listed in its row in
	# the "cluster" column

# Add the sequences to the data frame so we can make consensus sequences
clsts$seqs = seqs[rownames(clsts)]

if (!dir.exists(outdir)){
	dir.create(outdir)
}
save('clsts', file = file.path(outdir, 'clst99.Rdata'))
