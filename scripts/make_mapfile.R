# Use the metadata and sample info sheets from IMAGINE and Laura to make a
# functional mapfile including all and only the samples we have both sequencing
# and unambiguous metadata for

## Setup ####
library(tidyverse)

## IMAGINE sheet ####
img_sheet = read.csv('data/active_IMAGINE_metadata_wide.csv')
# head(img_sheet)
colnames(img_sheet) = c('Site', 'DiseaseType','Baseline','Year1','Year2',
                        'Year3','Year4')
img_long = (img_sheet
           %>% pivot_longer(c(Baseline, starts_with('Year')), names_to = 'Timepoint',
                            values_to = 'SampleID')
           %>% filter(!is.na(SampleID)))
# head(img_long)
# dim(img_long)

## Laura's infosheet ####

# Read in Laura's info sheet
infosheet = read.csv('data/active_Rossi_info_datasheet.csv',
                     header = TRUE, strip.white = TRUE)
# head(infosheet)

## Compare the two sheets ####

# sum(!infosheet$Sample.ID %in% img_long$SampleID)
# infosheet %>%
#     filter(!Sample.ID %in% img_long$SampleID)

## Houston, we have a problem. There are 155 Sample IDs in Laura's info sheet
# that are not in the metadata from IMAGINE.

# probs = (infosheet
#          %>% filter(!(Sample.ID %in% img_long$SampleID)))
# 
# write.csv(probs, file = 'intermed/missing_from_IMAGINE.csv')

## Generate the Mapfile ####

# Filter out site 25 until its sample IDs are sorted
infosheet = (infosheet
             %>% rename(SampleID = 'Sample.ID'))

mapfile = (img_long
           %>% full_join(infosheet)
           %>% select(SampleID, everything()))
# dim(mapfile)
# head(mapfile)

# this mapfile includes everything: site 25 is in there, as are the Surette
# sample IDs that are absent from the IMAGINE metadata

write.csv(mapfile, file = 'intermed/mapfile_full.csv', row.names = FALSE)

# this mapfile excludes site 25 but includes samples which have not yet been
# sequenced

mapfile_clean = (mapfile
                 %>% filter(Site != '25'))

write.csv(mapfile_clean, file = 'cleaned/mapfile_clean.csv', row.names = FALSE)

# this mapfile only includes samples that have been sequenced, and excludes
# those from site 25

mapfile_seq = (mapfile_clean
               %>% filter(SampleID %in% infosheet$SampleID))


write.csv(mapfile_seq, file = 'cleaned/mapfile_sequenced.csv',
          row.names = FALSE)
