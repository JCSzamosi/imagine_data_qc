#!/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=60G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=08_make_full_99
#SBATCH --time=00:15:00
#SBATCH --account=rrg-surette

echo module load r/4.5.0
module load r/4.5.0

echo Rscript ./scripts/cluster99/08_make_full99.R
Rscript ./scripts/cluster99/08_make_full99.R
