# Load Packages ####

library(dada2)
library(dplyr)

# Set I/O Variables ####

indir = 'intermed'
conseqf = 'conseqs99.csv'
outf = 'clstaxtab99.csv'

# Read in the data ####

cat('\nRead in the consensus sequences\n')

conseq = read.csv(file = file.path(indir, conseqf),
                  row.names = 1, header = TRUE)

seqs = conseq$consensus

cat('\nCheck sequences\n')
if (length(unique(seqs))/length(seqs) != 1){
    msg = 'The consensus sequences are not all unique'
    stop(msg)
}
cat('\nStart assigning taxonomy\n')
taxtab = assignTaxonomy(seqs,
                        refFasta = 'refs/silva_nr99_v138_train_set.fa',
                        tryRC = TRUE, multithread = 40, verbose = TRUE)

cat('\nFinished assigning taxonomy\n')

taxtab = (taxtab
          %>% data.frame()
          %>% mutate(seqs = rownames(.))
          %>% full_join(conseq, by = c('seqs' = 'consensus')))

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
