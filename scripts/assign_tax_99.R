library(tidyverse)
library(DECIPHER)
library(dada2)
library(phyloseq)

load('intermed/clst.Rdata')

# A function to convert a set of sequences into a consensus sequence
get_conseq = function(x){
    if (length(x) > 1){
        aln = AlignSeqs(DNAStringSet(x))
    } else {
        aln = DNAStringSet(x)
    }
    con = ConsensusSequence(aln)
    return(as.character(con))
}

# Create the consensus sequences for each cluster
conseq = (clsts
          %>% group_by(cluster)
          %>% summarize(consensus = get_conseq(seqs)))

# Assign taxonomy to the consensus sequences
clstax = assignTaxonomy(conseq$consensus, 
                        refFasta = '~/Disk2/CommonData/SILVA/silva_nr99_v138_wSpecies_train_set.fa',
                        tryRC = TRUE, multithread = 8)


save(conseq, clstax, file = 'intermed/tax_99.Rdata')