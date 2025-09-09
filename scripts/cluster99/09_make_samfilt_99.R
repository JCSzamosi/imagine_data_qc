# Load packages

library(phyloseq)

# Set Up I/O Variables

cld = 'cleaned'
clst = 'cluster99'
full = 'full'
samf = 'samfilt'
indir = file.path(cld, clst, full)
outdir = file.path(cld, clst, samf)

inf = 'full99_ps.Rdata'
outf = 'samfilt99_ps.Rdata'
outseq = 'otu99_seqs_samfilt.Rdata'

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

cat('\nWriting files.\n')

if (!dir.exists(outdir)){
	dir.create(outdir)
}
save(list = c('ps99_samfilt', 'otu_seqs_samfilt'), 
	file = file.path(outdir, outf))
save(otu_seqs_samfilt, file = file.path(outdir, outseq))
