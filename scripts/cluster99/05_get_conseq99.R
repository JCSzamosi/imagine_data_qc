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
mat = 'full_mat.Rdata'
cts = file.path('cleaned','asvs','full', mat)

### Import Data ####
cat('\nLoading cluster set.\n')
load(inf)

cat('\nLoading counts\n')
load(cts)

dim(asv_full)
dim(clsts)
full_cts = rowSums(asv_full)
head(full_cts)

full_cts = data.frame(total = full_cts,
                      seqs = names(full_cts))
head(full_cts)

clsts = (clsts
         %>% full_join(full_cts, by = 'seqs'))
head(clsts)

conseq = (clsts
          %>% group_by(cluster)
          %>% summarize(conseq = seqs[which.max(total)],
                        max = max(total),
                        min = min(total),
                        size = length(total)))
head(conseq)
summary(conseq)

conseq[which.max(conseq$max),]

### Set up for parallelization
# cat('\nSetting up for parallel processing.\n')
# ncores = 10
# registerDoParallel(cores = ncores)

### Get the most common sequence in each cluster

conseq = (clsts
          %>% count(cluster, seqs)
          %>% group_by(cluster)
          %>% summarize(conseq = seqs[which.max(n)]))
dim(conseq)
head(conseq)



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

cat('\nDONE\n')
