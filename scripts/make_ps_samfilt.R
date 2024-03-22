library(phyloseq)

load('cleaned/ps_full.Rdata')
load('cleaned/seqs_full.Rdata')

ps_samfilt = prune_samples(sample_sums(ps) >= 10000, ps)
ps_samfilt = prune_taxa(taxa_sums(ps_samfilt) > 0, ps_samfilt)
seqs_samfilt = seqs[taxa_names(ps_samfilt)]

save(ps_samfilt, file = 'cleaned/ps_samfilt.Rdata')
save(seqs_samfilt, file = 'cleaned/seqs_samfilt.Rdata')
