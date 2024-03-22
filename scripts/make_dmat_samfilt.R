library(DECIPHER)

load('intermed/aln_samfilt.Rdata')

# Create a distance matrix 
dmat = DistanceMatrix(aln, type = 'dist', processors = 10)

save(dmat, file = 'intermed/dmat_samfilt.Rdata')