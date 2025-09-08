# Load Packages ####

library(dada2)

# Set I/O Variables ####

indir = 'intermed'
conseqf = 'conseqs99.csv'
outdir = 'cleaned'
outf = 'clstaxtab99.csv'

# Read in the data ####

cat('\nRead in the consensus sequences\n')

conseq = read.csv(file = file.path(indir, conseqf),
                  row.names = 1, header = TRUE)

seqs = conseq$consensus

cat('\nCheck sequences\n')
if (length(unique(seqs))/length(seqs) != 1){
    msg = 'The consensus sequences are not all unique'
    stop(msg)
}
cat('\nStart assigning taxonomy\n')
taxtab = assignTaxonomy(seqs,
                        refFasta = 'refs/silva_nr99_v138_train_set.fa',
                        tryRC = TRUE, multithread = 40, verbose = TRUE)

outp = file.path(outd, outf)
cat('\nWrite tax table')
cat('\nDone\n')
