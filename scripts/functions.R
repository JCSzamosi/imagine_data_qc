# Get a consensus sequence for each cluster, using ambiguity codes
get_conseq = function(x){
	# A function to convert a set of sequences into a consensus sequence
	if (length(x) > 1){
		aln = AlignSeqs(DNAStringSet(x))
	} else {
		aln = DNAStringSet(x)
	}
	con = ConsensusSequence(aln)
	return(as.character(con))
}

get_conseq_par = function(df, clust){
    df_clst = filter(df, cluster == clust)
    df_sum = data.frame(cluster = clust, 
                        consensus = get_conseq(df_clst$seqs))
    return(df_sum)
}