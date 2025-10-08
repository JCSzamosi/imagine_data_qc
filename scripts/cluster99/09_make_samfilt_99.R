# Load packages

library(phyloseq)

# Set Up I/O Variables

cld = 'cleaned'
clst = 'cluster99'
full = 'full'
samf = 'samfilt'
indir = file.path(cld, clst, full)

inf = 'full99_ps.Rdata'

## output

outdir = file.path(cld, clst, samf)
outmat = 'samfilt99_mat.Rdata'
otucsv = 'samfilt99_otu.csv'
taxcsv = 'samfilt99_tax.csv'
mapcsv = 'samfilt99_map.csv'
outps = 'samfilt99_ps.Rdata'
outseq = 'samfilt99_seqs.Rdata'

load(file.path(indir, inf))

cat('\nThe distribution of read depths is:\n')
print(summary(sample_sums(ps99_full)))

cat('\nThe properties of the phyloseq object are:\n')
print(ps99_full)

cat('\nRemoving negative controls\n')
ps99_samfilt = subset_samples(ps99_full, 
						startsWith(as.character(Study.ID), 'IMG'))
ns = nsamples(ps99_samfilt)
cat(paste('\nRemoved negative controls. ', as.character(ns),
			' samples remaining.\n', sep = ''))

cat('\nRemoving samples with < 10,000 reads.\n')
ps99_samfilt = prune_samples(sample_sums(ps99_samfilt) >= 10000, ps99_samfilt)
ns1 = nsamples(ps99_samfilt)
cat(paste('\nRemoved low-read samples. ', as.character(ns1),
			' out of ', as.character(ns), ' samples remaining, or ',
			as.character(round(ns1/ns, 4) * 100), '%.\n',
			sep = ''))

cat('\nRemoving taxa with 0 counts.\n')
nt = ntaxa(ps99_samfilt)
ps99_samfilt = prune_taxa(taxa_sums(ps99_samfilt) > 0, ps99_samfilt)
nt_1 = ntaxa(ps99_samfilt)
cat(paste('\nRemoved 0-count taxa. ', as.character(nt_1), ' out of ',
			as.character(nt), ' taxa remaining, or ',
			as.character(round(nt_1/nt, 4) * 100), '%.\n',
			sep = ''))
otu_seqs_samfilt = otu_seqs[taxa_names(ps99_samfilt)]

cat('\nWriting phyloseq object files\n')
if (!dir.exists(outdir)){
	dir.create(outdir, recursive = TRUE)
}

wrps = file.path(outdir, outps)
save(list = c('ps99_samfilt', 'otu_seqs_samfilt'), file = wrps)
wrseq = file.path(outdir, outseq)
save(otu_seqs_samfilt, file = wrseq)

# Create the individual matrices/data frames ###

otu99_samfilt = as.matrix(otu_table(ps99_samfilt))
rownames(otu99_samfilt) = otu_seqs[rownames(otu99_samfilt)]
tax99_samfilt = as.matrix(tax_table(ps99_samfilt))
rownames(tax99_samfilt) = otu_seqs[rownames(tax99_samfilt)]
map99_samfilt = data.frame(sample_data(ps99_samfilt))

## Write the individual tables

cat('\nWriting the individual tables\n')
wrmat = file.path(outdir, outmat)
save(list = c('otu99_samfilt', 'tax99_samfilt', 'map99_samfilt'), 
     file = wrmat)

wrotu = file.path(outdir, otucsv)
wrtax = file.path(outdir, taxcsv)
wrmap = file.path(outdir, mapcsv)
write.csv(otu99_samfilt, file = wrotu, row.names = TRUE)
write.csv(tax99_samfilt, file = wrtax, row.names = TRUE)
write.csv(map99_samfilt, file = wrmap, row.names = TRUE)

cat('\nWriting track stats\n')

stats_df = data.frame(Step = 'cluster99/09_make_samfilt99.R',
						Samples = c(nsamples(ps99_samfilt),NA,
									ncol(otu99_samfilt),
									NA,
									nrow(map99_samfilt)),
						Taxa = c(ntaxa(ps99_samfilt),length(otu_seqs),
								nrow(otu99_samfilt),
								nrow(tax99_samfilt),
								NA),
						File = c(wrps,wrseq,
								wrotu,
								wrtax,
								wrmap))
write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)

cat('\nDONE\n')
