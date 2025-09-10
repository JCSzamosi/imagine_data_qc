# Load Packages ####

library(phyloseq)
library(tidyverse)
library(AfterSl1p)

# Define I/O Variables ####

outdir = 'cleaned/full'
outmat = 'full_mat.Rdata'
asvcsv = 'full_asv.csv'
taxcsv = 'full_tax.csv'
mapcsv = 'full_map.csv'
outps = 'full_ps.Rdata'
seqf = 'full_seqs.Rdata'
datdir = 'data'
taxf = 'merged_taxtab.rds'
asvf = 'merged_seqtab.rds'
mapf = 'merged_maptab.rds'

taxfile = file.path(datdir, taxf)
asvfile = file.path(datdir, asvf)
mapfile = file.path(datdir, mapf)

# Import & Check Data ####

cat('\nReading in tax table\n')
taxtab = readRDS(taxfile)

## Read in the asv table
cat('\nReading in asv table\n')
asvtab = readRDS(asvfile)

## Check the rows
cat('\nChecking the rownames match\n')
seqs = rownames(taxtab)
if (!all(seqs == rownames(asvtab))){
	msg = 'The taxtab and asvtab rownames don\'t match'
	stop(msg)
}
rownames(taxtab) = rownames(asvtab) = NULL

## Read in the mapfile
cat('\nReading in the mapfile\n')
maptab = readRDS(mapfile)

## Check for duplicated sample/study IDs
cat('\nChecking for duplicates\n')
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

## Remove them if there are any
if (length(c(dup_samp, dup_stud)) > 0){
	cat('\nDuplicates found. Removing them\n')
	maptab = (maptab
			  %>% filter(!(Sample.ID %in% dup_samp) &
								!(Study.ID %in% dup_stud))
			  %>% filter(!is.na(Study.ID)))
} else {
	cat('\nNo duplicates found\n')
}

## Check the samples

cat('\nChecking for missing samples.\n')
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

## Clean/organize the maptab
cat('\nCleaning up the mapfile\n')
rownames(maptab) = maptab$Study.ID

## Make matrices
asvtab = as.matrix(asvtab)
taxtab = as.matrix(taxtab)


# Create the phyloseq & seqs objects ####

## Create the phyloseq object
cat('\nCreating the phyloseq object\n')
ps_full = phyloseq(otu_table(asvtab, taxa_are_rows = TRUE),
              tax_table(taxtab),
              sample_data(maptab))

## Name the sequence data
names(seqs) = taxa_names(ps_full)

## Check the phyloseq object

cat(sprintf('\nThe original ASV table had %i samples and %i ASVs\n', 
			ncol(asvtab), nrow(asvtab)))

cat(sprintf('\nThe original map table had %i rows after removing duplicates.\n',
			nrow(maptab)))

cat(sprintf(paste('\nThe phyloseq object has %i samples and %i taxa',
					'before removing host\n'), 
			nsamples(ps_full), ntaxa(ps_full)))

## Remove host sequences
cat('\nPropagating taxon IDs down the levels\n')
ps_full = prop_tax_down(ps_full, indic = FALSE)
cat('\nRemoving host ASVs\n')
ps_full = subset_taxa(ps_full,
                        Kingdom %in% c('Bacteria','Archaea') &
                            !startsWith(as.character(Phylum), 'k_') &
                            Family != 'Mitochondria' &
                            Order != 'Chloroplast')
seqs = seqs[taxa_names(ps_full)]

cat(sprintf('\nThe phyloseq object has %i taxa after removing host.\n',
			ntaxa(ps_full)))

## Write the phyloseq object

cat('\nWriting phyloseq object files\n')
if (!dir.exists(outdir)){
	dir.create(outdir)
}

wrps = file.path(outdir, outps)
wrseq = file.path(outdir, seqf)
save(list = c('ps_full', 'seqs'), file = wrps)
save(seqs, file = wrseq)

# Create the individual matrices/data frames ###

asv_full = as.matrix(otu_table(ps_full))
rownames(asv_full) = seqs[rownames(asv_full)]
tax_full = as.matrix(tax_table(ps_full))
rownames(tax_full) = seqs[rownames(tax_full)]
map_full = data.frame(sample_data(ps_full))

## Write the individual tables

cat('\nWriting the individual tables\n')
wrmat = file.path(outdir, outmat)
save(list = c('asv_full', 'tax_full', 'map_full'), 
     file = wrmat)

wrasv = file.path(outdir, asvcsv)
wrtax = file.path(outdir, taxcsv)
wrmap = file.path(outdir, mapcsv)
write.csv(asv_full, file = wrasv, row.names = TRUE)
write.csv(tax_full, file = wrtax, row.names = TRUE)
write.csv(map_full, file = wrmap, row.names = TRUE)

cat('\nWriting track stats\n')

stats_df = data.frame(Step = 'asvs/02_make_full.R',
						Samples = c(nsamples(ps_full),NA,
									ncol(asv_full),
									NA,
									nrow(map_full)),
						Taxa = c(ntaxa(ps_full),length(seqs),
								nrow(asv_full),
								nrow(tax_full),
								NA),
						File = c(wrps,wrseq,
								wrasv,
								wrtax,
								wrmap))
write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)
cat('\nDONE\n')
