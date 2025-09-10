# Load Required Packages

library(dada2)
library(tidyverse)
library(DECIPHER)
library(doParallel)
source('./scripts/functions.R')

# Set up I/O Variables
indir = 'intermed'
clsf = 'clsts99.Rdata'
inf = file.path(indir, clsf)
conseq_f = 'conseqs99.csv'

### Import Data ####
cat('\nLoading cluster set.\n')
load(inf)

### Set up for parallelization
cat('\nSetting up for parallel processing.\n')
ncores = 10
registerDoParallel(cores = ncores)

### Actually get the consensus sequences
cat('\nGet the consensus sequences for the clusters...\n')
conseq = foreach(clust = unique(clsts$cluster), .combine = rbind) %dopar% {
    get_conseq_par(clsts, clust)   
}

### Write the consensus sequences to a file
conseq_path = file.path(indir, conseq_f)
cat(sprintf('\nWriting the consensus sequence file to %s.\n',
            conseq_path))
write.csv(conseq, file = conseq_path, row.names = TRUE)

cat('\nWriting stats tracking\n')

stats_df = data.frame(Step = 'cluster99/05_get_conseq99.R',
						Samples = NA,
						Taxa = nrow(conseq),
						File = conseq_path)

write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)

cat('\nDONE\n')
