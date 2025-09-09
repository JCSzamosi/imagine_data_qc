# Load Packages ####

library(phyloseq)
library(tidyverse)
library(AfterSl1p)

# Define I/O Variables ####

## input

intdir = 'intermed'
datdir = 'data'
cldir = 'cleaned'
asvs = 'asvs'
cl99 = 'cluster99'
full = 'full'
otufile = 'clstab99.csv'
taxfile = 'clstaxtab99.csv'
mapfile = 'full_map.csv'

## output

outdir = file.path(cldir, cl99, full)
outmat = 'full99_mat.Rdata'
otucsv = 'full99_otu.csv'
taxcsv = 'full99_tax.csv'
mapcsv = 'full99_map.csv'
outdf = 'full99_df.Rdata'
outps = 'full99_ps.Rdata'

# Import & Check Data ####

cat('\nRead in the tax table\n')
taxtab = read.csv(file.path(intdir, taxfile), row.names = 1)

cat('\nRead in the otu table\n')
otutab = read.csv(file.path(intdir, otufile), row.names = 1)

cat('\nCheck the sequences\n')
taxtab = (taxtab
			%>% column_to_rownames('seqs')
			%>% select(-cluster))
if (nrow(taxtab) != nrow(otutab)){
	msg = 'Counts table and tax table have different numbers of taxa'
	stop(msg)
} else if (!all(rownames(taxtab) %in% rownames(otutab))){
	msg = 'The tax and counts tables do not have the same sequences'
	stop(msg)
}

## Read in the mapfile
maptab = read.csv(file.path(cldir, asvs, full, mapfile), row.names = 1)

## Check that the sample IDs match the otu table
cat('\nCheck the sample IDs\n')
if (nrow(maptab) != ncol(otutab)){
	msg = 'Counts table and map file have different numbers of samples'
	stop(msg)
} else if (!all(rownames(maptab) %in% colnames(otutab))){
	msg = 'The count and map tables do not have the same sample IDs'
	stop(msg)
}

cat('\nReorder the tax table to match the otu table\n')

taxtab = taxtab[rownames(otutab),]
otu_seqs = rownames(taxtab)
rownames(taxtab) = rownames(otutab) = NULL

## Make matrices
otutab = as.matrix(otutab)
taxtab = as.matrix(taxtab)


ps99_full = phyloseq(otu_table(otutab, taxa_are_rows = TRUE),
				tax_table(taxtab),
				sample_data(maptab))

## Name the sequence data
names(otu_seqs) = taxa_names(ps99_full)

## Check the phyloseq object

cat(sprintf('\nThe original OTU table had %i samples and %i OTUs\n', 
			ncol(otutab), nrow(otutab)))

cat(sprintf('\nThe original map table had %i rows after removing duplicates.\n',
			nrow(maptab)))

cat(sprintf(paste('\nThe phyloseq object has %i samples and %i taxa',
					'before removing host\n'), 
			nsamples(ps99_full), ntaxa(ps99_full)))


## Remove host sequences
cat('\nPropagating taxon IDs down the levels\n')
ps99_full = prop_tax_down(ps99_full, indic = FALSE)
cat('\nRemoving host ASVs\n')
ps99_full = subset_taxa(ps99_full,
                        Kingdom %in% c('Bacteria','Archaea') &
                            !startsWith(as.character(Phylum), 'k_') &
                            Family != 'Mitochondria' &
                            Order != 'Chloroplast')
otu_seqs = otu_seqs[taxa_names(ps99_full)]

## Write the phyloseq object

cat('\nWriting phyloseq object files\n')
if (!dir.exists(outdir)){
	dir.create(outdir)
}
save(list = c('ps99_full', 'otu_seqs'), file = file.path(outdir, outps))
save(otu_seqs, file = file.path(outdir, 'full99_seqs.Rdata'))

# Create the individual matrices/data frames ###

otu99_full = as.matrix(otu_table(ps99_full))
rownames(otu99_full) = otu_seqs[rownames(otu99_full)]
tax99_full = as.matrix(tax_table(ps99_full))
rownames(tax99_full) = otu_seqs[rownames(tax99_full)]
map99_full = data.frame(sample_data(ps99_full))

## Write the individual tables

cat('\nWriting the individual tables\n')
save(list = c('otu99_full', 'tax99_full', 'map99_full'), 
     file = file.path(outdir, outmat))
write.csv(otu99_full, file = file.path(outdir, otucsv), row.names = TRUE)
write.csv(tax99_full, file = file.path(outdir, taxcsv), row.names = TRUE)
write.csv(map99_full, file = file.path(outdir, mapcsv), row.names = TRUE)

cat('\nDONE\n')
