library(stringr)
library(R.utils)

# Find out what the merge file name is
indir = 'data'
inf = 'active_mergetab_nochim.rds'
mergf = Sys.readlink(file.path(indir,inf))

# Extract the stuff that needs to go into the output filename
outf = (mergf
        %>% basename()
        %>% str_replace('mergetab_nochim',
                        'seqtab_nochim_transposed')
        %>% str_replace('.rds','.csv'))
outp = file.path(indir, 'current', outf)

mergetab = readRDS('data/active_mergetab_nochim.rds')
seqtab = t(mergetab)
write.csv(seqtab, outp)

lnf = 'active_seqtab_nochim.csv'
createLink(link = file.path(indir,lnf), target = outp, overwrite = TRUE)


