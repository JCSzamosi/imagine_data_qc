# Load Packages ####

library(doParallel)
source('./scripts/functions.R')

# Define I/O Variables ####
outdir = 'intermed'
clstrds = 'clstab99.rds'

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
rownames(clsts) = clsts$seqs
full_mat = cbind(clsts[rownames(asv_full),]$cluster,asv_full)
colnames(full_mat)[1] = 'cluster'
uniqu_clsts = unique(full_mat[,1])

# Run the addition in parallel ####

cat('\nSet up the parallelization\n')
ncores = 10

cat('\nStart summing the taxa together within cluster\n')
clstab = foreach(clust = uniqu_clsts, .combine = rbind) %dopar% {
    sum_asv_clusters(full_mat, clust)
}

# Tidy up the output ####
# Add the cluster consensus sequences as the rownames of the new table 

cat('\nTidying up the output\n')
if (!all(conseq$cluster == clstab$cluster)){
    msg = 'the clusters are wrong or out of order'
    stop(msg)
}
rownames(clstab) = conseq$consensus

# Write the files
write_rds(clstab, file = file.path(outdir,clstrds))
