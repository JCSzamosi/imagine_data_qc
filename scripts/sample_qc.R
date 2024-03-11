# Identify and deal with any problems with sequenced samples.

## Setup ####
library(phyloseq)
library(tidyverse)

## Import ####

# Read in the tax table
taxfile = 'data/taxa_IMG1-4164-Aug2023_v34_silva138wsp.csv'
taxtab = read.csv(taxfile, row.names = 1)
head(taxtab)

# Read in the asv table
asvfile = 'data/seqtab_nochim_transposed_IMG1-4164-Aug2023_v34.csv'
asvtab = read.csv(asvfile, row.names = 1)

# Check the rows
seqs = rownames(taxtab)
all(seqs == rownames(asvtab))
rownames(taxtab) = rownames(asvtab) = NULL

# Make matrices
asvtab = as.matrix(asvtab)
taxtab = as.matrix(taxtab)

# Read in the mapfile
mapfile = 'cleaned/mapfile_sequenced.csv'
maptab = read.csv(mapfile)
head(maptab)
summary(maptab)

# Clean/organize the maptab
maptab = (maptab
          %>% column_to_rownames('Study.ID..')
          %>% mutate_at(vars(Site, DiseaseType, Timepoint, Study,
                             Sample.Type, Illumina.Plate.Number,
                             GPrep.Plate...), factor))

## Make Phyloseq ####

ps = phyloseq(otu_table(asvtab, taxa_are_rows = TRUE),
              tax_table(taxtab),
              sample_data(maptab))
ps

# Name the sequence data
names(seqs) = taxa_names(ps)

## Save Unfiltered ####
save(ps, seqs, file = 'cleaned/ps_full.Rdata')


## Investigate samples ####