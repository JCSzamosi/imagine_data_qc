# Load Packages ####

library(dada2)

# Set I/O Variables ####

indir = 'intermed'
conseqf = 'conseqs99.csv'
outdir = 'cleaned'
outf = 'clstaxtab99.rds'

# Read in the data ####

cat('\nRead in the consensus sequences\n')

conseq = read.csv(file = file.path(indir, conseqf),
                  row.names = 1)