library(tidyverse)

infosheet = read.csv('data/active_Rossi_info_datasheet.csv')
seqtab = read.csv('data/active_seqtab_nochim.csv', nrow = 1)

missing_merge = (infosheet
                 %>% filter(!(Study.ID %in% colnames(seqtab))))
dim(missing_merge)

# head(infosheet)
missing = (infosheet
           %>% filter(!(Study.ID %in% colnames(seqtab))))
dim(missing)
dim(infosheet)
sum(infosheet$Illumina.Plate.Number == '')
dim(infosheet)
dim(seqtab)
dim(missing)
sum(colnames(seqtab) %in% infosheet$Study.ID)

missing = (missing
           %>% filter(Illumina.Plate.Number != ''))
dim(missing)

no_info = colnames(seqtab)[!colnames(seqtab) %in% infosheet$Study.ID]
no_info = no_info[startsWith(no_info, 'IMG')]
length(no_info)

missing
no_info

no_info = sub('A','', no_info)
no_info = sub('B','', no_info)
length(no_info)
sum(no_info %in% infosheet$Study.ID)
dim(missing)
sum(missing$Study.ID %in% no_info)

missing = (missing
           %>% filter(!Study.ID %in% no_info))
missing

write.csv(missing, file = 'intermed/missing_from_seqtab.csv')


# no_info