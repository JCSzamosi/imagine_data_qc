library(phyloseq)
library(tidyverse)
library(AfterSl1p)

cat('\nRead in the data\n')

indir = 'intermed'
datdir = 'data'
cldir = 'cleaned'
full = 'full'
cl99 = 'cluster99'
clstabf = 'clstab99.csv'
taxtabf = 'clstaxtab99.csv'
mapfile = 'full_map.csv'
outdir = file.path(cldir, cl99, full)
outmat = 'full99_mat.Rdata'
asvcsv = 'full99_asv.csv'
taxcsv = 'full99_tax.csv'
mapcsv = 'full99_map.csv'
outdf = 'full99_df.Rdata'
outps = 'full99_ps.Rdata'

taxfile = 'data/merged_taxtab.rds'
asvfile = 'data/merged_seqtab.rds'
mapfile = 'data/merged_maptab.rds'

clstab = read.csv(file.path(indir, clstabf), row.names = 1)
taxtab = read.csv(file.path(indir, taxtabf), row.names = 1)
maptab = read.csv(file.path(cldir, full, mapfile), row.names = 1)

cat('\nCheck the sequences\n')
taxtab = (taxtab
			%>% column_to_rownames('seqs')
			%>% select(-cluster))
if (nrow(taxtab) != nrow(clstab)){
	msg = 'Counts table and tax table have different numbers of taxa'
	stop(msg)
} else if (!all(rownames(taxtab) %in% rownames(clstab))){
	msg = 'The tax and counts tables do not have the same sequences'
	stop(msg)
}

if (nrow(maptab) != ncol(clstab)){
	msg = 'Counts table and map file have different numbers of samples'
	stop(msg)
} else if (!all(rownames(maptab) %in% colnames(clstab))){
	msg = 'The count and map tables do not have the same sample IDs'
	stop(msg)
}

cat('\nReorder the tax table to match the otu table\n')
taxtab = taxtab[rownames(clstab),]
otu_seqs = rownames(taxtab)
rownames(taxtab) = rownames(clstab) = NULL

ps99_full = phyloseq(otu_table(as.matrix(clstab), taxa_are_rows = TRUE),
				tax_table(as.matrix(taxtab)),
				sample_data(maptab))
names(otu_seqs) = taxa_names(ps99_full)

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
