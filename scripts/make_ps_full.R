library(phyloseq)
library(tidyverse)

taxfile = 'data/taxa_IMG1-4164-Aug2023_v34_silva138wsp.csv'
taxtab = read.csv(taxfile, row.names = 1)

# Read in the asv table
asvfile = 'data/seqtab_nochim_transposed_IMG1-4164-Aug2023_v34.csv'
asvtab = read.csv(asvfile, row.names = 1)

# Check the rows
seqs = rownames(taxtab)
if (!all(seqs == rownames(asvtab))){
	msg = 'The taxtab and asvtab rownames don\'t match'
	stop(msg)
}
rownames(taxtab) = rownames(asvtab) = NULL

# Make matrices
asvtab = as.matrix(asvtab)
taxtab = as.matrix(taxtab)

# Read in the mapfile
mapfile = 'cleaned/mapfile_sequenced.csv'
maptab = read.csv(mapfile)

# Clean/organize the maptab
maptab = (maptab
          %>% column_to_rownames('Study.ID..')
          %>% mutate_at(vars(Site, DiseaseType, Timepoint, Study,
                             Sample.Type, Illumina.Plate.Number,
                             GPrep.Plate...), factor))

# Create the phyloseq object with all samples and all taxa
ps = phyloseq(otu_table(asvtab, taxa_are_rows = TRUE),
              tax_table(taxtab),
              sample_data(maptab))

# Name the sequence data
names(seqs) = taxa_names(ps)

save(ps, seqs, file = 'cleaned/ps_full.Rdata')
