IMAGINE Project Data Curation
=============================

PLEASE DON'T TOUCH THIS REPOSITORY YET

This is a repository for running data QC steps on the IMAGINE 16S data, but Jake
is currently refactoring it and a lot of stuff in here either doesn't work, or
doesn't work as expected. Please no touching right now.

## Directory Overview

### Not tracked under Git

* [input/](./input/) - DO NOT TOUCH
	* raw input files received from Aida or Laura that need to be QC'ed and
	reformatted before use. These should be read-only and in general no one
	should be touching these except occasionally to update them to more current
	versions. That updating should be the responsibility of one person and
	currently that person is Jake.
* [data/](./data/) - DO NOT TOUCH
	* mapfiles, tax tables, and asvfiles that have been generated from the
	[input](./input/) files. These should be in a format that are easy to bring
	in to R, and should be useable for analysis. They will not have been cleaned
	or filtered except to merge duplicate samples, remove discards, and deal
	with any missing/duplicated sample IDs.
	* generating the files in this directory is a manual step and should be the
	responsibility of one person. Currently that person is Jake.
	* I am debating whether to move this directory up out of the [DataQC](./)
	directory and into the [16S](../) directory so it's more accessible.
* [cleaned/](./cleaned/)
	* contains a number of tables or rds/Rdata objects. Jake has and will update
	scripts to produce a few different cleaned datasets, including datasets that
	are 99% clustered, datasets that have low-read samples removed, etc. These
	are probably the datasets you want to start with to run your analyses.
	* If you want to make different cleaned datasets than are currently
	available, starting from the [data](./data/) files, please feel free. Just
	make sure to give your dataset an informative file name and avoid
	overwriting existing files. All cleaned datasets should be generated via
	scripts, and the script that produces that dataset should be listed below,
	following the example format, so that we have a record of what everything
	is. Scripts that produce the clean datasets should be stored in the
	[scripts/](./scripts/) directory.
		* **Example:** [cleaned file](./path/to/file) is created by 
		[script name](./path/to/script)
	* If you want to play with cleaning and saving datasets without following
	the above instructions, you are welcome to do so but please do not save any
	output into this DataQC directory. 
	* As with [data](./data/), I am debating moving this directory up out of the
	[DataQC](./) directory and into the [16S](./16S) directory so that it's more
	accessible.

### Tracked under Git

* [scripts/](./scripts/)
	* contains all the scripts used to generate the files in [data](./data/) or
	[cleaned](./cleaned/). Ideally, all scripts should be controlled by a
	Makefile (or, later on, a Nextflow pipeline), but if you are not comfortable
	using Make, that is okay. 
	* please make a directory with your name on it inside the scripts directory
	if you are not making your scripts part of the Make pipeline, so that we
	don't get too much clash.
	* **analysis scripts do not belong in this directory.** This directory is
	only for cleaning and QCing the data before analysis. If you want to conduct
	analysis, please create a different directory outside of the DataQC
	directory and then symlink to the [cleaned](./cleaned/) or [data](./data/)
	directory from there to bring in the data you need for your analysis
