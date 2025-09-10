# Load packages

library(dada2)
library(readr)

# Define I/O Variables

datdir = 'data'
seqfile = 'merged_seqtab.rds'
inf = file.path(datdir, seqfile)
refd = 'refs'
refdb = 'silva_nr99_v138_train_set.fa'
ref = file.path(refd, refdb)
outf = 'merged_taxtab.rds'

# Load data

cat('\nRead in the asv table\n')
asvtab = readRDS(inf)
seqs = rownames(asvtab)

# Check the sequences

cat('\nCheck sequences\n')
if (!length(unique(seqs))/length(seqs) == 1){
    msg = 'The ASVs are not all unique'
    stop(msg)
}

# Assign taxonomy
cat('\nStart assigning taxonomy\n')
taxtab = assignTaxonomy(seqs,
                        refFasta = ref,
                        tryRC = TRUE, multithread = 40, verbose = TRUE)

# Write the tax table
outp = file.path(datdir, outf)
cat('\nWrite tax table\n')
write_rds(taxtab, file = outp)

# Write the tracking stats

cat('\nWrite tracking stats\n')

stats_df = data.frame(Step = '01_assign_tax_asvs.R',
					Samples = NA,
					Taxa = nrow(taxtab),
					File = outp)
write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)

cat('\nDone\n')
