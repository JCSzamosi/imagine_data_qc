# Load Packages ####

library(tidyverse)
source('./scripts/functions.R')

# Define I/O Variables ####
outdir = 'intermed'
clstcsv = 'clstab99.csv'

# Load the input data ####

cat('\nRead in the data\n')
load('intermed/clst99.Rdata')
load('cleaned/full_mat.Rdata')
conseq = read.csv('intermed/conseqs99.csv', row.names = 1)

# Check the data ####

## Check that the sequences match in the two files
cat('\nCheck the inputs are good\n')
(chck_cl_in_ps = all(clsts$seqs %in% rownames(asv_full)))
(chck_ps_in_cl = all(rownames(asv_full) %in% clsts$seqs))

## If they don't, something has gone wrong. Stop here.
if (!chck_cl_in_ps){
    msg = paste('Some sequences in the cluster table are missing from the',
                'ASV table. Are you sure you\'re using the right files?')
    stop(msg)
} else if (!chck_ps_in_cl){
    msg = paste('Some sequences in the ASV table are missing from the',
                'cluster table. Are you sure you\'re using the right files?')
    stop(msg)
}

# Join the tables together ####

cat('\nJoin the inputs into one table\n')

full_df = (asv_full
           %>% data.frame()
           %>% rownames_to_column('seqs')
           %>% left_join(clsts, by = 'seqs')
           %>% select(cluster, everything())
           %>% select(-seqs))

cat('\nStart summing the taxa together within cluster\n')

clsdf = (full_df
         %>% group_by(cluster)
         %>% summarize_all(sum))

# Tidy up the output ####
# Add the cluster consensus sequences as the rownames of the new table

cat('\nFinish summing taxa. Cleaning up data table.\n')

clsdf = left_join(clsdf, conseq, by = 'cluster')
clstab = (clsdf
          %>% column_to_rownames('consensus')
          %>% select(-cluster)
          %>% as.matrix())

cat('\nWriting output file.\n')

# Write the files
write.csv(clstab, file = file.path(outdir,clstcsv),
          row.names = TRUE)

cat('\nDONE\n')
