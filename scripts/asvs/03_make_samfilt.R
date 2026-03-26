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
mat = 'full_mat.Rdata'
outmat = 'samfilt_mat.Rdata'
outf = 'samfilt_ps.Rdata'
outseq = 'samfilt_seqs.Rdata'
asvcsv = 'samfilt_asv.csv'
taxcsv_g = 'samfilt_tax_g.csv'
taxcsv_s = 'samfilt_tax_s.csv'
mapcsv = 'samfilt_map.csv'
tots = 'samfilt_asv_sample_totals.Rdata'

load(file.path(indir, inf))
load(file.path(indir, mat))

cat('\nThe distribution of read depths is:\n')
print(summary(sample_sums(ps_full)))

cat('\nThe properties of the phyloseq object are:\n')
print(ps_full)

cat('\nRemoving negative controls\n')
ps_samfilt = subset_samples(ps_full, startsWith(as.character(Study.ID), 'IMG'))
ns = nsamples(ps_samfilt)
cat(sprintf('\nRemoved negative controls. %i samples remaining.\n', ns))

cat('\nRemoving samples with < 9,000 reads.\n')
ps_samfilt = prune_samples(sample_sums(ps_samfilt) >= 9000, ps_samfilt)
ns1 = nsamples(ps_samfilt)
cat(sprintf('\nRemoved low-read samples. %i out of %i samples remaining, or %.2f%%.\n',
            ns1, ns, (ns1/ns)*100))

cat('\nRemoving taxa with 0 counts.\n')
nt = ntaxa(ps_samfilt)
ps_samfilt = prune_taxa(taxa_sums(ps_samfilt) > 0, ps_samfilt)
nt_1 = ntaxa(ps_samfilt)
cat(sprintf('\nRemoved 0-count taxa. %i out of %i taxa remaining, or %.2f%%.\n',
			nt_1, nt, (nt_1/nt)* 100))
seqs_samfilt = seqs[taxa_names(ps_samfilt)]
tax_samfilt_g = tax_full_g[taxa_names(ps_samfilt),]
tax_samfilt_s = tax_full_s[taxa_names(ps_samfilt),]

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
map_samfilt = data.frame(sample_data(ps_samfilt))

## Write the individual tables

cat('\nWriting the individual tables\n')
wrmat = file.path(outdir, outmat)
save(list = c('asv_samfilt', 'tax_samfilt', 'map_samfilt'), 
     file = wrmat)

wrasv = file.path(outdir, asvcsv)
wrtax_g = file.path(outdir, taxcsv_g)
wrtax_s = file.path(outdir, taxcsv_s)
wrmap = file.path(outdir, mapcsv)
write.csv(asv_samfilt, file = wrasv, row.names = TRUE)
write.csv(tax_samfilt_g, file = wrtax_g, row.names = TRUE)
write.csv(tax_samfilt_s, file = wrtax_s, row.names = TRUE)
write.csv(map_samfilt, file = wrmap, row.names = TRUE)

cat('\nWriting count totals\n')
taxsums = taxa_sums(ps_samfilt)
names(taxsums) = seqs[names(taxsums)]

samsums = sample_sums(ps_samfilt)

wrtots = file.path(outdir, tots)
save(taxsums, samsums, file = wrtots)

cat('\nWriting track stats\n')
stats_df = data.frame(Step = 'asvs/03_make_samfilt.R',
						Samples = c(nsamples(ps_samfilt),NA,
									ncol(asv_samfilt),
									NA,
									NA,
									nrow(map_samfilt)),
						Taxa = c(ntaxa(ps_samfilt),length(seqs_samfilt),
								nrow(asv_samfilt),
								nrow(tax_samfilt_g),
								nrow(tax_samfilt_s),
								NA),
						File = c(wrps,wrseq,
								wrasv,
								wrtax_g, wrtax_s,
								wrmap))
write.table(stats_df, file = 'stats/track_counts.csv',
			append = TRUE, quote = TRUE, sep = ',',
			row.names = FALSE, col.names = FALSE)

cat('\nDONE\n')
