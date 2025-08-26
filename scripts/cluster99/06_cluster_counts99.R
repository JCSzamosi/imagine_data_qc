# Setup ###

library(tidyverse)
library(phyloseq)
library(doParallel)
load('intermed/clst.Rdata')
load('cleaned/ps_full.Rdata')

# Get the asv table and give it its rownames back

asvtab = as.matrix(otu_table(ps))
rownames(asvtab) = seqs

rm(ps, seqs)

# Check that the sequences match in the two files

(chck_cl_in_ps = all(clsts$seqs %in% rownames(asvtab)))
(chck_ps_in_cl = all(rownames(asvtab) %in% clsts$seqs))

# If they don't, something has gone wrong. Stop here.
if (!chck_cl_in_ps){
    msg = paste('Some sequences in the cluster table are missing from the',
                'ASV table. Are you sure you\'re using the right files?')
    stop(msg)
} else if (!chck_ps_in_cl){
    msg = paste('Some sequences in the ASV table are missing from the',
                'cluster table. Are you sure you\'re using the right files?')
    stop(msg)
}

# Join with the cluster table
rownames(clsts) = clsts$seqs
full_mat = cbind(clsts[rownames(asvtab),]$cluster,asvtab)
colnames(full_mat)[1] = 'cluster'

rm(asvtab)
# Sum the counts at each sample within each cluster. Host sequences have already
# been removed at this point, so we don't need to do anything about them.

ncores = 2
registerDoParallel(cores = ncores)

sum_asv_clusters = function(mat, clust){
    mat = mat[which(mat[,1] == clust),]
    sum_row = colSums(mat[,-1])
    sum_row = c(clust, sum_row)
    names(sum_row)[1] = 'cluster'
    return(sum_row)
}

tst = sum_asv_clusters(full_mat, unique(full_mat[,'cluster'][3]))

uniqu_clsts = unique(full_mat[,1])
clst_tab = foreach(clust = uniqu_clsts[1:10], .combine = rbind) %dopar% {
    sum_asv_clusters(full_mat, clust)
}

clstdf = (asvdf
		%>% group_by(cluster)
		%>% summarise_all(sum)
		%>% ungroup()
		%>% filter(!is.na(cluster))
		%>% data.frame())
dim(clstdf)

# Add the cluster consensus sequences as the rownames of the new table 
all(conseq$cluster == clstdf$cluster)
rownames(clstdf) = conseq$consensus
head(clstdf)

# Make it a matrix just like dada2 produces
clstab = as.matrix(select(clstdf, -cluster))
clstab[1:10,1:10]
```

### Done

Now we have a cluster count table `clstab`, and an associated taxonomy table
`clstax` and should be able to put them in phyloseq and do stuff.

```{r}

```