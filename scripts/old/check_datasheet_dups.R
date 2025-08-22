library(tidyverse)
img_d = read.csv('data/active_IMAGINE_metadata_wide.csv')
head(img_d)
colnames(img_d) = c('Site','Participant', 'Disease', 'IBDType', 'Baseline', 'Y1',
                    'Y2', 'Y3','Y4')

img_d_long = (img_d
              %>% pivot_longer(-(1:4),
                          names_to = 'Timepoint', values_to = 'SampleID')
              %>% filter(!is.na(SampleID)))
head(img_d_long)

img_dups = (img_d_long 
            %>% count(SampleID)
            %>% filter(n > 1)
            %>% left_join(img_d_long))
img_dups


ds = read.csv('data/active_Rossi_info_datasheet.csv')
ds_dedup = unique(select(ds, -ID))
any(is.na(ds$Sample.ID))
head(ds)
summary(ds)
dim(ds)
dim(ds_dedup)

dups = (ds_dedup
        %>% count(Sample.ID) 
        %>% filter(n > 1) 
        %>% left_join(ds))
dups = select(dups, -n)
dim(dups)
head(arrange(dups, Sample.ID))

img_d_long %>% filter(SampleID %in% dups$Sample.ID)

write.csv(dups, file = 'intermed/actual_dups.csv')

ident = (ds
         %>% count(Sample.ID)
         %>% filter(n > 1)
         %>% left_join(ds)
         %>% select(-n)
         %>% filter(!Sample.ID %in% dups$Sample.ID))
dim(ident)
head(ident)
write.csv(ident, file = 'intermed/identical_dups.csv')

# Are any duplicates in the sequenced data?

asvtab = readRDS('data/active_mergetab_nochim.rds')
asvtab = t(asvtab)
head(colnames(asvtab))
any(colnames(asvtab) %in% dups$Study.ID)
colnames(asvtab)[colnames(asvtab) %in% dups$Study.ID]

# Yes. Don't merge the sheets until this is sorted out.
dups %>% filter(Study.ID %in% colnames(asvtab))
