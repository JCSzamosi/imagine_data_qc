IMAGINE Project Data Curation
=============================

**PLEASE DON'T TOUCH THIS REPOSITORY YET**

This is a repository for running data QC steps on the IMAGINE 16S data, but Jake
is currently refactoring it and a lot of stuff in here either doesn't work, or
doesn't work as expected. Please no touching right now.

## Directory Overview

### Not tracked under Git

* [input/](./input/) - **READ ONLY**
	* raw input files received from Aida or Laura that need to be QC'ed and
	reformatted before use. These should be read-only and in general no one
	should be touching these except occasionally to update them to more current
	versions. That updating should be the responsibility of one person and
	currently that person is Jake.
* [data/](./data/) - **READ ONLY**
	* mapfiles, tax tables, and asvfiles that have been generated from the
	[input](./input/) files. These should be in a format that are easy to bring
	in to R, and should be useable for analysis. They will not have been cleaned
	or filtered except to merge duplicate samples, remove discards, and deal
	with any missing/duplicated sample IDs.
	* generating the files in this directory is a manual step and should be the
	responsibility of one person. Currently that person is Jake.
	* I will put a symlink to this directory in the [16S](../) directory so that
	the files are accessible to everyone.
* [cleaned/](./cleaned/) - **START HERE**
	* contains a number of tables or rds/Rdata objects. Jake has, and will
	update, scripts to produce a few different cleaned datasets, including
	datasets that are 99% clustered, datasets that have low-read samples
	removed, etc. These are probably the datasets you want to start with to run
	your analyses.
	* If you want to make different cleaned datasets than are currently
	available, starting from the [data](./data/) files, please feel free. Just
	make sure to give your dataset an informative and unique file name and avoid
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
	* As with [data/](./data/), I am debating moving this directory up out of 
	the [DataQC/](./) directory and into the [16S](./16S) directory so that it's
	more accessible.

### Tracked under Git

