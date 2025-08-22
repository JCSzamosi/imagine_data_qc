library(phyloseq)
library(tidyverse)
library(AfterSl1p)

taxfile = 'data/active_taxtab_silva138wsp.rds'
taxtab = readRDS(taxfile)

# Read in the asv table
asvfile = 'cleaned/seqtab_cleaned.csv'
asvtab = read.csv(asvfile, row.names = 1)

# Check the rows
seqs = rownames(taxtab)
if (!all(seqs == rownames(asvtab))){
	msg = 'The taxtab and asvtab rownames don\'t match'
	stop(msg)
}
rownames(taxtab) = rownames(asvtab) = NULL

# Read in the mapfile
mapfile = 'cleaned/mapfile_clean.csv'
maptab = read.csv(mapfile)

# Check the samples

all(colnames(asvtab) %in% maptab$Study.ID)
all(maptab$Study.ID %in% colnames(asvtab))

# Make matrices
asvtab = as.matrix(asvtab)
taxtab = as.matrix(taxtab)

# Clean/organize the maptab
maptab = (maptab
          %>% column_to_rownames('Study.ID')
          %>% mutate_at(vars(Site, DiseaseType, Timepoint, Study.Name,
                             Sample.Type, Illumina.Plate.Number,
                             GPrep.Plate...), factor))

# Create the phyloseq object with all samples and all taxa
ps = phyloseq(otu_table(asvtab, taxa_are_rows = TRUE),
              tax_table(taxtab),
              sample_data(maptab))

# Name the sequence data
names(seqs) = taxa_names(ps)

# Remove host sequences
ps = prop_tax_down(ps, indic = FALSE)
ps = subset_taxa(ps,
                        Kingdom %in% c('Bacteria','Archaea') &
                            !startsWith(as.character(Phylum), 'k_') &
                            Family != 'Mitochondria' &
                            Order != 'Chloroplast')
seqs = seqs[taxa_names(ps)]
save(ps, file = 'cleaned/ps_full.Rdata')
save(seqs, file = 'cleaned/seqs_full.Rdata')
