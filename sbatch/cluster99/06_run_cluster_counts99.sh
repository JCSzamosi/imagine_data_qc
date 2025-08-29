#!/bin/bash

#SBATCH --cpus-per-task=10
#SBATCH --mem=150G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=06_cluster_counts99
#SBATCH --time=00:30:00
#SBATCH --account=rrg-surette

echo module load r/4.5.0
module load r/4.5.0

echo Rscript ./scripts/cluster99/06_cluster_counts99.R
Rscript ./scripts/cluster99/06_cluster_counts99.R
