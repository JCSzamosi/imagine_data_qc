# Load Packages ####

library(dada2)
library(dplyr)
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

refd = 'refs'
if (db == 'silva'){
    refdb = 'silva_nr99_v138_train_set.fa'
} else if (db == 'gg'){
    refdb = 'gg2_2024_09_toGenus_trainset.fa'
} else {
    stop('Database must be one of "silva" or "gg".')
}
ref = file.path(refd, refdb)
indir = 'intermed'
conseqf = 'conseqs99.csv'
outf = sprintf('clstaxtab99_%s.csv', db)

# Read in the data ####

cat('\nRead in the consensus sequences\n')

conseq = read.csv(file = file.path(indir, conseqf),
                  row.names = 1, header = TRUE)

seqs = conseq$conseq

cat('\nCheck sequences\n')
if (length(unique(seqs))/length(seqs) != 1){
    msg = 'The consensus sequences are not all unique'
    stop(msg)
}
cat('\nStart assigning taxonomy\n')
taxtab = assignTaxonomy(seqs,
                        refFasta = ref,
                        tryRC = TRUE, multithread = 40, verbose = TRUE)

cat('\nFinished assigning taxonomy\n')

taxtab = (taxtab
          %>% data.frame()
          %>% mutate(seqs = rownames(.))
          %>% full_join(conseq, by = c('seqs' = 'conseq'))
          %>% select(-max, -min, -size))

cat('\nWrite tax table')

outp = file.path(indir, outf)
write.csv(taxtab, outp)

cat('\nWriting track stats\n')

stats_df = data.frame(Step = 'cluster99/07_assign_tax_clsts99.R',
						Samples = NA,
						Taxa = c(nrow(taxtab)),
						File = c(outp))
write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)

cat('\nDone\n')
