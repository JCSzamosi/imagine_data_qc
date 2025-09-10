# Load packages

library(DECIPHER)

# Define I/O variables

outdir = 'intermed'
outfnm = 'clsts99.Rdata'
indir = 'cleaned/asvs/full/'
inseq = 'full_seqs.Rdata'
inf = file.path(indir, inseq)
outf = file.path(outdir, outfnm)

cat('\nLoad the sequences\n')

load(inf)

# Cluster sequences using UPGMA method (splits the difference between
# "complete" and "single" method with a maximum between-cluster difference of
# 0.01)

cat('\nStart clustering sequences\n')

clsts = Clusterize(DNAStringSet(seqs), cutoff = 0.01,
                   includeTerminalGaps = TRUE,
									 processors = 40)
	# Each sequence has its own row, in the order they were originally listed in
	# The cluster number that each sequence belongs to is listed in its row in
	# the "cluster" column

cat('\nFinished clustering\n')

# Add the sequences to the data frame so we can make consensus sequences
clsts$seqs = seqs[rownames(clsts)]

# Write the file

cat('\nWriting the cluster data frame\n')

if (!dir.exists(outdir)){
	dir.create(outdir)
}
save('clsts', file = outf)

cat('\nWriting Track Stats\n')

stats_df = data.frame(Step = 'cluster99/03_make_clusters.R',
						Samples = c(NA,NA),
						Taxa = c(nrow(clsts),
								length(unique(clsts$cluster))),
						File = c(paste(outf,'- ASVs'),
								paste(outf, '- clusters')))

write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)

cat('\nDONE\n')
