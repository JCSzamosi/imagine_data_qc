library(dada2)

datdir = 'data'
inf = file.path(datdir, 'merged_seqtab.rds')

cat('\nRead in the asv table')
asvtab = readRDS(inf)
seqs = rownames(asvtab)

cat('\nCheck sequences')
if (!length(unique(seqs))/length(seqs) == 1){
    msg = 'The ASVs are not all unique'
    stop(msg)
}
cat('\nStart assigning taxonomy')
taxtab = assignTaxonomy(seqs,
                        refFasta = 'refs/silva_nr99_v138_train_set.fa',
                        tryRC = TRUE, multithread = 40, verbose = TRUE)

outp = file.path(datdir, 'merged_taxtab.rds')
cat('\nWrite tax table')
write_rds(taxtab, file = outp)
cat('\nDone\n')