* [scripts/](./scripts/)
	* contains all the scripts used to generate the files in [data/](./data/) or
	[cleaned/](./cleaned/). Ideally, all scripts should be controlled by a
	Makefile (or, later on, a Nextflow pipeline), but if you are not comfortable
	using Make, that is okay. 
	* please make a directory with your name on it inside the scripts directory
	if you are not making your scripts part of the Make pipeline, so that we
	don't get too much clash.
	* **analysis scripts do not belong in this directory.** This directory is
	only for cleaning and QCing the data before analysis. If you want to conduct
	analysis, please create a different directory in the [16S/](../) directory
	and then symlink to the [cleaned](./cleaned/) or [data](./data/) directory
	from there to bring in the data you need for your analysis.
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
		[here](https://unix.stackexchange.com/questions/285690/slurm-custom-standard-output-name)
		or copy my method (look in my scripts for the `#SBATCH --output` and
		`#SBATCH --error` commands.

## Directory Details

### Raw Inputs 

* [input](./input/)

All raw input data files are stored in [input/](./input/). In general, no one
should be interacting with these files. The files people should use to conduct
their analysis will be generated from these raw inputs and will be stored in
[data/](./data/) and [cleaned/](./cleaned/).

All raw input data files are stored in [input/current/](./input/current). They
are not tracked under version control, and I am listing them below. Because the
file names change as they get updated, I have files in the [input/](./input/)
directory that are symlinks to these files. All the symlinks start with
`active_` followed by a description of what they are. When the input files get
updated (we get a new IMAGINE metadata sheet or mergetab or something), the
process is to move the exiting files from [input/current/](./input/current/)
to [input/obsolute](./input/obsolete), put the new files in
[input/current/](./input/current/), and update the symlinks in
[input/](./input/). Scripts should only ever point to the symlinks, not to the
actual files, so that they don't need to be updated when the files change.

The files in [input/](./input/) should never be edited. These are our raw input
data files.  Any filtering, QC, etc, happens upstream of these files and filtered
datasets should be written to [data/](./data/) or [cleaned/](./cleaned/).
Nothing should get written to [data/](./data/) manually, but only ever via the
scripts in [scripts/](./scripts/).

The files in [input/](./input/) are not to be tracked under version control
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

### Data Files

* [data](./data/)

Most analyses will probably start with files in the [cleaned/](./cleaned/)
folder; however, if you want to do your own data cleaning you should start in
the [data/](./data/) directory. There are three files in this directory, on
which very minimal cleaning has been done.

1. [merged_maptab.csv](./data/merged_maptab.csv)
	* This is the mapfile with all the sample metadata from both the IMAGINE
	database and the Surette lab sample info sheet. As long as there are
	duplicated sample IDs in either of those databases, this sheet will have
	some duplicated samples, so you'll need to check for those and remove
	them before moving forward.
	* This file is produced using the script
	[00_manual_qc_steps.Rmd](./scripts/00_manual_qc_steps.Rmd).
2. [merged_seqtab.csv](./data/merged_seqtab.csv)
	* This is the ASV table. Samples that have been sequenced repeatedly
	have been merged together, and column names have been cleaned so they
	match the `Study.ID` column in the mapfile. Samples that were labelled
	as "discard" have been removed; however, this file contains all negative
	controls and no read depth filtering has been performed.
	* This file is produced manually using the script
	[00_manual_qc_steps.Rmd](./scripts/00_manual_qc_steps.Rmd)
3. [merged_taxtab.csv](./data/merged_taxtab.csv)
	* This is the tax table that corresponds with the ASV table in 2. It is
	produced using the script
	[01_assign_tax_asvs.R](./scripts/assign_tax_asvs.R).

### Intermed

Files that are probably not going to be used directly in analysis, but are
required to produce the cleaned data files.

1. [clst99.Rdata](./intermed/clst99.Rdata)
    * The cluster table created by
    [03_make_clusters99.R](./scripts/cluster99/03_make_clusters99.R).
    * used as input by
        * [04_cluster_distributions99.R](./scripts/cluster99/04_cluster_distributions99.R)
        * [05_get_conseq99.R](./scripts/cluster99/05_get_conseq99.R)
        * [06_cluster_counts99.R](./scripts/cluster99/06_cluster_counts99.R)
2. [conseqs99.csv](./intermed/conseqs99.csv)
    * A csv table of the consensus sequences for each cluster, along with the
    cluster ID, created by
    [05_get_conseq99.R](./scripts/cluster99/05_get_conseq99.R).
    * used as input by
        * [06_cluster_counts99.R](./scripts/cluster99/06_cluster_counts99.R)
        * [07_assign_tax_clsts99.r](./scripts/cluster99/07_assign_tax_clsts99.R)
	
### Cleaned

**START HERE!** For the overwhelming majority of analyses, you should be
starting with data in this directory. These files have all had host ASVs
removed, and most of them have also had low-read-count samples removed. There
are options for ASVs or for 99%-clustered OTUs. The specific files are listed
below:

1. `full` files:
	* generated by [02_make_full.R](./scripts/02_make_full.R)
	* [full_ps.Rdata](./cleaned/full_ps.Rdata)
		* An `Rdata` file that contains two objects:
			* `ps` is a phyloseq object with all the non-discard samples and all
			non-host ASVs. It has not been clustered or filtered except to
			remove host.
			* for now, samples with duplicate IDs are removed from this dataset,
			but the goal is to deal with all the duplicate IDs that have come
			from the IMAGINE metadata so that these contain all the samples in
			the [data/](./data/) files.
			* `seqs` is a named vector of DNA sequences that correspond to the 
			taxa in the phyloseq object. They are named the same as the taxa so
			you can tell which is which. I always remove sequences to their own
			vector in order to reduce clutter in my objects and dataframes, but
			it does mean you have to be careful not to rename the taxa in the
			phyloseq object or you will not be able to reconnect them to their
			sequences
	* [full_seqs.Rdata](./cleaned/full_seqs.Rdata)
		* the same `seqs` vector as above, but packaged separately so you don't
		have to load the whole phyloseq object if all you need is the sequences.
	* [full_mats.Rdata](./cleaned/full_mats.Rdata)
		* The same data as in `full_ps`, but in two matrices: `full_asvtab` and
		`full_taxtab`, and one data frame: `full_maptab`. The tax and asv tables
		have sequences as their rownames.

2. [asvs/](./cleaned/asvs/)
	* files that are cleaned, filtered, and ready for analysis using unclustered
	asvs.
3. 


### Scripts

I have written several scripts to perform various data cleaning functions. The
first one should be run interactively, but the rest can be run via a Make file
or similar.

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
1. [01_assign_tax_asvs.R](./scripts/01_assign_tax_asvs.R)
	* This assigns taxonomy to the merged, transposed ASV table from step 0. It 
	takes [data/merged_seqtab.csv](./data/merged_seqtab.csv) and
	[refs/silva_nr99_v138_train_set.fa](./refs/silva_nr99_v138_train_set.fa) as
	inputs and creates [data/merged_taxtab.csv]. I'm not using the wSpecies file
	because the dada2 authors are clear that species should only be assigned via
	100% identity, not the heuristic assignment algorithm.
	* This should be run under `sbatch`. The script to do that is in
	[sbatch/01_run_assign_tax_asvs.sh](./sbatch/01_run_assign_tax_asvs.sh).
2. [02_make_full.R](./scripts/02_make_ps_full.R)
	* This takes all three files in [data/](./data/) as input and produces a
	phyloseq object and corresponding named vector of sequences in an RData file
	as output. This script removes host ASVs and any samples that have duplicate
	sample IDs, but does no other read depth, abundance, or prevalence filtering
	and does not remove negative controls.
	* The file produced in the [cleaned/](./cleaned/) directory is
	[ps_full.Rdata](./cleaned/ps_full.Rdata) and includes the following objects:
		* ps_full: phyloseq object with all samples and ASVs as described
		* seqs_full: named vector of sequences corresponding to ASVs
	* This needs to be run under `sbatch` because it uses more RAM than Nibi
	gives the login nodes. The script to do that is in
	[sbatch/02_run_make_full.sh](./sbatch/02_run_make_full.sh).

#### cluster99

3. [03_make_clusters99.R](./scripts/cluster99/03_make_clusters99.R)
	* This takes just the sequence vector
	([full_seqs.Rdata](./cleaned/full_seqs.Rdata)) and runs the 99% clustering
	on it. It returns a table of clusters that can then be used to create a new
	OTU table. This step is separated out into its own script because it takes
	forever and the next step can be error-prone.
	* Produces the file [intermed/clst99.Rdata](./intermed/clst99.Rdata).
	* Can be run under sbatch, but does not have to be. The more cores you can
	give it, the faster it runs, but it doesn't take much RAM. The script to run
	it under sbatch is at
	[sbatch/cluster99/03_run_make_clusters99.sh](./sbatch/cluster99/03_run_make_clusters99.sh)

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
