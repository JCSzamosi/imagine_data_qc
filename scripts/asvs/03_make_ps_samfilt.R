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
outf = 'samfilt_ps.Rdata'
outseq = 'seqs_samfilt.Rdata'

load(file.path(indir, inf)

cat('\nThe distribution of read depths is:\n')
print(summary(sample_sums(ps)))

cat('\nThe properties of the phyloseq object are:\n')
print(ps)

cat('\nRemoving negative controls\n')
ps_samfilt = subset_samples(ps, startsWith(as.character(Study.ID), 'IMG'))
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

cat('\nWriting files.\n')

save(list = c('ps_samfilt', 'seqs_samfilt'), 
	file = file.path(outdir, outf))
save(seqs_samfilt, file = file.path(outdir, outseq))
