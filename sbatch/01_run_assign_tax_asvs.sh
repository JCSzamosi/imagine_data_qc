#!/bin/bash

#SBATCH --cpus-per-task=30
#SBATCH --mem=30G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=01_assign_tax_asvs
#SBATCH --time=00:45:00
#SBATCH --account=rrg-surette

echo module load r/4.5.0
module load r/4.5.0

echo Rscript ./scripts/01_assign_tax_asvs.R
Rscript ./scripts/01_assign_tax_asvs.R
