library(tidyverse)

img_wide = read.csv('data/current/IMAGINE_StoolSpecimenCollectionIDListing_20230628_Surette_Revised_20240318_sheet1.csv')

img_new = read.csv('IMAGINE_first HC.csv')

head(img_new)
head(img_wide)

img_long = (img_wide
            %>% mutate(PatID = 1:nrow(.))
            %>% select(PatID, everything())
            %>% pivot_longer(-(1:3), names_to = 'Timepoint',
                             values_to = 'SampleID'))
img_actually_new = (img_new
                    %>% filter(!(Baseline.or.first.other.sample %in% img_long$SampleID)))
dim(img_new)
dim(img_actually_new)

head(img_actually_new)

to_bind = (img_actually_new
           %>% mutate(Timepoint = 'Baseline.Stool.Specimen.ID',
                      SampleID = Baseline.or.first.other.sample,
                PatID = (max(img_long$PatID)+1):(max(img_long$PatID) + nrow(.)))
           %>% select(-Baseline.or.first.other.sample)
           %>% select(PatID, everything()))
img_full = rbind(img_long, to_bind)

head(img_full)
img_full %>% count(SampleID) %>% filter(n > 1, !is.na(SampleID)) %>% left_join(img_full)

img_full_wide = (img_full
                 %>% pivot_wider(names_from = 'Timepoint',
                                 values_from = SampleID,
                                 values_fill = NA)
                 %>% select(-PatID))
colnames(img_full_wide) = c('Site Number', 'Disease Type',
                            'Baseline Stool Specimen ID', '1 Year Stool Specimen ID',
                            '2 Year Stool Specimen ID', '3 Year Stool Specimen ID',
                            '4 Year Stool Specimen ID')
head(img_full_wide)

write.csv(img_full_wide, 'data/current/IMAGINE_Sample_Info_from_IMAGINE_20250129.csv',
          row.names = FALSE, na = '')
