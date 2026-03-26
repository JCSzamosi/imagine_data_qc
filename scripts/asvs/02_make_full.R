# Load Packages ####

library(phyloseq)
library(tidyverse)
library(AfterSl1p)

# Define I/O Variables ####

outdir = 'cleaned/asvs/full'
outmat = 'full_mat.Rdata'
asvcsv = 'full_asv.csv'
taxcsv_g = 'full_tax_g.csv'
taxcsv_s = 'full_tax_s.csv'
mapcsv = 'full_map.csv'
outps = 'full_ps.Rdata'
seqf = 'full_seqs.Rdata'
datdir = 'data'
taxf_g = 'merged_taxtab_gg.rds'
taxf_s = 'merged_taxtab_silva.rds'
asvf = 'merged_seqtab.rds'
mapf = 'merged_maptab.rds'
tots = 'asv_sample_totals.Rdata'

taxfile_g = file.path(datdir, taxf_g)
taxfile_s = file.path(datdir, taxf_s)
asvfile = file.path(datdir, asvf)
mapfile = file.path(datdir, mapf)

# Import & Check Data ####

cat('\nReading in tax table\n')
taxtab_g = readRDS(taxfile_g)
taxtab_s = readRDS(taxfile_s)

## Read in the asv table
cat('\nReading in asv table\n')
asvtab = readRDS(asvfile)

## Check the rows
cat('\nChecking the rownames match\n')
if (!all(rownames(taxtab_g) == rownames(taxtab_s))){
    msg = 'The two taxtab rownames don\'t match'
    stop(msg)
}
seqs = rownames(taxtab_g)
if (!all(seqs == rownames(asvtab))){
	msg = 'The taxtab and asvtab rownames don\'t match'
	stop(msg)
}
rownames(taxtab_g) = rownames(taxtab_s) = rownames(asvtab) = NULL

## Read in the mapfile
cat('\nReading in the mapfile\n')
maptab = readRDS(mapfile)

## Check for duplicated sample/study IDs
cat('\nChecking for duplicates\n')
na_samp = (maptab
           %>% filter(is.na(Sample.ID)))
cat(sprintf('\nThere are %i rows that are missing Sample IDs. Continuing.\n',
            nrow(na_samp)))
dup_samp = (maptab
			%>% count(Sample.ID)
			%>% filter(n > 1)
			%>% pull(Sample.ID))
dup_samp = dup_samp[!is.na(dup_samp)]
na_stud = (maptab
           %>% filter(is.na(Study.ID)))
if (nrow(na_stud) >  0){
    cat(sprintf('\nThere are %i rows that are missing Study IDs. Removing them.',
                nrow(na_stud)))
    maptab = (maptab
              %>% filter(!is.na(Study.ID)))
}

dup_stud = (maptab
			%>% count(Study.ID)
			%>% filter(n > 1)
			%>% pull(Study.ID))

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
taxtab_g = as.matrix(taxtab_g)
taxtab_s = as.matrix(taxtab_s)


# Create the phyloseq & seqs objects ####

## Create the phyloseq object
cat('\nCreating the phyloseq object\n')
ps_full = phyloseq(otu_table(asvtab, taxa_are_rows = TRUE),
              sample_data(maptab))

## Name the sequence data & tax tables
rownames(asvtab) = rownames(taxtab_g) = rownames(taxtab_s) = 
  names(seqs) = taxa_names(ps_full)
taxtab_g = sub('^[a-z]__', '', taxtab_g)

## Check the phyloseq object

cat(sprintf('\nThe original ASV table had %i samples and %i ASVs\n', 
			ncol(asvtab), nrow(asvtab)))

cat(sprintf('\nThe original map table had %i rows after removing duplicates.\n',
			nrow(maptab)))

cat(sprintf(paste('\nThe phyloseq object has %i samples and %i taxa',
					'before removing host\n'), 
			nsamples(ps_full), ntaxa(ps_full)))

cat('\nUpdating the stats track table')
stats_df = data.frame(Step = 'Merge map and asv tables before removing host',
					Samples = nsamples(ps_full),
					Taxa = ntaxa(ps_full),
					File = NA)
write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)

## Remove host sequences (removing anything that is host by either DB)
cat('\nPropagating taxon IDs down the levels\n')
tax_propped_g = prop_tax_down(tax_table(taxtab_g), indic = FALSE)
tax_propped_s = prop_tax_down(tax_table(taxtab_s), indic = FALSE)
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
cat('\nRemoving host ASVs\n')
ps_full = prune_taxa(not_host, ps_full)
seqs = seqs[taxa_names(ps_full)]
tax_full_g = tax_propped_g[taxa_names(ps_full),]
tax_full_s = tax_propped_s[taxa_names(ps_full),]
asv_full = asvtab[taxa_names(ps_full),]

cat(sprintf('\nThe phyloseq object has %i taxa after removing host.\n',
			ntaxa(ps_full)))

## Write the phyloseq object

cat('\nWriting phyloseq object files\n')
if (!dir.exists(outdir)){
	dir.create(outdir, recursive = TRUE)
}

wrps = file.path(outdir, outps)
wrseq = file.path(outdir, seqf)
save(list = c('ps_full', 'seqs'), file = wrps)
save(seqs, file = wrseq)

# Create the individual matrices/data frames ###

rownames(asv_full) = seqs[rownames(asv_full)]
map_full = data.frame(sample_data(ps_full))

## Write the individual tables

cat('\nWriting the individual tables\n')
wrmat = file.path(outdir, outmat)
save(list = c('asv_full', 'tax_full_g', 'tax_full_s', 'map_full'), 
     file = wrmat)

wrasv = file.path(outdir, asvcsv)
wrtax_g = file.path(outdir, taxcsv_g)
wrtax_s = file.path(outdir, taxcsv_s)
wrmap = file.path(outdir, mapcsv)
write.csv(asv_full, file = wrasv, row.names = TRUE)
write.csv(tax_full_g, file = wrtax_g, row.names = TRUE)
write.csv(tax_full_s, file = wrtax_s, row.names = TRUE)
write.csv(map_full, file = wrmap, row.names = TRUE)

## Write some totals in case I want/need them later

cat('\nWriting count totals\n')
taxsums = taxa_sums(ps_full)
names(taxsums) = seqs[names(taxsums)]

samsums = sample_sums(ps_full)

wrtots = file.path(outdir, tots)
save(taxsums, samsums, file = wrtots)

cat('\nWriting track stats\n')

stats_df = data.frame(Step = 'asvs/02_make_full.R',
						Samples = c(nsamples(ps_full),NA,
									ncol(asv_full),
									NA,
									NA,
									nrow(map_full)),
						Taxa = c(ntaxa(ps_full),length(seqs),
								nrow(asv_full),
								nrow(tax_full_g),
								nrow(tax_full_s),
								NA),
						File = c(wrps,wrseq,
								wrasv,
								wrtax_g,
								wrtax_s,
								wrmap))
write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)
cat('\nDONE\n')
