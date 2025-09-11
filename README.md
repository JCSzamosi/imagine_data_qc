IMAGINE Project Data Curation
=============================

This is a repository for running data QC steps on the IMAGINE 16S data. If all
you want is to _use_ the cleaned data, you can access it via symlinks in the
`cleaned` directory in the `16S` directory above this one, or you can copy the
files to your own project directory directly.

If you want to suggest changes to how the cleaning is done, your best option is
to open an issue on the github repository's [issue
tracker](https://github.com/JCSzamosi/imagine_data_qc/issues).

If you want to write code to change how cleaning is done, please clone the
[github repository](https://github.com/JCSzamosi/imagine_data_qc) and submit a
pull request.

## Directory Overview

### Not tracked under Git

* [cleaned/](./cleaned/)
    * Contains a number of tables and Rdata objects that are ready to be used
      for downstream analysis. These files are produced from the files in the
      `data/` directory using the scripts in the `scripts/` directory. These are
      probably the datasets you want to start with to run your analyses.
    * All files should be contained within a subdirectory. The subdirectories
      are currently `asvs/` and `cluster99/`:
        * [asvs/](./cleaned/asvs/): Contains all cleaned data objects at the ASV
          level (not 99% clustered).
        * [cluster99/](./cleaned/cluster99/): Contains all cleaned data objects
          with ASVs clustered at 99% similarity.
    * Each of those contains 2 further subdirectories: `full/` and `samfilt/`:
        * `full/`: Contains all samples, regardless of how many reads they have.
          Includes negative controls.  _Excludes_ host taxa
        * `samfilt/` contains only samples with at least 10k reads. Any taxa
          that were 0 everywhere after low-read-count samples were removed are
          also removed, in addition to host taxa.
    * I have not done any prevalence or abundance filtering, beyond removing
      taxa that are 0 everywhere after some samples are removed, because I
      believe this should happen _after_ samples are subset for specific
      analysis, and the choice of whether/how to filter will vary depending on
      the scientific question and also which and how many samples are used.
* [data/](./data/)
    * Merged mapfile, tax table, and asvfile that have been generated from the
      `input` files. Specifically, any samples that were sequenced repeatedly
      have been merged, and any samples that have been labelled as "discard"
      have been removed. 
    * These are in .csv format, so that they can be easily read into R, but they
      are not clean enough to use. May contain duplicate sample IDs due to data
      entry errors upstream that we are working on addressing. Contain all
      samples, including low-read-count and negative control. Contain all ASVs
      including host taxa.
    * Generating the files in this directory is a manual step and should be the
      responsibility of one person. Currently that person is Jake.
* [input/](./input/)
    * Raw input files received from Aida or Laura that need to be QC'ed and
      reformatted before use. These should be read-only and in general no one
      should be touching these except occasionally to update them to more
      current versions. Updating them should be the responsibility of one person
      and currently that person is Jake.
* [intermed](./intermed/) - **IGNORE THIS**
    * Ignore this directory. It contains intermediate files that are needed to
      produce the files in `cleaned/`.

### Tracked under Git

* [scripts/](./scripts/)
    * contains all the scripts used to generate the files in `data/`
      and `cleaned/`. Ideally, all scripts should be controlled by a
      Makefile (or, later on, a Nextflow pipeline), but right now we are sort of
      between pipelines so they are being run manually. They are numbered and
      should always be run in order.
    * **analysis scripts do not belong in this directory.** This directory is
      only for cleaning and QCing the data before analysis. If you want to
      conduct analysis, please create a different directory in the [16S/](../)
      directory and then symlink to the `cleaned` or `data` directory from there
      to bring in the data you need for your analysis.
* [logs/](./logs/)
    * A place for log files. I like to log anything that I run
      non-interactively, so I can see what got written to standard error and
      standard out. I do this one of two ways, depending on how a script is run.
        * If a script is run under tmux, I use the pretty user-friendly logging
          extension [tmux-logging](https://github.com/tmux-plugins/tmux-logging)
          to capture all the output to a log file.
        * If I am running something via slurm, I create log files in the sbatch
          scripts which allow stderr and stdout to be written to a single file.
          Look in any script in `sbatch/` for an example.
* [sbatch/](./sbatch/)
    * Contains all the shell scripts passed to `sbatch` for running things under
      `slurm`
* [stats](./stats/)
    * Contains very basic summary statistic (think: number of samples, number of
      taxa) as data move through the pipeline so we can track it and make sure
      nothing is being lost.
    * This is **not** a place for statistical analysis. That should go in a
      different project directory.

## Directory Details

### Raw Inputs ([input/](./input/))

All raw input data files are stored in [input/](./input/). In general, no one
should be interacting with these files. The files people should use to conduct
their analysis will be generated from these raw inputs and will be stored in
[data/](./data/) and [cleaned/](./cleaned/).

All current raw input data files are stored in
[input/current/](./input/current). They are not tracked under version control,
and I list them below. Because the file names change as they get updated, I have
files in the [input/](./input/) directory that are symlinks to the
[input/current/](./input/current/) files. All the symlinks start with `active_`
followed by a description of what they are. When the input files get updated (we
get a new IMAGINE metadata sheet or mergetab or something), the process is to
move the exiting files from [input/current/](./input/current/) to
[input/obsolete](./input/obsolete), put the new files in
[input/current/](./input/current/), and update the symlinks in
[input/](./input/). Scripts should only ever point to the symlinks, not to the
actual files, so that they don't need to be updated when the files change.

The files in [input/](./input/) should never be edited. These are our raw input
data files. Any filtering, QC, etc, happens upstream of these files, and
filtered datasets should be written to [data/](./data/) or
[cleaned/](./cleaned/).  

The files in [input/](./input/) are not to be tracked under version control
because they are too big, and because they contain sensitive information that
should not be transfered to github. Below is a list of current input files and
their symlinks:

1. [active_IMAGINE_metadata_wide.csv](./input/active_IMAGINE_metadata_wide.csv)
->
[current/IMAGINE_Stool_IMG_20250528.csv](./input/current/IMAGINE_Stool_IMG_20250528.csv)
    * This is the most up-to-date version of the IMAGINE metadata sheet provided
      by Aida. It is always in wide format, with one row per participant, and
      needs to be reformatted before we can use it. There is a manual QC step
      (see Scripts section) to QC and reformat this file and reconcile it with
      2.
2. [active_Surette_sample_info_sheet.csv](./input/active_Rossi_info_datasheet.csv)
->
[current/IMG-correctedB-sampleinfosheet-Aug2025.csv](./input/current/IMG-correctedB-sampleinfosheet-Aug2025.csv)
    * This is the sample data sheet from the Surette lab provided by Laura. It
      has some columns we don't need. There is a manual QC step (see Scripts
      section) to QC this file and reconcile it with 1.
3. [active_mergetab_nochim.rds](./input/active_mergetab_nochim.rds) ->
[current/mergetab_nochim_IMG1-11887-May2025_v34.rds](./input/current/mergetab_nochim_IMG1-12888-Aug2025_v34.rds)
    * This is the merged ASV table provided by Laura. It should be updated
      whenever Laura re-runs `dada2` to add more sequenced samples. It contains
      all negative controls as well as duplicates from re-sequenced samples, and
      may accidentally contain samples that should have been discarded but
      weren't before sequencing. There is a manual QC step (see Scripts) that
      merges duplicated samples, removes discards, and reconciles the sample IDs
      with 1 and 2.

### Data Files ([data/](./data/))

Most analyses will probably start with files in the [cleaned/](./cleaned/)
folder; however, if you want to do your own data cleaning you should start in
the [data/](./data/) directory. There are three files in this directory, on
which very minimal cleaning has been done. These files serve as input for the
data cleaning steps in [scripts/asvs/](./scripts/asvs/) and
[scripts/cluster99](./scripts/cluster99).

1. [merged_maptab.csv](./data/merged_maptab.csv)
    * This is the mapfile with all the sample metadata from both the IMAGINE
      database and the Surette lab sample info sheet. As long as there are
      duplicated sample IDs in either of those databases, this sheet will have
      some duplicated samples, so you'll need to check for those and remove them
      before moving forward.
    * This file is produced using the script
      [00_manual_qc_steps.Rmd](./scripts/00_manual_qc_steps.Rmd). See Scripts
      for more detail.
2. [merged_seqtab.csv](./data/merged_seqtab.csv)
    * This is the ASV table. Samples that have been sequenced repeatedly have
      been merged together, and column names have been cleaned so they match the
      `Study.ID` column in the mapfile. Samples that were labelled as "discard"
      have been removed; however, this file contains all negative controls and
      no read depth filtering or removal of host taxa has been performed.
    * This file is produced manually using the script
      [00_manual_qc_steps.Rmd](./scripts/00_manual_qc_steps.Rmd). See Scripts
      for more detail.
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
3. [clstaxtab99.csv](./intermed/clstaxtab99.csv)
    * A csv table of taxon assignments, without host removed, for the 99%
      clustered data. Created by
      [07_assign_tax_clsts99.R](./scripts/cluster99/07_assign_tax_clsts99.R).
    * used as input by
        * [08_make_full99.R](scripts/cluster99/08_make_full99.R)
	
### Cleaned

**START HERE!** For the overwhelming majority of analyses, you should be
starting with data in this directory. These files have all had host ASVs
removed. Cleaned datasets exist for both ASVs and 99%-clustered OTUs. Within
each of those categories there are `full` and `samfilt` datasets. `full`
datasets do not have any samples removed for low read counts, and also include
all negative controls. `samfilt` datasets have had negative controls and samples
with <10k reads removed. They also have all ASVs that became 0 everywhere
removed.

The directory structure within [cleaned/](./cleaned/) is

* [asvs/](./cleaned/asvs/)
    * [full/](./cleaned/asvs/full/):
        * All files in this directory are generated by
          [02_make_full.R](./scripts/asvs/02_make_full.R)
        * Files have the prefix `full_`
    * [samfilt/](./cleaned/asvs/samfilt/)
        * All files in this directory are generated by
          [03_make_ps_samfilt.R](./scripts/asvs/03_make_ps_samfilt.R)
        * Files have the prefix `samfilt_`
* [cluster99/](./cleaned/cluster99/)
    * [full/](./cleaned/cluster99/full/)
        * All files in this directory are generated by
          [08_make_full99.R](./scripts/cluster99/08_make_full99.R).
        * Files have the prefix `full99_`
    * [samfilt/](./cleaned/cluster99/samfilt/)
        * All files in this directory are generated by
          [09_make_samfilt99.R](./scripts/cluster99/09_make_samfilt.R).
        * Files have the prefix `samfilt99_`

Within each directory, there are 6 files, as follows:

1. `XX_ps.Rdata`: An `Rdata` file that contains two objects:
    * A phyloseq object with the sample data, count data, and taxonomy data all
      in one place. The sequences have been removed to their own vector to
      reduce visual clutter.
    * A named vector of DNA sequences that correspond to the taxa in
      the phyloseq object. They are named the same as the taxa so you can tell
      which is which. It is important not to rename the taxa in the phyloseq
      object or you will not be able to reconnect them to their sequences
2. `XX_seqs.Rdata`: An `Rdata` file containing only the named sequence vector
   from above, so that if you only need the sequences you don't have to load the
   entire dataset into RAM.
3. `XX_mat.Rdata`: The same data as in 1, but in matrix/dataframe format instead
   of as a phyloseq object. The counts and tax tables are matrices and the
   sample data are in a data frame. The count and tax tables have sequences as
   rownames and the sample data table has Study IDs (IMG numbers) as rownames
4. `XX_asv.csv` or `XX_otu.csv`: The ASV or OTU count table from 3 in `.csv`
   format.
5. `XX_tax.csv`: The taxonomy table from 3 in `.csv` format.
6. `XX_map.csv`: The sample data table from 3 in `.csv` format.


### Scripts

I have written several scripts to perform various data cleaning functions. The
first one should be run interactively, but the rest can be run via a Make file
or similar.

0. [00_manual_qc__steps.Rmd](./scripts/00_manual_qc_steps.Rmd)
    * **Input files:**
        * [input/active_IMAGINE_metadata_wide.csv](./input/active_IMAGINE_metadata_wide.csv)
        * [input/active_Surette_sample_info_sheet.csv](./input/active_Surette_sample_info_sheet.csv)
        * [input/active_mergetab_nochim.rds](./input/active_mergetab_nochim.rds)
    * **Output files:** 
        * [data/merged_maptab.rds](./data/merged_maptab.rds) is the mapfile
          created by merging the IMAGINE sheet and the Surette lab sheet. It
          might contain duplicate sample IDs, if there were duplicates at the
          reconciliation step. The goal is to resolve all those duplicates, but
          for now there are some. This file will contain both sequenced and
          unsequenced samples, as well as all negative controls. 
        * [data/merged_seqtab.rds](./data/merged_seqtab.rds) is the transposed
          ASV table (taxa are rows), with the resequenced samples merged. It
          will contain negative controls and has not been in any way filtered
          except to remove samples that should have been discarded. The column
          names correspond to the `Study.ID` column in the mapfile
        * [stats/track_counts.csv](./stats/track_counts.csv) is a table that
          tracks the numbers of taxa and samples at each step in the data
          cleaning process. It is created here and the first two lines are
          written.
        * A variety of duplicate/missing sample files in
          [intermed/](./intermed/). These will vary depending on what's up with
          the spreadsheets.
    * This should always be run interactively, using something like RStudio, so
      you can look at the output at each step and make decisions. It will
      probably need to be changed/updated every time the files in
      [input/](./input/) are updated. Running this should be the responsibility
      of one person. Currently that person is Jake. Everything downstream of
      this can be run via a Makefile or Nextflow workflow or similar.
1. [01_assign_tax_asvs.R](./scripts/01_assign_tax_asvs.R)
    * **Input files:** 
        * [data/merged_seqtab.rds](./data/merged_seqtab.rds)
        * [refs/silva_nr99_v138_train_set.fa](./refs/silva_nr99_v138_train_set.fa)
    * **Output file:** 
        * [data/merged_taxtab.rds](./data/merged_taxtab.rds)
        * Writes a line to [stats/track_counts.csv](./stats/track_counts.csv)
    * This assigns taxonomy to the merged, transposed ASV table from step 0. It
      takes `data/merged_seqtab.rds` and `refs/silva_nr99_v138_train_set.fa` as
      inputs and creates `data/merged_taxtab.rds`. I'm not using the wSpecies
      file because the dada2 authors are clear that species should only be
      assigned via 100% alignment identity, not the heuristic assignment
      algorithm.
    * This should be run under `sbatch`. The script to do that is in
      [sbatch/01_run_assign_tax_asvs.sh](./sbatch/01_run_assign_tax_asvs.sh).

Everything downstream of this is either in the `asvs/` or `cluster99/` directory
within `scripts/.

#### [asvs/](./scripts/asvs)

2. [02_make_full.R](./scripts/asvs/02_make_ps_full.R)
    * **Input files:**
        * [data/merged_taxtab.rds](./data/merged_taxtab.rds)
        * [data/merged_seqtab.rds](./data/merged_seqtab.rds)
        * [data/merged_maptab.rds](./data/merged_maptab.rds)
    * **Output files:**
        * [cleaned/asvs/full/full_ps.Rdata](./cleaned/asvs/full/full_ps.Rdata)
        * [cleaned/asvs/full/full_seqs.Rdata](./cleaned/asvs/full/full_seqs.Rdata)
        * [cleaned/asvs/full/full_mat.Rdata](./cleaned/asvs/full/full_mat.Rdata)
        * [cleaned/asvs/full/full_asv.Rdata](./cleaned/asvs/full/full_asv.Rdata)
        * [cleaned/asvs/full/full_tax.Rdata](./cleaned/asvs/full/full_tax.Rdata)
        * [cleaned/asvs/full/full_map.Rdata](./cleaned/asvs/full/full_map.Rdata)
        * Writes 5 lines to [stats/track_counts.csv](./stats/track_counts.csv)
    * This takes all three files in `data/` as input and produces a phyloseq
      object and corresponding named vector of sequences in an RData file as
      output. This script removes host ASVs and any samples that have duplicate
      sample IDs, but does no other read depth, abundance, or prevalence
      filtering and does not remove negative controls.
    * This needs to be run under `sbatch` because it uses more RAM than Nibi
      gives the login nodes.
3. [03_make_ps_samfilt.R](./scripts/asvs/03_make_ps_samfilt.R)
    * **Input file:**
        * [cleaned/asvs/full/full_ps.Rdata](./cleaned/asvs/full/full_ps.Rdata)
    * **Output files:**
        * [cleaned/asvs/samfilt/samfilt_ps.Rdata](./cleaned/asvs/samfilt/samfilt_ps.Rdata)
        * [cleaned/asvs/samfilt/seqs_samfilt.Rdata](./cleaned/asvs/samfilt/seqs_samfilt.Rdata)
        * [cleaned/asvs/samfilt/samfilt_mat.Rdata](./cleaned/asvs/samfilt/samfilt_mat.Rdata)
        * [cleaned/asvs/samfilt/samfilt_asv.Rdata](./cleaned/asvs/samfilt/samfilt_asv.Rdata)
        * [cleaned/asvs/samfilt/samfilt_tax.Rdata](./cleaned/asvs/samfilt/samfilt_tax.Rdata)
        * [cleaned/asvs/samfilt/samfilt_map.Rdata](./cleaned/asvs/samfilt/samfilt_map.Rdata)
        * Writes 5 lines to [stats/track_counts.csv](./stats/track_counts.csv)
    * Filters out negative controls and any samples with less than 10k reads.
      Removes any taxa that are 0 everywhere once those samples have been
      removed.

#### [cluster99/](./scripts/cluster99/)

3. [03_make_clusters99.R](./scripts/cluster99/03_make_clusters99.R)
    * **Input file:**
        * [cleaned/asvs/full/full_seqs.Rdata'](./cleaned/asvs/full/full_seqs.Rdata)
    * **Output file:**
        * [intermed/clsts99.Rdata](./intermed/clsts99.Rdata)
        * Writes 2 lines to [stats/track_counts.csv](./stats/track_counts.csv)
    * This takes just the sequence vector (`full_seqs.Rdata`) and runs the 99%
      clustering on it. It returns a table of clusters that can then be used to
      create a new OTU table.
    * Can be run under sbatch, but does not have to be. The more cores you can
      give it, the faster it runs, but it doesn't take much RAM.
4. [04_cluster_distributions99.R](./scripts/cluster99/04_cluster_distributions99.R)
    * **Input file:**
        * [intermed/clsts99.Rdata](./intermed/clsts99.Rdata)
    * **Output files:**
        * [stats/cluster_size_distribution99.csv](./stats/cluster_size_distribution99.csv)
        * [stats/cluster_size_distribution99.png](./stats/cluster_size_distribution99.png)
    * This creates a csv of the counts of clusters of various sizes, as well as
      a plot, for QC of clustering.
    * Doesn't need to be run under sbatch. Currently no script to do so.
5. [05_get_conseq99.R](./scripts/cluster99/05_get_conseq99.R)
    * **Input file:**
       * [intermed/clsts99.Rdata](./intermed/clsts99.Rdata)
    * **Output file:**
       * [intermed/conseqs99.csv](./intermed/conseqs99.csv)
        * Writes 1 line to [stats/track_counts.csv](./stats/track_counts.csv)
    * **Requires:**
        * [scripts/functions.R](./scripts/functions.R)
    * Gets the consensus sequence for each 99% cluster from its member
      sequences. Not currently run under sbatch because I can't get doParallel
      working correctly, but it runs fine on a login node.
6. [06_cluster_counts99.R](./scripts/cluster99/06_cluster_counts99.R)
    * **Input files:**
        * [intermed/clsts99.Rdata](./intermed/clsts99.Rdata)
        * [intermed/conseqs9.csv](./intermed/conseqs9.csv)
        * [cleaned/full/full_mat.Rdata](./cleaned/full/full_mat.Rdata)
    * **Output file:**
        * [intermed/clstab99.csv](./intermed/clstab99.csv)
        * Writes 1 line to [stats/track_counts.csv](./stats/track_counts.csv)
    * **Requires:**
        * [scripts/functions.R](./scripts/functions.R)
    * Adds up the counts within a cluster within sample to make a cluster count
      table
    * Is not (currently) parallelized but doesn't take super long. Needs to be
      run under sbatch because it uses a stupid amount of RAM.
7. [07_assign_tax_clsts99.sh](./scripts/cluster99/07_assign_tax_clsts99.sh)
    * **Input file:**
        * [intermed/conseqs99.csv](./intermed/conseqs99.csv)
    * **Output file:**
        * [intermed/clstaxtab99.csv](./intermed/clstaxtab99.csv)
        * Writes 1 line to [stats/track_counts.csv](./stats/track_counts.csv)
    * **Requires:**
        * [scripts/functions.R](./scripts/functions.R)
    * Assigns taxonomy to the consensus sequences of the clusters.
    * Doesn't need to be run under sbatch. Currently no script to do so.
8. [08_make_full99.R](./scripts/cluster9/08_make_full99.R)
    * **Input files:**
        * [intermed/clstaxtab99.csv](./intermed/clstaxtab99.csv)
        * [intermed/clstab99.csv](./intermed/clstab99.csv)
        * [cleaned/asvs/full/full_map.csv](./cleaned/asvs/full/full_map.csv)
    * **Output files:**
        * [cleaned/cluster99/full/full99_ps.Rdata](./cleaned/cluster99/full/full99_ps.Rdata)
        * [cleaned/cluster99/full/full99_seqs.Rdata](./cleaned/cluster99/full/full99_seqs.Rdata)
        * [cleaned/cluster99/full/full99_mat.Rdata](./cleaned/cluster99/full/full99_mat.Rdata)
        * [cleaned/cluster99/full/full99_otu.Rdata](./cleaned/cluster99/full/full99_otu.Rdata)
        * [cleaned/cluster99/full/full99_tax.Rdata](./cleaned/cluster99/full/full99_tax.Rdata)
        * [cleaned/cluster99/full/full99_map.Rdata](./cleaned/cluster99/full/full99_map.Rdata)
        * Writes 5 lines to [stats/track_counts.csv](./stats/track_counts.csv)
    * This takes the clustered count and tax tables in `intermed/` and the
      cleaned mapfile from `cleaned/asvs/full/full_map.csv` and creates a
      phyloseq object and corresponding named vector of sequences in an RData
      file as output. This script removes host OTUs and any samples that have
      duplicate sample IDs, but does no other read depth, abundance, or
      prevalence filtering and does not remove negative controls.
    * This does not need to be run under `sbatch` and there is currently no
      script to do so.
9. [09_make_samfilt_99.R](./scripts/cluster99/09_make_samfilt_99.R)
    * **Input file:**
        * [cleaned/cluster99/full/full99_ps.Rdata](./cleaned/cluster99/full/full99_ps.Rdata)
    * **Output files:**
        * [cleaned/cluster99/samfilt/samfilt99_ps.Rdata](./cleaned/cluster99/samfilt/samfilt99_ps.Rdata)
        * [cleaned/cluster99/samfilt/otu99_seqs_samfilt.Rdata](./cleaned/cluster99/samfilt/otu99_seqs_samfilt.Rdata)
        * [cleaned/cluster99/samfilt/samfilt99_mat.Rdata](./cleaned/cluster99/samfilt/samfilt99_mat.Rdata)
        * [cleaned/cluster99/samfilt/samfilt99_otu.Rdata](./cleaned/cluster99/samfilt/samfilt99_otu.Rdata)
        * [cleaned/cluster99/samfilt/samfilt99_tax.Rdata](./cleaned/cluster99/samfilt/samfilt99_tax.Rdata)
        * [cleaned/cluster99/samfilt/samfilt99_map.Rdata](./cleaned/cluster99/samfilt/samfilt99_map.Rdata)
        * Writes 5 lines to [stats/track_counts.csv](./stats/track_counts.csv)
    * Filters out negative controls and any samples with less than 10k reads.
      Removes any taxa that are 0 everywhere once those samples have been
      removed.

### SBATCH

Scripts that require more RAM or cores than a login node provides, or that just
take a long time, need to be run under `slurm` using `sbatch`. The scripts that
control that are in this directory and are pretty self-explanatory. They are:

* [01_run_assign_tax_asvs.sh](./sbatch/01_run_assign_tax_asvs.sh)
* (./sbatch/asvs/)
    * [02_run_make_full.sh](./sbatch/asvs/02_run_make_full.sh)
    * [03_run_make_samfilt.sh](./sbatch/asvs/03_run_make_samfilt.sh)
* (./sbatch/cluster99/)
    * [03_run_make_clusters99.sh](./sbatch/cluster99/03_run_make_clusters99.sh)
    * [06_run_cluster_counts99.sh](./sbatch/cluster99/06_run_cluster_counts99.sh)
    * [07_run_assign_tax_99.sh](./sbatch/cluster99/07_run_assign_tax_99.sh)

