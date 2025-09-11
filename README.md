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

### Raw Inputs 

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

### Data Files

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
removed, and most of them have also had low-read-count samples removed. There
are options for ASVs or for 99%-clustered OTUs. The specific files are listed
below:

1. [asvs/](./cleaned/asvs/)
    * files that are cleaned, filtered, and ready for analysis using unclustered
      asvs.
    * Contains two subdirectories: `full/` and `samfilt`
    1. [full/](./cleaned/asvs/full/):
        * All files in this directory are generated by
          [02_make_full.R](./scripts/asvs/02_make_full.R)
        * [full_ps.Rdata](./cleaned/asvs/full/full_ps.Rdata)
            * An `Rdata` file that contains two objects:
                * `ps_full` is a phyloseq object with all the non-discard
                  samples and all non-host ASVs. It has not been clustered or
                  filtered except to remove host. For now, samples with
                  duplicate IDs are removed from this dataset, but the goal is
                  to deal with all the duplicate IDs that have come from the
                  IMAGINE metadata so that these contain all the samples in the
                  [data/](./data/) files.
                * `seqs` is a named vector of DNA sequences that correspond to
                  the taxa in the phyloseq object. They are named the same as
                  the taxa so you can tell which is which. I always remove
                  sequences to their own vector in order to reduce clutter in my
                  objects and dataframes, but it does mean you have to be
                  careful not to rename the taxa in the phyloseq object or you
                  will not be able to reconnect them to their sequences
        * [full_seqs.Rdata](./cleaned/asvs/full/full_seqs.Rdata)
            * the same `seqs` vector as above, but packaged separately so you
              don't have to load the whole phyloseq object if all you need is
              the sequences.
        * [full_mats.Rdata](./cleaned/asvs/full/full_mats.Rdata)
            * The same data as in `full_ps`, but in two matrices: `full_asvtab`
              and `full_taxtab`, and one data frame: `full_maptab`. The tax and
              asv tables have sequences as their rownames.
        * [full_asv.csv](./cleaned/asvs/full/full_asv.csv)
            * A `.csv` version of the asv count matrix above
        * [full_tax.csv](./cleaned/asvs/full/full_tax.csv)
            * A `.csv` version of the tax table matrix above
        * [full_map.csv](./cleaned/asvs/full/full_map.csv)
            * A `.csv` version of the map table above. This is the first mapfile
              that is guaranteed not to have any repeat Study IDs, so it's the
              one to use downstream.
    2. [samfilt/](./cleaned/asvs/samfilt/)
        * Contains a dataset that is derived from the one in `full/`. Has had
          all negative control samples removed, as well as all samples with <10k
          reads. Any ASVs that were 0 everywhere after the low-read-count
          samples were removed are also removed, but no further prevalence or
          abundance filtering has been done.
        * All files in this directory are generated by
          [03_make_ps_samfilt.R](./scripts/asvs/03_make_ps_samfilt.R)

    
