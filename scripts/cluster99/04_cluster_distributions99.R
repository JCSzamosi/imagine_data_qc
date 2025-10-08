# Load Packages

library(tidyverse)

# Set up I/O Variables

indir = 'intermed'
clsf = 'clsts99.Rdata'
inf = file.path(indir, clsf)
outdir = 'stats'
sizetab_f = 'cluster_size_distribution99.csv'
sizeplt_f = 'cluster_size_distribution99.png'

### Import Data

load(inf)

### Look at the clusters

nasv = nrow(clsts)

cat(sprintf('\nThere were %s ASVs before clustering.\n', 
            format(nasv, big.mark = ',')))

# Count the clusters
nclst = n_distinct(clsts$cluster)

cat(sprintf('\nThere are %s clusters at 99%% clustering.\n', 
            format(nclst, big.mark = ',')))

# Count the number of clusters of each size
size_tab = (clsts
            %>% count(cluster, name = 'size')
            %>% count(size, name = 'count'))

cat(sprintf('\nThe largest cluster has %s ASVs',
            format(max(size_tab$size), big.mark = ',')))

cat(sprintf(paste('\nThe smallest cluster size is %i, and there are %s',
					'clusters of that size.\n'),
            min(size_tab$size),
            format(size_tab$count[which.min(size_tab$size)],
                     big.mark = ',')))

st_path = file.path(outdir, sizetab_f)
cat(sprintf('\nPrinting cluster size info to %s.\n', st_path))
write.csv(size_tab, st_path, row.names = TRUE)

size_plt = ggplot(size_tab, aes(size, count)) +
    geom_bar(stat = 'identity',
             colour = 'dodgerblue3') +
    scale_y_sqrt() +
    scale_x_sqrt() +
    theme_bw()
size_plt

sp_path = file.path(outdir, sizeplt_f)
cat(sprintf('\nPrinting cluster size graph to %s.\n', sp_path))

ggsave(plot = size_plt, file = sp_path, height = 4, width = 4.5)

cat('\nDONE\n')
