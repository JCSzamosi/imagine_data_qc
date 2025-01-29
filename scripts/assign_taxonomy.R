library(dada2)
library(stringr)
library(R.utils)

indir = 'data'
inf = file.path(indir, 'active_seqtab_nochim.csv')
asvtab = read.csv(inf)

seqs = asvtab$X
head(seqs)
if (!length(unique(seqs))/length(seqs) == 1){
    msg = 'The ASVs are not all unique'
    stop(msg)
}

taxtab = assignTaxonomy(seqs,
                        refFasta = 'data/silva_nr99_v138_wSpecies_train_set.fa',
                        tryRC = TRUE, multithread = 20, verbose = TRUE)

# Get the filename for the output file
outf = (inf
        %>% Sys.readlink()
        %>% basename()
        %>% str_replace('seqtab_nochim_transposed', 'taxtab_nochim')
        %>% str_replace('.csv', '.rds'))
outp = file.path(indir, 'current', outf)
saveRDS(taxtab, outp)

lnf = file.path(indir, 'active_taxtab_silva138wsp.rds')
createLink(link = lnf, target = outp, overwrite = TRUE)