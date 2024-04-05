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

# Filter out samples we're not using and remove duplicate rows
infosheet = (infosheet
             %>% filter(!grepl('DNP', Illumina.Plate.Number),
                        !grepl('DNP',Study.ID))
             %>% select(-ID)
             %>% unique())
# dim(infosheet)

## Compare the two sheets ####

# sum(!(infosheet$Sample.ID %in% img_long$SampleID))

## Houston, we have a problem. There are 327 Sample IDs in Laura's info sheet
# that are not in the metadata from IMAGINE.

probs = (infosheet
         %>% filter(!(Sample.ID %in% img_long$SampleID)))
# old_probs = read.csv('intermed/missing_from_IMAGINE.csv')

# all(probs$Sample.ID %in% old_probs$Sample.ID)

## Generate the Mapfile ####

infosheet = (infosheet
             %>% rename(SampleID = 'Sample.ID'))

mapfile = (img_long
           %>% full_join(infosheet)
           %>% select(SampleID, everything()))
# dim(mapfile)
# head(mapfile)

# this mapfile includes everything: site 25 is in there, as are the Surette
# sample IDs that are absent from the IMAGINE metadata, and the two remaining
# duplicate sample IDs
# dim(mapfile)
write.csv(mapfile, file = 'intermed/mapfile_full.csv', row.names = FALSE)

# this mapfile includes everything that has been sequenced

mapfile_seq = (mapfile
               %>% filter(!(Illumina.Plate.Number %in% c('','no amp')),
                          !is.na(Illumina.Plate.Number)))
# dim(mapfile_clean)

write.csv(mapfile_seq, file = 'cleaned/mapfile_sequenced.csv',
          row.names = FALSE)