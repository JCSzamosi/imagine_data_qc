library(phyloseq)

load('cleaned/ps_full.Rdata')

cat('\nThe distribution of read depths is:\n')
print(summary(sample_sums(ps))

cat('\nThe properties of the phyloseq object are:\n')
print(ps)

cat('\nRemoving negative controls\n')
ps_samfilt = subset_samples(
ps_samfilt = prune_samples(sample_sums(ps) >= 10000, ps)
ps_samfilt = prune_taxa(taxa_sums(ps_samfilt) > 0, ps_samfilt)
seqs_samfilt = seqs[taxa_names(ps_samfilt)]

save(ps_samfilt, file = 'cleaned/ps_samfilt.Rdata')
save(seqs_samfilt, file = 'cleaned/seqs_samfilt.Rdata')
