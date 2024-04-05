library(tidyverse)

infosheet = read.csv('data/active_Rossi_info_datasheet.csv')
seqtab = read.csv('data/active_seqtab_nochim.csv', nrow = 1)

mergetab = readRDS('../Analysis/data/mergetab_nochim_IMG1-4164-Aug2023_v34.rds')
dim(mergetab)

missing_merge = (infosheet
                 %>% filter(!(Study.ID %in% rownames(mergetab))))
dim(missing_merge)

# head(infosheet)
missing = (infosheet
           %>% filter(!(Study.ID %in% colnames(seqtab))))
# dim(missing)
# dim(infosheet)
# sum(infosheet$Illumina.Plate.Number == '')
# dim(infosheet)
# dim(seqtab)
# dim(missing)
# sum(colnames(seqtab) %in% infosheet$Study.ID)

missing = (missing
           %>% filter(Illumina.Plate.Number != ''))
# dim(missing)

no_info = colnames(seqtab)[!colnames(seqtab) %in% infosheet$Study.ID]
no_info = no_info[startsWith(no_info, 'IMG')]
# length(no_info)

write.csv(missing, file = 'intermed/missing_from_seqtab.csv')


# no_info