#!/bin/bash

#SBATCH --cpus-per-task=15
#SBATCH --mem=50G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=00_manual_qc_steps
#SBATCH --time=00:30:00
#SBATCH --account=rrg-surette


echo module load r/4.5.0
module load r/4.5.0

echo Rscript --vanilla -e 'rmarkdown::render("scripts/00_manual_qc_steps.Rmd",  output_dir = "./", knit_root_dir = "../", output_file = "manual_qc_steps.html")'
Rscript --vanilla -e 'rmarkdown::render("scripts/00_manual_qc_steps.Rmd",  output_dir = "./", knit_root_dir = "../", output_file = "manual_qc_steps.html")'
