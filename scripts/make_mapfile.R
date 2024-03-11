# Use the metadata and sample info sheets from IMAGINE and Laura to make a
# functional mapfile including all and only the samples we have both sequencing
# and unambiguous metadata for

## Setup ####
library(tidyverse)

## QC IMAGINE sheet ####
img_sheet = read.csv('data/corrected_IMAGINE_Stool_SpecimenCollectionIDListing_20230628_Surrete_sheet1.csv')
head(img_sheet)
colnames(img_sheet) = c('Site', 'DiseaseType','Baseline','Year1','Year2',
                        'Year3','Year4')
img_long = (img_sheet
           %>% pivot_longer(c(Baseline, starts_with('Year')), names_to = 'Timepoint',
                            values_to = 'SampleID'))
head(img_long)
dim(img_long)

# check for duplicate sample IDs
dups = (img_long
        %>% filter(!is.na(SampleID))
        %>% count(SampleID)
        %>% left_join(img_long)
        %>% filter(n > 1)
        %>% select(-n)
        %>% arrange(SampleID, Site))
dups
write.csv(dups, file = 'intermed/duplicate_sampleIDs.csv', row.names = FALSE)

# There are 10 duplicated sample IDs. These must be eliminated from analysis
# until they can be corrected

## QC Laura's infosheet ####

# Read in Laura's info sheet
infosheet = read.csv('data/IMG1-4164_sampleinfosheet_Aug2023.csv',
                     header = TRUE, strip.white = TRUE)
head(infosheet)
l_dups = (infosheet 
          %>% count(Sample.ID..) 
          %>% left_join(infosheet)
          %>% filter(n > 1))
dim(l_dups)
summary(l_dups)

## Compare the two sheets ####

any(l_dups$Sample.ID.. %in% dups$SampleID)
any(dups$SampleID %in% l_dups$Sample.ID..)

# It's not the same set of duplicates
dim(infosheet)

write.csv(l_dups, file = 'intermed/l_duplicate_sampleIDs.csv',
          row.names = FALSE)


# For now, we'll just remove everything that is duplicated. We're also removing
# everything from site 25 until they are able to figure out what caused their
# sample duplication problems.

img_filt = (img_long
            %>% filter(Site != 25, 
                       !is.na(SampleID),
                       !SampleID %in% dups$SampleID))
dim(img_long)
dim(img_filt)

# Removing site 25 means removing 3385 samples. The duplicates are just an
# additional 6 or so.

insh_filt = (infosheet
             %>% filter(!Sample.ID.. %in% l_dups$Sample.ID..)
             %>% rename(SampleID = 'Sample.ID..'))
dim(infosheet)
dim(insh_filt)

# This cost us 66 rows, which is 33 samples.

## Generate the Mapfile ####

mapfile = (img_filt
           %>% left_join(insh_filt)
           %>% select(SampleID, everything()))
dim(mapfile)
head(mapfile)


# this mapfile excludes site 25 and all duplicate Sample IDs, but includes
# samples which have not yet been sequenced

write.csv(mapfile, file = 'cleaned/mapfile_all.csv', row.names = FALSE)

# now write a mapfile only including sequenced samples

write.csv(filter(mapfile, !is.na(Study.ID..)),
          file = 'cleaned/mapfile_sequenced.csv', row.names = FALSE)
