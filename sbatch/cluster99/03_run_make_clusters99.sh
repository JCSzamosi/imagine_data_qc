#!/bin/bash

#SBATCH --cpus-per-task=40
#SBATCH --mem=8G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=03_make_clusters99.R
#SBATCH --time=02:00:00
#SBATCH --account=rrg-surette

echo module load r/4.5.0
module load r/4.5.0

echo Rscript ./scripts/cluster99/03_make_clusters99.R
Rscript ./scripts/cluster99/03_make_clusters99.R
