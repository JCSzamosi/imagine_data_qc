#!/bin/bash

#SBATCH --cpus-per-task=25
#SBATCH --mem=10G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=07_assign_tax_cl99
#SBATCH --time=00:10:00
#SBATCH --account=rrg-surette

echo module load r/4.5.0
module load r/4.5.0

echo Rscript ./scripts/cluster99/07_assign_tax_clsts99.R
Rscript ./scripts/cluster99/07_assign_tax_clsts99.R
