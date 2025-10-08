# Load packages

library(phyloseq)

# Set Up I/O Variables

cld = 'cleaned'
asvs = 'asvs'
full = 'full'
samf = 'samfilt'
indir = file.path(cld, asvs, full)
outdir = file.path(cld, asvs, samf)

inf = 'full_ps.Rdata'
outmat = 'samfilt_mat.Rdata'
outf = 'samfilt_ps.Rdata'
outseq = 'samfilt_seqs.Rdata'
asvcsv = 'samfilt_asv.csv'
taxcsv = 'samfilt_tax.csv'
mapcsv = 'samfilt_map.csv'

load(file.path(indir, inf))

cat('\nThe distribution of read depths is:\n')
print(summary(sample_sums(ps_full)))

cat('\nThe properties of the phyloseq object are:\n')
print(ps_full)

cat('\nRemoving negative controls\n')
ps_samfilt = subset_samples(ps_full, startsWith(as.character(Study.ID), 'IMG'))
ns = nsamples(ps_samfilt)
cat(paste('\nRemoved negative controls. ', as.character(ns),
			' samples remaining.\n', sep = ''))

cat('\nRemoving samples with < 10,000 reads.\n')
ps_samfilt = prune_samples(sample_sums(ps_samfilt) >= 10000, ps_samfilt)
ns1 = nsamples(ps_samfilt)
cat(paste('\nRemoved low-read samples. ', as.character(ns1),
			' out of ', as.character(ns), ' samples remaining, or ',
			as.character(round(ns1/ns, 4) * 100), '%.\n',
			sep = ''))

cat('\nRemoving taxa with 0 counts.\n')
nt = ntaxa(ps_samfilt)
ps_samfilt = prune_taxa(taxa_sums(ps_samfilt) > 0, ps_samfilt)
nt_1 = ntaxa(ps_samfilt)
cat(paste('\nRemoved 0-count taxa. ', as.character(nt_1), ' out of ',
			as.character(nt), ' taxa remaining, or ',
			as.character(round(nt_1/nt, 4) * 100), '%.\n',
			sep = ''))
seqs_samfilt = seqs[taxa_names(ps_samfilt)]

## Write the phyloseq object

cat('\nWriting phyloseq object files\n')
if (!dir.exists(outdir)){
	dir.create(outdir, recursive = TRUE)
}

wrps = file.path(outdir, outf)
wrseq = file.path(outdir, outseq)
save(list = c('ps_samfilt', 'seqs_samfilt'), file = wrps)
save(seqs_samfilt, file = wrseq)

# Create the individual matrices/data frames ###

asv_samfilt = as.matrix(otu_table(ps_samfilt))
rownames(asv_samfilt) = seqs_samfilt[rownames(asv_samfilt)]
tax_samfilt = as.matrix(tax_table(ps_samfilt))
rownames(tax_samfilt) = seqs_samfilt[rownames(tax_samfilt)]
map_samfilt = data.frame(sample_data(ps_samfilt))

## Write the individual tables

cat('\nWriting the individual tables\n')
wrmat = file.path(outdir, outmat)
save(list = c('asv_samfilt', 'tax_samfilt', 'map_samfilt'), 
     file = wrmat)

wrasv = file.path(outdir, asvcsv)
wrtax = file.path(outdir, taxcsv)
wrmap = file.path(outdir, mapcsv)
write.csv(asv_samfilt, file = wrasv, row.names = TRUE)
write.csv(tax_samfilt, file = wrtax, row.names = TRUE)
write.csv(map_samfilt, file = wrmap, row.names = TRUE)

cat('\nWriting track stats\n')
stats_df = data.frame(Step = 'asvs/03_make_samfilt.R',
						Samples = c(nsamples(ps_samfilt),NA,
									ncol(asv_samfilt),
									NA,
									nrow(map_samfilt)),
						Taxa = c(ntaxa(ps_samfilt),length(seqs_samfilt),
								nrow(asv_samfilt),
								nrow(tax_samfilt),
								NA),
						File = c(wrps,wrseq,
								wrasv,
								wrtax,
								wrmap))
write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)

cat('\nDONE\n')
