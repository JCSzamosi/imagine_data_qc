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
taxfile_g = 'clstaxtab99_gg.csv'
taxfile_s = 'clstaxtab99_silva.csv'
mapfile = 'full_map.csv'

## output

outdir = file.path(cldir, cl99, full)
outmat = 'full99_mat.Rdata'
otucsv = 'full99_otu.csv'
taxcsv_g = 'full99_tax_g.csv'
taxcsv_s = 'full99_tax_s.csv'
mapcsv = 'full99_map.csv'
outdf = 'full99_df.Rdata'
outps = 'full99_ps.Rdata'
outseq = 'full99_seqs.Rdata'

# Import & Check Data ####

cat('\nRead in the tax table\n')
taxtab_g = read.csv(file.path(intdir, taxfile_g), row.names = 1)
taxtab_s = read.csv(file.path(intdir, taxfile_s), row.names = 1)

cat('\nRead in the otu table\n')
otutab = read.csv(file.path(intdir, otufile), row.names = 1)

cat('\nCheck the sequences\n')
taxtab_g = (taxtab_g
			%>% column_to_rownames('seqs')
			%>% select(-cluster))
taxtab_s = (taxtab_s
			%>% column_to_rownames('seqs')
			%>% select(-cluster))
if (nrow(taxtab_g) != nrow(taxtab_s)){
  msg = 'The two taxonomy tables have different numbers of taxa'
  stop(msg)
}
if (nrow(taxtab_g) != nrow(otutab)){
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

if (!all(rownames(taxtab_g) == rownames(taxtab_s))){
  msg = 'The tax table rownames don\'t match each other.'
  stop(msg)
} 

if (!all(rownames(taxtab_g) == rownames(otutab))){
  msg = 'The tax and otu table rownames don\'t match.'
  stop(msg)
}
otu_seqs = rownames(taxtab_g)
rownames(taxtab_g) = rownames(taxtab_s) = rownames(otutab) = NULL

## Make matrices
otutab = as.matrix(otutab)
taxtab_g = as.matrix(taxtab_g)
taxtab_s = as.matrix(taxtab_s)
taxtab_g = sub('^[a-z]__', '', taxtab_g)

ps99_full = phyloseq(otu_table(otutab, taxa_are_rows = TRUE),
				sample_data(maptab))
## Name the sequence data
rownames(otutab) = rownames(taxtab_g) = rownames(taxtab_s) = 
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
tax_propped_g = prop_tax_down(tax_table(taxtab_g), indic = FALSE)
tax_propped_s = prop_tax_down(tax_table(taxtab_s), indic = FALSE)
cat('\nRemoving host ASVs\n')
not_host_g = with(data.frame(tax_propped_g),
                  Kingdom %in% c('Bacteria','Archaea') &
                    !startsWith(as.character(Phylum), 'k_') &
                    Family != 'Mitochondria' &
                    Order != 'Chloroplast',
                  Class != 'Chloroplast')
not_host_s = with(data.frame(tax_propped_s),
                  Kingdom %in% c('Bacteria','Archaea') &
                    !startsWith(as.character(Phylum), 'k_') &
                    Family != 'Mitochondria' &
                    Order != 'Chloroplast',
                  Class != 'Chloroplast')

not_host = not_host_g & not_host_s
ps99_full = prune_taxa(not_host, ps99_full)

otu99_seqs = otu_seqs[taxa_names(ps99_full)]
tax99_full_g = tax_propped_g[taxa_names(ps99_full),]
tax99_full_s = tax_propped_s[taxa_names(ps99_full),]
otu99_full = otutab[taxa_names(ps99_full),]

## Write the phyloseq object

cat('\nWriting phyloseq object files\n')
if (!dir.exists(outdir)){
	dir.create(outdir, recursive = TRUE)
}

wrps = file.path(outdir, outps)
save(list = c('ps99_full', 'otu_seqs'), file = wrps)
wrseq = file.path(outdir, outseq)
save(otu_seqs, file = wrseq)

# Create the individual matrices/data frames ###

map99_full = data.frame(sample_data(ps99_full))

## Write the individual tables

cat('\nWriting the individual tables\n')
wrmat = file.path(outdir, outmat)
save(list = c('otu99_full', 'tax99_full', 'map99_full'), 
     file = wrmat)

wrotu = file.path(outdir, otucsv)
wrtax_g = file.path(outdir, taxcsv_g)
wrtax_s = file.path(outdir, taxcsv_s)
wrmap = file.path(outdir, mapcsv)
write.csv(otu99_full, file = wrotu, row.names = TRUE)
write.csv(tax99_full, file = wrtax, row.names = TRUE)
write.csv(map99_full, file = wrmap, row.names = TRUE)

cat('\nWriting track stats\n')

stats_df = data.frame(Step = 'cluster99/08_make_full99.R',
						Samples = c(nsamples(ps99_full),NA,
									ncol(otu99_full),
									NA,NA,
									nrow(map99_full)),
						Taxa = c(ntaxa(ps99_full),length(otu_seqs),
								nrow(otu99_full),
								nrow(tax99_full_g),
								nrow(tax99_full_s),
								NA),
						File = c(wrps,wrseq,
								wrotu,
								wrtax_g, wrtax_s,
								wrmap))
write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)

cat('\nDONE\n')