* [Makefile](./Makefile)
	* A Makefile so that things happen in the correct order and only when
	necessary. If you want to learn about Make you can 
	[start here](https://makefiletutorial.com/), but I will be honest, I don't
	recommend it. The plan is to transition this pipeline to Nextflow, which is
	a lot less hostile.
* [logs/](./logs/)
	* A place for log files. I like to log anything that I run
	non-interactively, so I can see what got written to standard error and
	standard out. There are a few different options for this, depending on how
	you run things:
		* If you use tmux, there is a [pretty user-friend logging
		extension](https://github.com/tmux-plugins/tmux-logging) that you can
		use.
		* If you use screen and want to learn about logging, feel free to ask
		for my .screenrc file for an example of how to control log output.
		* If you are running something via slurm, you can control the logfile
		output following the first answer
		[here](https://unix.stackexchange.com/questions/285690/slurm-custom-standard-output-name).

## Directory Details

### Raw Inputs

All raw input data files are stored in [./input/](./input/). In general, no one
should be interacting with these files. The files people should use to conduct
their analysis will be generated from these raw inputs and will be stored in
[./data/](./data/) and [./cleaned/](./cleaned/).

All raw input data files are stored in [./input/current/](./input/current). They
are not tracked under version control, and I am listing them below. Because the
file names change as they get updated, I have files in the [./input/](./input/)
directory that are symlinks to these files. All the symlinks start with
`active_` followed by a description of what they are. When the input files get
updated (we get a new IMAGINE metadata sheet or mergetab or something), the
process is to move the exiting files from [./input/current/](./input/current/)
to [./input/obsolute](./input/obsolete), put the new files in
[./input/current/], and update the symlinks in [./input]. Scripts should only
ever point to the symlinks, not to the actual files, so that they don't need to
be updated when the files change.

The files in [./input/](./input/) should never be edited, and certainly not by a
script. Any filtering, QC, etc, happens upstream of that and filtered datasets
should be written to [./data/](./data/). Nothing should get written to
[./data/](./data/) manually, but only ever via the scripts in
[./scripts](./scripts/) and ideally only via the Makefile (or, hopefully in the
future, a Nextflow workflow).

The files in [./input/](./input/) are not to be tracked under version control
because they are too big, and because they contain sensitive information that
should not be transfered to github. Below is a list of current input files and
their symlinks:

1. [active_IMAGINE_metadata_wide.csv](./input/active_IMAGINE_metadata_wide.csv)
->
[current/IMAGINE_Stool_IMG_20250528.csv](./input/current/IMAGINE_Stool_IMG_20250528.csv)
	* This is the most up-to-date version of the IMAGINE metadata sheet provided
	by Aida. It is always in wide format, with one row per participant, and
	needs to be reformatted before we can use it. There is a manual QC step (see
	Scripts section) to QC and reformat this file and reconcile it with 2.
2. [active_Surette_sample_info_sheet.csv](./input/active_Rossi_info_datasheet.csv)
->
[current/IMG-corrected-sampleinfosheet-Aug2025.csv](./input/current/IMG-corrected-sampleinfosheet-Aug2025.csv)
	* This is the sample data sheet from the Surette lab provided by Laura. It
	has some columns we don't need. There is a manual QC step (see Scripts
	section) to QC this file and reconcile it with 1.
3. [active_mergetab_nochim.rds](./input/active_mergetab_nochim.rds) ->
[current/mergetab_nochim_IMG1-11887-May2025_v34.rds](./input/current/mergetab_nochim_IMG1-11887-May2025_v34.rds)
	* This is the merged ASV table provided by Laura. It should be updated
	whenever Laura re-runs `dada2` to add more sequened samples. It contains all
	negative controls as well as duplicates from re-sequenced samples, and may
	accidentally contain samples that should have been discarded but weren't
	before sequencing. There is a manual QC step (see Scripts) that merges
	duplicated samples, removes discards, and reconciles the sample IDs with 1
	and 2.

Sometimes Laura provides transposed seqtab files and tax tables, but not always
because they take forever to generate. I have scripts to produce them.

JAKE STOPPED EDITING HERE. WILL RETURN TOMORROW.

### Scripts

I have written several scripts to perform various data cleaning functions. One
of them should be run interactively, but the rest can be run via a Make file or
similar.

0. [00_manual_qc__steps.Rmd](./scripts/00_manual_qc_steps.Rmd)
	* This should always be done interactively, using something like RStudio, so
	you can look at the output at each step and make decisions. It will probably
	need to be changed/updated every time the files in [input/](./input/) are
	updated. Running this should be the responsibility of one person. Currently
	that person is Jake. Everything downstream of this can be run via the
	Makefile.
	* Output files: 
		* duplicate/missing sample files in [intermed/](./intermed/). These will
		vary depending on what's up with the sheets.
		* [data/merged_maptab.csv](./data/merged_maptab.csv) is the mapfile
		created by merging the IMAGINE sheet and the Surette lab sheet. It might
		contain duplicate sample IDs, if there were duplicates at the
		reconciliation step. The goal is to resolve all those duplicates, but
		for now there are some. This file will contain both sequenced and
		unsequenced samples, as well as all negative controls. 
		* [data/merged_seqtab.csv](./data/merged_seqtab.csv) is the transposed
		ASV table (taxa are rows), with the resequenced samples merged. It will
		contain negative controls and has not been in any way filtered except to
		remove samples that should have been discarded. The column names
		correspond to the Study.ID column in the mapfile
1. [01_assign_tax_asvs.R](01_assign_tax_asvs.R)
	* This assigns taxonomy to the merged, transposed ASV table from step 0. It 
	takes [data/merged_seqtab.csv] and
	[refs/silva_nr99_v138_train_set.fa](./refs/silva_nr99_v138_train_set.fa) as
	inputs and creates [data/merged_taxtab.csv]. I'm not using the wSpecies file
	because the dada2 authors are clear that species should only be assigned via
	100% identity, not the heuristing assignment algorithm.

## Processing Pipeline

Everything is controlled by the [Makefile](./Makefile). If you're on a normal
linux system and you have gnu-make installed, you should just be able to type
`make TARGETNAME` from the top of the [DataQC/](../DataQC) directory structure
and everything required to generate the latest version of whatever you're trying
to generate will get created.

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
