library(multidplyr)
library(dplyr, warn.conflicts = FALSE)
library(dada2)

load('intermed/clst.Rdata')

# Create computer core clusters for parallel processing, and sub-divide data
cores = new_cluster(20)

# A function to convert a set of sequences into a consensus sequence
## create it in each cluster
cluster_assign(cores, 
	get_conseq = function(x){
    	if (length(x) > 1){
        	aln = AlignSeqs(DNAStringSet(x))
	    } else {
    	    aln = DNAStringSet(x)
	    }
    	con = ConsensusSequence(aln)
	    return(as.character(con))
	}	
)

cluster_library(cores, 'DECIPHER')

clsts1 = (clsts
			%>% group_by(cluster)
			%>% partition(cores))

# Create the consensus sequences for each cluster
conseq = (clsts1
          %>% summarize(consensus = get_conseq(seqs))
		  %>% collect())

# Assign taxonomy to the consensus sequences
clstax = assignTaxonomy(conseq$consensus, 
                        refFasta = 'data/silva_nr99_v138_wSpecies_train_set.fa',
                        tryRC = TRUE, multithread = 20)


save(conseq, clstax, file = 'intermed/tax_99.Rdata')
