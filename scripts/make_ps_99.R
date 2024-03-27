# Load needed packages
library(phyloseq)
library(tidyverse)
library(multidplyr)

# Load needed data
load('cleaned/ps_full.Rdata')
load('intermed/tax_99.Rdata')
load('intermed/clst.Rdata')
load('cleaned/seqs_full.Rdata')

# Extract tables from the ps object
asvtab = data.frame(otu_table(ps))
maptab = data.frame(sample_data(ps))

# Check the inputs
if ((!all(rownames(clsts) %in% rownames(asvtab))) |
     (!all(rownames(clsts) %in% rownames(asvtab)))){
    msg = 'The taxa in the clusters do not match the taxa in ps_full'
    stop(msg)
}

if (!nrow(clsts) == nrow(asvtab)){
    msg = 'ps_full and the cluster table contain different numbers of taxa'
    stop(msg)
}
if (!nrow(clstax) == nrow(conseq)){
    msg = 'the numbers of clusters don\'t match in the tax_99 files'
    stop(msg)
}

# Reformat the tables
asvtab = (asvtab
          %>% rownames_to_column('TaxID'))
clsts = (clsts
         %>% rownames_to_column('TaxID'))

# Join the asv table to the cluster table so each taxon's cluster is known
asv_clst = (clsts
            %>% full_join(asvtab, by = 'TaxID'))

# Get the sums of the counts within each cluster. Do this in parallel.
cores = new_cluster(8)
asv_clst1 = (asv_clst
             %>% group_by(cluster)
             %>% partition(cores))
otutab = (asv_clst1
       %>% summarize(across(starts_with('IMG'), sum))
       %>% collect())

# Add 'cl' to the cluster names and make it rownames to create the phyloseq
# object
otutab = (otutab
       %>% mutate(cluster = paste('cl',cluster, sep = ''))
       %>% column_to_rownames('cluster'))
clstax = (clstax
          %>% data.frame()
          %>% rownames_to_column('consensus'))

# Reformat the cluster taxa table so it can go into a phyloseq object
clstax = (conseq
          %>% full_join(clstax, by = 'consensus')
          %>% select(-consensus)
          %>% mutate(cluster = paste('cl', cluster, sep = ''))
          %>% column_to_rownames('cluster'))

# Check outputs
if (!nrow(otutab) == nrow(asv_clst) == n_distinct(clsts$cluster)){
    msg = 'The summing within cluster didn\'t work. Wrong number of clusters'
    stop(msg)
}

# Create the 99% otu phyloseq object
ps_99 = phyloseq(otu_table(as.matrix(tst), taxa_are_rows = TRUE),
                 tax_table(as.matrix(clstax)),
                 sample_data(maptab))
save(ps_99, file = 'cleaned/ps_99.Rdata')