2. [cluster99/](./cleaned/cluster99/)
    * Files that are cleaned, filtered, and ready for analysis using taxa
      clustered at the 99% similarity level.
    * Contains two subdirectories: `full/` and `samfilt/` as above
    * [full/](./cleaned/cluster99/full/)
        * All files in this directory are generated by
          [08_make_full99.R](./scripts/cluster99/08_make_full99.R).
        * [full99_ps.Rdata](./cleaned/cluster99/full/full99_ps.Rdata)
            * An `Rdata` file that contains two objects:
                * `ps99_full` is a phyloseq object with all the non-discard
                  samples and all non-host OTUs. It has not been 
                  filtered except to remove host. For now, samples with
                  duplicate IDs are removed from this dataset, but the goal is
                  to deal with all the duplicate IDs that have come from the
                  IMAGINE metadata so that these contain all the samples in the
                  [data/](./data/) files.
                * `otu_seqs` is a named vector of consensus sequences that
                  correspond to the clustered OTUs in the phyloseq object. They
                  are named the same as the phyloseq taxa so you can tell which
                  is which. I always remove sequences to their own vector in
                  order to reduce clutter in my objects and dataframes, but it
                  does mean you have to be careful not to rename the taxa in the
                  phyloseq object or you will not be able to reconnect them to
                  their sequences
        * [full99_seqs.Rdata](./cleaned/cluster99/full/full99_seqs.Rdata)
            * the same `otu_seqs` vector as above, but packaged separately so
              you don't have to load the whole phyloseq object if all you need
              is the sequences.
        * [full99_mats.Rdata](./cleaned/cluster99/full/full99_mats.Rdata)
            * The same data as in `full99_ps`, but in two matrices:
              `full99_asvtab` and `full99_taxtab`, and one data frame:
              `full99_maptab`. The tax and otu tables have sequences as their
              rownames.
        * [full99_asv.csv](./cleaned/cluster99/full/full_asv.csv)
            * A `.csv` version of the asv count matrix above
        * [full99_tax.csv](./cleaned/cluster99/full/full_tax.csv)
            * A `.csv` version of the tax table matrix above
        * [full99_map.csv](./cleaned/cluster99/full/full_map.csv)
            * A `.csv` version of the map table above

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
        * duplicate/missing sample files in [intermed/](./intermed/). These will
          vary depending on what's up with the spreadsheets.
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
    * This assigns taxonomy to the merged, transposed ASV table from step 0. It
      takes `data/merged_seqtab.rds` and `refs/silva_nr99_v138_train_set.fa`
      as inputs and creates `data/merged_taxtab.rds`. I'm not using the wSpecies
      file because the dada2 authors are clear that species should only be
      assigned via 100% alignment identity, not the heuristic assignment
      algorithm.
    * This should be run under `sbatch`. The script to do that is in
      [sbatch/01_run_assign_tax_asvs.sh](./sbatch/01_run_assign_tax_asvs.sh).

Everything downstream of this is either in the `asvs` or `cluster99` directory.

#### [asvs/](./scripts/asvs)

    2. [02_make_full.R](./scripts/asvs/02_make_ps_full.R)
        * **Input files:**
            * [data/merged_taxtab.rds](./data/merged_taxtab.rds)
            * [data/merged_seqtab.rds](./data/merged_seqtab.rds)
            * [data/merged_maptab.rds](./data/merged_maptab.rds)
        * **Output files:**
            * [cleaned/full/full_ps.Rdata](./cleaned/full/full_ps.Rdata)
            * [cleaned/full/full_seqs.Rdata](./cleaned/full/full_seqs.Rdata)
            * [cleaned/full/full_mat.Rdata](./cleaned/full/full_mat.Rdata)
            * [cleaned/full/full_asv.Rdata](./cleaned/full/full_asv.Rdata)
            * [cleaned/full/full_tax.Rdata](./cleaned/full/full_tax.Rdata)
            * [cleaned/full/full_map.Rdata](./cleaned/full/full_map.Rdata)
        * This takes all three files in `data/` as input and produces a
          phyloseq object and corresponding named vector of sequences in an
          RData file as output. This script removes host ASVs and any samples
          that have duplicate sample IDs, but does no other read depth,
          abundance, or prevalence filtering and does not remove negative
          controls.
        * The file produced in the [cleaned/](./cleaned/) directory is
        * This needs to be run under `sbatch` because it uses more RAM than Nibi
          gives the login nodes. The script to do that is in
          [sbatch/asvs/02_run_make_full.sh](./sbatch/asvs/02_run_make_full.sh).
    3. [03_make_ps_samfilt.R](./scripts/asvs/03_make_ps_samfilt.R)
        * **Input file:**
            * [cleaned/asvs/full/full_ps.Rdata](./cleaned/asvs/full/full_ps.Rdata)
        * **Output files:**
            * [cleaned/asvs/samfilt/samfilt_ps.Rdata](./cleaned/asvs/samfilt/samfilt_ps.Rdata)
            * [cleaned/asvs/samfilt/seqs_samfilt.Rdata](./cleaned/asvs/samfilt/seqs_samfilt.Rdata)
        * Filters out negative controls and any samples with &lt; 10k reads.
          Removes any taxa that are 0 everywhere once those samples have been
          removed.
