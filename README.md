IMAGINE Project Data Curation
=============================

## Data

All current data files are stored in [./data/current/](./data/current). They are
not tracked under version control, and I am listing them below. Because the file
names change as they get updated, I have files in the [./data/](./data/)
directory that are symlinks to these files. They all start with `active_`
followed by a description of what they are. If you need to rerun the pipeline,
you'll need to move the old files from [./data/current/](./data/current/) to
[./data/obsolete/](./data/obsolete/), put the new files in
[./data/current/](./data/current/), and then update the symlinks. The Make file
and scripts should only refer to the symlinks, so you shouldn't have to change
anything else.

Double check that you have a replacement for a file before you move it. Some
files in [./data/current/] are generated by scripts and can just be overwritten
that way, or else do not change every time and might need to just be left where
they are.

The data files used here, which are too large to track under version control,
are:

1. The metadata sheet provided by Tania and Aida from the IMAGINE project:
	* [data/current/IMAGINE_Stool_SpecimenCollectionIDListing_20230628_Surette.xls](data/IMAGINE_Stool_SpecimenCollectionIDListing_20230628_Surette.xls)
2. The .csv version of the first sheet of that Excel file, saved by me: 
	* [data/currentIMAGINE_Stool_SpecimenCollectionIDListing_20230628_Surette_sheet1.csv](data/IMAGINE_Stool_SpecimenCollectionIDListing_20230628_Surette_sheet1.csv)
3. The .csv provided by Mike with the first samples from the sites that need
	more profiles
	* [data/current/IMAGINE_first HC.csv](data/current/IMAGINE_first HC.csv)
4. The Sample Info Sheet provided by Laura after sequencing:
	[data/current/IMG_sampleinfosheet_Jan2025.xlsx](data/current/IMG_sampleinfosheet_Jan2025.xlsx)
5. Sometimes Laura provides a seqtab and sometimes she provides a mergetab
file. There are scripts for each option, which you can read about below.
6. If Laura provides a taxtable, it goes in [./data/current/](./data/current/)
as well, but she doesn't have to. There are scripts here which will generate it,
put it in that directory, and then create the symlink.

## Processing Pipeline

Everything is controlled by the [Makefile](./Makefile). If you're on a normal
linux system and you have gnu-make installed, you should just be able to type
`make TARGETNAME` from the top of the [../DataQC](../DataQC) directory structure
and everything required to generate the latest version of whatever you're trying
to generate.

That's the idea in principle. In practice, I guarantee you will run into errors.
I recommend looking at the Makefile with your target in mind, checking what's
upstream of it, and making one or two steps at a time to catch those errors.

Here is the pipeline in detail:

Outside the Makefile:

0. [./scripts/manually_fix_imagine_sheet.R](./scripts/manually_fix_imagine_sheet.R)
	* This is outside the Makefile. You'll want to run it first, and only if the
	IMAGINE file has changed. It just adds Mike's list of sample IDs to the one I
	got from Tania and Aida and re-generates the wide IMAGINE data

In the Makefile:

1. `data/active_seqtab_nochim.csv`
	* This will get triggered if the `data/active_mergetab_nochim.rds` symlink is
	newer than the seqtab symlink above. If Laura gives you a mergetab rds file,
	and you put it in the `data/current/` directory and update the symlink, this
	will turn it into a transposed seqtab, put that in the `data/current/`
	directory, and then create the appropriate symlink in the `data/` directory.
	If Laura gives you a transposed seqtab csv file instead, and you appropriately
	update _its_ symlink in the `data` directory, Make should ignore this recipe
2. `data/active_taxtab_silva138wsp.rds`
	* This will be triggered if the `data/active_seqtab_nochim.csv` symlink is
	newer than the symlink to the taxtab listed above. If Laura hasn't assigned
	taxonomy yet, this will run. If Laura sends you a taxtab along with a seqtab
	and you appropriately place them in `data/current/` and update the symlinks,
	then Make should ignore this recipe. Normally I tell Laura that just a
	mergetab rds is fine, because that's easier for her, and my computer will run
	the taxonomy assignment faster than hers will, so these two steps _do_ get
	triggered.
3. `cleaned/seqtab_cleaned.csv`
	* Reformats sample IDs, merges multiply sequenced samples, and otherwise makes
	a seqtab that will work nicely with the metadata files.
4. `intermed/missing_from_seqtab.csv`
	* There are often some samples that are present in the infosheet Laura sends
	you that will be missing from your seqtab. Sometimes this is because the
	infosheet contained samples that have not yet been sequenced, but sometimes
	it's the result of data entry errors. If you have time, it's worth running it
	by Laura and making sure there aren't any errors, but if you don't have time
	you can just let it go
5. `intermed/mapfile_full.csv`
	* This merges the sample info files from the IMAGINE group with the sample
	data sheet from Laura to create one unified mapfile. You will get a
	many-to-many relationship warning because there are some data-entry errors on
	the side of the IMAGINE group. Site 25 has some problems with their SampleIDs,
	so they are excluded from the Participant Documents, but for completeness and
	for future analysis, I am not removing them from my initial data processing
	step. You can double check that that's all that's going on by loading the file
	`intermed/mapfile_full.csv` into R and counting the SampleID column.
	Everything with n > 1 should have at least one row from Site 25. If that is
	_not_ the case, you'll need to talk to Tania and Aida about it.
	* In addition to the full mapfile, this step also produces the following
	cleaned mapfiles:
		* `cleaned/mapfile_sequenced.csv`: A mapfile that only includes sequenced
		samples
		* `cleaned/mapfile_clean.csv`: A mapfile that only includes sequenced
		samples and excludes all samples from site 25.
6. `cleaned/ps_full.Rdata`
	* Produces a phyloseq object from the cleaned seqtab, taxtab, and mapfile.
	Excludes unsequenced samples (obviously) and samples from site 25.
	* Because I like to remove the ASV sequences from the phyloseq object for
	readability, this also produces a file with a vector of sequences, named with
	the phyloseq taxa IDs.:
		* `cleaned/seqs_full.Rdata`
7. `cleaned/ps_samfilt.Rdata`
	* Removes all samples that have fewer than 10,000 reads and all taxa that are
	zero everywhere. "samfilt" is short for "sample-filtered"
8. `intermed/clst.Rdata`
	* Clusters the sequences to 99% similarity. This just creates the clustering.
	Downstream scripts will assign taxonomy and create the phyloseq object.
9. `intermed/tax_99.Rdata`
	* Creates consensus sequences for the clusters, and assigns taxonomy to them
10. `cleaned/ps_99.Rdata`
	* Creates the phyloseq object of the 99% clustered OTUs
11. `cleaned/ps_99_samfilt.Rdata`
	* Filters to only samples that are in ps_samfilt and removes taxa that are 0
	everywhere.
