# Load Packages ####

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

datd = 'data'
if (db == 'silva'){
    taxf = 'merged_taxtab_silva.rds'
} else if (db == 'gg'){
    taxf = 'merged_taxtab_gg.rds'
} else {
    stop('Database must be one of "silva" or "gg".')
}
ref = file.path(datd, taxf)
indir = 'intermed'
conseqf = 'conseqs99.csv'
outf = sprintf('clstaxtab99_%s.csv', db)

# Read in the data ####

cat('\nRead in the consensus sequences\n')

conseq = read.csv(file = file.path(indir, conseqf),
                  row.names = 1, header = TRUE)

seqs = conseq$conseq

taxtab = readRDS(ref)

if (!all(seqs %in% rownames(taxtab))){
  msg = 'Some reference sequences are missing from the tax table'
  stop(msg)
}

cat('\nCheck sequences\n')
if (length(unique(seqs))/length(seqs) != 1){
    msg = 'The consensus sequences are not all unique'
    stop(msg)
}
cat('\nGet the taxonomy from the ASV tax table\n')

clstax = taxtab[seqs,]

cat('\nFinished assigning taxonomy\n')

tst = (clstax
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
