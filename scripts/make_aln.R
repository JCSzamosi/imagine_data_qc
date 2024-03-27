library(DECIPHER)

load('cleaned/seqs_full.Rdata')

# Start by making a multisequence alignment of the ASVs
aln = AlignSeqs(DNAStringSet(seqs), processors = 20)

save(aln, file = 'intermed/aln.Rdata')
