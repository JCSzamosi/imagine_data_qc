library(tidyverse)
img_d = read.csv('data/IMAGINE_wide.csv')
head(img_d)
colnames(img_d) = c('Site','Disease', 'Baseline', 'Y1', 'Y2', 'Y3','Y4')

img_d_long = pivot_longer(img_d, -(1:2),
                          names_to = 'Timepoint', values_to = 'SampleID')
head(img_d_long)
img_dups = (img_d_long 
            %>% filter(!is.na(SampleID))
            %>% count(SampleID)
            %>% filter(n > 1)
            %>% left_join(img_d_long))
img_dups


ds = read.csv('data/Surette_datasheet.csv')
any(is.na(ds$Sample.ID..))
head(ds)
summary(ds)

dups = (ds 
        %>% count(Sample.ID..) 
        %>% filter(n > 1) 
        %>% left_join(ds))
dups = select(dups, -n, -ID)
dups

write.csv(dups, file = 'intermed/l_dup2.csv')


# Are any duplicates in the sequenced data?

asvtab = read.csv('data/seqtab_nochim_transposed_IMG1-4164-Aug2023_v34.csv')
head(colnames(asvtab))
any(colnames(asvtab) %in% dups$Study.ID..)
colnames(asvtab)[colnames(asvtab) %in% dups$Study.ID..]

# Yes. Don't merge the sheets until this is sorted out.
dups %>% filter(Study.ID.. %in% colnames(asvtab))
