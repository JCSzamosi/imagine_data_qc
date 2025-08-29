## Setup ####

library(dada2)
library(tidyverse)
library(DECIPHER)
library(doParallel)
source('./scripts/functions.R')
outdir = 'intermed'
conseq_f = 'conseqs99.csv'

### Import Data ####
cat('\nLoading cluster set.\n')
load('intermed/clst99.Rdata')

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
conseq_path = file.path(outdir, conseq_f)
cat(sprintf('\nWriting the consensus sequence file to %s.\n',
            conseq_path))
write.csv(conseq, file = conseq_path, row.names = TRUE)

cat('\nDONE\n')
