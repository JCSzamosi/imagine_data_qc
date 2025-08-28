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

sum_asv_clusters = function(mat, clust){
    if (length(which(mat[,1] == clust)) == 1){
        mat = mat[which(mat[,1] == clust),]
        return(mat)
    }
    mat = mat[which(mat[,1] == clust),]
    sum_row = colSums(mat[,-1])
    sum_row = c(clust, sum_row)
    names(sum_row)[1] = 'cluster'
    return(sum_row)
}
