library(phyloseq)
library(tidyverse)
library(AfterSl1p)

outdir = 'cleaned'
cat('\nReading in tax table\n')
taxfile = 'data/merged_taxtab.rds'
taxtab = readRDS(taxfile)

# Read in the asv table
cat('Reading in asv table\n')
asvfile = 'data/merged_seqtab.rds'
asvtab = readRDS(asvfile)

# Check the rowsa
cat('Checking the rownames match\n')
seqs = rownames(taxtab)
if (!all(seqs == rownames(asvtab))){
	msg = 'The taxtab and asvtab rownames don\'t match'
	stop(msg)
}
rownames(taxtab) = rownames(asvtab) = NULL

# Read in the mapfile
cat('Reading in the mapfile\n')
mapfile = 'data/merged_maptab.rds'
maptab = readRDS(mapfile)

# Check for duplicated sample/study IDs

cat('Checking for duplicates\n')
dup_samp = (maptab
			%>% count(Sample.ID)
			%>% filter(n > 1)
			%>% pull(Sample.ID))
dup_samp = dup_samp[!is.na(dup_samp)]
dup_stud = (maptab
			%>% count(Study.ID)
			%>% filter(n > 1)
			%>% pull(Study.ID))
dup_stud = dup_stud[!is.na(dup_stud)]

# Remove them if there are any
if (length(c(dup_samp, dup_stud)) > 0){
	cat('Duplicates found. Removing them\n')
	maptab = (maptab
			  %>% filter(!(Sample.ID %in% dup_samp) &
								!(Study.ID %in% dup_stud))
			  %>% filter(!is.na(Sample.ID) & !is.na(Study.ID)))
} else {
	cat('No duplicates found\n')
}

# Check the samples

cat('Checking for missing samples.\n')
asv_in_map = all(colnames(asvtab) %in% maptab$Study.ID)
if (! asv_in_map){
	cat(paste('Some samples in the ASV table are absent from the mapfile.',
				'Continuing\n'))
}

map_in_asv = all(maptab$Study.ID %in% colnames(asvtab))
if (! map_in_asv){
	cat(paste('Some samples in the mapfile are absent from the ASV table.',
				'Continuing\n'))
}

# Make matrices
asvtab = as.matrix(asvtab)
taxtab = as.matrix(taxtab)

# Clean/organize the maptab
cat('Cleaning up the mapfile\n')
maptab = (maptab
          %>% column_to_rownames('Study.ID')
          %>% mutate(across(c(Site.Number, Participant.ID, Sample.ID), factor),
		  			Disease.Type = factor(Disease.Type, 
											levels = c('Healthy', 'IBS', 'IBD')),
					Timepoint = factor(Timepoint, 
										levels = c('Baseline', 'Y1', 'Y2',
													'Y3', 'Y4')),
					IBD.Classification = factor(IBD.Classification,
												levels = c('UC', 'CD',
												'IBD unclassified', 'IBS',
												'Healthy'))))

# Create the phyloseq object with all samples and all taxa
cat('Creating the phyloseq object\n')
ps = phyloseq(otu_table(asvtab, taxa_are_rows = TRUE),
              tax_table(taxtab),
              sample_data(maptab))

# Name the sequence data
names(seqs) = taxa_names(ps)

# Remove host sequences
cat('Propagating taxon IDs down the levels\n')
ps = prop_tax_down(ps, indic = FALSE)
cat('Removing host ASVs\n')
ps = subset_taxa(ps,
                        Kingdom %in% c('Bacteria','Archaea') &
                            !startsWith(as.character(Phylum), 'k_') &
                            Family != 'Mitochondria' &
                            Order != 'Chloroplast')
seqs = seqs[taxa_names(ps)]
cat('Writing files\n')
if (!dir.exists(outdir)){
	dir.create(outdir)
}
save(list = c('ps', 'seqs'), file = file.path(outdir, 'ps_full.Rdata'))
save(seqs, file = file.path(outdir, 'seqs_full.Rdata'))
cat('DONE\n')
