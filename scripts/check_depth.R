library(tidyverse)
asvtab = readRDS('data/merged_seqtab.rds')
maptab = readRDS('data/merged_maptab.rds')
depth = colSums(asvtab)

maptab = (maptab
          %>% mutate(depth = depth[as.character(Study.ID)]))

head(maptab)

low = (maptab
       %>% filter(depth < 10000, 
                  !grepl('neg', as.character(Study.ID))))
dim(low)
head(low)

low %>% count(Illumina.Plate.Number)

low %>% filter(Illumina.Plate.Number == 'LR425')
depth['IMG1066']
