library(DECIPHER)

load('intermed/aln.Rdata')

# Create a distance matrix 
dmat = DistanceMatrix(aln, type = 'dist', processors = 10)

save(dmat, file = 'intermed/dmat.Rdata')