 # Load packages

library(phyloseq)

# Set Up I/O Variables

cld = 'cleaned'
clst = 'cluster99'
full = 'full'
samf = 'samfilt'
indir = file.path(cld, clst, full)

inf = 'full99_ps.Rdata'
intax_g = 'full99_tax_g.csv'
intax_s = 'full99_tax_s.csv'

## output

outdir = file.path(cld, clst, samf)
outmat = 'samfilt99_mat.Rdata'
otucsv = 'samfilt99_otu.csv'
taxcsv_g = 'samfilt99_tax_g.csv'
taxcsv_s = 'samfilt99_tax_s.csv'
mapcsv = 'samfilt99_map.csv'
outps = 'samfilt99_ps.Rdata'
outseq = 'samfilt99_seqs.Rdata'

load(file.path(indir, inf))
tax99_full_g = read.csv(file.path(indir, intax_g),
                      row.names = 1)
tax99_full_s = read.csv(file.path(indir, intax_s),
                      row.names = 1)

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
cat(sprintf('\nRemoved low-read samples. %i out of %i samples remaining, or %.2f%%.\n',
            ns1, ns, (ns1/ns)*100))

cat('\nRemoving taxa with 0 counts.\n')
nt = ntaxa(ps99_samfilt)
ps99_samfilt = prune_taxa(taxa_sums(ps99_samfilt) > 0, ps99_samfilt)
nt_1 = ntaxa(ps99_samfilt)
cat(sprintf('\nRemoved 0-count taxa. %i out of %i taxa remaining, or %.2f%%.\n',
            nt_1, nt, (nt_1/nt)*100))
otu_seqs_samfilt = otu_seqs[taxa_names(ps99_samfilt)]
tax99_samfilt_g = tax99_full_g[taxa_names(ps99_samfilt),]
tax99_samfilt_s = tax99_full_s[taxa_names(ps99_samfilt),]

if (nrow(tax99_samfilt_g) != nrow(tax99_samfilt_s)){
  msg = 'the output tax tables don\'t match.'
  stop(msg)
}

if (nrow(tax99_samfilt_g) != ntaxa(ps99_samfilt)){
  msg = 'The number of taxa in the tax table doesn\'t match the ps object.'
  stop(msg)
}

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
map99_samfilt = data.frame(sample_data(ps99_samfilt))

## Write the individual tables

cat('\nWriting the individual tables\n')
wrmat = file.path(outdir, outmat)
save(list = c('otu99_samfilt', 'tax99_samfilt_g', 'tax99_samfilt_s', 'map99_samfilt'), 
     file = wrmat)

wrotu = file.path(outdir, otucsv)
wrtax_g = file.path(outdir, taxcsv_g)
wrtax_s = file.path(outdir, taxcsv_s)
wrmap = file.path(outdir, mapcsv)
write.csv(otu99_samfilt, file = wrotu, row.names = TRUE)
write.csv(tax99_samfilt_g, file = wrtax_g, row.names = TRUE)
write.csv(tax99_samfilt_s, file = wrtax_s, row.names = TRUE)
write.csv(map99_samfilt, file = wrmap, row.names = TRUE)

cat('\nWriting track stats\n')

stats_df = data.frame(Step = 'cluster99/09_make_samfilt99.R',
						Samples = c(nsamples(ps99_samfilt),NA,
									ncol(otu99_samfilt),
									NA,NA,
									nrow(map99_samfilt)),
						Taxa = c(ntaxa(ps99_samfilt),length(otu_seqs),
								nrow(otu99_samfilt),
								nrow(tax99_samfilt_g),
								nrow(tax99_samfilt_s),
								NA),
						File = c(wrps,wrseq,
								wrotu,
								wrtax_g, wrtax_s,
								wrmap))
write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)

cat('\nDONE\n')
