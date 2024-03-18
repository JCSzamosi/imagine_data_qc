ds = read.delim('data/IMGcorrected_reformatted.tsv')
summary(ds)
library(tidyverse)
filter(ds, is.na(ID))


ds = read.delim('data/IMGcorrected_rm-s.txt', sep = '|')
head(ds)
ds = mutate_if(ds, is.character, trimws)
head(ds)
any(!is.na(ds$X))
ds = select(ds, -X)
head(ds)

dups = ds %>% count(Sample.ID) %>% filter(n > 1) %>% left_join(ds)
dups = select(dups, -n, -ID)
dups

ds %>% filter(startsWith(Sample.ID, 'I'))

write.csv(dups, file = 'l_dup2.csv')


d_dup = read.csv('../ParticipantDocument_Full/intermed/duplicate_sampleIDs.csv')
d_dup

sum(d_dup$SampleID %in% as.numeric(dups$Sample.ID))
summary(dups)
