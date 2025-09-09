
cat('\nThe distribution of read depths is:\n')
print(summary(sample_sums(ps99)))

cat('\nThe properties of the phyloseq object are:\n')
print(ps99)

cat('\nRemoving negative controls\n')
ps99_samfilt = subset_samples(ps99, startsWith(as.character(Study.ID), 'IMG'))
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
seqs_samfilt = seqs[taxa_names(ps99_samfilt)]

cat('\nWriting files.\n')

save(ps99_samfilt, file = 'cleaned/ps99_samfilt.Rdata')
save(seqs_samfilt, file = 'cleaned/seqs_samfilt.Rdata')
