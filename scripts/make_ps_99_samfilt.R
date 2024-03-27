library(phyloseq)

load('cleaned/ps_samfilt.Rdata')
load('cleaned/ps_99.Rdata')

ps_99_samfilt = prune_samples(sample_names(ps_samfilt), ps_99)
ps_99_samfilt = prune_taxa(taxa_sums(ps_99_samfilt) > 0, ps_99_samfilt)

save(ps_99_samfilt, file = 'cleaned/ps_99_samfilt.Rdata')