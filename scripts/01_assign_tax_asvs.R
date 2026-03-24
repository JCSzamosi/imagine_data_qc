# Load packages

library(dada2)
library(readr)
library(optparse)

# Define I/O Variables

opts = list(
    make_option(c('-d', '--db'), type = 'character', default = 'silva',
                help = 'Either \'silva\' or \'gg\'. Defines the database.')
)

opt_parser <- OptionParser(option_list = opts)
# Parse the arguments
opt <- parse_args(opt_parser)
db = opt$db

datdir = 'data'
seqfile = 'merged_seqtab.rds'
inf = file.path(datdir, seqfile)
refd = 'refs'
if (db == 'silva'){
    refdb = 'silva_nr99_v138_train_set.fa'
} else if (db == 'gg'){
    refdb = 'gg2_2024_09_toGenus_trainset.fa'
} else {
    stop('Database must be one of "silva" or "gg".')
}

ref = file.path(refd, refdb)
outf = sprintf('merged_taxtab_%s.rds', db)

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

stats_df = data.frame(Step = sprintf('01_assign_tax_asvs.R: %s', db),
					Samples = NA,
					Taxa = nrow(taxtab),
					File = outp)
write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)

cat('\nDone\n')
