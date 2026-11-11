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
if (!db %in% c('gg', 'silva')){
    stop('Database must be one of "silva" or "gg".')
}

taxf = sprintf('merged_taxtab_%s.rds', db)
taxb = sprintf('merged_taxboot_%s.rds', db)

ref = file.path(datd, taxf)
refb = file.path(datd, taxb)
indir = 'intermed'
conseqf = 'conseqs99.csv'
outf = sprintf('clstaxtab99_%s.csv', db)
outbf = sprintf('clstaxboot99_%s.csv', db)

# Read in the data ####

cat('\nRead in the consensus sequences\n')

conseq = read.csv(file = file.path(indir, conseqf),
                  row.names = 1, header = TRUE)

seqs = conseq$conseq

taxtab = readRDS(ref)
taxboot = readRDS(refb)

if (!all(seqs %in% rownames(taxtab))){
  msg = 'Some reference sequences are missing from the tax table'
  stop(msg)
}

if (!all(seqs %in% rownames(taxboot))){
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
clsboot = taxboot[seqs,]

cat('\nFinished assigning taxonomy\n')

clstax = (clstax
          %>% data.frame()
       %>% mutate(seqs = rownames(.))
          %>% full_join(conseq, by = c('seqs' = 'conseq'))
          %>% select(-max, -min, -size))
clsboot = (clsboot
           %>% data.frame()
           %>% mutate(seqs = rownames(.))
           %>% full_join(conseq, by = c('seqs' = 'conseq'))
           %>% select(-max, -min, -seqs, -size))

cat('\nWrite tax table')

outp = file.path(indir, outf)
outbp = file.path(indir, outbf)
write.csv(clstax, outp)
write.csv(clsboot, outbp)

cat('\nWriting track stats\n')

stats_df = data.frame(Step = 'cluster99/07_assign_tax_clsts99.R',
						Samples = NA,
						Taxa = c(nrow(taxtab)),
						File = c(outp))
write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)

cat('\nDone\n')
