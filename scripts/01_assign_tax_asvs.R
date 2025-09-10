# Load packages

library(dada2)

# Define I/O Variables

datdir = 'data'
seqfile = 'merged_seqtab.rds'
inf = file.path(datdir, seqfile)
refd = 'refs'
refdb = 'silva_nr99_v138_train_set.fa'
ref = file.path(refd, refdb)
outf = 'merged_taxtab.rds'

# Load data

cat('\nRead in the asv table')
asvtab = readRDS(inf)
seqs = rownames(asvtab)

# Check the sequences

cat('\nCheck sequences')
if (!length(unique(seqs))/length(seqs) == 1){
    msg = 'The ASVs are not all unique'
    stop(msg)
}

# Assign taxonomy
cat('\nStart assigning taxonomy')
taxtab = assignTaxonomy(seqs,
                        refFasta = ref,
                        tryRC = TRUE, multithread = 40, verbose = TRUE)

# Write the tax table
outp = file.path(datdir, outf)
cat('\nWrite tax table')
writeRDS(taxtab, file = outp)

# Write the tracking stats

cat('\nWrite tracking stats\n')

stats_df = data.frame(Step = '01_assign_tax_asvs.R',
					Samples = NA,
					Taxa = nrow(taxtab),
					File = outp)
write.csv(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, row.names = FALSE, col.names = FALSE)

cat('\nDone\n')
