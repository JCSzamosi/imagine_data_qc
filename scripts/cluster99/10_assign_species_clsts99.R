# load packages

library(dada2)

# Define I/O Variables

opts = list(
    make_option(c('-d', '--db'), type = 'character', default = 'silva',
                help = 'Either \'silva\' or \'gg\'. Defines the database.')
)

opt_parser <- OptionParser(option_list = opts)
# Parse the arguments
opt <- parse_args(opt_parser)
db = opt$db

refd = 'refs'
if (db == 'silva'){
    refdb = 'silva_v138.2_assignSpecies.fa'
} else if (db == 'gg'){
    refdb = 'gg2_2024_09_toSpecies_trainset.fa'
} else {
    stop('Database must be one of "silva" or "gg".')
}
ref = file.path(refd, refdb)
indir = 'cleaned/cluster99/full'
conseqf = 'full99_seqs.Rdata'
outdir = indir
outfn = sprintf('full99_spc_%s.csv', substr(db, 1, 1))
outf = file.path(outdir, outfn)
inf = file.path(indir, conseqf)

# import sequences

load(inf)

otu_spc = assignSpecies(otu_seqs, 
                        refFasta = ref,
                        tryRC = TRUE,
                        n = 100,
                        verbose = TRUE)
  