library(dada2)
asvtab = readRDS('data/current/seqtab_nochim_transposed_IMG1-5525-April2024_v34.rds')

seqs = asvtab$X
head(seqs)
if (!length(unique(seqs))/length(seqs) == 1){
    msg = 'The ASVs are not all unique'
    stop(msg)
}

taxtab = assignTaxonomy(seqs,
                        refFasta = 'data/silva_nr99_v138_wSpecies_train_set.fa',
                        tryRC = TRUE, multithread = 20, verbose = TRUE)
saveRDS(taxtab, 'data/current/taxtab_nochim_IMG1-5525-April2024_v34.rds')