#### [cluster99/](./scripts/cluster99/)

    3. [03_make_clusters99.R](./scripts/cluster99/03_make_clusters99.R)
        * **Input file:**
            * [cleaned/full_seqs.Rdata'](./cleaned/full_seqs.Rdata)
        * **Output file:**
            * [intermed/clst99.Rdata](./intermed/clst99.Rdata)
        * This takes just the sequence vector (`full_seqs.Rdata`) and runs the
          99% clustering on it. It returns a table of clusters that can then be
          used to create a new OTU table. This step is separated out into its
          own script because it takes forever and the next steps can be
          error-prone.
        * Can be run under sbatch, but does not have to be. The more cores you
          can give it, the faster it runs, but it doesn't take much RAM. The
          script to run it under sbatch is at
          [sbatch/cluster99/03_run_make_clusters99.sh](./sbatch/cluster99/03_run_make_clusters99.sh)
    4. [04_cluster_distributions99.R](./scripts/cluster99/04_cluster_distributions99.R)
        * **Input file:**
            * [intermed/clst99.Rdata](./intermed/clst99.Rdata)
        * **Output files:**
            * [stats/cluster_size_distribution99.csv](./stats/cluster_size_distribution99.csv)
            * [stats/cluster_size_distribution99.png](./stats/cluster_size_distribution99.png)
        * This creates a csv of the counts of clusters of various sizes, as well
          as a plot, for QC of clustering.
        * Doesn't need to be run under sbatch. Currently no script to do so.
    5. [05_get_conseq99.R](./scripts/cluster99/05_get_conseq99.R)
        * **Input file:**
           * [intermed/clst99.Rdata](./intermed/clst99.Rdata)
        * **Output file:**
           * [intermed/conseqs99.csv](./intermed/conseqs99.csv)
        * **Requires:**
            * [scripts/functions.R](./scripts/functions.R)
        * Gets the consensus sequence for each 99% cluster from its member
          sequences. Not currently run under sbatch because I can't get
          doParallel working correctly. Need to fix that before this can be
          easily run
    6. [06_cluster_counts99.R](./scripts/cluster99/06_cluster_counts99.R)
        * **Input files:**
            * [intermed/clst99.Rdata](./intermed/clst99.Rdata)
            * [intermed/conseqs9.csv](./intermed/conseqs9.csv)
            * [cleaned/full/full_mat.Rdata](./cleaned/full/full_mat.Rdata)
        * **Output file:**
            * [intermed/clstab99.csv](./intermed/clstab99.csv)
        * **Requires:**
            * [scripts/functions.R](./scripts/functions.R)
        * Adds up the counts within a cluster within sample to make a cluster
          count table
        * Is not (currently) parallelized but doesn't take super long. Needs to
          be run under sbatch because it uses a stupid amount of RAM. The script
          to do that is in
          [sbatch/cluster99/06_run_cluster_counts99.sh](./sbatch/cluster99/run_cluster_counts99.sh)
    7. [07_assign_tax_clsts99.sh](./scripts/cluster99/07_assign_tax_clsts99.sh)
        * **Input file:**
            * [intermed/conseqs99.csv](./intermed/conseqs99.csv)
        * **Output file:**
            * [intermed/clstaxtab99.csv](./intermed/clstaxtab99.csv)
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
        * This takes the clustered count and tax tables in `intermed/` and the
          cleaned mapfile from `cleaned/asvs/full/full_map.csv` and creates a
          phyloseq object and corresponding named vector of sequences in an
          RData file as output. This script removes host OTUs and any samples
          that have duplicate sample IDs, but does no other read depth,
          abundance, or prevalence filtering and does not remove negative
          controls.
        * This does not need to be run under `sbatch` and there is currently no
          script to do so.
    9. [09_make_samfilt_99.R](./scripts/cluster99/09_make_samfilt_99.R)
        * **Input file:**
            * [cleaned/cluster99/full/full99_ps.Rdata](./cleaned/cluster99/full/full99_ps.Rdata)
        * **Output files:**
            * [cleaned/cluster99/samfilt/samfilt99_ps.Rdata](./cleaned/cluster99/samfilt/samfilt99_ps.Rdata)
            * [cleaned/cluster99/samfilt/otu99_seqs_samfilt.Rdata](./cleaned/cluster99/samfilt/otu99_seqs_samfilt.Rdata)
        * Filters out negative controls and any samples with &lt; 10k reads.
          Removes any taxa that are 0 everywhere once those samples have been
          removed.
